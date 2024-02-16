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

  void scrollListener() {
    final bool result = (widget._viewModel.scrollController.offset <=
        (2 * widget._initHeight / 3));

    if (result != isOpen) {
      isOpen = result;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    widget._viewModel.scrollController.addListener(scrollListener);
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
            style: const TextStyle(
                color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(isOpen ? 'Hide Details' : 'View Details',
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
