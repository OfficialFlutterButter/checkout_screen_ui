import 'package:checkout_screen_ui/ui_components/footer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CheckoutPageFooter builds Terms and Privacy actions', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CheckoutPageFooter(
            termsLink: 'https://example.com/terms',
            privacyLink: 'https://example.com/privacy',
            note: 'Note',
            noteLink: 'https://example.com/',
          ),
        ),
      ),
    );

    expect(find.text('Terms'), findsOneWidget);
    expect(find.text('Privacy'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
  });
}
