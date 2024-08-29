import 'package:flutter/cupertino.dart';

class SizeConfig{

  static MediaQueryData? _mediaQueryData;
  static double? deviceFontSize, deviceWidth, deviceHeight;

  void init(BuildContext context){
    _mediaQueryData = MediaQuery.of(context);
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    deviceFontSize = _mediaQueryData!.textScaleFactor;
  }


}