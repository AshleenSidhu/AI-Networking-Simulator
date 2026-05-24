import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/connect_theme.dart';
import 'scenario_data.dart';

class IndustryChip extends StatelessWidget {
  const IndustryChip({
    super.key,
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final IndustryOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? ConnectColors.accent.withValues(alpha: 0.18) : ConnectColors.cardElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? ConnectColors.accent : ConnectColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                option.icon,
                size: 16,
                color: selected ? ConnectColors.accent : ConnectColors.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                option.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? ConnectColors.textPrimary : ConnectColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IndustryChipRow extends StatelessWidget {
  const IndustryChipRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: kScenarioIndustries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final option = kScenarioIndustries[index];
          return IndustryChip(
            option: option,
            selected: selected == option.label,
            onTap: () => onSelected(option.label),
          );
        },
      ),
    );
  }
}
