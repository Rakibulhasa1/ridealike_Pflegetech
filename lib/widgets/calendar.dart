import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jiffy/jiffy.dart';
import 'package:some_calendar/some_calendar.dart';

class Calendar extends StatefulWidget{
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  DateTime selectedDate = DateTime.now();
  List<DateTime> selectedDates = [];
  // final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return Container(
      child: SomeCalendar(
        primaryColor: Color(0xFFFF8F68),
        textColor: Color(0xff353B50),
        mode: SomeMode.Multi,
        isWithoutDialog: true,
        scrollDirection: Axis.vertical,
        selectedDates: selectedDates,
        startDate: Jiffy().subtract(years: 3).dateTime,
        lastDate: Jiffy().add(months: 9).dateTime,
        // startDate: Jiffy().subtract(years: 3),
        // lastDate: Jiffy().add(months: 9),
        done: (date) {
          setState(() {
            selectedDates = date;
            print('dates:$date');
          });
        },
      ),
    );
  }
}