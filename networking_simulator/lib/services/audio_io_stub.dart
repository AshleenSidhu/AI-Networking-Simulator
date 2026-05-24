import 'audio_io.dart';

/// Non-web stub. Returned by the platform-conditional factory so that
/// `flutter test` (which runs on the host VM) and any non-web build can
/// still compile. The real implementation in `audio_io_web.dart` uses
/// dart:js_interop and only works in a browser.
AudioIO createRealAudioIO() => MockAudioIO();
