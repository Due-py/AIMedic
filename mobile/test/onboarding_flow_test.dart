import 'package:aimedic/core/router.dart';
import 'package:aimedic/features/gamification/gamification_repository.dart';
import 'package:aimedic/features/insights/insights_repository.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/features/tracking/tracking_repository.dart';
import 'package:aimedic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<void> pumpApp(WidgetTester tester, FakeProfileRepository repo) async {
  // Home reads today's log, gamification and insights too; stub them so the
  // dashboard renders without touching the network.
  await tester.pumpWidget(ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(repo),
      trackingRepositoryProvider.overrideWithValue(FakeTrackingRepository()),
      gamificationRepositoryProvider
          .overrideWithValue(FakeGamificationRepository()),
      insightsRepositoryProvider.overrideWithValue(FakeInsightsRepository()),
    ],
    child: const AimedicApp(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => router.go('/'));

  testWidgets('home shows create-profile prompt when no profile exists',
      (tester) async {
    await pumpApp(tester, FakeProfileRepository());

    expect(find.text('Tạo hồ sơ'), findsOneWidget);
  });

  testWidgets('onboarding wizard validates and saves, home shows targets',
      (tester) async {
    final repo = FakeProfileRepository();
    await pumpApp(tester, repo);

    await tester.tap(find.text('Tạo hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.text('Bước 1/4'), findsOneWidget);

    // Empty age blocks the step.
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập thông tin này'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '13');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.text('Bước 2/4'), findsOneWidget);

    // Out-of-range height is rejected.
    await tester.enterText(find.byType(TextFormField).first, '20');
    await tester.enterText(find.byType(TextFormField).last, '45');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.text('Giá trị chưa hợp lệ'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, '155');
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.text('Bước 3/4'), findsOneWidget);

    // Default activity level is fine.
    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.text('Bước 4/4'), findsOneWidget);

    await tester.tap(find.text('Hoàn thành'));
    await tester.pumpAndSettle();

    // Saved and back home with personalized targets. The stat cards live
    // below the gradient header, so scroll them into view before asserting.
    expect(repo.stored, isNotNull);
    expect(repo.stored!.draft.age, 13);

    final list = find.byType(Scrollable).first;
    for (final value in ['18.7', '1800', '9–11', '2106']) {
      await tester.scrollUntilVisible(find.text(value), 200,
          scrollable: list);
      expect(find.text(value), findsOneWidget);
    }
  });
}
