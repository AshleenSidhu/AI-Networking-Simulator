import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/session.dart';
import '../../state/auth_controller.dart';
import '../../state/persona_repository.dart';
import '../../state/user_stats_provider.dart';
import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../state/connect_app_state.dart';
import '../theme/connect_theme.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool notifications = true;
  bool reminders = true;

  @override
  Widget build(BuildContext context) {
    final app = ConnectScope.of(context);

    final content = ListenableBuilder(
      listenable: app,
      builder: (context, _) {
        final isWide = ConnectResponsive.isDesktop(context);

        final header = _ProfileHeader(app: app);
        final skills = _SkillsSection(app: app);
        final sessions = _RecentSessions();
        final prefs = _PreferencesSection(
          notifications: notifications,
          darkMode: app.isDarkMode,
          reminders: reminders,
          onNotifications: (v) => setState(() => notifications = v),
          onDarkMode: app.setDarkMode,
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
                const Center(child: _LogOutButton()),
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
              const _LogOutButton(),
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

/// Tappable "Log Out" affordance shared by the mobile and wide profile
/// layouts. Calls [AuthController.signOut] and routes back to the welcome
/// screen so the user lands in the same state as a fresh app launch.
class _LogOutButton extends ConsumerWidget {
  const _LogOutButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        await ref.read(authControllerProvider).signOut();
        if (!context.mounted) return;
        connectReplace(context, const WelcomeScreen());
      },
      child: Text(
        'Log Out',
        style: connectMuted(14).copyWith(color: ConnectColors.danger),
      ),
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
            side: BorderSide(color: ConnectColors.border),
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
  const _SkillsSection({required this.app});
  final ConnectAppState app;

  @override
  Widget build(BuildContext context) {
    // Skill keys must match what the feedback judge emits. The 4 below
    // are the canonical set; the judge may emit more, in which case they
    // aggregate into `app.skills` but aren't surfaced here yet.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Your Skills', style: connectTitle(context, size: 18)),
        const SizedBox(height: 16),
        _SkillRow('Communication', app.skills['Communication'] ?? 0),
        _SkillRow('Confidence', app.skills['Confidence'] ?? 0),
        _SkillRow('Active Listening', app.skills['Active Listening'] ?? 0),
        _SkillRow('Follow-up', app.skills['Follow-up'] ?? 0),
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

class _RecentSessions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncSessions = ref.watch(recentSessionsProvider);
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
        asyncSessions.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: ConnectColors.accent),
            ),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('Could not load sessions: $e', style: connectMuted()),
          ),
          data: (sessions) {
            if (sessions.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ConnectColors.card,
                  borderRadius:
                      BorderRadius.circular(ConnectColors.radius),
                  border: Border.all(color: ConnectColors.border),
                ),
                child: Text(
                  'Finish a call and it will show up here.',
                  style: connectMuted(),
                ),
              );
            }
            return Column(
              children: sessions
                  .take(5)
                  .map((s) => _SessionRow(session: s))
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _SessionRow extends ConsumerWidget {
  const _SessionRow({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final persona = ref.watch(personaByIdProvider(session.personaId));
    final emoji = persona?.avatarEmoji ?? '💬';
    final title = persona?.name ?? 'Custom Persona';
    final when = _relativeTime(session.startedAt);
    final scoreText = session.score?.toString();

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
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(when, style: connectMuted(12)),
              ],
            ),
          ),
          if (scoreText != null)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ConnectColors.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$scoreText/100',
                style: TextStyle(
                  color: ConnectColors.success,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: ConnectColors.cardElevated,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('No score', style: connectMuted(11)),
            ),
        ],
      ),
    );
  }
}

String _relativeTime(DateTime t) {
  final now = DateTime.now();
  final d = now.difference(t);
  if (d.inDays >= 7) return '${(d.inDays / 7).floor()}w ago';
  if (d.inDays >= 1) return '${d.inDays}d ago';
  if (d.inHours >= 1) return '${d.inHours}h ago';
  if (d.inMinutes >= 1) return '${d.inMinutes}m ago';
  return 'just now';
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
