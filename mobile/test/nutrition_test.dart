import 'package:aimedic/features/nutrition/meal_section.dart';
import 'package:aimedic/features/nutrition/nutrition_repository.dart';
import 'package:aimedic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => ProviderScope(
      child: MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('vi'), Locale('en')],
        home: Scaffold(body: child),
      ),
    );

void main() {
  testWidgets('meal section lists logged meals as chips', (tester) async {
    await tester.pumpWidget(_wrap(const MealSection(
      meals: ['Phở bò (~450 kcal)', 'Sữa chua (~120 kcal)'],
    )));

    expect(find.textContaining('Bữa ăn hôm nay'), findsOneWidget);
    expect(find.text('Phở bò (~450 kcal)'), findsOneWidget);
    expect(find.text('Sữa chua (~120 kcal)'), findsOneWidget);
    expect(find.text('Chụp món ăn'), findsOneWidget);
  });

  testWidgets('result sheet shows name, kcal, macros and comment',
      (tester) async {
    await tester.pumpWidget(_wrap(const MealResultSheet(
      analysis: MealAnalysis(
        isFood: true,
        name: 'Bát salad đậu phụ',
        calories: 450,
        proteinG: 25,
        carbsG: 40,
        fatG: 20,
        comment: 'Bữa ăn cân bằng đó!',
      ),
    )));

    expect(find.text('Bát salad đậu phụ'), findsOneWidget);
    expect(find.text('🔥 450 kcal'), findsOneWidget);
    expect(find.text('25 g'), findsOneWidget);
    expect(find.text('Đạm'), findsOneWidget);
    expect(find.text('Bữa ăn cân bằng đó!'), findsOneWidget);
  });

  testWidgets('non-food result shows the friendly message', (tester) async {
    await tester.pumpWidget(_wrap(const MealResultSheet(
      analysis: MealAnalysis(
        isFood: false,
        name: '',
        calories: 0,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
        comment: 'Đây có vẻ là một chiếc bàn học.',
      ),
    )));

    expect(find.textContaining('không phải đồ ăn'), findsOneWidget);
    expect(find.text('Đây có vẻ là một chiếc bàn học.'), findsOneWidget);
  });
}
