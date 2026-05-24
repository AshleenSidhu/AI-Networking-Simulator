import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../state/persona_repository.dart';
import '../../state/schedule_controller.dart';
import '../navigation/connect_routes.dart';
import '../state/connect_app_state.dart';
import '../theme/connect_theme.dart';
import 'call_screen.dart';
import 'scenario_select_screen.dart';
import 'schedule_screen.dart';

String _formatScheduledWhen(DateTime when) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(when.year, when.month, when.day);
  final delta = day.difference(today).inDays;
  final hour = when.hour % 12 == 0 ? 12 : when.hour % 12;
  final min = when.minute.toString().padLeft(2, '0');
  final ampm = when.hour >= 12 ? 'PM' : 'AM';
  final timeLabel = '$hour:$min $ampm';
  if (delta == 0) return 'Today · $timeLabel';
  if (delta == 1) return 'Tomorrow · $timeLabel';
  if (delta == -1) return 'Yesterday · $timeLabel';
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[when.month - 1]} ${when.day} · $timeLabel';
}

abstract final class _HomeColors {
  static Color get background => ConnectColors.background;
  static Color get surface => ConnectColors.card;
  static Color get elevated => ConnectColors.cardElevated;
  static const accent = ConnectColors.accent;
  static Color get textPrimary => ConnectColors.textPrimary;
  static Color get textSecondary =>
      ConnectColors.isDark ? const Color(0xFF666660) : const Color(0xFF6B7280);
  static Color get textMuted =>
      ConnectColors.isDark ? const Color(0xFF333330) : const Color(0xFF9CA3AF);
  static Color get success => ConnectColors.actionGreen;
  static Color get border => ConnectColors.border;
  static Color get borderFaint =>
      ConnectColors.isDark ? const Color(0x08FFFFFF) : const Color(0xFFF0F1F5);
}

TextStyle _homeCapsLabel({Color color = _HomeColors.accent, double size = 10, double letterSpacing = 1}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w600,
      letterSpacing: letterSpacing,
      color: color,
    );

TextStyle _homeMono(String text, {double size = 32, FontWeight weight = FontWeight.w200, Color? color}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? _HomeColors.textPrimary,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onGoProfile});

  final VoidCallback onGoProfile;

  static void showHowItWorksPopup(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _HowItWorksPopup(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _HomeColors.background,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 80),
        children: [
          const _StatusBarRow(),
          _TopNavRow(onGoProfile: onGoProfile),
          const SizedBox(height: 24),
          _HeroSection(onHowItWorks: () => showHowItWorksPopup(context)),
          const SizedBox(height: 24),
          const _HomeDivider(),
          const SizedBox(height: 24),
          const _GlobalStatsRow(),
          const SizedBox(height: 24),
          _SectionHeader(
            left: 'UPCOMING',
            right: 'See all',
            onRightTap: () => connectPush(context, const ScheduleScreen()),
          ),
          const SizedBox(height: 12),
          const _HomeUpcomingCard(),
          const SizedBox(height: 24),
          const _SectionHeader(left: 'SCENARIOS', right: 'Browse all'),
          const SizedBox(height: 12),
          const _ScenarioBentoGrid(),
          const SizedBox(height: 24),
          const _ProgressCard(),
        ],
      ),
    );
  }
}

class _StatusBarRow extends StatelessWidget {
  const _StatusBarRow();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '5:41',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: _HomeColors.textMuted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Row(
                children: [
                  _StatusDot(filled: true),
                  const SizedBox(width: 3),
                  _StatusDot(filled: true),
                  const SizedBox(width: 3),
                  _StatusDot(filled: false),
                  const SizedBox(width: 10),
                  _StatusDot(filled: true),
                  const SizedBox(width: 3),
                  _StatusDot(filled: true),
                  const SizedBox(width: 3),
                  _StatusDot(filled: true),
                  const SizedBox(width: 3),
                  _StatusDot(filled: false),
                ],
              ),
            ],
          ),
        ),
        Container(height: 1, color: _HomeColors.borderFaint),
      ],
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.filled});
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? _HomeColors.textSecondary.withValues(alpha: 0.6) : Colors.transparent,
        border: filled ? null : Border.all(color: _HomeColors.textSecondary.withValues(alpha: 0.35)),
      ),
    );
  }
}

class _TopNavRow extends StatelessWidget {
  const _TopNavRow({required this.onGoProfile});

  final VoidCallback onGoProfile;

  @override
  Widget build(BuildContext context) {
    final app = ConnectScope.of(context);
    final streak = app.dayStreak;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          Text(
            'CONNECTAI',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.65,
              color: _HomeColors.accent,
            ),
          ),
          const Spacer(),
          if (streak > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: _HomeColors.elevated,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _HomeColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('🔥 $streak', style: GoogleFonts.inter(fontSize: 11, color: _HomeColors.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Text('day streak', style: GoogleFonts.inter(fontSize: 10, color: _HomeColors.textSecondary)),
                ],
              ),
            ),
          if (streak > 0) const SizedBox(width: 12),
          Container(width: 1, height: 20, color: _HomeColors.border),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onGoProfile,
            child: CircleAvatar(
              radius: 14,
              backgroundColor: ConnectColors.accent,
              child: Text(
                app.initials,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onHowItWorks});

  final VoidCallback onHowItWorks;

  @override
  Widget build(BuildContext context) {
    final headline = GoogleFonts.inter(
      fontSize: 38,
      fontWeight: FontWeight.w300,
      height: 1.12,
      color: _HomeColors.textPrimary,
      letterSpacing: -0.5,
    );

    return SizedBox(
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            left: -20,
            right: -20,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.75,
                  colors: [
                    _HomeColors.accent.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('YOUR AI COACH', style: _homeCapsLabel(letterSpacing: 1.2)),
              const SizedBox(height: 8),
              Text('Practice the conversation', style: headline),
              RichText(
                text: TextSpan(
                  style: headline,
                  children: [
                    const TextSpan(text: 'before it '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: DecoratedBox(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: _HomeColors.accent, width: 1)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Text('happens.', style: headline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Real AI personas. Real feedback. Zero real-world consequences.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                  color: _HomeColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    flex: 65,
                    child: _HeroPrimaryButton(
                      onTap: () => connectPush(context, const ScenarioSelectScreen()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 35,
                    child: _HeroSecondaryButton(onTap: onHowItWorks),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HowItWorksPopup extends StatelessWidget {
  const _HowItWorksPopup();

  static const _steps = [
    ('01', 'Choose a persona', 'Pick a recruiter, investor, or build your own custom role.'),
    ('02', 'Start a live call', 'Talk naturally — the AI responds in real time like a real conversation.'),
    ('03', 'Get coached feedback', 'Review scores, metrics, and a narrative breakdown after every session.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: _HomeColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _HomeColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: _HomeColors.textMuted,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('HOW IT WORKS', style: _homeCapsLabel()),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded, size: 20, color: _HomeColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...List.generate(_steps.length, (i) {
              final (num, title, body) = _steps[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < _steps.length - 1 ? 10 : 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _HomeColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _HomeColors.border),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        num,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _HomeColors.accent,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _HomeColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              body,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                height: 1.55,
                                color: _HomeColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            Material(
              color: _HomeColors.accent,
              borderRadius: BorderRadius.circular(8),
              child: InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 48,
                  child: Center(
                    child: Text(
                      'Got it',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroPrimaryButton extends StatelessWidget {
  const _HeroPrimaryButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _HomeColors.accent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Start session',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSecondaryButton extends StatelessWidget {
  const _HeroSecondaryButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _HomeColors.border),
          ),
          child: Text(
            'How it works',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _HomeColors.textPrimary.withValues(alpha: 0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeDivider extends StatelessWidget {
  const _HomeDivider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: _HomeColors.borderFaint);
  }
}

class _GlobalStatsRow extends StatelessWidget {
  const _GlobalStatsRow();

  @override
  Widget build(BuildContext context) {
    final app = ConnectScope.of(context);
    final g = app.growthPercent;
    final growthLabel = g == 0 ? '—' : (g > 0 ? '+$g%' : '$g%');
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: _GlobalStat('${app.sessionsCompleted}', 'SESSIONS')),
          Container(width: 1, color: _HomeColors.borderFaint),
          Expanded(child: _GlobalStat('${app.avgScore}%', 'CONFIDENCE')),
          Container(width: 1, color: _HomeColors.borderFaint),
          Expanded(child: _GlobalStat(growthLabel, 'GROWTH')),
        ],
      ),
    );
  }
}

class _GlobalStat extends StatelessWidget {
  const _GlobalStat(this.value, this.label);
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: _homeMono(value, size: 32)),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            color: _HomeColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.left,
    required this.right,
    this.onRightTap,
  });

  final String left;
  final String right;
  final VoidCallback? onRightTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: _homeCapsLabel()),
        GestureDetector(
          onTap: onRightTap,
          behavior: HitTestBehavior.opaque,
          child: Text(right, style: GoogleFonts.inter(fontSize: 11, color: _HomeColors.textSecondary)),
        ),
      ],
    );
  }
}

class _HomeUpcomingCard extends ConsumerWidget {
  const _HomeUpcomingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final next = ref.watch(nextSessionProvider);
    if (next == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _HomeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _HomeColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: _HomeColors.textSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No upcoming sessions — schedule one from feedback or the Schedule tab.',
                style: GoogleFonts.inter(fontSize: 12, color: _HomeColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    final persona = ref.watch(personaByIdProvider(next.personaId));
    final title = persona?.name ?? 'Practice Session';
    final emoji = persona?.avatarEmoji ?? '💬';
    final whenLabel = _formatScheduledWhen(next.scheduledAt);

    return GestureDetector(
      onTap: () => connectPush(context, CallScreen(personaId: next.personaId)),
      child: Container(
        decoration: BoxDecoration(
          color: _HomeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _HomeColors.border),
          boxShadow: [BoxShadow(color: _HomeColors.accent.withValues(alpha: 0.08), blurRadius: 24)],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 2, color: _HomeColors.accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _HomeColors.textPrimary),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    whenLabel,
                                    style: GoogleFonts.inter(fontSize: 12, color: _HomeColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (next.note != null && next.note!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _HomeColors.accent.withValues(alpha: 0.07),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: _HomeColors.accent.withValues(alpha: 0.19)),
                                ),
                                child: Text(
                                  'Scheduled',
                                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _HomeColors.accent),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 10,
                              backgroundColor: _HomeColors.accent.withValues(alpha: 0.25),
                              child: Text(emoji, style: const TextStyle(fontSize: 10)),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'with $title',
                              style: GoogleFonts.inter(fontSize: 11, color: _HomeColors.textSecondary),
                            ),
                            const Spacer(),
                            Text(
                              'Join →',
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: _HomeColors.accent),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ScenarioBentoGrid extends StatelessWidget {
  const _ScenarioBentoGrid();

  static const _row1Height = 148.0;
  static const _row2Height = 118.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _row1Height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 58,
                child: _ScenarioTile(
                  emoji: '👔',
                  title: 'Recruiter',
                  subtitle: 'Most practiced',
                  badge: 'Popular',
                  onTap: () => connectPush(context, const ScenarioSelectScreen()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 38,
                child: _ScenarioTile(
                  emoji: '💰',
                  title: 'Investor',
                  subtitle: 'Advanced',
                  onTap: () => connectPush(context, const ScenarioSelectScreen()),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: _row2Height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ScenarioTile(
                  emoji: '🤝',
                  title: 'Networking',
                  subtitle: 'Beginner',
                  compact: true,
                  onTap: () => connectPush(context, const ScenarioSelectScreen()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScenarioTile(
                  emoji: '🎓',
                  title: 'Mentor',
                  subtitle: 'Intermediate',
                  compact: true,
                  onTap: () => connectPush(context, const ScenarioSelectScreen()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ScenarioTile(
                  emoji: '🚀',
                  title: 'Founder',
                  subtitle: 'Advanced',
                  compact: true,
                  onTap: () => connectPush(context, const ScenarioSelectScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScenarioTile extends StatefulWidget {
  const _ScenarioTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.compact = false,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final bool compact;

  @override
  State<_ScenarioTile> createState() => _ScenarioTileState();
}

class _ScenarioTileState extends State<_ScenarioTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bg = _pressed ? _HomeColors.borderFaint : _HomeColors.surface;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _HomeColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.emoji, style: TextStyle(fontSize: widget.compact ? 24 : 32, height: 1)),
                const Spacer(),
                if (widget.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _HomeColors.accent.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      widget.badge!,
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _HomeColors.accent),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Text(
              widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: widget.compact ? 13 : 14,
                fontWeight: FontWeight.w500,
                color: _HomeColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 10, color: _HomeColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    final app = ConnectScope.of(context);
    final skills = app.skills.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    if (skills.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _HomeColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _HomeColors.border),
        ),
        child: Text(
          'Complete a session to see skill progress from your feedback reports.',
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(fontSize: 12, color: _HomeColors.textSecondary),
        ),
      );
    }

    final g = app.growthPercent;
    final growthLine = g == 0
        ? 'Keep practicing to track improvement over time.'
        : (g > 0 ? '+$g% improvement from earlier sessions' : '$g% vs earlier sessions');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _HomeColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _HomeColors.border),
        boxShadow: [BoxShadow(color: _HomeColors.accent.withValues(alpha: 0.08), blurRadius: 24)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR PROGRESS',
                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 1, color: _HomeColors.textSecondary),
              ),
              Text('From feedback', style: GoogleFonts.inter(fontSize: 10, color: _HomeColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(skills.length, (i) {
            final entry = skills[i];
            final label = entry.key;
            final fill = entry.value.clamp(0.0, 1.0);
            final value = '${(fill * 100).round()}%';
            return Column(
              children: [
                if (i > 0) Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 10), color: _HomeColors.borderFaint),
                Row(
                  children: [
                    SizedBox(
                      width: 84,
                      child: Text(label, style: GoogleFonts.inter(fontSize: 13, color: _HomeColors.textPrimary)),
                    ),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (_, c) {
                          return Stack(
                            children: [
                              Container(height: 2, width: c.maxWidth.clamp(0, 120), color: _HomeColors.borderFaint),
                              Container(height: 2, width: (c.maxWidth.clamp(0, 120)) * fill, color: _HomeColors.accent),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      value,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: _HomeColors.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
          Container(height: 1, margin: const EdgeInsets.only(top: 12, bottom: 12), color: _HomeColors.borderFaint),
          Text(
            growthLine,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: g > 0 ? _HomeColors.success : _HomeColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

