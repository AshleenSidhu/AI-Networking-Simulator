import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class ScheduleColors {
  static const background = Color(0xFF080808);
  static const surface = Color(0xFF0F0F0F);
  static const elevated = Color(0xFF141414);
  static const accent = Color(0xFF7C3AED);
  static const teal = Color(0xFF2DD4BF);
  static const gold = Color(0xFFE8B84B);
  static const textPrimary = Color(0xFFF2F2F0);
  static const textSecondary = Color(0xFF666660);
  static const textMuted = Color(0xFF333330);
  static const success = Color(0xFF4CAF7D);
  static const border = Color(0x1AFFFFFF);
  static const borderFaint = Color(0x08FFFFFF);
  static const borderHairline = Color(0x0FFFFFFF);
  static const overlay = Color(0x80000000);
  static const accentGlow = Color(0x087C3AED);
}

TextStyle scheduleInter({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = ScheduleColors.textPrimary,
  double? height,
  double letterSpacing = 0,
}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

TextStyle scheduleCaps({Color color = ScheduleColors.accent, double size = 10}) =>
    scheduleInter(size: size, weight: FontWeight.w600, color: color, letterSpacing: 1);
