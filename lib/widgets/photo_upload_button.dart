import 'package:flutter/material.dart';

class PhotoUploadButton extends StatelessWidget {
  final Function onPress;
  final BorderRadiusGeometry? borderRadius;

  const PhotoUploadButton({Key? key, required this.onPress, this.borderRadius})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius:
      borderRadius == null ? BorderRadius.circular(0) : borderRadius,
      color: Color.fromRGBO(224, 224, 224, 1),
      child: InkWell(
        onTap: onPress as void Function(),
        child: Container(
          height: 100,
          width: 100,
          child: Image.asset(
            "icons/Scan-Placeholder.png",
            width: 50,
          ),
        ),
      ),
    );
  }
}
