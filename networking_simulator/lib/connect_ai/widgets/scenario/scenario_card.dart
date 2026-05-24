import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/connect_theme.dart';

class ScenarioCard extends StatelessWidget {
  const ScenarioCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    this.trailingIcon,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: selected ? ConnectColors.accent.withValues(alpha: 0.1) : ConnectColors.card,
            borderRadius: BorderRadius.circular(ConnectColors.radius),
            border: Border.all(
              color: selected ? ConnectColors.accent : ConnectColors.border,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected ? ConnectColors.cardShadowSelected : ConnectColors.cardShadow,
          ),
          child: Row(
            children: [
              if (trailingIcon != null)
                trailingIcon!
              else
                Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: ConnectColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: connectMuted(13)),
                  ],
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: ConnectColors.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: ConnectColors.accent.withValues(alpha: 0.45),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
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
