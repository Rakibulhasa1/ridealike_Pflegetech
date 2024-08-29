import 'package:flutter/material.dart';

String dropdownValue = 'Leave review';
class SwapReviewRating extends StatefulWidget {

  @override
  _SwapReviewRatingState createState() => _SwapReviewRatingState();
}

class _SwapReviewRatingState extends State<SwapReviewRating> {
  bool _enabled = true;
  int? value;

  List<Map> _items = [
    {
      "value": 11,
      "text": 'asdf'
    },
    {
      "value": 27,
      "text": 'qwert'
    },
    {
      "value": 31,
      "text": 'yxcv'
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        child: Center(
          child: Column(
            children: <Widget>[

              Switch(
                onChanged: (v) => setState(() {
                  _enabled = v;
                }),
                value: _enabled,
              ),
              DropdownButton(
                disabledHint: value != null
                    ? Text(_items.firstWhere((item) => item["value"] == value)["text"])
                    : null,
                items: _items.map((item) => DropdownMenuItem(
                  value: item["value"],
                  child: Text(item["text"]),
                )).toList(),
                onChanged: _enabled
                    ? (v) => setState(() {
                  value = v as int?;
                })
                    : null,
                value: value,
              )
            ],
          ),
        ),
      ),
    );
  }
}



