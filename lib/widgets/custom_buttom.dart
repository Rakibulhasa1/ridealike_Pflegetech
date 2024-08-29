import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  //final bool value;
  final Function() press;

  CustomButton({required this.title, required this.isSelected, required this.press, });

  @override
  Widget build(BuildContext context) {
    return isSelected
        ? GestureDetector(
            onTap: press,
            child: ElevatedButton(
              onPressed: press,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffff8e62),
              ),

              // decoration: BoxDecoration(
              //   color: Color(0xffff8e62),
              //   borderRadius: BorderRadius.all(Radius.circular(8.0)),
              // ),
              child: GestureDetector(
                onTap: press,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 10,

                        color: Colors.white),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          )
        : GestureDetector(
            onTap: press,
            child: ElevatedButton(
              onPressed: press,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffe9e9e9),
              ),

              // decoration: BoxDecoration(
              //   color: Color(0xffe9e9e9),
              //   borderRadius: BorderRadius.all(Radius.circular(8.0)),
              // ),

              child: GestureDetector(
                onTap: press,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 10,
                        color: Color(0xff353B50).withOpacity(0.5)),
                    maxLines: 1,
                  ),
                ),
              ),
            ),
          );
  }
}
