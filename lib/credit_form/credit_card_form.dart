import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:text_form_field_wrapper/text_form_field_wrapper.dart';
import '../models/card_form_results.dart';
import '../ui_components/pay_button.dart';
import 'validation.dart';
import 'dart:async';

export 'validation.dart' show CardBrand, CardTypeRegs;

class CreditCardForm extends StatefulWidget {
  /// The CreditCardForm is a stateful widget containing a form and fields
  /// necessary to complete a typical credit card transaction
  const CreditCardForm({
    super.key,
    this.countries = const ['United States'],
    this.initEmail = '',
    this.initBuyerName = '',
    this.initPhone = '',
    this.displayEmail = true,
    this.lockEmail = false,
    required this.onCardPay,
    this.payBtnKey,
    this.formKey,
    this.displayTestData = false,
    this.displayPhone = true,
    this.submitLabel = 'Pay',
    this.zipValidator,
    this.phoneValidator,
    this.emailValidator,
    this.nameValidator,
    this.formatE164Phone,
    this.obscureCvv = false,
  });

  /// If you have a List of Countries that you would like to use to override the
  /// currently provide list of 1, being 'United States', add the list here.
  /// Warning: The credit card form does not currently adjust based on selected
  /// country's needs to verify a card. This form may not work for all countries
  final List<String> countries;

  /// Provide an email if you have it, to prefill the email field on the Credit
  /// Card form
  final String initEmail;

  /// Provide a name if you have it, to prefill the name field on the Credit
  /// Card form
  final String initBuyerName;

  /// Provide a phone number if you have it, to prefill the name field on the
  /// Credit Card form
  final String initPhone;

  /// Should the email box be displayed?
  final bool displayEmail;

  /// Should the email form field be locked? This should only be done if an
  /// [initEmail] is provided
  final bool lockEmail;

  /// Provide a function that receives [CardFormResults] as a parameter that is
  /// to be trigger once the user completes the credit card form and presses
  /// pay
  final Function(CardFormResults) onCardPay;

  /// If you would like to control the pay button state to display text or icons
  /// based on the current stage of the payment process, you will need to
  /// provide a [CardPayButtonState] key to update it.
  final GlobalKey<CardPayButtonState>? payBtnKey;

  /// You will need to provide a general [FormState] key to control, validate
  /// and save the form data based on your needs.
  final GlobalKey<FormState>? formKey;

  final bool displayPhone;

  final String submitLabel;

  /// If you would like to display test data during your development, a dataset
  /// based on Stripe test data is provided. To use this date, simply mark this
  /// true.
  /// WARNING: Make sure to mark false for any release. In release builds,
  /// test data is never applied even when this is true.
  final bool displayTestData;

  /// Optional override for ZIP validation (default: 5-digit US-style).
  final StringValidator? zipValidator;

  /// Optional override for phone validation when [displayPhone] is true.
  final StringValidator? phoneValidator;

  /// Optional override for email validation when [displayEmail] is true.
  final StringValidator? emailValidator;

  /// Optional override for the cardholder name validation.
  final StringValidator? nameValidator;

  /// Optional E.164 formatter for [CardFormResults.phone] from the display field.
  final String Function(String displayPhone)? formatE164Phone;

  /// When true, the CVV field hides its value. Defaults to false.
  final bool obscureCvv;

  @override
  State<CreditCardForm> createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  late final GlobalKey<FormState> _formKey;

  late final GlobalKey<CardPayButtonState>? payBtnKey;

  CardBrand brand = CardBrand.n_a;

  bool get isCvvFront => brand == CardBrand.amex;

  int chosenCountryIndex = 0;

  late final TextEditingController cEmail;
  late final TextEditingController cCardNumber;
  late final TextEditingController cExpiry;
  late final TextEditingController cSecurity;
  late final TextEditingController cName;
  late final TextEditingController cCountry;
  late final TextEditingController cZip;
  late final TextEditingController cPhone;

  bool get _applyTestData => kDebugMode && widget.displayTestData;

  /// MM/YY for the same calendar month one year ahead (debug test prefill).
  static String _oneYearAheadExpiryMmYy() {
    final d = DateTime.now();
    final next = DateTime(d.year + 1, d.month, 1);
    final mm = next.month.toString().padLeft(2, '0');
    final yy = (next.year % 100).toString().padLeft(2, '0');
    return '$mm/$yy';
  }

  @override
  void initState() {
    super.initState();
    if (widget.formKey != null) {
      _formKey = widget.formKey!;
    } else {
      _formKey = GlobalKey<FormState>();
    }

    cEmail = TextEditingController();
    cCardNumber = TextEditingController();
    cExpiry = TextEditingController();
    cSecurity = TextEditingController();
    cName = TextEditingController();
    cCountry = TextEditingController();
    cZip = TextEditingController();
    cPhone = TextEditingController();

    cCountry.text = widget.countries.isNotEmpty ? widget.countries[0] : '';
    payBtnKey = widget.payBtnKey;

    _applyPrefillFromWidget(resetTestBlock: true);
  }

  void _applyPrefillFromWidget({required bool resetTestBlock}) {
    if (_applyTestData) {
      cEmail.text = 'example@example.com';
      cName.text = 'John Doe';
      cCardNumber.text = '4242 4242 4242 4242';
      cExpiry.text = _oneYearAheadExpiryMmYy();
      cSecurity.text = '424';
      cZip.text = '42424';
      cPhone.text = '555-555-5555';
      return;
    }

    if (resetTestBlock) {
      if (widget.initEmail.isNotEmpty) {
        cEmail.text = widget.initEmail;
      }
      if (widget.initBuyerName.isNotEmpty) {
        cName.text = widget.initBuyerName;
      }
      if (widget.initPhone.isNotEmpty && widget.initPhone.length >= 10) {
        final digits = widget.initPhone.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 10) {
          final d = digits.substring(0, 10);
          cPhone.text =
              '${d.substring(0, 3)}-${d.substring(3, 6)}-${d.substring(6)}';
        }
      }
    }
  }

  @override
  void didUpdateWidget(CreditCardForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.countries.isNotEmpty &&
        chosenCountryIndex >= widget.countries.length) {
      chosenCountryIndex = 0;
    }
    if (oldWidget.countries != widget.countries ||
        oldWidget.initEmail != widget.initEmail ||
        oldWidget.initBuyerName != widget.initBuyerName ||
        oldWidget.initPhone != widget.initPhone ||
        oldWidget.displayTestData != widget.displayTestData) {
      _applyPrefillFromWidget(resetTestBlock: true);
    }
  }

  @override
  void dispose() {
    cEmail.dispose();
    cCardNumber.dispose();
    cExpiry.dispose();
    cSecurity.dispose();
    cName.dispose();
    cCountry.dispose();
    cZip.dispose();
    cPhone.dispose();
    super.dispose();
  }

  String _formatPhoneForResults() {
    final raw = cPhone.text;
    if (raw.isEmpty) {
      return '';
    }
    if (widget.formatE164Phone != null) {
      return widget.formatE164Phone!(raw);
    }
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return '';
    }
    return '+1$digits';
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (widget.displayEmail)
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4, 16, 0, 4),
                  child: Text('Email'),
                ),
              ],
            ),
          if (widget.displayEmail)
            TextFormFieldWrapper(
              formField: TextFormField(
                controller: cEmail,
                textAlign: TextAlign.center,
                enabled: !widget.lockEmail,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final StringValidator v =
                      widget.emailValidator ?? EmailSubmitRegexValidator();
                  if (v.isValid(value!)) {
                    return null;
                  }
                  return "Invalid";
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 0,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          if (widget.displayEmail) const SizedBox(height: 20),
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4, 16, 0, 4),
                child: Text('Card Information'),
              ),
            ],
          ),
          TextFormFieldWrapper(
            position: TextFormFieldPosition.top,
            formField: TextFormField(
              controller: cCardNumber,
              keyboardType: TextInputType.number,
              enableSuggestions: false,
              autocorrect: false,
              enableIMEPersonalizedLearning: false,
              smartDashesType: SmartDashesType.disabled,
              smartQuotesType: SmartQuotesType.disabled,
              validator: (value) {
                if (CreditNumberSubmitRegexValidator().isValid(value!)) {
                  return null;
                }
                return 'Enter a valid card number';
              },
              inputFormatters: const [CardNumberInputFormatter()],
              decoration: const InputDecoration(
                hintText: '1234 1234 1234 1234',
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 16,
                ),
                border: InputBorder.none,
              ),
              onChanged: (input) {
                final CardBrand newBrand = CardTypeRegs.findBrand(
                  input.replaceAll(' ', ''),
                );
                if (brand != newBrand) {
                  setState(() {
                    brand = newBrand;
                  });
                }
              },
            ),
            suffix: _BrandsDisplay(brand: brand),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormFieldWrapper(
                  position: TextFormFieldPosition.bottomLeft,
                  formField: TextFormField(
                    controller: cExpiry,
                    keyboardType: TextInputType.number,
                    enableSuggestions: false,
                    autocorrect: false,
                    enableIMEPersonalizedLearning: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    validator: (value) {
                      if (isCreditExpiryOnOrAfterMonth(value!)) {
                        return null;
                      }
                      return "Invalid";
                    },
                    inputFormatters: [
                      MaskedTextInputFormatter(mask: 'xx/xx', separator: '/'),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'MM / YY',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: TextFormFieldWrapper(
                  position: TextFormFieldPosition.bottomRight,
                  formField: TextFormField(
                    controller: cSecurity,
                    obscureText: widget.obscureCvv,
                    validator: (value) {
                      if (CreditCvvSubmitRegexValidator().isValid(value!)) {
                        return null;
                      }
                      return "Invalid";
                    },
                    keyboardType: TextInputType.number,
                    enableSuggestions: false,
                    autocorrect: false,
                    enableIMEPersonalizedLearning: false,
                    smartDashesType: SmartDashesType.disabled,
                    smartQuotesType: SmartQuotesType.disabled,
                    inputFormatters: [
                      MaskedTextInputFormatter(
                        mask: brand == CardBrand.amex ? 'xxxx' : 'xxx',
                        separator: '',
                      ),
                    ],
                    decoration: const InputDecoration(
                      hintText: 'CVC',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 16,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                  suffix: SizedBox(
                    height: 30,
                    width: 30,
                    child: isCvvFront
                        ? Image.asset(
                            'assets/images/cvv_front.png',
                            package: 'checkout_screen_ui',
                          )
                        : Image.asset(
                            'assets/images/cvv_back.png',
                            package: 'checkout_screen_ui',
                          ),
                  ),
                ),
              ),
            ],
          ),
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4, 16, 0, 4),
                child: Text('Name on card'),
              ),
            ],
          ),
          TextFormFieldWrapper(
            formField: TextFormField(
              controller: cName,
              keyboardType: TextInputType.name,
              validator: (input) {
                final StringValidator v =
                    widget.nameValidator ?? CreditNameSubmitRegexValidator();
                if (v.isValid(input!)) {
                  return null;
                }
                return 'Enter a valid name';
              },
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const Row(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(4, 16, 0, 4),
                child: Text('Country or region'),
              ),
            ],
          ),
          TextFormFieldWrapper(
            position: TextFormFieldPosition.top,
            formField: DropdownButtonFormField<int>(
              key: ValueKey<int>(chosenCountryIndex),
              initialValue: widget.countries.isEmpty
                  ? null
                  : chosenCountryIndex.clamp(0, widget.countries.length - 1),
              items: widget.countries
                  .asMap()
                  .entries
                  .map(
                    (e) => DropdownMenuItem<int>(
                      value: e.key,
                      child: Text(e.value),
                    ),
                  )
                  .toList(),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 16,
                ),
                border: InputBorder.none,
              ),
              onChanged: (widget.countries.length > 1)
                  ? (o) {
                      if (o == null) {
                        return;
                      }
                      setState(() {
                        chosenCountryIndex = o;
                        cCountry.text = widget.countries[o];
                      });
                    }
                  : null,
            ),
          ),
          TextFormFieldWrapper(
            position: TextFormFieldPosition.bottom,
            formField: TextFormField(
              controller: cZip,
              keyboardType: TextInputType.number,
              validator: (input) {
                final StringValidator v =
                    widget.zipValidator ?? AddressPostalSubmitRegexValidator();
                if (v.isValid(input!)) {
                  return null;
                }
                return 'Enter a valid zip code';
              },
              inputFormatters: [
                MaskedTextInputFormatter(mask: 'xxxxx', separator: ''),
              ],
              decoration: const InputDecoration(
                hintText: 'ZIP',
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 16,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (widget.displayPhone)
            const Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(4, 16, 0, 4),
                  child: Text('Phone Number'),
                ),
              ],
            ),
          if (widget.displayPhone)
            TextFormFieldWrapper(
              position: TextFormFieldPosition.alone,
              formField: TextFormField(
                controller: cPhone,
                keyboardType: TextInputType.number,
                validator: (input) {
                  input = input!.replaceAll('-', '');
                  final StringValidator v =
                      widget.phoneValidator ?? PhoneRegexValidator();
                  if (v.isValid(input)) {
                    return null;
                  }
                  return 'Enter a valid phone number';
                },
                inputFormatters: [
                  MaskedTextInputFormatter(
                    mask: 'xxx-xxx-xxxx',
                    separator: '-',
                  ),
                ],
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 16,
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          const SizedBox(height: 30),
          Semantics(
            button: true,
            label: widget.submitLabel,
            child: CardPayButton(
              key: payBtnKey,
              initStatus: CardPayButtonStatus.ready,
              text: widget.submitLabel,
              onPressed: () {
                final bool result = _formKey.currentState!.validate();
                if (result) {
                  _formKey.currentState!.save();
                  widget.onCardPay(
                    CardFormResults(
                      email: cEmail.text,
                      cardNumber: cCardNumber.text.replaceAll(' ', ''),
                      cardExpiry: cExpiry.text,
                      cardSec: cSecurity.text,
                      name: cName.text,
                      country: cCountry.text,
                      zip: cZip.text,
                      phone: _formatPhoneForResults(),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandsDisplay extends StatefulWidget {
  const _BrandsDisplay({this.brand = CardBrand.n_a});
  final CardBrand brand;

  @override
  State<_BrandsDisplay> createState() => _BrandsDisplayState();
}

class _BrandsDisplayState extends State<_BrandsDisplay> {
  Widget diners = SizedBox(
    height: 15,
    width: 30,
    child: Image.asset(
      'assets/images/card_diners.png',
      package: 'checkout_screen_ui',
    ),
  );
  Widget jcb = SizedBox(
    height: 15,
    width: 30,
    child: Image.asset(
      'assets/images/card_jcb.png',
      package: 'checkout_screen_ui',
    ),
  );
  Widget union = SizedBox(
    height: 15,
    width: 30,
    child: Image.asset(
      'assets/images/card_union_pay.png',
      package: 'checkout_screen_ui',
    ),
  );
  Widget discover = SizedBox(
    height: 15,
    width: 30,
    child: Image.asset(
      'assets/images/card_discover.png',
      package: 'checkout_screen_ui',
    ),
  );
  Widget visa = SizedBox(
    height: 15,
    width: 30,
    child: Image.asset(
      'assets/images/card_visa.png',
      package: 'checkout_screen_ui',
    ),
  );
  Widget master = SizedBox(
    height: 15,
    width: 30,
    child: Image.asset(
      'assets/images/card_mastercard.png',
      package: 'checkout_screen_ui',
    ),
  );
  Widget amex = SizedBox(
    height: 15,
    width: 30,
    child: Image.asset(
      'assets/images/card_amex.png',
      package: 'checkout_screen_ui',
    ),
  );

  Widget? image;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 3);
    timer = Timer.periodic(oneSec, (Timer timer) {
      if (timer.tick % 4 == 0) {
        setState(() {
          image = discover;
        });
      } else if (timer.tick % 4 == 1) {
        setState(() {
          image = jcb;
        });
      } else if (timer.tick % 4 == 2) {
        setState(() {
          image = diners;
        });
      } else if (timer.tick % 4 == 3) {
        setState(() {
          image = union;
        });
      }
    });
  }

  Widget get mainImage {
    switch (widget.brand) {
      case CardBrand.amex:
        return amex;
      case CardBrand.masterCard:
        return master;
      case CardBrand.discover:
        return discover;
      case CardBrand.diners:
        return diners;
      case CardBrand.jcb:
        return jcb;
      case CardBrand.union:
        return union;
      default:
        return visa;
    }
  }

  @override
  Widget build(BuildContext context) {
    return (widget.brand != CardBrand.n_a)
        ? mainImage
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              visa,
              master,
              amex,
              Container(
                constraints: const BoxConstraints(maxWidth: 30, maxHeight: 15),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 700),
                  child: image ?? discover,
                ),
              ),
            ],
          );
  }
}
