import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';
import 'package:ridealike/utils/TimeUtils.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:ridealike/widgets/sized_text.dart';

class SearchCarTripDuration extends StatefulWidget {
  @override
  _SearchCarTripDurationState createState() => _SearchCarTripDurationState();
}

class _SearchCarTripDurationState extends State<SearchCarTripDuration> {
  var headingText = TextStyle(
      fontSize: 12,
      letterSpacing: 0.2,
      color: Color(0xf371D32).withOpacity(0.5),
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.w500);

  double _initialPickupTime = 0.0;

  final ValueNotifier<double> _pickupTime = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _returnTime = ValueNotifier<double>(0.0);

  DateTime? _firstDate;
  DateTime? _lastDate;
 DatePeriod? _selectedPeriod;
  String error = "";
  bool hasError = false;

  Color selectedPeriodStartColor = Color(0xFFFF8F68);
  Color selectedPeriodLastColor = Color(0xFFFF8F68);
  Color selectedPeriodMiddleColor = Color(0xFFFF8F68);

  SearchData? receivedData;

  DatePickerRangeStyles styles = DatePickerRangeStyles(
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
    ),
  );


  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Search Car Trip Duration"});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      receivedData = ModalRoute.of(context)!.settings.arguments as SearchData;
      _firstDate = DateTime.now().subtract(Duration(days: 0));
      _lastDate = DateTime.now().add(Duration(days: 350));

      if (receivedData != null && receivedData!.read!) {
        if (receivedData!.tripStartDate != null &&
            receivedData!.tripEndDate != null) {
          DateTime selectedPeriodStart =
              DateTime.parse(receivedData!.tripStartDate.toString()).toLocal();
          DateTime selectedPeriodEnd =
              DateTime.parse(receivedData!.tripEndDate.toString()).toLocal();
          if (selectedPeriodStart.isBefore(_firstDate!)) {
            selectedPeriodStart = _firstDate!;
          }
          setState(() {
            _selectedPeriod =
                DatePeriod(selectedPeriodStart, selectedPeriodEnd);
          });
        }
        if (receivedData!.tripStartTime != null &&
            receivedData!.tripEndTime != null) {
          _pickupTime.value = receivedData!.tripStartTime!;
          _initialPickupTime = _pickupTime.value;
          _returnTime.value = receivedData!.tripEndTime!;
        }
        receivedData!.read = false;
      } else {
        DateTime selectedPeriodStart = DateTime.now();
        DateTime selectedPeriodEnd = DateTime.now().add(Duration(days: 4));
        setState(() {
          if (selectedPeriodStart.isAfter(selectedPeriodEnd)) {
            _selectedPeriod =
                DatePeriod(selectedPeriodEnd, selectedPeriodStart);
          } else {
            _selectedPeriod =
                DatePeriod(selectedPeriodStart, selectedPeriodEnd);
          }
        });
      }
      if (receivedData != null && !receivedData!.save!) {
        print("yes yes");
        maintainPickUpAndReturnTime(first: true);
      } else {
        print("no no");
      }
    });
  }

  //TODO
  void updateReturnHourSelection({ bool? noUpdate}) {
    print("updateReturnHourSelection");
    setState(() {
      hasError = false;
    });
    //
    int diff = _selectedPeriod!.end.difference(_selectedPeriod!.start).inDays;
    print("day diff " + diff.toString());
    if (diff >= 1) {
      if (!noUpdate!) {
        print("33333333333");
        //_returnTime.value = 0.0;
        _returnTime.value = _pickupTime.value;
      }
    }
    //
    if (_selectedPeriod!.start.day == _selectedPeriod!.end.day) {
      if (_pickupTime.value.floor() >= 20) {
        print("updateReturnHourSelection:::1");
        double diff = _pickupTime.value.floor() - 20.0;
        _returnTime.value = diff;
        DateTime updatedEnd = _selectedPeriod!.end.add(Duration(days: 1));
        setState(() {
          _selectedPeriod = DatePeriod(_selectedPeriod!.start, updatedEnd);
        });
      } else {
        print("updateReturnHourSelection:::2");
        if ((_pickupTime.value.floor() + 4.0) > _returnTime.value) {
          _returnTime.value = _pickupTime.value.floor() + 4.0;
        }
      }
    }
    if ((_selectedPeriod!.end.day - _selectedPeriod!.start.day) == 1) {
      if (_pickupTime.value.floor() >= 20) {
        print("updateReturnHourSelection:::3");
        double diff = _pickupTime.value.floor() - 20.0;
        print("updateReturnHourSelection:::diff:::$diff");
        if (diff > _returnTime.value) {
          _returnTime.value = diff;
        }
      } else {
        print("updateReturnHourSelection:::4");
        /*if((_pickupTime.value.floor() + 4.0) > _returnTime.value){
          _returnTime.value = _pickupTime.value.floor() + 4.0;
        }*/
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _pickupTime.value = _initialPickupTime;
                    _returnTime.value = 0.0;
                    _firstDate = DateTime.now().subtract(Duration(days: 0));
                    _lastDate = DateTime.now().add(Duration(days: 350));

                    DateTime selectedPeriodStart =
                        DateTime.now().subtract(Duration(days: 0));
                    DateTime selectedPeriodEnd =
                        DateTime.now().add(Duration(days: 4));
                    _selectedPeriod =
                        DatePeriod(selectedPeriodStart, selectedPeriodEnd);
                  });
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xFFFF8F62),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        elevation: 0.0,
      ),
      body: _selectedPeriod == null
          ? Container()
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Trip duration',
                    style: TextStyle(
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                        fontFamily: 'Urbanist',
                        color: Color(0xff371D32)),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.center,
                    child: RangePicker(
                      firstDate: _firstDate!,
                      lastDate: _lastDate!,
                      selectedPeriod: _selectedPeriod!,
                      onChanged: (DatePeriod newPeriod) {
                        int diff =
                            newPeriod.end.difference(newPeriod.start).inDays;
                        if (diff > 29) {
                          newPeriod = DatePeriod(newPeriod.start,
                              newPeriod.start.add(Duration(days: 29)));
                        }
                        setState(() {
                          _selectedPeriod = newPeriod;
                        });
                        if (_selectedPeriod!.start.day ==
                            _selectedPeriod!.end.day) {
                          _pickupTime.value = 0.0;
                          _returnTime.value = 4.0;
                        }
                        maintainPickUpAndReturnTime();
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
                  ),
                  Text(
                    'PICKUP TIME',
                    style: headingText,
                  ),
                  Divider(),
                  SizedBox(
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
                              padding: const EdgeInsets.only(top: 0),
                              child: ValueListenableBuilder(
                                valueListenable: _pickupTime,
                                builder:
                                    (BuildContext context, val, Widget? child) {
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
                              padding: EdgeInsets.only(bottom: 0.0),
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
                                        inactiveTrackColor: Color(0xFFE0E0E0),
                                        tickMarkShape: RoundSliderTickMarkShape(
                                            tickMarkRadius: 4.0),
                                        activeTickMarkColor: Color(0xffFF8F62),
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
                                                if (_selectedPeriod!.start.day ==
                                                    DateTime.now().day) {
                                                  print("111:::" +
                                                      values.toString());
                                                  int hours = DateTime.now()
                                                      .toLocal()
                                                      .hour;
                                                  if (values.floor() >
                                                      (hours + 1)) {
                                                    _pickupTime.value = values;
                                                  }
                                                  if (((_selectedPeriod
                                                              !.end.day -
                                                          _selectedPeriod
                                                              !.start.day) ==
                                                      1)) {
                                                    double diff = _pickupTime
                                                            .value
                                                            .floor() -
                                                        20.0;
                                                    print("diff:::" +
                                                        values
                                                            .floor()
                                                            .toString());
                                                    if (diff >= 0 &&
                                                        diff >
                                                            _returnTime.value) {
                                                      _returnTime.value = diff;
                                                    }
                                                  }
                                                } else if (_selectedPeriod
                                                            !.start.day ==
                                                        _selectedPeriod
                                                            !.end.day &&
                                                    _selectedPeriod!.start.day !=
                                                        DateTime.now().day) {
                                                  print("222:::" +
                                                      values.toString());
                                                  DateTime next =
                                                      _selectedPeriod!.start.add(
                                                          Duration(days: 1));

                                                  _pickupTime.value = values;
                                                } else if (((_selectedPeriod
                                                                !.end.day -
                                                            _selectedPeriod
                                                                !.start.day) ==
                                                        1) &&
                                                    _pickupTime.value.floor() >=
                                                        20) {
                                                  _pickupTime.value = values;
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
                                                          _returnTime.value) {
                                                    _returnTime.value = diff;
                                                  }
                                                } else {
                                                  print("444:::" +
                                                      values
                                                          .floor()
                                                          .toString());
                                                  _pickupTime.value = values;
                                                }
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
                  SizedBox(height: 5),
                  Text(
                    'RETURN TIME',
                    style: headingText,
                  ),
                  SizedBox(
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
                                builder:
                                    (BuildContext context, val, Widget? child) {
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
                              padding: EdgeInsets.only(bottom: 0.0),
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
                                        inactiveTrackColor: Color(0xFFE0E0E0),
                                        tickMarkShape: RoundSliderTickMarkShape(
                                            tickMarkRadius: 4.0),
                                        activeTickMarkColor: Color(0xffFF8F62),
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
                                                if (_selectedPeriod!.start.day ==
                                                    _selectedPeriod!.end.day) {
                                                  print(
                                                      "1:::${values.floor()}");
                                                  if (values >=
                                                      (_pickupTime.value
                                                              .floor() +
                                                          4.0)) {
                                                    _returnTime.value = values;
                                                  }
                                                } else if (((_selectedPeriod
                                                                !.end.day -
                                                            _selectedPeriod
                                                                !.start.day) ==
                                                        1) &&
                                                    _pickupTime.value.floor() >=
                                                        20) {
                                                  print(
                                                      "2:::${values.floor()}");

                                                  double diff = _pickupTime
                                                          .value
                                                          .floor() -
                                                      20.0;
                                                  if (values.floor() >= diff) {
                                                    _returnTime.value = values;
                                                  }
                                                } else {
                                                  print(
                                                      "3:::${values.floor()}");
                                                  _returnTime.value = values;
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
                  Divider(),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        width: 150,
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
                              SizedText(
                                deviceWidth: SizeConfig.deviceWidth!,
                                textWidthPercentage: 0.4,
                                text: DateFormat('EE, MMM dd')
                                    .format(_selectedPeriod!.start),
                                fontFamily: 'Urbanist',
                                fontSize: 15,
                                textColor: Color(0xff371D32),
                              ),
                              SizedBox(height: 8),
                              ValueListenableBuilder(
                                valueListenable: _pickupTime,
                                builder:
                                    (BuildContext context, val, Widget? child) {
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
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xffFF8F62),
                      ),
                      SizedBox(width: 8),
                      SizedBox(
                        width: 150,
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
                              SizedText(
                                deviceWidth: SizeConfig.deviceWidth!,
                                textWidthPercentage: 0.4,
                                text: DateFormat('EE, MMM dd')
                                    .format(_selectedPeriod!.end),
                                fontFamily: 'Urbanist',
                                fontSize: 15,
                                textColor: Color(0xff371D32),
                              ),
                              SizedBox(height: 8),
                              ValueListenableBuilder(
                                valueListenable: _returnTime,
                                builder:
                                    (BuildContext context, val, Widget? child) {
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
                  // SizedBox(height: 20),
                  SizedBox(
                    height: 8,
                  ),
                  hasError
                      ? Align(
                          child: Text(
                            '$error',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xFFF55A51),
                            ),
                          ),
                          alignment: Alignment.centerLeft,
                        )
                      : Container(),
                  SizedBox(
                    height: 8,
                  ),
                  Row(
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
                                    borderRadius: BorderRadius.circular(8.0)),),
                                onPressed: () {
                                  DateTime startDate = DateTime(
                                      _selectedPeriod!.start.year,
                                      _selectedPeriod!.start.month,
                                      _selectedPeriod!.start.day,
                                      _pickupTime.value.toInt(),
                                      0,
                                      0);
                                  DateTime endDate = DateTime(
                                      _selectedPeriod!.end.year,
                                      _selectedPeriod!.end.month,
                                      _selectedPeriod!.end.day,
                                      _returnTime.value.toInt(),
                                      0,
                                      0);
                                  receivedData!.tripStartDate = startDate;
                                  receivedData!.tripStartTime =
                                      _pickupTime.value.floorToDouble();
                                  receivedData!.tripEndDate = endDate;
                                  receivedData!.tripEndTime =
                                      _returnTime.value.floorToDouble();

                                  //
                                  receivedData!.save = true;
                                  //

                                  print(_pickupTime.value.floorToDouble());
                                  print(_returnTime.value.floorToDouble());

                                  AppEventsUtils.logEvent("search_car_calendar",
                                      params: {
                                        "start_date": startDate.toString(),
                                        "end_date": endDate.toString()
                                      });

                                  Navigator.pop(
                                    context,
                                    receivedData,
                                  );
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
                ],
              ),
            ),
    );
  }

  void maintainPickUpAndReturnTime({bool first = false}) {
    print("maintain:::start");

    setState(() {
      hasError = false;
      error = '';
    });

    DateTime start = _selectedPeriod!.start;

    print("maintain:::start:::$start");

    int hours = DateTime.now().toLocal().hour;

    print("maintain:::hours:::$hours");

    if (start.day == DateTime.now().day) {
      print("maintain:::if");
      print("maintain:::${start.day}:::${DateTime.now().day}");
      if (hours + 2 > 23) {
        print("maintain:::if:::if");
        print("maintain:::if:::${hours + 2}");
        setState(() {
          error = 'Selected day pickup not possible';
          hasError = true;
        });
      } else {
        if (_pickupTime.value <= hours + 2) {
          _pickupTime.value = hours.toDouble() + 2;
          if (first) {
            _initialPickupTime = _pickupTime.value;
          }
        }
        updateReturnHourSelection(noUpdate: false);
      }
    } else {
      updateReturnHourSelection(noUpdate: false);
    }
  }

  // TODO event decoration
  EventDecoration _eventDecorationBuilder(DateTime date) {
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
}
