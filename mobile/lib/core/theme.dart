import 'package:flutter/material.dart';

/// Bright, friendly, calm — see CLAUDE.md "UI Philosophy".
class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFF2AA5A0); // calm teal

  static ThemeData light() => _base(Brightness.light);
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.comfortable,
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          // Large touch targets for young students.
          minimumSize: const Size(64, 48),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(height: 72),
    );
  }
}
