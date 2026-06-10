import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Transisi halaman kustom: fade lembut + sedikit geser ke atas.
/// Dipakai di semua platform agar perpindahan layar terasa mulus & konsisten.
class _SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const _SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.04),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class AppTheme {
  AppTheme._();

  static const _pageTransitions = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: _SmoothPageTransitionsBuilder(),
      TargetPlatform.iOS: _SmoothPageTransitionsBuilder(),
      TargetPlatform.macOS: _SmoothPageTransitionsBuilder(),
      TargetPlatform.windows: _SmoothPageTransitionsBuilder(),
      TargetPlatform.linux: _SmoothPageTransitionsBuilder(),
      TargetPlatform.fuchsia: _SmoothPageTransitionsBuilder(),
    },
  );

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.lightText),
        titleTextStyle: TextStyle(
          color: AppColors.lightText,
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.lightText),
        bodyMedium: TextStyle(color: AppColors.lightText),
        titleLarge: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600),
      ),
      cardColor: AppColors.lightSurface,
      dividerColor: AppColors.lightDivider,
      iconTheme: const IconThemeData(color: AppColors.lightText),
      pageTransitionsTheme: _pageTransitions,
      splashFactory: InkRipple.splashFactory,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
        error: AppColors.danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.darkText),
        titleTextStyle: TextStyle(
          color: AppColors.darkText,
          fontFamily: 'Poppins',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      fontFamily: 'Poppins',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.darkText),
        bodyMedium: TextStyle(color: AppColors.darkText),
        titleLarge: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.darkText, fontWeight: FontWeight.w600),
      ),
      cardColor: AppColors.darkSurface,
      dividerColor: AppColors.darkDivider,
      iconTheme: const IconThemeData(color: AppColors.darkText),
      pageTransitionsTheme: _pageTransitions,
      splashFactory: InkRipple.splashFactory,
    );
  }
}
