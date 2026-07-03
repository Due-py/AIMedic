import 'package:aimedic/features/profile/profile_models.dart';
import 'package:aimedic/features/reminders/reminder_rules.dart';
import 'package:flutter_test/flutter_test.dart';

ProfileDraft profile({String wake = '06:30', String sleep = '22:00'}) =>
    ProfileDraft(
      age: 13,
      gender: Gender.male,
      heightCm: 155,
      weightKg: 45,
      activityLevel: ActivityLevel.moderate,
      sleepTime: sleep,
      wakeTime: wake,
    );

void main() {
  test('typical schedule: capped water, eye rest, bedtime', () {
    final reminders = computeReminders(profile());
    final byType = <ReminderType, List<Reminder>>{};
    for (final r in reminders) {
      byType.putIfAbsent(r.type, () => []).add(r);
    }

    // Water: 07:30, 10:00, 12:30, 15:00 — capped at 4.
    expect(
      byType[ReminderType.water]!.map((r) => '${r.hour}:${r.minute}'),
      ['7:30', '10:0', '12:30', '15:0'],
    );
    // Eye rest 4h after waking.
    expect(byType[ReminderType.eyeRest]!.single.hour, 10);
    // Wind-down 30 min before bed.
    final bedtime = byType[ReminderType.bedtime]!.single;
    expect((bedtime.hour, bedtime.minute), (21, 30));
  });

  test('after-midnight bedtime wraps correctly', () {
    final reminders = computeReminders(profile(wake: '07:00', sleep: '00:30'));
    final bedtime =
        reminders.singleWhere((r) => r.type == ReminderType.bedtime);
    expect((bedtime.hour, bedtime.minute), (0, 0));
  });

  test('short day never schedules reminders within an hour of bed', () {
    final reminders = computeReminders(profile(wake: '10:00', sleep: '13:00'));
    // Only 11:00 fits: 12:30 would be within an hour of the 13:00 bedtime.
    final water = reminders.where((r) => r.type == ReminderType.water);
    expect(water.map((r) => r.hour), [11]);
    // Eye rest would land at 14:00, after bedtime — skipped.
    expect(reminders.where((r) => r.type == ReminderType.eyeRest), isEmpty);
  });

  test('unique notification ids', () {
    final reminders = computeReminders(profile());
    final ids = reminders.map((r) => r.id).toSet();
    expect(ids.length, reminders.length);
  });
}
