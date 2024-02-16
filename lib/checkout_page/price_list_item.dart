part of 'checkout_page.dart';

/// Private stateless widget used to display a line item for each product
/// line item
class _PriceListItem extends StatefulWidget {
  const _PriceListItem(
      {super.key,
      required this.priceItem,
      required _CheckoutViewModel viewModel})
      : _viewModel = viewModel;

  final PriceItem priceItem;
  final _CheckoutViewModel _viewModel;

  @override
  State<_PriceListItem> createState() => _PriceListItemState();
}

class _PriceListItemState extends State<_PriceListItem> {
  bool open = false;

  void onLongPress() {
    setState(() {
      open = !open;
    });
  }

  void close() {
    setState(() {
      open = false;
    });
  }

  void onClickIncrement() {
    widget.priceItem.quantity++;
    widget._viewModel.onItemsUpdated();
    setState(() {});
  }

  void onClickDecrement() {
    widget.priceItem.quantity--;
    widget._viewModel.onItemsUpdated();
    setState(() {});
  }

  void onClickDelete() {
    widget.priceItem.quantity = 0;
    widget._viewModel.onItemsUpdated();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          onLongPress: () => onLongPress(),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      widget.priceItem.name,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      'x${widget.priceItem.quantity}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Text(
                      '\$${widget.priceItem.price}',
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              (widget.priceItem.description != null &&
                      widget.priceItem.description!.isNotEmpty)
                  ? Row(
                      children: [
                        Text(
                          widget.priceItem.description!,
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
              // if open, display buttons to increase or decrease quantity or remove
              if (open)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      onPressed: onClickDecrement,
                      child: const Icon(Icons.remove),
                    ),
                    IconButton(
                      onPressed: onClickDelete,
                      icon: const Icon(Icons.delete),
                    ),
                    ElevatedButton(
                      onPressed: onClickIncrement,
                      child: const Icon(Icons.add),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
