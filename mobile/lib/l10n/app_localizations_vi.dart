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
}
