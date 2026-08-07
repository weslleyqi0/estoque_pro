import 'package:flutter/material.dart';

/// Design system color palette
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF1351D6);
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF0B3693);

  static const Color secondary = Color(0xFF96B7FF);
  static const Color secondaryLight = Color(0xFFADC7FF);
  static const Color secondaryDark = Color(0xFF7DA6FF);

  static const Color accent = Color(0xFFFF6B9D);
  static const Color accentLight = Color(0xFFFF9BBD);
  static const Color accentDark = Color(0xFFCC4570);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Neutral Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF7F7F7);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F5F5);

  static const Color textPrimaryLight = Color(0xFF1F2937);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textDisabledLight = Color(0xFF9CA3AF);

  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color dividerLight = Color(0xFFF3F4F6);

  // Neutral Colors - Dark Mode
  static const Color backgroundDark = Color(0xFF111827);
  static const Color surfaceDark = Color(0xFF1F2937);
  static const Color surfaceVariantDark = Color(0xFF374151);

  static const Color textPrimaryDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFFD1D5DB);
  static const Color textDisabledDark = Color(0xFF9CA3AF);

  static const Color borderDark = Color(0xFF4B5563);
  static const Color dividerDark = Color(0xFF374151);

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);

  // Transparent
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
}
