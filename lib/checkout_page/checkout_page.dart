import 'package:flutter/material.dart';
import '../credit_form/credit_card_form.dart';

import '../models/card_form_results.dart';
import '../models/checkout_result.dart';
import '../models/price_item.dart';
import '../ui_components/pay_button.dart';

part 'price_list_item.dart';
part 'checkout_data.dart';
part 'checkout_view_model.dart';
part 'charge_amount_display.dart';
part 'tax_item.dart';
part 'list_of_charges.dart';

/// The CheckoutPage widget is a stateless widget resembling your typical
/// checkout page and some typical option along with some helpful features
/// such as built-in form validation and credit card icons that update
/// based on the input provided.
/// This is a UI widget only and holds no responsibility and makes no guarantee
/// for transactions using this ui. Transaction security and integrity is
/// the responsibility of the developer and what ever Third-party transaction
/// api that developer is using. A great API to use is Stripe
class CheckoutPage extends StatelessWidget {
  /// The CheckoutPage widget is a stateless widget resembling your typical
  /// checkout page and some typical option along with some helpful features
  /// such as built-in form validation and credit card icons that update
  /// based on the input provided.
  /// This is a UI widget only and holds no responsibility and makes no guarantee
  /// for transactions using this ui. Transaction security and integrity is
  /// the responsibility of the developer and what ever Third-party transaction
  /// api that developer is using. A great API to use is Stripe
  CheckoutPage({Key? key, required this.data, this.footer})
      : _viewModel = _CheckoutViewModel(data: data),
        super(key: key) {}

  final CheckoutData data;

  final _CheckoutViewModel _viewModel;

  /// Provide a footer to end the checkout page using any desired widget or
  /// use our built-in [CheckoutPageFooter]
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    // some ui sizing variables
    const double _spacing = 30.0;
    const double _padding = 18.0;
    const double _dividerThickness = 1.2;
    const double _collapsedAppBarHeight = 100;

    // calculate the height of the expanded appbar based on the total number
    // of line items to display.
    final double _expHeight =
        (data.priceItems.length > 10 ? 500 : data.priceItems.length * 50) +
            (data.taxRate != null ? 50 : 0) +
            165;

    // Calculate the init height the scroll should be set to to properly
    // display the title and amount to be charged
    final double _initHeight = _expHeight - (_collapsedAppBarHeight + 30.0);

    // create a ScrollController to listen to whether or not the appbar is open
    _viewModel.setScrollController(
        ScrollController(initialScrollOffset: _initHeight));

    return CustomScrollView(
      controller: _viewModel.scrollController,
      slivers: [
        SliverAppBar(
          snap: false,
          pinned: false,
          floating: false,
          backgroundColor: Colors.grey.shade50,
          collapsedHeight: _collapsedAppBarHeight,
          // set to false to prevent undesired back arrow
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              SizedBox(
                width: 40,
                child: (data.onBack != null)
                    ? IconButton(
                        onPressed: () => data.onBack!(),
                        icon: const Icon(
                          Icons.keyboard_arrow_left_outlined,
                          color: Colors.black,
                        ))
                    : null,
              ),
              Expanded(
                  child: Text(
                data.payToName.length < 16
                    ? '${data.payToName} Checkout'
                    : data.payToName,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 26, color: Colors.black),
              )),
              const SizedBox(
                width: 40,
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size(120.0, 32.0),
            child: _ChargeAmountDisplay(
                key: _viewModel.totalDisplayKey,
                initHeight: _initHeight,
                viewModel: _viewModel),
          ),
          expandedHeight: _expHeight,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            background: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 80, 16.0, 0),
              child: _ListOfCharges(viewModel: _viewModel),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (data.displayNativePay)
                      const SizedBox(height: _spacing * 2),
                    if (data.displayNativePay)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _viewModel.onClickNative,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                              height: 16,
                              width: 16,
                              child: Image.asset(
                                  data.isApple
                                      ? 'assets/images/apple-32.png'
                                      : 'assets/images/G_mark_small.png',
                                  package: 'checkout_screen_ui'),
                            ),
                            Text(
                              'Pay',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: data.isApple
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    if (data._displayOrCash)
                      const SizedBox(
                        height: _spacing,
                      ),
                    if (data._displayOrCash)
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: _dividerThickness,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: _padding),
                            child: Text('Or pay with Cash'),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: _dividerThickness,
                            ),
                          ),
                        ],
                      ),
                    if (data.displayCashPay) const SizedBox(height: _spacing),
                    if (data.displayCashPay)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: _viewModel.onClickCash,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                              height: 32,
                              width: 32,
                              child: Image.asset(
                                  'assets/images/pay_option_cash.png', //assets/images/pay_option_cash.png
                                  package: 'checkout_screen_ui'),
                            ),
                            Text(
                              'Cash',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: data.isApple
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    if (data._displayCashPrice)
                      const Padding(
                        padding: EdgeInsets.only(top: 12.0, bottom: 8.0),
                        child: Text(
                          'Discounted price of',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                              fontSize: 12),
                        ),
                      ),
                    if (data._displayCashPrice)
                      Text(
                        '\$${data.cashPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    if (data._displayOrCard)
                      const SizedBox(
                        height: _spacing,
                      ),
                    if (data._displayOrCard)
                      const Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: _dividerThickness,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: _padding),
                            child: Text('Or pay with Card'),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: _dividerThickness,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: _spacing,
                    ),
                    CreditCardForm(
                      formKey: data.formKey,
                      onCardPay: _viewModel.onClickCardPay,
                      displayEmail: data.displayEmail,
                      lockEmail: data.lockEmail,
                      initBuyerName: data.initBuyerName,
                      initEmail: data.initEmail,
                      initPhone: data.initPhone,
                      payBtnKey: data.payBtnKey,
                      displayTestData: data.displayTestData,
                    ),
                    footer ?? const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
