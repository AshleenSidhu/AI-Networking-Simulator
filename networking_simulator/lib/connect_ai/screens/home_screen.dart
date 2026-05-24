import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../layout/responsive.dart';
import '../navigation/connect_routes.dart';
import '../state/connect_app_state.dart';
import '../theme/connect_theme.dart';
import '../widgets/connect_widgets.dart';
import '../widgets/session_form_widgets.dart';
import 'scenario_select_screen.dart';
import 'schedule_screen.dart';

// --- home_screen.dart ---

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
          const _TopNavRow(),
          const SizedBox(height: 24),
          _HeroSection(onHowItWorks: () => showHowItWorksPopup(context)),
          const SizedBox(height: 24),
          const _HomeDivider(),
          const SizedBox(height: 24),
          const _GlobalStatsRow(),
          const SizedBox(height: 24),
          const _SectionHeader(left: 'UPCOMING', right: 'See all'),
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
  const _TopNavRow();

  @override
  Widget build(BuildContext context) {
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
                Text('🔥 8', style: GoogleFonts.inter(fontSize: 11, color: _HomeColors.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Text('day streak', style: GoogleFonts.inter(fontSize: 10, color: _HomeColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 20, color: _HomeColors.border),
          const SizedBox(width: 12),
          Icon(Icons.notifications_none_rounded, size: 18, color: _HomeColors.textPrimary.withValues(alpha: 0.6)),
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
    return IntrinsicHeight(
      child: Row(
        children: [
          const Expanded(child: _GlobalStat('2.4k', 'USERS')),
          Container(width: 1, color: _HomeColors.borderFaint),
          const Expanded(child: _GlobalStat('94%', 'SUCCESS')),
          Container(width: 1, color: _HomeColors.borderFaint),
          const Expanded(child: _GlobalStat('4.9★', 'RATING')),
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
  const _SectionHeader({required this.left, required this.right});
  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: _homeCapsLabel()),
        Text(right, style: GoogleFonts.inter(fontSize: 11, color: _HomeColors.textSecondary)),
      ],
    );
  }
}

class _HomeUpcomingCard extends StatelessWidget {
  const _HomeUpcomingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
                                  'Recruiter Practice',
                                  style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: _HomeColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tomorrow · 6:30 PM',
                                  style: GoogleFonts.inter(fontSize: 12, color: _HomeColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _HomeColors.accent.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _HomeColors.accent.withValues(alpha: 0.19)),
                            ),
                            child: Text(
                              '15 min',
                              style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: _HomeColors.accent),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const _AvatarStack(),
                          const SizedBox(width: 8),
                          Text(
                            'with Sarah Chen',
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
    );
  }
}

class _AvatarStack extends StatelessWidget {
  const _AvatarStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 20,
      child: Stack(
        children: [
          _MiniAvatar('SC', _HomeColors.accent.withValues(alpha: 0.25), _HomeColors.accent, left: 0),
          _MiniAvatar('MW', _HomeColors.elevated, _HomeColors.textSecondary, left: 14),
          _MiniAvatar('PP', _HomeColors.success.withValues(alpha: 0.2), _HomeColors.success, left: 28),
        ],
      ),
    );
  }
}

class _MiniAvatar extends StatelessWidget {
  const _MiniAvatar(this.initials, this.bg, this.fg, {required this.left});
  final String initials;
  final Color bg;
  final Color fg;
  final double left;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: _HomeColors.surface, width: 1),
        ),
        child: Text(
          initials,
          style: GoogleFonts.inter(fontSize: 7, fontWeight: FontWeight.w700, color: fg),
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

  static const _metrics = [
    ('Confidence', 0.74, '74%'),
    ('Clarity', 0.81, '81%'),
    ('Listening', 0.68, '68%'),
    ('Follow-up', 0.77, '77%'),
  ];

  @override
  Widget build(BuildContext context) {
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
              Text('This week', style: GoogleFonts.inter(fontSize: 10, color: _HomeColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_metrics.length, (i) {
            final (label, fill, value) = _metrics[i];
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
            '+12% improvement from last week',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 12, color: _HomeColors.success),
          ),
        ],
      ),
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
    ConnectScope.of(context);
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
        backgroundColor: _HomeColors.background,
        body: Stack(
          children: [
            body,
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _FloatingPillNav(index: _index, onTap: goToTab),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: ConnectColors.background,
      body: Row(
        children: [
          _SideRail(index: _index, onTap: goToTab),
          VerticalDivider(width: 1, color: ConnectColors.border),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _FloatingPillNav extends StatelessWidget {
  const _FloatingPillNav({required this.index, required this.onTap});
  final int index;
  final void Function(int) onTap;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded),
    (Icons.phone_outlined, Icons.phone_rounded),
    (Icons.calendar_today_outlined, Icons.calendar_month_rounded),
    (Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: _HomeColors.elevated,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _HomeColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(_items.length, (i) {
                final (outline, filled) = _items[i];
                final active = index == i;
                return _PillNavItem(
                  icon: active ? filled : outline,
                  active: active,
                  accentColor: _HomeColors.accent,
                  onTap: () => onTap(i),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillNavItem extends StatelessWidget {
  const _PillNavItem({
    required this.icon,
    required this.active,
    required this.onTap,
    this.accentColor = _HomeColors.accent,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final color = active ? accentColor : _HomeColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: color),
            if (active)
              Container(
                width: 3,
                height: 3,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
              )
            else
              const SizedBox(height: 8),
          ],
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
              child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
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

// --- edit_profile_screen.dart ---
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;

  static const _roles = [
    ('🎓', 'Student', 'University or college student'),
    ('💼', 'Early Professional', '0-3 years work experience'),
    ('🚀', 'Mid-Level Professional', '3-8 years work experience'),
    ('👑', 'Senior Professional', '8+ years experience'),
  ];

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

  static const _goals = [
    ('🎯', 'Land a Job', 'Practice recruiter and hiring manager calls'),
    ('💰', 'Investor Pitch', 'Practice pitching to VCs and angels'),
    ('🤝', 'General Networking', 'Build connections in your industry'),
    ('💼', 'Client or Sales Calls', 'Win clients and close deals'),
  ];

  late String _role;
  late Set<String> _industriesSelected;
  late String _goal;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    final app = ConnectScope.of(context);
    _nameCtrl.text = app.name;
    _role = app.role;
    _industriesSelected = Set<String>.from(app.industries);
    _goal = app.goal;
    _loaded = true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (_industriesSelected.isEmpty) return;
    ConnectScope.of(context).updateProfile(
      name: _nameCtrl.text,
      role: _role,
      industries: _industriesSelected,
      goal: _goal,
    );
    Navigator.pop(context);
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
                      'Edit Profile',
                      textAlign: TextAlign.center,
                      style: connectTitle(context, size: 18),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 24, bottom: 16),
                  children: [
                    sessionSectionTitle('Your name'),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      style: TextStyle(color: ConnectColors.textPrimary, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'Your name',
                        hintStyle: connectMuted(15),
                        filled: true,
                        fillColor: ConnectColors.card,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ConnectColors.radius),
                          borderSide: BorderSide(color: ConnectColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(ConnectColors.radius),
                          borderSide: const BorderSide(color: ConnectColors.accent, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Your role'),
                    const SizedBox(height: 12),
                    ..._roles.map((r) {
                      final (emoji, title, subtitle) = r;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SelectableOptionCard(
                          emoji: emoji,
                          title: title,
                          subtitle: subtitle,
                          selected: _role == title,
                          onTap: () => setState(() => _role = title),
                        ),
                      );
                    }),
                    const SizedBox(height: 18),
                    sessionSectionTitle('Industry'),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _industries.map((ind) {
                        return ConnectChip(
                          label: ind,
                          selected: _industriesSelected.contains(ind),
                          onTap: () {
                            setState(() {
                              if (_industriesSelected.contains(ind)) {
                                if (_industriesSelected.length > 1) {
                                  _industriesSelected.remove(ind);
                                }
                              } else {
                                _industriesSelected.add(ind);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    sessionSectionTitle('Main goal'),
                    const SizedBox(height: 12),
                    ...List.generate(_goals.length, (i) {
                      final (emoji, title, subtitle) = _goals[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SelectableOptionCard(
                          emoji: emoji,
                          title: title,
                          subtitle: subtitle,
                          selected: _goal == title,
                          onTap: () => setState(() => _goal = title),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              ConnectPrimaryButton(label: 'Save Changes', onPressed: _save),
              SizedBox(height: ConnectResponsive.isMobile(context) ? 8 : 16),
            ],
          ),
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
          onPressed: () => connectSlideUp(context, const EditProfileScreen()),
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
            child: Text('$score/100', style: TextStyle(color: ConnectColors.success, fontWeight: FontWeight.w600, fontSize: 12)),
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

