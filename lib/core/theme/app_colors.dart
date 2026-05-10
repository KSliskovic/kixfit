import 'package:flutter/material.dart';

/// KixFit Color Palette
/// Dark mode first, premium fitness aesthetic
abstract class AppColors {
  // === BACKGROUNDS ===
  static const Color backgroundDeep = Color(0xFF0A0A0F);
  static const Color backgroundSurface = Color(0xFF12121A);
  static const Color backgroundElevated = Color(0xFF1A1A26);
  static const Color backgroundCard = Color(0xFF1E1E2E);

  // === BRAND ACCENTS ===
  static const Color primary = Color(0xFF7C6FFF);
  static const Color primaryLight = Color(0xFF9D93FF);
  static const Color primaryDark = Color(0xFF5A4FCC);

  static const Color secondary = Color(0xFF4ECDC4);
  static const Color secondaryLight = Color(0xFF72E0D9);
  static const Color secondaryDark = Color(0xFF2EA89F);

  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF9191);
  static const Color accentDark = Color(0xFFCC4848);

  // === TEXT ===
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA0A0B0);
  static const Color textMuted = Color(0xFF606070);
  static const Color textDisabled = Color(0xFF404050);

  // === STATUS ===
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF2196F3);

  // === MACRO COLORS ===
  static const Color macroProtein = Color(0xFF7C6FFF);   // violet
  static const Color macroCarbs = Color(0xFF4ECDC4);     // teal
  static const Color macroFat = Color(0xFFFF6B6B);       // coral
  static const Color macroCalories = Color(0xFFFFD93D);  // amber

  // === GLASS / OVERLAYS ===
  static const Color glassFill = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x26FFFFFF);
  static const Color glassStroke = Color(0x0DFFFFFF);
  static const Color overlay = Color(0x80000000);

  // === GRADIENTS ===
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C6FFF), Color(0xFF4ECDC4)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A0A0F), Color(0xFF12121A)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E1E2E), Color(0xFF15152A)],
  );

  static const LinearGradient proteinGradient = LinearGradient(
    colors: [Color(0xFF7C6FFF), Color(0xFF9D93FF)],
  );

  static const LinearGradient carbsGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF72E0D9)],
  );

  static const LinearGradient fatGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF9191)],
  );
}
