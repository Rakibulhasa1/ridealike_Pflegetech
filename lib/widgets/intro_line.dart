import 'package:flutter/material.dart';

import '../utils/size_config.dart';
import './sized_text.dart';

class IntroLine extends StatelessWidget {
  final String? text;

  IntroLine({this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, color: Color(0xffFF8F68),),
        SizedBox(width: SizeConfig.deviceWidth! * 0.052,),
        SizedText(
          deviceWidth: SizeConfig.deviceWidth!,
          textWidthPercentage: 0.8,
          text: text!,
          textColor: Colors.white,
          fontSize: (SizeConfig.deviceHeight! * 0.029)/SizeConfig.deviceFontSize!,
        ),
      ],
    );
  }
}