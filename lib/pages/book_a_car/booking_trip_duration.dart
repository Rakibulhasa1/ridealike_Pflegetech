import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/utils/dateutils.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/utils/TimeUtils.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:ridealike/widgets/sized_text.dart';

import '../../widgets/shimmer.dart';
import 'booking_info.dart';


class Event {
  DateTime start;
  DateTime end;

  Event({required this.start, required this.end});
}

class BookingTripDuration extends StatefulWidget {
  final bookingInfo;
  final reset;

  BookingTripDuration({this.bookingInfo, this.reset = false});

  @override
  State createState() => BookingTripDurationState(bookingInfo, reset);
}

class BookingTripDurationState extends State<BookingTripDuration> {
  var bookingInfo;
  bool reset;

  BookingTripDurationState(this.bookingInfo, this.reset);

  final ValueNotifier<double> _pickupTime = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _returnTime = ValueNotifier<double>(0.0);

  DateTime selectedDate = DateTime.now();

  DateTime? _firstDate;
  DateTime? _lastDate;

 DateTime? _lastPeriodStart;

  DateTime? selectedPeriodStart;
  DatePeriod? _selectedPeriod;
  DateTime? selectedPeriodEnd;
  Color selectedPeriodStartColor = Color(0xFFFF8F68);
  Color selectedPeriodLastColor = Color(0xFFFF8F68);
  Color selectedPeriodMiddleColor = Color(0xFFFF8F68);

  DatePickerRangeStyles styles = DatePickerRangeStyles(
      selectedPeriodMiddleDecoration:BoxDecoration(
        color: Color(0xFFFF8F68), // Change the background color to orange
      // Optionally, change the shape to a circle
      ),
      currentDateStyle:TextStyle(
          color: Color(0xFFFF8F68) // Change the color to orange
      ),
    selectedDateStyle: TextStyle(
      color: Color(0xFFFF8F68) // Change the color to orange
    ),
  );
  String calID = "";
  List<String> calendarEvents = [];

  final storage = new FlutterSecureStorage();

  bool _loading = true;
  String error = "";
  bool hasError = false;

  bool _fromSearch = false;

  DateTime? lastSelectedDate;

  bool _dateChanged = false;

  void handleShowBookingInfoModal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        bookingInfo["pickupTime"] = _pickupTime.value;
        bookingInfo["returnTime"] = _returnTime.value;
        return BookingInfo(bookingInfo: bookingInfo);
      },
    );
  }

  DateTime _getLastDate(String status) {
    DateTime time = DateTime.now();
    if (status == null || status.isEmpty) {
      time = time.add(Duration(hours: 1));
    } else {
      if (status == "AllFutureDates") {
        time = time.add(Duration(days: 364));
      } else if (status == "Months1") {
        time = time.add(Duration(days: 29));
      } else if (status == "Months3") {
        time = time.add(Duration(days: 89));
      } else if (status == "Months6") {
        time = time.add(Duration(days: 179));
      } else if (status == "Months12") {
        time = time.add(Duration(days: 364));
      } else {
        time = time.add(Duration(days: 364));
      }
    }
    time = time.subtract(
      Duration(
          hours: time.hour,
          minutes: time.minute,
          seconds: time.second,
          milliseconds: time.millisecond,
          microseconds: time.microsecond),
    );
    return time;
  }

  void getCalendarEvents() async {
    try {
      print("calendar events");
      var data = {
        "CalendarID": bookingInfo['calendarID'].toString(),
      };
      //print(data);
      final response = await HttpClient.post(
          viewCalendarEventsUrl,
          data,
          token: await storage.read(key: 'jwt') as String);

      var status = response["Status"];
      //print(response.toString());
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
        //TODO test code
        //calendarEvents.add("2021-04-09");
        //calendarEvents.add("2021-04-15");
        //calendarEvents.add("2021-03-06");
        // calendarEvents.add("2021-02-26");
        // calendarEvents.add("2021-02-27");
        // calendarEvents.add("2021-02-28");
      }
    } catch (e) {
      print(e);
    } finally {
      if (_fromSearch) {
        print("from search");
        updateDaySelectionForSearch();
      } else {
        updateDaySelection();
      }
      setState(() {
        _loading = false;
      });
    }
  }

  void updateDaySelectionForSearch() {
    DateTime start =
    DateTime.parse(bookingInfo['startDate'].toString()).toLocal();
    DateTime end = DateTime.parse(bookingInfo['endDate'].toString()).toLocal();
    print("?????????????????????????????????????????????");
    print(start);
    print(end);
    print("?????????????????????????????????????????????");
    _lastDate = _getLastDate(bookingInfo['window'].toString());
    while (start.isBefore(_lastDate!)) {
      if (!calendarEvents.contains(DateFormat('yyyy-MM-dd').format(start)) &&
          !(start.month == DateTime.now().month &&
              start.day == DateTime.now().day &&
              (start.toLocal().hour + 2) > 23)) {
        setState(() {
          selectedPeriodStart = start;
        });
        break;
      }
      start = start.add(Duration(days: 1));
    }

    DateTime tempEnd = DateTime(
        selectedPeriodStart!.year,
        selectedPeriodStart!.month,
        selectedPeriodStart!.day,
        selectedPeriodEnd!.hour);
    while (tempEnd.isBefore(end.add(Duration(hours: 1)))) {
      if (!calendarEvents.contains(DateFormat('yyyy-MM-dd').format(tempEnd))) {
        setState(() {
          selectedPeriodEnd = tempEnd;
        });
      } else {
        break;
      }
      tempEnd = tempEnd.add(Duration(days: 1));
    }

    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    print(selectedPeriodStart);
    print(selectedPeriodEnd!);
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    _selectedPeriod = DatePeriod(selectedPeriodStart!, selectedPeriodEnd!);

    maintainPickUpAndReturnTime();
  }

  void updateDaySelection() {
    DateTime start;
    DateTime end;
    if (bookingInfo['saveData'] == null) {
      print("savedata null");
      // start = DateTime.now();
      // end = start;
      start = DateTime.now();
      DateTime tempStart = start.subtract(Duration(
        minutes: start.minute,
        seconds: start.second,
        milliseconds: start.millisecond,
        microseconds: start.microsecond,
      ));
      start = tempStart;
      end = start;

      while (start.isBefore(_lastDate!)) {
        print("start:::$start");
        if (!calendarEvents.contains(DateFormat('yyyy-MM-dd').format(start))) {
          if (!calendarEvents.contains(
              DateFormat('yyyy-MM-dd').format(start.add(Duration(days: 1))))) {
            if (!(start.month == DateTime.now().month &&
                start.day == DateTime.now().day &&
                (start.toLocal().hour + 2) > 23)) {
              selectedPeriodStart = start;
              break;
            }
          } else {
            if (!(start.month == DateTime.now().month &&
                start.day == DateTime.now().day &&
                (start.toLocal().hour + 2) > 19)) {
              selectedPeriodStart = start;
              break;
            }
          }
        }
        //
        start = start.add(Duration(days: 1));
        print("start:::$start:::done");
      }
      end = selectedPeriodStart!;
      for (int i = 0; i < 5; i++) {
        if (!calendarEvents.contains(DateFormat('yyyy-MM-dd').format(end))) {
          selectedPeriodEnd = end;
        } else {
          break;
        }
        end = end.add(Duration(days: 1));
      }
    } else {
      print("savedata yes");
      start = DateTime.parse(bookingInfo['startDate'].toString()).toLocal();
      end = DateTime.parse(bookingInfo['endDate'].toString()).toLocal();
      selectedPeriodStart = start;
      selectedPeriodEnd = end;
    }
    _selectedPeriod = DatePeriod(selectedPeriodStart!, selectedPeriodEnd!);

    print("start:::$selectedPeriodStart");
    print("end:::$selectedPeriodEnd");
    //
    maintainPickUpAndReturnTime();
  }

  void updateReturnHourSelection({bool? noUpdate}) {
    print("updateReturnHourSelection");
    setState(() {
      hasError = false;
    });
    DateTime next = _selectedPeriod!.start.add(Duration(days: 1));
    if (_selectedPeriod!.start.day == _selectedPeriod!.end.day) {
      if ((calendarEvents.contains(DateFormat('yyyy-MM-dd').format(next)) &&
          _pickupTime.value.floor() >= 20)) {
        return;
      }
      if (_pickupTime.value.floor() >= 20) {
        DateTime updatedEnd = _selectedPeriod!.end.add(Duration(days: 1));
        if (updatedEnd.isAfter(_lastDate!)) {
          return;
        }
        double diff = _pickupTime.value.floor() - 20.0;
        print("11111111111");
        _returnTime.value = diff;

        if (!calendarEvents
            .contains(DateFormat('yyyy-MM-dd').format(updatedEnd))) {
          setState(() {
            _selectedPeriod = DatePeriod(_selectedPeriod!.start, updatedEnd);
          });
        } else {
          setState(() {
            error = 'Selected day pickup not possible';
            hasError = true;
          });
        }
      } else {
        if ((_pickupTime.value.floor() + 4.0) > _returnTime.value) {
          print("2222222222");
          _returnTime.value = _pickupTime.value.floor() + 4.0;
        }
      }
    } else {
      //TODO
      int diff = _selectedPeriod!.end.difference(_selectedPeriod!.start).inDays;
      print("day diff " + diff.toString());
      if (diff >= 1) {
        if (!noUpdate!) {
          print("33333333333");
          if (_fromSearch) {
            if(_dateChanged){
              _returnTime.value = 0.0;
            }else{
              _returnTime.value = double.parse(selectedPeriodEnd!.hour.toString());
            }
            //
          } else {
            print(bookingInfo['saveData']);
            if (bookingInfo['saveData'] == null) {
              print("null 33333333333");
              //_returnTime.value = 0.0;
              _returnTime.value = _pickupTime.value;
            } else {
              if (bookingInfo['saveData'] == false) {
                print("false 33333333333");
                //_returnTime.value = 0.0;
                _returnTime.value = _pickupTime.value;
              } else {
                print("true 33333333333");
                _returnTime.value =
                    double.parse(selectedPeriodEnd!.hour.toString());
              }
            }
          }
        }
      }
      /*if (diff >= 1) {
        if (!noUpdate) {
          print("33333333333");
          if(_fromSearch){
            _returnTime.value = double.parse(selectedPeriodEnd.hour.toString());
          }else{
            if( bookingInfo['saveData'] == null){
              _returnTime.value = 0.0;
            }else{
              _returnTime.value = double.parse(selectedPeriodEnd.hour.toString());
            }
          }
        }
      }*/
    }
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Booking Calendar"});
      if (bookingInfo["route"] != null &&
          bookingInfo["route"] == "/car_details") {
        _fromSearch = true;
        print("from search");
      }
      print("from search:::" + _fromSearch.toString());
      print("window:::" + bookingInfo['window'].toString());
      styles = DatePickerRangeStyles(
        currentDateStyle: TextStyle(
            color: Colors.black
        ),
        selectedSingleDateDecoration: BoxDecoration(
          color: Color(0xFFFF8F68),
          borderRadius: BorderRadius.circular(8.0), // Add border radius
        ),
        selectedPeriodMiddleDecoration: BoxDecoration(
          color: Color(0xFFFF8F68),
          borderRadius: BorderRadius.zero, // No border radius
        ),
        selectedPeriodStartDecoration: BoxDecoration(
          color: Color(0xFFFF8F68),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0), // Add border radius to top left corner
            bottomLeft: Radius.circular(8.0), // Add border radius to bottom left corner
          ),
        ),
        selectedPeriodLastDecoration: BoxDecoration(
          color: Color(0xFFFF8F68),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(8.0), // Add border radius to top right corner
            bottomRight: Radius.circular(8.0), // Add border radius to bottom right corner
          ),
        ),);
      calID = bookingInfo['calendarID'].toString();
      //
      _firstDate = DateTime.now().subtract(Duration(days: 30));
      _lastDate = _getLastDate(bookingInfo['window'].toString());
      if (reset) {
        _pickupTime.value = 0.0;
        _returnTime.value = 0.0;
        selectedPeriodStart = DateTime.now();
        selectedPeriodEnd = DateTime.now().add(Duration(days: 4));
        _selectedPeriod = DatePeriod(selectedPeriodStart!, selectedPeriodEnd!);
      } else {
        selectedPeriodStart =
            DateTime.parse(bookingInfo['startDate'].toString()).toLocal();
        selectedPeriodEnd =
            DateTime.parse(bookingInfo['endDate'].toString()).toLocal();

        DateTime curTime = DateTime.now();

        if (selectedPeriodStart!.isBefore(curTime)) {
          selectedPeriodStart = curTime;
        } else {
          _pickupTime.value = double.parse(selectedPeriodStart!.hour.toString());
        }

        if (selectedPeriodEnd!.isBefore(curTime)) {
          selectedPeriodEnd = curTime.add(Duration(days: 0));
        } else {
          _returnTime.value = double.parse(selectedPeriodEnd!.hour.toString());
        }

        if (selectedPeriodStart!.isAfter(selectedPeriodEnd!)) {
          _selectedPeriod = DatePeriod(selectedPeriodEnd!, selectedPeriodStart!);
        } else {
          _selectedPeriod = DatePeriod(selectedPeriodStart!, selectedPeriodEnd!);
        }

        if (bookingInfo["pickupTime"] != null &&
            bookingInfo["returnTime"] != null) {
          _pickupTime.value = bookingInfo["pickupTime"];
          _returnTime.value = bookingInfo["returnTime"];
        } else {
          _pickupTime.value = 0.0;
          _returnTime.value = 0.0;
        }
      }
      getCalendarEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

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
                        "Trip duration",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
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
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          showModalBottomSheet(
                            isScrollControlled: true,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            context: context,
                            builder: (context) {
                              return BookingTripDuration(
                                bookingInfo: bookingInfo,
                                reset: true,
                              );
                            },
                          );
                        },
                        child: Text(
                          "Reset",
                          style: TextStyle(
                            color: Color(0xffFF8F68),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.only(right: 16, left: 16, top: 16),
                child: Text(
                  'PICKUP AND RETURN',
                  style: TextStyle(
                      color: Color(0xff371D32).withOpacity(0.5),
                      letterSpacing: 0.2,
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Divider(),
              _selectedPeriod != null
                  ? Container(
                padding: EdgeInsets.only(
                    right: 16, bottom: 16, left: 16),
                child: RangePicker(
                  firstDate: _firstDate!,
                  lastDate: _lastDate!,
                  selectedPeriod: _selectedPeriod!,
                  onChanged: (DatePeriod newPeriod) {
                    _dateChanged = true;
                    print(newPeriod.start.toString() +
                        ":::" +
                        newPeriod.end.toString());
                    int diff = newPeriod.end
                        .difference(newPeriod.start)
                        .inDays;
                    if (diff > 29) {
                      if (_lastPeriodStart != null &&
                          DateFormat('yyyy-MM-dd')
                              .format(_lastPeriodStart!) ==
                              DateFormat('yyyy-MM-dd')
                                  .format(newPeriod.end)) {
                        newPeriod = DatePeriod(
                            newPeriod.end
                                .subtract(Duration(days: 29)),
                            newPeriod.end);
                      } else {
                        newPeriod = DatePeriod(
                            newPeriod.start,
                            newPeriod.start
                                .add(Duration(days: 29)));
                      }
                    }
                    //TODO
                    print("savedata ${_selectedPeriod!.start} ${_selectedPeriod!.end}");
                    if (diff >
                        1) {
                      print("savedata false");
                      bookingInfo['saveData'] =
                      false;
                    }
                    //
                    _lastPeriodStart = newPeriod.start;
                    _isValidRange(newPeriod);
                  },
                  selectableDayPredicate: (date) {
                    if (date.month == DateTime.now().month &&
                        date.day == DateTime.now().day &&
                        calendarEvents.contains(
                            DateFormat('yyyy-MM-dd').format(
                                date.add(Duration(days: 1))))) {
                      return !((DateTime.now().hour + 2) > 19);
                    }
                    if (date.month == DateTime.now().month &&
                        date.day == DateTime.now().day) {
                      return !(date.month == DateTime.now().month &&
                          date.day == DateTime.now().day &&
                          (DateTime.now().hour + 2) > 23);
                    }
                    return !date.isBefore(
                        DateTime.now().subtract(Duration(days: 1)));
                  },
                  datePickerStyles: styles,
                  eventDecorationBuilder: _eventDecorationBuilder,
                  datePickerLayoutSettings:
                  DatePickerLayoutSettings(
                    showPrevMonthEnd: false,
                    showNextMonthStart: false,
                    maxDayPickerRowCount: 6,
                  ),
                ),
              )
                  : Container(),
              Padding(
                padding:
                const EdgeInsets.only(right: 16, left: 16, top: 16),
                child: Text(
                  'PICKUP TIME',
                  style: TextStyle(
                      color: Color(0xff371D32).withOpacity(0.5),
                      letterSpacing: 0.2,
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Divider(),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ValueListenableBuilder(
                              valueListenable: _pickupTime,
                              builder: (BuildContext context, val,
                                  Widget? child) {
                                return Text(
                                  TimeUtils.formatSliderTime((val as num).toInt()),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
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
                                      thumbColor: Color(0xffFFFFFF),
                                      trackShape:
                                      RoundedRectSliderTrackShape(),
                                      trackHeight: 2.0,
                                      activeTrackColor: Color(0xffFF8F62),
                                      inactiveTrackColor:
                                      Color(0xFFE0E0E0),
                                      tickMarkShape:
                                      RoundSliderTickMarkShape(
                                          tickMarkRadius: 4.0),
                                      activeTickMarkColor:
                                      Color(0xffFF8F62),
                                      inactiveTickMarkColor:
                                      Color(0xFFE0E0E0),
                                      valueIndicatorColor: Colors.white,
                                      showValueIndicator:
                                      ShowValueIndicator.always,
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 14.0,
                                        elevation: 3.0,
                                      ),
                                    ),
                                    child: ValueListenableBuilder(
                                      valueListenable: _pickupTime,
                                      builder: (context, val, child) {
                                        return Slider(
                                          min: 0.0,
                                          max: 23.0,
                                          onChanged: (values) {
                                            if (!hasError) {
                                              if (_selectedPeriod
                                                  !.start.day ==
                                                  DateTime.now().day) {
                                                print("111:::" +
                                                    values.toString());

                                                DateTime next =
                                                _selectedPeriod!.start
                                                    .add(Duration(
                                                    days: 1));
                                                if (calendarEvents.contains(
                                                    DateFormat(
                                                        'yyyy-MM-dd')
                                                        .format(
                                                        next)) &&
                                                    values >= 20) {
                                                  print("false");
                                                  return;
                                                }
                                                int hours = DateTime.now()
                                                    .toLocal()
                                                    .hour;
                                                if (values.floor() >
                                                    (hours + 1)) {
                                                  _pickupTime.value =
                                                      values;
                                                }
                                                if (((_selectedPeriod
                                                    !.end.day -
                                                    _selectedPeriod
                                                        !.start.day) ==
                                                    1)) {
                                                  double diff =
                                                      _pickupTime.value
                                                          .floor() -
                                                          20.0;
                                                  print("diff:::" +
                                                      values
                                                          .floor()
                                                          .toString());
                                                  if (diff >= 0 &&
                                                      diff >
                                                          _returnTime
                                                              .value) {
                                                    _returnTime.value =
                                                        diff;
                                                  }
                                                }
                                              } else if (_selectedPeriod
                                                  !.start.day ==
                                                  _selectedPeriod
                                                      !.end.day &&
                                                  _selectedPeriod
                                                      !.start.day !=
                                                      DateTime.now()
                                                          .day) {
                                                print("222:::" +
                                                    values.toString());
                                                DateTime next =
                                                _selectedPeriod!.start
                                                    .add(Duration(
                                                    days: 1));

                                                if (calendarEvents.contains(
                                                    DateFormat(
                                                        'yyyy-MM-dd')
                                                        .format(
                                                        next)) &&
                                                    values >= 20) {
                                                  return;
                                                }
                                                if (values >= 20 &&
                                                    next.isAfter(
                                                        _lastDate!)) {
                                                  return;
                                                }
                                                _pickupTime.value =
                                                    values;
                                              } else if (((_selectedPeriod
                                                  !.end.day -
                                                  _selectedPeriod
                                                      !.start
                                                      .day) ==
                                                  1) &&
                                                  _pickupTime.value
                                                      .floor() >=
                                                      20) {
                                                _pickupTime.value =
                                                    values;
                                                print("333:::" +
                                                    values
                                                        .floor()
                                                        .toString());
                                                double diff = _pickupTime
                                                    .value
                                                    .floor() -
                                                    20.0;
                                                print("diff:::" +
                                                    values
                                                        .floor()
                                                        .toString());
                                                if (_pickupTime.value <
                                                    values) {
                                                  return;
                                                }
                                                if (diff >= 0 &&
                                                    diff >
                                                        _returnTime
                                                            .value) {
                                                  _returnTime.value =
                                                      diff;
                                                }
                                              } else {
                                                print("444:::" +
                                                    values
                                                        .floor()
                                                        .toString());
                                                _pickupTime.value =
                                                    values;
                                              }

                                              print("updateReturnHourSelection(noUpdate: true)");
                                              updateReturnHourSelection(
                                                  noUpdate: true);
                                            }
                                          },
                                          value: val as double,
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
                padding:
                const EdgeInsets.only(right: 16, left: 16, top: 16),
                child: Text(
                  'RETURN TIME',
                  style: TextStyle(
                      color: Color(0xff371D32).withOpacity(0.5),
                      letterSpacing: 0.2,
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Divider(),
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ValueListenableBuilder(
                              valueListenable: _returnTime,
                              builder: (BuildContext context, val,
                                  Widget? child) {
                                return Text(
                                  TimeUtils.formatSliderTime((val as num).toInt()),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
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
                                      thumbColor: Color(0xffFFFFFF),
                                      trackShape:
                                      RoundedRectSliderTrackShape(),
                                      trackHeight: 2.0,
                                      activeTrackColor: Color(0xffFF8F62),
                                      inactiveTrackColor:
                                      Color(0xFFE0E0E0),
                                      tickMarkShape:
                                      RoundSliderTickMarkShape(
                                          tickMarkRadius: 4.0),
                                      activeTickMarkColor:
                                      Color(0xffFF8F62),
                                      inactiveTickMarkColor:
                                      Color(0xFFE0E0E0),
                                      valueIndicatorColor: Colors.white,
                                      showValueIndicator:
                                      ShowValueIndicator.always,
                                      thumbShape: RoundSliderThumbShape(
                                        enabledThumbRadius: 14.0,
                                        elevation: 3.0,
                                      ),
                                    ),
                                    child: ValueListenableBuilder(
                                      valueListenable: _returnTime,
                                      builder: (context, val, child) {
                                        return Slider(
                                          min: 0.0,
                                          max: 23.0,
                                          onChanged: (values) {
                                            if (!hasError) {
                                              if (_selectedPeriod
                                                  !.start.day ==
                                                  _selectedPeriod
                                                      !.end.day &&
                                                  _selectedPeriod
                                                      !.start.day ==
                                                      DateTime.now()
                                                          .day) {
                                                if (values >=
                                                    (_pickupTime.value
                                                        .floor() +
                                                        4.0)) {
                                                  _returnTime.value =
                                                      values;
                                                }
                                              } else if (_selectedPeriod
                                                  !.start.day ==
                                                  _selectedPeriod
                                                      !.end.day &&
                                                  _selectedPeriod
                                                      !.start.day !=
                                                      DateTime.now()
                                                          .day) {
                                                DateTime next =
                                                _selectedPeriod!.start
                                                    .add(Duration(
                                                    days: 1));

                                                if (!calendarEvents
                                                    .contains(DateFormat(
                                                    'yyyy-MM-dd')
                                                    .format(next))) {
                                                  if (values.floor() >
                                                      (_pickupTime.value
                                                          .floor() +
                                                          3)) {
                                                    _returnTime.value =
                                                        values;
                                                  }
                                                } else {
                                                  /*if (values.floor() <=
                                                            23.0) {
                                                          _returnTime.value =
                                                              values;
                                                        }*/
                                                  if (values >=
                                                      (_pickupTime.value
                                                          .floor() +
                                                          4.0)) {
                                                    _returnTime.value =
                                                        values;
                                                  }
                                                }
                                              } else if (((_selectedPeriod
                                                  !.end.day -
                                                  _selectedPeriod
                                                      !.start
                                                      .day) ==
                                                  1) &&
                                                  _pickupTime.value
                                                      .floor() >=
                                                      20) {
                                                double diff = _pickupTime
                                                    .value
                                                    .floor() -
                                                    20.0;
                                                if (values.floor() >=
                                                    diff) {
                                                  _returnTime.value =
                                                      values;
                                                }
                                              } else {
                                                _returnTime.value =
                                                    values;
                                              }
                                            }
                                          },
                                          value: val as double,
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
              Divider(),
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 152,
                      child: Container(
                        // height: 100,
                        padding: EdgeInsets.all(16.0),
                        decoration: new BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          borderRadius: new BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _selectedPeriod != null
                                ? SizedText(
                              deviceWidth: SizeConfig.deviceWidth!,
                              textWidthPercentage: 0.4,
                              text: DateFormat('EE, MMM dd')
                                  .format(_selectedPeriod!.start),
                              fontFamily: 'Urbanist',
                              fontSize: 15,
                              textColor: Color(0xff371D32),
                            )
                                : SizedText(
                              deviceWidth: SizeConfig.deviceWidth!,
                              textWidthPercentage: 0.4,
                              text: DateFormat('EE, MMM dd')
                                  .format(selectedDate),
                              fontFamily: 'Urbanist',
                              fontSize: 15,
                              textColor: Color(0xff371D32),
                            ),
                            SizedBox(height: 8),
                            ValueListenableBuilder(
                              valueListenable: _pickupTime,
                              builder: (BuildContext context, val,
                                  Widget? child) {
                                return Text(
                                  TimeUtils.formatSliderTime((val as num).toInt()),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Color(0xFF353B50),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    // SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xffFF8F62),
                    ),
                    // SizedBox(width: 8),
                    SizedBox(
                      width: 152,
                      child: Container(
                        // height: 75,
                        padding: EdgeInsets.all(16.0),
                        decoration: new BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          borderRadius: new BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            _selectedPeriod != null
                                ? SizedText(
                              deviceWidth: deviceWidth,
                              textWidthPercentage: 0.4,
                              text: DateFormat('EE, MMM dd')
                                  .format(_selectedPeriod!.end),
                              fontFamily: 'Urbanist',
                              fontSize: 15,
                              textColor: Color(0xff371D32),
                            )
                                : SizedText(
                              deviceWidth: deviceWidth,
                              textWidthPercentage: 0.4,
                              text: DateFormat('EE, MMM dd')
                                  .format(selectedDate),
                              fontFamily: 'Urbanist',
                              fontSize: 15,
                              textColor: Color(0xff371D32),
                            ),
                            SizedBox(height: 8),
                            ValueListenableBuilder(
                              valueListenable: _returnTime,
                              builder: (BuildContext context, val,
                                  Widget? child) {
                                return Text(
                                  TimeUtils.formatSliderTime((val as num).toInt()),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Color(0xFF353B50),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              hasError
                  ? Align(
                child: Container(
                  margin: EdgeInsets.only(left: 15.0),
                  child: Text(
                    '$error',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      color: Color(0xFFF55A51),
                    ),
                  ),
                ),
                alignment: Alignment.centerLeft,
              )
                  : Container(),
              SizedBox(
                height: 8,
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
                            child: ElevatedButton(style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Color(0xffFF8F68),
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(8.0)),),
                              onPressed: hasError
                                  ? null
                                  : () {
                                String tempPickup =
                                TimeUtils.getSliderTime(
                                    _pickupTime.value.toInt());
                                String tempReturn =
                                TimeUtils.getSliderTime(
                                    _returnTime.value.toInt());

                                bookingInfo['startDate'] =
                                    DateFormat("y-MM-dd").format(
                                        _selectedPeriod!.start) +
                                        'T' +
                                        tempPickup +
                                        ':00:00.000Z';
                                bookingInfo['endDate'] =
                                    DateFormat("y-MM-dd").format(
                                        _selectedPeriod!.end) +
                                        'T' +
                                        tempReturn +
                                        ':00:00.000Z';

                                DateTime startDT = DateTime.parse(
                                    bookingInfo["startDate"])
                                    .toUtc();
                                DateTime endDT = DateTime.parse(
                                    bookingInfo["endDate"])
                                    .toUtc();

                                /*if (DateTime.now()
                                                .timeZoneOffset
                                                .isNegative) {
                                              startDT = startDT.add(
                                                  DateTime.now()
                                                      .timeZoneOffset);
                                              endDT = endDT.add(DateTime.now()
                                                  .timeZoneOffset);
                                            } else {
                                              startDT = startDT.subtract(
                                                  DateTime.now()
                                                      .timeZoneOffset);
                                              endDT = endDT.subtract(
                                                  DateTime.now()
                                                      .timeZoneOffset);
                                            }*/

                                startDT = startDT.subtract(
                                    DateTime.now().timeZoneOffset);
                                endDT = endDT.subtract(
                                    DateTime.now().timeZoneOffset);

                                AppEventsUtils.logEvent("book_car_calendar",
                                    params: {
                                      "start_date": startDT.toString(),
                                      "end_date": endDT.toString()
                                    });

                                bookingInfo['startDate'] =
                                    startDT.toIso8601String();
                                bookingInfo['endDate'] =
                                    endDT.toIso8601String();
                                bookingInfo['saveData'] = true;
                                handleShowBookingInfoModal(context);
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

  EventDecoration _eventDecorationBuilder(DateTime date) {
    if (_isBlockedDate(date)) {
      return EventDecoration(
          boxDecoration: BoxDecoration(
              color: Colors.grey.shade300, shape: BoxShape.circle));
    }
    if (DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(_selectedPeriod!.start) &&
        DateFormat('yyyy-MM-dd').format(date) ==
            DateFormat('yyyy-MM-dd').format(_selectedPeriod!.end)) {
      return EventDecoration(
        boxDecoration: BoxDecoration(
          color: selectedPeriodStartColor,
          borderRadius: BorderRadius.all(
            Radius.circular(24.0),
          ),
        ),
      );
    }
    if (DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(_selectedPeriod!.start)) {
      return EventDecoration(
        boxDecoration: BoxDecoration(
          color: selectedPeriodStartColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            bottomLeft: Radius.circular(24.0),
          ),
        ),
      );
    }
    if (DateFormat('yyyy-MM-dd').format(date) ==
        DateFormat('yyyy-MM-dd').format(_selectedPeriod!.end)) {
      return EventDecoration(
        boxDecoration: BoxDecoration(
          color: selectedPeriodLastColor,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24.0),
            bottomRight: Radius.circular(24.0),
          ),
        ),
      );
    }
    if (date.isAfter(_selectedPeriod!.start) &&
        date.isBefore(_selectedPeriod!.end)) {
      return EventDecoration(
        boxDecoration: BoxDecoration(
            color: selectedPeriodMiddleColor, shape: BoxShape.rectangle),
      );
    }
    return EventDecoration(
      boxDecoration:
      BoxDecoration(color: Colors.transparent, shape: BoxShape.rectangle),
    );
  }

  bool _isBlockedDate(DateTime date) {
    return calendarEvents.contains(DateFormat('yyyy-MM-dd').format(date));
  }

  void maintainPickUpAndReturnTime() {
    print("maintainPickUpAndReturnTime");
    setState(() {
      hasError = false;
      error = '';
    });

    DateTime start = _selectedPeriod!.start;
    if (_fromSearch) {
      _pickupTime.value = start.hour.toDouble();
    }

    int hours = DateTime.now().toLocal().hour;

    if (start.day == DateTime.now().day) {
      if (hours + 2 > 23) {
        setState(() {
          error = 'Selected day pickup not possible';
          hasError = true;
        });
      } else {
        if (_pickupTime.value <= hours + 2) {
          _pickupTime.value = hours.toDouble() + 2;
        }
        updateReturnHourSelection(noUpdate: false);
      }
    } else {
      updateReturnHourSelection(noUpdate: false);
    }
  }

  void _isValidRange(DatePeriod _selectedPeriod) {
    bool validity = true;
    if (lastSelectedDate == null) {
      lastSelectedDate = _selectedPeriod!.end;
    }

    List<DateTime> dates = DateUtil.instance
        .getDaysInBetween(_selectedPeriod!.start, _selectedPeriod!.end);

    List<DateTime> d = [];
    for (DateTime date in dates) {
      if (_isBlockedDate(date)) {
        validity = false;
      } else {
        d.add(date);
      }
    }

    if (validity) {
      setState(() {
        this._selectedPeriod = _selectedPeriod;
        if (lastSelectedDate == _selectedPeriod!.end) {
          lastSelectedDate = _selectedPeriod!.start;
        } else {
          lastSelectedDate = _selectedPeriod!.end;
        }
      });
    } else {
      setState(() {
        if (d.length > 0) {
          if (d[0] == lastSelectedDate) {
            this._selectedPeriod = DatePeriod(d[d.length - 1], d[d.length - 1]);
            lastSelectedDate = d[d.length - 1];
          } else {
            this._selectedPeriod = DatePeriod(d[0], d[0]);
            lastSelectedDate = d[0];
          }
        }
      });
    }

    if (_selectedPeriod!.start.day == _selectedPeriod!.end.day) {
      _pickupTime.value = 0.0;
      _returnTime.value = 4.0;
    }

    maintainPickUpAndReturnTime();
  }
}