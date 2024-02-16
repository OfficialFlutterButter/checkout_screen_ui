part of 'checkout_page.dart';

/// Private stateless widget used to display a line item for each product
/// line item
class _TaxListItem extends StatefulWidget {
  const _TaxListItem(
      {required super.key, required _CheckoutViewModel viewModel})
      : _viewModel = viewModel;

  final _CheckoutViewModel _viewModel;

  @override
  State<_TaxListItem> createState() => _TaxListItemState();
}

class _TaxListItemState extends State<_TaxListItem> {
  void onUpdated() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget._viewModel.data.taxRate == null) {
      return const SizedBox.shrink();
    }

    String taxPercent =
        (widget._viewModel.data.taxRate! * 100).toStringAsFixed(2);

    String taxAmount = widget._viewModel.data.totalTax;

    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'Tax',
                    overflow: TextOverflow.clip,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '$taxPercent%',
                    textAlign: TextAlign.end,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '\$' + taxAmount,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
