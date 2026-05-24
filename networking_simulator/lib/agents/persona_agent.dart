import 'package:flutter/services.dart' show rootBundle;

import '../models/persona.dart';

/// Builds the Gemini Live `system_instruction` string for a session.
///
/// Combines:
/// 1. The persona's bundled template (loaded once from `prompts/<id>.md`).
/// 2. Per-user values pulled from `ConnectAppState` (industry, role, goal).
/// 3. The cross-session summary written by `summary_agent.dart` after the
///    last session, so the persona "remembers" what was practiced before.
///
/// Templates use `{{snake_case}}` placeholders. Unfilled placeholders are
/// left in place so the model can ignore them rather than seeing a blank.
class PersonaAgent {
  PersonaAgent({required this.persona});

  final Persona persona;
  final _cache = <String, String>{};

  /// Substitutes placeholders into the persona's template. Pass any
  /// runtime values (industry, difficulty, goal, summary) in [vars].
  Future<String> buildSystemInstruction({
    required Map<String, String> vars,
    String? previousSummary,
  }) async {
    final template = await _loadTemplate();
    final allVars = {
      ...vars,
      if (previousSummary != null && previousSummary.isNotEmpty)
        'previous_summary': previousSummary,
      'previous_summary_block': previousSummary == null || previousSummary.isEmpty
          ? ''
          : '## What the user has practiced before\n\n$previousSummary\n',
    };
    return _interpolate(template, allVars);
  }

  Future<String> _loadTemplate() async {
    // Custom (user-authored) personas store the template inline on the
    // model. Skip the rootBundle lookup entirely for them — Flutter Web's
    // asset loader prints a noisy "failed to fetch ... 404" log line
    // *before* a try/catch can suppress it, polluting the console for
    // every custom persona call.
    if (persona.isCustom) {
      return persona.systemPromptTemplate;
    }
    final key = 'prompts/${persona.id}.md';
    if (_cache.containsKey(key)) return _cache[key]!;
    try {
      final raw = await rootBundle.loadString(key);
      _cache[key] = raw;
      return raw;
    } catch (_) {
      // Defensive fallback for the (currently impossible) case of a
      // template id that resolves but bundles. Keeps non-custom callers
      // from crashing on a typo'd prompts/ entry.
      return persona.systemPromptTemplate;
    }
  }

  String _interpolate(String template, Map<String, String> vars) {
    var out = template;
    vars.forEach((k, v) {
      out = out.replaceAll('{{$k}}', v);
    });
    return out;
  }
}
