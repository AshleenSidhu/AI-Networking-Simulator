import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/feedback_report.dart';
import '../models/session.dart';
import '../models/user_stats.dart';
import '../services/firestore_service.dart';

/// All recent sessions (last 20). Used directly by the profile screen's
/// recent-sessions list and aggregated by [userStatsProvider].
final recentSessionsProvider = StreamProvider<List<Session>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.watchRecentSessions();
});

/// All feedback reports for the current user. Used by [userStatsProvider]
/// to aggregate skill-bar averages and by the score-backfill provider to
/// retro-fill `Session.score` for sessions written before the
/// feedback-controller writeback fix landed.
final feedbackReportsProvider = StreamProvider<List<FeedbackReport>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.watchFeedbackReports();
});

/// Aggregated user stats: derived from the recent-sessions stream and
/// the feedback-reports stream.
final userStatsProvider = Provider<UserStats>((ref) {
  final sessions = ref.watch(recentSessionsProvider).value ?? const [];
  final reports = ref.watch(feedbackReportsProvider).value ?? const [];
  if (sessions.isEmpty) {
    return UserStats(
      sessionsCompleted: 0,
      avgScore: 0,
      dayStreak: 0,
      skills: _aggregateSkills(reports),
      growthPercent: 0,
    );
  }

  final scored = sessions.where((s) => s.score != null).toList();
  final total = scored.length;
  final avg = total == 0
      ? 0
      : (scored.map((s) => s.score!).reduce((a, b) => a + b) / total).round();

  // Day streak — simplest possible computation: number of unique days in
  // the last 30 that have at least one session, counting backwards from
  // today and breaking on the first gap.
  final dayKeys = sessions
      .map((s) => DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day))
      .toSet();
  final today = DateTime.now();
  var streak = 0;
  for (var i = 0; i < 60; i++) {
    final day = DateTime(today.year, today.month, today.day - i);
    if (dayKeys.contains(day)) {
      streak++;
    } else if (streak > 0) {
      break;
    }
  }

  // Growth percent: recent-half avg vs. older-half avg of the scored
  // sessions. The original week-over-week calc returned 0 for any user
  // who hadn't been active for ≥2 weeks — hostile to a fresh demo where
  // 2-4 sessions all happen the same evening. The recency split keeps
  // working with as few as 2 scored sessions.
  //
  // `scored` is ordered most-recent-first because `watchRecentSessions`
  // queries `orderBy('startedAt', descending: true)`.
  int growth = 0;
  if (scored.length >= 2) {
    final half = scored.length ~/ 2;
    final pivot = half == 0 ? 1 : half;
    final recent = scored.take(pivot).map((s) => s.score!).toList();
    final older = scored.skip(pivot).map((s) => s.score!).toList();
    if (older.isNotEmpty) {
      final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
      final olderAvg = older.reduce((a, b) => a + b) / older.length;
      if (olderAvg > 0) {
        growth = (((recentAvg - olderAvg) / olderAvg) * 100).round();
      }
    }
  }

  return UserStats(
    sessionsCompleted: sessions.length,
    avgScore: avg,
    dayStreak: streak,
    skills: _aggregateSkills(reports),
    growthPercent: growth,
  );
});

/// Averages each skill's 0..1 score across the user's feedback reports.
/// Returns an empty map when no reports exist — the profile_screen reads
/// `app.skills[name] ?? 0` and renders an empty bar in that case.
Map<String, double> _aggregateSkills(List<FeedbackReport> reports) {
  if (reports.isEmpty) return const {};
  final sums = <String, double>{};
  final counts = <String, int>{};
  for (final r in reports) {
    for (final entry in r.skillScores.entries) {
      sums[entry.key] = (sums[entry.key] ?? 0) + entry.value;
      counts[entry.key] = (counts[entry.key] ?? 0) + 1;
    }
  }
  final out = <String, double>{};
  for (final key in sums.keys) {
    out[key] = sums[key]! / counts[key]!;
  }
  return out;
}
