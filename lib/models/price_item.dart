import 'package:flutter/widgets.dart';

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
      required int quantity,
      required this.itemCostCents,
      this.canEditQuantity = true,
      this.image})
      : _quantity = quantity;

  /// The name of the item to be displayed at checkout
  /// ex: 'Product A'
  final String name;

  /// The optional description of the item to be displayed at checkout
  /// ex: 'additional information about product'
  final String? description;

  final bool canEditQuantity;

  /// the quantity of the item to be display at checkout
  /// ex: 1
  int _quantity;
  int get quantity => _quantity;
  set quantity(int value) {
    if (canEditQuantity == false) return;
    _quantity = value;
    // uiState?.update();
  }

  /// The total cost of the line item as cents to be display at checkout
  /// ex: 1299  => this represent $12.99
  final int itemCostCents;

  int get totalPriceCents => itemCostCents * quantity;

  final Widget? image;

  /// getter for the price as string with no dollar sign included
  /// ex: returns => '12.99'
  String get price => (totalPriceCents.toDouble() / 100.00).toStringAsFixed(2);

  int get itemPrice => itemCostCents;

  String get itemPriceString =>
      (itemCostCents.toDouble() / 100.00).toStringAsFixed(2);

  @override
  String toString() {
    return 'PriceItem [ name: $name, description: $description, quantity: $quantity, totalPriceCents: $itemCostCents ]';
  }
}
