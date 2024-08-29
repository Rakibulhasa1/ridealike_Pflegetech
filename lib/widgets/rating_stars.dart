import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {

  final int? rating;

  RatingStars({this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize:
      MainAxisSize.min,
      children: List.generate(5, (indexIcon) {
        return Icon(
          Icons.star,
          size: 13,
          color: indexIcon < rating! ? Color(0xff5BC0EB).withOpacity(0.8):Colors.grey,
        );
      }),

    );
  }
}