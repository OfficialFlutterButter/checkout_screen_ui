import 'package:flutter/material.dart';

/// Theme values for [CheckoutPage] and related widgets.
///
/// Apply with [ThemeData.extensions]:
/// ```dart
/// theme: ThemeData(
///   extensions: const [CheckoutTheme()],
/// ),
/// ```
class CheckoutTheme extends ThemeExtension<CheckoutTheme> {
  const CheckoutTheme({
    this.appBarBackgroundColor,
    this.collapsedTitleColor,
    this.chargeAmountColor,
    this.nativePayBackgroundColor,
    this.nativePayForegroundColor,
    this.cashPayBackgroundColor,
    this.cashPayForegroundColor,
  });

  /// [SliverAppBar.backgroundColor] when not null.
  final Color? appBarBackgroundColor;

  /// Title text color in the app bar.
  final Color? collapsedTitleColor;

  /// Color of the main charge amount figure.
  final Color? chargeAmountColor;

  final Color? nativePayBackgroundColor;
  final Color? nativePayForegroundColor;
  final Color? cashPayBackgroundColor;
  final Color? cashPayForegroundColor;

  static CheckoutTheme of(BuildContext context) {
    return Theme.of(context).extension<CheckoutTheme>() ?? const CheckoutTheme();
  }

  @override
  CheckoutTheme copyWith({
    Color? appBarBackgroundColor,
    Color? collapsedTitleColor,
    Color? chargeAmountColor,
    Color? nativePayBackgroundColor,
    Color? nativePayForegroundColor,
    Color? cashPayBackgroundColor,
    Color? cashPayForegroundColor,
  }) {
    return CheckoutTheme(
      appBarBackgroundColor: appBarBackgroundColor ?? this.appBarBackgroundColor,
      collapsedTitleColor: collapsedTitleColor ?? this.collapsedTitleColor,
      chargeAmountColor: chargeAmountColor ?? this.chargeAmountColor,
      nativePayBackgroundColor:
          nativePayBackgroundColor ?? this.nativePayBackgroundColor,
      nativePayForegroundColor:
          nativePayForegroundColor ?? this.nativePayForegroundColor,
      cashPayBackgroundColor:
          cashPayBackgroundColor ?? this.cashPayBackgroundColor,
      cashPayForegroundColor:
          cashPayForegroundColor ?? this.cashPayForegroundColor,
    );
  }

  @override
  CheckoutTheme lerp(ThemeExtension<CheckoutTheme>? other, double t) {
    if (other is! CheckoutTheme) return this;
    return CheckoutTheme(
      appBarBackgroundColor:
          Color.lerp(appBarBackgroundColor, other.appBarBackgroundColor, t),
      collapsedTitleColor:
          Color.lerp(collapsedTitleColor, other.collapsedTitleColor, t),
      chargeAmountColor:
          Color.lerp(chargeAmountColor, other.chargeAmountColor, t),
      nativePayBackgroundColor: Color.lerp(
          nativePayBackgroundColor, other.nativePayBackgroundColor, t),
      nativePayForegroundColor: Color.lerp(
          nativePayForegroundColor, other.nativePayForegroundColor, t),
      cashPayBackgroundColor:
          Color.lerp(cashPayBackgroundColor, other.cashPayBackgroundColor, t),
      cashPayForegroundColor:
          Color.lerp(cashPayForegroundColor, other.cashPayForegroundColor, t),
    );
  }
}
