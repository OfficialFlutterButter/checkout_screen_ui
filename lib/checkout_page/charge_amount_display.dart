part of 'checkout_page.dart';

class _ChargeAmountDisplay extends StatefulWidget {
  const _ChargeAmountDisplay({
    super.key,
    required _CheckoutViewModel viewModel,
    // required bool isOpen,
    // required ScrollController scrollController,
    required double initHeight,
    // required String priceString,
    // required this.textKey,
    // required this.textWhileClosed,
  })  : _viewModel = viewModel,
        // _isOpen = isOpen,
        _initHeight = initHeight;
  // _priceString = viewModel.data.totalPrice;

  // final bool _isOpen;
  final double _initHeight;
  // final String _priceString;
  // final GlobalKey<_StatefulWrapperState> textKey;
  // final Widget textWhileClosed;
  final _CheckoutViewModel _viewModel;

  @override
  State<_ChargeAmountDisplay> createState() => _ChargeAmountDisplayState();
}

class _ChargeAmountDisplayState extends State<_ChargeAmountDisplay> {
  bool isOpen = false;

  ScrollController? _listeningOn;

  void scrollListener() {
    final bool result = (widget._viewModel.scrollController.offset <=
        (2 * widget._initHeight / 3));

    if (result != isOpen) {
      isOpen = result;
      setState(() {});
    }
  }

  void _attachScrollListener() {
    final ScrollController c = widget._viewModel.scrollController;
    if (_listeningOn == c) {
      return;
    }
    _listeningOn?.removeListener(scrollListener);
    _listeningOn = c;
    _listeningOn!.addListener(scrollListener);
  }

  @override
  void initState() {
    super.initState();
    _attachScrollListener();
  }

  @override
  void didUpdateWidget(_ChargeAmountDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget._viewModel.scrollController != widget._viewModel.scrollController ||
        oldWidget._initHeight != widget._initHeight) {
      _attachScrollListener();
    }
  }

  @override
  void dispose() {
    _listeningOn?.removeListener(scrollListener);
    super.dispose();
  }

  void onUpdate() {
    setState(() {});
  }

  void onClickTotalDisplay() {
    setState(() {
      widget._viewModel.scrollController.animateTo(
        isOpen ? widget._initHeight : 0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );

      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClickTotalDisplay,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Charge Amount '),
          Text(
            '\$${widget._viewModel.data.totalPrice}',
            style: TextStyle(
                color: CheckoutTheme.of(context).chargeAmountColor ??
                    Colors.green,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          Text(isOpen ? 'Hide Details' : 'View Details',
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
