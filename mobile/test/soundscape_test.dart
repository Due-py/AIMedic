import 'package:aimedic/features/wellness/soundscape_screen.dart';
import 'package:aimedic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpSounds(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    locale: Locale('vi'),
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [Locale('vi'), Locale('en')],
    home: SoundscapeScreen(),
  ));
  await tester.pump();
}

void main() {
  testWidgets('shows four sounds and timer chips', (tester) async {
    await pumpSounds(tester);

    expect(find.text('Mưa rơi'), findsOneWidget);
    expect(find.text('Sóng biển'), findsOneWidget);
    expect(find.text('Gió nhẹ'), findsOneWidget);
    expect(find.text('Suối chảy'), findsOneWidget);
    expect(find.text('Không hẹn giờ'), findsOneWidget);
    expect(find.text('20 phút'), findsOneWidget);
  });

  testWidgets('tapping a sound toggles its active state', (tester) async {
    await pumpSounds(tester);

    // The audio plugin is unavailable in tests; the UI state must still
    // toggle because playback errors are swallowed.
    await tester.tap(find.text('Mưa rơi'));
    await tester.pump();
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsOneWidget);

    await tester.tap(find.text('Mưa rơi'));
    await tester.pump();
    expect(find.byIcon(Icons.pause_circle_filled_rounded), findsNothing);
  });
}
