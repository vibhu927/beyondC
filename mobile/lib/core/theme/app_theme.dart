import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBg,
      primaryColor: AppColors.neon,
      colorScheme: const ColorScheme.light(
        primary: AppColors.neon,
        secondary: AppColors.pink,
        tertiary: AppColors.blue,
        surface: AppColors.lightSurface,
        onPrimary: AppColors.lightText,
        onSecondary: AppColors.lightBg,
        onSurface: AppColors.lightText,
        error: AppColors.error,
      ),
      textTheme: _buildLightTextTheme(),
      primaryTextTheme: _buildLightTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBg,
        foregroundColor: AppColors.lightText,
        elevation: 0,
        toolbarHeight: kToolbarHeight,
        centerTitle: false,
        titleTextStyle: AppTypography.displaySM,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        surfaceTintColor: Colors.transparent,
        shape: Border(
          bottom: BorderSide(color: AppColors.lightDivider, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.neon,
        unselectedItemColor: AppColors.lightMuted,
        selectedLabelStyle: AppTypography.labelXS,
        unselectedLabelStyle: AppTypography.labelXS,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
            width: AppSpacing.borderWidth,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.lightBorder,
            width: AppSpacing.borderWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.neon,
            width: AppSpacing.borderWidth,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: AppSpacing.borderWidth,
          ),
        ),
        hintStyle: AppTypography.bodyMD.copyWith(color: AppColors.lightMuted),
        labelStyle: AppTypography.labelMD.copyWith(color: AppColors.lightText),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        labelStyle: AppTypography.labelSM.copyWith(color: AppColors.lightText),
        side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightDivider,
        thickness: 1,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightText,
        contentTextStyle:
            AppTypography.bodyMD.copyWith(color: AppColors.lightBg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      fontFamily: GoogleFonts.nunito().fontFamily,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBg,
      primaryColor: AppColors.neon,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neon,
        secondary: AppColors.pink,
        tertiary: AppColors.blue,
        surface: AppColors.darkSurface,
        onPrimary: AppColors.lightText,
        onSecondary: AppColors.darkText,
        onSurface: AppColors.darkText,
        error: AppColors.error,
      ),
      textTheme: _buildDarkTextTheme(),
      primaryTextTheme: _buildDarkTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBg,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        toolbarHeight: kToolbarHeight,
        centerTitle: false,
        titleTextStyle:
            AppTypography.displaySM.copyWith(color: AppColors.darkText),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        surfaceTintColor: Colors.transparent,
        shape: const Border(
          bottom: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.neon,
        unselectedItemColor: AppColors.darkMuted,
        selectedLabelStyle: AppTypography.labelXS,
        unselectedLabelStyle: AppTypography.labelXS,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.neon, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTypography.bodyMD.copyWith(color: AppColors.darkMuted),
        labelStyle: AppTypography.labelMD.copyWith(color: AppColors.darkText),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        labelStyle: AppTypography.labelSM.copyWith(color: AppColors.darkText),
        side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
      ),
      dividerTheme:
          const DividerThemeData(color: AppColors.darkDivider, thickness: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle:
            AppTypography.bodyMD.copyWith(color: AppColors.darkText),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      fontFamily: GoogleFonts.nunito().fontFamily,
    );
  }

  static TextTheme _buildLightTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.leagueSpartan(),
      displayMedium: GoogleFonts.leagueSpartan(),
      displaySmall: GoogleFonts.leagueSpartan(),
      headlineLarge: GoogleFonts.leagueSpartan(),
      headlineMedium: GoogleFonts.leagueSpartan(),
      headlineSmall: GoogleFonts.leagueSpartan(),
      titleLarge: GoogleFonts.leagueSpartan(),
      titleMedium: GoogleFonts.spaceGrotesk(),
      titleSmall: GoogleFonts.spaceGrotesk(),
      bodyLarge: GoogleFonts.nunito(),
      bodyMedium: GoogleFonts.nunito(),
      bodySmall: GoogleFonts.nunito(),
      labelLarge: GoogleFonts.spaceGrotesk(),
      labelMedium: GoogleFonts.spaceGrotesk(),
      labelSmall: GoogleFonts.spaceGrotesk(),
    );
  }

  static TextTheme _buildDarkTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.leagueSpartan(),
      displayMedium: GoogleFonts.leagueSpartan(),
      displaySmall: GoogleFonts.leagueSpartan(),
      headlineLarge: GoogleFonts.leagueSpartan(),
      headlineMedium: GoogleFonts.leagueSpartan(),
      headlineSmall: GoogleFonts.leagueSpartan(),
      titleLarge: GoogleFonts.leagueSpartan(),
      titleMedium: GoogleFonts.spaceGrotesk(),
      titleSmall: GoogleFonts.spaceGrotesk(),
      bodyLarge: GoogleFonts.nunito(),
      bodyMedium: GoogleFonts.nunito(),
      bodySmall: GoogleFonts.nunito(),
      labelLarge: GoogleFonts.spaceGrotesk(),
      labelMedium: GoogleFonts.spaceGrotesk(),
      labelSmall: GoogleFonts.spaceGrotesk(),
    );
  }
}
