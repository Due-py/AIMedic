// Mirrors backend/app/features/challenges/rules.py.

class Challenge {
  const Challenge({
    required this.code,
    required this.name,
    required this.metric,
    required this.goal,
    required this.total,
    required this.myContribution,
    required this.memberCount,
    required this.daysLeft,
  });

  final String code;
  final String name;
  final String metric; // water_ml | steps | logged_days
  final int goal;
  final int total;
  final int myContribution;
  final int memberCount;
  final int daysLeft;

  double get progress => goal == 0 ? 0 : (total / goal).clamp(0.0, 1.0);
  bool get completed => total >= goal;

  factory Challenge.fromJson(Map<String, dynamic> json) => Challenge(
        code: json['code'] as String,
        name: json['name'] as String,
        metric: json['metric'] as String,
        goal: json['goal'] as int,
        total: json['total'] as int,
        myContribution: json['my_contribution'] as int,
        memberCount: json['member_count'] as int,
        daysLeft: json['days_left'] as int,
      );
}
