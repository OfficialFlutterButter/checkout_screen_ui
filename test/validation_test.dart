import 'package:checkout_screen_ui/credit_form/validation.dart';
import 'package:checkout_screen_ui/models/card_form_results.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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

    test('accepts brand numbers grouped or as digits', () {
      const numbers = <String, String>{
        '4242424242424242': '4242 4242 4242 4242',
        '4222222222222': '4222 2222 2222 2',
        '4000000000000000006': '4000 0000 0000 0000 006',
        '5555555555554444': '5555 5555 5555 4444',
        '378282246310005': '3782 822463 10005',
        '6011111111111117': '6011 1111 1111 1117',
        '36227206271667': '3622 7206 2716 67',
        '3056930009020004': '3056 9300 0902 0004',
        '3566002020360505': '3566 0020 2036 0505',
        '6200000000000005': '6200 0000 0000 0005',
        '900000000001': '9000 0000 0001',
      };
      for (final entry in numbers.entries) {
        expect(v.isValid(entry.key), isTrue, reason: entry.key);
        expect(v.isValid(entry.value), isTrue, reason: entry.value);
        expect(
          CardNumberInputFormatter()
              .formatEditUpdate(_end(''), _end(entry.key))
              .text,
          entry.value,
          reason: entry.key,
        );
      }
    });

    test('rejects a 16-digit Visa that fails Luhn', () {
      expect(v.isValid('4242 4242 4242 4241'), isFalse);
      expect(luhnValid('4242424242424241'), isFalse);
      expect(luhnValid('4242424242424242'), isTrue);
    });

    test('rejects Visa lengths other than 13, 16, and 19', () {
      expect(v.isValid('400000000002'), isFalse);
      expect(v.isValid('400000000000006'), isFalse);
    });

    test('rejects 15-digit JCB', () {
      expect(v.isValid('350000000000006'), isFalse);
    });

    test('rejects digits mixed with other separators', () {
      expect(v.isValid('4242-4242-4242-4242'), isFalse);
    });
  });

  group('card number display helpers', () {
    test('Amex helper uses 4-6-5', () {
      expect(
        FormValidator.getDisplayAmexNumberFormat('378282246310005'),
        '3782 822463 10005',
      );
    });

    test('non-Amex helper groups 19 digits in fours', () {
      expect(
        FormValidator.getDisplayCreditNumberFormat('4000000000000000006'),
        '4000 0000 0000 0000 006',
      );
    });
  });

  group('MaskedTextInputFormatter', () {
    final card = MaskedTextInputFormatter(
      mask: 'xxxx xxxx xxxx xxxx',
      separator: ' ',
    );
    final exp = MaskedTextInputFormatter(mask: 'xx/xx', separator: '/');
    final phone = MaskedTextInputFormatter(
      mask: 'xxx-xxx-xxxx',
      separator: '-',
    );
    final zip = MaskedTextInputFormatter(mask: 'xxxxx', separator: '');

    test('formats a pasted card number, expiry, and phone number', () {
      expect(
        card.formatEditUpdate(_end(''), _end('4242424242424242')).text,
        '4242 4242 4242 4242',
      );
      expect(exp.formatEditUpdate(_end(''), _end('1230')).text, '12/30');
      expect(
        phone.formatEditUpdate(_end(''), _end('2345678901')).text,
        '234-567-8901',
      );
    });

    test('strips non-digits', () {
      expect(card.formatEditUpdate(_end(''), _end('abcd')).text, '');
      expect(zip.formatEditUpdate(_end(''), _end('90a210')).text, '90210');
      expect(
        card.formatEditUpdate(_end(''), _end('4242-4242-4242-4242')).text,
        '4242 4242 4242 4242',
      );
    });

    test('inserts in the middle and keeps the cursor on that digit', () {
      final result = card.formatEditUpdate(
        _end('4242 4242'),
        const TextEditingValue(
          text: '42942 4242',
          selection: TextSelection.collapsed(offset: 3),
        ),
      );
      expect(result.text, '4294 2424 2');
      expect(result.selection.extentOffset, 3);
    });

    test('backspace on a separator deletes the digit before it', () {
      final result = card.formatEditUpdate(
        _at('4242 4242', 5),
        _at('42424242', 4),
      );
      expect(result.text, '4244 242');
      expect(result.selection.extentOffset, 3);
    });

    test('forward delete on a separator deletes the following digit', () {
      final result = card.formatEditUpdate(
        _at('4242 4242', 4),
        _at('42424242', 4),
      );
      expect(result.text, '4242 242');
      expect(result.selection.extentOffset, 4);
    });

    test('deletes a digit in the middle without sticking', () {
      final result = card.formatEditUpdate(
        _at('4242 4242', 3),
        _at('422 4242', 2),
      );
      expect(result.text, '4224 242');
      expect(result.selection.extentOffset, 2);
    });

    test('caps the field at the mask length', () {
      expect(
        card.formatEditUpdate(_end(''), _end('42424242424242429')).text,
        '4242 4242 4242 4242',
      );
      expect(zip.formatEditUpdate(_end('90210'), _end('902106')).text, '90210');
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

  group('EmailSubmitRegexValidator', () {
    final v = EmailSubmitRegexValidator();
    final form = FormValidator();

    test('accepts multi-dot domains and a tagged local part', () {
      for (final email in [
        'a@b.com',
        'wes@mail.example.com',
        'a@b.co.uk',
        'first.last+tag@sub.domain.io',
        '  a@b.com  ',
      ]) {
        expect(v.isValid(email), isTrue, reason: email);
        expect(form.validateEmail(email), isNull, reason: email);
      }
    });

    test('rejects incomplete addresses', () {
      for (final email in ['a@b', 'a@.com', '@b.com', 'a b@c.com', '   ']) {
        expect(v.isValid(email), isFalse, reason: email);
      }
      expect(form.validateEmail('a@b'), 'Invalid Email');
      expect(form.validateEmail('   '), 'Entry Required');
    });
  });

  group('CreditNameSubmitRegexValidator', () {
    final v = CreditNameSubmitRegexValidator();
    final form = FormValidator();

    test(
      'accepts accents, apostrophes, hyphens, periods, and Han characters',
      () {
        for (final name in [
          'John Doe',
          'José Núñez',
          "O'Brien",
          'Mary-Jane Smith',
          'John Doe Jr.',
          '李小龙',
          '  José  ',
        ]) {
          expect(v.isValid(name), isTrue, reason: name);
          expect(form.validateName(name), isNull, reason: name);
        }
      },
    );

    test('rejects empty, digits, and markup', () {
      for (final name in ['', '   ', '12345', '<script>']) {
        expect(v.isValid(name), isFalse, reason: name);
      }
      expect(form.validateName(''), 'Entry Required');
      expect(form.validateName('   '), 'Entry Required');
      expect(form.validateName('12345'), 'Invalid Name');
      expect(form.validateName('A' * 100), isNull);
      expect(form.validateName('A' * 101), 'Maximum of 100 characters');
      expect(v.isValid('A' * 101), isFalse);
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

TextEditingValue _end(String text) {
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
}

TextEditingValue _at(String text, int offset) {
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: offset),
  );
}
