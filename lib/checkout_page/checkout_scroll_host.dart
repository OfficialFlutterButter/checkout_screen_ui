part of 'checkout_page.dart';

class _CheckoutScrollHost extends StatefulWidget {
  const _CheckoutScrollHost({
    required this.data,
    required this.viewModel,
    this.footer,
  });

  final CheckoutData data;
  final _CheckoutViewModel viewModel;
  final Widget? footer;

  @override
  State<_CheckoutScrollHost> createState() => _CheckoutScrollHostState();
}

class _CheckoutScrollHostState extends State<_CheckoutScrollHost> {
  static const double _spacing = 30.0;
  static const double _padding = 18.0;
  static const double _dividerThickness = 1.2;
  static const double _collapsedAppBarHeight = 100;

  ScrollController? _scrollController;
  String? _layoutSignature;

  static double _expandedHeight(CheckoutData data) {
    return (data.priceItems.length > 10 ? 500 : data.priceItems.length * 50) +
        (data.taxRate != null ? 50 : 0) +
        165;
  }

  static String _signatureFor(CheckoutData d) {
    return '${d.priceItems.length}_${d.taxRate}_${d.subtotalCents}';
  }

  double get _initHeight {
    final exp = _expandedHeight(widget.data);
    return exp - (_collapsedAppBarHeight + 30.0);
  }

  void _createAndAttachScrollController({ScrollController? replace}) {
    final init = _initHeight;
    final next = ScrollController(initialScrollOffset: init);
    widget.viewModel.attachScrollController(next);
    _scrollController = next;
    if (replace != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        replace.dispose();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _layoutSignature = _signatureFor(widget.data);
    _createAndAttachScrollController();
  }

  @override
  void didUpdateWidget(_CheckoutScrollHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextSig = _signatureFor(widget.data);
    if (nextSig != _layoutSignature) {
      _layoutSignature = nextSig;
      final oldController = _scrollController;
      _createAndAttachScrollController(replace: oldController);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = CheckoutTheme.of(context);
    final CheckoutData data = widget.data;
    final _CheckoutViewModel vm = widget.viewModel;
    final double expHeight = _expandedHeight(data);
    final double initHeight = _initHeight;

    return CustomScrollView(
      controller: vm.scrollController,
      slivers: [
        SliverAppBar(
          snap: false,
          pinned: false,
          floating: false,
          backgroundColor: theme.appBarBackgroundColor ?? Colors.grey.shade50,
          collapsedHeight: _collapsedAppBarHeight,
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
                style: TextStyle(
                  fontSize: 26,
                  color: theme.collapsedTitleColor ?? Colors.black,
                ),
              )),
              const SizedBox(
                width: 40,
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size(120.0, 32.0),
            child: _ChargeAmountDisplay(
                key: vm.totalDisplayKey,
                initHeight: initHeight,
                viewModel: vm),
          ),
          expandedHeight: expHeight,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            background: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 80, 16.0, 0),
              child: _ListOfCharges(viewModel: vm),
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
                          backgroundColor:
                              theme.nativePayBackgroundColor ?? Colors.black,
                          foregroundColor:
                              theme.nativePayForegroundColor ?? Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: vm.onClickNative,
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
                                  color: theme.nativePayForegroundColor ??
                                      Colors.white),
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
                          backgroundColor:
                              theme.cashPayBackgroundColor ?? Colors.green,
                          foregroundColor:
                              theme.cashPayForegroundColor ?? Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: vm.onClickCash,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                              height: 32,
                              width: 32,
                              child: Image.asset(
                                  'assets/images/pay_option_cash.png',
                                  package: 'checkout_screen_ui'),
                            ),
                            Text(
                              'Cash',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: data.isApple
                                      ? FontWeight.w500
                                      : FontWeight.w400,
                                  color: theme.cashPayForegroundColor ??
                                      Colors.white),
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
                      onCardPay: vm.onClickCardPay,
                      displayEmail: data.displayEmail,
                      lockEmail: data.lockEmail,
                      initBuyerName: data.initBuyerName,
                      initEmail: data.initEmail,
                      initPhone: data.initPhone,
                      payBtnKey: data.payBtnKey,
                      displayTestData: data.displayTestData,
                      countries: data.countries,
                      displayPhone: data.displayPhone,
                      submitLabel: data.submitLabel,
                      zipValidator: data.zipValidator,
                      phoneValidator: data.phoneValidator,
                      formatE164Phone: data.formatE164Phone,
                    ),
                    widget.footer ?? const SizedBox(height: 120),
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
