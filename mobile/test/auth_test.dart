import 'package:aimedic/features/auth/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:aimedic/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpAuth(WidgetTester tester) async {
  await tester.pumpWidget(const MaterialApp(
    locale: Locale('vi'),
    localizationsDelegates: [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [Locale('vi'), Locale('en')],
    home: AuthScreen(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('login form validates before touching Firebase',
      (tester) async {
    await pumpAuth(tester);

    // Empty submit → both required errors, no crash (Firebase absent).
    await tester.tap(find.text('Đăng nhập').last);
    await tester.pumpAndSettle();
    expect(find.text('Vui lòng nhập thông tin này'), findsNWidgets(2));

    // Bad email + short password.
    await tester.enterText(find.byType(TextFormField).first, 'not-an-email');
    await tester.enterText(find.byType(TextFormField).last, '123');
    await tester.tap(find.text('Đăng nhập').last);
    await tester.pumpAndSettle();
    expect(find.text('Email chưa hợp lệ.'), findsOneWidget);
    expect(find.text('Mật khẩu cần ít nhất 6 ký tự.'), findsOneWidget);
  });

  testWidgets('register mode adds confirm field and checks mismatch',
      (tester) async {
    await pumpAuth(tester);

    await tester.tap(find.text('Chưa có tài khoản? Đăng ký'));
    await tester.pumpAndSettle();
    expect(find.text('Tạo tài khoản'), findsOneWidget);

    await tester.enterText(
        find.byType(TextFormField).at(0), 'test@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different');
    await tester.tap(find.text('Đăng ký'));
    await tester.pumpAndSettle();
    expect(find.text('Mật khẩu nhập lại chưa khớp.'), findsOneWidget);
  });
}
