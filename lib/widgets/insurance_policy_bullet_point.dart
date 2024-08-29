import 'package:flutter/material.dart';

import 'insurance_policy_text.dart';

class InsurancePolicyBulletPoint extends StatelessWidget {
  final String text;

  const InsurancePolicyBulletPoint(this.text);

  @override
  Widget build(BuildContext context) {
    return
      Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 15),
        Icon(Icons.check, color: Color(0xffFF8F68),),
        SizedBox(width: 10),
        Flexible(
          child: InsurancePolicyText(text),
        )
      ],
    );
  }
}
