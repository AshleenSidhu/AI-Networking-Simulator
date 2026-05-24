import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../agents/feedback_agent.dart';
import '../models/feedback_report.dart';
import '../models/scheduled_session.dart';
import '../services/firestore_service.dart';

/// Streams the [FeedbackReport] for a given session. Emits an empty
/// placeholder first so the UI can render a shimmer; the final report
/// replaces it with `isStreaming: false`.
final feedbackProvider =
    StreamProvider.family<FeedbackReport, String>((ref, sessionId) async* {
  final firestore = ref.read(firestoreServiceProvider);
  final session = await firestore.readSession(sessionId);
  if (session == null) {
    yield FeedbackReport.empty(sessionId);
    return;
  }

  final agent = ref.read(feedbackAgentProvider);
  FeedbackReport? last;
  await for (final report in agent.judge(
    sessionId: sessionId,
    transcript: session.transcript,
  )) {
    last = report;
    yield report;
  }

  if (last != null && !last.isStreaming) {
    await firestore.writeFeedbackReport(last);
    // Denormalize score + report id onto the Session so home / profile
    // stats can render without joining the feedbackReports collection.
    // This is the path `Session.score`'s doc comment was promising.
    await firestore.writeSession(
      session.copyWith(
        score: last.score,
        feedbackReportId: last.sessionId,
      ),
    );
  }
});

/// Schedule-the-next-session command exposed on the feedback screen.
class FeedbackController extends Notifier<void> {
  @override
  void build() {}

  Future<void> scheduleNext(ScheduledSession session) async {
    final firestore = ref.read(firestoreServiceProvider);
    await firestore.writeScheduledSession(session);
  }
}

final feedbackControllerProvider = NotifierProvider<FeedbackController, void>(
  FeedbackController.new,
);
