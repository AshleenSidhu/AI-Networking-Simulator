import 'dart:async';

import '../models/transcript_turn.dart';
import 'gemini_live_service.dart';

/// Browser-STT + Gemini-text + browser-TTS fallback path.
///
/// **Status: stub.** The dart:js_interop bindings for
/// `webkitSpeechRecognition` are sensitive to Dart SDK version (the
/// `callAsConstructor` extension surfaced inconsistencies across SDKs).
/// For the demo we stick to either:
///   - `USE_MOCKS=true` (canned conversation), or
///   - the real [RealGeminiLiveService] (WebSocket + audio worklet).
///
/// If the live path needs an insurance route on stage, the proper impl
/// would: (1) ship a small `web/connect_ai_helpers.js` that exposes
/// `__ca_newSpeechRecognition()` as a JS factory, (2) `@JS`-bind it in
/// Dart, (3) wire the start/stop/onresult lifecycle the same way the
/// previous attempt did. ~30 minutes of work.
class SttFallbackService implements GeminiLiveService {
  SttFallbackService({required this.apiKey});

  final String apiKey;
  final _transcriptCtrl = StreamController<TranscriptTurn>.broadcast();
  final _speakingCtrl = StreamController<bool>.broadcast();

  @override
  Stream<TranscriptTurn> get transcripts => _transcriptCtrl.stream;

  @override
  Stream<bool> get isAiSpeaking => _speakingCtrl.stream;

  @override
  Future<void> connect({
    required String systemInstruction,
    required String voice,
  }) async {
    throw UnimplementedError(
      'STT fallback is stubbed in this build. Run with '
      '--dart-define=USE_MOCKS=true for the demo flow, or supply '
      'GEMINI_API_KEY and use the realtime path. See BACKEND_LOG.md.',
    );
  }

  @override
  Future<void> disconnect() async {
    _speakingCtrl.add(false);
  }

  @override
  void setMuted(bool muted) {}
}
