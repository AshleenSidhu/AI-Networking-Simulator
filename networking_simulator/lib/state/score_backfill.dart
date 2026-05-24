import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_service.dart';

/// One-shot migration: copies `FeedbackReport.score` back to
/// `Session.score` for any session that's missing it.
///
/// Background: `feedback_controller.dart` was updated on 2026-05-24
/// 02:45 to write the judge's final score into both
/// `feedbackReports/{id}` AND `sessions/{id}.score`. Sessions written
/// *before* that fix only have the FeedbackReport; their Session has
/// `score == null`. `userStatsProvider` averages `Session.score`, so
/// those sessions don't contribute to the home/profile Confidence stat
/// even though they were judged correctly at the time.
///
/// This provider runs once at sign-in (it re-runs if uid changes), walks
/// every feedback report for the current user, and writes the score
/// back to its session document. The Firestore snapshot listener that
/// `recentSessionsProvider` is subscribed to will then re-emit the
/// updated sessions, which cascades into `userStatsProvider` and the
/// bridge — so the home / profile screens repaint with real numbers
/// without any user action.
///
/// Idempotent: if the session already has a score, it's left alone.
/// Safe to run on every sign-in.
final scoreBackfillProvider = Provider<void>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    // No signed-in user → firestoreServiceProvider is a fresh mock; nothing
    // to backfill. Re-runs once uid populates.
    return;
  }

  // Fire-and-forget. Errors are logged but don't surface to the user —
  // the worst case is that some past sessions stay scoreless until they
  // happen to go through the feedback flow again.
  Future.microtask(() async {
    final firestore = ref.read(firestoreServiceProvider);
    try {
      final reports = await firestore.watchFeedbackReports().first;
      if (reports.isEmpty) {
        debugPrint('[ScoreBackfill] no feedback reports found for uid=$uid');
        return;
      }

      var patched = 0;
      for (final report in reports) {
        final session = await firestore.readSession(report.sessionId);
        if (session == null) continue;
        if (session.score != null) continue;
        await firestore.writeSession(
          session.copyWith(
            score: report.score,
            feedbackReportId: report.sessionId,
          ),
        );
        patched++;
      }
      debugPrint(
        '[ScoreBackfill] uid=$uid reports=${reports.length} patched=$patched',
      );
    } catch (e, st) {
      debugPrint('[ScoreBackfill] error: $e\n$st');
    }
  });
});
