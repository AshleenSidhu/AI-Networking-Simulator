import 'package:flutter/material.dart';

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

  int sessionsCompleted = 12;
  int avgScore = 74;
  int dayStreak = 8;

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
