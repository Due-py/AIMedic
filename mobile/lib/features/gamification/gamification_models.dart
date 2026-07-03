// Mirrors backend/app/features/gamification/rules.py.

class Badge {
  const Badge({required this.id, required this.earned});

  final String id;
  final bool earned;

  factory Badge.fromJson(Map<String, dynamic> json) =>
      Badge(id: json['id'] as String, earned: json['earned'] as bool);
}

class GamificationState {
  const GamificationState({
    required this.xp,
    required this.level,
    required this.xpIntoLevel,
    required this.xpPerLevel,
    required this.streakDays,
    required this.badges,
  });

  final int xp;
  final int level;
  final int xpIntoLevel;
  final int xpPerLevel;
  final int streakDays;
  final List<Badge> badges;

  factory GamificationState.fromJson(Map<String, dynamic> json) =>
      GamificationState(
        xp: json['xp'] as int,
        level: json['level'] as int,
        xpIntoLevel: json['xp_into_level'] as int,
        xpPerLevel: json['xp_per_level'] as int,
        streakDays: json['streak_days'] as int,
        badges: (json['badges'] as List<dynamic>)
            .map((e) => Badge.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
