/// LLM-judge output for a completed session. Streamed field-by-field by
/// [FeedbackAgent] so the UI can render a loading shimmer that fills in
/// progressively.
class FeedbackReport {
  const FeedbackReport({
    required this.sessionId,
    required this.score,
    required this.fillerCount,
    required this.strongestMoment,
    required this.areasForImprovement,
    required this.recommendedNextPersonaId,
    required this.recommendedNextRationale,
    required this.skillScores,
    required this.generatedAt,
    this.isStreaming = false,
  });

  final String sessionId;

  /// Overall conversation score, 0..100.
  final int score;

  /// Count of filler words ("um", "uh", "like", "you know", "kinda").
  final int fillerCount;

  /// 1-2 sentence quote-style callout of the user's best moment.
  final String strongestMoment;

  /// 2-4 short bullets ("Ask follow-up questions about role scope.").
  final List<String> areasForImprovement;

  /// Persona id the judge suggests the user practice next.
  final String recommendedNextPersonaId;

  /// Why this persona was recommended ("You did well with screening
  /// questions — try a hiring manager next to practice deeper technical
  /// discussions.").
  final String recommendedNextRationale;

  /// 0..1 score per skill name, used by `profile_screen.dart`'s skill bars
  /// over time (averaged across sessions). Per-session this is the judge's
  /// rating of this single conversation.
  final Map<String, double> skillScores;

  final DateTime generatedAt;

  /// True while the judge is still streaming. UI can render partials and
  /// flip to "final" presentation when this turns false.
  final bool isStreaming;

  FeedbackReport copyWith({
    int? score,
    int? fillerCount,
    String? strongestMoment,
    List<String>? areasForImprovement,
    String? recommendedNextPersonaId,
    String? recommendedNextRationale,
    Map<String, double>? skillScores,
    bool? isStreaming,
  }) {
    return FeedbackReport(
      sessionId: sessionId,
      score: score ?? this.score,
      fillerCount: fillerCount ?? this.fillerCount,
      strongestMoment: strongestMoment ?? this.strongestMoment,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      recommendedNextPersonaId:
          recommendedNextPersonaId ?? this.recommendedNextPersonaId,
      recommendedNextRationale:
          recommendedNextRationale ?? this.recommendedNextRationale,
      skillScores: skillScores ?? this.skillScores,
      generatedAt: generatedAt,
      isStreaming: isStreaming ?? this.isStreaming,
    );
  }

  Map<String, dynamic> toJson() => {
        'sessionId': sessionId,
        'score': score,
        'fillerCount': fillerCount,
        'strongestMoment': strongestMoment,
        'areasForImprovement': areasForImprovement,
        'recommendedNextPersonaId': recommendedNextPersonaId,
        'recommendedNextRationale': recommendedNextRationale,
        'skillScores': skillScores,
        'generatedAt': generatedAt.toIso8601String(),
      };

  factory FeedbackReport.fromJson(Map<String, dynamic> json) => FeedbackReport(
        sessionId: json['sessionId'] as String,
        score: json['score'] as int,
        fillerCount: json['fillerCount'] as int,
        strongestMoment: json['strongestMoment'] as String,
        areasForImprovement:
            (json['areasForImprovement'] as List<dynamic>).cast<String>(),
        recommendedNextPersonaId:
            json['recommendedNextPersonaId'] as String,
        recommendedNextRationale:
            json['recommendedNextRationale'] as String,
        skillScores: (json['skillScores'] as Map<String, dynamic>)
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
        generatedAt: DateTime.parse(json['generatedAt'] as String),
      );

  /// Placeholder used during streaming before any field has arrived.
  factory FeedbackReport.empty(String sessionId) => FeedbackReport(
        sessionId: sessionId,
        score: 0,
        fillerCount: 0,
        strongestMoment: '',
        areasForImprovement: const [],
        recommendedNextPersonaId: '',
        recommendedNextRationale: '',
        skillScores: const {},
        generatedAt: DateTime.now(),
        isStreaming: true,
      );
}
