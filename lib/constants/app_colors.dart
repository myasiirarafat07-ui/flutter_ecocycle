import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary & Accent (Eco Green & Cyan)
  static const Color primary = Color(0xFF22C55E); // Green 500
  static const Color secondary = Color(0xFF0891B2); // Cyan 600
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF0F172A); // Slate 900
  static const Color lightTextMuted = Color(0xFF475569); // Slate 600
  static const Color lightDivider = Color(0xFFE2E8F0); // Slate 200

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF0D1F0F); // Very Dark Green
  static const Color darkSurface = Color(0xFF1A3B1A); // Dark Card
  static const Color darkSurfaceLight = Color(0xFF1E5C1E); // Lighter Dark Card
  static const Color darkText = Colors.white;
  static const Color darkTextMuted = Colors.white60;
  static const Color darkDivider = Color(0xFF1A3B1A);

  // Status Colors
  static const Color danger = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
}

/// Theme-aware color accessors. Resolves the correct light/dark value from the
/// active [Theme], so screens can write `context.textColor` instead of long
/// `Theme.of(context)...` chains.
extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textColor => isDark ? AppColors.darkText : AppColors.lightText;
  Color get mutedColor =>
      isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
  Color get surfaceColor =>
      isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surfaceAltColor =>
      isDark ? AppColors.darkSurfaceLight : AppColors.lightBackground;
  Color get bgColor =>
      isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get dividerColor =>
      isDark ? AppColors.darkDivider : AppColors.lightDivider;
}
