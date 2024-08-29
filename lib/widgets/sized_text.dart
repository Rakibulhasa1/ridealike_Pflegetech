import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SizedText extends StatelessWidget {

  final double deviceWidth, textWidthPercentage;
  final String text;
  final Color textColor;
  final String? fontFamily;
  final double? fontSize;
  final TextOverflow? textOverflow;
  final int? maxLines;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;

  SizedText({required this.deviceWidth,required this.textWidthPercentage,required this.text,required this.textColor, this.fontFamily, this.fontSize, this.textOverflow, this.maxLines, this.textAlign, this.fontWeight ,});


  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: deviceWidth * textWidthPercentage,
      ),
      child: AutoSizeText(
        text,
        overflow: textOverflow,
        maxLines: maxLines,
        textAlign: textAlign,
        style: TextStyle(
          fontWeight: fontWeight,
          fontFamily: fontFamily,
          fontSize: fontSize,
          color: textColor,
        ),
      ),
    );
  }
}
