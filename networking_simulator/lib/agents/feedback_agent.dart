import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/feedback_report.dart';
import '../models/transcript_turn.dart';
import '../services/env.dart';
import '../services/gemini_text_service.dart';

/// Judges a completed session and streams a [FeedbackReport].
///
/// The judge runs as a one-shot JSON-mode call to Gemini text — we don't
/// stream the JSON itself (it's small) but we wrap the future in a stream
/// so the UI can show a loading state and "thinking" animation while it
/// resolves.
///
/// Loads its rubric prompt from `prompts/feedback_judge.md`.
abstract class FeedbackAgent {
  /// Emits one or more [FeedbackReport] values. The first emit has
  /// `isStreaming: true` so the UI can show a shimmer. The final emit
  /// has the populated report with `isStreaming: false`.
  Stream<FeedbackReport> judge({
    required String sessionId,
    required List<TranscriptTurn> transcript,
  });
}

class MockFeedbackAgent implements FeedbackAgent {
  @override
  Stream<FeedbackReport> judge({
    required String sessionId,
    required List<TranscriptTurn> transcript,
  }) async* {
    yield FeedbackReport.empty(sessionId);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    yield FeedbackReport(
      sessionId: sessionId,
      score: 78,
      fillerCount: 4,
      strongestMoment:
          "You handled the 'why us' question with a specific, well-researched answer.",
      areasForImprovement: const [
        'Ask three follow-up questions to show curiosity.',
        'Cut filler words on technical answers.',
        "Slow down on the 'tell me about yourself' opener.",
      ],
      // Must match a real persona id from PersonaRepository.templates,
      // otherwise the FeedbackScreen falls through to the bare "Back to
      // home" button instead of rendering the scheduling CTA.
      recommendedNextPersonaId: 'networking_marcus',
      recommendedNextRationale:
          "You did well with screening — try Marcus next to go deeper on technical fit and 'manager interview' framing.",
      skillScores: const {
        'Communication': 0.82,
        'Confidence': 0.70,
        'Active Listening': 0.60,
        'Follow-up': 0.55,
      },
      generatedAt: DateTime.now(),
    );
  }
}

class RealFeedbackAgent implements FeedbackAgent {
  RealFeedbackAgent({required this.text});

  final GeminiTextService text;

  @override
  Stream<FeedbackReport> judge({
    required String sessionId,
    required List<TranscriptTurn> transcript,
  }) async* {
    yield FeedbackReport.empty(sessionId);

    final rubric = await rootBundle.loadString('prompts/feedback_judge.md');
    final transcriptText = transcript
        .map((t) => '${t.speaker == Speaker.user ? 'USER' : 'AI'}: ${t.text}')
        .join('\n');

    final prompt = '$rubric\n\n## Transcript\n\n$transcriptText';

    try {
      final raw = await text.generate(
        prompt: prompt,
        jsonMode: true,
      );
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      yield FeedbackReport(
        sessionId: sessionId,
        score: (decoded['score'] as num?)?.toInt() ?? 0,
        fillerCount: (decoded['fillerCount'] as num?)?.toInt() ?? 0,
        strongestMoment: decoded['strongestMoment'] as String? ?? '',
        areasForImprovement:
            (decoded['areasForImprovement'] as List<dynamic>?)
                    ?.cast<String>() ??
                const [],
        recommendedNextPersonaId:
            decoded['recommendedNextPersonaId'] as String? ?? '',
        recommendedNextRationale:
            decoded['recommendedNextRationale'] as String? ?? '',
        skillScores:
            (decoded['skillScores'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, (v as num).toDouble()),
        ),
        generatedAt: DateTime.now(),
      );
    } catch (e, st) {
      debugPrint('[FeedbackAgent] judge failed: $e\n$st');
      // Surface an empty-but-finalized report so the UI exits its loading
      // state. Better than hanging forever.
      yield FeedbackReport(
        sessionId: sessionId,
        score: 0,
        fillerCount: 0,
        strongestMoment: 'Could not score this session.',
        areasForImprovement: ['Try again — the judge errored: $e'],
        recommendedNextPersonaId: '',
        recommendedNextRationale: '',
        skillScores: const {},
        generatedAt: DateTime.now(),
      );
    }
  }
}

final feedbackAgentProvider = Provider<FeedbackAgent>((ref) {
  if (useMocks) return MockFeedbackAgent();
  final text = ref.watch(geminiTextServiceProvider);
  if (text is MockGeminiTextService) return MockFeedbackAgent();
  return RealFeedbackAgent(text: text);
});
