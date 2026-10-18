import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Absa Bank Official Brand Palette
  static const Color absaRed = Color(0xFFDC0032); // Signature Absa Passionate Red
  static const Color absaBurgundy = Color(0xFF6E001B); // Deep Rich Wine / Burgundy
  static const Color absaCrimson = Color(0xFF9E0024); // Rich Imperial Crimson
  static const Color absaCoral = Color(0xFFFF385C); // Sunset Coral / Accent Glow
  static const Color absaGold = Color(0xFFFFB81C); // Absa Premier / Private Banking Gold

  // Dark Obsidian & Velvet Charcoal with subtle warm wine undertones
  static const Color backgroundDark = Color(0xFF0C090D); // Deep pitch black
  static const Color surfaceDark = Color(0xFF161017); // Dark velvet charcoal
  static const Color surfaceBorder = Color(0xFF2E1C28); // Subtle burgundy/plum border
  static const Color cardElevated = Color(0xFF221623); // Elevated container

  // Light Mode Palette
  static const Color backgroundLight = Color(0xFFF7F5F8); // Clean off-white pearl
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white card surface
  static const Color surfaceBorderLight = Color(0xFFE9E0E6); // Delicate soft border
  static const Color cardElevatedLight = Color(0xFFFDFBFD);

  // Typography Palette - Dark
  static const Color textLight = Color(0xFFFBF8FA);
  static const Color textMuted = Color(0xFFA694A0);
  static const Color textSubtle = Color(0xFF756370);

  // Typography Palette - Light
  static const Color textDark = Color(0xFF1B1117);
  static const Color textDarkMuted = Color(0xFF6C5A66);
  static const Color textDarkSubtle = Color(0xFF94838F);

  // Risk Palette (Fintech Protection)
  static const Color riskHigh = Color(0xFFFF1744); // Urgent Neon Crimson
  static const Color riskSuspicious = Color(0xFFFF9100); // Vivid Amber
  static const Color riskLow = Color(0xFF00C853); // Safe Emerald

  // Dynamic Theme Helpers
  static Color backgroundColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? backgroundDark : backgroundLight;

  static Color surfaceColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceDark : surfaceLight;

  static Color borderColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? surfaceBorder : surfaceBorderLight;

  static Color textColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textLight : textDark;

  static Color textMutedColor(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? textMuted : textDarkMuted;

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: absaRed,
        secondary: absaCoral,
        surface: surfaceDark,
        surfaceContainerHighest: cardElevated,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textLight,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textLight,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: textLight,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13.5,
          color: textMuted,
          height: 1.45,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textLight,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textLight),
      ),
      cardTheme: CardThemeData(
        color: surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: absaRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: absaRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.light().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: absaRed,
        secondary: absaCoral,
        surface: surfaceLight,
        surfaceContainerHighest: cardElevatedLight,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.outfit(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: textDark,
        ),
        headlineSmall: GoogleFonts.outfit(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        titleLarge: GoogleFonts.outfit(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 15,
          color: textDark,
          height: 1.5,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13.5,
          color: textDarkMuted,
          height: 1.45,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: textDark,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: textDark),
      ),
      cardTheme: CardThemeData(
        color: surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: surfaceBorderLight, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: absaRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: surfaceBorderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: surfaceBorderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: absaRed, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
