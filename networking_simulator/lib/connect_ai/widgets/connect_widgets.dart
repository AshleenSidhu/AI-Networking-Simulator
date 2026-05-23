import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../layout/responsive.dart';
import '../theme/connect_theme.dart';

/// Legacy wrapper — prefer [ConnectPage] for responsive layouts.
class ConnectFrame extends StatelessWidget {
  const ConnectFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ConnectPage(child: child);
  }
}

class ConnectPrimaryButton extends StatelessWidget {
  const ConnectPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.large = false,
    this.shimmer = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  final bool large;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final child = Text(
      label,
      style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: large ? 17 : 15),
    );

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: ConnectColors.textPrimary,
            side: const BorderSide(color: ConnectColors.border),
            padding: EdgeInsets.symmetric(vertical: large ? 18 : 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ConnectColors.radius)),
          ),
          child: child,
        ),
      );
    }

    final button = SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: ConnectColors.accent,
          foregroundColor: ConnectColors.textPrimary,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: large ? 20 : 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ConnectColors.radius)),
        ),
        child: child,
      ),
    );

    if (!shimmer) return button;
    return _ShimmerButton(child: button);
  }
}

class _ShimmerButton extends StatefulWidget {
  const _ShimmerButton({required this.child});
  final Widget child;

  @override
  State<_ShimmerButton> createState() => _ShimmerButtonState();
}

class _ShimmerButtonState extends State<_ShimmerButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 + _c.value * 2, 0),
              end: Alignment(_c.value * 2, 0),
              colors: [
                Colors.white.withValues(alpha: 0.85),
                Colors.white,
                Colors.white.withValues(alpha: 0.85),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class OnboardingProgress extends StatelessWidget {
  const OnboardingProgress({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(4, (i) {
        final filled = i < step;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
            decoration: BoxDecoration(
              color: filled ? ConnectColors.accent : ConnectColors.cardElevated,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        );
      }),
    );
  }
}

class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key, required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        ConnectResponsive.pagePadding(context).left,
        12,
        ConnectResponsive.pagePadding(context).right,
        0,
      ),
      child: Row(
        children: [
          Expanded(child: OnboardingProgress(step: step)),
          const SizedBox(width: 12),
          Text('$step of 4', style: connectMuted(12)),
          const SizedBox(width: 8),
          Text('Skip', style: connectMuted(13)),
        ],
      ),
    );
  }
}

class SelectableOptionCard extends StatelessWidget {
  const SelectableOptionCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? ConnectColors.accent.withValues(alpha: 0.12) : ConnectColors.card,
          borderRadius: BorderRadius.circular(ConnectColors.radius),
          border: Border.all(
            color: selected ? ConnectColors.accent : ConnectColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: ConnectColors.accent.withValues(alpha: 0.2), blurRadius: 16)]
              : null,
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: connectMuted(13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectChip extends StatelessWidget {
  const ConnectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? ConnectColors.accent.withValues(alpha: 0.2) : ConnectColors.card,
          borderRadius: BorderRadius.circular(ConnectColors.radius),
          border: Border.all(color: selected ? ConnectColors.accent : ConnectColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? ConnectColors.textPrimary : ConnectColors.textMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
