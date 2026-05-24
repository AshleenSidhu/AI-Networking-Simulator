import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'audio_io_stub.dart'
    if (dart.library.js_interop) 'audio_io_web.dart' as platform;
import 'env.dart';

/// Browser audio I/O contract used by [RealGeminiLiveService]. Wraps the
/// `web/audio_worklet.js` module that captures mic at 16 kHz mono PCM and
/// plays back 24 kHz mono PCM chunks the model emits.
abstract class AudioIO {
  /// One-time setup: load the worklet module, request mic permission,
  /// open the AudioContext. Throws if the user denies permission.
  Future<void> initialize();

  /// Stream of 16-bit little-endian PCM frames at 16 kHz, ~100 ms per chunk.
  /// Ready to base64-encode and ship as the Gemini Live `realtimeInput.audio`.
  Stream<Uint8List> get micFrames;

  /// Queue a 16-bit LE PCM chunk at 24 kHz for playback. Chunks are
  /// concatenated transparently so the model's chunked output sounds smooth.
  void enqueuePlayback(Uint8List pcm24k);

  /// Stop mic capture and drain the playback queue.
  Future<void> stop();

  /// Notifies when the playback queue is empty (proxy for "AI done speaking").
  Stream<bool> get isPlaying;
}

/// No-op mock for non-web platforms and for `USE_MOCKS=true`. Emits no
/// mic frames, discards playback chunks. Lets the rest of the controller
/// stack run without a real browser audio context.
class MockAudioIO implements AudioIO {
  final _micCtrl = StreamController<Uint8List>.broadcast();
  final _playingCtrl = StreamController<bool>.broadcast();

  @override
  Future<void> initialize() async {}

  @override
  Stream<Uint8List> get micFrames => _micCtrl.stream;

  @override
  Stream<bool> get isPlaying => _playingCtrl.stream;

  @override
  void enqueuePlayback(Uint8List pcm24k) {
    _playingCtrl.add(true);
    Timer(const Duration(milliseconds: 200), () => _playingCtrl.add(false));
  }

  @override
  Future<void> stop() async {}
}

final audioIoProvider = Provider<AudioIO>((ref) {
  if (useMocks) return MockAudioIO();
  return platform.createRealAudioIO();
});
