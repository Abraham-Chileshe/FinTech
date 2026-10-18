import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Sber-inspired Fintech Vibrant Green Palette
  static const Color primaryGreen = Color(0xFF22C55E); // Signature High-Contrast Sber Green (#22C55E)
  static const Color sberGreen = Color(0xFF21A038); // Official Sber Forest Green
  static const Color sberDarkGreen = Color(0xFF15803D); // Deep Accent Green
  static const Color mintAccent = Color(0xFF34D399); // Electric Mint Accent
  static const Color accentOrange = Color(0xFFFF6D00); // Sber Notification & Badge Orange (#FF6D00)
  static const Color accentGold = Color(0xFFFFB81C); // Premier Gold Accent
  static const Color accentBlue = Color(0xFF1E88E5); // Accent Blue

  // Brand aliases for backward compatibility across existing widgets
  static const Color absaRed = primaryGreen; 
  static const Color absaBurgundy = Color(0xFF042C4E);
  static const Color absaCrimson = sberDarkGreen;
  static const Color absaCoral = primaryGreen;
  static const Color absaGold = accentGold;

  // Header Ocean / Midnight Blue Palette (matching top section of Sber reference)
  static const Color headerBlueDark = Color(0xFF042C4E); // Deep Sber Midnight Navy
  static const Color headerBlueMid = Color(0xFF073C68); // Rich Ocean Navy
  static const Color headerBlueDeep = Color(0xFF062C4C);
  static const Color headerBlueEnd = Color(0xFF091F33); // Smooth transition to dark
  static const Color headerCardBg = Color(0xFF0C3860); // Translucent top navy card
  static const Color headerCardBorder = Color(0xFF185286); // Top navy card border
  static const Color headerSearchBg = Color(0xFF062B4A); // Search pill container
  static const Color headerSearchBorder = Color(0xFF164B78); // Search pill border
  static const Color headerTextMuted = Color(0xFF7E9DB8); // "В кошельке" style text

  // Dark Neutral Obsidian & Charcoal (matching lower section of Sber reference)
  static const Color backgroundDark = Color(0xFF0C0F12); // True Obsidian Jet Black scaffold
  static const Color surfaceDark = Color(0xFF181B1F); // Dark Graphite Card Surface (#181B1F)
  static const Color surfaceBorder = Color(0xFF25292E); // Subtle Dark Slate Border
  static const Color cardElevated = Color(0xFF1E2227); // Elevated Container
  static const Color avatarDark = Color(0xFF262A2E); // Contact Avatar Circle (#262A2E)

  // Light Mode Palette (Clean Cool Bank Gray)
  static const Color backgroundLight = Color(0xFFF3F5F8); // Clean cool bank gray
  static const Color surfaceLight = Color(0xFFFFFFFF); // Pure white card surface
  static const Color surfaceBorderLight = Color(0xFFE2E8F0); // Soft cool border
  static const Color cardElevatedLight = Color(0xFFF8FAFC);
  static const Color avatarLight = Color(0xFFE8EEF3);

  // Typography Palette - Dark
  static const Color textLight = Color(0xFFFFFFFF); // Crisp white
  static const Color textMuted = Color(0xFF8E9AA7); // Cool slate muted text
  static const Color textSubtle = Color(0xFF5E6E7E); // Deep slate subtle

  // Typography Palette - Light
  static const Color textDark = Color(0xFF0F172A); // Deep slate dark text
  static const Color textDarkMuted = Color(0xFF64748B); // Muted slate text
  static const Color textDarkSubtle = Color(0xFF94A3B8); // Soft slate text

  // Risk Palette (Fintech Protection)
  static const Color riskHigh = Color(0xFFFF3B30); // Urgent Crimson for fraud alerts
  static const Color riskSuspicious = Color(0xFFFF6D00); // Vivid Sber Orange for warnings & notifications
  static const Color riskLow = Color(0xFF22C55E); // Safe Emerald Green

  // Header Helpers
  static List<Color> headerGradientColors(bool isDark) => isDark
      ? const [
          Color(0xFF042C4E), // Deep Sber Midnight Navy
          Color(0xFF073C68), // Rich Ocean Navy
          Color(0xFF062C4C),
          Color(0xFF091F33),
        ]
      : const [
          Color(0xFF0B4F82), // Crisp Atlantic Ocean Blue for light mode
          Color(0xFF093E68),
          Color(0xFF072E4D),
          Color(0xFF06233B),
        ];

  static Color headerNavColor(bool isDark) =>
      isDark ? const Color(0xFF042C4E) : const Color(0xFF0B4F82);

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
        primary: primaryGreen,
        secondary: mintAccent,
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
        backgroundColor: headerBlueDark,
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
          backgroundColor: primaryGreen,
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
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
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
        primary: primaryGreen,
        secondary: mintAccent,
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
        backgroundColor: const Color(0xFF0B4F82),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 19,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
          backgroundColor: primaryGreen,
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
          borderSide: const BorderSide(color: primaryGreen, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
