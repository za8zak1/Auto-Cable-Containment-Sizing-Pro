import 'package:flutter/material.dart';

/// Central place for every color, gradient and shape constant used across
/// the app, so the light/dark themes and the custom-painted widgets
/// (gauges, radial chart) all stay visually consistent.
class AppColors {
  AppColors._();

  static const Color primaryBlue = Color(0xFF1730B8);
  static const Color primaryTeal = Color(0xFF17B8C4);
  static const Color accentAmber = Color(0xFFFFC000);
  static const Color accentOrange = Color(0xFFFF7A1A);

  static const Color pass = Color(0xFF16A34A);
  static const Color fail = Color(0xFFE11D48);
  static const Color warn = Color(0xFFF59E0B);

  static const Color lightBg = Color(0xFFF0F3F8);
  static const Color darkBg = Color(0xFF10151F);
  static const Color darkSurface = Color(0xFF1A2130);

  static const List<Color> heroGradient = [primaryBlue, primaryTeal];

  /// Colour ring used by the dashboard's cable-family radial chart and
  /// family list dots - order matches how families are enumerated.
  static const List<Color> familyPalette = [
    Color(0xFFE11D48), // red
    Color(0xFFEC4899), // pink
    Color(0xFF8B5CF6), // purple
    Color(0xFF3B82F6), // blue
    Color(0xFF06B6D4), // cyan
    Color(0xFF10B981), // green
    Color(0xFFF59E0B), // amber
  ];
}

class AppTheme {
  AppTheme._();

  static const double cardRadius = 22;
  static const double chipRadius = 30;

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
        brightness: Brightness.light,
      ),
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.6),
        ),
        labelStyle: const TextStyle(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.12),
        elevation: 4,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primaryBlue : Colors.grey.shade600,
          );
        }),
      ),
    );
  }

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryTeal,
        brightness: Brightness.dark,
      ),
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.primaryTeal.withValues(alpha: 0.18),
        elevation: 4,
      ),
    );
  }
}
