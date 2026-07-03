import 'package:aimedic/core/router.dart';
import 'package:aimedic/features/insights/insights_repository.dart';
import 'package:aimedic/features/profile/profile_models.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<void> pumpHome(
    WidgetTester tester, FakeInsightsRepository insights) async {
  final profileRepo = FakeProfileRepository();
  await profileRepo.save(const ProfileDraft(
    age: 13,
    gender: Gender.male,
    heightCm: 155,
    weightKg: 45,
    activityLevel: ActivityLevel.moderate,
    sleepTime: '22:00',
    wakeTime: '06:30',
  ));
  await tester.pumpWidget(ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(profileRepo),
      insightsRepositoryProvider.overrideWithValue(insights),
    ],
    child: const AimedicApp(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => router.go('/'));

  testWidgets('insight messages rendered with values', (tester) async {
    final repo = FakeInsightsRepository()
      ..insights = const [
        Insight(id: 'sleep_debt', level: 'warn', value: 6.8),
        Insight(id: 'water_good', level: 'positive', value: 1900),
        Insight(id: 'high_stress', level: 'warn'),
      ];
    await pumpHome(tester, repo);

    expect(find.text('Nhận xét tuần này'), findsOneWidget);
    expect(find.textContaining('6.8 giờ'), findsOneWidget);
    expect(find.textContaining('1900 ml'), findsOneWidget);
    expect(find.textContaining('hít thở sâu'), findsOneWidget);
  });

  testWidgets('card hidden when there are no insights yet', (tester) async {
    await pumpHome(tester, FakeInsightsRepository());

    expect(find.text('Nhận xét tuần này'), findsNothing);
  });

  testWidgets('unknown insight id from newer backend is skipped',
      (tester) async {
    final repo = FakeInsightsRepository()
      ..insights = const [
        Insight(id: 'brand_new_rule', level: 'info'),
        Insight(id: 'low_exercise', level: 'info'),
      ];
    await pumpHome(tester, repo);

    expect(find.textContaining('vận động khá ít'), findsOneWidget);
  });
}
