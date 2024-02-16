import 'price_item.dart';

/// Class object containing the information related to what the user is expecting
/// to pay for after completing the checkout process
class CheckOutResult {
  /// The list of items the user agreed to pay for
  final List<PriceItem> priceItems;

  /// The total cost of the items in cents
  final int totalCostCents;

  /// The total tax of the items in cents
  final int taxCents;

  /// The total cost of the items in cents before tax
  final int subtotalCents;

  CheckOutResult(
      {required List<PriceItem> priceItems,
      required this.totalCostCents,
      required this.taxCents,
      required this.subtotalCents})
      : priceItems = List.unmodifiable(priceItems);
}
