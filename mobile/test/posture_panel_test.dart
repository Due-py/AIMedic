import 'package:aimedic/features/posture/posture_rules.dart';
import 'package:aimedic/features/posture/posture_screen.dart';
import 'package:aimedic/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      locale: const Locale('vi'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('vi'), Locale('en')],
      home: Scaffold(body: child),
    );

void main() {
  testWidgets('all-good posture shows praise', (tester) async {
    await tester.pumpWidget(_wrap(const PostureStatusPanel(
      status: PostureStatus(
        detected: true,
        neckStraight: PostureCheck.good,
        shouldersLevel: PostureCheck.good,
        goodDistance: PostureCheck.good,
      ),
    )));

    expect(find.textContaining('Tư thế tuyệt vời'), findsOneWidget);
    expect(find.text('Cổ thẳng'), findsOneWidget);
  });

  testWidgets('bad checks show gentle tips', (tester) async {
    await tester.pumpWidget(_wrap(const PostureStatusPanel(
      status: PostureStatus(
        detected: true,
        neckStraight: PostureCheck.bad,
        shouldersLevel: PostureCheck.good,
        goodDistance: PostureCheck.bad,
      ),
    )));

    expect(find.textContaining('Chỉnh lại'), findsOneWidget);
    expect(find.textContaining('Ngẩng đầu lên'), findsOneWidget);
    expect(find.textContaining('xa màn hình'), findsOneWidget);
  });

  testWidgets('not-detected state asks student into frame', (tester) async {
    await tester.pumpWidget(_wrap(const PostureStatusPanel(
      status: PostureStatus(detected: false),
    )));

    expect(find.textContaining('giữa khung hình'), findsOneWidget);
  });
}
