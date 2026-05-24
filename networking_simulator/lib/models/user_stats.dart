/// Aggregated stats shown on the home tiles and profile screen.
/// Derived in-app from the sessions list — not stored separately.
class UserStats {
  const UserStats({
    required this.sessionsCompleted,
    required this.avgScore,
    required this.dayStreak,
    required this.skills,
    required this.growthPercent,
  });

  final int sessionsCompleted;
  final int avgScore;
  final int dayStreak;

  /// Skill name → 0..1, averaged across the user's session feedback reports.
  /// Drives the `_SkillRow` bars on profile_screen.dart.
  final Map<String, double> skills;

  /// Recent-week vs prior-week delta as a percent integer (e.g. `+23`),
  /// shown in the home "Growth" mini stat. Can be negative.
  final int growthPercent;

  /// Empty fallback used before the first session lands.
  factory UserStats.empty() => const UserStats(
        sessionsCompleted: 0,
        avgScore: 0,
        dayStreak: 0,
        skills: {},
        growthPercent: 0,
      );
}
