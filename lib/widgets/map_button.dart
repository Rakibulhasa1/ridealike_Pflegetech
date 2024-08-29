import 'package:flutter/material.dart';
import 'package:ridealike/utils/size_config.dart';

class MapButton extends StatelessWidget {

  final void Function()? onPressed;

  const MapButton({ this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(16.0))),
        backgroundColor: Color(0xffA6C9FE),

      ),

      onPressed: onPressed,
      child: SizedBox(
        width: SizeConfig.deviceFontSize! * 63,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'MAP',
              style: TextStyle(
                color: Color(0xffFFFFFF),
                letterSpacing: 0.4,
                fontSize: 14,
                fontFamily: 'Urbanist',
              ),
            ),
            SizedBox(
              width: 8
            ),
            Icon(Icons.map_outlined,color: Colors.white,)
          ],
        ),
      ),

    );
  }
}