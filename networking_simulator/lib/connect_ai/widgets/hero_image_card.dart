import 'package:flutter/material.dart';

import '../theme/connect_theme.dart';

class HeroImageCard extends StatelessWidget {
  const HeroImageCard({
    super.key,
    required this.imagePath,
    this.height = 180,
    this.fallbackIcon,
    this.fallbackGradient,
  });

  final String imagePath;
  final double height;
  final IconData? fallbackIcon;
  final List<Color>? fallbackGradient;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ConnectColors.radius),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _FallbackHero(
                icon: fallbackIcon ?? Icons.image_outlined,
                gradient: fallbackGradient,
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.05),
                    Colors.white.withValues(alpha: 0.72),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallbackHero extends StatelessWidget {
  const _FallbackHero({required this.icon, this.gradient});

  final IconData icon;
  final List<Color>? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient ??
              [
                ConnectColors.accent.withValues(alpha: 0.15),
                ConnectColors.background,
              ],
        ),
      ),
      child: Center(
        child: Icon(icon, size: 56, color: ConnectColors.accent.withValues(alpha: 0.55)),
      ),
    );
  }
}
