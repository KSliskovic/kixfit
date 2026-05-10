/// KixFit Spacing & Dimension Constants
abstract class AppSpacing {
  // === BASE SPACING ===
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // === PADDING ===
  static const double pagePadding = 20.0;
  static const double cardPadding = 16.0;
  static const double sectionGap = 28.0;

  // === BORDER RADIUS ===
  static const double radiusXs = 6.0;
  static const double radiusSm = 10.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 100.0;

  // === ICON SIZES ===
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // === TOUCH TARGETS ===
  static const double touchTarget = 48.0;
  static const double buttonHeight = 56.0;
  static const double buttonHeightSm = 44.0;

  // === APP BAR ===
  static const double appBarHeight = 60.0;
  static const double bottomNavHeight = 72.0;

  // === MACRO RING ===
  static const double macroRingSize = 160.0;
  static const double macroRingStrokeWidth = 14.0;
  static const double macroRingSmallSize = 80.0;
  static const double macroRingSmallStroke = 8.0;
}

/// KixFit Duration Constants
abstract class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration xSlow = Duration(milliseconds: 800);
  static const Duration page = Duration(milliseconds: 400);
}
