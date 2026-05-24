import 'package:flutter/material.dart';

import '../utils/schedule_datetime.dart';
import 'schedule_design.dart';
import 'schedule_layout.dart';

class SessionCardData {
  const SessionCardData({
    required this.dayLabel,
    required this.date,
    required this.title,
    required this.subtitle,
    required this.chips,
    required this.accentColor,
  });

  final String dayLabel;
  final int date;
  final String title;
  final String subtitle;
  final List<SessionChipData> chips;
  final Color accentColor;

  factory SessionCardData.fromSession(ScheduleDemoSession session) => SessionCardData(
        dayLabel: ScheduleDateTime.weekdayShort(session.start),
        date: session.start.day,
        title: session.title,
        subtitle: ScheduleDateTime.relativeDayLabel(
          session.start,
          atTime: session.start,
        ),
        accentColor: session.color,
        chips: [
          SessionChipData(label: session.scenarioLabel, accent: true, gold: session.gold),
          SessionChipData(label: '${session.durationMinutes} min', accent: false),
        ],
      );

  static List<SessionCardData> upcomingFromNow({int limit = 3}) =>
      ScheduleDemoSession.upcoming()
          .take(limit)
          .map(SessionCardData.fromSession)
          .toList();
}

class SessionChipData {
  const SessionChipData({required this.label, required this.accent, this.gold = false});
  final String label;
  final bool accent;
  final bool gold;
}

class SessionCardWidget extends StatelessWidget {
  const SessionCardWidget({
    super.key,
    required this.data,
    this.onJoin,
    this.onMenu,
  });

  final SessionCardData data;
  final VoidCallback? onJoin;
  final VoidCallback? onMenu;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 340;

        final details = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: scheduleInter(size: 14, weight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(data.subtitle, style: scheduleInter(size: 12, color: ScheduleColors.textSecondary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: data.chips.map((c) => _Chip(data: c, accentColor: data.accentColor)).toList(),
            ),
          ],
        );

        final actions = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
              onPressed: onMenu,
              icon: Icon(Icons.more_horiz_rounded, size: 20, color: ScheduleColors.textMuted),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onJoin,
              child: Text(
                'Join',
                style: scheduleInter(size: 12, weight: FontWeight.w500, color: data.accentColor),
              ),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: scheduleSurfaceDecoration(accent: data.accentColor),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 2, color: data.accentColor),
              const SizedBox(width: 12),
              _DateBlock(dayLabel: data.dayLabel, date: data.date),
              Container(
                width: 1,
                height: narrow ? 48 : 56,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: ScheduleColors.borderFaint,
              ),
              Expanded(
                child: narrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [details, const SizedBox(height: 8), actions],
                      )
                    : details,
              ),
              if (!narrow) actions,
            ],
          ),
        );
      },
    );
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock({required this.dayLabel, required this.date});
  final String dayLabel;
  final int date;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dayLabel,
          style: scheduleInter(size: 10, weight: FontWeight.w600, color: ScheduleColors.textSecondary, letterSpacing: 0.8),
        ),
        Text(
          '$date',
          style: scheduleInter(size: 24, weight: FontWeight.w200, color: ScheduleColors.textPrimary),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.data, required this.accentColor});
  final SessionChipData data;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final color = data.gold ? ScheduleColors.gold : accentColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: data.accent ? color.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: data.accent ? color.withValues(alpha: 0.19) : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        data.label,
        style: scheduleInter(
          size: 10,
          weight: FontWeight.w500,
          color: data.accent ? color : ScheduleColors.textSecondary,
        ),
      ),
    );
  }
}
