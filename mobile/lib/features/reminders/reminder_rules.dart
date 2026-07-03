// Pure reminder-time computation, separated from the notifications plugin
// so it can be unit-tested.

import '../profile/profile_models.dart';

enum ReminderType { water, eyeRest, bedtime }

class Reminder {
  const Reminder({
    required this.id,
    required this.type,
    required this.hour,
    required this.minute,
  });

  final int id;
  final ReminderType type;
  final int hour; // 0-23
  final int minute; // 0-59

  @override
  String toString() =>
      '$type@${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

const _maxWaterReminders = 4; // anti-spam cap (CLAUDE.md: avoid excess)

int _parseMinutes(String hhmm) {
  final parts = hhmm.split(':');
  return int.parse(parts[0]) * 60 + int.parse(parts[1]);
}

Reminder _at(int id, ReminderType type, int minutesOfDay) {
  final m = ((minutesOfDay % 1440) + 1440) % 1440;
  return Reminder(id: id, type: type, hour: m ~/ 60, minute: m % 60);
}

/// Derives the daily reminder schedule from the student's profile:
/// - water: every 2.5h starting 1h after wake-up, while at least 1h
///   before bedtime (max [_maxWaterReminders]);
/// - eye rest: 4h after wake-up;
/// - bedtime wind-down: 30 min before sleep time.
List<Reminder> computeReminders(ProfileDraft profile) {
  final wake = _parseMinutes(profile.wakeTime);
  var sleep = _parseMinutes(profile.sleepTime);
  // A bedtime at/after midnight belongs to the next day.
  if (sleep <= wake) sleep += 1440;

  final reminders = <Reminder>[];
  var id = 0;

  for (var t = wake + 60;
      t <= sleep - 60 && reminders.length < _maxWaterReminders;
      t += 150) {
    reminders.add(_at(id++, ReminderType.water, t));
  }

  final eyeRest = wake + 240;
  if (eyeRest <= sleep - 60) {
    reminders.add(_at(id++, ReminderType.eyeRest, eyeRest));
  }

  reminders.add(_at(id++, ReminderType.bedtime, sleep - 30));
  return reminders;
}
