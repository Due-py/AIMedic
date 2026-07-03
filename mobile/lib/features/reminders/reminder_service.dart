import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../profile/profile_models.dart';
import 'reminder_rules.dart';

/// Schedules daily local notifications derived from the student's profile.
/// Failures are swallowed: reminders are a nice-to-have and must never
/// block onboarding.
class ReminderService {
  ReminderService._();

  static final instance = ReminderService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // VI-first, matching the app locale. Move into l10n when EN ships.
  static const _messages = {
    ReminderType.water: (
      'Uống nước nào! 💧',
      'Một cốc nước nhỏ giúp bạn tỉnh táo và khỏe mạnh hơn.',
    ),
    ReminderType.eyeRest: (
      'Cho mắt nghỉ chút nhé 👀',
      'Nhìn ra xa 20 giây và chớp mắt vài lần cho đỡ mỏi.',
    ),
    ReminderType.bedtime: (
      'Sắp đến giờ ngủ rồi 🌙',
      'Cất điện thoại và thư giãn để có giấc ngủ thật ngon nhé.',
    ),
  };

  Future<bool> _init() async {
    if (_initialized) return true;
    if (kIsWeb) return false;
    try {
      tz_data.initializeTimeZones();
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz.identifier));

      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(),
        ),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _initialized = true;
      return true;
    } catch (e) {
      debugPrint('Reminder init failed: $e');
      return false;
    }
  }

  Future<void> scheduleFromProfile(ProfileDraft profile) async {
    if (!await _init()) return;
    try {
      await _plugin.cancelAll();
      for (final reminder in computeReminders(profile)) {
        final (title, body) = _messages[reminder.type]!;
        await _plugin.zonedSchedule(
          id: reminder.id,
          title: title,
          body: body,
          scheduledDate: _nextInstance(reminder.hour, reminder.minute),
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'health_reminders',
              'Nhắc nhở sức khỏe',
              channelDescription:
                  'Nhắc uống nước, nghỉ mắt và đi ngủ đúng giờ',
              importance: Importance.defaultImportance,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time, // repeat daily
        );
      }
    } catch (e) {
      debugPrint('Reminder scheduling failed: $e');
    }
  }

  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
