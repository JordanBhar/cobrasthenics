import 'package:flutter/material.dart';

// ─── Cobrasthenics Design Tokens ──────────────────────────────────────────────
// Single source of truth for all colours, text styles, radii, and spacing.
// Reference these constants from every widget — never use raw hex strings.

abstract class AppColors {
  // Surfaces
  static const Color background = Color(0xFF080808);
  static const Color card = Color(0xFF111111);
  static const Color elevated = Color(0xFF1A1A1A);
  static const Color elevated2 = Color(0xFF222222);
  static const Color border = Color(0xFF242424);
  static const Color border2 = Color(0xFF2E2E2E);

  // Brand
  static const Color brand = Color(0xFF0A84FF);
  static const Color brandDim = Color(0x240A84FF); // 14%

  // Status / semantic
  static const Color green = Color(0xFF30D158);
  static const Color greenDim = Color(0x1F30D158); // 12%
  static const Color red = Color(0xFFFF453A);
  static const Color redDim = Color(0x1FFF453A);
  static const Color gold = Color(0xFFFFB800);
  static const Color goldDim = Color(0x1FFFB800);
  static const Color orange = Color(0xFFFF9F0A);
  static const Color orangeDim = Color(0x1FFF9F0A);
  static const Color purple = Color(0xFFBF5AF2);
  static const Color purpleDim = Color(0x1FBF5AF2);
  static const Color teal = Color(0xFF4DD0E1);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A8A8E);
  static const Color textHint = Color(0xFF48484A);

  // Difficulty mapping
  static Color difficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return green;
      case 'intermediate':
        return orange;
      case 'advanced':
        return red;
      case 'elite':
        return purple;
      default:
        return textSecondary;
    }
  }
}

abstract class AppRadii {
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 28;

  static BorderRadius get xsBr => BorderRadius.circular(xs);
  static BorderRadius get smBr => BorderRadius.circular(sm);
  static BorderRadius get mdBr => BorderRadius.circular(md);
  static BorderRadius get lgBr => BorderRadius.circular(lg);
  static BorderRadius get xlBr => BorderRadius.circular(xl);
  static BorderRadius get xxlBr => BorderRadius.circular(xxl);
}

abstract class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double h1 = 40;
  static const double h2 = 48;
  static const double h3 = 64;
}

abstract class AppTextStyles {
  static const String _fontFamily = 'SF Pro Display';
  static const String _monoFamily = 'DM Mono';

  static const TextStyle display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 38,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1.9,
  );
  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -1.4,
  );
  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.8,
  );
  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.4,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.65,
  );
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.06,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textHint,
    letterSpacing: 0.08,
  );
  static const TextStyle mono = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static const TextStyle monoLarge = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: -0.6,
  );
  static const TextStyle pill = TextStyle(
    fontFamily: _monoFamily,
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.08,
  );
}

// ─── ThemeData ────────────────────────────────────────────────────────────────
class AppTheme {
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brand,
        secondary: AppColors.green,
        error: AppColors.red,
        surface: AppColors.card,
      ),
      fontFamily: 'SF Pro Display',
      dividerColor: AppColors.border,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        titleTextStyle: AppTextStyles.h3,
      ),
    );
  }
}
