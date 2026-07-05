// Mirrors backend/app/features/classrooms/rules.py.

class ClassInfo {
  const ClassInfo({
    required this.code,
    required this.name,
    required this.memberCount,
    required this.isOwner,
  });

  final String code;
  final String name;
  final int memberCount;
  final bool isOwner;

  factory ClassInfo.fromJson(Map<String, dynamic> json) => ClassInfo(
        code: json['code'] as String,
        name: json['name'] as String,
        memberCount: json['member_count'] as int,
        isOwner: json['is_owner'] as bool,
      );
}

class ClassDashboard {
  const ClassDashboard({
    required this.code,
    required this.name,
    required this.memberCount,
    required this.locked,
    required this.minMembers,
    this.activeMembers,
    this.avgSleepHours,
    this.avgWaterMl,
    this.avgSteps,
    this.avgExerciseMinutes,
    this.avgMood,
    this.avgStress,
  });

  final String code;
  final String name;
  final int memberCount;
  final bool locked;
  final int minMembers;
  final int? activeMembers;
  final double? avgSleepHours;
  final int? avgWaterMl;
  final int? avgSteps;
  final int? avgExerciseMinutes;
  final double? avgMood;
  final double? avgStress;

  factory ClassDashboard.fromJson(Map<String, dynamic> json) => ClassDashboard(
        code: json['code'] as String,
        name: json['name'] as String,
        memberCount: json['member_count'] as int,
        locked: json['locked'] as bool,
        minMembers: json['min_members'] as int,
        activeMembers: json['active_members'] as int?,
        avgSleepHours: (json['avg_sleep_hours'] as num?)?.toDouble(),
        avgWaterMl: json['avg_water_ml'] as int?,
        avgSteps: json['avg_steps'] as int?,
        avgExerciseMinutes: json['avg_exercise_minutes'] as int?,
        avgMood: (json['avg_mood'] as num?)?.toDouble(),
        avgStress: (json['avg_stress'] as num?)?.toDouble(),
      );
}
