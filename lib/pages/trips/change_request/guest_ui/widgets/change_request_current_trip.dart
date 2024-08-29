import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/utils/dateutils.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/utils/TimeUtils.dart';
import '../../../../../widgets/shimmer.dart';

class Event {
  DateTime start;
  DateTime end;

  Event({required this.start, required this.end});
}

class ChangeRequestCurrentTripDuration extends StatefulWidget {
  final bookingInfo;

  ChangeRequestCurrentTripDuration({this.bookingInfo});

  @override
  State createState() => BookingTripDurationState(bookingInfo);
}

class BookingTripDurationState extends State<ChangeRequestCurrentTripDuration> {
  var bookingInfo;

  BookingTripDurationState(this.bookingInfo);

  final ValueNotifier<double> _returnTime = ValueNotifier<double>(0.0);
  DateTime _firstDate = DateTime(2022, 7, 1);
  DateTime _lastDate = DateTime(2024, 7, 21);
  bool isSliderActive = false;
  DateTime? selectedPeriodStart;
  DatePeriod? _selectedPeriod;
  DateTime? selectedPeriodEnd;
  Color? selectedPeriodStartColor = Color(0xFFFF8F68);
  Color? selectedPeriodLastColor = Color(0xFFFF8F68);
  Color? selectedPeriodMiddleColor = Color(0xFFFF8F68);
  DatePickerRangeStyles? styles = DatePickerRangeStyles();
  String calID = "";
  List<String> calendarEvents = [];
  final storage = new FlutterSecureStorage();
  bool _loading = true;
  String error = "";
  bool hasError = false;
  DateTime? lastSelectedDate;

  //DateTime? returnTime;

  Future<void> getCalendarIdByCarId() async {
    var data = {
      "CarID": "${bookingInfo['carID']}",
    };
    print(data);
    try {
      print("${bookingInfo['carID']}++++++++");
      final response = await HttpClient.post(getCarUrl, data,
          token: await storage.read(key: 'jwt') as String);
      var calendarId = response["Car"]["CalendarID"];
      print("$calendarId ============");
      if (response["Status"]["success"]) {
        bookingInfo['calendarID'] = calendarId;
        getCalendarEvents();
      }
    } catch (e) {
      print(e);
    }
  }

  void getCalendarEvents() async {
    try {
      print("calendar events");
      var data = {
        "CalendarID": bookingInfo['calendarID'].toString(),
      };
      final response = await HttpClient.post(viewCalendarEventsUrl, data,
          token: await storage.read(key: 'jwt') as String);
      var status = response["Status"];
      calendarEvents.clear();
      if (status["success"]) {
        var calendar = response["Calendar"];
        List events = calendar["events"];
        for (var eventData in events) {
          var event = eventData["event"];
          List<DateTime> dates = DateUtil.instance.getDaysInBetween(
            DateTime.parse(event["start_datetime"].toString()),
            DateTime.parse(event["end_datetime"].toString()),
          );
          for (DateTime date in dates) {
            calendarEvents.add(DateFormat('yyyy-MM-dd').format(date.toLocal()));
          }
        }
      }
    } catch (e) {
      print(e);
    } finally {
      print("start and end date");
      print(bookingInfo['startDate']);
      print(bookingInfo['endDate']);

      List<DateTime> dates = DateUtil.instance
          .getDaysInBetween(bookingInfo['startDate'], bookingInfo['endDate']);
      print("$dates ===========event list");
      dates.forEach((element) {
        calendarEvents
            .remove(DateFormat('yyyy-MM-dd').format(element.toLocal()));
      });

      print(calendarEvents);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      styles = DatePickerRangeStyles(
        currentDateStyle: TextStyle(color: Colors.black),
        selectedSingleDateDecoration: BoxDecoration(
          color: Color(0xFFFF8F68),
          borderRadius: BorderRadius.circular(8.0),
        ),
        selectedPeriodMiddleDecoration: BoxDecoration(
          color: Color(0xFFFF8F68),
          borderRadius: BorderRadius.zero,
        ),
        selectedPeriodStartDecoration: BoxDecoration(
          color: Color(0xFFFF8F68),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
          ),
        ),
        selectedPeriodLastDecoration: BoxDecoration(
          color: Color(0xFFFF8F68),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8.0),
            bottomRight: Radius.circular(8.0),
          ),
        ),
      );
      calID = bookingInfo['calendarID'].toString();
      _selectedPeriod = DatePeriod(
        DateTime(
          widget.bookingInfo['endDate']!.toLocal().year,
          widget.bookingInfo['endDate']!.toLocal().month,
          widget.bookingInfo['endDate']!.toLocal().day,
        ),
        DateTime(
          widget.bookingInfo['endDate']!.toLocal().year,
          widget.bookingInfo['endDate']!.toLocal().month,
          widget.bookingInfo['endDate']!.toLocal().day,
        ).add(Duration(days: 0)),
      );
      if (widget.bookingInfo["endDate"] != null) {
        print("yes");
        _returnTime.value =
            (widget.bookingInfo['endDate'] as DateTime).toLocal().hour + 1;
      } else {
        print("no");
        _returnTime.value = 0.0;
      }
      getCalendarIdByCarId();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      color: Color.fromRGBO(64, 64, 64, 1),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height / 2,
          maxHeight: MediaQuery.of(context).size.height - 24,
        ),
        child: Container(
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: _loading
              ? ShimmerEffect()
              : ListView(
                  shrinkWrap: true,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              "Extend Trip",
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 20,
                                color: Color(0xFF371D32),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Icon(
                              Icons.arrow_back,
                              color: Color(0xffFF8F68),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 16, left: 16, top: 16),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text(
                          "You can extend upto 3 days at each extension request",
                          style: TextStyle(
                              // color: Color(0xff371D32).withOpacity(0.5),
                              letterSpacing: 0.2,
                              fontFamily: 'Urbanist',
                              fontSize: 18,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    Divider(),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.only(right: 16, bottom: 0, left: 16),
                      child: RangePicker(
                        firstDate: _firstDate,
                        lastDate: _lastDate,
                        selectedPeriod: _selectedPeriod ??
                            DatePeriod(
                              DateTime(
                                widget.bookingInfo['endDate']!.toLocal().year,
                                widget.bookingInfo['endDate']!.toLocal().month,
                                widget.bookingInfo['endDate']!.toLocal().day,
                              ),
                              DateTime(
                                widget.bookingInfo['endDate']!.toLocal().year,
                                widget.bookingInfo['endDate']!.toLocal().month,
                                widget.bookingInfo['endDate']!.toLocal().day,
                              ).add(Duration(days: 0)),
                            ),
                        onChanged: (DatePeriod newPeriod) {
                          setState(() {
                            _selectedPeriod = DatePeriod(
                              DateTime(
                                widget.bookingInfo['endDate']!.toLocal().year,
                                widget.bookingInfo['endDate']!.toLocal().month,
                                widget.bookingInfo['endDate']!.toLocal().day,
                              ),
                              newPeriod.end.add(Duration(days: 0)),
                            );
                          });
                          setSlider();
                        },
                        selectableDayPredicate: (date) {
                          int differenceInDays = date
                              .difference(DateTime(
                                widget.bookingInfo['endDate']!.toLocal().year,
                                widget.bookingInfo['endDate']!.toLocal().month,
                                widget.bookingInfo['endDate']!.toLocal().day,
                              ))
                              .inDays;
                          return differenceInDays >= 0 && differenceInDays <= 3;
                        },
                        datePickerStyles: styles,
                        datePickerLayoutSettings: DatePickerLayoutSettings(
                          showPrevMonthEnd: false,
                          showNextMonthStart: false,
                          maxDayPickerRowCount: 6,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 16,
                        left: 16,
                      ),
                      child: Text(
                        "Move the Slider below to extend trip",
                        style: TextStyle(
                            // color: Color(0xff371D32).withOpacity(0.5),
                            letterSpacing: 0.2,
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.only(right: 16, left: 16),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8.0)),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: ValueListenableBuilder(
                                    valueListenable: _returnTime,
                                    builder: (BuildContext context, double val,
                                        Widget? child) {
                                      // TODO
                                      return Text(
                                        "Return Time: ${DateFormat('hh  a').format((DateTime.now().subtract(Duration(hours: DateTime.now().hour))).toLocal().add(Duration(hours: _returnTime.value.toInt())))}",
                                        style: TextStyle(
                                          letterSpacing: 0.2,
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF353B50),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: SliderTheme(
                                          data: SliderThemeData(
                                            thumbColor: Color(0xffFF8F62),
                                            trackHeight: 3.0,
                                            activeTrackColor: Color(0xffFF8F62),
                                            inactiveTrackColor:
                                                Color(0xFFE0E0E0),
                                            showValueIndicator:
                                                ShowValueIndicator.always,
                                            thumbShape: RoundSliderThumbShape(
                                              enabledThumbRadius: 14.0,
                                              elevation: 3.0,
                                             ),
                                          ),
                                          child: ValueListenableBuilder(
                                            valueListenable: _returnTime,
                                            builder:
                                                (context, double val, child) {
                                              return Slider(
                                                min: 0.0,
                                                max: 23.0,
                                                onChanged: (value) {
                                                  //TODO
                                                  updateSlider(value);
                                                },
                                                value: val,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.only(right: 16, left: 16, bottom: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.maxFinite,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Color(0xffFF8F68),
                                      padding: EdgeInsets.all(16.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                    ),
                                    onPressed: hasError
                                        ? null
                                        : () {
                                            String tempReturn =
                                                TimeUtils.getSliderTime(
                                                    _returnTime.value.toInt());
                                            bookingInfo['endDate'] =
                                                DateFormat("y-MM-dd").format(
                                                        _selectedPeriod!.end) +
                                                    'T' +
                                                    tempReturn +
                                                    ':00:00.000Z';
                                            DateTime endDT = DateTime.parse(
                                                    bookingInfo["endDate"])
                                                .toUtc();
                                            endDT = endDT.subtract(
                                                DateTime.now().timeZoneOffset);
                                            bookingInfo['endDate'] =
                                                endDT.toIso8601String();
                                            bookingInfo['saveData'] = true;
                                            Navigator.pop(
                                                context, {"endDate": endDT});
                                          },
                                    child: Text(
                                      'Save',
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void setSlider() {
    int diff = _selectedPeriod!.end.difference(_selectedPeriod!.start).inDays;
    print("day diff " + diff.toString());
    int lastReturn =
        (widget.bookingInfo['endDate'] as DateTime).toLocal().hour + 1;
    if (diff == 0) {
      _returnTime.value = lastReturn.toDouble();
    } else {
      _returnTime.value = 0.0;
    }
  }

  void updateSlider(double value) {
    int diff = _selectedPeriod!.end.difference(_selectedPeriod!.start).inDays;
    print("day diff " + diff.toString());
    int lastReturn =
        (widget.bookingInfo['endDate'] as DateTime).toLocal().hour + 1;
    if (diff == 0) {
      if (value > lastReturn) {
        _returnTime.value = value;
      }
    } else if (diff == 3) {
      if (value <= lastReturn) {
        _returnTime.value = value;
      }
    } else {
      _returnTime.value = value;
    }
  }
}
