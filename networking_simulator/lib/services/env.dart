import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Build-time + env access. Read these constants — never reach into
/// `dotenv.env` from a widget or controller.

/// When true, every service uses its in-memory mock. Pass with
/// `flutter run --dart-define=USE_MOCKS=true`. Default: false.
const bool useMocks = bool.fromEnvironment('USE_MOCKS');

/// When false, the realtime voice loop is replaced by the
/// browser-STT + Gemini-text + browser-TTS fallback path. Default: true.
const bool useLive = bool.fromEnvironment('USE_LIVE', defaultValue: true);

/// Gemini Live model.
///
/// Naming has been turbulent — for posterity:
/// - `gemini-2.5-flash-preview-native-audio-dialog` (mid-2025) → 404, dead
/// - `gemini-live-2.5-flash-native-audio` (early-2026 docs alias) → 404 for
///   public API keys; docs-only string
/// - `gemini-2.0-flash-live-001` (GA half-cascaded) → server returns 1008
///   "not found for API version v1beta" on this key
/// - `gemini-2.5-flash-native-audio-preview-12-2025` (Dec 2025) → predecessor
/// - **`gemini-3.1-flash-live-preview` (Mar 2026, current default)** ← us
///
/// 3.1 migration note: it dropped proactive audio + affective dialog and
/// renamed `thinkingBudget` → `thinkingLevel`. We don't use any of those.
/// See: https://ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-live-preview
const String geminiLiveModel = String.fromEnvironment(
  'GEMINI_LIVE_MODEL',
  defaultValue: 'gemini-3.1-flash-live-preview',
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
