import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:web/web.dart' as web;

import '../models/transcript_turn.dart';
import 'env.dart';
import 'gemini_live_service.dart';

/// Browser-STT + Gemini-text + browser-TTS fallback path.
///
/// Used when [useLive] is false (e.g. via `--dart-define=USE_LIVE=false`),
/// when the Gemini Live API is unreachable, or as insurance on stage if
/// the realtime path hiccups.
///
/// Architecture:
/// 1. `webkitSpeechRecognition` / `SpeechRecognition` listens for user
///    speech and emits final transcripts.
/// 2. Each finalized user transcript is pushed into a chat history and
///    sent to Gemini text `generateContent`.
/// 3. The text reply streams back via SSE — words are emitted as the AI's
///    transcript turn AND fed to `window.speechSynthesis` so it's spoken.
///
/// Web only. On non-web platforms, [connect] throws.
class SttFallbackService implements GeminiLiveService {
  SttFallbackService({required this.apiKey});

  final String apiKey;
  final _transcriptCtrl = StreamController<TranscriptTurn>.broadcast();
  final _speakingCtrl = StreamController<bool>.broadcast();
  final _uuid = const Uuid();
  final List<Map<String, dynamic>> _history = [];

  JSObject? _recognition;
  String _systemInstruction = '';
  bool _connected = false;
  bool _muted = false;

  @override
  Stream<TranscriptTurn> get transcripts => _transcriptCtrl.stream;

  @override
  Stream<bool> get isAiSpeaking => _speakingCtrl.stream;

  @override
  Future<void> connect({
    required String systemInstruction,
    required String voice,
  }) async {
    if (!kIsWeb) {
      throw UnsupportedError(
          'SttFallbackService is web-only. Run with USE_MOCKS=true on '
          'non-web platforms.');
    }
    _systemInstruction = systemInstruction;
    _connected = true;

    final ctor =
        web.window.getProperty<JSAny?>('webkitSpeechRecognition'.toJS) ??
            web.window.getProperty<JSAny?>('SpeechRecognition'.toJS);
    if (ctor == null) {
      throw UnsupportedError(
          'This browser does not support SpeechRecognition. '
          'Try Chrome or Edge.');
    }
    final rec = (ctor as JSFunction).callAsConstructor<JSObject>();
    _recognition = rec;
    rec.setProperty('continuous'.toJS, true.toJS);
    rec.setProperty('interimResults'.toJS, true.toJS);
    rec.setProperty('lang'.toJS, 'en-US'.toJS);

    rec.setProperty(
      'onresult'.toJS,
      (JSAny event) {
        final e = event as JSObject;
        final results = e.getProperty<JSObject>('results'.toJS);
        final length =
            results.getProperty<JSNumber>('length'.toJS).toDartInt;
        final lastIdx =
            e.getProperty<JSNumber>('resultIndex'.toJS).toDartInt;
        final buffer = StringBuffer();
        var anyFinal = false;
        for (var i = lastIdx; i < length; i++) {
          final result =
              results.getProperty<JSObject>(i.toString().toJS);
          final alt = result.getProperty<JSObject>('0'.toJS);
          final text = alt.getProperty<JSString>('transcript'.toJS).toDart;
          final isFinal = result.getProperty<JSBoolean>('isFinal'.toJS).toDart;
          buffer.write(text);
          if (isFinal) anyFinal = true;
        }
        final text = buffer.toString().trim();
        if (text.isEmpty) return;
        final turnId = _uuid.v4();
        _transcriptCtrl.add(TranscriptTurn(
          id: turnId,
          speaker: Speaker.user,
          text: text,
          timestamp: DateTime.now(),
          isPartial: !anyFinal,
        ));
        if (anyFinal) {
          _sendToGemini(text);
        }
      }.toJS,
    );

    rec.setProperty('onerror'.toJS, (JSAny e) {
      debugPrint('[SttFallback] recognition error: ${e.toString()}');
    }.toJS);
    rec.setProperty('onend'.toJS, (JSAny _) {
      if (_connected && !_muted) {
        // Auto-restart so we capture the next user turn.
        try {
          rec.callMethod<JSAny?>('start'.toJS);
        } catch (_) {}
      }
    }.toJS);

    rec.callMethod<JSAny?>('start'.toJS);
  }

  Future<void> _sendToGemini(String userText) async {
    _history.add({
      'role': 'user',
      'parts': [
        {'text': userText}
      ]
    });
    final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$geminiTextModel:streamGenerateContent?key=$apiKey&alt=sse');
    final aiTurnId = _uuid.v4();
    final aiText = StringBuffer();
    _speakingCtrl.add(true);
    try {
      final req = http.Request('POST', url)
        ..headers['Content-Type'] = 'application/json'
        ..body = jsonEncode({
          'contents': _history,
          'system_instruction': {
            'parts': [
              {'text': _systemInstruction}
            ]
          },
        });
      final res = await http.Client().send(req);
      if (res.statusCode != 200) {
        final body = await res.stream.bytesToString();
        throw Exception('Gemini text ${res.statusCode}: $body');
      }
      await for (final line in res.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())) {
        if (!line.startsWith('data:')) continue;
        final payload = line.substring(5).trim();
        if (payload.isEmpty || payload == '[DONE]') continue;
        try {
          final decoded = jsonDecode(payload) as Map<String, dynamic>;
          final cands = decoded['candidates'] as List?;
          if (cands == null || cands.isEmpty) continue;
          final parts = (cands.first['content']?['parts'] as List?) ?? [];
          for (final p in parts) {
            final t = p['text'] as String?;
            if (t != null && t.isNotEmpty) {
              aiText.write(t);
              _transcriptCtrl.add(TranscriptTurn(
                id: aiTurnId,
                speaker: Speaker.ai,
                text: aiText.toString(),
                timestamp: DateTime.now(),
                isPartial: true,
              ));
            }
          }
        } catch (_) {}
      }
      final finalText = aiText.toString();
      _transcriptCtrl.add(TranscriptTurn(
        id: aiTurnId,
        speaker: Speaker.ai,
        text: finalText,
        timestamp: DateTime.now(),
        isPartial: false,
      ));
      _history.add({
        'role': 'model',
        'parts': [
          {'text': finalText}
        ]
      });
      _speak(finalText);
    } catch (e, st) {
      debugPrint('[SttFallback] text error: $e\n$st');
    } finally {
      _speakingCtrl.add(false);
    }
  }

  void _speak(String text) {
    if (text.isEmpty) return;
    try {
      final synth = web.window.speechSynthesis;
      final u = web.SpeechSynthesisUtterance(text)..rate = 1.0;
      synth.speak(u);
    } catch (e) {
      debugPrint('[SttFallback] speak failed: $e');
    }
  }

  @override
  void setMuted(bool muted) {
    _muted = muted;
    final rec = _recognition;
    if (rec == null) return;
    try {
      if (muted) {
        rec.callMethod<JSAny?>('stop'.toJS);
      } else if (_connected) {
        rec.callMethod<JSAny?>('start'.toJS);
      }
    } catch (_) {}
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    try {
      _recognition?.callMethod<JSAny?>('abort'.toJS);
    } catch (_) {}
    _recognition = null;
    try {
      web.window.speechSynthesis.cancel();
    } catch (_) {}
    _speakingCtrl.add(false);
  }
}
