import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In vi, this message translates to:
  /// **'AIMedic'**
  String get appTitle;

  /// No description provided for @homeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get homeTitle;

  /// No description provided for @homeGreeting.
  ///
  /// In vi, this message translates to:
  /// **'Chào {name}! Hôm nay bạn thế nào?'**
  String homeGreeting(String name);

  /// No description provided for @coachTitle.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý AI'**
  String get coachTitle;

  /// No description provided for @trackingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhật ký'**
  String get trackingTitle;

  /// No description provided for @profileTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profileTitle;

  /// No description provided for @waterTarget.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu nước uống'**
  String get waterTarget;

  /// No description provided for @sleepTarget.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu giấc ngủ'**
  String get sleepTarget;

  /// No description provided for @calorieTarget.
  ///
  /// In vi, this message translates to:
  /// **'Năng lượng mỗi ngày'**
  String get calorieTarget;

  /// No description provided for @comingSoon.
  ///
  /// In vi, this message translates to:
  /// **'Tính năng đang được phát triển'**
  String get comingSoon;

  /// No description provided for @medicalDisclaimer.
  ///
  /// In vi, this message translates to:
  /// **'AIMedic là công cụ hỗ trợ thói quen lành mạnh, không thay thế bác sĩ hoặc nhân viên y tế.'**
  String get medicalDisclaimer;

  /// No description provided for @onboardingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo hồ sơ sức khỏe'**
  String get onboardingTitle;

  /// No description provided for @stepOf.
  ///
  /// In vi, this message translates to:
  /// **'Bước {current}/{total}'**
  String stepOf(int current, int total);

  /// No description provided for @stepBasicsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn là ai?'**
  String get stepBasicsTitle;

  /// No description provided for @ageLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tuổi'**
  String get ageLabel;

  /// No description provided for @genderLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giới tính'**
  String get genderLabel;

  /// No description provided for @genderMale.
  ///
  /// In vi, this message translates to:
  /// **'Nam'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In vi, this message translates to:
  /// **'Nữ'**
  String get genderFemale;

  /// No description provided for @stepBodyTitle.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao và cân nặng'**
  String get stepBodyTitle;

  /// No description provided for @heightLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chiều cao (cm)'**
  String get heightLabel;

  /// No description provided for @weightLabel.
  ///
  /// In vi, this message translates to:
  /// **'Cân nặng (kg)'**
  String get weightLabel;

  /// No description provided for @stepActivityTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bạn vận động thế nào?'**
  String get stepActivityTitle;

  /// No description provided for @activitySedentary.
  ///
  /// In vi, this message translates to:
  /// **'Ít vận động'**
  String get activitySedentary;

  /// No description provided for @activitySedentaryDesc.
  ///
  /// In vi, this message translates to:
  /// **'Hầu như không tập thể dục'**
  String get activitySedentaryDesc;

  /// No description provided for @activityLight.
  ///
  /// In vi, this message translates to:
  /// **'Nhẹ nhàng'**
  String get activityLight;

  /// No description provided for @activityLightDesc.
  ///
  /// In vi, this message translates to:
  /// **'Vận động 1-3 ngày mỗi tuần'**
  String get activityLightDesc;

  /// No description provided for @activityModerate.
  ///
  /// In vi, this message translates to:
  /// **'Vừa phải'**
  String get activityModerate;

  /// No description provided for @activityModerateDesc.
  ///
  /// In vi, this message translates to:
  /// **'Vận động 3-5 ngày mỗi tuần'**
  String get activityModerateDesc;

  /// No description provided for @activityActive.
  ///
  /// In vi, this message translates to:
  /// **'Năng động'**
  String get activityActive;

  /// No description provided for @activityActiveDesc.
  ///
  /// In vi, this message translates to:
  /// **'Vận động 6-7 ngày mỗi tuần'**
  String get activityActiveDesc;

  /// No description provided for @activityVeryActive.
  ///
  /// In vi, this message translates to:
  /// **'Rất năng động'**
  String get activityVeryActive;

  /// No description provided for @activityVeryActiveDesc.
  ///
  /// In vi, this message translates to:
  /// **'Chơi thể thao hằng ngày'**
  String get activityVeryActiveDesc;

  /// No description provided for @stepSleepTitle.
  ///
  /// In vi, this message translates to:
  /// **'Lịch ngủ của bạn'**
  String get stepSleepTitle;

  /// No description provided for @sleepTimeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giờ đi ngủ'**
  String get sleepTimeLabel;

  /// No description provided for @wakeTimeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Giờ thức dậy'**
  String get wakeTimeLabel;

  /// No description provided for @nextButton.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get nextButton;

  /// No description provided for @backButton.
  ///
  /// In vi, this message translates to:
  /// **'Quay lại'**
  String get backButton;

  /// No description provided for @finishButton.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành'**
  String get finishButton;

  /// No description provided for @fieldRequired.
  ///
  /// In vi, this message translates to:
  /// **'Vui lòng nhập thông tin này'**
  String get fieldRequired;

  /// No description provided for @fieldInvalid.
  ///
  /// In vi, this message translates to:
  /// **'Giá trị chưa hợp lệ'**
  String get fieldInvalid;

  /// No description provided for @profileSaveError.
  ///
  /// In vi, this message translates to:
  /// **'Không lưu được hồ sơ. Vui lòng thử lại.'**
  String get profileSaveError;

  /// No description provided for @retryButton.
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get retryButton;

  /// No description provided for @createProfilePrompt.
  ///
  /// In vi, this message translates to:
  /// **'Hãy tạo hồ sơ sức khỏe để nhận mục tiêu dành riêng cho bạn!'**
  String get createProfilePrompt;

  /// No description provided for @createProfileButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo hồ sơ'**
  String get createProfileButton;

  /// No description provided for @editProfileButton.
  ///
  /// In vi, this message translates to:
  /// **'Chỉnh sửa hồ sơ'**
  String get editProfileButton;

  /// No description provided for @bmiLabel.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ số BMI'**
  String get bmiLabel;

  /// No description provided for @bmiHealthy.
  ///
  /// In vi, this message translates to:
  /// **'Cân đối'**
  String get bmiHealthy;

  /// No description provided for @bmiUnderweight.
  ///
  /// In vi, this message translates to:
  /// **'Hơi gầy'**
  String get bmiUnderweight;

  /// No description provided for @bmiOverweight.
  ///
  /// In vi, this message translates to:
  /// **'Hơi thừa cân'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In vi, this message translates to:
  /// **'Thừa cân'**
  String get bmiObese;

  /// No description provided for @waterValue.
  ///
  /// In vi, this message translates to:
  /// **'{amount} ml mỗi ngày'**
  String waterValue(int amount);

  /// No description provided for @sleepValue.
  ///
  /// In vi, this message translates to:
  /// **'{min}-{max} giờ mỗi đêm'**
  String sleepValue(int min, int max);

  /// No description provided for @calorieValue.
  ///
  /// In vi, this message translates to:
  /// **'Khoảng {amount} kcal'**
  String calorieValue(int amount);

  /// No description provided for @loadError.
  ///
  /// In vi, this message translates to:
  /// **'Không tải được dữ liệu. Kiểm tra kết nối rồi thử lại nhé.'**
  String get loadError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
