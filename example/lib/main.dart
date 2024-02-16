// ignore_for_file: avoid_print

import 'dart:io';
import 'package:checkout_screen_ui/checkout_ui.dart';
import 'package:checkout_screen_ui/models/checkout_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyDemoPage(),
    );
  }
}

class MyDemoPage extends StatelessWidget {
  const MyDemoPage({Key? key}) : super(key: key);

  /// REQUIRED: (If you are using native pay option)
  ///
  /// A function to handle the native pay button being clicked. This is where
  /// you would interact with your native pay api
  Future<void> _nativePayClicked(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Native Pay requires setup')));
  }

  /// REQUIRED: (If you are using cash pay option)
  ///
  /// A function to handle the cash pay button being clicked. This is where
  /// you would integrate whatever logic is needed for recording a cash transaction
  Future<void> _cashPayClicked(BuildContext context) async {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Cash Pay requires setup')));
  }

  @override
  Widget build(BuildContext context) {
    final demoOnlyStuff = DemoOnlyStuff();

    /// RECOMMENDED: A global Key to access the credit card pay button options
    ///
    /// If you want to interact with the payment button icon, you will need to
    /// create a global key to pass to the checkout page. Without this key
    /// the the button will always display 'Pay'. You may view several ways to
    /// interact with the button elsewhere within this example.
    final GlobalKey<CardPayButtonState> _payBtnKey =
        GlobalKey<CardPayButtonState>();

    /// REQUIRED: A function to handle submission of credit card form
    ///
    /// A function is needed to handle your credit card api calls.
    ///
    /// NOTE: This function in our demo example is under the widget's 'build'
    /// method only because it needs access to an instance variable. There is
    /// no requirement to have this function built here in live code.
    Future<void> _creditPayClicked(
        CardFormResults results, CheckOutResult checkOutResult) async {
      // you can update the pay button to show something is happening
      _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.processing);

      // This is where you would implement you Third party credit card
      // processing api
      demoOnlyStuff.callTransactionApi(_payBtnKey);

      print(results);
      // WARNING: you should NOT print the above out using live code

      for (PriceItem item in checkOutResult.priceItems) {
        print('Item: ${item.name} - Quantity: ${item.quantity}');
      }

      final String subtotal =
          (checkOutResult.subtotalCents / 100).toStringAsFixed(2);
      print('Subtotal: \$$subtotal');

      final String tax = (checkOutResult.taxCents / 100).toStringAsFixed(2);
      print('Tax: \$$tax');

      final String total =
          (checkOutResult.totalCostCents / 100).toStringAsFixed(2);
      print('Total: \$$total');
    }

    /// REQUIRED: A list of what the user is buying
    ///
    /// A list of item will be needed to pass into the checkout page. This is a
    /// simple demo array of [PriceItem]s used to make the demo work. The total
    /// price is automatically added later.
    final List<PriceItem> _priceItems = [
      PriceItem(name: 'Product A', quantity: 1, itemCostCents: 5200),
      PriceItem(name: 'Product B', quantity: 2, itemCostCents: 8599),
      PriceItem(name: 'Product C', quantity: 1, itemCostCents: 2499),
      PriceItem(
          name: 'Delivery Charge',
          quantity: 1,
          itemCostCents: 1599,
          canEditQuantity: false),
    ];

    /// REQUIRED: A name representing the receiver of the funds from user
    ///
    /// Demo vendor name provided here. User's need to know who is receiving
    /// their money
    const String _payToName = 'Magic Vendor';

    /// REQUIRED: (if you are using the native pay options)
    ///
    /// Determine whether this platform is iOS. This affects which native pay
    /// option appears. This is the most basic form of logic needed. You adjust
    /// this logic based on your app's needs and the platforms you are
    /// developing for.
    final _isApple = kIsWeb ? false : Platform.isIOS;

    /// RECOMMENDED: widget to display at footer of page
    ///
    /// Apple and Google stores typically require a link to privacy and terms when
    /// your app is collecting and/or transmitting sensitive data. This link is
    /// expected on the same page as the form that the user is filling out. You
    /// can make this any type of widget you want, but we have created a prebuilt
    /// [CheckoutPageFooter] widget that just needs the corresponding links
    const _footer = CheckoutPageFooter(
      // These are example url links only. Use your own links in live code
      privacyLink: 'https://[Credit Processor].com/privacy',
      termsLink: 'https://[Credit Processor].com/payment-terms/legal',
      note: 'Powered By [Credit Processor]',
      noteLink: 'https://[Credit Processor].com/',
    );

    /// OPTIONAL: A function for the back button
    ///
    /// This to be used as needed. If you have another back button built into your
    /// app, you can leave this function null. If you need a back button function,
    /// simply add the needed logic here. The minimum required in a simple
    /// Navigator.of(context).pop() request
    Function? _onBack = Navigator.of(context).canPop()
        ? () => Navigator.of(context).pop()
        : null;
    // return const Scaffold(
    //   body: WebViewStructure(
    //     allowSideBySide: true,
    //   ),
    // );
    // Put it all together
    return Scaffold(
      appBar: null,
      body: CheckoutPage(
        data: CheckoutData(
          priceItems: _priceItems,
          payToName: _payToName,
          displayNativePay: !kIsWeb,
          onNativePay: (checkoutResults) => _nativePayClicked(context),
          onCashPay: (checkoutResults) => _cashPayClicked(context),
          isApple: _isApple,
          onCardPay: (paymentInfo, checkoutResults) =>
              _creditPayClicked(paymentInfo, checkoutResults),
          onBack: _onBack,
          payBtnKey: _payBtnKey,
          displayTestData: true,
          taxRate: 0.07,
        ),
        footer: _footer,
      ),
    );
  }
}

/// This class is meant to help separate logic that is only used within this demo
/// and not expected to resemble logic needed in live code. That said there may
/// exist some logic that is helpful to use in live code, such as calls to the
/// [CardPayButtonState] key to update its displayed color and icon.
class DemoOnlyStuff {
  // DEMO ONLY:
  // this variable is only used for this demo.
  bool shouldSucceed = true;

  // DEMO ONLY:
  // In this demo, this function is used to delay the resetting of the pay
  // button state in order to allow the user to resubmit the form.
  // If you API calls a failing a transaction, you may need a similar function
  // to update the button from CardPayButtonStatus.fail to
  // CardPayButtonStatus.success. The user will not be able to submit another
  // payment until the button is reset.
  Future<void> provideSomeTimeBeforeReset(
      GlobalKey<CardPayButtonState> _payBtnKey) async {
    await Future.delayed(const Duration(seconds: 2), () {
      _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.ready);
      return;
    });
  }

  Future<void> callTransactionApi(
      GlobalKey<CardPayButtonState> _payBtnKey) async {
    await Future.delayed(const Duration(seconds: 2), () {
      if (shouldSucceed) {
        _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.success);
        shouldSucceed = false;
      } else {
        _payBtnKey.currentState?.updateStatus(CardPayButtonStatus.fail);
        shouldSucceed = true;
      }
      provideSomeTimeBeforeReset(_payBtnKey);
      return;
    });
  }
}
