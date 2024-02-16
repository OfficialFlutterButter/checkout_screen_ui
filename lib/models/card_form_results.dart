/// Class that houses all expected form data from the checkout ui
///
/// !DO NOT SAVE THIS DATA TO A LOG FILE OR PRINT IT OUT IN LIVE CODE
class CardFormResults {
  /// Class that houses all expected form data from the checkout ui
  const CardFormResults({
    required this.email,
    required this.cardNumber,
    required this.cardExpiry,
    required this.cardSec,
    required this.name,
    required this.country,
    required this.zip,
    required this.phone,
  });

  /// email string
  final String email;

  /// 15 to 16 digit credit card number. numeric characters only and no spaces
  final String cardNumber;

  /// full expiration date string MM/YY format
  final String cardExpiry;

  /// cvv string. numeric characters only and no spaces
  final String cardSec;

  /// string representing buyer's name
  final String name;

  /// string representing billing country
  final String country;

  /// 5 digit zip / postal code. numeric characters only and no spaces
  final String zip;

  /// 10 digit phone number. numeric characters only and no spaces
  final String phone;

  /// getter to retrieve the year from expiration string
  int get expYear => int.parse(cardExpiry.split('/')[1]) + 2000;

  /// getter to retrieve the expiration month from the expiration string
  int get expMonth => int.parse(cardExpiry.split('/')[0]);

  @override
  String toString() {
    return 'CardFormResults [$email , $cardNumber, $cardExpiry, $cardSec, $name, $country, $zip , $phone]';
  }
}
