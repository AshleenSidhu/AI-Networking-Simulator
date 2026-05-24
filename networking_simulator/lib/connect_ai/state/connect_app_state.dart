import 'package:flutter/material.dart';

import '../theme/connect_theme.dart';

/// In-memory UI state (no backend). Updated during onboarding, read on Home/Profile.
class ConnectAppState extends ChangeNotifier {
  String name = 'Alex';
  String role = 'Early Professional';
  final Set<String> industries = {'Technology'};
  String goal = 'Land a Job';
  String goalDetail = 'Recruiter & Hiring Manager focus';

  // Onboarding draft (updated each step before profile is built)
  String onboardingName = '';
  String onboardingRole = 'Early Professional';
  final Set<String> onboardingIndustries = {'Technology'};
  String onboardingGoal = 'Land a Job';

  static const _goalDetails = {
    'Land a Job': 'Recruiter & Hiring Manager focus',
    'Investor Pitch': 'VC & angel conversation focus',
    'General Networking': 'Industry connection focus',
    'Client or Sales Calls': 'Client acquisition focus',
  };

  void setOnboardingName(String value) {
    onboardingName = value.trim();
    notifyListeners();
  }

  void setOnboardingRole(String value) {
    onboardingRole = value;
    notifyListeners();
  }

  void setOnboardingIndustries(Set<String> value) {
    onboardingIndustries
      ..clear()
      ..addAll(value);
    notifyListeners();
  }

  void setOnboardingGoal(String value) {
    onboardingGoal = value;
    notifyListeners();
  }

  void commitOnboardingProfile() {
    final detail = _goalDetails[onboardingGoal] ?? onboardingGoal;
    updateFromOnboarding(
      name: onboardingName.isEmpty ? 'Alex' : onboardingName,
      role: onboardingRole,
      industries: Set<String>.from(onboardingIndustries),
      goal: onboardingGoal,
      goalDetail: detail,
    );
  }

  // Initialized to zero so the first paint never shows misleading demo
  // numbers. The bridge (`connectStateSyncProvider`) overwrites these from
  // `userStatsProvider` within a frame of app start.
  int sessionsCompleted = 0;
  int avgScore = 0;
  int dayStreak = 0;
  int growthPercent = 0;

  /// Per-skill 0..1 score averaged across the user's FeedbackReports.
  /// Empty until the first report lands. Profile_screen reads it to drive
  /// the skill-progress bars.
  Map<String, double> skills = const {};

  /// Backend-driven affordance: kept in sync with [userStatsProvider] by
  /// `connectStateSyncProvider`. Don't call from widgets — call upstream
  /// providers if you need to mutate Firestore.
  void applyDerivedStats({
    required int sessionsCompleted,
    required int avgScore,
    required int dayStreak,
    required int growthPercent,
    required Map<String, double> skills,
  }) {
    var changed = false;
    if (this.sessionsCompleted != sessionsCompleted) {
      this.sessionsCompleted = sessionsCompleted;
      changed = true;
    }
    if (this.avgScore != avgScore) {
      this.avgScore = avgScore;
      changed = true;
    }
    if (this.dayStreak != dayStreak) {
      this.dayStreak = dayStreak;
      changed = true;
    }
    if (this.growthPercent != growthPercent) {
      this.growthPercent = growthPercent;
      changed = true;
    }
    if (!_skillsEqual(this.skills, skills)) {
      this.skills = Map.unmodifiable(skills);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  bool _skillsEqual(Map<String, double> a, Map<String, double> b) {
    if (a.length != b.length) return false;
    for (final entry in a.entries) {
      final other = b[entry.key];
      if (other == null || (other - entry.value).abs() > 0.001) return false;
    }
    return true;
  }

  bool isDarkMode = false;

  void setDarkMode(bool value) {
    isDarkMode = value;
    applyConnectThemeMode(dark: value);
    notifyListeners();
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts.first.length >= 2
          ? parts.first.substring(0, 2).toUpperCase()
          : parts.first[0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String get displayName => name.trim().isEmpty ? 'there' : name.trim();

  String get industryLabel =>
      industries.isEmpty ? 'General' : industries.take(2).join(' · ');

  void updateFromOnboarding({
    required String name,
    required String role,
    required Set<String> industries,
    required String goal,
    required String goalDetail,
  }) {
    this.name = name;
    this.role = role;
    this.industries
      ..clear()
      ..addAll(industries);
    this.goal = goal;
    this.goalDetail = goalDetail;
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required String role,
    required Set<String> industries,
    required String goal,
  }) {
    final detail = _goalDetails[goal] ?? goal;
    updateFromOnboarding(
      name: name.trim().isEmpty ? 'Alex' : name.trim(),
      role: role,
      industries: industries,
      goal: goal,
      goalDetail: detail,
    );
  }
}

/// Draft values collected during onboarding (updated each step).
class ConnectScope extends InheritedNotifier<ConnectAppState> {
  const ConnectScope({
    super.key,
    required ConnectAppState appState,
    required super.child,
  }) : super(notifier: appState);

  static ConnectAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ConnectScope>();
    assert(scope != null, 'ConnectScope not found');
    return scope!.notifier!;
  }
}
