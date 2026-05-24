import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../layout/responsive.dart';
import '../utils/schedule_datetime.dart';
import '../widgets/schedule_design.dart';
import '../widgets/schedule_layout.dart';
import '../widgets/session_card.dart';
import '../widgets/timeline_view.dart';
import '../widgets/week_strip.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key, this.embedded = true});

  final bool embedded;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  late DateTime _weekStart;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = ScheduleDateTime.today;
    _weekStart = ScheduleDateTime.startOfWeek(_selectedDay);
  }

  List<WeekStripDay> get _weekDays => WeekStripWidget.forWeek(_weekStart);

  void _openAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: ScheduleColors.overlay,
      builder: (_) => AddSessionSheet(
        weekStart: _weekStart,
        selectedDay: _selectedDay,
        onDateSelected: (d) => setState(() => _selectedDay = ScheduleDateTime.dateOnly(d)),
      ),
    );
  }

  void _selectDay(DateTime day) => setState(() => _selectedDay = ScheduleDateTime.dateOnly(day));

  void _shiftWeek(int delta) {
    setState(() => _weekStart = _weekStart.add(Duration(days: 7 * delta)));
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ScheduleColors.background,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final split = ScheduleLayout.useSplitLayout(context);
            final wide = ScheduleLayout.useWideHeader(context);
            final compact = ConnectResponsive.isMobile(context);

            return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: ListView(
                padding: ScheduleLayout.pagePadding(context),
                children: [
                  _ScheduleAppBar(
                    onAdd: _openAddSheet,
                    compact: compact,
                    wide: wide,
                    monthLabel: ScheduleDateTime.monthYear(_selectedDay),
                  ),
                  SizedBox(height: wide ? 20 : 8),
                  if (wide) ...[
                    _ScheduleStatsRow(weekStart: _weekStart),
                    const SizedBox(height: 20),
                  ],
                  () {
                    final strip = WeekStripWidget(
                      days: _weekDays,
                      selectedDay: _selectedDay,
                      today: ScheduleDateTime.today,
                      compact: compact,
                      onDayTap: _selectDay,
                      onPrevWeek: () => _shiftWeek(-1),
                      onNextWeek: () => _shiftWeek(1),
                    );
                    final weekUi = wide
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                            decoration: scheduleSurfaceDecoration(),
                            child: strip,
                          )
                        : strip;
                    return weekUi.animate().fadeIn(duration: 280.ms).slideY(begin: 0.04, end: 0);
                  }(),
                  const SizedBox(height: 16),
                  const _Hairline(),
                  const SizedBox(height: 16),
                  const _AiRecommendationBanner().animate().fadeIn(delay: 80.ms, duration: 300.ms),
                  SizedBox(height: wide ? 28 : 20),
                  if (split)
                    ConnectSplitLayout(
                      primaryFlex: 3,
                      secondaryFlex: 2,
                      primary: _DayTimelineSection(selectedDay: _selectedDay, wide: wide),
                      secondary: const _UpcomingSection(),
                    )
                  else ...[
                    _DayTimelineSection(selectedDay: _selectedDay, wide: wide),
                    const SizedBox(height: 20),
                    const _UpcomingSection(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DayTimelineSection extends StatelessWidget {
  const _DayTimelineSection({required this.selectedDay, this.wide = false});

  final DateTime selectedDay;
  final bool wide;

  String get _sectionLabel =>
      ScheduleDateTime.isSameDay(selectedDay, ScheduleDateTime.today)
          ? 'TODAY'
          : ScheduleDateTime.weekdayShort(selectedDay);

  @override
  Widget build(BuildContext context) {
    final events = ScheduleDemoSession.forDay(selectedDay)
        .map(TimelineEvent.fromSession)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_sectionLabel, style: scheduleCaps()),
            Text(
              ScheduleDateTime.fullDate(selectedDay),
              style: scheduleInter(size: wide ? 13 : 12, color: ScheduleColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: EdgeInsets.all(wide ? 20 : 12),
          decoration: scheduleSurfaceDecoration(),
          child: TimelineView.adaptive(
            context,
            selectedDay: selectedDay,
            events: events,
          ).animate().fadeIn(delay: 160.ms, duration: 320.ms),
        ),
      ],
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection();

  @override
  Widget build(BuildContext context) {
    final upcoming = SessionCardData.upcomingFromNow();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('UPCOMING', style: scheduleCaps()),
            Text('View all', style: scheduleInter(size: 11, color: ScheduleColors.textSecondary)),
          ],
        ),
        const SizedBox(height: 10),
        if (upcoming.isEmpty)
          Text(
            'No upcoming sessions',
            style: scheduleInter(size: 13, color: ScheduleColors.textSecondary),
          )
        else
          ...upcoming.asMap().entries.map((e) {
            return Padding(
              padding: EdgeInsets.only(bottom: e.key < upcoming.length - 1 ? 8 : 0),
              child: SessionCardWidget(data: e.value),
            );
          }),
      ],
    );
  }
}

class _ScheduleAppBar extends StatelessWidget {
  const _ScheduleAppBar({
    required this.onAdd,
    required this.compact,
    required this.wide,
    required this.monthLabel,
  });

  final VoidCallback onAdd;
  final bool compact;
  final bool wide;
  final String monthLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: scheduleInter(size: wide ? 28 : (compact ? 20 : 22), weight: FontWeight.w200),
                  ),
                  const SizedBox(height: 4),
                  Text(monthLabel, style: scheduleInter(size: 12, color: ScheduleColors.textSecondary)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              visualDensity: VisualDensity.compact,
              icon: Icon(Icons.search_rounded, size: 22, color: ScheduleColors.textSecondary),
            ),
            Material(
              color: ScheduleColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                onTap: onAdd,
                borderRadius: BorderRadius.circular(999),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.add_rounded, size: 20, color: ScheduleColors.accent),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const _Hairline(),
      ],
    );
  }
}

class _ScheduleStatsRow extends StatelessWidget {
  const _ScheduleStatsRow({required this.weekStart});

  final DateTime weekStart;

  @override
  Widget build(BuildContext context) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final weekSessions = ScheduleDemoSession.all().where((s) {
      final d = ScheduleDateTime.dateOnly(s.start);
      return !d.isBefore(weekStart) && !d.isAfter(weekEnd);
    }).toList();
    final totalMinutes = weekSessions.fold<int>(0, (sum, s) => sum + s.durationMinutes);
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final practiceLabel = hours > 0 ? (mins > 0 ? '${hours}h ${mins}m' : '${hours}h') : '${mins}m';
    final nextInterview = ScheduleDateTime.nextWeekdayName(ScheduleDateTime.today, DateTime.thursday);
    final interviewShort = nextInterview.substring(0, 3);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: scheduleSurfaceDecoration(),
      child: Row(
        children: [
          Expanded(child: _ScheduleStat('${weekSessions.length}', 'This week')),
          const _StatDivider(),
          Expanded(child: _ScheduleStat(practiceLabel, 'Practice time')),
          const _StatDivider(),
          Expanded(child: _ScheduleStat(interviewShort, 'Next interview')),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 36, color: ScheduleColors.borderFaint);
  }
}

class _ScheduleStat extends StatelessWidget {
  const _ScheduleStat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: scheduleInter(size: 28, weight: FontWeight.w200, letterSpacing: -0.5),
        ),
        const SizedBox(height: 6),
        Text(
          label.toUpperCase(),
          style: scheduleInter(
            size: 10,
            weight: FontWeight.w600,
            color: ScheduleColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _Hairline extends StatelessWidget {
  const _Hairline();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1, color: ScheduleColors.borderHairline);
  }
}

class _AiRecommendationBanner extends StatelessWidget {
  const _AiRecommendationBanner();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stacked = constraints.maxWidth < 380;

        final interviewDay = ScheduleDateTime.nextWeekdayName(ScheduleDateTime.today, DateTime.thursday);
        final suggested = ScheduleDemoSession.upcoming().take(2).length;

        final content = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI RECOMMENDATION',
              style: scheduleInter(
                size: 11,
                weight: FontWeight.w600,
                color: ScheduleColors.accent,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'You have an interview $interviewDay. Practice recruiter calls today.',
              style: scheduleInter(size: 13, height: 1.4),
            ),
            const SizedBox(height: 4),
            Text(
              '$suggested sessions suggested',
              style: scheduleInter(size: 11, color: ScheduleColors.textSecondary),
            ),
          ],
        );

        final addButton = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: ScheduleColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ScheduleColors.accent.withValues(alpha: 0.25)),
          ),
          child: Text(
            'Add',
            style: scheduleInter(size: 12, weight: FontWeight.w500, color: ScheduleColors.accent),
          ),
        );

        final roomy = constraints.maxWidth >= 600;

        return Container(
          decoration: BoxDecoration(
            color: ScheduleColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ScheduleColors.border),
            boxShadow: [BoxShadow(color: ScheduleColors.accentGlow, blurRadius: 40)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                border: Border(left: BorderSide(color: ScheduleColors.accent, width: 2)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(14, roomy ? 16 : 12, 14, roomy ? 16 : 12),
                child: stacked
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 18, color: ScheduleColors.accent),
                              const SizedBox(width: 8),
                              Expanded(child: content),
                            ],
                          ),
                          const SizedBox(height: 10),
                          addButton,
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 18, color: ScheduleColors.accent),
                          const SizedBox(width: 10),
                          Expanded(child: content),
                          const SizedBox(width: 8),
                          addButton,
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AddSessionSheet extends StatefulWidget {
  const AddSessionSheet({
    super.key,
    required this.weekStart,
    required this.selectedDay,
    required this.onDateSelected,
  });

  final DateTime weekStart;
  final DateTime selectedDay;
  final ValueChanged<DateTime> onDateSelected;

  static const scenarios = [
    ('👔', 'Recruiter'),
    ('💰', 'Investor'),
    ('🤝', 'Networking'),
    ('🎓', 'Mentor'),
    ('🚀', 'Founder'),
  ];

  @override
  State<AddSessionSheet> createState() => _AddSessionSheetState();
}

class _AddSessionSheetState extends State<AddSessionSheet> {
  int _scenario = 0;
  int _timeIndex = 0;
  int _duration = 15;
  bool _reminder = true;
  int _reminderIndex = 1;

  List<DateTime> get _timeSlots =>
      ScheduleDateTime.timeSlotsForDay(widget.selectedDay);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;
    final slots = _timeSlots;
    if (_timeIndex >= slots.length) _timeIndex = 0;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Container(
          decoration: BoxDecoration(
            color: ScheduleColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: ScheduleColors.border)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('New Session', style: scheduleInter(size: 18, weight: FontWeight.w300)),
                  const SizedBox(height: 4),
                  Text('Schedule a practice session', style: scheduleInter(size: 13, color: ScheduleColors.textSecondary)),
                  const SizedBox(height: 24),
                  Text('SCENARIO', style: scheduleCaps()),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AddSessionSheet.scenarios.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        final (emoji, name) = AddSessionSheet.scenarios[i];
                        final selected = _scenario == i;
                        return GestureDetector(
                          onTap: () => setState(() => _scenario = i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? ScheduleColors.accent.withValues(alpha: 0.07) : Colors.transparent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected ? ScheduleColors.accent : Colors.white.withValues(alpha: 0.08),
                              ),
                            ),
                            child: Text(
                              '$emoji $name',
                              style: scheduleInter(
                                size: 13,
                                color: selected ? ScheduleColors.accent : ScheduleColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('DATE', style: scheduleCaps()),
                  const SizedBox(height: 10),
                  WeekStripWidget(
                    days: WeekStripWidget.forWeek(widget.weekStart),
                    selectedDay: widget.selectedDay,
                    today: ScheduleDateTime.today,
                    compact: true,
                    showNav: false,
                    onDayTap: (d) {
                      widget.onDateSelected(d);
                      setState(() => _timeIndex = 0);
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('TIME', style: scheduleCaps(color: ScheduleColors.teal)),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 36,
                    child: slots.isEmpty
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'No open slots today',
                              style: scheduleInter(size: 12, color: ScheduleColors.textSecondary),
                            ),
                          )
                        : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: slots.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final selected = _timeIndex == i;
                              return GestureDetector(
                                onTap: () => setState(() => _timeIndex = i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected ? ScheduleColors.teal.withValues(alpha: 0.12) : ScheduleColors.elevated,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: selected ? ScheduleColors.teal : ScheduleColors.border),
                                  ),
                                  child: Text(
                                    ScheduleDateTime.formatTime12(slots[i]),
                                    style: scheduleInter(
                                      size: 12,
                                      weight: FontWeight.w500,
                                      color: selected ? ScheduleColors.teal : ScheduleColors.textSecondary,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text('DURATION', style: scheduleCaps()),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleBtn(
                        icon: Icons.remove,
                        borderColor: Colors.white.withValues(alpha: 0.08),
                        onTap: () => setState(() => _duration = (_duration - 5).clamp(5, 60)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(durationLabel, style: scheduleInter(size: 14)),
                      ),
                      _CircleBtn(
                        icon: Icons.add,
                        borderColor: ScheduleColors.accent,
                        iconColor: ScheduleColors.accent,
                        onTap: () => setState(() => _duration = (_duration + 5).clamp(5, 60)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.notifications_none_rounded, size: 20, color: ScheduleColors.textSecondary),
                      const SizedBox(width: 10),
                      Text('Remind me', style: scheduleInter(size: 14)),
                      const Spacer(),
                      Switch(
                        value: _reminder,
                        onChanged: (v) => setState(() => _reminder = v),
                        activeTrackColor: ScheduleColors.accent.withValues(alpha: 0.5),
                        activeThumbColor: ScheduleColors.accent,
                      ),
                    ],
                  ),
                  if (_reminder) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: ['15 min', '30 min', '1 hr'].asMap().entries.map((e) {
                        final selected = _reminderIndex == e.key;
                        return Padding(
                          padding: EdgeInsets.only(right: e.key < 2 ? 8 : 0),
                          child: GestureDetector(
                            onTap: () => setState(() => _reminderIndex = e.key),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: selected ? ScheduleColors.accent.withValues(alpha: 0.12) : Colors.transparent,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: selected ? ScheduleColors.accent : ScheduleColors.border),
                              ),
                              child: Text(
                                e.value,
                                style: scheduleInter(
                                  size: 11,
                                  color: selected ? ScheduleColors.accent : ScheduleColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 28),
                  Material(
                    color: ScheduleColors.accent,
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 18, color: ScheduleColors.background),
                            const SizedBox(width: 8),
                            Text(
                              'Schedule Session',
                              style: scheduleInter(size: 14, weight: FontWeight.w600, color: ScheduleColors.background),
                            ),
                          ],
                        ),
                      ),
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

  String get durationLabel => '$_duration min';
}

class _CircleBtn extends StatelessWidget {
  const _CircleBtn({
    required this.icon,
    required this.borderColor,
    this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final Color borderColor;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: Icon(icon, size: 18, color: iconColor ?? ScheduleColors.textPrimary),
        ),
      ),
    );
  }
}