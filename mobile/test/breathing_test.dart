import 'package:aimedic/features/wellness/breathing_screen.dart';
import 'package:aimedic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpBreathing(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    locale: Locale('vi'),
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [Locale('vi'), Locale('en')],
    home: BreathingScreen(),
  ));
  await tester.pump();
}

void main() {
  testWidgets('guides through inhale → hold → exhale phases', (tester) async {
    await pumpBreathing(tester);

    expect(find.text('Góc bình yên'), findsOneWidget);
    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    expect(find.text('Hít vào...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Giữ hơi...'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    expect(find.text('Thở ra...'), findsOneWidget);

    // Stop cancels the session cleanly.
    await tester.tap(find.text('Dừng lại'));
    await tester.pump();
    expect(find.text('Bắt đầu'), findsOneWidget);
  });

  testWidgets('completing the session shows the done message', (tester) async {
    await pumpBreathing(tester);

    await tester.tap(find.text('Bắt đầu'));
    await tester.pump();
    // 1-minute session: advance past the end.
    for (var i = 0; i < 61; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    expect(find.textContaining('Tuyệt vời'), findsOneWidget);
  });
}
