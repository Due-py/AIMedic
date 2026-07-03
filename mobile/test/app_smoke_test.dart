import 'package:aimedic/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app boots with Vietnamese home screen and navigation',
      (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AimedicApp()));
    await tester.pumpAndSettle();

    expect(find.text('AIMedic'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Trang chủ'), findsOneWidget);
    expect(find.text('Trợ lý AI'), findsOneWidget);
  });
}
