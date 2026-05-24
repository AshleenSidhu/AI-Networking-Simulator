import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Build-time + env access. Read these constants — never reach into
/// `dotenv.env` from a widget or controller.

/// When true, every service uses its in-memory mock. Pass with
/// `flutter run --dart-define=USE_MOCKS=true`. Default: false.
const bool useMocks = bool.fromEnvironment('USE_MOCKS');

/// When false, the realtime voice loop is replaced by the
/// browser-STT + Gemini-text + browser-TTS fallback path. Default: true.
const bool useLive = bool.fromEnvironment('USE_LIVE', defaultValue: true);

/// Gemini Live model — flip to `gemini-2.0-flash-live-001` if the preview
/// model gates us. Half-cascaded but cheaper and good enough for demo.
const String geminiLiveModel = String.fromEnvironment(
  'GEMINI_LIVE_MODEL',
  defaultValue: 'gemini-2.5-flash-preview-native-audio-dialog',
);

/// Gemini text model for the judge + summary calls.
const String geminiTextModel = String.fromEnvironment(
  'GEMINI_TEXT_MODEL',
  defaultValue: 'gemini-2.5-flash',
);

/// Resolves the Gemini API key from .env. Returns null if .env failed to
/// load or the key is missing — caller decides whether to fall back to
/// mocks or raise.
String? get geminiApiKey {
  try {
    final v = dotenv.env['GEMINI_API_KEY'];
    return (v == null || v.isEmpty) ? null : v;
  } catch (_) {
    return null;
  }
}
