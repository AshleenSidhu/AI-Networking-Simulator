import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/transcript_turn.dart';
import 'audio_io.dart';
import 'env.dart';
import 'gemini_live_service.dart';

/// Real Gemini Live WebSocket client.
///
/// Hot loop:
/// 1. [connect] opens the WS and sends a `setup` frame.
/// 2. On `setupComplete`, [_attachAudioPipe] starts pumping mic frames
///    from [AudioIO] as base64 PCM chunks into `realtimeInput.mediaChunks`.
/// 3. Incoming `serverContent.modelTurn.parts` audio is base64-decoded
///    and forwarded to [AudioIO.enqueuePlayback].
/// 4. Incoming `serverContent.inputTranscription` / `outputTranscription`
///    are emitted as [TranscriptTurn]s on [transcripts].
///
/// The WS endpoint, model, and voice come from env.dart constants.
class RealGeminiLiveService implements GeminiLiveService {
  RealGeminiLiveService({required this.apiKey, required this.audio});

  final String apiKey;
  final AudioIO audio;

  WebSocketChannel? _ws;
  StreamSubscription? _wsSub;
  StreamSubscription<Uint8List>? _micSub;
  StreamSubscription<bool>? _playSub;
  final Completer<void> _setupComplete = Completer<void>();

  final _transcriptCtrl = StreamController<TranscriptTurn>.broadcast();
  final _speakingCtrl = StreamController<bool>.broadcast();
  final _uuid = const Uuid();

  bool _muted = false;
  bool _connected = false;
  String? _currentUserTurnId;
  String? _currentAiTurnId;
  final StringBuffer _userTurnText = StringBuffer();
  final StringBuffer _aiTurnText = StringBuffer();

  @override
  Stream<TranscriptTurn> get transcripts => _transcriptCtrl.stream;

  @override
  Stream<bool> get isAiSpeaking => _speakingCtrl.stream;

  @override
  Future<void> connect({
    required String systemInstruction,
    required String voice,
  }) async {
    final uri = Uri.parse(
      'wss://generativelanguage.googleapis.com/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent?key=$apiKey',
    );
    _ws = WebSocketChannel.connect(uri);
    _connected = true;

    _wsSub = _ws!.stream.listen(
      _onMessage,
      onError: (e) {
        debugPrint('[GeminiLive] WS error: $e');
        _transcriptCtrl.addError(e);
      },
      onDone: () {
        debugPrint('[GeminiLive] WS closed');
        _connected = false;
      },
    );

    // Setup frame.
    final setup = {
      'setup': {
        'model': 'models/$geminiLiveModel',
        'generation_config': {
          'response_modalities': ['AUDIO'],
          'speech_config': {
            'voice_config': {
              'prebuilt_voice_config': {'voice_name': voice}
            }
          },
        },
        'system_instruction': {
          'parts': [
            {'text': systemInstruction}
          ]
        },
        'input_audio_transcription': const <String, dynamic>{},
        'output_audio_transcription': const <String, dynamic>{},
      },
    };
    _ws!.sink.add(jsonEncode(setup));

    await _setupComplete.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        throw TimeoutException(
            'Gemini Live setup_complete not received in 15 s');
      },
    );

    await audio.initialize();
    _attachAudioPipe();
  }

  void _attachAudioPipe() {
    _micSub = audio.micFrames.listen(_onMicChunk);
    _playSub = audio.isPlaying.listen((playing) {
      // Forward AudioIO's playback-queue empty signal to consumers.
      if (!playing) _speakingCtrl.add(false);
    });
  }

  void _onMicChunk(Uint8List pcm16) {
    if (!_connected || _muted) return;
    final ws = _ws;
    if (ws == null) return;
    final b64 = base64Encode(pcm16);
    final frame = {
      'realtime_input': {
        'media_chunks': [
          {
            'mime_type': 'audio/pcm;rate=16000',
            'data': b64,
          }
        ],
      },
    };
    ws.sink.add(jsonEncode(frame));
  }

  void _onMessage(dynamic raw) {
    try {
      final text = raw is String
          ? raw
          : raw is List<int>
              ? utf8.decode(raw)
              : raw.toString();
      final msg = jsonDecode(text) as Map<String, dynamic>;

      if (msg.containsKey('setupComplete')) {
        if (!_setupComplete.isCompleted) _setupComplete.complete();
        return;
      }

      final server = msg['serverContent'] as Map<String, dynamic>?;
      if (server == null) return;

      // Input STT.
      final inputTrans = server['inputTranscription'] as Map<String, dynamic>?;
      if (inputTrans != null) {
        final fragment = inputTrans['text'] as String? ?? '';
        _currentUserTurnId ??= _uuid.v4();
        _userTurnText.write(fragment);
        _transcriptCtrl.add(TranscriptTurn(
          id: _currentUserTurnId!,
          speaker: Speaker.user,
          text: _userTurnText.toString(),
          timestamp: DateTime.now(),
          isPartial: true,
        ));
      }

      // Output (model) transcription + audio.
      final modelTurn = server['modelTurn'] as Map<String, dynamic>?;
      if (modelTurn != null) {
        final parts = (modelTurn['parts'] as List<dynamic>? ?? []);
        for (final part in parts) {
          final map = part as Map<String, dynamic>;
          final inlineData = map['inlineData'] as Map<String, dynamic>?;
          if (inlineData != null) {
            final mime = inlineData['mimeType'] as String? ?? '';
            if (mime.startsWith('audio/')) {
              final b64 = inlineData['data'] as String? ?? '';
              if (b64.isNotEmpty) {
                final pcm = base64Decode(b64);
                audio.enqueuePlayback(pcm);
                _speakingCtrl.add(true);
              }
            }
          }
        }
      }

      final outputTrans = server['outputTranscription'] as Map<String, dynamic>?;
      if (outputTrans != null) {
        final fragment = outputTrans['text'] as String? ?? '';
        _currentAiTurnId ??= _uuid.v4();
        _aiTurnText.write(fragment);
        _transcriptCtrl.add(TranscriptTurn(
          id: _currentAiTurnId!,
          speaker: Speaker.ai,
          text: _aiTurnText.toString(),
          timestamp: DateTime.now(),
          isPartial: true,
        ));
      }

      // Turn completion signals.
      final turnComplete = server['turnComplete'] as bool? ?? false;
      if (turnComplete) {
        _finalizeAndResetTurns();
      }
      final interrupted = server['interrupted'] as bool? ?? false;
      if (interrupted) {
        // Drain playback so the user can interject without overlap.
        _speakingCtrl.add(false);
      }
    } catch (e, st) {
      debugPrint('[GeminiLive] message parse error: $e\n$st\nraw: $raw');
    }
  }

  void _finalizeAndResetTurns() {
    if (_currentUserTurnId != null) {
      _transcriptCtrl.add(TranscriptTurn(
        id: _currentUserTurnId!,
        speaker: Speaker.user,
        text: _userTurnText.toString(),
        timestamp: DateTime.now(),
        isPartial: false,
      ));
      _currentUserTurnId = null;
      _userTurnText.clear();
    }
    if (_currentAiTurnId != null) {
      _transcriptCtrl.add(TranscriptTurn(
        id: _currentAiTurnId!,
        speaker: Speaker.ai,
        text: _aiTurnText.toString(),
        timestamp: DateTime.now(),
        isPartial: false,
      ));
      _currentAiTurnId = null;
      _aiTurnText.clear();
    }
  }

  @override
  void setMuted(bool muted) {
    _muted = muted;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    await _micSub?.cancel();
    await _playSub?.cancel();
    await _wsSub?.cancel();
    try {
      await _ws?.sink.close();
    } catch (_) {}
    await audio.stop();
    _speakingCtrl.add(false);
  }
}
