import 'package:flutter/material.dart';

import '../layout/responsive.dart';
import 'schedule_design.dart';

/// Responsive layout helpers for the schedule screen.
abstract final class ScheduleLayout {
  /// Full width on web/tablet; mobile keeps comfortable side margins via padding.
  static double contentWidth(BuildContext context, BoxConstraints constraints) =>
      constraints.maxWidth;

  static EdgeInsets pagePadding(BuildContext context) {
    final bottom = ConnectResponsive.useSideNavigation(context) ? 32.0 : 88.0;
    if (ConnectResponsive.isDesktop(context)) {
      return EdgeInsets.fromLTRB(48, 16, 48, bottom);
    }
    if (ConnectResponsive.isTablet(context)) {
      return EdgeInsets.fromLTRB(32, 12, 32, bottom);
    }
    return EdgeInsets.fromLTRB(20, 8, 20, bottom);
  }

  static bool useSplitLayout(BuildContext context) =>
      ConnectResponsive.isTablet(context) || ConnectResponsive.isDesktop(context);

  static bool useWideHeader(BuildContext context) =>
      ConnectResponsive.isDesktop(context) || ConnectResponsive.isTablet(context);

  static TimelineMetrics timelineMetrics(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final mobile = ConnectResponsive.isMobile(context);
    final desktop = ConnectResponsive.isDesktop(context);
    final compact = mobile || height < 740;

    return TimelineMetrics(
      hourHeight: desktop ? 44.0 : (compact ? 34.0 : 40.0),
      startHour: compact ? 9 : 8,
      endHour: compact ? 18 : 19,
      labelWidth: desktop ? 52.0 : (compact ? 40.0 : 48.0),
      maxHeight: desktop ? 480.0 : (compact ? 280.0 : 360.0),
    );
  }
}

class TimelineMetrics {
  const TimelineMetrics({
    required this.hourHeight,
    required this.startHour,
    required this.endHour,
    required this.labelWidth,
    required this.maxHeight,
  });

  final double hourHeight;
  final int startHour;
  final int endHour;
  final double labelWidth;
  final double maxHeight;
}

/// Surface card styling aligned with the home screen.
BoxDecoration scheduleSurfaceDecoration({Color? accent}) {
  final line = accent ?? ScheduleColors.accent;
  return BoxDecoration(
    color: ScheduleColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: ScheduleColors.border),
    boxShadow: [BoxShadow(color: line.withValues(alpha: 0.08), blurRadius: 40)],
  );
}
