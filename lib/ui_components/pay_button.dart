import 'package:flutter/material.dart';

/// Status of the pay button based ont he transaction in progress.
/// The icon and text will update based on the status provided
enum CardPayButtonStatus {
  // ignore: constant_identifier_names
  not_ready,
  ready,
  processing,
  success,
  fail,
}

class CardPayButton extends StatefulWidget {
  /// Button representing the option to submit the credit card info and start
  /// the process of a payment.
  const CardPayButton({
    Key? key,
    required this.onPressed,
    this.initStatus,
  }) : super(key: key);
  final CardPayButtonStatus? initStatus;
  final Function() onPressed;

  @override
  CardPayButtonState createState() => CardPayButtonState();
}

class CardPayButtonState extends State<CardPayButton> {
  CardPayButtonStatus status = CardPayButtonStatus.not_ready;

  updateStatus(CardPayButtonStatus newStatus) {
    setState(() {
      status = newStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    if (widget.initStatus != null) {
      status = widget.initStatus!;
    }
  }

  bool get shouldBeGreen => !shouldBeBlue && !shouldBeRed;
  bool get shouldBeBlue => status == CardPayButtonStatus.not_ready;
  bool get shouldBeRed => status == CardPayButtonStatus.fail;

  Color get color => shouldBeBlue
      ? Colors.blue.shade600
      : (shouldBeRed ? Colors.red : Colors.green);

  Widget get displayedWidget {
    Widget w = Text('Pay',
        style: TextStyle(color: Colors.grey.shade200, fontSize: 20.0));

    switch (status) {
      case CardPayButtonStatus.ready:
        break;
      case CardPayButtonStatus.processing:
        w = SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.green.shade50,
            strokeWidth: 2.0,
          ),
        );
        break;
      case CardPayButtonStatus.success:
        w = Icon(
          Icons.check_circle,
          color: Colors.green.shade100,
        );
        break;
      case CardPayButtonStatus.fail:
        w = Icon(
          Icons.highlight_remove_rounded,
          color: Colors.red.shade900,
        );
        break;
      default:
        break;
    }
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 50),
      ),
      onPressed: (status == CardPayButtonStatus.ready)
          ? () => widget.onPressed()
          : () => {},
      child: displayedWidget,
    );
  }
}
