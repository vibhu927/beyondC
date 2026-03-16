import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.white,
      primaryColor: AppColors.neon,
      colorScheme: const ColorScheme.light(
        primary: AppColors.neon,
        secondary: AppColors.pink,
        tertiary: AppColors.blue,
        surface: AppColors.surface,
        onPrimary: AppColors.ink,
        onSecondary: AppColors.white,
        onSurface: AppColors.ink,
        error: AppColors.error,
      ),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.displaySM,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.muted,
        selectedLabelStyle: AppTypography.labelXS,
        unselectedLabelStyle: AppTypography.labelXS,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Input / TextField
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
              color: AppColors.ink, width: AppSpacing.borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
              color: AppColors.ink, width: AppSpacing.borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
              color: AppColors.neon, width: AppSpacing.borderWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
              color: AppColors.error, width: AppSpacing.borderWidth),
        ),
        hintStyle: AppTypography.bodyMD.copyWith(color: AppColors.muted),
        labelStyle: AppTypography.labelMD,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        labelStyle: AppTypography.labelSM,
        side: const BorderSide(color: AppColors.ink, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTypography.bodyMD.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      fontFamily: 'Nunito',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.ink,
      primaryColor: AppColors.neon,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neon,
        secondary: AppColors.pink,
        tertiary: AppColors.blue,
        surface: Color(0xFF171717),
        onPrimary: AppColors.ink,
        onSecondary: AppColors.white,
        onSurface: AppColors.white,
        error: AppColors.error,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.ink,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle:
            AppTypography.displaySM.copyWith(color: AppColors.white),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: Color(0xFF2A2A2A), width: 1),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF222222),
        contentTextStyle: AppTypography.bodyMD.copyWith(color: AppColors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      fontFamily: 'Nunito',
    );
  }
}
