import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../state/connect_app_state.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import '../widgets/schedule_widgets.dart';
import '../widgets/session_form_widgets.dart';
import 'scenario_select_screen.dart';

// --- home_screen.dart ---
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
            onPressed: () => connectPush(context, const ScenarioSelectScreen()),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: const Border(
          left: BorderSide(color: ConnectColors.accent, width: 3),
          top: BorderSide(color: ConnectColors.border),
          right: BorderSide(color: ConnectColors.border),
          bottom: BorderSide(color: ConnectColors.border),
        ),
      ),
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
              children: [
                Text('Recruiter Practice', style: TextStyle(fontWeight: FontWeight.w700)),
                Text('Tomorrow · 6:30 PM', style: TextStyle(color: ConnectColors.textMuted, fontSize: 12)),
                SizedBox(height: 8),
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
    );
  }
}

class _ScenarioScroll extends StatelessWidget {
  const _ScenarioScroll({required this.scenarios});
  final List<(String, String)> scenarios;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scenarios.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final (emoji, name) = scenarios[i];
          return GestureDetector(
            onTap: () => connectPush(context, const ScenarioSelectScreen()),
            child: Container(
              width: 100,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: ConnectColors.card,
                borderRadius: BorderRadius.circular(ConnectColors.radius),
                border: Border.all(color: ConnectColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 26, height: 1.1)),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
                  ),
                  const Text('→', style: TextStyle(color: ConnectColors.accent, height: 1.2)),
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

// --- home_shell.dart ---
class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<HomeShell> createState() => HomeShellState();
}

class HomeShellState extends State<HomeShell> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  void goToTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final useSide = ConnectResponsive.useSideNavigation(context);
    final pages = [
      HomeScreen(onGoProfile: () => goToTab(3)),
      const ScenarioSelectScreen(embedded: true),
      const ScheduleScreen(embedded: true),
      const ProfileScreen(embedded: true),
    ];

    final body = IndexedStack(index: _index, children: pages);

    if (!useSide) {
      return Scaffold(
        backgroundColor: ConnectColors.background,
        body: body,
        bottomNavigationBar: _BottomNav(index: _index, onTap: goToTab),
      );
    }

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: Row(
        children: [
          _SideRail(index: _index, onTap: goToTab),
          const VerticalDivider(width: 1, color: ConnectColors.border),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});
  final int index;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: ConnectColors.background,
        border: Border(top: BorderSide(color: ConnectColors.border)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Nav(0, Icons.home_rounded, 'Home', index, onTap),
              _Nav(1, Icons.phone_rounded, 'Practice', index, onTap),
              _Nav(2, Icons.calendar_month_rounded, 'Schedule', index, onTap),
              _Nav(3, Icons.person_rounded, 'Profile', index, onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.index, required this.onTap});
  final int index;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      color: ConnectColors.card,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: ConnectColors.accent,
              ),
              child: const Icon(Icons.mic_rounded, color: ConnectColors.textPrimary, size: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              'ConnectAI',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 32),
            _RailItem(0, Icons.home_rounded, 'Home', index, onTap),
            _RailItem(1, Icons.phone_rounded, 'Practice', index, onTap),
            _RailItem(2, Icons.calendar_month_rounded, 'Schedule', index, onTap),
            _RailItem(3, Icons.person_rounded, 'Profile', index, onTap),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  const _RailItem(this.i, this.icon, this.label, this.current, this.onTap);
  final int i;
  final IconData icon;
  final String label;
  final int current;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final active = current == i;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: active ? ConnectColors.accent.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onTap(i),
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 72,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Icon(icon, color: active ? ConnectColors.accent : ConnectColors.textMuted),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      color: active ? ConnectColors.accent : ConnectColors.textMuted,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Nav extends StatelessWidget {
  const _Nav(this.i, this.icon, this.label, this.current, this.onTap);
  final int i;
  final IconData icon;
  final String label;
  final int current;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    final active = current == i;
    final color = active ? ConnectColors.accent : ConnectColors.textMuted;
    final iconOnly = ConnectResponsive.isMobile(context);
    return GestureDetector(
      onTap: () => onTap(i),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: iconOnly ? 20 : 16, vertical: iconOnly ? 10 : 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: iconOnly ? 26 : 24),
            if (!iconOnly) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// --- profile_screen.dart ---
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;
  bool darkMode = true;
  bool reminders = true;

  @override
  Widget build(BuildContext context) {
    final app = ConnectScope.of(context);

    final content = ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final isWide = ConnectResponsive.isDesktop(context);

        final header = _ProfileHeader(app: app);
        final skills = _SkillsSection();
        final sessions = _RecentSessions();
        final prefs = _PreferencesSection(
          notifications: notifications,
          darkMode: darkMode,
          reminders: reminders,
          onNotifications: (v) => setState(() => notifications = v),
          onDarkMode: (v) => setState(() => darkMode = v),
          onReminders: (v) => setState(() => reminders = v),
        );

        if (isWide) {
          return ConnectPage(
            fullWidth: widget.embedded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                const SizedBox(height: 24),
                ConnectSplitLayout(
                  primary: Column(children: [skills, const SizedBox(height: 24), sessions]),
                  secondary: prefs,
                  primaryFlex: 3,
                  secondaryFlex: 2,
                ),
                const SizedBox(height: 32),
                Center(child: Text('Log Out', style: connectMuted(14).copyWith(color: ConnectColors.danger))),
              ],
            ),
          );
        }

        return ConnectPage(
          fullWidth: widget.embedded,
          child: Column(
            children: [
              header,
              const SizedBox(height: 24),
              skills,
              const SizedBox(height: 24),
              sessions,
              const SizedBox(height: 24),
              prefs,
              const SizedBox(height: 32),
              Text('Log Out', style: connectMuted(14).copyWith(color: ConnectColors.danger)),
            ],
          ),
        );
      },
    );

    if (widget.embedded) {
      return SingleChildScrollView(child: content);
    }

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SingleChildScrollView(child: content),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.app});
  final ConnectAppState app;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ConnectColors.accent.withValues(alpha: 0.15),
              ),
            ),
            CircleAvatar(
              radius: 40,
              backgroundColor: ConnectColors.accent,
              child: Text(app.initials, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(app.displayName, style: connectTitle(context, size: 24)),
        Text('${app.role} · ${app.industryLabel}', textAlign: TextAlign.center, style: connectMuted()),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: ConnectColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(ConnectColors.radius),
          ),
          child: Text(
            '✦ ${app.sessionsCompleted} Sessions Completed',
            style: const TextStyle(color: ConnectColors.accent, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: ConnectColors.textPrimary,
            side: const BorderSide(color: ConnectColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ConnectColors.radius)),
          ),
          child: const Text('Edit Profile'),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _Stat('${app.sessionsCompleted}', 'Sessions'),
            const SizedBox(width: 10),
            _Stat('${app.avgScore}%', 'Avg Score'),
            const SizedBox(width: 10),
            _Stat('${app.dayStreak}', 'Day Streak 🔥'),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ConnectColors.card,
            borderRadius: BorderRadius.circular(ConnectColors.radius),
            border: Border.all(color: ConnectColors.accent.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your Goal', style: connectMuted(12)),
              const SizedBox(height: 6),
              Text('🎯 ${app.goal}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
              Text(app.goalDetail, style: connectMuted(13)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);
  final String value;
  final String label;

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
            Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
            Text(label, style: connectMuted(11)),
          ],
        ),
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Skills', style: connectTitle(context, size: 18)),
        const SizedBox(height: 16),
        const _SkillRow('Communication', 0.78),
        const _SkillRow('Confidence', 0.71),
        const _SkillRow('Active Listening', 0.64),
        const _SkillRow('Follow-up', 0.85),
      ],
    );
  }
}

class _SkillRow extends StatelessWidget {
  const _SkillRow(this.label, this.value);
  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label),
              Text('${(value * 100).round()}%', style: connectMuted(13)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: ConnectColors.cardElevated,
              color: ConnectColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentSessions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Sessions', style: connectTitle(context, size: 18)),
            Text('See all', style: connectMuted(13)),
          ],
        ),
        const SizedBox(height: 12),
        const _SessionRow('👔', 'Recruiter Practice', '2 days ago', '82'),
        const _SessionRow('🤝', 'Networking Event', '5 days ago', '71'),
        const _SessionRow('💰', 'Investor Pitch', '1 week ago', '68'),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  const _SessionRow(this.emoji, this.title, this.when, this.score);
  final String emoji;
  final String title;
  final String when;
  final String score;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: ConnectColors.cardElevated,
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(when, style: connectMuted(12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: ConnectColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$score/100', style: const TextStyle(color: ConnectColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _PreferencesSection extends StatelessWidget {
  const _PreferencesSection({
    required this.notifications,
    required this.darkMode,
    required this.reminders,
    required this.onNotifications,
    required this.onDarkMode,
    required this.onReminders,
  });

  final bool notifications;
  final bool darkMode;
  final bool reminders;
  final ValueChanged<bool> onNotifications;
  final ValueChanged<bool> onDarkMode;
  final ValueChanged<bool> onReminders;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Preferences', style: connectMuted(12)),
        const SizedBox(height: 12),
        _ToggleRow('🔔', 'Notifications', notifications, onNotifications),
        _ToggleRow('🌙', 'Dark Mode', darkMode, onDarkMode),
        _ToggleRow('📅', 'Session Reminders', reminders, onReminders),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow(this.emoji, this.label, this.value, this.onChanged);
  final String emoji;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: ConnectColors.textPrimary,
            activeTrackColor: ConnectColors.accent,
          ),
        ],
      ),
    );
  }
}

// --- schedule_screen.dart ---
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key, this.embedded = true});

  final bool embedded;

  static const _weekDays = [
    WeekDay(label: 'MON', date: 10),
    WeekDay(label: 'TUE', date: 11, hasSession: true),
    WeekDay(label: 'WED', date: 12),
    WeekDay(label: 'THU', date: 13, hasSession: true),
    WeekDay(label: 'FRI', date: 14),
    WeekDay(label: 'SAT', date: 15),
    WeekDay(label: 'SUN', date: 16),
  ];

  @override
  Widget build(BuildContext context) {
    final content = ConnectPage(
      fullWidth: embedded && ConnectResponsive.useSideNavigation(context),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Schedule', style: connectTitle(context, size: 24)),
              IconButton(
                onPressed: () {},
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ConnectColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ConnectColors.border),
                  ),
                  child: const Icon(Icons.calendar_month_outlined, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _AiRecommendationsSection(),
          const SizedBox(height: 24),
          WeekStrip(
            days: _weekDays,
            selectedIndex: 1,
            todayIndex: 1,
            onDayTap: (_) {},
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Upcoming Sessions', style: connectTitle(context, size: 18)),
              TextButton(
                onPressed: () => connectSlideUp(context, const AddSessionScreen()),
                child: const Text(
                  '+ Add Session',
                  style: TextStyle(color: ConnectColors.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _UpcomingSessionCard(
            dayLabel: 'TUE',
            date: 11,
            time: '6:30 PM',
            title: 'Recruiter Practice',
            subtitle: 'Tomorrow · 15 minutes',
            chips: const ['Medium 🟡', '👔 Recruiter'],
            blockColor: ConnectColors.accent,
            onEdit: () => connectSlideUp(context, const EditSessionScreen()),
          ),
          _UpcomingSessionCard(
            dayLabel: 'THU',
            date: 13,
            time: '4:00 PM',
            title: 'Networking Event Practice',
            subtitle: 'Thursday · 10 minutes',
            chips: const ['Easy 🟢', '🤝 Networking'],
            blockColor: ConnectColors.warning,
            onEdit: () => connectSlideUp(context, const EditSessionScreen()),
          ),
          _UpcomingSessionCard(
            dayLabel: 'SAT',
            date: 15,
            time: '11:00 AM',
            title: 'Investor Pitch Practice',
            subtitle: 'Saturday · 15 minutes',
            chips: const ['Hard 🔴', '💰 Investor'],
            blockColor: ConnectColors.cardElevated,
            mutedBlock: true,
            onEdit: () => connectSlideUp(context, const EditSessionScreen()),
          ),
          const SizedBox(height: 28),
          Text('Past Sessions', style: connectMuted(12)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('See 12 past sessions', style: connectMuted(14)),
                  Text('›', style: connectMuted(18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );

    if (embedded) return content;

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: content,
    );
  }
}

class _AiRecommendationsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border(
          left: BorderSide(color: ConnectColors.accent, width: 3),
          top: BorderSide(color: ConnectColors.border),
          right: BorderSide(color: ConnectColors.border),
          bottom: BorderSide(color: ConnectColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: ConnectColors.accent.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: ConnectColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(ConnectColors.radius),
            ),
            child: const Text(
              '✦ AI Coach',
              style: TextStyle(color: ConnectColors.accent, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          _RecommendationCard(
            borderColor: ConnectColors.accent,
            badge: '📈 Based on your last session',
            body:
                'You struggled with behavioral questions. We recommend a 15-minute recruiter practice tomorrow at 6:30 PM.',
            buttonLabel: '+ Add to Schedule',
            buttonColor: ConnectColors.accent,
          ),
          const SizedBox(height: 12),
          _RecommendationCard(
            borderColor: ConnectColors.warning,
            badge: '📅 Upcoming opportunity',
            body:
                'You have a networking event in 3 days. We recommend two additional practice sessions this week.',
            buttonLabel: '+ Add to Schedule',
            buttonColor: ConnectColors.warning,
          ),
        ],
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.borderColor,
    required this.badge,
    required this.body,
    required this.buttonLabel,
    required this.buttonColor,
  });

  final Color borderColor;
  final String badge;
  final String body;
  final String buttonLabel;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ConnectColors.cardElevated,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border(left: BorderSide(color: borderColor, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(badge, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          Text(body, style: connectMuted(13)),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => connectSlideUp(context, const AddSessionScreen()),
              style: TextButton.styleFrom(
                foregroundColor: buttonColor,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(buttonLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  const _UpcomingSessionCard({
    required this.dayLabel,
    required this.date,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.blockColor,
    required this.onEdit,
    this.mutedBlock = false,
  });

  final String dayLabel;
  final int date;
  final String time;
  final String title;
  final String subtitle;
  final List<String> chips;
  final Color blockColor;
  final VoidCallback onEdit;
  final bool mutedBlock;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: mutedBlock ? ConnectColors.cardElevated : blockColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  dayLabel,
                  style: TextStyle(
                    fontSize: 10,
                    color: mutedBlock ? ConnectColors.textMuted : ConnectColors.textMuted,
                  ),
                ),
                Text(
                  '$date',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: mutedBlock ? ConnectColors.textMuted : ConnectColors.textPrimary,
                  ),
                ),
                Text(time, style: connectMuted(9)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(subtitle, style: connectMuted(12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: chips.map((c) => SessionMetaChip(label: c)).toList(),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: ConnectColors.textMuted, size: 20),
            color: ConnectColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit')),
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: ConnectColors.danger))),
            ],
            onSelected: (v) {
              if (v == 'edit') onEdit();
            },
          ),
        ],
      ),
    );
  }
}

// --- add_session_screen.dart ---
class AddSessionScreen extends StatefulWidget {
  const AddSessionScreen({super.key});

  @override
  State<AddSessionScreen> createState() => _AddSessionScreenState();
}

class _AddSessionScreenState extends State<AddSessionScreen> {
  int _scenario = 0;
  int _dayIndex = 1;
  int _timeIndex = 6;
  String _difficulty = 'Medium';
  bool _reminder = true;
  int _reminderTiming = 1;

  static const _scenarios = [
    ('👔', 'Recruiter'),
    ('💰', 'Investor'),
    ('🤝', 'Networking'),
    ('💼', 'Hiring Manager'),
    ('🎓', 'Mentor'),
    ('🚀', 'Founder'),
  ];

  static const _times = [
    '8:00 AM', '9:00 AM', '10:00 AM', '12:00 PM',
    '2:00 PM', '4:00 PM', '6:30 PM', '8:00 PM',
  ];

  static const _weekDays = [
    WeekDay(label: 'MON', date: 10),
    WeekDay(label: 'TUE', date: 11, hasSession: true),
    WeekDay(label: 'WED', date: 12),
    WeekDay(label: 'THU', date: 13, hasSession: true),
    WeekDay(label: 'FRI', date: 14),
    WeekDay(label: 'SAT', date: 15),
    WeekDay(label: 'SUN', date: 16),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const ConnectBackButton(),
                  Expanded(
                    child: Text(
                      'New Session',
                      textAlign: TextAlign.center,
                      style: connectTitle(context, size: 18),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 24),
                  children: [
                    sessionSectionTitle('Choose a scenario'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _scenarios.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final (emoji, label) = _scenarios[i];
                          return ScenarioChip(
                            emoji: emoji,
                            label: label,
                            selected: _scenario == i,
                            onTap: () => setState(() => _scenario = i),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Pick a date'),
                    const SizedBox(height: 12),
                    WeekStrip(
                      days: _weekDays,
                      selectedIndex: _dayIndex,
                      todayIndex: 1,
                      onDayTap: (i) => setState(() => _dayIndex = i),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Pick a time'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _times.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) => TimeChip(
                          label: _times[i],
                          selected: _timeIndex == i,
                          onTap: () => setState(() => _timeIndex = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Session settings'),
                    const SizedBox(height: 12),
                    SessionSettingsCard(
                      difficulty: _difficulty,
                      onDifficulty: (d) => setState(() => _difficulty = d),
                    ),
                    const SizedBox(height: 20),
                    sessionSectionTitle('Set a reminder'),
                    const SizedBox(height: 12),
                    SessionReminderCard(
                      enabled: _reminder,
                      timingIndex: _reminderTiming,
                      onToggle: (v) => setState(() => _reminder = v),
                      onTiming: (i) => setState(() => _reminderTiming = i),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              ConnectPrimaryButton(
                label: 'Schedule Session',
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: ConnectResponsive.isMobile(context) ? 8 : 16),
            ],
          ),
        ),
      ),
    );
  }
}

// --- edit_session_screen.dart ---
class EditSessionScreen extends StatefulWidget {
  const EditSessionScreen({super.key});

  @override
  State<EditSessionScreen> createState() => _EditSessionScreenState();
}

class _EditSessionScreenState extends State<EditSessionScreen> {
  int _scenario = 0;
  int _dayIndex = 1;
  int _timeIndex = 6;
  String _difficulty = 'Medium';
  bool _reminder = true;
  int _reminderTiming = 1;

  static const _scenarios = [
    ('👔', 'Recruiter'),
    ('💰', 'Investor'),
    ('🤝', 'Networking'),
    ('💼', 'Hiring Manager'),
    ('🎓', 'Mentor'),
    ('🚀', 'Founder'),
  ];

  static const _times = [
    '8:00 AM', '9:00 AM', '10:00 AM', '12:00 PM',
    '2:00 PM', '4:00 PM', '6:30 PM', '8:00 PM',
  ];

  static const _weekDays = [
    WeekDay(label: 'MON', date: 10),
    WeekDay(label: 'TUE', date: 11, hasSession: true),
    WeekDay(label: 'WED', date: 12),
    WeekDay(label: 'THU', date: 13, hasSession: true),
    WeekDay(label: 'FRI', date: 14),
    WeekDay(label: 'SAT', date: 15),
    WeekDay(label: 'SUN', date: 16),
  ];

  Future<void> _showDeleteDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: ConnectColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ConnectColors.radius)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Delete Session?', style: connectTitle(context, size: 20)),
              const SizedBox(height: 12),
              Text(
                'This will remove your Recruiter Practice session on Tuesday at 6:30 PM.',
                style: connectMuted(14),
              ),
              const SizedBox(height: 24),
              ConnectPrimaryButton(
                label: 'Cancel',
                outlined: true,
                onPressed: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ConnectColors.danger,
                    foregroundColor: ConnectColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ConnectColors.radius),
                    ),
                  ),
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: SafeArea(
        child: ConnectPage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const ConnectBackButton(),
                  Expanded(
                    child: Text(
                      'Edit Session',
                      textAlign: TextAlign.center,
                      style: connectTitle(context, size: 18),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 24),
                  children: [
                    sessionSectionTitle('Choose a scenario'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _scenarios.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final (emoji, label) = _scenarios[i];
                          return ScenarioChip(
                            emoji: emoji,
                            label: label,
                            selected: _scenario == i,
                            onTap: () => setState(() => _scenario = i),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Pick a date'),
                    const SizedBox(height: 12),
                    WeekStrip(
                      days: _weekDays,
                      selectedIndex: _dayIndex,
                      todayIndex: 1,
                      onDayTap: (i) => setState(() => _dayIndex = i),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Pick a time'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _times.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) => TimeChip(
                          label: _times[i],
                          selected: _timeIndex == i,
                          onTap: () => setState(() => _timeIndex = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Session settings'),
                    const SizedBox(height: 12),
                    SessionSettingsCard(
                      difficulty: _difficulty,
                      onDifficulty: (d) => setState(() => _difficulty = d),
                    ),
                    const SizedBox(height: 20),
                    sessionSectionTitle('Set a reminder'),
                    const SizedBox(height: 12),
                    SessionReminderCard(
                      enabled: _reminder,
                      timingIndex: _reminderTiming,
                      onToggle: (v) => setState(() => _reminder = v),
                      onTiming: (i) => setState(() => _reminderTiming = i),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Danger Zone',
                      style: connectMuted(12).copyWith(color: ConnectColors.danger),
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _showDeleteDialog,
                      icon: const Icon(Icons.delete_outline, color: ConnectColors.danger),
                      label: const Text('Delete Session', style: TextStyle(color: ConnectColors.danger)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: ConnectColors.danger),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ConnectColors.radius),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              ConnectPrimaryButton(
                label: 'Save Changes',
                onPressed: () => Navigator.pop(context),
              ),
              SizedBox(height: ConnectResponsive.isMobile(context) ? 8 : 16),
            ],
          ),
        ),
      ),
    );
  }
}

