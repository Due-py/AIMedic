// Mirrors backend/app/features/tracking/schemas.py.

class DailyLog {
  const DailyLog({
    required this.date,
    this.waterMl = 0,
    this.sleepHours,
    this.exerciseMinutes = 0,
    this.screenTimeMinutes,
    this.mood,
    this.stress,
    this.steps = 0,
    this.meals = const [],
  });

  final String date; // "YYYY-MM-DD"
  final int waterMl;
  final double? sleepHours;
  final int exerciseMinutes;
  final int? screenTimeMinutes;
  final int? mood; // 1-5
  final int? stress; // 1-5
  final int steps;
  final List<String> meals;

  factory DailyLog.fromJson(Map<String, dynamic> json) => DailyLog(
        date: json['date'] as String,
        waterMl: json['water_ml'] as int? ?? 0,
        sleepHours: (json['sleep_hours'] as num?)?.toDouble(),
        exerciseMinutes: json['exercise_minutes'] as int? ?? 0,
        screenTimeMinutes: json['screen_time_minutes'] as int?,
        mood: json['mood'] as int?,
        stress: json['stress'] as int?,
        steps: json['steps'] as int? ?? 0,
        meals: (json['meals'] as List<dynamic>?)?.cast<String>() ?? const [],
      );
}

/// Only the fields being logged right now; null fields are left untouched.
class DailyLogPatch {
  const DailyLogPatch({
    this.waterMl,
    this.sleepHours,
    this.exerciseMinutes,
    this.screenTimeMinutes,
    this.mood,
    this.stress,
    this.steps,
    this.meals,
  });

  final int? waterMl;
  final double? sleepHours;
  final int? exerciseMinutes;
  final int? screenTimeMinutes;
  final int? mood;
  final int? stress;
  final int? steps;
  final List<String>? meals;

  Map<String, dynamic> toJson() => {
        if (waterMl != null) 'water_ml': waterMl,
        if (sleepHours != null) 'sleep_hours': sleepHours,
        if (exerciseMinutes != null) 'exercise_minutes': exerciseMinutes,
        if (screenTimeMinutes != null) 'screen_time_minutes': screenTimeMinutes,
        if (mood != null) 'mood': mood,
        if (stress != null) 'stress': stress,
        if (steps != null) 'steps': steps,
        if (meals != null) 'meals': meals,
      };
}

String isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
