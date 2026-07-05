import 'package:aimedic/core/router.dart';
import 'package:aimedic/features/classroom/classroom_models.dart';
import 'package:aimedic/features/classroom/classroom_repository.dart';
import 'package:aimedic/features/profile/profile_models.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<FakeClassroomRepository> pumpApp(WidgetTester tester,
    {FakeClassroomRepository? repo}) async {
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
  final classroomRepo = repo ?? FakeClassroomRepository();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(profileRepo),
      classroomRepositoryProvider.overrideWithValue(classroomRepo),
    ],
    child: const AimedicApp(),
  ));
  await tester.pumpAndSettle();
  return classroomRepo;
}

void main() {
  setUp(() => router.go('/'));

  testWidgets('owner sees stats button and share code', (tester) async {
    final repo = FakeClassroomRepository()
      ..classes.add(const ClassInfo(
          code: 'LOP123', name: 'Lớp 7A1', memberCount: 12, isOwner: true));
    await pumpApp(tester, repo: repo);

    await tester.scrollUntilVisible(find.text('Lớp 7A1'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Xem thống kê'), findsOneWidget);
    expect(find.text('Chủ lớp'), findsOneWidget);
    expect(find.textContaining('LOP123'), findsOneWidget);
  });

  testWidgets('member has no stats button', (tester) async {
    final repo = FakeClassroomRepository()
      ..classes.add(const ClassInfo(
          code: 'LOP123', name: 'Lớp 7A1', memberCount: 12, isOwner: false));
    await pumpApp(tester, repo: repo);

    await tester.scrollUntilVisible(find.text('Lớp 7A1'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Xem thống kê'), findsNothing);
  });

  testWidgets('dashboard shows anonymous aggregates', (tester) async {
    final repo = FakeClassroomRepository()
      ..classes.add(const ClassInfo(
          code: 'LOP123', name: 'Lớp 7A1', memberCount: 12, isOwner: true));
    await pumpApp(tester, repo: repo);

    router.push('/class/LOP123/dashboard');
    await tester.pumpAndSettle();

    expect(find.text('Thống kê lớp'), findsOneWidget);
    expect(find.textContaining('ẩn danh'), findsOneWidget);
    expect(find.text('9/12'), findsOneWidget); // active members
    expect(find.text('7.8 giờ'), findsOneWidget);
    expect(find.text('1400 ml'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('2.4/5'), 200,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('2.4/5'), findsOneWidget); // stress
  });

  testWidgets('locked dashboard explains the minimum', (tester) async {
    final repo = FakeClassroomRepository()
      ..classes.add(const ClassInfo(
          code: 'LOP123', name: 'Nhỏ', memberCount: 2, isOwner: true))
      ..dashboardResult = const ClassDashboard(
        code: 'LOP123',
        name: 'Nhỏ',
        memberCount: 2,
        locked: true,
        minMembers: 3,
      );
    await pumpApp(tester, repo: repo);

    router.push('/class/LOP123/dashboard');
    await tester.pumpAndSettle();

    expect(find.textContaining('ít nhất 3 thành viên'), findsOneWidget);
    expect(find.text('1400 ml'), findsNothing);
  });
}
