import 'package:flutter/material.dart';
import 'credit_card_form.dart';
import 'package:url_launcher/url_launcher.dart';

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
  const CheckoutPage(
      {Key? key,
      required this.priceItems,
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
      this.displayTestData = false,
      this.footer})
      :
        // assert(priceItems.length <= 10),
        super(key: key);

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
  final Function? onNativePay;

  /// Should the cash option appear?
  final bool displayCashPay;

  /// Provide a function that should trigger if the user presses the cash
  /// option. Can be left null if Cash option is not to be displayed
  final Function? onCashPay;

  /// Provide a function that receives [CardFormResults] as a parameter that is
  /// to be trigger once the user completes the credit card form and presses
  /// pay
  final Function(CardFormResults) onCardPay;

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

  /// Provide a footer to end the checkout page using any desired widget or
  /// use our built-in [CheckoutPageFooter]
  final Widget? footer;

  /// getter to determine whether or not to display divider above the cash button
  bool get _displayOrCash => displayNativePay && displayCashPay;

  /// getter to determine whether or not to display divider above the card button
  bool get _displayOrCard => displayNativePay || displayCashPay;

  /// getter to determine whether or not to display a discounted cash price
  bool get _displayCashPrice => displayCashPay && (cashPrice != null);

  @override
  Widget build(BuildContext context) {
    // some ui sizing variables
    const double _spacing = 30.0;
    const double _padding = 18.0;
    const double _dividerThickness = 1.2;
    const double _collapsedAppBarHeight = 100;

    // reference to whether or not the sliverAppBar is open or closed
    bool _isOpen = false;

    // Calculate the total charge amount
    int _priceCents = 0;
    for (var item in priceItems) {
      _priceCents += item.totalPriceCents;
    }

    // create a new list of items
    final List<PriceItem> _priceItems = priceItems;

    // add the final price as a line item
    _priceItems.add(
        PriceItem(name: 'Total', quantity: 1, totalPriceCents: _priceCents));

    // convert the calculated total to a string
    final String _priceString =
        (_priceCents.toDouble() / 100).toStringAsFixed(2);

    // calculate the height of the expanded appbar based on the total number
    // of line items to display.
    final double _expHeight =
        (_priceItems.length > 10 ? 500 : _priceItems.length * 50) + 165;

    // Calculate the init height the scroll should be set to to properly
    // display the title and amount to be charged
    final double _initHeight = _expHeight - (_collapsedAppBarHeight + 30.0);

    // create a ScrollController to listen to whether or not the appbar is open
    final ScrollController _scrollController =
        ScrollController(initialScrollOffset: _initHeight);

    // create a key to modify the details text based on appbar expanded status
    final GlobalKey<_StatefulWrapperState> textKey =
        GlobalKey<_StatefulWrapperState>();

    // set the text that should be display based on the appbar status
    const Widget textWhileClosed = Text(
      'View Details',
      style: TextStyle(fontSize: 12.0),
    );
    const Widget textWhileOpen = Text(
      'Hide Details',
      style: TextStyle(fontSize: 12.0),
    );

    // add the listener to the scroll controller mentioned above
    _scrollController.addListener(() {
      final bool result = (_scrollController.offset <= (2 * _initHeight / 3));
      if (result != _isOpen) {
        _isOpen = result;
        if (_isOpen) {
          textKey.currentState?.setChild(textWhileOpen);
        } else {
          textKey.currentState?.setChild(textWhileClosed);
        }
      }
    });

    return CustomScrollView(
      controller: _scrollController,
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
                child: (onBack != null)
                    ? IconButton(
                        onPressed: () => onBack!(),
                        icon: const Icon(
                          Icons.keyboard_arrow_left_outlined,
                          color: Colors.black,
                        ))
                    : null,
              ),
              Expanded(
                  child: Text(
                payToName.length < 16 ? '$payToName Checkout' : payToName,
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
            child: GestureDetector(
              onTap: () {
                if (_isOpen) {
                  _scrollController.jumpTo(_initHeight);
                } else {
                  _scrollController.jumpTo(0);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Charge Amount '),
                  Text(
                    '\$$_priceString',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                  _StatefulWrapper(
                    key: textKey,
                    initChild: textWhileClosed,
                  ),
                ],
              ),
            ),
          ),
          expandedHeight: _expHeight,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            background: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 80, 16.0, 0),
              child: Column(
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView(
                      shrinkWrap: true,
                      children: _priceItems
                          .map((priceItem) =>
                              _PriceListItem(priceItem: priceItem))
                          .toList(),
                    ),
                  ),
                ],
              ),
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
                    if (displayNativePay) const SizedBox(height: _spacing * 2),
                    if (displayNativePay)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          if (onNativePay != null) {
                            onNativePay!();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                              height: 16,
                              width: 16,
                              child: Image.asset(
                                  isApple
                                      ? 'assets/images/apple-32.png'
                                      : 'assets/images/G_mark_small.png',
                                  package: 'checkout_screen_ui'),
                            ),
                            Text(
                              'Pay',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: isApple
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    if (_displayOrCash)
                      const SizedBox(
                        height: _spacing,
                      ),
                    if (_displayOrCash)
                      Row(
                        children: const [
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
                    if (displayCashPay) const SizedBox(height: _spacing),
                    if (displayCashPay)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: () {
                          if (onCashPay != null) {
                            onCashPay!();
                          }
                        },
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
                                  fontWeight: isApple
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      ),
                    if (_displayCashPrice)
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
                    if (_displayCashPrice)
                      Text(
                        '\$${cashPrice!.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    if (_displayOrCard)
                      const SizedBox(
                        height: _spacing,
                      ),
                    if (_displayOrCard)
                      Row(
                        children: const [
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
                      formKey: formKey,
                      onCardPay: (CardFormResults results) =>
                          onCardPay(results),
                      displayEmail: displayEmail,
                      lockEmail: lockEmail,
                      initBuyerName: initBuyerName,
                      initEmail: initEmail,
                      initPhone: initPhone,
                      payBtnKey: payBtnKey,
                      displayTestData: displayTestData,
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

/// Private and simple class meant to wrap a stateless widget
class _StatefulWrapper extends StatefulWidget {
  const _StatefulWrapper({Key? key, required this.initChild}) : super(key: key);
  final Widget initChild;

  @override
  _StatefulWrapperState createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<_StatefulWrapper> {
  late Widget child;

  setChild(Widget newChild) {
    setState(() {
      child = newChild;
    });
  }

  @override
  void initState() {
    super.initState();
    child = widget.initChild;
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// Class object containing required information to display in the checkout
///
/// This class holds the name, description, quantity and cost of items to be
/// displayed on the drop down menu within the checkout page.
class PriceItem {
  /// Class object containing required information to display in the checkout
  ///
  /// This class holds the name, description, quantity and cost of items to be
  /// displayed on the drop down menu within the checkout page.
  PriceItem(
      {required this.name,
      this.description,
      required this.quantity,
      required this.totalPriceCents});

  /// The name of the item to be displayed at checkout
  /// ex: 'Product A'
  final String name;

  /// The optional description of the item to be displayed at checkout
  /// ex: 'additional information about product'
  final String? description;

  /// the quantity of the item to be display at checkout
  /// ex: 1
  final int quantity;

  /// The total cost of the line item as cents to be display at checkout
  /// ex: 1299  => this represent $12.99
  final int totalPriceCents;

  /// getter for the price as string with no dollar sign included
  /// ex: returns => '12.99'
  String get price => (totalPriceCents.toDouble() / 100.00).toStringAsFixed(2);

  @override
  String toString() {
    return 'PriceItem [ name: $name, description: $description, quantity: $quantity, totalPriceCents: $totalPriceCents ]';
  }
}

/// Private stateless widget used to display a line item for each product
/// line item
class _PriceListItem extends StatelessWidget {
  const _PriceListItem({Key? key, required this.priceItem}) : super(key: key);

  final PriceItem priceItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    priceItem.name,
                    overflow: TextOverflow.clip,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: (priceItem.quantity == 1)
                      ? Container()
                      : Text(
                          'x${priceItem.quantity}',
                        ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '\$${priceItem.price}',
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            (priceItem.description != null && priceItem.description!.isNotEmpty)
                ? Row(
                    children: [
                      Text(
                        priceItem.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.clip,
                      ),
                    ],
                  )
                : const SizedBox(
                    height: 16,
                  ),
          ],
        ),
      ),
    );
  }
}

/// Status of the pay button based ont he transaction in progress.
/// The icon and text will update based on the status provided
enum CardPayButtonStatus {
  // ignore: constant_identifier_names
  not_ready,
  ready,
  processing,
  success,
  fail,
}

class CardPayButton extends StatefulWidget {
  /// Button representing the option to submit the credit card info and start
  /// the process of a payment.
  const CardPayButton({
    Key? key,
    required this.onPressed,
    this.initStatus,
  }) : super(key: key);
  final CardPayButtonStatus? initStatus;
  final Function() onPressed;

  @override
  CardPayButtonState createState() => CardPayButtonState();
}

class CardPayButtonState extends State<CardPayButton> {
  CardPayButtonStatus status = CardPayButtonStatus.not_ready;

  updateStatus(CardPayButtonStatus newStatus) {
    setState(() {
      status = newStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initStatus != null) {
      status = widget.initStatus!;
    }
  }

  bool get shouldBeGreen => !shouldBeBlue && !shouldBeGreen;
  bool get shouldBeBlue => status == CardPayButtonStatus.not_ready;
  bool get shouldBeRed => status == CardPayButtonStatus.fail;

  Color get color => shouldBeBlue
      ? Colors.blue.shade600
      : (shouldBeRed ? Colors.red : Colors.green);

  Widget get displayedWidget {
    Widget w = Text('Pay',
        style: TextStyle(color: Colors.grey.shade200, fontSize: 20.0));

    switch (status) {
      case CardPayButtonStatus.ready:
        break;
      case CardPayButtonStatus.processing:
        w = SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.green.shade50,
            strokeWidth: 2.0,
          ),
        );
        break;
      case CardPayButtonStatus.success:
        w = Icon(
          Icons.check_circle,
          color: Colors.green.shade100,
        );
        break;
      case CardPayButtonStatus.fail:
        w = Icon(
          Icons.highlight_remove_rounded,
          color: Colors.red.shade900,
        );
        break;
      default:
        break;
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: (status == CardPayButtonStatus.ready)
          ? () => widget.onPressed()
          : () => {},
      child: displayedWidget,
    );
  }
}

/// Class that houses all expected form data from the checkout ui
class CardFormResults {
  /// Class that houses all expected form data from the checkout ui
  const CardFormResults({
    required this.email,
    required this.cardNumber,
    required this.cardExpiry,
    required this.cardSec,
    required this.name,
    required this.country,
    required this.zip,
    required this.phone,
  });

  /// email string
  final String email;

  /// 15 to 16 digit credit card number. numeric characters only and no spaces
  final String cardNumber;

  /// full expiration date string MM/YY format
  final String cardExpiry;

  /// cvv string. numeric characters only and no spaces
  final String cardSec;

  /// string representing buyer's name
  final String name;

  /// string representing billing country
  final String country;

  /// 5 digit zip / postal code. numeric characters only and no spaces
  final String zip;

  /// 10 digit phone number. numeric characters only and no spaces
  final String phone;

  /// getter to retrieve the year from expiration string
  int get expYear => int.parse(cardExpiry.split('/')[1]) + 2000;

  /// getter to retrieve the expiration month from the expiration string
  int get expMonth => int.parse(cardExpiry.split('/')[0]);

  @override
  String toString() {
    return 'CardFormResults [$email , $cardNumber, $cardExpiry, $cardSec, $name, $country, $zip , $phone]';
  }
}

/// The CheckoutPageFooter is a pre-constructed footer that only requires url
/// links to the desired publicly accessible terms of service page and terms
/// of service page. There is also the ability to add a foot note that can be
/// also be linked to a publicly accessible webpage.
class CheckoutPageFooter extends StatelessWidget {
  /// The CheckoutPageFooter is a pre-constructed footer that only requires url
  /// links to the desired publicly accessible terms of service page and terms
  /// of service page. There is also the ability to add a foot note that can be
  /// also be linked to a publicly accessible webpage.
  const CheckoutPageFooter(
      {Key? key,
      required this.termsLink,
      required this.privacyLink,
      this.note,
      this.noteLink})
      : super(key: key);

  /// url string to the expected publicly accessible webpage displaying your
  /// terms of service
  final String termsLink;

  /// url string to the expected publicly accessible webpage displaying your
  /// privacy statement
  final String privacyLink;

  /// string representing your desired foot note. Leave null if not desired
  final String? note;

  /// if you would like the user to be sent to a publicly accessible webpage
  /// if they click on the footnote, add the url string here.
  final String? noteLink;

  @override
  Widget build(BuildContext context) {
    bool displayNote = (noteLink != null || note != null);
    String noteText = '';
    if (displayNote) {
      noteText = note ?? noteLink!;
    }

    return Column(
      children: [
        const SizedBox(
          height: 60,
        ),
        if (displayNote)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  if (noteLink != null) {
                    final uri = Uri(path: noteLink!);
                    await canLaunchUrl(uri)
                        ? await launchUrl(uri)
                        : throw 'Could not launch $noteLink';
                  }
                },
                child: Text(noteText),
              )
            ],
          ),
        if (displayNote)
          const SizedBox(
            height: 10,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                final uri = Uri(path: termsLink);
                await canLaunchUrl(uri)
                    ? await launchUrl(uri)
                    : throw 'Could not launch $termsLink';
              },
              child: const Text('Terms'),
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
                onPressed: () async {
                  final uri = Uri(path: privacyLink);
                  await canLaunchUrl(uri)
                      ? await launchUrl(uri)
                      : throw 'Could not launch $privacyLink';
                },
                child: const Text('Privacy')),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
