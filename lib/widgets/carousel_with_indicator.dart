import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:carousel_slider/carousel_slider.dart';

final List<String> imgList = [
  'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
  'https://images.unsplash.com/photo-1522205408450-add114ad53fe?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=368f45b0888aeb0b7b08e3a1084d3ede&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=94a1e718d89ca60a6337a6008341ca50&auto=format&fit=crop&w=1950&q=80',
  'https://images.unsplash.com/photo-1523205771623-e0faa4d2813d?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=89719a0d55dd05e2deae4120227e6efc&auto=format&fit=crop&w=1953&q=80',
  'https://images.unsplash.com/photo-1508704019882-f9cf40e475b4?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=8c6e5e3aba713b17aa1fe71ab4f0ae5b&auto=format&fit=crop&w=1352&q=80',
  'https://images.unsplash.com/photo-1519985176271-adb1088fa94c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=a0c8d632e977f94e5d312d9893258f59&auto=format&fit=crop&w=1355&q=80'
];

final List<String> textList = [
  'Earn up to \$2,000 a month by renting your car with a like minded peer.',
  'Earn up to \$2,000 a month by renting your car with a like minded peer.',
  'Earn up to \$2,000 a month by renting your car with a like minded peer.',
  'Earn up to \$2,000 a month by renting your car with a like minded peer.',
];
final List child = map<Widget>(textList, (index, i) {
  var container = Container(
    width: 375,
    height: 44,
    child: Text(i,
      style: TextStyle(
        color: Color(0xff371D32),
        fontWeight: FontWeight.normal,
        fontSize: 16,
        letterSpacing: -0.25,
        fontFamily: 'Urbanist'
      ),
      ),
    );
  return container;
  },
).toList();

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

final CarouselSlider coverScreenExample = CarouselSlider(
  options: CarouselOptions(
    viewportFraction: 1.0,
    aspectRatio: 2.0,
    autoPlay: true,
    enlargeCenterPage: false,
  ),

  items: map<Widget>(imgList, (index, i) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: NetworkImage(i), fit: BoxFit.cover),
        ),
      );
    },
  ),
);

class CarouselWithIndicator extends StatefulWidget {
  @override
  _CarouselWithIndicatorState createState() => _CarouselWithIndicatorState();
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicator> {
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      child: Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 60,

              autoPlay: true,
              viewportFraction: 2.0,
              enlargeCenterPage: true,
              onPageChanged: (index, CarouselPageChangedReason reason) {
                setState(() {
                  _current = index;
                });
              },

            ), items: child as List<Widget>,
           ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: map<Widget>(
              textList,
              (index, url) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.only(left: 4, right: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index ? Color(0xffFF8F68) : Color(0xffE0E0E0)
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}