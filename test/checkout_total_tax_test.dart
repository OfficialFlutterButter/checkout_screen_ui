import 'package:checkout_screen_ui/checkout_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CheckoutPage shows charge amount including tax', (tester) async {
    final items = <PriceItem>[
      PriceItem(name: 'A', quantity: 1, itemCostCents: 1000),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CheckoutPage(
            data: CheckoutData(
              priceItems: items,
              payToName: 'Vendor',
              taxRate: 0.10,
              onCardPay: (results, checkout) {
                expect(results, isA<CardFormResults>());
                expect(checkout, isA<CheckOutResult>());
              },
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.textContaining('11.00'), findsWidgets);
    expect(find.text('Charge Amount '), findsOneWidget);
  });
}
