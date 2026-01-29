
import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // no instance

  /* ===========================
   * Brand Colors
   * =========================== */

  static const Color primary = Color(0xFFD4AF37); // Gold
  static const Color secondary = Color(0xFF7A1E2D); // Wine

  /* ===========================
   * Primary Variants
   * =========================== */

  static const Color primaryLight = Color(0xFFE8CC73);
  static const Color primaryDark = Color(0xFFB8962E);

  static const Color onPrimary = Color(0xFFFFFFFF); // text/icons on gold
  static const Color onSecondary = Color(0xFFFFFFFF);

  /* ===========================
   * Background & Surface
   * =========================== */

  static const Color background = Color(0xFFFFFDF8); // Ivory
  static const Color surface = Color(0xFFFFFFFF); // Cards
  static const Color scaffold = Color(0xFFFFFDF8);

  /* ===========================
   * Text Colors
   * =========================== */

  static const Color textPrimary = Color(0xFF2B2B2B);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textDisabled = Color(0xFF9E9E9E);
  static const Color textHint = Color(0xFF9E9E9E);

  /* ===========================
   * Border & Divider
   * =========================== */

  static const Color divider = Color(0xFFEEE8D8);
  static const Color border = Color(0xFFE0E0E0);

  /* ===========================
   * State Colors
   * =========================== */

  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF9A825);
  static const Color info = Color(0xFF1565C0);

  /* ===========================
   * Buttons
   * =========================== */

  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFFBDBDBD);

  /* ===========================
   * Icons
   * =========================== */

  static const Color iconPrimary = primary;
  static const Color iconSecondary = secondary;
  static const Color iconDisabled = Color(0xFF9E9E9E);

  /* ===========================
   * Overlays & Misc
   * =========================== */

  static const Color overlay = Color(0x66000000);
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}
