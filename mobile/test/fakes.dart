import 'package:aimedic/features/profile/profile_models.dart';
import 'package:aimedic/features/profile/profile_repository.dart';

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
