import 'package:aimedic/core/router.dart';
import 'package:aimedic/features/challenges/challenge_repository.dart';
import 'package:aimedic/features/profile/profile_models.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<FakeChallengeRepository> pumpHome(WidgetTester tester) async {
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
  final repo = FakeChallengeRepository();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(profileRepo),
      challengeRepositoryProvider.overrideWithValue(repo),
    ],
    child: const AimedicApp(),
  ));
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  setUp(() => router.go('/'));

  testWidgets('empty state invites the class', (tester) async {
    await pumpHome(tester);
    expect(find.text('Thử thách lớp học'), findsOneWidget);
    expect(find.textContaining('mục tiêu chung'), findsOneWidget);
  });

  testWidgets('joining by code shows team progress', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Nhập mã'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'ABC123');
    await tester.tap(find.text('Nhập mã').last);
    await tester.pumpAndSettle();

    expect(find.text('Lớp 7A1 uống nước'), findsOneWidget);
    expect(find.text('4500 / 10000'), findsOneWidget);
    expect(find.textContaining('Phần của bạn: 500'), findsOneWidget);
    expect(find.textContaining('12 thành viên'), findsOneWidget);
  });

  testWidgets('bad code shows error snackbar', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Nhập mã'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'WRONG1');
    await tester.tap(find.text('Nhập mã').last);
    await tester.pumpAndSettle();

    expect(find.textContaining('Không tìm thấy'), findsOneWidget);
  });

  testWidgets('create sheet makes a challenge with share code',
      (tester) async {
    final repo = await pumpHome(tester);

    await tester.tap(find.text('Tạo mới'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), 'Đi bộ cả lớp');
    await tester.enterText(find.byType(TextField).at(1), '100000');
    await tester.tap(find.text('Bước chân'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tạo mới').last);
    await tester.pumpAndSettle();

    expect(repo.challenges.single.name, 'Đi bộ cả lớp');
    expect(repo.challenges.single.metric, 'steps');
    expect(find.text('Đi bộ cả lớp'), findsOneWidget);
    expect(find.textContaining('ABC123'), findsOneWidget); // share code shown
  });
}
