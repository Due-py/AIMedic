import 'package:aimedic/core/router.dart';
import 'package:aimedic/features/pet/pet_repository.dart';
import 'package:aimedic/features/profile/profile_models.dart';
import 'package:aimedic/features/profile/profile_repository.dart';
import 'package:aimedic/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

Future<FakePetRepository> pumpHomeWithPet(WidgetTester tester) async {
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
  final petRepo = FakePetRepository();
  await tester.pumpWidget(ProviderScope(
    overrides: [
      profileRepositoryProvider.overrideWithValue(profileRepo),
      petRepositoryProvider.overrideWithValue(petRepo),
    ],
    child: const AimedicApp(),
  ));
  await tester.pumpAndSettle();
  return petRepo;
}

void main() {
  setUp(() => router.go('/'));

  testWidgets('pet card shows companion, mood and coins', (tester) async {
    await pumpHomeWithPet(tester);

    expect(find.textContaining('Bo'), findsWidgets);
    expect(find.text('🐣'), findsOneWidget); // chick stage
    expect(find.text('12'), findsOneWidget); // coin chip
  });

  testWidgets('shop: buying an accessory equips it and deducts coins',
      (tester) async {
    final repo = await pumpHomeWithPet(tester);

    await tester.tap(find.text('Cửa hàng'));
    await tester.pumpAndSettle();
    expect(find.text('Cửa hàng phụ kiện'), findsOneWidget);

    await tester.tap(find.text('Mua · 10 xu'));
    await tester.pumpAndSettle();

    expect(repo.owned, ['balloon']);
    expect(repo.coins, 2);
    expect(find.text('Đang đeo'), findsOneWidget);
  });

  testWidgets('shop: unaffordable item shows snackbar', (tester) async {
    final repo = await pumpHomeWithPet(tester);

    await tester.tap(find.text('Cửa hàng'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mua · 50 xu')); // crown, only 12 coins
    await tester.pumpAndSettle();

    expect(repo.owned, isEmpty);
    expect(find.textContaining('Chưa đủ xu'), findsOneWidget);
  });
}
