import 'package:aimedic/features/coach/coach_models.dart';
import 'package:aimedic/features/coach/coach_repository.dart';
import 'package:aimedic/features/profile/profile_models.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/features/tracking/tracking_models.dart';
import 'package:aimedic/features/tracking/tracking_repository.dart';

/// In-memory ProfileRepository that mimics the backend's dev mode,
/// including target computation for assertion-friendly values.
class FakeProfileRepository implements ProfileRepository {
  Profile? stored;

  @override
  Future<Profile?> fetch() async => stored;

  @override
  Future<Profile> save(ProfileDraft draft) async {
    final heightM = draft.heightCm / 100;
    final bmi = double.parse(
        (draft.weightKg / (heightM * heightM)).toStringAsFixed(1));
    stored = Profile(
      draft: draft,
      targets: HealthTargets(
        bmi: bmi,
        bmiCategory: bmi < 18.5
            ? 'underweight'
            : bmi < 25
                ? 'healthy'
                : bmi < 30
                    ? 'overweight'
                    : 'obese',
        dailyCalories: 2106,
        dailyWaterMl: 1800,
        sleepHoursMin: 9,
        sleepHoursMax: 11,
      ),
    );
    return stored!;
  }
}

class FakeCoachRepository implements CoachRepository {
  final List<ChatMessage> messages = [];
  bool failNext = false;

  @override
  Future<List<ChatMessage>> history() async => List.of(messages);

  @override
  Future<ChatMessage> send(String message) async {
    if (failNext) {
      failNext = false;
      throw Exception('network');
    }
    messages.add(ChatMessage(role: 'user', content: message));
    final reply =
        ChatMessage(role: 'assistant', content: 'Uống đủ nước mỗi ngày nhé!');
    messages.add(reply);
    return reply;
  }
}

class FakeTrackingRepository implements TrackingRepository {
  final Map<String, DailyLog> logs = {};

  DailyLog _day(String date) => logs[date] ?? DailyLog(date: date);

  @override
  Future<DailyLog> fetchDay(String date) async => _day(date);

  @override
  Future<List<DailyLog>> fetchRange(String start, String end) async {
    final dates = logs.keys
        .where((d) => start.compareTo(d) <= 0 && d.compareTo(end) <= 0)
        .toList()
      ..sort();
    return [for (final d in dates) logs[d]!];
  }

  @override
  Future<DailyLog> patchDay(String date, DailyLogPatch patch) async {
    final old = _day(date);
    final updated = DailyLog(
      date: date,
      waterMl: patch.waterMl ?? old.waterMl,
      sleepHours: patch.sleepHours ?? old.sleepHours,
      exerciseMinutes: patch.exerciseMinutes ?? old.exerciseMinutes,
      screenTimeMinutes: patch.screenTimeMinutes ?? old.screenTimeMinutes,
      mood: patch.mood ?? old.mood,
      stress: patch.stress ?? old.stress,
      meals: patch.meals ?? old.meals,
    );
    logs[date] = updated;
    return updated;
  }

  @override
  Future<DailyLog> addWater(String date, {int amountMl = 250}) async {
    final old = _day(date);
    return patchDay(date, DailyLogPatch(waterMl: old.waterMl + amountMl));
  }
}
