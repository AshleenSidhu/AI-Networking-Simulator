import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color tokens — switch via [isDark] (synced from profile toggle).
abstract final class ConnectColors {
  static bool isDark = false;

  static const accent = Color(0xFF7C3AED);
  static const actionGreen = Color(0xFF34C759);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFEF4444);
  static const radius = 16.0;

  static Color get background =>
      isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FC);

  static Color get card =>
      isDark ? const Color(0xFF13131A) : const Color(0xFFFFFFFF);

  static Color get cardElevated =>
      isDark ? const Color(0xFF1C1C26) : const Color(0xFFF3F4F8);

  static Color get textPrimary =>
      isDark ? const Color(0xFFF8F8FF) : const Color(0xFF2D2D2D);

  static Color get textMuted =>
      isDark ? const Color(0xFF6B7280) : const Color(0xFF6B7280);

  static Color get success =>
      isDark ? const Color(0xFF10B981) : const Color(0xFF10B981);

  static Color get border =>
      isDark ? const Color(0xFF2A2A36) : const Color(0xFFE5E7EB);

  static List<BoxShadow> get cardShadow => isDark
      ? []
      : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ];

  static List<BoxShadow> get cardShadowSelected => [
        BoxShadow(
          color: accent.withValues(alpha: isDark ? 0.28 : 0.18),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  /// White label/icon on filled purple or green buttons.
  static const onAccent = Colors.white;
}

ThemeData buildConnectTheme() => _buildTheme(Brightness.light);

ThemeData buildConnectDarkTheme() => _buildTheme(Brightness.dark);

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final background = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF8F9FC);
  final surface = isDark ? const Color(0xFF13131A) : const Color(0xFFFFFFFF);
  final textPrimary = isDark ? const Color(0xFFF8F8FF) : const Color(0xFF2D2D2D);

  final base = ThemeData(brightness: brightness, useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    ),
    colorScheme: isDark
        ? const ColorScheme.dark(
            primary: ConnectColors.accent,
            surface: Color(0xFF13131A),
            onSurface: Color(0xFFF8F8FF),
          )
        : const ColorScheme.light(
            primary: ConnectColors.accent,
            surface: Color(0xFFFFFFFF),
            onSurface: Color(0xFF2D2D2D),
          ),
  );
}

TextStyle connectTitle(BuildContext context, {double size = 26}) =>
    GoogleFonts.inter(
      fontSize: size,
      fontWeight: FontWeight.w700,
      height: 1.2,
      color: ConnectColors.textPrimary,
    );

TextStyle connectMuted([double size = 14]) =>
    GoogleFonts.inter(fontSize: size, color: ConnectColors.textMuted, height: 1.45);

bool isActionButtonLabel(String label) {
  final lower = label.toLowerCase();
  return lower.contains('save') || lower.contains('start call');
}

void applyConnectThemeMode({required bool dark}) {
  ConnectColors.isDark = dark;
}
