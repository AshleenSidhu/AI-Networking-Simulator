import 'package:flutter/material.dart';

/// Date/time helpers for the schedule UI (local device clock).
abstract final class ScheduleDateTime {
  static DateTime dateOnly(DateTime value) => DateTime(value.year, value.month, value.day);

  static DateTime get now => DateTime.now();

  static DateTime get today => dateOnly(now);

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Monday-based week start.
  static DateTime startOfWeek(DateTime date) {
    final d = dateOnly(date);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  static List<DateTime> daysInWeek(DateTime weekStart) =>
      List.generate(7, (i) => dateOnly(weekStart.add(Duration(days: i))));

  static String weekdayShort(DateTime date) {
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    return labels[date.weekday - 1];
  }

  static String weekdayFull(DateTime date) {
    const labels = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return labels[date.weekday - 1];
  }

  static String monthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  static String fullDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdayFull(date)}, ${months[date.month - 1]} ${date.day}';
  }

  static String formatTime12(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  static String relativeDayLabel(DateTime date, {DateTime? atTime}) {
    final diff = dateOnly(date).difference(today).inDays;
    final timeSuffix = atTime != null ? ' · ${formatTime12(atTime)}' : '';
    if (diff == 0) return 'Today$timeSuffix';
    if (diff == 1) return 'Tomorrow$timeSuffix';
    if (diff == -1) return 'Yesterday$timeSuffix';
    return '${weekdayFull(date)}$timeSuffix';
  }

  static String nextWeekdayName(DateTime from, int weekday) {
    var d = dateOnly(from);
    while (d.weekday != weekday) {
      d = d.add(const Duration(days: 1));
    }
    if (isSameDay(d, from)) {
      d = d.add(const Duration(days: 7));
    }
    return weekdayFull(d);
  }

  static List<DateTime> timeSlotsForDay(DateTime day, {int startHour = 8, int endHour = 20}) {
    final slots = <DateTime>[];
    var cursor = DateTime(day.year, day.month, day.day, startHour);
    final end = DateTime(day.year, day.month, day.day, endHour);
    while (!cursor.isAfter(end)) {
      if (isSameDay(day, today)) {
        if (!cursor.isBefore(now)) slots.add(cursor);
      } else if (day.isAfter(today)) {
        slots.add(cursor);
      }
      cursor = cursor.add(const Duration(minutes: 30));
    }
    if (slots.isEmpty && isSameDay(day, today)) {
      final addMin = now.minute % 30 == 0 ? 30 : 30 - (now.minute % 30);
      final next = now.add(Duration(minutes: addMin));
      slots.add(DateTime(day.year, day.month, day.day, next.hour, next.minute));
    }
    return slots;
  }
}

/// Demo sessions anchored to the current calendar (UI-only data).
class ScheduleDemoSession {
  const ScheduleDemoSession({
    required this.start,
    required this.durationMinutes,
    required this.title,
    required this.difficulty,
    required this.color,
    required this.scenarioLabel,
    this.gold = false,
  });

  final DateTime start;
  final int durationMinutes;
  final String title;
  final String difficulty;
  final Color color;
  final String scenarioLabel;
  final bool gold;

  static List<ScheduleDemoSession> all() {
    final t = ScheduleDateTime.today;
    DateTime at(int dayOffset, int hour, [int minute = 0]) =>
        DateTime(t.year, t.month, t.day + dayOffset, hour, minute);

    return [
      ScheduleDemoSession(
        start: at(0, 9),
        durationMinutes: 30,
        title: 'Recruiter Practice',
        difficulty: 'Easy',
        color: const Color(0xFF2DD4BF),
        scenarioLabel: '👔 Recruiter',
      ),
      ScheduleDemoSession(
        start: at(0, 11),
        durationMinutes: 30,
        title: 'Investor Pitch Practice',
        difficulty: 'Hard',
        color: const Color(0xFFE8B84B),
        scenarioLabel: '💰 Investor',
        gold: true,
      ),
      ScheduleDemoSession(
        start: at(0, 18, 30),
        durationMinutes: 15,
        title: 'Networking Practice',
        difficulty: 'Medium',
        color: const Color(0xFF2DD4BF),
        scenarioLabel: '🤝 Networking',
      ),
      ScheduleDemoSession(
        start: at(1, 9),
        durationMinutes: 15,
        title: 'Recruiter Practice',
        difficulty: 'Easy',
        color: const Color(0xFF2DD4BF),
        scenarioLabel: '👔 Recruiter',
      ),
      ScheduleDemoSession(
        start: at(3, 11),
        durationMinutes: 30,
        title: 'Investor Pitch',
        difficulty: 'Hard',
        color: const Color(0xFFE8B84B),
        scenarioLabel: '💰 Investor',
        gold: true,
      ),
      ScheduleDemoSession(
        start: at(5, 18, 30),
        durationMinutes: 15,
        title: 'Networking Event Practice',
        difficulty: 'Medium',
        color: const Color(0xFF2DD4BF),
        scenarioLabel: '🤝 Networking',
      ),
    ];
  }

  static Set<DateTime> daysWithSessions() =>
      all().map((s) => ScheduleDateTime.dateOnly(s.start)).toSet();

  static List<ScheduleDemoSession> forDay(DateTime day) {
    final sessions = all().where((s) => ScheduleDateTime.isSameDay(s.start, day)).toList();
    sessions.sort((a, b) => a.start.compareTo(b.start));
    return sessions;
  }

  static List<ScheduleDemoSession> upcoming({DateTime? after}) {
    final cutoff = after ?? ScheduleDateTime.now;
    final sessions = all().where((s) => s.start.isAfter(cutoff)).toList();
    sessions.sort((a, b) => a.start.compareTo(b.start));
    return sessions;
  }
}
