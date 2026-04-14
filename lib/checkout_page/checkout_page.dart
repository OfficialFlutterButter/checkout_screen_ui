import 'package:flutter/material.dart';
import '../checkout_theme.dart';
import '../credit_form/credit_card_form.dart';
import '../credit_form/validation.dart';

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
part 'checkout_scroll_host.dart';

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
  CheckoutPage({super.key, required this.data, this.footer})
      : _viewModel = _CheckoutViewModel(data: data);

  final CheckoutData data;

  final _CheckoutViewModel _viewModel;

  /// Provide a footer to end the checkout page using any desired widget or
  /// use our built-in [CheckoutPageFooter]
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return _CheckoutScrollHost(
      data: data,
      viewModel: _viewModel,
      footer: footer,
    );
  }
}
