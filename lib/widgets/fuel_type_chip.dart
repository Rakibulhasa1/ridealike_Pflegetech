import 'package:flutter/material.dart';

class FuelTypeChip extends StatelessWidget {
  final Function()? onTap;
  final Color? boxColor, textColor;
  final String? text;

  const FuelTypeChip({this.onTap, this.boxColor, this.textColor, this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56.0,
        decoration: new BoxDecoration(
          color: boxColor,
          borderRadius: new BorderRadius
              .circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              text!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}