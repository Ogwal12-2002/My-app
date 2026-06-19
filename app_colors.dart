import 'package:flutter/material.dart';

/// Centralized color palette. Keeping this separate from [AppTheme] makes
/// it easy to reskin the app later without touching ThemeData wiring.
class AppColors {
  // Brand
  static const Color primary = Color(0xFF2F6FED); // confident blue
  static const Color primaryDark = Color(0xFF5B8DEF);

  // Semantic
  static const Color success = Color(0xFF34C759);
  static const Color danger = Color(0xFFFF3B30);
  static const Color warning = Color(0xFFFFA726);

  // Light theme surfaces
  static const Color lightBackground = Color(0xFFF7F8FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF1A1C1E);
  static const Color lightMuted = Color(0xFF6B7280);

  // Dark theme surfaces
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1F22);
  static const Color darkOnSurface = Color(0xFFE7E9EC);
  static const Color darkMuted = Color(0xFF9AA0A6);

  // Scanner overlay
  static const Color overlayMask = Color(0xCC000000); // 80% black
  static const Color scanFrameBorder = Color(0xFFFFFFFF);
  static const Color scanLine = Color(0xFF34C759);
}
