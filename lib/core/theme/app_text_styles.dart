import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Playfair-style headings + Lato body.
class AppTextStyles {
  AppTextStyles._();

  static TextStyle get headingXL => GoogleFonts.playfairDisplay(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.15,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get headingL => GoogleFonts.playfairDisplay(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingM => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingS => GoogleFonts.playfairDisplay(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyL => GoogleFonts.lato(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyM => GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyS => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelL => GoogleFonts.lato(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelM => GoogleFonts.lato(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelS => GoogleFonts.lato(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: AppColors.textSecondary,
      );

  static TextStyle get buttonPrimary => GoogleFonts.lato(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: AppColors.onPrimary,
      );

  static TextStyle get buttonSecondary => GoogleFonts.lato(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.secondary,
      );

  static TextStyle get price => GoogleFonts.playfairDisplay(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
      );

  static TextStyle get link => GoogleFonts.lato(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.secondary,
        decoration: TextDecoration.underline,
      );

  static TextStyle get caption => GoogleFonts.lato(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  static TextStyle get error => GoogleFonts.lato(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
      );

  /// Logo / display serif (italic where used via copyWith).
  static TextStyle get displaySerif => GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary,
      );
}
