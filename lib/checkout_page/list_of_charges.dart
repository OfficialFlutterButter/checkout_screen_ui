part of 'checkout_page.dart';

class _ListOfCharges extends StatelessWidget {
  const _ListOfCharges({
    required _CheckoutViewModel viewModel,
  }) : _viewModel = viewModel;

  final _CheckoutViewModel _viewModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 30,
        ),
        Container(
          constraints: const BoxConstraints(maxHeight: 400),
          child: ListView(
            shrinkWrap: true,
            children: _viewModel.data.priceItems
                .map((priceItem) =>
                    _PriceListItem(priceItem: priceItem, viewModel: _viewModel))
                .toList(),
          ),
        ),
        _TaxListItem(viewModel: _viewModel, key: _viewModel.taxListItemKey),
      ],
    );
  }
}
