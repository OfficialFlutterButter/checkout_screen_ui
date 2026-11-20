import 'package:flutter/services.dart';

class FormValidator {
  String? validateEmail(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 'Entry Required';
    } else if (!EmailSubmitRegexValidator().isValid(trimmed)) {
      return 'Invalid Email';
    } else {
      return null;
    }
  }

  String? validateName(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      return 'Entry Required';
    } else if (trimmed.length > _maxCardholderNameLength) {
      return 'Maximum of $_maxCardholderNameLength characters';
    } else if (!CreditNameSubmitRegexValidator().isValid(trimmed)) {
      return 'Invalid Name';
    } else {
      return null;
    }
  }

  String? validatePhone(String input) {
    const pattern = r'(^[0-9]{10}$)'; // 2345678901
    final regExp = RegExp(pattern);
    const pattern2 = r'(^\d{3}-\d{3}-\d{4}$)'; //234-567-8901
    final regExp2 = RegExp(pattern2);

    if (input.isEmpty) {
      return 'Entry Required';
    } else if (input.length > 10) {
      return 'Maximum of 10 digits';
    } else if (!(regExp.hasMatch(input) || regExp2.hasMatch(input))) {
      return 'Only numeric digits accepted';
    } else {
      return null;
    }
  }

  static String getDisplayAmexNumberFormat(String input) {
    // amex 4-6-5, same grouping as [CardTypeRegs.groupDigits]
    final digits = input.replaceAll(RegExp(r'\D'), '');
    final max = CardTypeRegs.maxDigits(CardBrand.amex);
    final capped = digits.length > max ? digits.substring(0, max) : digits;
    return _groupAmex(capped);
  }

  static String getDisplayCreditNumberFormat(String input) {
    // Non-Amex PANs are groups of 4, with a short tail. Up to 19 digits.
    final digits = input.replaceAll(RegExp(r'\D'), '');
    const max = 19;
    final capped = digits.length > max ? digits.substring(0, max) : digits;
    return _groupFours(capped);
  }

  static String getDisplayCreditExpFormat(String input) {
    input = input.replaceAll(RegExp("[^\\d]"), "");

    if (input.isNotEmpty &&
        (input.length == 1) &&
        (input[0] != '0' && input[0] != '1')) {
      input = '0$input';
    }
    if (input.length >= 2) {
      input = '${input.substring(0, 2)}/${input.substring(2)}';
    }
    if (input.length >= 5) {
      input = input.substring(0, 5);
    }
    return input;
  }
}

abstract class StringValidator {
  bool isValid(String value);
}

class RegexValidator implements StringValidator {
  RegexValidator({this.regexSource});
  final String? regexSource;

  /// value: the input string
  /// returns: true if the input string is a full match for regexSource
  @override
  bool isValid(String value) {
    try {
      final regex = RegExp(regexSource!);
      final matches = regex.allMatches(value);
      for (Match match in matches) {
        if (match.start == 0 && match.end == value.length) {
          return true;
        }
      }
      return false;
    } catch (e) {
      // Invalid regex
      assert(false, e.toString());
      return true;
    }
  }
}

class ValidatorInputFormatter implements TextInputFormatter {
  ValidatorInputFormatter({this.editingValidator});
  final StringValidator? editingValidator;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final oldValueValid = editingValidator!.isValid(oldValue.text);
    final newValueValid = editingValidator!.isValid(newValue.text);
    if (oldValueValid && !newValueValid) {
      return oldValue;
    }
    return newValue;
  }
}

class EmailEditingRegexValidator extends RegexValidator {
  EmailEditingRegexValidator()
    : super(
        regexSource:
            "^[a-zA-Z0-9_.+-]*(@([a-zA-Z0-9-]*(\\.[a-zA-Z0-9-]*)?)?)?\$",
      );
}

class EmailSubmitRegexValidator extends RegexValidator {
  EmailSubmitRegexValidator() : super(regexSource: _emailSubmitPattern);

  static final RegExp _regex = RegExp(_emailSubmitPattern);

  @override
  bool isValid(String value) => _regex.hasMatch(value.trim());
}

const String _emailSubmitPattern =
    r"^[A-Za-z0-9._%+'-]+@[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?)+$";

class PhoneSubmitRegexValidator extends RegexValidator {
  PhoneSubmitRegexValidator()
    : super(
        regexSource:
            r'(^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$)',
      );
}

/// Returns true when digits-only input is consistent with an Amex PAN prefix.
bool isLikelyAmexCardDigits(String digitsOnly) {
  return digitsOnly.startsWith('34') || digitsOnly.startsWith('37');
}

/// Card number check driven by [CardTypeRegs]: brand length, then Luhn.
///
/// Accepts digits only, or digits with spaces (the grouped field text).
class CreditNumberSubmitRegexValidator implements StringValidator {
  CreditNumberSubmitRegexValidator();

  static final RegExp _nonDigitOrSpace = RegExp(r'[^\d ]');

  @override
  bool isValid(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || _nonDigitOrSpace.hasMatch(trimmed)) {
      return false;
    }
    final digits = trimmed.replaceAll(' ', '');
    if (digits.isEmpty) {
      return false;
    }
    final brand = CardTypeRegs.findBrand(digits);
    if (!CardTypeRegs.allowsLength(brand, digits.length)) {
      return false;
    }
    return luhnValid(digits);
  }
}

/// Expiration in MM/YY with slash (matches masked field output).
class CreditExpirySubmitRegexValidator extends RegexValidator {
  CreditExpirySubmitRegexValidator()
    : super(regexSource: r'^(0[1-9]|1[0-2])\/(\d{2})$');
}

/// True when [value] is valid MM/YY and the expiry month is still current or in
/// the future relative to [at] (defaults to [DateTime.now]). Cards are treated
/// as valid through the **last day** of the printed month.
///
/// Two-digit years are interpreted as **20YY** (common for payment UIs).
bool isCreditExpiryOnOrAfterMonth(String value, {DateTime? at}) {
  if (!CreditExpirySubmitRegexValidator().isValid(value)) {
    return false;
  }
  final parts = value.split('/');
  final month = int.parse(parts[0], radix: 10);
  final yy = int.parse(parts[1], radix: 10);
  final fullYear = 2000 + yy;
  final now = at ?? DateTime.now();
  if (fullYear > now.year) {
    return true;
  }
  if (fullYear < now.year) {
    return false;
  }
  return month >= now.month;
}

class CreditCvvSubmitRegexValidator extends RegexValidator {
  CreditCvvSubmitRegexValidator() : super(regexSource: r'^[0-9]{3,4}$');
}

const int _maxCardholderNameLength = 100;

class CreditNameSubmitRegexValidator extends RegexValidator {
  CreditNameSubmitRegexValidator() : super();

  static final RegExp _name = RegExp(
    r"^[\p{L}\p{M}][\p{L}\p{M} .,'\u2019-]*$",
    unicode: true,
  );

  @override
  bool isValid(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > _maxCardholderNameLength) {
      return false;
    }
    return _name.hasMatch(trimmed);
  }
}

class AddressLineSubmitRegexValidator extends RegexValidator {
  AddressLineSubmitRegexValidator() : super(regexSource: r'^[a-zA-Z0-9\s]*$');
}

class AddressCitySubmitRegexValidator extends RegexValidator {
  AddressCitySubmitRegexValidator() : super(regexSource: r'^[a-zA-Z\s]*$');
}

class AddressPostalSubmitRegexValidator extends RegexValidator {
  AddressPostalSubmitRegexValidator() : super(regexSource: r'^[0-9]{5}$');
}

class AddressStateSubmitRegexValidator extends RegexValidator {
  AddressStateSubmitRegexValidator() : super(regexSource: r'^[A-Z]{2}$');
}

class PhoneRegexValidator extends RegexValidator {
  PhoneRegexValidator() : super(regexSource: r'^[0-9]{10}$');
}

/// Luhn (mod-10) check. [digits] must be numeric; anything else is invalid.
bool luhnValid(String digits) {
  if (digits.isEmpty) {
    return false;
  }
  var sum = 0;
  var alternate = false;
  for (var i = digits.length - 1; i >= 0; i--) {
    final n = int.tryParse(digits[i]);
    if (n == null) {
      return false;
    }
    var d = n;
    if (alternate) {
      d *= 2;
      if (d > 9) {
        d -= 9;
      }
    }
    sum += d;
    alternate = !alternate;
  }
  return sum % 10 == 0;
}

// ignore: constant_identifier_names
enum CardBrand { n_a, visa, masterCard, discover, amex, diners, jcb, union }

/// Brand prefixes, accepted lengths, and on-screen grouping.
///
/// Prefix order matches the historical [findBrand] checks. Lengths:
/// Visa 13/16/19, Mastercard 16, Amex 15, Discover 16–19, Diners 14–19,
/// JCB 16–19, UnionPay 16–19, unrecognized 12–19. Every accepted number
/// must also pass [luhnValid]. Amex displays as 4-6-5; every other brand
/// displays in groups of 4 with a short tail.
class CardTypeRegs {
  static final RegExp _visa = RegExp(r'^4[0-9]{0,}$');
  static final RegExp _master = RegExp(
    r'^(5[1-5]|222[1-9]|22[3-9]|2[3-6]|27[01]|2720)[0-9]{0,}$',
  );
  static final RegExp _discover = RegExp(
    r'^(6011|65|64[4-9]|62212[6-9]|6221[3-9]|622[2-8]|6229[01]|62292[0-5])[0-9]{0,}$',
  );
  static final RegExp _amex = RegExp(r'^3[47][0-9]{0,}$');
  static final RegExp _diners = RegExp(r'^3(?:0[0-59]{1}|[689])[0-9]{0,}$');
  static final RegExp _jcb = RegExp(r'^(?:2131|1800|35)[0-9]{0,}$');
  static final RegExp _union = RegExp(r'^(62|88)\d+$');

  static CardBrand findBrand(String cardNUmber) {
    if (_visa.matchAsPrefix(cardNUmber) != null) return CardBrand.visa;
    if (_master.matchAsPrefix(cardNUmber) != null) return CardBrand.masterCard;
    if (_discover.matchAsPrefix(cardNUmber) != null) return CardBrand.discover;
    if (_diners.matchAsPrefix(cardNUmber) != null) return CardBrand.diners;
    if (_amex.matchAsPrefix(cardNUmber) != null) return CardBrand.amex;
    if (_jcb.matchAsPrefix(cardNUmber) != null) return CardBrand.jcb;
    if (_union.matchAsPrefix(cardNUmber) != null) return CardBrand.union;
    return CardBrand.n_a;
  }

  /// Most digits the field may hold for [brand] while the number is incomplete.
  static int maxDigits(CardBrand brand) {
    switch (brand) {
      case CardBrand.masterCard:
        return 16;
      case CardBrand.amex:
        return 15;
      case CardBrand.visa:
      case CardBrand.discover:
      case CardBrand.diners:
      case CardBrand.jcb:
      case CardBrand.union:
      case CardBrand.n_a:
        return 19;
    }
  }

  /// True when [length] is a complete PAN length for [brand].
  static bool allowsLength(CardBrand brand, int length) {
    switch (brand) {
      case CardBrand.visa:
        return length == 13 || length == 16 || length == 19;
      case CardBrand.masterCard:
        return length == 16;
      case CardBrand.amex:
        return length == 15;
      case CardBrand.discover:
      case CardBrand.jcb:
      case CardBrand.union:
        return length >= 16 && length <= 19;
      case CardBrand.diners:
        return length >= 14 && length <= 19;
      case CardBrand.n_a:
        return length >= 12 && length <= 19;
    }
  }

  /// Groups [digits] for display. Amex is 4-6-5; everything else is groups of 4.
  static String groupDigits(String digits) {
    if (findBrand(digits) == CardBrand.amex) {
      return _groupAmex(digits);
    }
    return _groupFours(digits);
  }
}

String _groupAmex(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i == 4 || i == 10) {
      buffer.write(' ');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

String _groupFours(String digits) {
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && i % 4 == 0) {
      buffer.write(' ');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

final RegExp _digitChar = RegExp(r'\d');

class _KeptEdit {
  const _KeptEdit(this.raw, this.before);
  final String raw;
  final int before;
}

String _keepChars(String text, RegExp allowedChar) {
  final buffer = StringBuffer();
  for (final rune in text.runes) {
    final ch = String.fromCharCode(rune);
    if (allowedChar.hasMatch(ch)) {
      buffer.write(ch);
    }
  }
  return buffer.toString();
}

int _countKept(String text, int end, RegExp allowedChar) {
  final limit = end < 0 ? 0 : (end > text.length ? text.length : end);
  var count = 0;
  for (var i = 0; i < limit; i++) {
    if (allowedChar.hasMatch(text[i])) {
      count++;
    }
  }
  return count;
}

int _offsetAfterKept(String text, int keptCount, RegExp allowedChar) {
  if (keptCount <= 0) {
    return 0;
  }
  var seen = 0;
  for (var i = 0; i < text.length; i++) {
    if (allowedChar.hasMatch(text[i])) {
      seen++;
      if (seen == keptCount) {
        return i + 1;
      }
    }
  }
  return text.length;
}

/// Rebuilds the kept characters in [newValue].
///
/// A backspace that removes only a separator also drops the kept character
/// before the cursor. A forward delete that removes only a separator drops
/// the kept character after the cursor. Either way the separator is put back
/// by the mask, and the cursor is not stuck on it.
_KeptEdit _keptEdit({
  required TextEditingValue oldValue,
  required TextEditingValue newValue,
  required RegExp allowedChar,
}) {
  final oldRaw = _keepChars(oldValue.text, allowedChar);
  var raw = _keepChars(newValue.text, allowedChar);
  final cursor = newValue.selection.isValid
      ? newValue.selection.extentOffset
      : newValue.text.length;
  var before = _countKept(newValue.text, cursor, allowedChar);

  final separatorOnly =
      raw == oldRaw &&
      newValue.text.length < oldValue.text.length &&
      oldValue.selection.isCollapsed &&
      newValue.selection.isCollapsed &&
      oldValue.selection.isValid;

  if (separatorOnly && raw.isNotEmpty) {
    final movedLeft = cursor < oldValue.selection.extentOffset;
    if (movedLeft) {
      if (before > 0 && before <= raw.length) {
        raw = raw.substring(0, before - 1) + raw.substring(before);
        before -= 1;
      }
    } else if (before < raw.length) {
      raw = raw.substring(0, before) + raw.substring(before + 1);
    }
  }

  return _KeptEdit(raw, before);
}

_KeptEdit _capKept(_KeptEdit edit, int max) {
  if (edit.raw.length <= max) {
    return edit;
  }
  final raw = edit.raw.substring(0, max);
  final before = edit.before > raw.length ? raw.length : edit.before;
  return _KeptEdit(raw, before);
}

int _maskCapacity(String mask, String separator) {
  if (separator.isEmpty) {
    return mask.length;
  }
  var count = 0;
  var m = 0;
  while (m < mask.length) {
    if (mask.startsWith(separator, m)) {
      m += separator.length;
    } else {
      count++;
      m += 1;
    }
  }
  return count;
}

String _applyMask(String raw, String mask, String separator) {
  final out = StringBuffer();
  var i = 0;
  var m = 0;
  while (m < mask.length && i < raw.length) {
    if (separator.isNotEmpty && mask.startsWith(separator, m)) {
      out.write(separator);
      m += separator.length;
    } else {
      out.write(raw[i]);
      i++;
      m += 1;
    }
  }
  return out.toString();
}

TextEditingValue _collapsed(String text, int offset) {
  final safe = offset < 0 ? 0 : (offset > text.length ? text.length : offset);
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: safe),
  );
}

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  /// Characters that occupy a slot in [mask]. Defaults to digits.
  /// Each character of the input is tested on its own.
  final RegExp allowedChars;

  MaskedTextInputFormatter({
    required this.mask,
    required this.separator,
    RegExp? allowedChars,
  }) : allowedChars = allowedChars ?? _digitChar;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final edit = _capKept(
      _keptEdit(
        oldValue: oldValue,
        newValue: newValue,
        allowedChar: allowedChars,
      ),
      _maskCapacity(mask, separator),
    );
    final text = _applyMask(edit.raw, mask, separator);
    return _collapsed(text, _offsetAfterKept(text, edit.before, allowedChars));
  }
}

/// Card-number formatter. Grouping and the digit cap come from [CardTypeRegs]
/// for the digits in this edit, so a pasted Amex number is 4-6-5 immediately.
class CardNumberInputFormatter extends TextInputFormatter {
  const CardNumberInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final kept = _keptEdit(
      oldValue: oldValue,
      newValue: newValue,
      allowedChar: _digitChar,
    );
    final brand = CardTypeRegs.findBrand(kept.raw);
    final edit = _capKept(kept, CardTypeRegs.maxDigits(brand));
    final text = CardTypeRegs.groupDigits(edit.raw);
    return _collapsed(text, _offsetAfterKept(text, edit.before, _digitChar));
  }
}
