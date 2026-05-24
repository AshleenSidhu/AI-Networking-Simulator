import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../state/connect_app_state.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import 'scenario_select_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onGoProfile});

  final VoidCallback onGoProfile;

  static const _scenarios = [
    ('👔', 'Recruiter'),
    ('💰', 'Investor'),
    ('🤝', 'Networking'),
    ('🚀', 'Founder'),
    ('🎓', 'Mentor'),
  ];

  @override
  Widget build(BuildContext context) {
    final app = ConnectScope.of(context);

    return ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        return ConnectPage(
          fullWidth: ConnectResponsive.useSideNavigation(context),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _TopBar(
                greeting: 'Good morning, ${app.displayName} 👋',
                initials: app.initials,
                onAvatarTap: onGoProfile,
              ),
              const SizedBox(height: 24),
              if (ConnectResponsive.isDesktop(context))
                ConnectSplitLayout(
                  primary: _HeroCard(app: app),
                  secondary: Column(
                    children: [
                      _StatsRow(),
                      const SizedBox(height: 16),
                      _UpcomingCard(),
                    ],
                  ),
                  secondaryFlex: 2,
                )
              else ...[
                _HeroCard(app: app),
                const SizedBox(height: 20),
                _StatsRow(),
                const SizedBox(height: 20),
                _UpcomingCard(),
              ],
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Popular scenarios', style: connectTitle(context, size: 18)),
                  Text('See all', style: connectMuted(13)),
                ],
              ),
              const SizedBox(height: 14),
              _ScenarioScroll(scenarios: _scenarios),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.greeting,
    required this.initials,
    required this.onAvatarTap,
  });

  final String greeting;
  final String initials;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(greeting, style: connectTitle(context, size: 20))),
        GestureDetector(
          onTap: onAvatarTap,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: ConnectColors.accent,
            child: Text(initials, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.app});
  final ConnectAppState app;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.accent.withValues(alpha: 0.45)),
        gradient: LinearGradient(
          colors: [ConnectColors.accent.withValues(alpha: 0.12), ConnectColors.card],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: ConnectColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ConnectColors.radius),
            ),
            child: Text(
              '✦ Personalized for ${app.role}',
              style: const TextStyle(color: ConnectColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          Text('Practice networking.', style: connectTitle(context, size: 26)),
          Text('Before it matters.', style: connectTitle(context, size: 26)),
          const SizedBox(height: 10),
          Text(
            'Goal: ${app.goal} · ${app.industryLabel}',
            style: connectMuted(14),
          ),
          const SizedBox(height: 20),
          ConnectPrimaryButton(
            label: 'Start Practicing',
            onPressed: () => connectPush(
              context,
              const ScenarioSelectScreen(),
            ),
          ),
          const SizedBox(height: 12),
          ConnectPrimaryButton(label: 'View Progress', outlined: true, onPressed: () {}),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final app = ConnectScope.of(context);
    return Row(
      children: [
        _MiniStat('${app.sessionsCompleted}', 'Sessions'),
        const SizedBox(width: 10),
        _MiniStat('${app.avgScore}%', 'Confidence'),
        const SizedBox(width: 10),
        _MiniStat('+23%', 'Growth', valueColor: ConnectColors.success),
      ],
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Note: Flutter forbids non-uniform Border colors when borderRadius is
    // set. The purple accent stripe is rendered as a Positioned child
    // inside a Stack instead, and the outer Container's border is uniform.
    return Container(
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 3,
            child: ColoredBox(color: ConnectColors.accent),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: ConnectColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('TUE', style: TextStyle(fontSize: 10, color: ConnectColors.textMuted)),
                      Text('14', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Recruiter Practice', style: TextStyle(fontWeight: FontWeight.w700)),
                      Text('Tomorrow · 6:30 PM', style: TextStyle(color: ConnectColors.textMuted, fontSize: 12)),
                      SizedBox(height: 6),
                      Row(children: [_Pill('15 min'), SizedBox(width: 6), _Pill('Medium')]),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConnectColors.accent,
                    foregroundColor: ConnectColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Join →', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioScroll extends StatelessWidget {
  const _ScenarioScroll({required this.scenarios});
  final List<(String, String)> scenarios;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scenarios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final (emoji, name) = scenarios[i];
          return GestureDetector(
            onTap: () => connectPush(
              context,
              const ScenarioSelectScreen(),
            ),
            child: Container(
              width: 100,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ConnectColors.card,
                borderRadius: BorderRadius.circular(ConnectColors.radius),
                border: Border.all(color: ConnectColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  const Text('→', style: TextStyle(color: ConnectColors.accent, fontSize: 11)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(this.value, this.label, {this.valueColor});
  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ConnectColors.card,
          borderRadius: BorderRadius.circular(ConnectColors.radius),
          border: Border.all(color: ConnectColors.border),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: valueColor)),
            const SizedBox(height: 4),
            Text(label, style: connectMuted(11)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ConnectColors.cardElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: connectMuted(10)),
    );
  }
}
