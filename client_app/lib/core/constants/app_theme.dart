import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Canonical Semantic Colors (WCAG AA Contrast Verified)
  static const Color bgSurfacePrimary = Color(0xFF121212);
  static const Color bgSurfaceElevated = Color(0xFF1E1E1E);
  static const Color bgSurfaceMuted = Color(0xFF2C2C2C);

  static const Color fgTextPrimary = Color(0xFFF8F9FA);
  static const Color fgTextSecondary = Color(0xFF8E8E93);
  static const Color fgTextDisabled = Color(0xFF48484A);

  static const Color accentGold = Color(0xFFD4AF37);
  static const Color accentGoldLight = Color(0xFFE5C158);
  static const Color statusError = Color(0xFFFF453A);
  static const Color statusSuccess = Color(0xFF32D74B);

  // Base-8 Spacing System
  static const double space8 = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;

  static ThemeData get luxuryDarkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgSurfacePrimary,
      primaryColor: accentGold,
      fontFamily: 'SF Pro Display',
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        surface: bgSurfacePrimary,
        error: statusError,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentGold,
          foregroundColor: Colors.black,
          minimumSize: const Size.fromHeight(52), // Strict 48dp+ accessibility
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
