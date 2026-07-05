import 'package:aimedic/features/coach/coach_models.dart';
import 'package:aimedic/features/coach/coach_repository.dart';
import 'package:aimedic/features/gamification/gamification_models.dart';
import 'package:aimedic/features/gamification/gamification_repository.dart';
import 'package:aimedic/features/insights/insights_repository.dart';
import 'package:aimedic/features/pet/pet_models.dart';
import 'package:aimedic/features/pet/pet_repository.dart';
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

class FakePetRepository implements PetRepository {
  static const _catalog = [
    Accessory(id: 'balloon', emoji: '🎈', price: 10),
    Accessory(id: 'crown', emoji: '👑', price: 50),
  ];

  int coins = 12;
  List<String> owned = [];
  List<String> equipped = [];

  PetState get _state => PetState(
        stage: 'chick',
        mood: 'happy',
        coins: coins,
        owned: List.of(owned),
        equipped: List.of(equipped),
        catalog: _catalog,
      );

  @override
  Future<PetState> fetch() async => _state;

  @override
  Future<PetState> buy(String accessoryId) async {
    final accessory = _catalog.firstWhere((a) => a.id == accessoryId);
    if (coins < accessory.price) throw Exception('not enough coins');
    coins -= accessory.price;
    owned.add(accessoryId);
    equipped.add(accessoryId);
    return _state;
  }

  @override
  Future<PetState> toggleEquip(String accessoryId) async {
    equipped.contains(accessoryId)
        ? equipped.remove(accessoryId)
        : equipped.add(accessoryId);
    return _state;
  }
}

class FakeGamificationRepository implements GamificationRepository {
  GamificationState state = const GamificationState(
    xp: 45,
    level: 1,
    xpIntoLevel: 45,
    xpPerLevel: 100,
    streakDays: 3,
    badges: [
      Badge(id: 'first_log', earned: true),
      Badge(id: 'streak_3', earned: true),
      Badge(id: 'streak_7', earned: false),
    ],
  );

  @override
  Future<GamificationState> fetch() async => state;
}

class FakeInsightsRepository implements InsightsRepository {
  List<Insight> insights = const [];

  @override
  Future<List<Insight>> fetch() async => insights;
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
