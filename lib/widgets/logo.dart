import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              color: Color(0xffFF8F68),
              shape: BoxShape.rectangle),
         ),

        Positioned(left: 16.255,
          child: Container(
            height: 41.25,
            width: 25,
            padding: EdgeInsets.symmetric(vertical: 27.25),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xffFFFFFF).withOpacity(0.4),
                shape: BoxShape.rectangle),

          ),
        ),
        Positioned(left: 27.405,
          child: Container(
            height: 41.25,
            width: 25,
            padding: EdgeInsets.symmetric(vertical: 27.25),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFFFFFFFF).withOpacity(0.6),

                shape: BoxShape.rectangle),

          ),
        ),

        Positioned(
          left:38.755,
          child: Container(
            height: 41.25,
            width: 25,
            padding: EdgeInsets.symmetric(vertical: 27.25),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color(0xFFFFFFFF).withOpacity(0.8),
                shape: BoxShape.rectangle),

          ),
        ),


      ],
    );
  }
}
