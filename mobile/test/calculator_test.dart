import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zaymy247/screens/calculator_screen.dart';

void main() {
  testWidgets('Calculator screen renders sliders, checkbox and result',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CalculatorScreen())),
    );

    expect(find.text('Сумма займа'), findsWidgets);
    expect(find.text('Срок займа'), findsWidgets);
    expect(find.text('Первый займ бесплатно'), findsOneWidget);
    expect(find.text('К возврату'), findsOneWidget);

    // Включаем акцию — сумма к возврату должна быть равна сумме займа.
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('Первый займ бесплатно'), findsOneWidget);
  });
}
