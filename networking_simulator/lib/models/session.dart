import 'transcript_turn.dart';

/// A completed (or in-flight) practice session. Written to Firestore at
/// `users/{uid}/sessions/{sessionId}` when the user hangs up.
class Session {
  const Session({
    required this.id,
    required this.personaId,
    required this.startedAt,
    required this.endedAt,
    required this.transcript,
    this.summary,
    this.feedbackReportId,
    this.score,
  });

  final String id;
  final String personaId;
  final DateTime startedAt;
  final DateTime endedAt;
  final List<TranscriptTurn> transcript;

  /// 2-3 sentence summary written by `summary_agent.dart`. Injected into
  /// the next session's `system_instruction` so the persona remembers.
  final String? summary;

  /// Pointer to the FeedbackReport in `users/{uid}/feedbackReports/{id}`.
  final String? feedbackReportId;

  /// Cached final score (0..100) so the home screen and profile can render
  /// without joining the feedbackReport collection.
  final int? score;

  Duration get duration => endedAt.difference(startedAt);

  Session copyWith({
    String? id,
    String? personaId,
    DateTime? startedAt,
    DateTime? endedAt,
    List<TranscriptTurn>? transcript,
    String? summary,
    String? feedbackReportId,
    int? score,
  }) {
    return Session(
      id: id ?? this.id,
      personaId: personaId ?? this.personaId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      transcript: transcript ?? this.transcript,
      summary: summary ?? this.summary,
      feedbackReportId: feedbackReportId ?? this.feedbackReportId,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'personaId': personaId,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'transcript': transcript.map((t) => t.toJson()).toList(),
        'summary': summary,
        'feedbackReportId': feedbackReportId,
        'score': score,
      };

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        id: json['id'] as String,
        personaId: json['personaId'] as String,
        startedAt: DateTime.parse(json['startedAt'] as String),
        endedAt: DateTime.parse(json['endedAt'] as String),
        transcript: (json['transcript'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(TranscriptTurn.fromJson)
            .toList(),
        summary: json['summary'] as String?,
        feedbackReportId: json['feedbackReportId'] as String?,
        score: json['score'] as int?,
      );
}

/// Lifecycle phase of a live call. Drives the call-screen UI.
enum SessionPhase {
  /// Opening the WebSocket and waiting for `setup_complete`.
  connecting,

  /// The call is in flight. Mic is hot (unless muted). Transcript is streaming.
  live,

  /// User hung up or AI completed. Transcript is written to Firestore.
  ended,

  /// Unrecoverable error — show banner with [SessionState.error] and a
  /// "Retry" button that re-creates the controller.
  error,
}

/// Immutable view of the current call. Read by `call_screen.dart` via
/// `ref.watch(sessionControllerProvider(personaId))`.
class SessionState {
  const SessionState({
    required this.sessionId,
    required this.personaId,
    required this.transcript,
    required this.elapsed,
    required this.isMuted,
    required this.isAiSpeaking,
    required this.isPushToTalkDown,
    required this.phase,
    this.error,
  });

  final String sessionId;
  final String personaId;
  final List<TranscriptTurn> transcript;
  final Duration elapsed;
  final bool isMuted;

  /// True while audio is playing back to the user. UI uses this to animate
  /// the soundwave widget.
  final bool isAiSpeaking;

  /// True while the push-to-talk button is held. Mic is forced live during
  /// PTT regardless of [isMuted].
  final bool isPushToTalkDown;

  final SessionPhase phase;
  final String? error;

  SessionState copyWith({
    String? sessionId,
    String? personaId,
    List<TranscriptTurn>? transcript,
    Duration? elapsed,
    bool? isMuted,
    bool? isAiSpeaking,
    bool? isPushToTalkDown,
    SessionPhase? phase,
    String? error,
  }) {
    return SessionState(
      sessionId: sessionId ?? this.sessionId,
      personaId: personaId ?? this.personaId,
      transcript: transcript ?? this.transcript,
      elapsed: elapsed ?? this.elapsed,
      isMuted: isMuted ?? this.isMuted,
      isAiSpeaking: isAiSpeaking ?? this.isAiSpeaking,
      isPushToTalkDown: isPushToTalkDown ?? this.isPushToTalkDown,
      phase: phase ?? this.phase,
      error: error ?? this.error,
    );
  }
}
