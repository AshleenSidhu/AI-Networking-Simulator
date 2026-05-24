import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/transcript_turn.dart';
import 'audio_io.dart';
import 'env.dart';
import 'gemini_live_service_real.dart';
import 'stt_fallback_service.dart';

/// The real-time voice contract used by [SessionController]. Owns the
/// WebSocket to Gemini Live, the audio worklet round-trip, and emits
/// transcript deltas as they arrive.
///
/// Implementations:
/// - [MockGeminiLiveService]: in-memory canned 5-turn conversation. Used
///   when `USE_MOCKS=true`.
/// - `RealGeminiLiveService` (in `gemini_live_service_real.dart`): the
///   actual WS client. Loaded by [geminiLiveServiceProvider] when not mocking.
abstract class GeminiLiveService {
  /// Stream of transcript turns. Partial turns arrive multiple times with
  /// the same id and `isPartial: true` until the model finalizes.
  Stream<TranscriptTurn> get transcripts;

  /// True while audio is being played back. Used by the call screen to
  /// animate the soundwave.
  Stream<bool> get isAiSpeaking;

  /// Open the WS, send the setup frame, start pumping mic frames.
  /// Completes when the server reports `setup_complete`.
  Future<void> connect({
    required String systemInstruction,
    required String voice,
  });

  /// Tear down the WS, drain the audio queues, stop the mic.
  Future<void> disconnect();

  /// Mutes the mic stream upstream of the WS so we don't waste bandwidth
  /// sending silence. Push-to-talk overrides this in [SessionController].
  void setMuted(bool muted);
}

/// In-memory mock that emits a canned 5-turn conversation with realistic
/// delays. Use to build screens without a Gemini API key.
class MockGeminiLiveService implements GeminiLiveService {
  final _transcriptCtrl = StreamController<TranscriptTurn>.broadcast();
  final _speakingCtrl = StreamController<bool>.broadcast();
  final _uuid = const Uuid();
  Timer? _scriptTimer;
  bool _muted = false;
  bool _connected = false;

  static const _script = <(Speaker, String, Duration)>[
    (
      Speaker.ai,
      "Hi! Thanks for hopping on the call. To get started — could you tell me a bit about your background?",
      Duration(milliseconds: 1500),
    ),
    (
      Speaker.user,
      "Of course — I'm a recent computer science grad, mostly focused on backend systems.",
      Duration(seconds: 6),
    ),
    (
      Speaker.ai,
      "Got it. What's drawing you to our team specifically?",
      Duration(seconds: 4),
    ),
    (
      Speaker.user,
      "I really like the infrastructure work your team is publishing.",
      Duration(seconds: 5),
    ),
    (
      Speaker.ai,
      "Excellent. Walk me through how you'd approach scaling our event pipeline if traffic doubled overnight.",
      Duration(seconds: 4),
    ),
  ];

  @override
  Stream<TranscriptTurn> get transcripts => _transcriptCtrl.stream;

  @override
  Stream<bool> get isAiSpeaking => _speakingCtrl.stream;

  @override
  Future<void> connect({
    required String systemInstruction,
    required String voice,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _connected = true;
    _runScript();
  }

  void _runScript() {
    var index = 0;
    void next() {
      if (!_connected || index >= _script.length) return;
      final (speaker, text, delay) = _script[index++];
      _scriptTimer = Timer(delay, () {
        if (!_connected) return;
        if (speaker == Speaker.ai) _speakingCtrl.add(true);
        _transcriptCtrl.add(TranscriptTurn(
          id: _uuid.v4(),
          speaker: speaker,
          text: text,
          timestamp: DateTime.now(),
        ));
        if (speaker == Speaker.ai) {
          Timer(Duration(milliseconds: 80 * text.split(' ').length), () {
            if (_connected) _speakingCtrl.add(false);
          });
        }
        next();
      });
    }
    next();
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _scriptTimer?.cancel();
    _scriptTimer = null;
    _speakingCtrl.add(false);
  }

  @override
  void setMuted(bool muted) => _muted = muted;

  /// Exposed for test purposes only.
  bool get debugMuted => _muted;
}

/// Riverpod provider. Selects an implementation in priority order:
/// 1. `USE_MOCKS=true` → Mock (canned conversation).
/// 2. No `GEMINI_API_KEY` → Mock (frontend dev hasn't filled `.env`).
/// 3. `USE_LIVE=false` → STT fallback (browser STT + Gemini text + TTS).
/// 4. Default → [RealGeminiLiveService] (WebSocket + audio worklet).
final geminiLiveServiceProvider = Provider<GeminiLiveService>((ref) {
  if (useMocks) return MockGeminiLiveService();
  final key = geminiApiKey;
  if (key == null) return MockGeminiLiveService();
  if (!useLive) return SttFallbackService(apiKey: key);
  final audio = ref.watch(audioIoProvider);
  return RealGeminiLiveService(apiKey: key, audio: audio);
});
