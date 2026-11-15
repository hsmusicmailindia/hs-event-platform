import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds
  static const bgSurfaceLight = Color(0xFFFFFFFF);
  static const bgElevatedLight = Color(0xFFF8F9FA);
  static const bgMutedLight = Color(0xFFE9ECEF);

  static const bgSurfaceDark = Color(0xFF121212);
  static const bgElevatedDark = Color(0xFF1E1E1E);
  static const bgMutedDark = Color(0xFF2C2C2C);

  // Foregrounds (WCAG AA Compliant)
  static const fgTextPrimaryLight = Color(0xFF212529);
  static const fgTextSecondaryLight = Color(0xFF6C757D);
  static const fgTextDisabledLight = Color(0xFFCED4DA);

  static const fgTextPrimaryDark = Color(0xFFF8F9FA);
  static const fgTextSecondaryDark = Color(0xFFADB5BD);
  static const fgTextDisabledDark = Color(0xFF495057);

  // Primary Actions
  static const actionPrimary = Color(0xFF0D6EFD);
  static const actionPrimaryDark = Color(0xFF3D8BFD);
  static const actionOnPrimary = Color(0xFFFFFFFF);

  // Feedback Tokens
  static const statusSuccess = Color(0xFF198754);
  static const statusWarning = Color(0xFFFFC107);
  static const statusError = Color(0xFFDC3545);
}