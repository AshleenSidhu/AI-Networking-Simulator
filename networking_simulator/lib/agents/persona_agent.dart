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
    final key = 'prompts/${persona.id}.md';
    if (_cache.containsKey(key)) return _cache[key]!;
    try {
      final raw = await rootBundle.loadString(key);
      _cache[key] = raw;
      return raw;
    } catch (_) {
      // Custom (user-authored) personas pass their full template inline
      // via `Persona.systemPromptTemplate`.
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
