part of 'checkout_page.dart';

class CheckoutData {
  /// The CheckoutData widget is a stateless widget resembling your typical
  /// checkout page and some typical option along with some helpful features
  /// such as built-in form validation and credit card icons that update
  /// based on the input provided.
  /// This is a UI widget only and holds no responsibility and makes no guarantee
  /// for transactions using this ui. Transaction security and integrity is
  /// the responsibility of the developer and what ever Third-party transaction
  /// api that developer is using. A great API to use is Stripe
  const CheckoutData(
      {required this.priceItems,
      required this.payToName,
      this.displayNativePay = false,
      this.isApple = false,
      this.onNativePay,
      this.displayCashPay = false,
      this.onCashPay,
      required this.onCardPay,
      this.displayEmail = true,
      this.lockEmail = false,
      this.initEmail = '',
      this.initPhone = '',
      this.initBuyerName = '',
      this.countriesOverride,
      this.onBack,
      this.payBtnKey,
      this.formKey,
      this.cashPrice,
      this.taxRate,
      this.displayTestData = false});

  /// The list of items with prices [PriceItem]'s to be shown within the
  /// drop down banner on the checkout page
  final List<PriceItem> priceItems;

  /// If you are providing a cash option at a discount, provide its price
  /// ex: 12.99
  final double? cashPrice;

  /// Provide the name of the vendor handling the transaction or receiving the
  /// funds from the user during this transaction
  final String payToName;

  /// should you display native pay option?
  final bool displayNativePay;

  /// is this the user on an apple based platform?
  final bool isApple;

  /// Provide a function that will be triggered once the user clicks on the
  /// native button. Can be left null if native option is not to be displayed
  final void Function(CheckOutResult checkOutResult)? onNativePay;

  /// Should the cash option appear?
  final bool displayCashPay;

  /// Provide a function that should trigger if the user presses the cash
  /// option. Can be left null if Cash option is not to be displayed
  final void Function(CheckOutResult checkOutResult)? onCashPay;

  /// Provide a function that receives [CardFormResults] as a parameter that is
  /// to be trigger once the user completes the credit card form and presses
  /// pay
  final Function(CardFormResults results, CheckOutResult checkOutResult)
      onCardPay;

  /// Should the email box be displayed?
  final bool displayEmail;

  /// Should the email form field be locked? This should only be done if an
  /// [initEmail] is provided
  final bool lockEmail;

  /// Provide an email if you have it, to prefill the email field on the Credit
  /// Card form
  final String initEmail;

  /// Provide a name if you have it, to prefill the name field on the Credit
  /// Card form
  final String initBuyerName;

  /// Provide a phone number if you have it, to prefill the name field on the
  /// Credit Card form
  final String initPhone;

  /// If you have a List of Countries that you would like to use to override the
  /// currently provide list of 1, being 'United States', add the list here.
  /// Warning: The credit card form does not currently adjust based on selected
  /// country's needs to verify a card. This form may not work for all countries
  final List<String>? countriesOverride;

  /// If you would like to provide an integrated back button in the header, add
  /// add the needed functionality here.
  /// ex) onBack : ()=>Navigator.of(context).pop();
  final Function? onBack;

  /// If you would like to control the pay button state to display text or icons
  /// based on the current stage of the payment process, you will need to
  /// provide a [CardPayButtonState] key to update it.
  final GlobalKey<CardPayButtonState>? payBtnKey;

  /// You will need to provide a general [FormState] key to control, validate
  /// and save the form data based on your needs.
  final GlobalKey<FormState>? formKey;

  /// If you would like to display test data during your development, a dataset
  /// based on Stripe test data is provided. To use this date, simply mark this
  /// true.
  /// WARNING: Make sure to mark false for any release
  final bool displayTestData;

  /// The tax rate to be applied to the total price
  final double? taxRate;

  int get totalTaxCents {
    if (taxRate == null) {
      return 0;
    }
    return (totalCostCents * taxRate!).toInt();
  }

  String get totalTax => (totalTaxCents.toDouble() / 100.00).toStringAsFixed(2);

  int get subtotalCents {
    return priceItems.fold(0, (prev, item) => prev + item.totalPriceCents);
  }

  int get totalCostCents {
    int amount =
        priceItems.fold(0, (prev, item) => prev + item.totalPriceCents);
    if (taxRate != null) {
      amount += (amount * taxRate!).toInt();
    }
    return amount;
  }

  String get totalPrice =>
      (totalCostCents.toDouble() / 100.00).toStringAsFixed(2);

  /// getter to determine whether or not to display divider above the cash button
  bool get _displayOrCash => displayNativePay && displayCashPay;

  /// getter to determine whether or not to display divider above the card button
  bool get _displayOrCard => displayNativePay || displayCashPay;

  /// getter to determine whether or not to display a discounted cash price
  bool get _displayCashPrice => displayCashPay && (cashPrice != null);

  /// need to trigger the ui to update for
  /// - change item quantity
  ///   - item price, and total price
}
