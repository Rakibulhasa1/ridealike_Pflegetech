import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ThemeData basicTheme() {
  return ThemeData(
    primaryColor: Colors.white,
    hintColor: Color(0xffFF8F68),
    textTheme: TextTheme(
        headline1: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 36,
            color: Color(0xff371D32)),
        subtitle1: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 28,
            color: Color(0xff371D32)),
        headline4: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xffFFFFFF)),
        headline3: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Color(0xff371D32)),
        headline2: TextStyle(
            letterSpacing: 0.2,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            fontFamily: 'Urbanist',
            color: Color(0xff353B50))),
  );
}
