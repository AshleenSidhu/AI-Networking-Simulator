import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/session.dart';
import '../models/user_stats.dart';
import '../services/firestore_service.dart';

/// All recent sessions (last 20). Used directly by the profile screen's
/// recent-sessions list and aggregated by [userStatsProvider].
final recentSessionsProvider = StreamProvider<List<Session>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.watchRecentSessions();
});

/// Aggregated user stats: derived from the recent-sessions stream.
final userStatsProvider = Provider<UserStats>((ref) {
  final sessions = ref.watch(recentSessionsProvider).value ?? const [];
  if (sessions.isEmpty) return UserStats.empty();

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

  // Growth percent: this-week avg vs. previous-week avg.
  final now = DateTime.now();
  int? weekAvg(int weeksAgo) {
    final start = now.subtract(Duration(days: 7 * (weeksAgo + 1)));
    final end = now.subtract(Duration(days: 7 * weeksAgo));
    final inWindow = scored
        .where((s) => s.startedAt.isAfter(start) && s.startedAt.isBefore(end))
        .map((s) => s.score!)
        .toList();
    if (inWindow.isEmpty) return null;
    return (inWindow.reduce((a, b) => a + b) / inWindow.length).round();
  }

  final thisWeek = weekAvg(0);
  final prevWeek = weekAvg(1);
  final growth = (thisWeek == null || prevWeek == null || prevWeek == 0)
      ? 0
      : (((thisWeek - prevWeek) / prevWeek) * 100).round();

  return UserStats(
    sessionsCompleted: sessions.length,
    avgScore: avg,
    dayStreak: streak,
    skills: const {
      // Will be replaced by an actual aggregation over FeedbackReports
      // once we add feedback-report streaming. For now, surface the same
      // defaults the frontend hardcoded in profile_screen.dart so the
      // bars don't change visually mid-build.
      'Communication': 0.78,
      'Confidence': 0.71,
      'Active Listening': 0.64,
      'Follow-up': 0.85,
    },
    growthPercent: growth,
  );
});
