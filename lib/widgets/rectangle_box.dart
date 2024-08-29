import 'package:flutter/material.dart';

class RectangleBox extends StatelessWidget {
  final EdgeInsets? padding;
  final Widget child;
  RectangleBox({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding == null ? EdgeInsets.all(16) : padding,
      decoration: BoxDecoration(
        color: Color(0xffF2F2F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
