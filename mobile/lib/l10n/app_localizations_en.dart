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

  @override
  String get onboardingTitle => 'Create your health profile';

  @override
  String stepOf(int current, int total) {
    return 'Step $current/$total';
  }

  @override
  String get stepBasicsTitle => 'Who are you?';

  @override
  String get ageLabel => 'Age';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get stepBodyTitle => 'Height and weight';

  @override
  String get heightLabel => 'Height (cm)';

  @override
  String get weightLabel => 'Weight (kg)';

  @override
  String get stepActivityTitle => 'How active are you?';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activitySedentaryDesc => 'Little or no exercise';

  @override
  String get activityLight => 'Light';

  @override
  String get activityLightDesc => 'Active 1-3 days a week';

  @override
  String get activityModerate => 'Moderate';

  @override
  String get activityModerateDesc => 'Active 3-5 days a week';

  @override
  String get activityActive => 'Active';

  @override
  String get activityActiveDesc => 'Active 6-7 days a week';

  @override
  String get activityVeryActive => 'Very active';

  @override
  String get activityVeryActiveDesc => 'Sports every day';

  @override
  String get stepSleepTitle => 'Your sleep schedule';

  @override
  String get sleepTimeLabel => 'Bedtime';

  @override
  String get wakeTimeLabel => 'Wake-up time';

  @override
  String get nextButton => 'Next';

  @override
  String get backButton => 'Back';

  @override
  String get finishButton => 'Finish';

  @override
  String get fieldRequired => 'Please fill in this field';

  @override
  String get fieldInvalid => 'This value is not valid';

  @override
  String get profileSaveError =>
      'Could not save your profile. Please try again.';

  @override
  String get retryButton => 'Retry';

  @override
  String get createProfilePrompt =>
      'Create your health profile to get goals made just for you!';

  @override
  String get createProfileButton => 'Create profile';

  @override
  String get editProfileButton => 'Edit profile';

  @override
  String get bmiLabel => 'BMI';

  @override
  String get bmiHealthy => 'Healthy';

  @override
  String get bmiUnderweight => 'A bit underweight';

  @override
  String get bmiOverweight => 'A bit overweight';

  @override
  String get bmiObese => 'Overweight';

  @override
  String waterValue(int amount) {
    return '$amount ml per day';
  }

  @override
  String sleepValue(int min, int max) {
    return '$min-$max hours per night';
  }

  @override
  String calorieValue(int amount) {
    return 'About $amount kcal';
  }

  @override
  String get loadError =>
      'Could not load your data. Check your connection and try again.';
}
