import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class ConnectColors {
  static const background = Color(0xFF0A0A0F);
  static const accent = Color(0xFF7C3AED);
  static const card = Color(0xFF13131A);
  static const cardElevated = Color(0xFF1C1C26);
  static const textPrimary = Color(0xFFF8F8FF);
  static const textMuted = Color(0xFF6B7280);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const border = Color(0xFF2A2A36);

  static const radius = 16.0;
}

ThemeData buildConnectTheme() {
  final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: ConnectColors.background,
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: ConnectColors.textPrimary,
      displayColor: ConnectColors.textPrimary,
    ),
    colorScheme: const ColorScheme.dark(
      primary: ConnectColors.accent,
      surface: ConnectColors.card,
    ),
  );
}

TextStyle connectTitle(BuildContext context, {double size = 26}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: FontWeight.w700, height: 1.2);

TextStyle connectMuted([double size = 14]) =>
    GoogleFonts.inter(fontSize: size, color: ConnectColors.textMuted, height: 1.45);
