import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  // Display — League Spartan (headings, big text)
  static const TextStyle displayXL = TextStyle(
    fontFamily: 'League Spartan',
    fontSize: 40,
    fontWeight: FontWeight.w800,
    height: 1.1,
    letterSpacing: -1.0,
  );

  static const TextStyle displayLG = TextStyle(
    fontFamily: 'League Spartan',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMD = TextStyle(
    fontFamily: 'League Spartan',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle displaySM = TextStyle(
    fontFamily: 'League Spartan',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  // Body — Nunito
  static const TextStyle bodyLG = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySM = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyXS = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  // Labels — Space Grotesk (tags, badges, buttons, stats)
  static const TextStyle labelLG = TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMD = TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSM = TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );

  static const TextStyle labelXS = TextStyle(
    fontFamily: 'Space Grotesk',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );

  // Button text
  static const TextStyle buttonLG = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonMD = TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );
}
