part of 'checkout_page.dart';

class _ListOfCharges extends StatelessWidget {
  const _ListOfCharges({
    required _CheckoutViewModel viewModel,
  }) : _viewModel = viewModel;

  final _CheckoutViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    double listHeight = _viewModel.data.priceItems.length * 50.0;
    if (listHeight > 400) {
      listHeight = 400;
    }

    return Container(
      margin: const EdgeInsets.only(top: 30),
      // constraints: const BoxConstraints(maxHeight: 400),
      height: 400,
      child: ListView(
        shrinkWrap: true,
        children: [
          ..._viewModel.data.priceItems
              .map((priceItem) => _PriceListItem(
                  key: _viewModel.priceItemKeys[priceItem]!,
                  priceItem: priceItem,
                  viewModel: _viewModel))
              .toList(),
          _TaxListItem(viewModel: _viewModel, key: _viewModel.taxListItemKey),
        ],
      ),
    );
  }
}
