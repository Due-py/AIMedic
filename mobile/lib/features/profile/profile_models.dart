// Mirrors backend/app/features/profile/schemas.py.

enum Gender { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

extension ActivityLevelWire on ActivityLevel {
  String get wire => switch (this) {
        ActivityLevel.veryActive => 'very_active',
        _ => name,
      };

  static ActivityLevel fromWire(String value) => switch (value) {
        'very_active' => ActivityLevel.veryActive,
        _ => ActivityLevel.values.byName(value),
      };
}

class HealthTargets {
  const HealthTargets({
    required this.bmi,
    required this.bmiCategory,
    required this.dailyCalories,
    required this.dailyWaterMl,
    required this.sleepHoursMin,
    required this.sleepHoursMax,
  });

  final double bmi;
  final String bmiCategory;
  final int dailyCalories;
  final int dailyWaterMl;
  final int sleepHoursMin;
  final int sleepHoursMax;

  factory HealthTargets.fromJson(Map<String, dynamic> json) => HealthTargets(
        bmi: (json['bmi'] as num).toDouble(),
        bmiCategory: json['bmi_category'] as String,
        dailyCalories: json['daily_calories'] as int,
        dailyWaterMl: json['daily_water_ml'] as int,
        sleepHoursMin: json['sleep_hours_min'] as int,
        sleepHoursMax: json['sleep_hours_max'] as int,
      );
}

class ProfileDraft {
  const ProfileDraft({
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.activityLevel,
    required this.sleepTime,
    required this.wakeTime,
  });

  final int age;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final ActivityLevel activityLevel;
  final String sleepTime; // "HH:mm"
  final String wakeTime; // "HH:mm"

  Map<String, dynamic> toJson() => {
        'age': age,
        'gender': gender.name,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'activity_level': activityLevel.wire,
        'sleep_time': sleepTime,
        'wake_time': wakeTime,
      };
}

class Profile {
  const Profile({required this.draft, required this.targets});

  final ProfileDraft draft;
  final HealthTargets targets;

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        draft: ProfileDraft(
          age: json['age'] as int,
          gender: Gender.values.byName(json['gender'] as String),
          heightCm: (json['height_cm'] as num).toDouble(),
          weightKg: (json['weight_kg'] as num).toDouble(),
          activityLevel:
              ActivityLevelWire.fromWire(json['activity_level'] as String),
          sleepTime: json['sleep_time'] as String,
          wakeTime: json['wake_time'] as String,
        ),
        targets:
            HealthTargets.fromJson(json['targets'] as Map<String, dynamic>),
      );
}
