import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors
  static const Color neon = Color(0xFFC8FF00);        // Primary — Neon Yellow-Green
  static const Color pink = Color(0xFFFF2D78);         // Secondary — Hot Pink
  static const Color blue = Color(0xFF3D5BFF);         // Tertiary — Electric Blue
  static const Color purple = Color(0xFF9B5DE5);       // Fourth — Vivid Purple
  static const Color orange = Color(0xFFFF6B00);       // Fifth — Bright Orange

  // Neutrals
  static const Color ink = Color(0xFF0D0D0D);          // Near black
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F7F7);
  static const Color surfaceAlt = Color(0xFFFAFAFA);
  static const Color muted = Color(0xFF6B6B6B);
  static const Color divider = Color(0xFFE5E5E5);

  // Dark surface (for dark section cards)
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkBorder = Color(0xFF333333);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Status pill colors
  static const Color statusPending = Color(0xFFFBBF24);
  static const Color statusActive = Color(0xFF22C55E);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusCompleted = Color(0xFF3D5BFF);
}
