import 'package:flutter/services.dart';

class FormValidator {
  String? validateEmail(String input) {
    const pattern = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
    final regExp = RegExp(pattern);

    if (input.isEmpty) {
      return 'Entry Required';
    } else if (!regExp.hasMatch(input)) {
      return 'Invalid Email';
    } else {
      return null;
    }
  }

  String? validateName(String input) {
    const pattern = r'(^[a-zA-Z]{1,35}$)';
    final regExp = RegExp(pattern);

    if (input.isEmpty) {
      return 'Entry Required';
    } else if (input.length > 35) {
      return 'Maximum of 35 characters';
    } else if (!regExp.hasMatch(input)) {
      return 'Only alpha characters accepted';
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
    // amex   4-6-5

    input = input.replaceAll(RegExp("[^\\d]"), "");
    if (input.length >= 4) {
      input = '${input.substring(0, 4)} ${input.substring(4)}';
    }
    if (input.length >= 11) {
      input = '${input.substring(0, 9)} ${input.substring(9)}';
    }
    if (input.length >= 18) {
      input = input.substring(0, 18);
    }
    return input;
  }

  static String getDisplayCreditNumberFormat(String input) {
    // visa   4-4-4-4
    // disc   4-4-4-4
    // master 4-4-4-4
    // diners 4-4-4-4
    // jcb    4-4-4-4
    // union  4-4-4-4

    input = input.replaceAll(RegExp("[^\\d]"), "");
    if (input.length >= 4) {
      input = '${input.substring(0, 4)} ${input.substring(4)}';
    }
    if (input.length >= 9) {
      input = '${input.substring(0, 9)} ${input.substring(9)}';
    }
    if (input.length >= 14) {
      input = '${input.substring(0, 14)} ${input.substring(14)}';
    }
    if (input.length >= 19) {
      input = input.substring(0, 19);
    }
    return input;
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
      TextEditingValue oldValue, TextEditingValue newValue) {
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
                "^[a-zA-Z0-9_.+-]*(@([a-zA-Z0-9-]*(\\.[a-zA-Z0-9-]*)?)?)?\$");
}

class EmailSubmitRegexValidator extends RegexValidator {
  EmailSubmitRegexValidator()
      : super(
            regexSource: "(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\\.[a-zA-Z0-9-]+\$)");
}

class PhoneSubmitRegexValidator extends RegexValidator {
  PhoneSubmitRegexValidator()
      : super(
            regexSource:
                r'(^\s*(?:\+?(\d{1,3}))?[-. (]*(\d{3})[-. )]*(\d{3})[-. ]*(\d{4})(?: *x(\d+))?\s*$)');
}

/// Returns true when digits-only input is consistent with an Amex PAN prefix.
bool isLikelyAmexCardDigits(String digitsOnly) {
  return digitsOnly.startsWith('34') || digitsOnly.startsWith('37');
}

/// Visa/MC-style 16-digit groups (4-4-4-4) or Amex 15-digit (4-6-5), spaces included.
class CreditNumberSubmitRegexValidator implements StringValidator {
  CreditNumberSubmitRegexValidator();

  static final RegExp _pan16 = RegExp(r'^\d{4} \d{4} \d{4} \d{4}$');
  static final RegExp _amex15 = RegExp(r'^\d{4} \d{6} \d{5}$');

  @override
  bool isValid(String value) {
    final trimmed = value.trim();
    if (_pan16.hasMatch(trimmed)) {
      return true;
    }
    if (_amex15.hasMatch(trimmed)) {
      final digits = trimmed.replaceAll(RegExp(r'\D'), '');
      return isLikelyAmexCardDigits(digits);
    }
    return false;
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

class CreditNameSubmitRegexValidator extends RegexValidator {
  CreditNameSubmitRegexValidator() : super(regexSource: r'^[a-zA-Z\s]*$');
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

class MaskedTextInputFormatter extends TextInputFormatter {
  final String mask;
  final String separator;

  MaskedTextInputFormatter({
    required this.mask,
    required this.separator,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      if (newValue.text.length > oldValue.text.length) {
        if (newValue.text.length > mask.length) return oldValue;
        if (newValue.text.length < mask.length &&
            mask[newValue.text.length - 1] == separator) {
          return TextEditingValue(
            text:
                '${oldValue.text}$separator${newValue.text.substring(newValue.text.length - 1)}',
            selection: TextSelection.collapsed(
              offset: newValue.selection.end + 1,
            ),
          );
        }
      }
    }
    return newValue;
  }
}
