import 'package:flutter/material.dart';

class RangeSliderBottomSheet extends StatefulWidget {
  final RangeValues selectedRange;
  final void Function(RangeValues) onRangeSelected;

  const RangeSliderBottomSheet(
      {Key? key, required this.selectedRange, required this.onRangeSelected})
      : super(key: key);

  @override
  _RangeSliderBottomSheetState createState() => _RangeSliderBottomSheetState();
}

class _RangeSliderBottomSheetState extends State<RangeSliderBottomSheet> {
  RangeValues? selectedRange;

  @override
  Widget build(BuildContext context) {
    if (selectedRange == null) {
      selectedRange = widget.selectedRange;
    }
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '\$${selectedRange!.start.floor().toString()}',
                style: TextStyle(
                    color: Color(0xff371D32),
                    fontSize: 16,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                    letterSpacing: 2),
              ),
              Text(
                ' to \$${selectedRange!.end.floor().toString()}' + '/day',
                style: TextStyle(
                    color: Color(0xff371D32),
                    fontSize: 16,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2),
              ),
            ],
          ),
          RangeSlider(
            values: selectedRange!,
            min: 0,
            max: 999,
            onChanged: (RangeValues newValues) {
              selectedRange = newValues;
              setState(() {

              });
            },
          ),
          Divider(),
          SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width,
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Color(0xffFF8F68)),
              onPressed: () {
                widget.onRangeSelected(selectedRange!);
                Navigator.pop(context);
              },
              child: Text(
                'Apply',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Urbanist'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
