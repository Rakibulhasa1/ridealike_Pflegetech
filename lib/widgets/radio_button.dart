import 'package:ridealike/widgets/buton.dart';
import 'package:flutter/material.dart';

typedef void Toggle(int index);

class RadioButton extends StatelessWidget {
  final List<String> items;
  final List<bool> isSelected;
  final Toggle onPress;

  RadioButton(
    {
      required this.items,
      required this.isSelected,
      required this.onPress
    }
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        items.length,
        (index) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: items.length - 1 == index ? 0 : 16),
            child: Button(
              title: items[index],
              color: isSelected[index] ? Color(0xffff8e62) : Color(0xffE0E0E0),
              textStyle: isSelected[index] ? TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                color: Colors.white
              ) : TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 12,
                color: Color(0xff353B50).withOpacity(0.5)
              ),
              onPress: () => onPress(index),
            ),
          ),
        ),
      ),
    );
  }
}
