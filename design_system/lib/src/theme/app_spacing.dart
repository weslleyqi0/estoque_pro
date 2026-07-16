import 'package:flutter/material.dart';

/// Design system spacing and sizing tokens
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (4px)
  static const double _base = 4.0;

  /// Spacing scale with 4px increments
  static const double space4 = _base;
  static const double space8 = _base * 2;
  static const double space12 = _base * 3;
  static const double space16 = _base * 4;
  static const double space20 = _base * 5;
  static const double space24 = _base * 6;
  static const double space32 = _base * 8;
  static const double space40 = _base * 10;
  static const double space48 = _base * 12;
  static const double space56 = _base * 14;

  /// Radius scale
  static const double radius2 = 2.0;
  static const double radius4 = 4.0;
  static const double radius8 = 8.0;
  static const double radius12 = 12.0;
  static const double radius16 = 16.0;
  static const double radius24 = 24.0;
  static const double radiusFull = 9999.0;

  /// Border Radius Objects
  static const BorderRadius borderRadius2 = BorderRadius.all(
    Radius.circular(radius2),
  );
  static const BorderRadius borderRadius4 = BorderRadius.all(
    Radius.circular(radius4),
  );
  static const BorderRadius borderRadius8 = BorderRadius.all(
    Radius.circular(radius8),
  );
  static const BorderRadius borderRadius12 = BorderRadius.all(
    Radius.circular(radius12),
  );
  static const BorderRadius borderRadius16 = BorderRadius.all(
    Radius.circular(radius16),
  );
  static const BorderRadius borderRadius24 = BorderRadius.all(
    Radius.circular(radius24),
  );
  static const BorderRadius borderRadiusFull = BorderRadius.all(
    Radius.circular(radiusFull),
  );

  /// Icon Sizes
  static const double icon16 = 16.0;
  static const double icon20 = 20.0;
  static const double icon24 = 24.0;
  static const double icon32 = 32.0;
  static const double icon40 = 40.0;
  static const double icon48 = 48.0;

  // Common Dimensions
  static const double buttonHeightLg = 60.0;

  static const double inputHeightLg = 56.0;

  static const double appBarHeight = 56.0;
  static const double bottomNavHeight = 56.0;

  static const double cardElevation = 2.0;
  static const double darkCardElevation = 8.0;
  static const double dialogElevation = 24.0;

  // Shadows
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowXl = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
}
