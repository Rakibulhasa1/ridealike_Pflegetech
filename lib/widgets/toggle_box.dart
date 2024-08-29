import 'package:ridealike/widgets/rectangle_box.dart';
import 'package:flutter/material.dart';

class ToggleBox extends StatelessWidget {
  final Widget toggleButtons;
  final String title;
  final String? subtitle;

  ToggleBox(
      {required this.toggleButtons, required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return RectangleBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: Color(0xff371D32)
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                subtitle ?? '',
                // subtitle,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  color: Color(0xFF353B50)
                ),
              ),
            ),
          SizedBox(
            height: 10,
          ),
          toggleButtons
        ],
      ),
    );
  }
}
