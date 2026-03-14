import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  // Display — Plus Jakarta Sans (headings, big text)
  static const TextStyle displayXL = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    height: 1.1,
    letterSpacing: -1.0,
  );

  static const TextStyle displayLG = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    height: 1.15,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMD = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.2,
  );

  static const TextStyle displaySM = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    height: 1.25,
  );

  // Body — Nunito
  static const TextStyle bodyLG = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.6,
  );

  static const TextStyle bodyMD = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.5,
  );

  static const TextStyle bodySM = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.ink,
    height: 1.5,
  );

  static const TextStyle bodyXS = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.muted,
    height: 1.4,
  );

  // Labels — Space Grotesk (tags, badges, buttons, stats)
  static const TextStyle labelLG = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: 0.2,
  );

  static const TextStyle labelMD = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSM = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.ink,
    letterSpacing: 0.2,
  );

  static const TextStyle labelXS = TextStyle(
    fontFamily: 'SpaceGrotesk',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
    letterSpacing: 0.5,
  );

  // Button text
  static const TextStyle buttonLG = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonMD = TextStyle(
    fontFamily: 'PlusJakartaSans',
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
  );
}
