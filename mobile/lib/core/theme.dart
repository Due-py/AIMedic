import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Soft & playful design system — bright, friendly, calm (CLAUDE.md UI).
/// Rounded Nunito type, generous 28px cards, pastel gradient accents.
class AppTheme {
  AppTheme._();

  // Brand + accent palette. Teal stays the primary brand colour; the
  // warm/cool accents drive the playful stat cards and gradients.
  static const teal = Color(0xFF17A2A0);
  static const coral = Color(0xFFFF8A65);
  static const mint = Color(0xFF34C79B);
  static const lavender = Color(0xFF9B8CFF);
  static const sunny = Color(0xFFFFC64D);
  static const sky = Color(0xFF4FB6F5);
  static const berry = Color(0xFFF06595);

  static const _ink = Color(0xFF243434);
  static const _scaffoldLight = Color(0xFFF6FBFA);
  static const _scaffoldDark = Color(0xFF10201F);

  /// Soft page-background gradient used behind headers.
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1FB6A6), Color(0xFF2AA5A0), Color(0xFF3FA7C4)],
  );

  static const cardRadius = 26.0;

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final scheme = ColorScheme.fromSeed(
      seedColor: teal,
      brightness: brightness,
    ).copyWith(
      surface: isLight ? Colors.white : const Color(0xFF172928),
      onSurface: isLight ? _ink : const Color(0xFFE6F0EF),
    );

    final baseText = GoogleFonts.nunitoTextTheme(
      ThemeData(brightness: brightness).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isLight ? _scaffoldLight : _scaffoldDark,
      textTheme: baseText.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: scheme.onSurface,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          textStyle: GoogleFonts.nunito(
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isLight ? const Color(0xFFF0F6F5) : const Color(0xFF1E302F),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.nunito(fontWeight: FontWeight.w700),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        side: BorderSide.none,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 74,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.16),
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(
          GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      visualDensity: VisualDensity.comfortable,
    );
  }
}
