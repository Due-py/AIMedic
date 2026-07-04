import 'package:aimedic/core/router.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/features/tracking/tracking_models.dart';
import 'package:aimedic/features/tracking/tracking_repository.dart';
import 'package:aimedic/features/tracking/weekly_chart.dart';
import 'package:aimedic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

const _today = '2026-07-03';

Future<FakeTrackingRepository> pumpTracking(WidgetTester tester) async {
  final repo = FakeTrackingRepository();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
      trackingRepositoryProvider.overrideWithValue(repo),
      todayDateProvider.overrideWithValue(_today),
    ],
    child: const AimedicApp(),
  ));
  await tester.pumpAndSettle();
  router.go('/tracking');
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  setUp(() => router.go('/'));

  testWidgets('water quick action accumulates and persists', (tester) async {
    final repo = await pumpTracking(tester);

    // No profile in the fake, so the water target defaults to 2000 ml.
    expect(find.text('0 / 2000 ml'), findsOneWidget);

    await tester.tap(find.text('+250 ml'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('+250 ml'));
    await tester.pumpAndSettle();

    expect(find.text('500 / 2000 ml'), findsOneWidget);
    expect(repo.logs[_today]!.waterMl, 500);
  });

  testWidgets('mood tap saves without touching other fields', (tester) async {
    final repo = await pumpTracking(tester);
    await repo.patchDay(_today, const DailyLogPatch(sleepHours: 8));

    // Bring the mood card's own label into view; the emoji row sits just
    // below it, comfortably clear of both viewport edges.
    await tester.scrollUntilVisible(find.text('Tâm trạng'), 150,
        scrollable: find.byType(Scrollable).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('😄'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('😄'));
    await tester.pumpAndSettle();

    expect(repo.logs[_today]!.mood, 5);
    expect(repo.logs[_today]!.sleepHours, 8); // merge, not overwrite
  });

  testWidgets('sleep dialog saves value and weekly chart renders',
      (tester) async {
    final repo = await pumpTracking(tester);
    // Seed some history for the chart window.
    await repo.patchDay('2026-07-01', const DailyLogPatch(waterMl: 1200));
    await repo.patchDay('2026-07-02', const DailyLogPatch(waterMl: 1600));

    final sleepTile = find.text('Giấc ngủ');
    await tester.scrollUntilVisible(sleepTile, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(sleepTile);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, '8.5');
    await tester.tap(find.text('Lưu'));
    await tester.pumpAndSettle();

    expect(repo.logs[_today]!.sleepHours, 8.5);
    expect(find.text('8.5 giờ'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byType(WeeklyChart),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byType(WeeklyChart), findsOneWidget);
  });
}
