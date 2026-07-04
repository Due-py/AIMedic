import 'package:aimedic/core/router.dart';
import 'package:aimedic/features/intro/intro_gate.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    IntroGate.seen = false;
    router.go('/');
  });

  tearDown(() => IntroGate.seen = true); // don't leak into other test files

  testWidgets('first launch shows intro; finishing it lands on the app',
      (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
      ],
      child: const AimedicApp(),
    ));
    await tester.pumpAndSettle();

    // Slide 1 visible, home is not.
    expect(find.textContaining('mình là AIMedic'), findsOneWidget);
    expect(find.text('Tạo hồ sơ'), findsNothing);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ghi lại'), findsOneWidget);

    await tester.tap(find.text('Tiếp tục'));
    await tester.pumpAndSettle();
    expect(find.text('Bắt đầu nào!'), findsOneWidget);

    await tester.tap(find.text('Bắt đầu nào!'));
    await tester.pumpAndSettle();

    // Intro completed and persisted; app content is showing (dev mode).
    expect(IntroGate.seen, isTrue);
    expect(find.text('Tạo hồ sơ'), findsOneWidget);
  });

  testWidgets('skip button exits the intro immediately', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
      ],
      child: const AimedicApp(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bỏ qua'));
    await tester.pumpAndSettle();

    expect(IntroGate.seen, isTrue);
    expect(find.text('Tạo hồ sơ'), findsOneWidget);
  });

  testWidgets('intro not shown again once seen', (tester) async {
    IntroGate.seen = true;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        profileRepositoryProvider.overrideWithValue(FakeProfileRepository()),
      ],
      child: const AimedicApp(),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('mình là AIMedic'), findsNothing);
    expect(find.text('Tạo hồ sơ'), findsOneWidget);
  });
}
