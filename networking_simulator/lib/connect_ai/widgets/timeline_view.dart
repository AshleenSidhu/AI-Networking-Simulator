import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/schedule_datetime.dart';
import 'schedule_design.dart';
import 'schedule_layout.dart';

class TimelineEvent {
  const TimelineEvent({
    required this.title,
    required this.subtitle,
    required this.startHour,
    required this.startMinute,
    required this.durationMinutes,
    required this.color,
  });

  final String title;
  final String subtitle;
  final int startHour;
  final int startMinute;
  final int durationMinutes;
  final Color color;

  factory TimelineEvent.fromSession(ScheduleDemoSession session) => TimelineEvent(
        title: session.title,
        subtitle: '${session.durationMinutes} min · ${session.difficulty}',
        startHour: session.start.hour,
        startMinute: session.start.minute,
        durationMinutes: session.durationMinutes,
        color: session.color,
      );
}

class TimelineView extends StatefulWidget {
  const TimelineView({
    super.key,
    this.startHour = 8,
    this.endHour = 19,
    this.hourHeight = 48,
    this.labelWidth = 48,
    this.maxHeight,
    this.showNowLine = true,
    this.events = const [],
  });

  factory TimelineView.adaptive(
    BuildContext context, {
    required DateTime selectedDay,
    List<TimelineEvent> events = const [],
  }) {
    final metrics = ScheduleLayout.timelineMetrics(context);
    final isToday = ScheduleDateTime.isSameDay(selectedDay, ScheduleDateTime.today);

    return TimelineView(
      startHour: metrics.startHour,
      endHour: metrics.endHour,
      hourHeight: metrics.hourHeight,
      labelWidth: metrics.labelWidth,
      maxHeight: metrics.maxHeight,
      showNowLine: isToday,
      events: events,
    );
  }

  final int startHour;
  final int endHour;
  final double hourHeight;
  final double labelWidth;
  final double? maxHeight;
  final bool showNowLine;
  final List<TimelineEvent> events;

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    _syncClock();
  }

  @override
  void didUpdateWidget(covariant TimelineView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showNowLine != widget.showNowLine) _syncClock();
  }

  void _syncClock() {
    _clock?.cancel();
    _clock = null;
    if (widget.showNowLine) {
      _clock = Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final hours = List.generate(widget.endHour - widget.startHour + 1, (i) => widget.startHour + i);
    final totalHeight = (hours.length - 1) * widget.hourHeight;

    final timeline = SizedBox(
      height: totalHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: widget.labelWidth,
            height: totalHeight,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                for (var i = 0; i < hours.length; i++)
                  Positioned(
                    top: i < hours.length - 1 ? i * widget.hourHeight : null,
                    bottom: i == hours.length - 1 ? 0 : null,
                    right: 6,
                    child: Text(
                      _formatHour(hours[i]),
                      style: scheduleInter(size: 10, color: ScheduleColors.textMuted),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Column(
                  children: List.generate(hours.length - 1, (_) {
                    return Container(
                      height: widget.hourHeight,
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: ScheduleColors.borderHairline)),
                      ),
                    );
                  }),
                ),
                ...widget.events.map(
                  (e) => _EventBlock(event: e, startHour: widget.startHour, hourHeight: widget.hourHeight),
                ),
                if (widget.showNowLine)
                  _CurrentTimeLine(
                    startHour: widget.startHour,
                    endHour: widget.endHour,
                    hourHeight: widget.hourHeight,
                    currentHour: now.hour,
                    currentMinute: now.minute,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.maxHeight != null && totalHeight > widget.maxHeight!) {
      return SizedBox(
        height: widget.maxHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ScheduleColors.border),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: timeline,
            ),
          ),
        ),
      );
    }

    return timeline;
  }

  String _formatHour(int h) {
    if (h == 0) return '12 AM';
    if (h < 12) return '$h AM';
    if (h == 12) return '12 PM';
    return '${h - 12} PM';
  }
}

class _EventBlock extends StatelessWidget {
  const _EventBlock({
    required this.event,
    required this.startHour,
    required this.hourHeight,
  });

  final TimelineEvent event;
  final int startHour;
  final double hourHeight;

  @override
  Widget build(BuildContext context) {
    final topMinutes = (event.startHour - startHour) * 60 + event.startMinute;
    final top = topMinutes / 60 * hourHeight;
    final height = (event.durationMinutes / 60) * hourHeight;
    final blockHeight = height.clamp(22.0, double.infinity);
    final showSubtitle = blockHeight >= 36;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      height: blockHeight,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: showSubtitle ? 5 : 2),
        decoration: BoxDecoration(
          color: event.color.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(6),
            bottomRight: Radius.circular(6),
          ),
          border: Border(left: BorderSide(color: event.color, width: 2)),
        ),
        child: showSubtitle
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    event.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: scheduleInter(size: 11, weight: FontWeight.w600, color: event.color),
                  ),
                  Text(
                    event.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: scheduleInter(size: 9, color: event.color.withValues(alpha: 0.5)),
                  ),
                ],
              )
            : Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  event.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: scheduleInter(size: 10, weight: FontWeight.w600, color: event.color),
                ),
              ),
      ),
    );
  }
}

class _CurrentTimeLine extends StatelessWidget {
  const _CurrentTimeLine({
    required this.startHour,
    required this.endHour,
    required this.hourHeight,
    required this.currentHour,
    required this.currentMinute,
  });

  final int startHour;
  final int endHour;
  final double hourHeight;
  final int currentHour;
  final int currentMinute;

  @override
  Widget build(BuildContext context) {
    if (currentHour < startHour || currentHour > endHour) return const SizedBox.shrink();

    final topMinutes = (currentHour - startHour) * 60 + currentMinute;
    final top = topMinutes / 60 * hourHeight;

    return Positioned(
      top: top,
      left: -4,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(color: ScheduleColors.accent, shape: BoxShape.circle),
          ),
          Expanded(child: Container(height: 1, color: ScheduleColors.accent)),
        ],
      ),
    );
  }
}
