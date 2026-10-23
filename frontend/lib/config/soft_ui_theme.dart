import 'package:flutter/material.dart';

/// Soft UI / Neumorphism Design System Constants & Theme
/// Based on the reference UI:
/// - Background: Light gray/off-white (#F2F5F8)
/// - Cards: Crisp white (#FFFFFF) with BorderRadius.circular(20)
/// - Primary Accent: Mint/Teal (#00D19E)
/// - Typography: Dark bold headers (#1E293B) with clean light-gray subtext (#8E9CAE)
/// - Shadows: Soft dual shadows for a floating depth effect
class SoftUiTheme {
  // Brand & Palette Colors
  static const Color background = Color(0xFFF2F5F8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFE9EEF4);
  static const Color primaryMint = Color(0xFF00D19E);
  static const Color mintDark = Color(0xFF00B589);
  static const Color mintLight = Color(0xFFE6FAF5);
  static const Color mintGlow = Color(0x4D00D19E);

  // Status & Secondary Colors
  static const Color blueAccent = Color(0xFF3B82F6);
  static const Color blueLight = Color(0xFFEFF6FF);
  static const Color amberWarning = Color(0xFFF59E0B);
  static const Color amberLight = Color(0xFFFEF3C7);
  static const Color redDanger = Color(0xFFEF4444);
  static const Color redLight = Color(0xFFFEE2E2);

  // Typography Colors
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF8E9CAE);
  static const Color textMuted = Color(0xFFB0BDCC);
  static const Color dividerColor = Color(0xFFE2E8F0);

  // Rounded Corner Radius
  static const double cardRadiusVal = 20.0;
  static final BorderRadius cardRadius = BorderRadius.circular(cardRadiusVal);
  static final BorderRadius pillRadius = BorderRadius.circular(30.0);
  static final BorderRadius buttonRadius = BorderRadius.circular(16.0);

  // Dual Shadows for Floating Depth Effect
  static final List<BoxShadow> cardShadow = [
    const BoxShadow(
      color: Color(0x0F1B2B40),
      blurRadius: 18,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0xFFFFFFFF),
      blurRadius: 8,
      offset: Offset(0, -2),
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> floatingHeroShadow = [
    const BoxShadow(
      color: Color(0x1712263F),
      blurRadius: 26,
      offset: Offset(0, 12),
      spreadRadius: 0,
    ),
    const BoxShadow(
      color: Color(0xFFFFFFFF),
      blurRadius: 10,
      offset: Offset(-2, -2),
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> buttonShadow = [
    const BoxShadow(
      color: Color(0x4000D19E),
      blurRadius: 16,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];

  static final List<BoxShadow> subtlePillShadow = [
    const BoxShadow(
      color: Color(0x0A0F172A),
      blurRadius: 8,
      offset: Offset(0, 3),
      spreadRadius: 0,
    ),
  ];

  // Card Decoration Helper
  static BoxDecoration cardDecoration({
    Color? color,
    BorderRadius? borderRadius,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: color ?? cardBg,
      borderRadius: borderRadius ?? cardRadius,
      border: border,
      boxShadow: shadows ?? cardShadow,
    );
  }

  // Soft Recessed Container Decoration (for inputs, inactive pills, chips)
  static BoxDecoration recessedDecoration({
    BorderRadius? borderRadius,
    Color? color,
  }) {
    return BoxDecoration(
      color: color ?? const Color(0xFFEAEFF5),
      borderRadius: borderRadius ?? BorderRadius.circular(14),
    );
  }

  // Complete Flutter ThemeData
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      primaryColor: primaryMint,
      canvasColor: background,
      colorScheme: const ColorScheme.light(
        primary: primaryMint,
        onPrimary: Colors.white,
        secondary: mintDark,
        onSecondary: Colors.white,
        surface: cardBg,
        onSurface: textPrimary,
        error: redDanger,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      dividerColor: dividerColor,
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: cardRadius,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w900,
          letterSpacing: -1,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 15,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 13,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          backgroundColor: cardBg,
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 13),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryMint, width: 2),
        ),
      ),
    );
  }
}
