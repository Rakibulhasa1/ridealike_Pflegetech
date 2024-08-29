import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/list_a_car/bloc/car_availability_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/list_a_car/response_model/get_calendar_response.dart';
import 'package:ridealike/pages/messages/utils/dateutils.dart';

import '../list_a_car/ui/price_your_car_ui.dart';

class DashboardManageCalendar extends StatefulWidget {
  @override
  _DashboardManageCalendarState createState() =>
      _DashboardManageCalendarState();
}

class _DashboardManageCalendarState extends State<DashboardManageCalendar> {
  var carAvailabilityBloc = CarAvailabilityBloc();
  DateTime? _firstDate;
  DateTime? _lastDate;
  List<DateTime> _selectedDates = [];
  List<String> _allDates = [];
  List<String> _systemDates = [];
  List<String> _regularDates = [];
  List<String> _currentSelected = [];

  Color selectedDateStyleColor = Color(0xff353B50);

  Color selectedSingleDateDecorationColor = Color(0xFFFF8F68);
  Color disableDateDecorationColor = Colors.grey;

  List<DateTime> convertedDates = [];

  @override
  void initState() {
    super.initState();
    _firstDate = DateTime.now().subtract(Duration(days: 30));
    _lastDate = DateTime.now().add(Duration(days: 365));
  }

  @override
  Widget build(BuildContext context) {
    //print(ModalRoute.of(context).settings.arguments.toString());

    DatePickerRangeStyles styles = DatePickerRangeStyles(
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

    CreateCarResponse createCarResponse =
        ModalRoute.of(context)!.settings.arguments as CreateCarResponse;

    carAvailabilityBloc.changedProgressIndicator.call(0);

    carAvailabilityBloc.callFetchSwapWithinConfiguration().then((value) {
      if (value != null) {
        carAvailabilityBloc.changedSwapWithinConfig.call(value);
        if (createCarResponse.car!.availability!.completed == false) {
          createCarResponse.car!.availability!.rentalAvailability!.advanceNotice =
              'SameDay';
          createCarResponse.car!.availability!.swapAvailability!.swapWithin = 100;
        }
      }
      if (createCarResponse.car!.availability!.completed == false) {
        createCarResponse.car!.availability!.swapAvailability!.swapVehiclesType
            !.midFullSize = true;
        createCarResponse
            .car!.availability!.swapAvailability!.swapVehiclesType!.sports = true;
        createCarResponse
            .car!.availability!.swapAvailability!.swapVehiclesType!.suv = true;
//        createCarResponse.car!.availability.swapAvailability.swapVehiclesType.sportsSUV = false;

        createCarResponse.car!.availability!.rentalAvailability!.shortestTrip = 1;
        createCarResponse.car!.availability!.rentalAvailability!.longestTrip = 1;
        createCarResponse.car!.availability!.swapAvailability!.swapWithin = 100;
        createCarResponse.car!.availability!.rentalAvailability!.advanceNotice =
            'SameDay';
        createCarResponse
            .car!.availability!.rentalAvailability!.sameDayCutOffTime!.hours = 12;
        carAvailabilityBloc.changedBlocDates.call(_selectedDates);
        carAvailabilityBloc.changedCarAvailabilityData.call(createCarResponse);
      } else {
        if (createCarResponse.car!.availability!.swapAvailability!.swapWithin! <
            10) {
          createCarResponse.car!.availability!.swapAvailability!.swapWithin = 10;
        }
        carAvailabilityBloc
            .carGetCalendarEvents(createCarResponse)
            .then((value) {
          if (value != null) {
            carAvailabilityBloc.changedCarAvailabilityData
                .call(createCarResponse);
            _systemDates.clear();
            HashSet<String> uniqueDates = HashSet<String>();

            for (Events events in value) {
              // TODO calendar block date range
              DateTime startDateTime =
                  DateTime.parse(events.event!.startDatetime!);
              DateTime endDateTime = DateTime.parse(events.event!.endDatetime!);
              List<DateTime> eventDateTimes = DateUtil.instance
                  .getDaysInBetween(startDateTime, endDateTime);
              for (DateTime eventDateTime in eventDateTimes) {
                if (eventDateTime
                    .isAfter(DateTime.now().subtract(Duration(days: 1)))) {
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(eventDateTime);
                  print(formattedDate + ":::" + events.event!.creator!);
                  //if (!uniqueDates.contains(formattedDate)) {
                    uniqueDates.add(formattedDate);
                    convertedDates.add(eventDateTime.toLocal());
                    _allDates.add(DateFormat('yyyy-MM-dd')
                        .format(eventDateTime.toLocal())
                        .toString());
                    if (events.event!.creator == "system") {
                      _systemDates.add(DateFormat('yyyy-MM-dd')
                          .format(eventDateTime.toLocal())
                          .toString());
                    } else {
                      _regularDates.add(DateFormat('yyyy-MM-dd')
                          .format(eventDateTime.toLocal())
                          .toString());
                      _currentSelected = _regularDates;
                    }
                  //}
                }
              }
            }
            carAvailabilityBloc.changedBlocDates.call(convertedDates);
          } else {
            carAvailabilityBloc.changedCarAvailabilityData
                .call(createCarResponse);
            carAvailabilityBloc.changedBlocDates.call(_selectedDates);
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
      ),
      body: StreamBuilder<CreateCarResponse>(
          stream: carAvailabilityBloc.carAvailabilityData,
          builder: (context, availabilityDataSnapshot) {
            return availabilityDataSnapshot.hasData &&
                    availabilityDataSnapshot.data != null
                ? SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        child: Text(
                                          'Manage car Availability',
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 36,
                                              color: Color(0xFF371D32),
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SvgPicture.asset('svg/event.svg'),
                            ],
                          ),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              SvgPicture.asset('svg/color rec.svg'),
                              SizedBox(width: 10,),
                              Text('The car is unavailable for booking',style: TextStyle(fontFamily: 'Urbanist',fontSize: 19),),
                            ],
                          ),
                          SizedBox(height: 35),
                          StreamBuilder<List<DateTime>>(
                              stream: carAvailabilityBloc.blocDates,
                              builder: (context, blocDatesSnapshot) {
                                return blocDatesSnapshot.hasData
                                    ? DayPicker.multi(
                                        selectedDates:
                                            blocDatesSnapshot.data!.length == 0
                                                ? List.generate(
                                                    1,
                                                    (index) => DateTime.now()
                                                        .subtract(
                                                            Duration(days: 1)))
                                                : blocDatesSnapshot.data as List<DateTime>,
                                        firstDate: _firstDate!,
                                        lastDate: _lastDate!,
                                        selectableDayPredicate:
                                            _isSelectableDate,
                                        datePickerStyles: styles,
                                        eventDecorationBuilder:
                                            _eventDecorationBuilder,
                                        onChanged: (List<DateTime> newDates) {
                                          newDates.removeWhere((element) =>
                                              element.isBefore(DateTime.now()
                                                  .subtract(
                                                      Duration(days: 1))));

                                          print("before:::" +
                                              newDates.length.toString());

                                          newDates.forEach((element) {
                                            print(element.toIso8601String());
                                          });

                                          newDates.removeWhere((element) =>
                                              _isSystemDate(element));

                                          print("after:::" +
                                              newDates.length.toString());

                                          _currentSelected.clear();
                                          newDates.forEach((element) {
                                            _currentSelected.add(
                                                DateFormat('yyyy-MM-dd')
                                                    .format(element.toLocal())
                                                    .toString());
                                          });

                                          var set1 = Set.from(_regularDates);
                                          var set2 = Set.from(_currentSelected);

                                          _regularDates =
                                              List.from(set1.difference(set2));

                                          _selectedDates = newDates;
                                          carAvailabilityBloc.changedBlocDates
                                              .call(newDates);
                                        },
                                        datePickerLayoutSettings:
                                           DatePickerLayoutSettings(
                                          showPrevMonthEnd: false,
                                          showNextMonthStart: false,
                                          maxDayPickerRowCount: 6,
                                        ),
                                      )
                                    : Container();
                              }),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Color(0xFFFF8F62),width:1.5),
                                    padding: EdgeInsets.all(12.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/dashboard_edit_pricing',
                                      arguments: {
                                        'carResponse': createCarResponse,
                                        'pushNeeded': true,
                                      },
                                    );
                                  },
                                  child: Text(
                                    'Edit pricing',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: StreamBuilder<int>(
                                  stream: carAvailabilityBloc.progressIndicator,
                                  builder: (context, progressIndicatorSnapshot) {
                                    return ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xFFFF8F62),
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8.0),
                                        ),
                                      ),
                                      onPressed: progressIndicatorSnapshot.data == 1
                                          ? null
                                          : () async {
                                        // Set blocked dates
                                        carAvailabilityBloc.changedProgressIndicator.call(1);
                                        await carAvailabilityBloc.datesBlock(
                                          createCarResponse.car!.iD!,
                                          convertedDates,
                                        );

                                        Navigator.pop(context);
                                      },
                                      child: progressIndicatorSnapshot.data == 0
                                          ? Text(
                                        'Save calendar',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      )
                                          : SizedBox(
                                        height: 18.0,
                                        width: 18.0,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

//                           Row(
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   children: [
//                                     SizedBox(
//                                       width: double.maxFinite,
//                                       child: StreamBuilder<int>(
//                                           stream: carAvailabilityBloc
//                                               .progressIndicator,
//                                           builder: (context,
//                                               progressIndicatorSnapshot) {
//                                             return ElevatedButton(style: ElevatedButton.styleFrom(
//                                               elevation: 0.0,
//                                               backgroundColor: Color(0xFFFF8F62),
//                                               padding: EdgeInsets.all(16.0),
//                                               shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.circular(
//                                                           8.0)),),
//                                               onPressed:
//                                                   progressIndicatorSnapshot
//                                                               .data ==
//                                                           1
//                                                       ? null
//                                                       : () async {
//                                                           // Set blocked dates
// //
//                                                           carAvailabilityBloc
//                                                               .changedProgressIndicator
//                                                               .call(1);
//                                                           await carAvailabilityBloc
//                                                               .datesBlock(
//                                                                   createCarResponse
//                                                                       .car!.iD!,
//                                                                   convertedDates);
//
//                                                           Navigator.pop(
//                                                               context);
//
//                                                           /*var res = await carAvailabilityBloc
//                                                               .carAvailability(
//                                                                   createCarResponse);
//
//                                                           if (res != null) {
//                                                             Navigator.pop(
//                                                                 context, res);
//                                                           }*/
//                                                         },
//                                               child: progressIndicatorSnapshot
//                                                           .data ==
//                                                       0
//                                                   ? Text(
//                                                       'Save',
//                                                       style: TextStyle(
//                                                           fontFamily:
//                                                               'Urbanist',
//                                                           fontSize: 18,
//                                                           color: Colors.white),
//                                                     )
//                                                   : SizedBox(
//                                                       height: 18.0,
//                                                       width: 18.0,
//                                                       child:
//                                                           new CircularProgressIndicator(
//                                                               strokeWidth: 2.5),
//                                                     ),
//                                             );
//                                           }),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
                        ],
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        CircularProgressIndicator(strokeWidth: 2.5)
                      ],
                    ),
                  );
          }),
    );
  }

  bool _isSelectableDate(DateTime date) {
    bool result = date.isBefore(DateTime.now().subtract(Duration(days: 1))) ||
        _systemDates.contains(DateFormat('yyyy-MM-dd').format(date.toLocal()));
    return !result;
  }

  bool _isSystemDate(DateTime date) {
    bool result =
        _systemDates.contains(DateFormat('yyyy-MM-dd').format(date.toLocal()));
    return result;
  }

  bool _isEventDate(DateTime date) {
    bool result =
        _regularDates.contains(DateFormat('yyyy-MM-dd').format(date.toLocal()));
    return result;
  }

  bool _isSelectedDate(DateTime date) {
    bool result = _currentSelected
        .contains(DateFormat('yyyy-MM-dd').format(date.toLocal()));
    return result;
  }

  EventDecoration _eventDecorationBuilder(DateTime date) {
    if (_isSystemDate(date)) {
      return EventDecoration(
          boxDecoration: BoxDecoration(
              color: Colors.grey.shade300, shape: BoxShape.circle));
    }
    if (_isEventDate(date) || _isSelectedDate(date)) {
      return EventDecoration(
          boxDecoration: BoxDecoration(
              color: Colors.grey.shade300, shape: BoxShape.circle));
    }
    return EventDecoration(
        boxDecoration:
            BoxDecoration(color: Colors.transparent, shape: BoxShape.circle));
  }
}
