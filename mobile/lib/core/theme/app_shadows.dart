import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppShadows {
  AppShadows._();

  // Soft depth shadows used across cards/pills/circles for visual separation.
  static List<BoxShadow> soft(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.18),
        offset: const Offset(0, 6),
        blurRadius: isDark ? 18 : 14,
      ),
    ];
  }

  static List<BoxShadow> softTight(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.42 : 0.14),
        offset: const Offset(0, 3),
        blurRadius: isDark ? 12 : 9,
      ),
    ];
  }

  // Neo-brutalist offset shadows — the BeyondC signature style
  // Usage: wrap widget in a Container with decoration using these

  static List<BoxShadow> neon = [
    const BoxShadow(
      color: AppColors.neon,
      offset: Offset(AppSpacing.shadowOffset, AppSpacing.shadowOffset),
      blurRadius: 0,
    ),
  ];

  static List<BoxShadow> pink = [
    const BoxShadow(
      color: AppColors.pink,
      offset: Offset(AppSpacing.shadowOffset, AppSpacing.shadowOffset),
      blurRadius: 0,
    ),
  ];

  static List<BoxShadow> blue = [
    const BoxShadow(
      color: AppColors.blue,
      offset: Offset(AppSpacing.shadowOffset, AppSpacing.shadowOffset),
      blurRadius: 0,
    ),
  ];

  static List<BoxShadow> purple = [
    const BoxShadow(
      color: AppColors.purple,
      offset: Offset(AppSpacing.shadowOffset, AppSpacing.shadowOffset),
      blurRadius: 0,
    ),
  ];

  static List<BoxShadow> orange = [
    const BoxShadow(
      color: AppColors.orange,
      offset: Offset(AppSpacing.shadowOffset, AppSpacing.shadowOffset),
      blurRadius: 0,
    ),
  ];

  static List<BoxShadow> ink = [
    const BoxShadow(
      color: AppColors.ink,
      offset: Offset(AppSpacing.shadowOffset, AppSpacing.shadowOffset),
      blurRadius: 0,
    ),
  ];

  // Pressed state — shadow collapses
  static List<BoxShadow> pressed = [
    const BoxShadow(
      color: Colors.transparent,
      offset: Offset.zero,
      blurRadius: 0,
    ),
  ];

  // Larger shadow for ticket card
  static List<BoxShadow> purpleLarge = [
    const BoxShadow(
      color: AppColors.purple,
      offset: Offset(6, 6),
      blurRadius: 0,
    ),
  ];
}
