import 'package:flutter/material.dart';

import '../constants/text_styles.dart';

class InsurancePolicyText extends StatelessWidget {
  final String text;

  const InsurancePolicyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
      style: insurancePolicyTextStyle,
    );
  }
}
