import 'package:flutter/material.dart';

/// Professional design theme configuration.
/// Uses sleek dark colors suited for engineering/BLE terminal dashboard interfaces.
class AppTheme {
  AppTheme._();

  // Colors - Dark Theme
  static const Color darkBackground = Color(0xFF0F172A); // Deep slate
  static const Color darkSurface = Color(0xFF1E293B); // Card slate
  static const Color darkSurfaceVariant = Color(0xFF334155); // Highlight slate
  static const Color darkPrimary = Color(0xFF6366F1); // Bright Indigo
  static const Color darkPrimaryVariant = Color(0xFF818CF8);
  static const Color darkSecondary = Color(0xFF0EA5E9); // Sky Cyan
  static const Color darkAccent = Color(
    0xFF10B981,
  ); // Emerald Green (Connected)
  static const Color darkError = Color(0xFFEF4444); // Red
  static const Color darkOnBackground = Color(0xFFF8FAFC); // White/Grey text
  static const Color darkOnSurface = Color(0xFFE2E8F0);
  static const Color darkTextMuted = Color(0xFF94A3B8);

  // Colors - Light Theme
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightPrimary = Color(0xFF4F46E5);
  static const Color lightSecondary = Color(0xFF0284C7);
  static const Color lightAccent = Color(0xFF059669);
  static const Color lightError = Color(0xFFDC2626);
  static const Color lightOnBackground = Color(0xFF0F172A);
  static const Color lightOnSurface = Color(0xFF334155);
  static const Color lightTextMuted = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: darkPrimary,
        secondary: darkSecondary,
        surface: darkSurface,
        error: darkError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkOnBackground,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkSurfaceVariant, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkOnBackground,
          side: const BorderSide(color: darkSurfaceVariant),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: darkOnBackground,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkOnBackground,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: darkOnSurface),
        bodyMedium: TextStyle(fontSize: 14, color: darkTextMuted),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: const ColorScheme.light(
        primary: lightPrimary,
        secondary: lightSecondary,
        surface: lightSurface,
        error: lightError,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightOnSurface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightOnBackground,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: lightSurfaceVariant, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightOnBackground,
          side: const BorderSide(color: lightSurfaceVariant),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: lightOnBackground,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: lightOnBackground,
        ),
        bodyLarge: TextStyle(fontSize: 16, color: lightOnSurface),
        bodyMedium: TextStyle(fontSize: 14, color: lightTextMuted),
      ),
    );
  }
}
