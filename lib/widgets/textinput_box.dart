import 'package:ridealike/widgets/rectangle_box.dart';
import 'package:flutter/material.dart';

class TextInputBox extends StatelessWidget {
  // final Function onChange;
  final void Function(String) onChange;
  final String label;
  final String hint;
  final Widget? rightLabelChild;

  const TextInputBox(
      {Key? key,
      required this.onChange,
      required this.label,
      required this.hint,
      this.rightLabelChild})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RectangleBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  color: Color(0xFF371D32)
                ),
              ),
              if (rightLabelChild != null) rightLabelChild!
            ],
          ),
          Container(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
              ),
              textInputAction: TextInputAction.done,
              maxLines: 3,
              onChanged: onChange,
            ),
          )
        ],
      ),
    );
  }
}
