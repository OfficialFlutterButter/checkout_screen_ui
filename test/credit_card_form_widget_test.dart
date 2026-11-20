import 'package:checkout_screen_ui/credit_form/credit_card_form.dart';
import 'package:checkout_screen_ui/models/card_form_results.dart';
import 'package:checkout_screen_ui/ui_components/pay_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('typed Visa number submits', (tester) async {
    final results = await _fill(tester, card: '4242424242424242');
    _expectPayload(results, card: '4242424242424242');
    expect(find.text('4242 4242 4242 4242'), findsOneWidget);
  });

  testWidgets('typed Amex number submits', (tester) async {
    final results = await _fill(tester, card: '378282246310005');
    _expectPayload(results, card: '378282246310005');
    expect(find.text('3782 822463 10005'), findsOneWidget);
  });

  testWidgets('pasted Visa number submits', (tester) async {
    final results = await _fill(
      tester,
      card: '4242424242424242',
      typeCharByChar: false,
    );
    _expectPayload(results, card: '4242424242424242');
    expect(find.text('4242 4242 4242 4242'), findsOneWidget);
  });

  testWidgets('typed Diners 14-digit number submits', (tester) async {
    final results = await _fill(tester, card: '36227206271667');
    _expectPayload(results, card: '36227206271667');
    expect(find.text('3622 7206 2716 67'), findsOneWidget);
  });

  testWidgets('multi-dot email submits', (tester) async {
    final results = await _fill(
      tester,
      card: '4242424242424242',
      email: 'wes@mail.example.com',
    );
    _expectPayload(
      results,
      card: '4242424242424242',
      email: 'wes@mail.example.com',
    );
  });

  testWidgets("name José O'Brien submits", (tester) async {
    const name = "José O'Brien";
    final results = await _fill(tester, card: '4242424242424242', name: name);
    _expectPayload(results, card: '4242424242424242', name: name);
  });

  testWidgets('name Ann Smith-Jones submits', (tester) async {
    const name = 'Ann Smith-Jones';
    final results = await _fill(tester, card: '4242424242424242', name: name);
    _expectPayload(results, card: '4242424242424242', name: name);
  });

  testWidgets('card, expiry, and CVV disable keyboard learning', (
    tester,
  ) async {
    await _pumpForm(tester, CreditCardForm(onCardPay: (_) {}));
    for (final index in [1, 2, 3]) {
      final field = _textField(tester, index);
      expect(field.enableSuggestions, isFalse);
      expect(field.autocorrect, isFalse);
      expect(field.enableIMEPersonalizedLearning, isFalse);
      expect(field.smartDashesType, SmartDashesType.disabled);
      expect(field.smartQuotesType, SmartQuotesType.disabled);
    }
    expect(_textField(tester, 3).obscureText, isFalse);
  });

  testWidgets('obscureCvv hides the CVV and the default leaves it visible', (
    tester,
  ) async {
    await _pumpForm(
      tester,
      CreditCardForm(onCardPay: (_) {}, obscureCvv: true),
    );
    expect(_textField(tester, 3).obscureText, isTrue);
  });

  testWidgets('payBtnKey updateStatus changes the button', (tester) async {
    final payBtnKey = GlobalKey<CardPayButtonState>();
    await _pumpForm(
      tester,
      CreditCardForm(onCardPay: (_) {}, payBtnKey: payBtnKey),
    );

    expect(find.text('Pay'), findsOneWidget);

    payBtnKey.currentState!.updateStatus(CardPayButtonStatus.processing);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Pay'), findsNothing);

    payBtnKey.currentState!.updateStatus(CardPayButtonStatus.success);
    await tester.pump();
    expect(find.byIcon(Icons.check_circle), findsOneWidget);

    payBtnKey.currentState!.updateStatus(CardPayButtonStatus.fail);
    await tester.pump();
    expect(find.byIcon(Icons.highlight_remove_rounded), findsOneWidget);
  });

  testWidgets('displayTestData prefills Stripe values in debug', (
    tester,
  ) async {
    expect(kDebugMode, isTrue);
    await _pumpForm(
      tester,
      CreditCardForm(onCardPay: (_) {}, displayTestData: true),
    );
    expect(_fieldText(tester, 0), 'example@example.com');
    expect(_fieldText(tester, 1), '4242 4242 4242 4242');
    expect(_fieldText(tester, 2), _oneYearAheadExpiry());
    expect(_fieldText(tester, 3), '424');
    expect(_fieldText(tester, 4), 'John Doe');
    expect(_fieldText(tester, 5), '42424');
    expect(_fieldText(tester, 6), '555-555-5555');
  });

  testWidgets('displayTestData off leaves the fields empty', (tester) async {
    await _pumpForm(tester, CreditCardForm(onCardPay: (_) {}));
    expect(_fieldText(tester, 0), isEmpty);
    expect(_fieldText(tester, 1), isEmpty);
    expect(_fieldText(tester, 4), isEmpty);
  });
}

void _expectPayload(
  CardFormResults? results, {
  required String card,
  String email = 'a@b.com',
  String name = 'John Doe',
}) {
  expect(results, isNotNull);
  final paid = results!;
  expect(paid.cardNumber, card);
  expect(paid.cardNumber, isNot(contains(' ')));
  expect(paid.cardExpiry, '12/30');
  expect(paid.expMonth, 12);
  expect(paid.expYear, 2030);
  expect(paid.cardSec, '123');
  expect(paid.email, email);
  expect(paid.name, name);
  expect(paid.country, 'United States');
  expect(paid.zip, '12345');
  expect(paid.phone, '+15555555555');
}

Future<CardFormResults?> _fill(
  WidgetTester tester, {
  required String card,
  String exp = '12/30',
  String cvv = '123',
  String email = 'a@b.com',
  String name = 'John Doe',
  bool typeCharByChar = true,
}) async {
  CardFormResults? got;
  await _pumpForm(
    tester,
    CreditCardForm(onCardPay: (results) => got = results),
  );

  final fields = find.byType(TextFormField);

  Future<void> type(int index, String value) async {
    final finder = fields.at(index);
    await tester.ensureVisible(finder);
    if (!typeCharByChar) {
      await tester.enterText(finder, value);
      await tester.pump();
      return;
    }
    for (final ch in value.split('')) {
      final current = tester.widget<TextFormField>(finder).controller!.text;
      await tester.enterText(finder, '$current$ch');
      await tester.pump();
    }
  }

  await type(0, email);
  await type(1, card);
  await type(2, exp.replaceAll('/', ''));
  await type(3, cvv);
  await type(4, name);
  await type(5, '12345');
  await type(6, '5555555555');

  await tester.ensureVisible(find.byType(ElevatedButton));
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  expect(find.text('Enter a valid card number'), findsNothing);
  expect(find.text('Enter a valid name'), findsNothing);
  expect(find.text('Invalid'), findsNothing);
  return got;
}

Future<void> _pumpForm(WidgetTester tester, CreditCardForm form) async {
  tester.view.physicalSize = const Size(1200, 3000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: form)),
    ),
  );
}

TextField _textField(WidgetTester tester, int index) {
  return tester.widget<TextField>(
    find.descendant(
      of: find.byType(TextFormField).at(index),
      matching: find.byType(TextField),
    ),
  );
}

String _fieldText(WidgetTester tester, int index) {
  return tester
      .widget<TextFormField>(find.byType(TextFormField).at(index))
      .controller!
      .text;
}

String _oneYearAheadExpiry() {
  final now = DateTime.now();
  final next = DateTime(now.year + 1, now.month, 1);
  final mm = next.month.toString().padLeft(2, '0');
  final yy = (next.year % 100).toString().padLeft(2, '0');
  return '$mm/$yy';
}
