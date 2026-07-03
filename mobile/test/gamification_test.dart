import 'package:aimedic/core/router.dart';
import 'package:aimedic/features/gamification/gamification_repository.dart';
import 'package:aimedic/features/profile/profile_models.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

void main() {
  setUp(() => router.go('/'));

  testWidgets('home shows level, XP, streak and badges', (tester) async {
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
        gamificationRepositoryProvider
            .overrideWithValue(FakeGamificationRepository()),
      ],
      child: const AimedicApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Cấp 1'), findsOneWidget);
    expect(find.text('45/100 XP'), findsOneWidget);
    expect(find.text('3 ngày liên tiếp'), findsOneWidget);
    expect(find.text('Chuỗi 3 ngày'), findsOneWidget);
    expect(find.text('Chuỗi 7 ngày'), findsOneWidget); // shown but unearned
  });
}
