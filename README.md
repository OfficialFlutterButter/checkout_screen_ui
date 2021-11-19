
A Widget representing a checkout screen that accepts native and credit card payments along with a button for cash payments if you system has 'in person' payments. This is a UI only widget and is meant to compliment whatever third party transaction api system you are using.


![A gif demonstrating the radio group in action.](./demo/checkout_screen_ui_demo.gif)

## Installation

In the `pubspec.yaml` of your flutter project, add the following dependency:
 ``` yaml dependencies:
 checkout_ui_screen: ^0.1.1
```
Import it to each file you use it in:
 ``` dart
 import 'package:checkout_screen_ui/checkout_page.dart';
 ```

## Usage

### Example 1

This example is a very basic checkout page.

```dart
/// Build a list of what the user is buying
final List<PriceItem> _priceItems = [
    PriceItem(name: 'Product A', quantity: 1, totalPriceCents: 5200),
    PriceItem(name: 'Product B', quantity: 2, totalPriceCents: 8599),
    PriceItem(name: 'Product C', quantity: 1, totalPriceCents: 2499),
    PriceItem(name: 'Delivery Charge', quantity: 1, totalPriceCents: 1599),
];

// build the checkout ui
CheckoutPage(
    priceItems: _priceItems,
    payToName: 'Vendor Name Here',
    displayNativePay: true,
    onNativePay: () => print('Native Pay Clicked'),
    isApple: Platform.isIOS,
    onCardPay: (results) => print( 'Credit card form submitted with results: $results'),
    onBack: ()=> Navigator.of(context).pop(),
);
```

## Additional information

- Is there a _bug_ in the code? [File an issue][issue].

If a feature is missing (the Dart language is always evolving) or you'd like an
easier or better way to do something, consider [opening a pull request][pull].
You can always [file an issue][issue], but generally speaking feature requests
will be on a best-effort basis.

[issue]: https://github.com/jonesw5/checkout_screen_ui/issues
[pull]: https://github.com/jonesw5/checkout_screen_ui/pulls
