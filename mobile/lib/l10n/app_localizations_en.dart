// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AIMedic';

  @override
  String get homeTitle => 'Home';

  @override
  String homeGreeting(String name) {
    return 'Hi $name! How are you today?';
  }

  @override
  String get coachTitle => 'AI Coach';

  @override
  String get trackingTitle => 'Journal';

  @override
  String get profileTitle => 'Profile';

  @override
  String get waterTarget => 'Water goal';

  @override
  String get sleepTarget => 'Sleep goal';

  @override
  String get calorieTarget => 'Daily energy';

  @override
  String get comingSoon => 'This feature is under development';

  @override
  String get medicalDisclaimer =>
      'AIMedic supports healthy habits and does not replace doctors or medical staff.';
}
