import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── BRAND (same in both modes) ──────────────────
  static const Color neon = Color(0xFFC8FF00);
  static const Color pink = Color(0xFFFF2D78);
  static const Color blue = Color(0xFF3D5BFF);
  static const Color purple = Color(0xFF9B5DE5);
  static const Color orange = Color(0xFFFF6B00);

  // ── LIGHT MODE ──────────────────────────────────
  static const Color lightBg = Color.fromARGB(255, 246, 246, 246);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFF0D0D0D);
  static const Color lightText = Color(0xFF0D0D0D);
  static const Color lightMuted = Color(0xFF6B6B6B);
  static const Color lightDivider = Color(0xFFE5E5E5);

  // ── DARK MODE ───────────────────────────────────
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceAlt = Color(0xFF222222);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkText = Color(0xFFF5F5F5);
  static const Color darkMuted = Color(0xFF888888);
  static const Color darkDivider = Color(0xFF2A2A2A);

  // ── SEMANTIC (same both modes) ──────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Backward-compatible aliases used across the app.
  static const Color ink = lightText;
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = lightSurface;
  static const Color surfaceAlt = lightSurfaceAlt;
  static const Color muted = lightMuted;
  static const Color divider = lightDivider;

  // Status pill colors
  static const Color statusPending = Color(0xFFFBBF24);
  static const Color statusActive = Color(0xFF22C55E);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusCompleted = Color(0xFF3D5BFF);
}
