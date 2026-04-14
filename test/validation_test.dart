import 'package:checkout_screen_ui/credit_form/validation.dart';
import 'package:checkout_screen_ui/models/card_form_results.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreditNumberSubmitRegexValidator', () {
    final v = CreditNumberSubmitRegexValidator();

    test('accepts 16-digit grouped PAN', () {
      expect(v.isValid('4242 4242 4242 4242'), isTrue);
    });

    test('accepts Amex 15-digit grouped PAN with prefix', () {
      expect(v.isValid('3782 822463 10005'), isTrue);
    });

    test('rejects Amex-shaped groups with wrong prefix', () {
      expect(v.isValid('1234 123456 12345'), isFalse);
    });

    test('rejects incomplete PAN', () {
      expect(v.isValid('4242 4242 4242'), isFalse);
    });
  });

  group('CreditExpirySubmitRegexValidator', () {
    final v = CreditExpirySubmitRegexValidator();

    test('accepts MM/YY with slash', () {
      expect(v.isValid('01/26'), isTrue);
      expect(v.isValid('12/99'), isTrue);
    });

    test('rejects invalid month', () {
      expect(v.isValid('13/26'), isFalse);
      expect(v.isValid('00/26'), isFalse);
    });

    test('rejects missing slash', () {
      expect(v.isValid('0126'), isFalse);
    });
  });

  group('isCreditExpiryOnOrAfterMonth', () {
    final at = DateTime(2026, 4, 13);

    test('accepts expiry in current month and year', () {
      expect(isCreditExpiryOnOrAfterMonth('04/26', at: at), isTrue);
    });

    test('rejects expiry before current month same year', () {
      expect(isCreditExpiryOnOrAfterMonth('03/26', at: at), isFalse);
    });

    test('rejects expiry in a prior year', () {
      expect(isCreditExpiryOnOrAfterMonth('04/25', at: at), isFalse);
    });

    test('accepts later month same year', () {
      expect(isCreditExpiryOnOrAfterMonth('12/26', at: at), isTrue);
    });

    test('rejects invalid format', () {
      expect(isCreditExpiryOnOrAfterMonth('4/26', at: at), isFalse);
    });
  });

  group('isLikelyAmexCardDigits', () {
    test('detects 34 and 37 prefixes', () {
      expect(isLikelyAmexCardDigits('34'), isTrue);
      expect(isLikelyAmexCardDigits('378282246310005'), isTrue);
      expect(isLikelyAmexCardDigits('4242424242424242'), isFalse);
    });
  });

  test('CardFormResults.toString is full in debug, redacted otherwise', () {
    const r = CardFormResults(
      email: 'buyer@example.com',
      cardNumber: '4242424242424242',
      cardExpiry: '12/34',
      cardSec: '123',
      name: 'Jane Doe',
      country: 'US',
      zip: '90210',
      phone: '+15555555555',
    );
    final s = r.toString();
    if (kDebugMode) {
      expect(s, contains('4242424242424242'));
      expect(s, contains('buyer@example.com'));
      expect(s, isNot(contains('redacted')));
    } else {
      expect(s, contains('redacted'));
      expect(s, isNot(contains('4242424242424242')));
    }
  });
}
