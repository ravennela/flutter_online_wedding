import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._(); // no instance

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    /* ===========================
     * Color Scheme
     * =========================== */
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      error: AppColors.error,
      onError: Colors.white,
      background: AppColors.background,
      onBackground: AppColors.textPrimary,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
    ),

    /* ===========================
     * Scaffold & Background
     * =========================== */
    scaffoldBackgroundColor: AppColors.scaffold,

    /* ===========================
     * AppBar Theme
     * =========================== */
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.surface,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
      ),
      titleTextStyle: AppTextStyles.headingM,
      surfaceTintColor: Colors.transparent,
    ),

    /* ===========================
     * Text Theme
     * =========================== */
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.headingXL,
      displayMedium: AppTextStyles.headingL,
      displaySmall: AppTextStyles.headingM,
      titleLarge: AppTextStyles.headingL,
      titleMedium: AppTextStyles.headingM,
      titleSmall: AppTextStyles.headingS,
      bodyLarge: AppTextStyles.bodyL,
      bodyMedium: AppTextStyles.bodyM,
      bodySmall: AppTextStyles.bodyS,
      labelLarge: AppTextStyles.labelL,
      labelMedium: AppTextStyles.labelM,
      labelSmall: AppTextStyles.labelS,
    ),

    /* ===========================
     * Button Themes
     * =========================== */

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.onPrimary,
        textStyle: AppTextStyles.buttonPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 48),
        elevation: 0,
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.secondary,
        textStyle: AppTextStyles.buttonSecondary,
        side: const BorderSide(color: AppColors.secondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.secondary,
        textStyle: AppTextStyles.link,
      ),
    ),

    /* ===========================
     * Input Fields
     * =========================== */

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      hintStyle: AppTextStyles.bodyS,
      labelStyle: AppTextStyles.labelM,
      errorStyle: AppTextStyles.error,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
    ),

    /* ===========================
     * Divider Theme
     * =========================== */

    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),

    /* ===========================
     * Icon Theme
     * =========================== */

    iconTheme: const IconThemeData(
      color: AppColors.iconSecondary,
      size: 22,
    ),

    /* ===========================
     * Bottom Sheet
     * =========================== */

    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    ),
  );
}
