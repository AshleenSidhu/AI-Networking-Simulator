import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transcript_turn.dart';
import '../services/env.dart';
import '../services/gemini_text_service.dart';

/// Writes the 2-3 sentence cross-session memory.
///
/// Run in parallel with [FeedbackAgent] after a session ends. The result is
/// stored at `users/{uid}/summaries/{personaId}` and prepended to the next
/// session's `system_instruction` via [PersonaAgent].
abstract class SummaryAgent {
  Future<String> writeSummary({
    required String personaName,
    required List<TranscriptTurn> transcript,
  });
}

class MockSummaryAgent implements SummaryAgent {
  @override
  Future<String> writeSummary({
    required String personaName,
    required List<TranscriptTurn> transcript,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return 'Last call with $personaName: user practiced the phone-screen opener; '
        "they need to ask more follow-up questions and slow down on the 'tell "
        "me about yourself' answer.";
  }
}

class RealSummaryAgent implements SummaryAgent {
  RealSummaryAgent({required this.text});

  final GeminiTextService text;

  @override
  Future<String> writeSummary({
    required String personaName,
    required List<TranscriptTurn> transcript,
  }) async {
    final rubric = await rootBundle.loadString('prompts/summary_writer.md');
    final transcriptText = transcript
        .map((t) => '${t.speaker == Speaker.user ? 'USER' : 'AI'}: ${t.text}')
        .join('\n');
    try {
      return await text.generate(
        prompt: '$rubric\n\nPersona: $personaName\n\nTranscript:\n$transcriptText',
        systemInstruction:
            'You are a concise summarizer. Output 2-3 sentences in plain prose, '
            'no headings or bullets.',
      );
    } catch (e) {
      debugPrint('[SummaryAgent] failed: $e');
      return '';
    }
  }
}

final summaryAgentProvider = Provider<SummaryAgent>((ref) {
  if (useMocks) return MockSummaryAgent();
  final text = ref.watch(geminiTextServiceProvider);
  if (text is MockGeminiTextService) return MockSummaryAgent();
  return RealSummaryAgent(text: text);
});
