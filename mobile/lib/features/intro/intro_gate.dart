import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the one-time welcome intro has been seen.
///
/// Defaults to true (skip intro) so widget tests and code paths that never
/// ran main() are unaffected; main() loads the real value from preferences
/// before the first frame.
class IntroGate {
  IntroGate._();

  static const _prefsKey = 'intro_seen';

  static bool seen = true;

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      seen = prefs.getBool(_prefsKey) ?? false;
    } catch (e) {
      debugPrint('Intro flag load failed: $e');
      seen = false; // no stored state → show the intro
    }
  }

  static Future<void> complete() async {
    seen = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefsKey, true);
    } catch (e) {
      debugPrint('Intro flag save failed: $e');
    }
  }
}
