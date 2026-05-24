import 'package:flutter/material.dart';

import '../utils/schedule_datetime.dart';
import 'schedule_design.dart';

class WeekStripDay {
  const WeekStripDay({
    required this.date,
    this.hasSession = false,
  });

  final DateTime date;
  final bool hasSession;

  String get label => ScheduleDateTime.weekdayShort(date);
  int get dayNumber => date.day;
}

class WeekStripWidget extends StatelessWidget {
  const WeekStripWidget({
    super.key,
    required this.days,
    required this.selectedDay,
    required this.today,
    this.onDayTap,
    this.onPrevWeek,
    this.onNextWeek,
    this.compact = false,
    this.showNav = true,
  });

  final List<WeekStripDay> days;
  final DateTime selectedDay;
  final DateTime today;
  final ValueChanged<DateTime>? onDayTap;
  final VoidCallback? onPrevWeek;
  final VoidCallback? onNextWeek;
  final bool compact;
  final bool showNav;

  static List<WeekStripDay> forWeek(DateTime weekStart, {Set<DateTime>? sessionDays}) {
    final sessions = sessionDays ?? ScheduleDemoSession.daysWithSessions();
    return ScheduleDateTime.daysInWeek(weekStart)
        .map(
          (d) => WeekStripDay(
            date: d,
            hasSession: sessions.contains(ScheduleDateTime.dateOnly(d)),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final height = compact ? 56.0 : 68.0;
    final circle = compact ? 28.0 : 32.0;

    return SizedBox(
      height: height,
      child: Row(
        children: [
          if (showNav)
            _NavArrow(icon: Icons.chevron_left_rounded, onTap: onPrevWeek),
          Expanded(
            child: Row(
              children: days.map((day) {
                final isToday = ScheduleDateTime.isSameDay(day.date, today);
                final isSelected = ScheduleDateTime.isSameDay(day.date, selectedDay) && !isToday;
                return Expanded(
                  child: GestureDetector(
                    onTap: onDayTap == null ? null : () => onDayTap!(day.date),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day.label,
                          maxLines: 1,
                          style: scheduleInter(
                            size: compact ? 9 : 10,
                            weight: FontWeight.w600,
                            color: ScheduleColors.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: compact ? 3 : 4),
                        _DayCircle(
                          date: day.dayNumber,
                          size: circle,
                          isToday: isToday,
                          isSelected: isSelected,
                          hasSession: day.hasSession && !isToday,
                          compact: compact,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          if (showNav)
            _NavArrow(icon: Icons.chevron_right_rounded, onTap: onNextWeek),
        ],
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
        onPressed: onTap,
        icon: Icon(icon, size: 18, color: ScheduleColors.textSecondary),
      ),
    );
  }
}

class _DayCircle extends StatelessWidget {
  const _DayCircle({
    required this.date,
    required this.size,
    required this.isToday,
    required this.isSelected,
    required this.hasSession,
    this.compact = false,
  });

  final int date;
  final double size;
  final bool isToday;
  final bool isSelected;
  final bool hasSession;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final fontSize = size <= 28 ? 13.0 : 15.0;

    Widget number = Text(
      '$date',
      style: scheduleInter(
        size: fontSize,
        weight: isToday ? FontWeight.w600 : FontWeight.w400,
        color: isToday ? ScheduleColors.background : ScheduleColors.textPrimary,
      ),
    );

    if (isToday) {
      number = Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: const BoxDecoration(color: ScheduleColors.accent, shape: BoxShape.circle),
        child: Text(
          '$date',
          style: scheduleInter(size: fontSize, weight: FontWeight.w600, color: ScheduleColors.background),
        ),
      );
    } else if (isSelected) {
      number = Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ScheduleColors.accent),
        ),
        child: Text(
          '$date',
          style: scheduleInter(size: fontSize, weight: FontWeight.w500, color: ScheduleColors.accent),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        number,
        SizedBox(height: hasSession && !isToday ? 3 : (compact ? 3 : 4)),
        if (hasSession && !isToday)
          Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(color: ScheduleColors.teal, shape: BoxShape.circle),
          ),
      ],
    );
  }
}
