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

  /// No description provided for @todayTitle.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get todayTitle;

  /// No description provided for @weeklyTitle.
  ///
  /// In vi, this message translates to:
  /// **'7 ngày qua'**
  String get weeklyTitle;

  /// No description provided for @waterLog.
  ///
  /// In vi, this message translates to:
  /// **'Nước uống'**
  String get waterLog;

  /// No description provided for @addCupButton.
  ///
  /// In vi, this message translates to:
  /// **'+250 ml'**
  String get addCupButton;

  /// No description provided for @sleepLog.
  ///
  /// In vi, this message translates to:
  /// **'Giấc ngủ'**
  String get sleepLog;

  /// No description provided for @exerciseLog.
  ///
  /// In vi, this message translates to:
  /// **'Vận động'**
  String get exerciseLog;

  /// No description provided for @screenTimeLog.
  ///
  /// In vi, this message translates to:
  /// **'Thời gian màn hình'**
  String get screenTimeLog;

  /// No description provided for @moodLog.
  ///
  /// In vi, this message translates to:
  /// **'Tâm trạng'**
  String get moodLog;

  /// No description provided for @stressLog.
  ///
  /// In vi, this message translates to:
  /// **'Căng thẳng'**
  String get stressLog;

  /// No description provided for @stepsLog.
  ///
  /// In vi, this message translates to:
  /// **'Bước chân'**
  String get stepsLog;

  /// No description provided for @stepsValue.
  ///
  /// In vi, this message translates to:
  /// **'{n} bước'**
  String stepsValue(int n);

  /// No description provided for @stepsAuto.
  ///
  /// In vi, this message translates to:
  /// **'Tự động đếm khi bạn mang theo điện thoại'**
  String get stepsAuto;

  /// No description provided for @badgeSteps8k.
  ///
  /// In vi, this message translates to:
  /// **'8.000 bước'**
  String get badgeSteps8k;

  /// No description provided for @notLoggedYet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa ghi'**
  String get notLoggedYet;

  /// No description provided for @mlValue.
  ///
  /// In vi, this message translates to:
  /// **'{amount} ml'**
  String mlValue(int amount);

  /// No description provided for @hoursValue.
  ///
  /// In vi, this message translates to:
  /// **'{amount} giờ'**
  String hoursValue(String amount);

  /// No description provided for @minutesValue.
  ///
  /// In vi, this message translates to:
  /// **'{amount} phút'**
  String minutesValue(int amount);

  /// No description provided for @stressLevelValue.
  ///
  /// In vi, this message translates to:
  /// **'Mức {level}/5'**
  String stressLevelValue(int level);

  /// No description provided for @saveButton.
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get saveButton;

  /// No description provided for @cancelButton.
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get cancelButton;

  /// No description provided for @chartWater.
  ///
  /// In vi, this message translates to:
  /// **'Nước (ml)'**
  String get chartWater;

  /// No description provided for @chartSleep.
  ///
  /// In vi, this message translates to:
  /// **'Ngủ (giờ)'**
  String get chartSleep;

  /// No description provided for @chartTargetLine.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu'**
  String get chartTargetLine;

  /// No description provided for @coachInputHint.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi mình về sức khỏe nhé...'**
  String get coachInputHint;

  /// No description provided for @coachSendTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get coachSendTooltip;

  /// No description provided for @coachTyping.
  ///
  /// In vi, this message translates to:
  /// **'AIMedic đang trả lời...'**
  String get coachTyping;

  /// No description provided for @coachSendError.
  ///
  /// In vi, this message translates to:
  /// **'Không gửi được tin nhắn. Vui lòng thử lại.'**
  String get coachSendError;

  /// No description provided for @coachWelcome.
  ///
  /// In vi, this message translates to:
  /// **'Chào bạn! Mình là AIMedic — người bạn đồng hành sức khỏe của bạn. Hãy hỏi mình về giấc ngủ, dinh dưỡng, vận động hoặc cảm xúc nhé! 💚'**
  String get coachWelcome;

  /// No description provided for @levelLabel.
  ///
  /// In vi, this message translates to:
  /// **'Cấp {level}'**
  String levelLabel(int level);

  /// No description provided for @xpProgress.
  ///
  /// In vi, this message translates to:
  /// **'{current}/{total} XP'**
  String xpProgress(int current, int total);

  /// No description provided for @streakDays.
  ///
  /// In vi, this message translates to:
  /// **'{days} ngày liên tiếp'**
  String streakDays(int days);

  /// No description provided for @petTitle.
  ///
  /// In vi, this message translates to:
  /// **'Bo — bạn đồng hành'**
  String get petTitle;

  /// No description provided for @petMoodHappy.
  ///
  /// In vi, this message translates to:
  /// **'Bo đang rất vui vì bạn chăm sóc bản thân! 🎉'**
  String get petMoodHappy;

  /// No description provided for @petMoodOk.
  ///
  /// In vi, this message translates to:
  /// **'Bo đang chờ bạn ghi thêm nhật ký hôm nay~'**
  String get petMoodOk;

  /// No description provided for @petMoodSleepy.
  ///
  /// In vi, this message translates to:
  /// **'Bo hơi buồn ngủ... ghi một hoạt động để đánh thức Bo nhé!'**
  String get petMoodSleepy;

  /// No description provided for @petCoins.
  ///
  /// In vi, this message translates to:
  /// **'{n} xu'**
  String petCoins(int n);

  /// No description provided for @petShopTitle.
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng phụ kiện'**
  String get petShopTitle;

  /// No description provided for @petShopHint.
  ///
  /// In vi, this message translates to:
  /// **'Kiếm xu bằng cách ghi nhật ký mỗi ngày'**
  String get petShopHint;

  /// No description provided for @petBuy.
  ///
  /// In vi, this message translates to:
  /// **'Mua · {n} xu'**
  String petBuy(int n);

  /// No description provided for @petWearing.
  ///
  /// In vi, this message translates to:
  /// **'Đang đeo'**
  String get petWearing;

  /// No description provided for @petOwned.
  ///
  /// In vi, this message translates to:
  /// **'Đã có'**
  String get petOwned;

  /// No description provided for @petNotEnoughCoins.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đủ xu — ghi thêm nhật ký để kiếm xu nhé!'**
  String get petNotEnoughCoins;

  /// No description provided for @petShopButton.
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng'**
  String get petShopButton;

  /// No description provided for @breathingTitle.
  ///
  /// In vi, this message translates to:
  /// **'Góc bình yên'**
  String get breathingTitle;

  /// No description provided for @breathingSubtitle.
  ///
  /// In vi, this message translates to:
  /// **'Hít thở sâu giúp bạn bình tĩnh và tập trung hơn'**
  String get breathingSubtitle;

  /// No description provided for @breathingInhale.
  ///
  /// In vi, this message translates to:
  /// **'Hít vào...'**
  String get breathingInhale;

  /// No description provided for @breathingHold.
  ///
  /// In vi, this message translates to:
  /// **'Giữ hơi...'**
  String get breathingHold;

  /// No description provided for @breathingExhale.
  ///
  /// In vi, this message translates to:
  /// **'Thở ra...'**
  String get breathingExhale;

  /// No description provided for @breathingStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu'**
  String get breathingStart;

  /// No description provided for @breathingStop.
  ///
  /// In vi, this message translates to:
  /// **'Dừng lại'**
  String get breathingStop;

  /// No description provided for @breathingDone.
  ///
  /// In vi, this message translates to:
  /// **'Tuyệt vời! Bạn cảm thấy thế nào?'**
  String get breathingDone;

  /// No description provided for @breathingMinutes.
  ///
  /// In vi, this message translates to:
  /// **'{n} phút'**
  String breathingMinutes(int n);

  /// No description provided for @breathingOpenButton.
  ///
  /// In vi, this message translates to:
  /// **'Thư giãn nào'**
  String get breathingOpenButton;

  /// No description provided for @introSlide1Title.
  ///
  /// In vi, this message translates to:
  /// **'Chào bạn, mình là AIMedic! 👋'**
  String get introSlide1Title;

  /// No description provided for @introSlide1Body.
  ///
  /// In vi, this message translates to:
  /// **'Người bạn đồng hành giúp bạn xây dựng thói quen sống khỏe mỗi ngày — được tạo ra dành riêng cho học sinh.'**
  String get introSlide1Body;

  /// No description provided for @introSlide2Title.
  ///
  /// In vi, this message translates to:
  /// **'Ghi lại & tiến bộ 📊'**
  String get introSlide2Title;

  /// No description provided for @introSlide2Body.
  ///
  /// In vi, this message translates to:
  /// **'Theo dõi nước uống, giấc ngủ, vận động và tâm trạng chỉ với một chạm. Nhận XP, huy hiệu và giữ chuỗi ngày của bạn!'**
  String get introSlide2Body;

  /// No description provided for @introSlide3Title.
  ///
  /// In vi, this message translates to:
  /// **'Trợ lý AI luôn bên bạn 🤖'**
  String get introSlide3Title;

  /// No description provided for @introSlide3Body.
  ///
  /// In vi, this message translates to:
  /// **'Hỏi bất cứ điều gì về sức khỏe — AI hiểu thói quen của bạn và trả lời thân thiện, dễ hiểu. Không chẩn đoán, không phán xét.'**
  String get introSlide3Body;

  /// No description provided for @introSkip.
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua'**
  String get introSkip;

  /// No description provided for @introNext.
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get introNext;

  /// No description provided for @introStart.
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu nào!'**
  String get introStart;

  /// No description provided for @authLoginTitle.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get authLoginTitle;

  /// No description provided for @authRegisterTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tạo tài khoản'**
  String get authRegisterTitle;

  /// No description provided for @emailLabel.
  ///
  /// In vi, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get passwordLabel;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In vi, this message translates to:
  /// **'Nhập lại mật khẩu'**
  String get confirmPasswordLabel;

  /// No description provided for @authLoginButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập'**
  String get authLoginButton;

  /// No description provided for @authRegisterButton.
  ///
  /// In vi, this message translates to:
  /// **'Đăng ký'**
  String get authRegisterButton;

  /// No description provided for @authSwitchToRegister.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tài khoản? Đăng ký'**
  String get authSwitchToRegister;

  /// No description provided for @authSwitchToLogin.
  ///
  /// In vi, this message translates to:
  /// **'Đã có tài khoản? Đăng nhập'**
  String get authSwitchToLogin;

  /// No description provided for @authErrorInvalidCredentials.
  ///
  /// In vi, this message translates to:
  /// **'Email hoặc mật khẩu chưa đúng.'**
  String get authErrorInvalidCredentials;

  /// No description provided for @authErrorEmailInUse.
  ///
  /// In vi, this message translates to:
  /// **'Email này đã được đăng ký.'**
  String get authErrorEmailInUse;

  /// No description provided for @authErrorWeakPassword.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu cần ít nhất 6 ký tự.'**
  String get authErrorWeakPassword;

  /// No description provided for @authErrorInvalidEmail.
  ///
  /// In vi, this message translates to:
  /// **'Email chưa hợp lệ.'**
  String get authErrorInvalidEmail;

  /// No description provided for @authErrorGeneric.
  ///
  /// In vi, this message translates to:
  /// **'Có lỗi xảy ra. Vui lòng thử lại.'**
  String get authErrorGeneric;

  /// No description provided for @passwordMismatch.
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu nhập lại chưa khớp.'**
  String get passwordMismatch;

  /// No description provided for @logoutTooltip.
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất'**
  String get logoutTooltip;

  /// No description provided for @challengeTitle.
  ///
  /// In vi, this message translates to:
  /// **'Thử thách lớp học'**
  String get challengeTitle;

  /// No description provided for @challengeEmpty.
  ///
  /// In vi, this message translates to:
  /// **'Cùng cả lớp lập một mục tiêu chung nhé!'**
  String get challengeEmpty;

  /// No description provided for @challengeJoinButton.
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã'**
  String get challengeJoinButton;

  /// No description provided for @challengeCreateButton.
  ///
  /// In vi, this message translates to:
  /// **'Tạo mới'**
  String get challengeCreateButton;

  /// No description provided for @challengeCodeLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mã tham gia (6 ký tự)'**
  String get challengeCodeLabel;

  /// No description provided for @challengeNameLabel.
  ///
  /// In vi, this message translates to:
  /// **'Tên thử thách'**
  String get challengeNameLabel;

  /// No description provided for @challengeGoalLabel.
  ///
  /// In vi, this message translates to:
  /// **'Mục tiêu chung'**
  String get challengeGoalLabel;

  /// No description provided for @challengeMetricWater.
  ///
  /// In vi, this message translates to:
  /// **'Nước (ml)'**
  String get challengeMetricWater;

  /// No description provided for @challengeMetricSteps.
  ///
  /// In vi, this message translates to:
  /// **'Bước chân'**
  String get challengeMetricSteps;

  /// No description provided for @challengeMetricDays.
  ///
  /// In vi, this message translates to:
  /// **'Ngày ghi nhật ký'**
  String get challengeMetricDays;

  /// No description provided for @challengeMembers.
  ///
  /// In vi, this message translates to:
  /// **'{n} thành viên'**
  String challengeMembers(int n);

  /// No description provided for @challengeDaysLeft.
  ///
  /// In vi, this message translates to:
  /// **'còn {n} ngày'**
  String challengeDaysLeft(int n);

  /// No description provided for @challengeMyPart.
  ///
  /// In vi, this message translates to:
  /// **'Phần của bạn: {n}'**
  String challengeMyPart(int n);

  /// No description provided for @challengeCompleted.
  ///
  /// In vi, this message translates to:
  /// **'Hoàn thành! Cả lớp làm được rồi! 🎉'**
  String get challengeCompleted;

  /// No description provided for @challengeShareCode.
  ///
  /// In vi, this message translates to:
  /// **'Mã mời: {code}'**
  String challengeShareCode(String code);

  /// No description provided for @challengeJoinError.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy thử thách với mã này.'**
  String get challengeJoinError;

  /// No description provided for @challengeCreateError.
  ///
  /// In vi, this message translates to:
  /// **'Không tạo được thử thách. Thử lại nhé.'**
  String get challengeCreateError;

  /// No description provided for @recapTitle.
  ///
  /// In vi, this message translates to:
  /// **'Tổng kết tuần của bạn'**
  String get recapTitle;

  /// No description provided for @insightsTitle.
  ///
  /// In vi, this message translates to:
  /// **'Nhận xét tuần này'**
  String get insightsTitle;

  /// No description provided for @insightSleepDebt.
  ///
  /// In vi, this message translates to:
  /// **'Bạn ngủ trung bình {value} giờ mỗi đêm — hơi ít đó. Thử đi ngủ sớm hơn 30 phút nhé!'**
  String insightSleepDebt(String value);

  /// No description provided for @insightSleepGood.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang ngủ rất điều độ ({value} giờ mỗi đêm). Tuyệt vời!'**
  String insightSleepGood(String value);

  /// No description provided for @insightLowWater.
  ///
  /// In vi, this message translates to:
  /// **'Bạn uống trung bình {value} ml nước mỗi ngày, thấp hơn mục tiêu. Nhớ mang theo chai nước nhé!'**
  String insightLowWater(String value);

  /// No description provided for @insightWaterGood.
  ///
  /// In vi, this message translates to:
  /// **'Bạn uống đủ nước mỗi ngày ({value} ml). Cứ tiếp tục nhé!'**
  String insightWaterGood(String value);

  /// No description provided for @insightHighScreenTime.
  ///
  /// In vi, this message translates to:
  /// **'Bạn dùng màn hình trung bình {value} phút mỗi ngày. Thử nghỉ giải lao và vận động nhiều hơn nhé!'**
  String insightHighScreenTime(String value);

  /// No description provided for @insightHighStress.
  ///
  /// In vi, this message translates to:
  /// **'Tuần này bạn có vẻ căng thẳng. Hãy thử hít thở sâu và trò chuyện với người thân nhé.'**
  String get insightHighStress;

  /// No description provided for @insightLowExercise.
  ///
  /// In vi, this message translates to:
  /// **'Tuần này bạn vận động khá ít. Đi bộ hoặc chơi thể thao 30 phút mỗi ngày sẽ rất tốt đó!'**
  String get insightLowExercise;

  /// No description provided for @badgeFirstLog.
  ///
  /// In vi, this message translates to:
  /// **'Khởi đầu'**
  String get badgeFirstLog;

  /// No description provided for @badgeStreak3.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi 3 ngày'**
  String get badgeStreak3;

  /// No description provided for @badgeStreak7.
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi 7 ngày'**
  String get badgeStreak7;

  /// No description provided for @badgeWater10l.
  ///
  /// In vi, this message translates to:
  /// **'10 lít nước'**
  String get badgeWater10l;

  /// No description provided for @badgeMood5Days.
  ///
  /// In vi, this message translates to:
  /// **'Hiểu cảm xúc'**
  String get badgeMood5Days;

  /// No description provided for @badgeActive5Days.
  ///
  /// In vi, this message translates to:
  /// **'Năng động'**
  String get badgeActive5Days;
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
