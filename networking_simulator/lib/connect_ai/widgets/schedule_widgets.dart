import 'package:flutter/material.dart';

import '../theme/connect_theme.dart';

/// Shared schedule UI pieces.
class WeekStrip extends StatelessWidget {
  const WeekStrip({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.onDayTap,
    this.todayIndex = 1,
  });

  final List<WeekDay> days;
  final int selectedIndex;
  final int todayIndex;
  final ValueChanged<int> onDayTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (i) {
        final day = days[i];
        final selected = i == selectedIndex;
        final isToday = i == todayIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onDayTap(i),
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Text(
                  day.label,
                  style: connectMuted(11).copyWith(
                    color: selected || isToday ? ConnectColors.textPrimary : ConnectColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected || isToday
                        ? ConnectColors.accent.withValues(alpha: selected ? 0.35 : 0.2)
                        : Colors.transparent,
                    border: selected
                        ? Border.all(color: ConnectColors.accent, width: 2)
                        : null,
                  ),
                  child: Text(
                    '${day.date}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isToday || selected ? ConnectColors.textPrimary : ConnectColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: day.hasSession ? ConnectColors.accent : Colors.transparent,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class WeekDay {
  const WeekDay({required this.label, required this.date, this.hasSession = false});
  final String label;
  final int date;
  final bool hasSession;
}

class ScenarioChip extends StatelessWidget {
  const ScenarioChip({
    super.key,
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? ConnectColors.accent.withValues(alpha: 0.12) : ConnectColors.card,
          borderRadius: BorderRadius.circular(ConnectColors.radius),
          border: Border.all(
            color: selected ? ConnectColors.accent : ConnectColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: selected ? ConnectColors.textPrimary : ConnectColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TimeChip extends StatelessWidget {
  const TimeChip({
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
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? ConnectColors.textPrimary : ConnectColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class DifficultyChip extends StatelessWidget {
  const DifficultyChip({
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? ConnectColors.accent.withValues(alpha: 0.2) : ConnectColors.cardElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? ConnectColors.accent : ConnectColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? ConnectColors.textPrimary : ConnectColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class SessionMetaChip extends StatelessWidget {
  const SessionMetaChip({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ConnectColors.cardElevated,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: connectMuted(11)),
    );
  }
}
