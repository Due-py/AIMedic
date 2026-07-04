// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'AIMedic';

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String homeGreeting(String name) {
    return 'Chào $name! Hôm nay bạn thế nào?';
  }

  @override
  String get coachTitle => 'Trợ lý AI';

  @override
  String get trackingTitle => 'Nhật ký';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String get waterTarget => 'Mục tiêu nước uống';

  @override
  String get sleepTarget => 'Mục tiêu giấc ngủ';

  @override
  String get calorieTarget => 'Năng lượng mỗi ngày';

  @override
  String get comingSoon => 'Tính năng đang được phát triển';

  @override
  String get medicalDisclaimer =>
      'AIMedic là công cụ hỗ trợ thói quen lành mạnh, không thay thế bác sĩ hoặc nhân viên y tế.';

  @override
  String get onboardingTitle => 'Tạo hồ sơ sức khỏe';

  @override
  String stepOf(int current, int total) {
    return 'Bước $current/$total';
  }

  @override
  String get stepBasicsTitle => 'Bạn là ai?';

  @override
  String get ageLabel => 'Tuổi';

  @override
  String get genderLabel => 'Giới tính';

  @override
  String get genderMale => 'Nam';

  @override
  String get genderFemale => 'Nữ';

  @override
  String get stepBodyTitle => 'Chiều cao và cân nặng';

  @override
  String get heightLabel => 'Chiều cao (cm)';

  @override
  String get weightLabel => 'Cân nặng (kg)';

  @override
  String get stepActivityTitle => 'Bạn vận động thế nào?';

  @override
  String get activitySedentary => 'Ít vận động';

  @override
  String get activitySedentaryDesc => 'Hầu như không tập thể dục';

  @override
  String get activityLight => 'Nhẹ nhàng';

  @override
  String get activityLightDesc => 'Vận động 1-3 ngày mỗi tuần';

  @override
  String get activityModerate => 'Vừa phải';

  @override
  String get activityModerateDesc => 'Vận động 3-5 ngày mỗi tuần';

  @override
  String get activityActive => 'Năng động';

  @override
  String get activityActiveDesc => 'Vận động 6-7 ngày mỗi tuần';

  @override
  String get activityVeryActive => 'Rất năng động';

  @override
  String get activityVeryActiveDesc => 'Chơi thể thao hằng ngày';

  @override
  String get stepSleepTitle => 'Lịch ngủ của bạn';

  @override
  String get sleepTimeLabel => 'Giờ đi ngủ';

  @override
  String get wakeTimeLabel => 'Giờ thức dậy';

  @override
  String get nextButton => 'Tiếp tục';

  @override
  String get backButton => 'Quay lại';

  @override
  String get finishButton => 'Hoàn thành';

  @override
  String get fieldRequired => 'Vui lòng nhập thông tin này';

  @override
  String get fieldInvalid => 'Giá trị chưa hợp lệ';

  @override
  String get profileSaveError => 'Không lưu được hồ sơ. Vui lòng thử lại.';

  @override
  String get retryButton => 'Thử lại';

  @override
  String get createProfilePrompt =>
      'Hãy tạo hồ sơ sức khỏe để nhận mục tiêu dành riêng cho bạn!';

  @override
  String get createProfileButton => 'Tạo hồ sơ';

  @override
  String get editProfileButton => 'Chỉnh sửa hồ sơ';

  @override
  String get bmiLabel => 'Chỉ số BMI';

  @override
  String get bmiHealthy => 'Cân đối';

  @override
  String get bmiUnderweight => 'Hơi gầy';

  @override
  String get bmiOverweight => 'Hơi thừa cân';

  @override
  String get bmiObese => 'Thừa cân';

  @override
  String waterValue(int amount) {
    return '$amount ml mỗi ngày';
  }

  @override
  String sleepValue(int min, int max) {
    return '$min-$max giờ mỗi đêm';
  }

  @override
  String calorieValue(int amount) {
    return 'Khoảng $amount kcal';
  }

  @override
  String get loadError =>
      'Không tải được dữ liệu. Kiểm tra kết nối rồi thử lại nhé.';

  @override
  String get todayTitle => 'Hôm nay';

  @override
  String get weeklyTitle => '7 ngày qua';

  @override
  String get waterLog => 'Nước uống';

  @override
  String get addCupButton => '+250 ml';

  @override
  String get sleepLog => 'Giấc ngủ';

  @override
  String get exerciseLog => 'Vận động';

  @override
  String get screenTimeLog => 'Thời gian màn hình';

  @override
  String get moodLog => 'Tâm trạng';

  @override
  String get stressLog => 'Căng thẳng';

  @override
  String get notLoggedYet => 'Chưa ghi';

  @override
  String mlValue(int amount) {
    return '$amount ml';
  }

  @override
  String hoursValue(String amount) {
    return '$amount giờ';
  }

  @override
  String minutesValue(int amount) {
    return '$amount phút';
  }

  @override
  String stressLevelValue(int level) {
    return 'Mức $level/5';
  }

  @override
  String get saveButton => 'Lưu';

  @override
  String get cancelButton => 'Hủy';

  @override
  String get chartWater => 'Nước (ml)';

  @override
  String get chartSleep => 'Ngủ (giờ)';

  @override
  String get chartTargetLine => 'Mục tiêu';

  @override
  String get coachInputHint => 'Hỏi mình về sức khỏe nhé...';

  @override
  String get coachSendTooltip => 'Gửi';

  @override
  String get coachTyping => 'AIMedic đang trả lời...';

  @override
  String get coachSendError => 'Không gửi được tin nhắn. Vui lòng thử lại.';

  @override
  String get coachWelcome =>
      'Chào bạn! Mình là AIMedic — người bạn đồng hành sức khỏe của bạn. Hãy hỏi mình về giấc ngủ, dinh dưỡng, vận động hoặc cảm xúc nhé! 💚';

  @override
  String levelLabel(int level) {
    return 'Cấp $level';
  }

  @override
  String xpProgress(int current, int total) {
    return '$current/$total XP';
  }

  @override
  String streakDays(int days) {
    return '$days ngày liên tiếp';
  }

  @override
  String get introSlide1Title => 'Chào bạn, mình là AIMedic! 👋';

  @override
  String get introSlide1Body =>
      'Người bạn đồng hành giúp bạn xây dựng thói quen sống khỏe mỗi ngày — được tạo ra dành riêng cho học sinh.';

  @override
  String get introSlide2Title => 'Ghi lại & tiến bộ 📊';

  @override
  String get introSlide2Body =>
      'Theo dõi nước uống, giấc ngủ, vận động và tâm trạng chỉ với một chạm. Nhận XP, huy hiệu và giữ chuỗi ngày của bạn!';

  @override
  String get introSlide3Title => 'Trợ lý AI luôn bên bạn 🤖';

  @override
  String get introSlide3Body =>
      'Hỏi bất cứ điều gì về sức khỏe — AI hiểu thói quen của bạn và trả lời thân thiện, dễ hiểu. Không chẩn đoán, không phán xét.';

  @override
  String get introSkip => 'Bỏ qua';

  @override
  String get introNext => 'Tiếp tục';

  @override
  String get introStart => 'Bắt đầu nào!';

  @override
  String get authLoginTitle => 'Đăng nhập';

  @override
  String get authRegisterTitle => 'Tạo tài khoản';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Mật khẩu';

  @override
  String get confirmPasswordLabel => 'Nhập lại mật khẩu';

  @override
  String get authLoginButton => 'Đăng nhập';

  @override
  String get authRegisterButton => 'Đăng ký';

  @override
  String get authSwitchToRegister => 'Chưa có tài khoản? Đăng ký';

  @override
  String get authSwitchToLogin => 'Đã có tài khoản? Đăng nhập';

  @override
  String get authErrorInvalidCredentials => 'Email hoặc mật khẩu chưa đúng.';

  @override
  String get authErrorEmailInUse => 'Email này đã được đăng ký.';

  @override
  String get authErrorWeakPassword => 'Mật khẩu cần ít nhất 6 ký tự.';

  @override
  String get authErrorInvalidEmail => 'Email chưa hợp lệ.';

  @override
  String get authErrorGeneric => 'Có lỗi xảy ra. Vui lòng thử lại.';

  @override
  String get passwordMismatch => 'Mật khẩu nhập lại chưa khớp.';

  @override
  String get logoutTooltip => 'Đăng xuất';

  @override
  String get insightsTitle => 'Nhận xét tuần này';

  @override
  String insightSleepDebt(String value) {
    return 'Bạn ngủ trung bình $value giờ mỗi đêm — hơi ít đó. Thử đi ngủ sớm hơn 30 phút nhé!';
  }

  @override
  String insightSleepGood(String value) {
    return 'Bạn đang ngủ rất điều độ ($value giờ mỗi đêm). Tuyệt vời!';
  }

  @override
  String insightLowWater(String value) {
    return 'Bạn uống trung bình $value ml nước mỗi ngày, thấp hơn mục tiêu. Nhớ mang theo chai nước nhé!';
  }

  @override
  String insightWaterGood(String value) {
    return 'Bạn uống đủ nước mỗi ngày ($value ml). Cứ tiếp tục nhé!';
  }

  @override
  String insightHighScreenTime(String value) {
    return 'Bạn dùng màn hình trung bình $value phút mỗi ngày. Thử nghỉ giải lao và vận động nhiều hơn nhé!';
  }

  @override
  String get insightHighStress =>
      'Tuần này bạn có vẻ căng thẳng. Hãy thử hít thở sâu và trò chuyện với người thân nhé.';

  @override
  String get insightLowExercise =>
      'Tuần này bạn vận động khá ít. Đi bộ hoặc chơi thể thao 30 phút mỗi ngày sẽ rất tốt đó!';

  @override
  String get badgeFirstLog => 'Khởi đầu';

  @override
  String get badgeStreak3 => 'Chuỗi 3 ngày';

  @override
  String get badgeStreak7 => 'Chuỗi 7 ngày';

  @override
  String get badgeWater10l => '10 lít nước';

  @override
  String get badgeMood5Days => 'Hiểu cảm xúc';

  @override
  String get badgeActive5Days => 'Năng động';
}
