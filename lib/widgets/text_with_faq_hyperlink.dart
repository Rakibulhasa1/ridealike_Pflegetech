import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/utils/url_launcher.dart';

class TextWithFaqHyperlink extends StatelessWidget {
  final String text;

  TextWithFaqHyperlink(this.text);


  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 18,
          color: Color(0xFF371D32),
        ),
        children: [
          TextSpan(
            text: text,
          ),
          TextSpan(
              text: ' FAQ',
              style: TextStyle(
                color: Colors.blue,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  UrlLauncher.launchUrl(faqUrl);
                }
          ),
        ],
      ),
    );
  }
}

