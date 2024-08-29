import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final void Function()? onPress;
  final String title;
  final Color? color;
  final TextStyle? textStyle;

  Button(
      {required this.title,
      required this.onPress,
      this.color,
      this.textStyle});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(6),
      color: color == null ? Color(0xffe9e9e9).withOpacity(0.5) : color,
      child: InkWell(
        onTap: onPress,
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 16),
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textStyle == null?
            TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              color: Color(0xff353B50).withOpacity(0.5)
            ): textStyle,
          ),
        ),
      ),
    );
  }
}
