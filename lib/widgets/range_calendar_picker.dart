
import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';

class RangeCalendarPicker extends StatefulWidget {
  RangeCalendarPicker(List<DateTime> selectedDates);

  @override
  _RangeCalendarPickerState createState() => _RangeCalendarPickerState();
}

class _RangeCalendarPickerState extends State<RangeCalendarPicker> {
  DateTime? _firstDate;
  DateTime? _lastDate;
  DatePeriod? _selectedPeriod;

  Color selectedPeriodStartColor=Color(0xFFFF8F68);
  Color selectedPeriodLastColor=Color(0xFFFF8F68);
  Color selectedPeriodMiddleColor=Color(0xFFFF8F68);

  @override
  void initState() {
    super.initState();

    _firstDate = DateTime.now().subtract(Duration(days: 0));
    _lastDate = DateTime.now().add(Duration(days: 350));

    DateTime selectedPeriodStart = DateTime.now().subtract(Duration(days: 0));
    DateTime selectedPeriodEnd = DateTime.now().add(Duration(days: 4));
    _selectedPeriod = DatePeriod(selectedPeriodStart, selectedPeriodEnd);
  }

  @override
  Widget build(BuildContext context) {
    DatePickerRangeStyles styles = DatePickerRangeStyles(
        selectedPeriodLastDecoration: BoxDecoration(
            color: selectedPeriodLastColor,
            borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24.0),
                bottomRight: Radius.circular(24.0))),
        selectedPeriodStartDecoration: BoxDecoration(
          color: selectedPeriodStartColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              bottomLeft: Radius.circular(24.0)
          ),
        ),
        selectedPeriodMiddleDecoration: BoxDecoration(
            color: selectedPeriodMiddleColor, shape: BoxShape.rectangle),);
    return RangePicker(
      firstDate: _firstDate as DateTime,
      lastDate: _lastDate as DateTime,
      selectedPeriod: _selectedPeriod as DatePeriod,
      onChanged: (DatePeriod newPeriod){
        setState(() {
          _selectedPeriod = newPeriod;
        });
      },
      datePickerStyles: styles,
      datePickerLayoutSettings: DatePickerLayoutSettings(
      showPrevMonthEnd: true,
      showNextMonthStart: true,
      maxDayPickerRowCount: 3,
    ),
    );
  }
}
