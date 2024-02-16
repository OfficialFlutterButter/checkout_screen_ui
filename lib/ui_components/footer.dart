import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// The CheckoutPageFooter is a pre-constructed footer that only requires url
/// links to the desired publicly accessible terms of service page and terms
/// of service page. There is also the ability to add a foot note that can be
/// also be linked to a publicly accessible webpage.
class CheckoutPageFooter extends StatelessWidget {
  /// The CheckoutPageFooter is a pre-constructed footer that only requires url
  /// links to the desired publicly accessible terms of service page and terms
  /// of service page. There is also the ability to add a foot note that can be
  /// also be linked to a publicly accessible webpage.
  const CheckoutPageFooter(
      {Key? key,
      required this.termsLink,
      required this.privacyLink,
      this.note,
      this.noteLink})
      : super(key: key);

  /// url string to the expected publicly accessible webpage displaying your
  /// terms of service
  final String termsLink;

  /// url string to the expected publicly accessible webpage displaying your
  /// privacy statement
  final String privacyLink;

  /// string representing your desired foot note. Leave null if not desired
  final String? note;

  /// if you would like the user to be sent to a publicly accessible webpage
  /// if they click on the footnote, add the url string here.
  final String? noteLink;

  @override
  Widget build(BuildContext context) {
    bool displayNote = (noteLink != null || note != null);
    String noteText = '';
    if (displayNote) {
      noteText = note ?? noteLink!;
    }

    return Column(
      children: [
        const SizedBox(
          height: 60,
        ),
        if (displayNote)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  if (noteLink != null) {
                    final uri = Uri(path: noteLink!);
                    await canLaunchUrl(uri)
                        ? await launchUrl(uri)
                        : throw 'Could not launch $noteLink';
                  }
                },
                child: Text(noteText),
              )
            ],
          ),
        if (displayNote)
          const SizedBox(
            height: 10,
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                final uri = Uri(path: termsLink);
                await canLaunchUrl(uri)
                    ? await launchUrl(uri)
                    : throw 'Could not launch $termsLink';
              },
              child: const Text('Terms'),
            ),
            const SizedBox(
              width: 10,
            ),
            TextButton(
                onPressed: () async {
                  final uri = Uri(path: privacyLink);
                  await canLaunchUrl(uri)
                      ? await launchUrl(uri)
                      : throw 'Could not launch $privacyLink';
                },
                child: const Text('Privacy')),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
