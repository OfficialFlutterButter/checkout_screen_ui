part of 'checkout_page.dart';

class _CheckoutViewModel {
  _CheckoutViewModel({required this.data});

// data
  final CheckoutData data;

// form state

// button state

// items states
  void onItemsUpdated() {
    // update the total
    totalDisplayKey.currentState?.onUpdate();
    // update the tax
    taxListItemKey.currentState?.onUpdated();
  }

// total Amount display
  GlobalKey<_ChargeAmountDisplayState>? _totalDisplayKey;
  GlobalKey<_ChargeAmountDisplayState> get totalDisplayKey {
    _totalDisplayKey ??= GlobalKey<_ChargeAmountDisplayState>();
    return _totalDisplayKey!;
  }

  GlobalKey<_TaxListItemState>? _taxListItemKey;
  GlobalKey<_TaxListItemState> get taxListItemKey {
    _taxListItemKey ??= GlobalKey<_TaxListItemState>();
    return _taxListItemKey!;
  }

  ScrollController? _scrollController;
  ScrollController get scrollController {
    _scrollController ??= ScrollController(
        initialScrollOffset: (data.priceItems.length * 50) + 165);
    return _scrollController!;
  }

  void setScrollController(ScrollController controller) {
    _scrollController = controller;
  }

// onClickCardPay
  void onClickCardPay(CardFormResults results) {
    data.onCardPay(
        results,
        CheckOutResult(
          priceItems: data.priceItems,
          totalCostCents: data.totalCostCents,
          taxCents: data.totalTaxCents,
          subtotalCents: data.subtotalCents,
        ));
  }

// onClickCash
  void onClickCash() {
    data.onCashPay?.call(CheckOutResult(
      priceItems: data.priceItems,
      totalCostCents: data.totalCostCents,
      taxCents: data.totalTaxCents,
      subtotalCents: data.subtotalCents,
    ));
  }

// onClickNative
  void onClickNative() {
    data.onNativePay?.call(CheckOutResult(
      priceItems: data.priceItems,
      totalCostCents: data.totalCostCents,
      taxCents: data.totalTaxCents,
      subtotalCents: data.subtotalCents,
    ));
  }
}
