import 'package:flutter/material.dart';

import '../theme/connect_theme.dart';
import 'connect_widgets.dart';
import 'schedule_widgets.dart';

class ConnectBackButton extends StatelessWidget {
  const ConnectBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.maybePop(context),
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ConnectColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: ConnectColors.border),
        ),
        child: const Icon(Icons.arrow_back_rounded, size: 20),
      ),
    );
  }
}

class SessionSettingsCard extends StatelessWidget {
  const SessionSettingsCard({
    super.key,
    required this.difficulty,
    required this.onDifficulty,
  });

  final String difficulty;
  final ValueChanged<String> onDifficulty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Duration'),
              Row(
                children: [
                  _CircleBtn(icon: Icons.remove),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('15 min', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  _CircleBtn(icon: Icons.add),
                ],
              ),
            ],
          ),
          const Divider(color: ConnectColors.border, height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Difficulty'),
              Row(
                children: ['Easy', 'Medium', 'Hard']
                    .map(
                      (d) => Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: DifficultyChip(
                          label: d,
                          selected: difficulty == d,
                          onTap: () => onDifficulty(d),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SessionReminderCard extends StatelessWidget {
  const SessionReminderCard({
    super.key,
    required this.enabled,
    required this.timingIndex,
    required this.onToggle,
    required this.onTiming,
  });

  final bool enabled;
  final int timingIndex;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onTiming;

  static const _timings = ['15 min before', '30 min before', '1 hour before'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ConnectColors.card,
        borderRadius: BorderRadius.circular(ConnectColors.radius),
        border: Border.all(color: ConnectColors.border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.notifications_outlined, color: ConnectColors.textMuted, size: 20),
              const SizedBox(width: 12),
              const Expanded(child: Text('Remind me before session')),
              Switch(
                value: enabled,
                onChanged: onToggle,
                activeThumbColor: ConnectColors.textPrimary,
                activeTrackColor: ConnectColors.accent,
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_timings.length, (i) {
                return ConnectChip(
                  label: _timings[i],
                  selected: timingIndex == i,
                  onTap: () => onTiming(i),
                );
              }),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ConnectColors.cardElevated,
        border: Border.all(color: ConnectColors.border),
      ),
      child: Icon(icon, size: 16, color: ConnectColors.textMuted),
    );
  }
}

Widget sessionSectionTitle(String title) {
  return Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16));
}
