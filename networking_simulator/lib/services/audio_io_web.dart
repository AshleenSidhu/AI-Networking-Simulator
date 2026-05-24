import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:web/web.dart' as web;

import 'audio_io.dart';

/// Real browser audio I/O. Backed by `web/audio_worklet.js`. See that file
/// for the mic resample + playback queue details.
class RealAudioIO implements AudioIO {
  web.AudioContext? _ctx;
  web.MediaStream? _stream;
  web.MediaStreamAudioSourceNode? _source;
  web.AudioWorkletNode? _mic;
  web.AudioWorkletNode? _playback;

  final _micCtrl = StreamController<Uint8List>.broadcast();
  final _playingCtrl = StreamController<bool>.broadcast();
  bool _initialized = false;

  @override
  Stream<Uint8List> get micFrames => _micCtrl.stream;

  @override
  Stream<bool> get isPlaying => _playingCtrl.stream;

  @override
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _ctx = web.AudioContext();
      await _ctx!.audioWorklet.addModule('audio_worklet.js'.toJS).toDart;

      final stream = await web.window.navigator.mediaDevices
          .getUserMedia(web.MediaStreamConstraints(audio: true.toJS))
          .toDart;
      _stream = stream;
      _source = _ctx!.createMediaStreamSource(stream);

      _mic = web.AudioWorkletNode(_ctx!, 'mic-processor');
      _mic!.port.onmessage = (web.MessageEvent event) {
        final data = event.data;
        if (data == null) return;
        // The worklet posts an ArrayBuffer of Int16 PCM, 16 kHz mono.
        final jsBuffer = data as JSArrayBuffer;
        final byteData = jsBuffer.toDart;
        _micCtrl.add(byteData.asUint8List());
      }.toJS;
      _source!.connect(_mic!);

      _playback = web.AudioWorkletNode(_ctx!, 'playback-processor');
      _playback!.connect(_ctx!.destination);
      _playback!.port.onmessage = (web.MessageEvent event) {
        final data = event.data;
        if (data == null) return;
        try {
          final obj = data as JSObject;
          final idle = obj.getProperty<JSBoolean?>('idle'.toJS);
          if (idle != null && idle.toDart) {
            _playingCtrl.add(false);
          }
        } catch (_) {}
      }.toJS;

      _initialized = true;
    } catch (e, st) {
      debugPrint('[RealAudioIO] initialize failed: $e\n$st');
      _initialized = false;
      rethrow;
    }
  }

  @override
  void enqueuePlayback(Uint8List pcm24k) {
    final node = _playback;
    if (node == null) return;
    final buffer = pcm24k.buffer.asInt8List().buffer.toJS;
    final payload = JSObject();
    payload.setProperty('pcm'.toJS, buffer);
    payload.setProperty('sourceRate'.toJS, 24000.toJS);
    node.port.postMessage(payload);
    _playingCtrl.add(true);
  }

  @override
  Future<void> stop() async {
    try {
      _stream?.getTracks().toDart.forEach((t) => t.stop());
      _mic?.disconnect();
      _playback?.disconnect();
      _source?.disconnect();
      await _ctx?.close().toDart;
    } catch (e) {
      debugPrint('[RealAudioIO] stop error: $e');
    } finally {
      _initialized = false;
    }
  }
}

/// Returned by the platform-conditional factory. On Flutter Web, this is
/// the real implementation. On non-web targets the stub is selected and
/// returns [MockAudioIO] instead.
AudioIO createRealAudioIO() => RealAudioIO();
