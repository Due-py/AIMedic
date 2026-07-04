import 'package:aimedic/core/router.dart';
import 'package:aimedic/features/coach/coach_repository.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<FakeCoachRepository> pumpCoach(WidgetTester tester) async {
  final repo = FakeCoachRepository();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
      coachRepositoryProvider.overrideWithValue(repo),
    ],
    child: const AimedicApp(),
  ));
  await tester.pumpAndSettle();
  router.go('/coach');
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  setUp(() => router.go('/'));

  testWidgets('shows welcome and disclaimer when no history', (tester) async {
    await pumpCoach(tester);

    expect(find.textContaining('Mình là AIMedic'), findsOneWidget);
  });

  testWidgets('sending a message shows user bubble and AI reply',
      (tester) async {
    final repo = await pumpCoach(tester);

    await tester.enterText(find.byType(TextField), 'Làm sao để ngủ ngon?');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Làm sao để ngủ ngon?'), findsOneWidget);
    expect(find.text('Uống đủ nước mỗi ngày nhé!'), findsOneWidget);
    expect(repo.messages.length, 2);
  });

  testWidgets('failed send keeps message and shows error snackbar',
      (tester) async {
    final repo = await pumpCoach(tester);
    repo.failNext = true;

    await tester.enterText(find.byType(TextField), 'Xin chào');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Xin chào'), findsOneWidget); // kept locally
    expect(find.textContaining('Không gửi được'), findsOneWidget);
  });
}
