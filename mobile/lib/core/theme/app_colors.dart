import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Canonical minimal palette for the current design direction.
  static const Color neon = Color(0xFFD8FF1A);
  static const Color darkGreen = Color(0xFF0F5B3B);
  static const Color offWhite = Color(0xFFF6F5F1);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color gray = Color(0xFF6B6B6B);
  static const Color darkBgGreen = Color(0xFF08110D);
  static const Color darkSurfaceGreen = Color(0xFF0F1B16);
  static const Color darkTintGreen = Color(0xFF163326);

  // Legacy accent colors kept for compatibility with older screens.
  static const Color pink = Color(0xFFFF2D78);
  static const Color blue = Color(0xFF3D5BFF);
  static const Color skyBlue = Color(0xFF78C8FF);
  static const Color purple = Color(0xFF9B5DE5);
  static const Color orange = Color(0xFFFF6B00);

  // Role palettes
  static const Color creatorPrimary = Color.fromARGB(255, 218, 246, 79);
  static const Color creatorDark = Color.fromARGB(255, 11, 68, 44);
  static const Color brandPrimary = Color.fromARGB(255, 228, 69, 125);
  static const Color brandDark = Color.fromARGB(255, 100, 11, 47);
  static const Color agencyPrimary = Color.fromARGB(255, 120, 200, 255);
  static const Color agencyDark = Color.fromARGB(255, 19, 39, 154);

  // LIGHT MODE
  static const Color lightBg = offWhite;
  static const Color lightSurface = pureWhite;
  static const Color lightSurfaceAlt = pureWhite;
  static const Color lightBorder = Color(0xFFE2E2E2);
  static const Color lightText = black;
  static const Color lightMuted = gray;
  static const Color lightDivider = Color(0xFFE8E8E8);

  // DARK MODE
  static const Color darkBg = darkBgGreen;
  static const Color darkSurface = darkSurfaceGreen;
  static const Color darkSurfaceAlt = darkTintGreen;
  static const Color darkBorder = Color(0xFF234636);
  static const Color darkText = Color(0xFFF5F5F1);
  static const Color darkMuted = Color(0xFFB0B0B0);
  static const Color darkDivider = Color(0xFF1E3329);

  // SEMANTIC (same both modes)
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);

  // Backward-compatible aliases used across the app.
  static const Color ink = lightText;
  static const Color white = pureWhite;
  static const Color surface = lightSurface;
  static const Color surfaceAlt = lightSurfaceAlt;
  static const Color muted = lightMuted;
  static const Color divider = lightDivider;

  // Status pill colors
  static const Color statusPending = Color(0xFFFBBF24);
  static const Color statusActive = Color(0xFF22C55E);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusCompleted = Color(0xFF3D5BFF);

  // Glass treatment for brand-primary status badges.
  static const LinearGradient brandPrimaryGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color.fromARGB(238, 255, 255, 255),
      Color.fromARGB(191, 255, 212, 228),
      Color.fromARGB(179, 251, 22, 102),
    ],
    stops: [0.0, 0.52, 1.0],
  );

  static const Color brandPrimaryGlassBorder = Color.fromARGB(92, 251, 22, 102);
  static const Color brandPrimaryGlassShadow = Color.fromARGB(38, 251, 22, 102);
}
