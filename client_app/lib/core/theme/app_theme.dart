import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.bgSurfaceLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.actionPrimary,
        onPrimary: AppColors.actionOnPrimary,
        surface: AppColors.bgSurfaceLight,
        error: AppColors.statusError,
      ),
      textTheme: AppTypography.textTheme(
        AppColors.fgTextPrimaryLight,
        AppColors.fgTextSecondaryLight,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48), // WCAG AA 48dp touch target
          backgroundColor: AppColors.actionPrimary,
          foregroundColor: AppColors.actionOnPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgSurfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.actionPrimaryDark,
        onPrimary: AppColors.actionOnPrimary,
        surface: AppColors.bgSurfaceDark,
        error: AppColors.statusError,
      ),
      textTheme: AppTypography.textTheme(
        AppColors.fgTextPrimaryDark,
        AppColors.fgTextSecondaryDark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: AppColors.actionPrimaryDark,
          foregroundColor: AppColors.actionOnPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
    );
  }
}