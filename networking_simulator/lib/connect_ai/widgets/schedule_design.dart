import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/connect_theme.dart';

abstract final class ScheduleColors {
  static Color get background => ConnectColors.background;
  static Color get surface => ConnectColors.card;
  static Color get elevated => ConnectColors.cardElevated;
  static const accent = ConnectColors.accent;
  static const teal = Color(0xFF2DD4BF);
  static const gold = Color(0xFFE8B84B);
  static Color get textPrimary => ConnectColors.textPrimary;
  static Color get textSecondary =>
      ConnectColors.isDark ? const Color(0xFF666660) : const Color(0xFF6B7280);
  static Color get textMuted =>
      ConnectColors.isDark ? const Color(0xFF333330) : const Color(0xFF9CA3AF);
  static Color get success => ConnectColors.success;
  static Color get border => ConnectColors.border;
  static Color get borderFaint =>
      ConnectColors.isDark ? const Color(0x08FFFFFF) : const Color(0xFFF0F1F5);
  static Color get borderHairline =>
      ConnectColors.isDark ? const Color(0x0FFFFFFF) : const Color(0xFFF3F4F6);
  static Color get overlay =>
      ConnectColors.isDark ? const Color(0x80000000) : const Color(0x66000000);
  static Color get accentGlow =>
      ConnectColors.isDark ? const Color(0x087C3AED) : const Color(0x147C3AED);
}

TextStyle scheduleInter({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double? height,
  double letterSpacing = 0,
}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color ?? ScheduleColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

TextStyle scheduleCaps({Color color = ScheduleColors.accent, double size = 10}) =>
    scheduleInter(size: size, weight: FontWeight.w600, color: color, letterSpacing: 1);
