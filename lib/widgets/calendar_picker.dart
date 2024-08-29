import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';


class CalendarPicker extends StatefulWidget {
  @override
  _CalendarPickerState createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  List<DateTime>? _selectedDates;
  DateTime? _firstDate;
  DateTime? _lastDate;
  Color selectedDateStyleColor=Color(0xff353B50);

  Color selectedSingleDateDecorationColor=Color(0xFFFF8F68);
  Color disableDateDecorationColor=Colors.grey;
  Color currentDateDecorationColor=Colors.grey;


  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _selectedDates = [
      now,
      now.subtract(Duration(days:0)),
      now.add(Duration(days: 45))
    ];

    _firstDate = DateTime.now().subtract(Duration(days: 0));
    _lastDate = DateTime.now().add(Duration(days: 350));
  }

  @override
  Widget build(BuildContext context) {
    DatePickerRangeStyles styles = DatePickerRangeStyles(
      disabledDateStyle:  Theme.of(context).textTheme.bodyText1!.copyWith(color: disableDateDecorationColor),
        selectedDateStyle: Theme.of(context).textTheme.bodyText1!.copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: selectedSingleDateDecorationColor, shape: BoxShape.circle),

    );



    return DayPicker.multi(
      selectedDates: _selectedDates as List<DateTime>,
      firstDate: _firstDate as DateTime,
      lastDate: _lastDate as DateTime,
      datePickerStyles: styles,
      onChanged: (List<DateTime> newDates) {
        setState(() {
          _selectedDates = newDates;
        });
      },

      datePickerLayoutSettings: DatePickerLayoutSettings(
             showPrevMonthEnd: true,
          showNextMonthStart: true,
        maxDayPickerRowCount: 3,
      ) ,
    );
  }


}
