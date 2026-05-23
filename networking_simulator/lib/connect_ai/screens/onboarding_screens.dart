import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../state/connect_app_state.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'profile_loading_screen.dart';

class OnboardingQ1Screen extends StatefulWidget {
  const OnboardingQ1Screen({super.key});

  @override
  State<OnboardingQ1Screen> createState() => _OnboardingQ1ScreenState();
}

class _OnboardingQ1ScreenState extends State<OnboardingQ1Screen> {
  late final TextEditingController _name;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_name.text.isEmpty) {
      _name.text = ConnectScope.of(context).onboardingName;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: 1,
      emoji: '👋',
      headline: "What's your name?",
      subtitle: "Let's make this personal",
      body: TextField(
        controller: _name,
        autofocus: true,
        style: const TextStyle(color: ConnectColors.textPrimary, fontSize: 18),
        decoration: InputDecoration(
          hintText: 'Your first name',
          hintStyle: connectMuted(16),
          filled: true,
          fillColor: ConnectColors.card,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ConnectColors.radius),
            borderSide: const BorderSide(color: ConnectColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(ConnectColors.radius),
            borderSide: const BorderSide(color: ConnectColors.accent, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
      onContinue: () {
        ConnectScope.of(context).setOnboardingName(_name.text);
        connectPush(context, const OnboardingQ2Screen());
      },
    );
  }
}

class OnboardingQ2Screen extends StatefulWidget {
  const OnboardingQ2Screen({super.key});

  @override
  State<OnboardingQ2Screen> createState() => _OnboardingQ2ScreenState();
}

class _OnboardingQ2ScreenState extends State<OnboardingQ2Screen> {
  static const _options = [
    ('🎓', 'Student', 'University or college student'),
    ('💼', 'Early Professional', '0-3 years work experience'),
    ('🚀', 'Mid-Level Professional', '3-8 years work experience'),
    ('👑', 'Senior Professional', '8+ years experience'),
  ];

  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = 1;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final role = ConnectScope.of(context).onboardingRole;
    final idx = _options.indexWhere((o) => o.$2 == role);
    if (idx >= 0) _selected = idx;
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: 2,
      emoji: '🎓',
      headline: 'What describes you best?',
      subtitle: "We'll personalize your experience",
      body: ConnectResponsive.isDesktop(context)
          ? GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.4,
              children: List.generate(_options.length, (i) {
                final (emoji, title, sub) = _options[i];
                return SelectableOptionCard(
                  emoji: emoji,
                  title: title,
                  subtitle: sub,
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                );
              }),
            )
          : Column(
              children: List.generate(_options.length, (i) {
                final (emoji, title, sub) = _options[i];
                return SelectableOptionCard(
                  emoji: emoji,
                  title: title,
                  subtitle: sub,
                  selected: _selected == i,
                  onTap: () => setState(() => _selected = i),
                );
              }),
            ),
      onContinue: () {
        ConnectScope.of(context).setOnboardingRole(_options[_selected].$2);
        connectPush(context, const OnboardingQ3Screen());
      },
    );
  }
}

class OnboardingQ3Screen extends StatefulWidget {
  const OnboardingQ3Screen({super.key});

  @override
  State<OnboardingQ3Screen> createState() => _OnboardingQ3ScreenState();
}

class _OnboardingQ3ScreenState extends State<OnboardingQ3Screen> {
  static const _industries = [
    'Technology',
    'Finance',
    'Healthcare',
    'Marketing',
    'Entrepreneurship',
    'Law',
    'Education',
    'Engineering',
    'Design',
    'Sales',
    'Product',
    'Other',
  ];

  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {'Technology'};
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selected.length == 1 && _selected.contains('Technology')) {
      _selected = Set<String>.from(ConnectScope.of(context).onboardingIndustries);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: 3,
      emoji: '🏢',
      headline: "What's your industry?",
      subtitle: 'Your personas will match your field',
      body: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _industries.map((ind) {
          return ConnectChip(
            label: ind,
            selected: _selected.contains(ind),
            onTap: () {
              setState(() {
                if (_selected.contains(ind)) {
                  _selected.remove(ind);
                } else {
                  _selected.add(ind);
                }
              });
            },
          );
        }).toList(),
      ),
      onContinue: () {
        ConnectScope.of(context).setOnboardingIndustries(_selected);
        connectPush(context, const OnboardingQ4Screen());
      },
    );
  }
}

class OnboardingQ4Screen extends StatefulWidget {
  const OnboardingQ4Screen({super.key});

  @override
  State<OnboardingQ4Screen> createState() => _OnboardingQ4ScreenState();
}

class _OnboardingQ4ScreenState extends State<OnboardingQ4Screen> {
  static const _goals = [
    ('🎯', 'Land a Job', 'Practice recruiter and hiring manager calls'),
    ('💰', 'Investor Pitch', 'Practice pitching to VCs and angels'),
    ('🤝', 'General Networking', 'Build connections in your industry'),
    ('💼', 'Client or Sales Calls', 'Win clients and close deals'),
  ];

  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = 0;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final goal = ConnectScope.of(context).onboardingGoal;
    final idx = _goals.indexWhere((g) => g.$2 == goal);
    if (idx >= 0) _selected = idx;
  }

  @override
  Widget build(BuildContext context) {
    return _OnboardingScaffold(
      step: 4,
      emoji: '🎯',
      headline: "What's your main goal?",
      subtitle: "We'll build your perfect practice plan",
      body: Column(
        children: List.generate(_goals.length, (i) {
          final (emoji, title, sub) = _goals[i];
          return SelectableOptionCard(
            emoji: emoji,
            title: title,
            subtitle: sub,
            selected: _selected == i,
            onTap: () => setState(() => _selected = i),
          );
        }),
      ),
      continueLabel: 'Build My Profile ✦',
      shimmerButton: true,
      largeButton: true,
      onContinue: () {
        final app = ConnectScope.of(context);
        app.setOnboardingGoal(_goals[_selected].$2);
        app.commitOnboardingProfile();
        connectPush(context, const ProfileLoadingScreen());
      },
    );
  }
}

class _OnboardingScaffold extends StatelessWidget {
  const _OnboardingScaffold({
    required this.step,
    required this.emoji,
    required this.headline,
    required this.subtitle,
    required this.body,
    required this.onContinue,
    this.continueLabel = 'Continue →',
    this.shimmerButton = false,
    this.largeButton = false,
  });

  final int step;
  final String emoji;
  final String headline;
  final String subtitle;
  final Widget body;
  final VoidCallback onContinue;
  final String continueLabel;
  final bool shimmerButton;
  final bool largeButton;

  @override
  Widget build(BuildContext context) {
    final pad = ConnectResponsive.pagePadding(context);

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OnboardingHeader(step: step),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.fromLTRB(0, 32, 0, 16),
                  children: [
                    if (ConnectResponsive.isDesktop(context))
                      ConnectSplitLayout(
                        primary: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emoji, style: const TextStyle(fontSize: 56)),
                            const SizedBox(height: 20),
                            Text(headline, style: connectTitle(context, size: 32)),
                            const SizedBox(height: 8),
                            Text(subtitle, style: connectMuted(16)),
                          ],
                        ),
                        secondary: body,
                        primaryFlex: 2,
                        secondaryFlex: 3,
                      )
                    else ...[
                      Text(emoji, style: const TextStyle(fontSize: 48)),
                      const SizedBox(height: 20),
                      Text(headline, style: connectTitle(context, size: 26)),
                      const SizedBox(height: 8),
                      Text(subtitle, style: connectMuted()),
                      const SizedBox(height: 28),
                      body,
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: pad.bottom),
                child: ConnectPrimaryButton(
                  label: continueLabel,
                  large: largeButton,
                  shimmer: shimmerButton,
                  onPressed: onContinue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
