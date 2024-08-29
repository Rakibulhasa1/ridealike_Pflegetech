import 'package:flutter/material.dart';

class ProfileIncompleteIndicator extends StatelessWidget {

  final String imagePath;

  ProfileIncompleteIndicator(this.imagePath);

  @override
  Widget build(BuildContext context) {
    return
      SizedBox(
      height: 21,
      width: 40,
      child: Stack(
        children: [
          Positioned(
            left: 7,
            child: Image.asset(imagePath),
          ),
          Positioned(
            right: 1,
            child: Container(
              height: 12.5,
              width: 12.5,
              decoration: BoxDecoration(
                color: Color(0xffFF8F68),
                border: Border.all(
                  color: Color(0xffFF8F68),
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
