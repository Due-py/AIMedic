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

  @override
  String get todayTitle => 'Today';

  @override
  String get weeklyTitle => 'Last 7 days';

  @override
  String get waterLog => 'Water';

  @override
  String get addCupButton => '+250 ml';

  @override
  String get sleepLog => 'Sleep';

  @override
  String get exerciseLog => 'Exercise';

  @override
  String get screenTimeLog => 'Screen time';

  @override
  String get moodLog => 'Mood';

  @override
  String get stressLog => 'Stress';

  @override
  String get notLoggedYet => 'Not logged yet';

  @override
  String mlValue(int amount) {
    return '$amount ml';
  }

  @override
  String hoursValue(String amount) {
    return '$amount hours';
  }

  @override
  String minutesValue(int amount) {
    return '$amount min';
  }

  @override
  String stressLevelValue(int level) {
    return 'Level $level/5';
  }

  @override
  String get saveButton => 'Save';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get chartWater => 'Water (ml)';

  @override
  String get chartSleep => 'Sleep (hours)';

  @override
  String get chartTargetLine => 'Target';

  @override
  String get coachInputHint => 'Ask me about your health...';

  @override
  String get coachSendTooltip => 'Send';

  @override
  String get coachTyping => 'AIMedic is replying...';

  @override
  String get coachSendError => 'Could not send your message. Please try again.';

  @override
  String get coachWelcome =>
      'Hi! I\'m AIMedic — your health companion. Ask me about sleep, nutrition, exercise or feelings! 💚';

  @override
  String levelLabel(int level) {
    return 'Level $level';
  }

  @override
  String xpProgress(int current, int total) {
    return '$current/$total XP';
  }

  @override
  String streakDays(int days) {
    return '$days-day streak';
  }

  @override
  String get petTitle => 'Bo — your companion';

  @override
  String get petMoodHappy =>
      'Bo is thrilled that you\'re taking care of yourself! 🎉';

  @override
  String get petMoodOk => 'Bo is waiting for you to log a bit more today~';

  @override
  String get petMoodSleepy => 'Bo is sleepy... log one activity to wake Bo up!';

  @override
  String petCoins(int n) {
    return '$n coins';
  }

  @override
  String get petShopTitle => 'Accessory shop';

  @override
  String get petShopHint => 'Earn coins by logging your day';

  @override
  String petBuy(int n) {
    return 'Buy · $n';
  }

  @override
  String get petWearing => 'Wearing';

  @override
  String get petOwned => 'Owned';

  @override
  String get petNotEnoughCoins => 'Not enough coins — log more to earn some!';

  @override
  String get petShopButton => 'Shop';

  @override
  String get breathingTitle => 'Calm corner';

  @override
  String get breathingSubtitle =>
      'Deep breathing helps you feel calm and focused';

  @override
  String get breathingInhale => 'Breathe in...';

  @override
  String get breathingHold => 'Hold...';

  @override
  String get breathingExhale => 'Breathe out...';

  @override
  String get breathingStart => 'Start';

  @override
  String get breathingStop => 'Stop';

  @override
  String get breathingDone => 'Great job! How do you feel?';

  @override
  String breathingMinutes(int n) {
    return '$n min';
  }

  @override
  String get breathingOpenButton => 'Let\'s relax';

  @override
  String get introSlide1Title => 'Hi, I\'m AIMedic! 👋';

  @override
  String get introSlide1Body =>
      'Your companion for building healthy habits every day — made especially for students.';

  @override
  String get introSlide2Title => 'Log & level up 📊';

  @override
  String get introSlide2Body =>
      'Track water, sleep, exercise and mood with one tap. Earn XP, badges and keep your streak going!';

  @override
  String get introSlide3Title => 'An AI coach by your side 🤖';

  @override
  String get introSlide3Body =>
      'Ask anything about health — the AI knows your habits and answers in a friendly, simple way. No diagnosis, no judgment.';

  @override
  String get introSkip => 'Skip';

  @override
  String get introNext => 'Next';

  @override
  String get introStart => 'Let\'s go!';

  @override
  String get authLoginTitle => 'Sign in';

  @override
  String get authRegisterTitle => 'Create account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get authLoginButton => 'Sign in';

  @override
  String get authRegisterButton => 'Sign up';

  @override
  String get authSwitchToRegister => 'No account yet? Sign up';

  @override
  String get authSwitchToLogin => 'Already have an account? Sign in';

  @override
  String get authErrorInvalidCredentials => 'Incorrect email or password.';

  @override
  String get authErrorEmailInUse => 'This email is already registered.';

  @override
  String get authErrorWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get authErrorInvalidEmail => 'That email doesn\'t look right.';

  @override
  String get authErrorGeneric => 'Something went wrong. Please try again.';

  @override
  String get passwordMismatch => 'Passwords don\'t match.';

  @override
  String get logoutTooltip => 'Sign out';

  @override
  String get insightsTitle => 'This week\'s insights';

  @override
  String insightSleepDebt(String value) {
    return 'You slept about $value hours a night — a bit short. Try going to bed 30 minutes earlier!';
  }

  @override
  String insightSleepGood(String value) {
    return 'Your sleep is on track ($value hours a night). Great job!';
  }

  @override
  String insightLowWater(String value) {
    return 'You drank about $value ml a day, below your goal. Keep a bottle nearby!';
  }

  @override
  String insightWaterGood(String value) {
    return 'You\'re hitting your water goal ($value ml a day). Keep it up!';
  }

  @override
  String insightHighScreenTime(String value) {
    return 'You averaged $value minutes of screen time a day. Try more breaks and movement!';
  }

  @override
  String get insightHighStress =>
      'You seemed stressed this week. Try deep breathing and talking to someone you trust.';

  @override
  String get insightLowExercise =>
      'Not much exercise this week. A 30-minute walk or game each day helps a lot!';

  @override
  String get badgeFirstLog => 'First step';

  @override
  String get badgeStreak3 => '3-day streak';

  @override
  String get badgeStreak7 => '7-day streak';

  @override
  String get badgeWater10l => '10 liters of water';

  @override
  String get badgeMood5Days => 'Mood aware';

  @override
  String get badgeActive5Days => 'Active';
}
