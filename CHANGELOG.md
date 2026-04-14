# Changelog

## 1.1.0

- Flutter Web: depend on `url_launcher_web` ^2.4.2 so `package:web` resolves to a Dart 3.10+–compatible release (fixes `dart compile js` failures with `web` 0.3.x).
- Minimum environment: Dart `>=3.10.0`, Flutter `>=3.38.0` (aligned with `url_launcher_web` 2.4.x).
- Example app: drop `dart:io` / `Platform.isIOS`; use `defaultTargetPlatform` so the demo compiles and runs on web.
- Raised Dart / Flutter constraints (from prior 1.0.x); updated `flutter_lints` and `url_launcher`.
- Fixed footer links to use `Uri.parse` and external `launchUrl` mode so HTTPS URLs open correctly.
- Card validation: Amex 15-digit (4-6-5) and standard 16-digit PAN patterns; MM/YY expiry regex aligned with the masked field; expiry must not be before the current month.
- `CardFormResults.toString` is redacted in profile/release; in debug it includes full values for local development only.
- Checkout scroll: single `ScrollController` owned by state with proper disposal; removed per-build controller creation.
- `CreditCardForm`: controller disposal, prefill via lifecycle (not in `build`), test data only in debug when enabled, optional ZIP/phone validators and E.164 formatter; `CheckoutData` gains `displayPhone`, `submitLabel`, and related optional hooks.
- Added `CheckoutTheme` as a `ThemeExtension` for app bar and pay button colors.
- Added `checkout_screen_ui.dart` library barrel and re-exported `validation.dart`.
