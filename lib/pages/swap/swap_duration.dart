import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/messages/utils/dateutils.dart';
import 'package:ridealike/utils/TimeUtils.dart';

import '../../utils/app_events/app_events_utils.dart';

class SwapDuration extends StatefulWidget {
  @override
  State createState() => SwapDurationState();
}

class SwapDurationState extends State<SwapDuration> {
  final ValueNotifier<double> _pickupTime = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _returnTime = ValueNotifier<double>(0.0);

  DateTime? _firstDate;
  DateTime? _lastDate;
  String? error;
  bool hasError = false;

  DateTime selectedDate = DateTime.now();

  DateTime? selectedPeriodStart;
   DatePeriod? _selectedPeriod;
  DateTime? selectedPeriodEnd;
  Color selectedPeriodStartColor = Color(0xFFFF8F68);
  Color selectedPeriodLastColor = Color(0xFFFF8F68);
  Color selectedPeriodMiddleColor = Color(0xFFFF8F68);
  DatePickerRangeStyles? styles;
  List<String> _calendarEvents = [];
  Map? receivedData;

  DatePeriod? lastSelectedPeriod;
  DateTime? lastSelectedDate;
  DatePeriod? lastSelectedPeriodNew;

  @override
  void dispose() {
    _pickupTime.dispose();
    _returnTime.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Swap Duration"});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        setInitData();
      });
    });
  }

  setInitData() {
    styles = DatePickerRangeStyles();
    receivedData = ModalRoute.of(context)!.settings.arguments as Map;

    print(receivedData!['_startDateTime']);
    print(receivedData!['_endDateTime']);

    if (receivedData!["events"] != null) {
      _calendarEvents = receivedData!["events"];
      print("received events");
      print(_calendarEvents.toString());
      print("received events");
    }

    _firstDate = DateTime.now().subtract(Duration(days: 30));
    _lastDate = DateTime.now().add(Duration(days: 350));

    selectedPeriodStart =
        DateTime.parse(receivedData!['_startDateTime']).toLocal();
    selectedPeriodEnd = DateTime.parse(receivedData!['_endDateTime']).toLocal();

    _pickupTime.value = double.parse(selectedPeriodStart!.hour.toString());
    _returnTime.value = double.parse(selectedPeriodEnd!.hour.toString());

    DateTime curTime = DateTime.now();

    if (selectedPeriodStart!.isBefore(curTime)) {
      selectedPeriodStart = curTime;
    } else {
      _pickupTime.value = double.parse(selectedPeriodStart!.hour.toString());
    }

    if (selectedPeriodEnd!.isBefore(curTime)) {
      selectedPeriodEnd = curTime.add(Duration(days: 4));
    } else {
      _returnTime.value = double.parse(selectedPeriodEnd!.hour.toString());
    }

    if (selectedPeriodStart!.isAfter(selectedPeriodEnd!)) {
      _selectedPeriod = DatePeriod(selectedPeriodEnd!, selectedPeriodStart!);
    } else {
      _selectedPeriod = DatePeriod(selectedPeriodStart!, selectedPeriodEnd!);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("rebuild");

    return Scaffold(
      body: _selectedPeriod != null
          ? Container(
              alignment: Alignment.bottomLeft,
              color: Color.fromRGBO(64, 64, 64, 1),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height / 2,
                  maxHeight: MediaQuery.of(context).size.height - 24,
                ),
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  // height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
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
                              child: Icon(Icons.arrow_back,
                                  color: Color(0xffFF8F68)),
                            ),
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
                      // TODO calendar
                      _selectedPeriod != null
                          ? Container(
                              padding: EdgeInsets.only(
                                  right: 16, bottom: 16, left: 16),
                              child: RangePicker(
                                firstDate: _firstDate!,
                                lastDate: _lastDate!,
                                selectedPeriod: _selectedPeriod!,
                                onChanged: (DatePeriod newPeriod) {
                                  setState(() {
                                    DatePeriod tempPeriod = newPeriod;
                                    print(tempPeriod.start.toString() +
                                        ":::" +
                                        tempPeriod.end.toString());
                                    int diff = tempPeriod.end
                                        .difference(tempPeriod.start)
                                        .inDays;
                                    print(diff);
                                    if (lastSelectedPeriod == null) {
                                      tempPeriod = DatePeriod(
                                          tempPeriod.start,
                                          tempPeriod.end
                                              .add(Duration(days: 1)));
                                    } else {
                                      if (tempPeriod.start
                                          .isBefore(lastSelectedPeriod!.start)) {
                                        print("111");
                                        List<DateTime> dates =
                                            DateUtil.instance.getDaysInBetween(
                                                tempPeriod.start,
                                                lastSelectedPeriod!.start);
                                        bool validity = true;
                                        for (DateTime date in dates) {
                                          if (_isBlockedDate(date)) {
                                            print(DateFormat('yyyy-MM-dd')
                                                .format(date));
                                            validity = false;
                                          }
                                        }
                                        print("validity:::"+validity.toString());
                                        if (validity) {
                                          tempPeriod = DatePeriod(
                                              tempPeriod.start,
                                              lastSelectedPeriod!.start);
                                        } else {
                                          tempPeriod = DatePeriod(
                                              tempPeriod.start,
                                              tempPeriod.end
                                                  .add(Duration(days: 1)));
                                        }
                                      } else if (tempPeriod.start
                                          .isBefore(lastSelectedPeriod!.end)) {
                                        print("222");
                                        tempPeriod = DatePeriod(
                                            tempPeriod.start,
                                            lastSelectedPeriod!.end);
                                      } else {
                                        //TODO
                                        print("333");
                                        if(_checkValidity(DatePeriod(
                                            lastSelectedPeriod!.start,
                                            tempPeriod.end))){
                                          tempPeriod = DatePeriod(
                                              lastSelectedPeriod!.start,
                                              tempPeriod.end);
                                        } else{
                                          tempPeriod = DatePeriod(
                                              tempPeriod.end,
                                              tempPeriod.end.add(Duration(days: 1)));
                                        }

                                      }
                                    }
                                    diff = tempPeriod.end
                                        .difference(tempPeriod.start)
                                        .inDays;
                                    print("diff::" + diff.toString());
                                    if (diff < 1) {
                                      tempPeriod = DatePeriod(
                                          tempPeriod.start,
                                          tempPeriod.end
                                              .add(Duration(days: 1)));
                                    }
                                    if (diff > 29) {
                                      tempPeriod = DatePeriod(
                                          tempPeriod.start,
                                          tempPeriod.start
                                              .add(Duration(days: 29)));
                                    }
                                    _selectedPeriod = tempPeriod;
                                    lastSelectedPeriod = _selectedPeriod;
                                    maintainPickUpAndReturnTime();
                                    _isValidRange(_selectedPeriod!);
                                  });
                                },
                                selectableDayPredicate: (date) {
                                  return (DateTime.now().hour < 22
                                          ? !date.isBefore(DateTime.now()
                                              .subtract(Duration(days: 1)))
                                          : !date.isBefore(DateTime.now())) &&
                                      !_isBlockedDate(date);
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
                                              activeTrackColor:
                                                  Color(0xffFF8F62),
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
                                                    if (DateUtil.instance
                                                            .getFormattedDate(
                                                                _selectedPeriod
                                                                    !.start) ==
                                                        DateUtil.instance
                                                            .getFormattedDate(
                                                                DateTime
                                                                    .now())) {
                                                      int hours = DateTime.now()
                                                          .toLocal()
                                                          .hour;
                                                      if (values.floor() >
                                                          (hours + 1)) {
                                                        _pickupTime.value =
                                                            values;
                                                      }
                                                    } else {
                                                      _pickupTime.value =
                                                          values;
                                                    }
                                                    if (_selectedPeriod!.end
                                                            .difference(
                                                                _selectedPeriod
                                                                    !.start)
                                                            .inDays <=
                                                        1) {
                                                      if (_pickupTime.value >
                                                          _returnTime.value)
                                                        _returnTime.value =
                                                            _pickupTime.value;
                                                    }
                                                  },
                                                  value: _pickupTime.value,
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
                                              activeTrackColor:
                                                  Color(0xffFF8F62),
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
                                                    if (_returnTime.value
                                                            .toInt() ==
                                                        values.toInt()) {
                                                      return;
                                                    }
                                                    if (_selectedPeriod!.end
                                                                .difference(
                                                                    _selectedPeriod
                                                                        !.start)
                                                                .inDays <=
                                                            1 &&
                                                        values.toInt() <
                                                            _pickupTime.value
                                                                .toInt()) {
                                                      return;
                                                    }
                                                    _returnTime.value = values;
                                                  },
                                                  value: _returnTime.value,
                                                );
                                              },
                                            ),
                                          ),
                                        )
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
                                    _selectedPeriod != null
                                        ? Text(
                                            DateFormat('EE, MMM dd')
                                                .format(_selectedPeriod!.start),
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xff371D32),
                                            ),
                                          )
                                        : Text(
                                            DateFormat('EE, MMM dd')
                                                .format(selectedDate),
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xff371D32),
                                            ),
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
                                    _selectedPeriod != null
                                        ? Text(
                                            DateFormat('EE, MMM dd')
                                                .format(_selectedPeriod!.end),
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xff371D32),
                                            ),
                                          )
                                        : Text(
                                            DateFormat('EE, MMM dd')
                                                .format(selectedDate),
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xff371D32),
                                            ),
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
                      Padding(
                        padding:
                            EdgeInsets.only(right: 16, left: 16, bottom: 16),
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
                                      onPressed: () {
                                        String tempPickup =
                                            TimeUtils.getSliderTime(
                                                _pickupTime.value.toInt());
                                        String tempReturn =
                                            TimeUtils.getSliderTime(
                                                _returnTime.value.toInt());

                                        receivedData!['_startDateTime'] =
                                            DateFormat("y-MM-dd").format(
                                                    _selectedPeriod!.start) +
                                                'T' +
                                                tempPickup +
                                                ':00:00.000Z';

                                        receivedData!['_endDateTime'] =
                                            DateFormat("y-MM-dd").format(
                                                    _selectedPeriod!.end) +
                                                'T' +
                                                tempReturn +
                                                ':00:00.000Z';

                                        DateTime startDT = DateTime.parse(
                                                receivedData!["_startDateTime"])
                                            .toUtc();
                                        DateTime endDT = DateTime.parse(
                                                receivedData!["_endDateTime"])
                                            .toUtc();

                                        print(DateTime.now().timeZoneOffset);

                                        startDT = startDT.subtract(
                                            DateTime.now().timeZoneOffset);
                                        endDT = endDT.subtract(
                                            DateTime.now().timeZoneOffset);

                                        print(startDT.toIso8601String());
                                        print(endDT.toIso8601String());

                                        receivedData!["StartDateTime"] =
                                            startDT.toIso8601String();
                                        receivedData!['EndDateTime'] =
                                            endDT.toIso8601String();

                                        print(receivedData!["StartDateTime"]);
                                        print(receivedData!["EndDateTime"]);
                                        Navigator.pop(context, receivedData);
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
            )
          : Container(),
    );
  }

  void maintainPickUpAndReturnTime() {
    print("maintainPickUpAndReturnTime");

    hasError = false;
    error = '';
    if (_selectedPeriod == null) {
      _pickupTime.value = 0.0;
      _returnTime.value = 0.0;
    } else {
      DateTime start = _selectedPeriod!.start;
      DateTime end = _selectedPeriod!.end;

      int hours = DateTime.now().toLocal().hour;

      if (start.day == DateTime.now().day) {
        if (hours + 2 > 23) {
          error = 'Selected day pickup not possible';
          hasError = true;
          return;
          // error
        }
        if (_pickupTime.value <= hours + 2) {
          _pickupTime.value = hours.toDouble() + 2;
        }
        _returnTime.value = _pickupTime.value;
      }
      if (end.day == start.day) {
        if (hours + 2 > 19) {
          // error
          error = 'Same day pickup and return not possible';
          hasError = true;
          return;
        } else {
          if (_pickupTime.value > 19.0) {
            _pickupTime.value = 19.0;
          }
          if (_returnTime.value.toInt() <= _pickupTime.value.toInt() + 3) {
            _returnTime.value = _pickupTime.value + 4;
          }
        }
      }
      if (start.difference(DateTime.now()).inDays >= 1 ||
          start.day != DateTime.now().day) {
        _pickupTime.value = 0.0;
        _returnTime.value = 0.0;
      }
    }
  }

  /*void maintainPickUpAndReturnTime() {
    print("maintainPickUpAndReturnTime");

    hasError = false;
    error = '';
    if (_selectedPeriod == null) {
      _pickupTime.value = 0.0;
      _returnTime.value = 0.0;
    } else {
      DateTime start = _selectedPeriod.start;
      DateTime end = _selectedPeriod.end;

      int hours = DateTime.now().toLocal().hour;

      if (start.day == DateTime.now().day) {
        if (hours + 2 > 23) {
          error = 'Selected day pickup not possible';
          hasError = true;
          return;
          // error
        }
        if (_pickupTime.value <= hours + 2) {
          _pickupTime.value = hours.toDouble() + 2;
        }
        _returnTime.value = _pickupTime.value;
      }
      if (end.day == start.day) {
        if (hours + 2 > 19) {
          // error
          error = 'Same day pickup and return not possible';
          hasError = true;
          return;
        } else {
          if (_pickupTime.value > 19.0) {
            _pickupTime.value = 19.0;
          }
          if (_returnTime.value.toInt() <= _pickupTime.value.toInt() + 3) {
            _returnTime.value = _pickupTime.value + 4;
          }
        }
      }
      if (start.difference(DateTime.now()).inDays >= 1 || start.day != DateTime.now().day) {
        _pickupTime.value = 0.0;
        _returnTime.value = 0.0;
      }
    }
  }*/

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

  /*bool _isBlockedDate(DateTime date) {
    return _calendarEvents.contains(DateFormat('yyyy-MM-dd').format(date)) ||
        (_calendarEvents.contains(DateFormat('yyyy-MM-dd')
                    .format(date.subtract(Duration(days: 1)))) &&
                _calendarEvents.contains(DateFormat('yyyy-MM-dd')
                    .format(date.add(Duration(days: 1)))) ||
            (DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now())) &&
                _calendarEvents.contains(DateFormat('yyyy-MM-dd')
                    .format(date.add(Duration(days: 1)))));
  }*/

  bool _isBlockedDate(DateTime date) {
    return _calendarEvents.contains(DateFormat('yyyy-MM-dd').format(date)) ||
        (_calendarEvents.contains(DateFormat('yyyy-MM-dd')
                    .format(date.subtract(Duration(days: 1)))) &&
                _calendarEvents.contains(DateFormat('yyyy-MM-dd')
                    .format(date.add(Duration(days: 1)))) ||
            (DateFormat('yyyy-MM-dd').format(date) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now())) &&
                _calendarEvents.contains(DateFormat('yyyy-MM-dd')
                    .format(date.add(Duration(days: 1)))));
  }

  bool _checkValidity(DatePeriod _selectedPeriod){
    bool validity = true;
    List<DateTime> dates = DateUtil.instance
        .getDaysInBetween(_selectedPeriod.start, _selectedPeriod.end);

    List<DateTime> d = [];
    for (DateTime date in dates) {
      if (_isBlockedDate(date)) {
        print(DateFormat('yyyy-MM-dd').format(date));
        print("false");
        validity = false;
      } else {
        print(DateFormat('yyyy-MM-dd').format(date));
        print("true");
        d.add(date);
      }
    }

    return validity;
  }

  void _isValidRange(DatePeriod _selectedPeriod) {
    bool validity = true;
    if (lastSelectedDate == null) {
      lastSelectedDate = _selectedPeriod.end;
    }

    print("selected:::" +
        _selectedPeriod.start.toString() +
        ":::" +
        _selectedPeriod.end.toString());

    List<DateTime> dates = DateUtil.instance
        .getDaysInBetween(_selectedPeriod.start, _selectedPeriod.end);

    print("days:::" + dates.toString());
    print("blocked:::" + _calendarEvents.toString());

    List<DateTime> d = [];
    for (DateTime date in dates) {
      if (_isBlockedDate(date)) {
        print(DateFormat('yyyy-MM-dd').format(date));
        print("false");
        validity = false;
      } else {
        print(DateFormat('yyyy-MM-dd').format(date));
        print("true");
        d.add(date);
      }
    }
    print("added:::" + d.toString());
    print("validity:::" + validity.toString());

    if (validity) {
      print("yes yes");
      setState(() {
        this._selectedPeriod = _selectedPeriod;
        if (lastSelectedDate == _selectedPeriod.end) {
          lastSelectedDate = _selectedPeriod.start;
        } else {
          lastSelectedDate = _selectedPeriod.end;
        }
        lastSelectedPeriodNew = _selectedPeriod;
        print("set last:::" +
            lastSelectedPeriodNew!.start.toString() +
            ":::" +
            lastSelectedPeriodNew!.end.toString());
      });
    } else {
      print("no no");
      setState(() {
        if (d.length > 0) {
          print("if");
          if (d[0] == lastSelectedDate) {
            print("if if");
            this._selectedPeriod = DatePeriod(d[d.length - 1], d[d.length - 1]);
            lastSelectedDate = d[d.length - 1];
          } else {
            print("if else");
            print("get last:::" +
                lastSelectedPeriodNew!.start.toString() +
                ":::" +
                lastSelectedPeriodNew!.end.toString());
            this._selectedPeriod = lastSelectedPeriodNew;
            lastSelectedDate = lastSelectedPeriodNew!.end;
            //updateDaySelection(_selectedPeriod.start,_selectedPeriod.end);
          }
        }
      });
    }
  }
}
