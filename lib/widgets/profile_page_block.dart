import 'package:flutter/material.dart';

class ProfilePageBlock extends StatelessWidget {
  final String? text, image;
  final Function? onPressed;
  final IconData? iconData;
  final bool border;

  ProfilePageBlock({
    this.text,
    this.iconData,
    this.onPressed,
    this.image,
    this.border = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0.0,
        primary: Color(0xFFF2F2F2),
        padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 12, right: 5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(
            color: border ? Color(0xfff44336) : Colors.transparent,
          ),
        ),
      ),
      // elevation: 0.0,
      // color: Color(0xFFF2F2F2),
      // padding: EdgeInsets.only(top: 12.0, bottom: 12.0, left: 12, right: 5),
      // shape: RoundedRectangleBorder(
      //   borderRadius: BorderRadius.circular(8.0),
      //   side: BorderSide(
      //     color: border ? Color(0xfff44336) : Colors.transparent,
      //   ),
      // ),
      onPressed: onPressed as void Function()?,
      child: Row(
        children: [
          // leading icon
          if (iconData != null) ...[
            Icon(
              iconData,
              color: Color(0xFF371D32),
            ),
            SizedBox(width: 10),
          ],
          // leading image
          if (image != null) ...[
            Container(
              width: 25.0, // Set the desired width
              height: 30.0, // Set the desired height
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(image!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
          Text(
            text!,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: Color(0xFF371D32),
            ),
          ),
          Spacer(),
          border
              ? Icon(Icons.error_outline, color: Color(0xfff44336))
              : Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
        ],
      ),
    );
  }
}
