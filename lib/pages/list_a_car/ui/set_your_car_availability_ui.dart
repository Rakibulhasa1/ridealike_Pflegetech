import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/list_a_car/bloc/car_availability_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/list_a_car/response_model/daily_mileage_configuration_response.dart';
import 'package:ridealike/pages/list_a_car/response_model/get_calendar_response.dart';
import 'package:ridealike/pages/messages/utils/dateutils.dart';
import 'package:ridealike/utils/empty_cheker.dart';
import 'package:ridealike/widgets/sized_text.dart';

import '../../../utils/app_events/app_events_utils.dart';

class CarAvailabilityUi extends StatefulWidget {
  @override
  State createState() => CarAvailabilityUiState();
}

class CarAvailabilityUiState extends State<CarAvailabilityUi> {
  var carAvailabilityBloc = CarAvailabilityBloc();
  List<DateTime> _selectedDates = [];
  Color selectedDateStyleColor = Color(0xff353B50);

  Color selectedSingleDateDecorationColor = Color(0xFFFF8F68);
  Color disableDateDecorationColor = Colors.grey;

  bool exitPressed = false;

  List<String> _allDates = [];
  List<String> _systemDates = [];
  List<String> _regularDates = [];
  List<String> _currentSelected = [];

  List<DateTime> convertedDates = [];

  Widget? _calendar;
  AsyncSnapshot<List<DateTime>>? blocDatesSnapshot;
  AsyncSnapshot<CreateCarResponse>? availabilityDataSnapshot;

  var purpose;
  bool? pushNeeded;
  String? pushRouteName;
  Map? routeData;
  CreateCarResponse? createCarResponse;
  DatePickerRangeStyles? styles;

  UniqueKey calendarKey = UniqueKey();
  UniqueKey? calendarKeyOld;

  double longMin = 1;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Set You Car Availability"});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      styles = DatePickerRangeStyles(
        disabledDateStyle: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: disableDateDecorationColor),
        selectedDateStyle: Theme.of(context)
            .textTheme
            .bodyText1!
            .copyWith(color: selectedDateStyleColor),
        selectedSingleDateDecoration: BoxDecoration(
            color: selectedSingleDateDecorationColor, shape: BoxShape.circle),
      );

      routeData = ModalRoute.of(context)!.settings.arguments as Map;
      createCarResponse = CreateCarResponse.fromJson(
          (routeData!['carResponse'] as CreateCarResponse).toJson());

      purpose = routeData!['purpose'];
      pushNeeded = routeData!['PUSH'] == null ? false : routeData!['PUSH'];
      pushRouteName = routeData!['ROUTE_NAME'];

      carAvailabilityBloc.changedProgressIndicator.call(0);

      carAvailabilityBloc.callFetchSwapWithinConfiguration().then((value) {
        if (value != null && value.status!.success!) {
          carAvailabilityBloc.changedSwapWithinConfig.call(value);
        } else {
          value = FetchDailyMileageConfigurationResponse(
              listCarConfigurables: ListCarConfigurables(
                  dailyMileageAllowanceLimitRange:
                  DailyMileageAllowanceLimitRange(min: 200, max: 1000),
                  swapWithinMaxLimit: 500));
        }
        if (createCarResponse!.car!.availability!.completed == false) {
          if (isEmpty(createCarResponse
             !.car!.availability!.rentalAvailability!.shortestTrip!)) {
            createCarResponse!.car!.availability!.rentalAvailability!.shortestTrip =
            1;
          }
          if (isEmpty(createCarResponse
             !.car!.availability!.rentalAvailability!.longestTrip!)) {
            createCarResponse!.car!.availability!.rentalAvailability!.longestTrip = 1;
          }

          if (isEmpty(
              createCarResponse!.car!.availability!.swapAvailability!.swapWithin!)) {
            createCarResponse!.car!.availability!.swapAvailability!.swapWithin =
                value.listCarConfigurables!.swapWithinMaxLimit! ~/ 5;
          }

          if (isEmptyString(createCarResponse
             !.car!.availability!.rentalAvailability!.advanceNotice!)) {
            createCarResponse!.car!.availability!.rentalAvailability!.advanceNotice =
            'SameDay';
          }
          if (isEmptyString(createCarResponse
             !.car!.availability!.rentalAvailability!.bookingWindow!)) {
            createCarResponse!.car!.availability!.rentalAvailability!.bookingWindow =
            'AllFutureDates';
          }

          if (isEmpty(createCarResponse
             !.car!.availability!.rentalAvailability!.sameDayCutOffTime!.hours!)) {
            createCarResponse
               !.car!.availability!.rentalAvailability!.sameDayCutOffTime!.hours = 23;
          }
          //
          carAvailabilityBloc
             !.carGetCalendarEvents(createCarResponse!)
              .then((value) {
            if (value != null) {
              carAvailabilityBloc.changedCarAvailabilityData
                  .call(createCarResponse!);
              _systemDates.clear();
              HashSet<String> uniqueDates = HashSet<String>();

              for (Events events in value) {
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
                    //print(formattedDate + ":::" + events.event.creator);
                    if (!uniqueDates.contains(formattedDate)) {
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
                    }
                  }
                }
              }
              carAvailabilityBloc.changedBlocDates.call(convertedDates);
            } else {
              carAvailabilityBloc.changedCarAvailabilityData
                  .call(createCarResponse!);
              carAvailabilityBloc.changedBlocDates.call(_selectedDates);
            }
          });


          //
          //carAvailabilityBloc.changedBlocDates.call(_selectedDates);
          //carAvailabilityBloc.changedCarAvailabilityData.call(createCarResponse);
        } else {
          if (createCarResponse!.car!.availability!.swapAvailability!.swapWithin! <
              value.listCarConfigurables!.swapWithinMaxLimit! ~/ 5 ||
              createCarResponse!.car!.availability!.swapAvailability!.swapWithin! >
                  value.listCarConfigurables!.swapWithinMaxLimit!) {
            createCarResponse!.car!.availability!.swapAvailability!.swapWithin =
                value.listCarConfigurables!.swapWithinMaxLimit! ~/ 5;
          }
          carAvailabilityBloc
             !.carGetCalendarEvents(createCarResponse!)
              .then((value) {
            if (value != null) {
              carAvailabilityBloc.changedCarAvailabilityData
                  .call(createCarResponse!);
              _systemDates.clear();
              HashSet<String> uniqueDates = HashSet<String>();

              for (Events events in value) {
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
                    //print(formattedDate + ":::" + events.event.creator);
                    if (!uniqueDates.contains(formattedDate)) {
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
                    }
                  }
                }
              }
              carAvailabilityBloc.changedBlocDates.call(convertedDates);
            } else {
              carAvailabilityBloc.changedCarAvailabilityData
                  .call(createCarResponse!);
              carAvailabilityBloc.changedBlocDates.call(_selectedDates);
            }
          });
        }
      });
    });


  }

  @override
  Widget build(BuildContext context) {
    print("rebuild");
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      //App Bar
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
            onPressed: () {
              if (pushNeeded!) {
                Navigator.pushNamed(context, pushRouteName!, arguments: {
                  'carResponse': routeData!['carResponse'],
                  'purpose': purpose
                });
              } else {
                Navigator.pop(context);
              }
            }),
        centerTitle: true,
        title: Text(
          '5/6',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: Color(0xff371D32),
          ),
        ),
        actions: <Widget>[
          StreamBuilder<CreateCarResponse>(
              stream: carAvailabilityBloc.carAvailabilityData,
              builder: (context, carAvailabilityDataSnapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        if (!exitPressed) {
                          //TODO
                          exitPressed = true;
                          var res = await carAvailabilityBloc.carAvailability(carAvailabilityDataSnapshot.data!, completed: false, saveAndExit: true);
                          await carAvailabilityBloc.datesBlock(availabilityDataSnapshot!.data!.car!.iD!, convertedDates);
                          Navigator.pushNamed(context, '/dashboard_tab',
                              arguments: res);
                        }
                      },
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(right: 16),
                          child: createCarResponse != null && createCarResponse!.car!.availability!.completed!
                              ? Text('')
                              : Text(
                            'Save & Exit',
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
                );
              }),
        ],
        elevation: 0.0,
      ),

      //Content of tabs
      body: StreamBuilder<CreateCarResponse>(
          stream: carAvailabilityBloc.carAvailabilityData,
          builder: (context, availabilityDataSnapshot) {
            this.availabilityDataSnapshot = availabilityDataSnapshot;
            return availabilityDataSnapshot.hasData &&
                    availabilityDataSnapshot.data != null
                ? Container(
                    child: new SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            // Header
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
                                            'Set vehicle\'s availability',
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
                                Image.asset(
                                    'icons/Calendar_Car-Availability.png'),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Section header
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Text(
                                          'Rental availability',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 18,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Advance notice
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF2F2F2),
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      'Advance notice',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            'Select how much notice you need before the trip can be booked.',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF353B50),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                     
                                                        backgroundColor: availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                   !.advanceNotice ==
                                                                'SameDay'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),),
                                                        onPressed: () {
                                                          availabilityDataSnapshot
                                                              .data
                                                             !.car
                                                              !.availability
                                                             !.rentalAvailability
                                                             !.advanceNotice =
                                                          'SameDay';
                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'SAME DAY',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.advanceNotice ==
                                                                            'SameDay'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),

                                                  backgroundColor: availabilityDataSnapshot
                                                      .data
                                                  !.car
                                                  !.availability
                                                  !.rentalAvailability
                                                  !.advanceNotice ==
                                                      'AtLeast1Day'
                                                      ? Color(0xFFFF8F62)
                                                      : Color(0xFFE0E0E0)
                                                      .withOpacity(
                                                      0.5),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          8.0)),),
                                                        onPressed: () {
                                                          availabilityDataSnapshot
                                                                  .data
                                                                 !.car
                                                                  !.availability
                                                                 !.rentalAvailability
                                                                 !.advanceNotice =
                                                              'AtLeast1Day';
                                                          availabilityDataSnapshot
                                                              .data
                                                             !.car
                                                              !.availability
                                                             !.rentalAvailability
                                                             !.sameDayCutOffTime
                                                              !.hours = 0;
                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                                  availabilityDataSnapshot
                                                                      .data!);
                                                        },
                                                   
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'AT LEAST 1 DAY’S NOTICE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.advanceNotice ==
                                                                            'AtLeast1Day'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                  
                                                        backgroundColor: availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                   !.advanceNotice ==
                                                                'AtLeast3Day'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),),
                                                        onPressed: () {
                                                          availabilityDataSnapshot
                                                              .data
                                                          !.car
                                                          !.availability
                                                          !.rentalAvailability
                                                          !.advanceNotice =
                                                          'AtLeast3Day';
                                                          availabilityDataSnapshot
                                                              .data
                                                          !.car
                                                          !.availability
                                                          !.rentalAvailability
                                                          !.sameDayCutOffTime
                                                          !.hours = 0;
                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'AT LEAST 3 DAYS’ NOTICE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.advanceNotice ==
                                                                            'AtLeast3Day'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                    
                                                        backgroundColor: availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                   !.advanceNotice ==
                                                                'AtLeast5Day'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),),
                                                        onPressed: () {
                                                          availabilityDataSnapshot
                                                              .data
                                                          !.car
                                                          !.availability
                                                          !.rentalAvailability
                                                          !.advanceNotice =
                                                          'AtLeast5Day';
                                                          availabilityDataSnapshot
                                                              .data
                                                          !.car
                                                          !.availability
                                                          !.rentalAvailability
                                                          !.sameDayCutOffTime
                                                              !.hours = 0;
                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'AT LEAST 5 DAYS’ NOTICE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.advanceNotice ==
                                                                            'AtLeast5Day'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                       
                                                        backgroundColor: availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                   !.advanceNotice ==
                                                                'AtLeast7Day'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),),
                                                        onPressed: () {
                                                          availabilityDataSnapshot
                                                              .data
                                                          !.car
                                                          !.availability
                                                          !.rentalAvailability
                                                          !.advanceNotice =
                                                          'AtLeast7Day';
                                                          availabilityDataSnapshot
                                                              .data
                                                          !.car
                                                          !.availability
                                                          !.rentalAvailability
                                                          !.sameDayCutOffTime
                                                              !.hours = 0;
                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'AT LEAST 7 DAYS’ NOTICE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.advanceNotice ==
                                                                            'AtLeast7Day'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Same day cut-off time
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF2F2F2),
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: Container(
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(height: 50,
                                                        width: MediaQuery.of(context).size.width*.55,
                                                        child: AutoSizeText(
                                                          'Same day booking must be made before this time',
                                                          style: TextStyle(
                                                            fontFamily: 'Urbanist',
                                                            fontSize: 16,
                                                            color:
                                                                Color(0xFF371D32),
                                                          ),maxLines: 2,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.sameDayCutOffTime!.hours!.round() > 12 ?
                                                        (availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.sameDayCutOffTime!.hours!.round() - 12)
                                                            : availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.sameDayCutOffTime!.hours!.round() == 0 ? 12
                                                            : availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.sameDayCutOffTime!.hours!.round()}' +
                                                            ':00 ' +
                                                            ''
                                                                '${num.parse(availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.sameDayCutOffTime!.hours!.
                                                            toStringAsFixed(2)) > 11.59 ? 'PM' : 'AM'}',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF353B50),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 8.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: SliderTheme(
                                                          data: SliderThemeData(
                                                            thumbColor: Color(
                                                                0xffFFFFFF),
                                                            trackShape:
                                                                RoundedRectSliderTrackShape(),
                                                            trackHeight: 4.0,
                                                            activeTrackColor:
                                                                Color(
                                                                    0xffFF8F62),
                                                            inactiveTrackColor:
                                                                Color(
                                                                    0xFFE0E0E0),
                                                            tickMarkShape:
                                                                RoundSliderTickMarkShape(
                                                                    tickMarkRadius:
                                                                        4.0),
                                                            activeTickMarkColor:
                                                                Color(
                                                                    0xffFF8F62),
                                                            inactiveTickMarkColor:
                                                                Color(
                                                                    0xFFE0E0E0),
                                                            thumbShape:
                                                                RoundSliderThumbShape(
                                                                    enabledThumbRadius:
                                                                        14.0),
                                                          ),
                                                          child: Slider(
                                                            min: 0.0,
                                                            max: 23.0,
                                                            onChanged: availabilityDataSnapshot
                                                                        .data
                                                                       !.car
                                                                        !.availability
                                                                       !.rentalAvailability
                                                                       !.advanceNotice ==
                                                                    'SameDay'
                                                                ? (values) {
                                                                    availabilityDataSnapshot
                                                                        .data
                                                                       !.car
                                                                        !.availability
                                                                       !.rentalAvailability
                                                                       !.sameDayCutOffTime
                                                                        !.hours = values.round();
                                                                    carAvailabilityBloc
                                                                        .changedCarAvailabilityData
                                                                        .call(availabilityDataSnapshot
                                                                            .data!);
                                                                  }
                                                                : null,

                                                            value: double.parse(
                                                                availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                   !.sameDayCutOffTime
                                                                    !.hours
                                                                    .toString()),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // TODO
                            //booking window//
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF2F2F2),
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      'Booking window',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            'Select how far into the future your car\u0027s calendar will show as available.',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF353B50),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),

                                                        backgroundColor: availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                    !.bookingWindow ==
                                                                'AllFutureDates'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),),
                                                        onPressed: () {
                                                          //TODO
                                                          print(
                                                              "AllFutureDates");

                                                          calendarKey = UniqueKey();

                                                          availabilityDataSnapshot
                                                              .data
                                                          !.car
                                                          !.availability
                                                          !.rentalAvailability
                                                              !.bookingWindow =
                                                          "AllFutureDates";

                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);


                                                          /*  setCalendar(
                                                              styles,
                                                              blocDatesSnapshot,
                                                              availabilityDataSnapshot);*/

                                                          /* carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                                  availabilityDataSnapshot
                                                                      .data!);*/
                                                          /*if( pushNeeded){
                                                            Navigator.pushNamed(context, pushRouteName, arguments:
                                                            {'carResponse': createCarResponse,'purpose':purpose});
                                                          } else {
                                                            Navigator.pop(context);
                                                            Navigator.pushReplacementNamed(
                                                              context,
                                                              '/set_your_car_availability_ui',
                                                              arguments: {'carResponse': createCarResponse,'purpose':purpose},
                                                            );
                                                          }*/
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'ALL FUTURE DATES ARE AVAILABLE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'SF Pro Display Bold',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.bookingWindow ==
                                                                            'AllFutureDates'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),

                                                        backgroundColor: availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                    !.bookingWindow ==
                                                                'Months1'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),),
                                                        onPressed: () {
                                                          //TODO
                                                          print("Months1");
                                                          calendarKey = UniqueKey();
                                                          availabilityDataSnapshot
                                                              .data
                                                          !.car
                                                          !.availability
                                                          !.rentalAvailability
                                                              !.bookingWindow =
                                                          "Months1";
                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);





                                                          //setCalendar(styles, blocDatesSnapshot, availabilityDataSnapshot);
                                                          /*carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                                  availabilityDataSnapshot
                                                                      .data!);*/

                                                          // _bookingWindow.value = "Months1";

                                                          // Navigator.pushReplacementNamed(
                                                          //   context,
                                                          //   '/set_your_car_availability_ui',
                                                          //   arguments: availabilityDataSnapshot
                                                          //       .data,
                                                          // );
                                                          /*if( pushNeeded){

                                                            Navigator.pushNamed(context, pushRouteName, arguments:
                                                            {'carResponse': createCarResponse,'purpose':purpose});
                                                          } else {
                                                            Navigator.pop(context);
                                                            Navigator.pushReplacementNamed(
                                                              context,
                                                              '/set_your_car_availability_ui',
                                                              arguments: {'carResponse': createCarResponse,'purpose':purpose},
                                                            );
                                                          }*/
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  '1 MONTH INTO THE FUTURE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'SF Pro Display Bold',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.bookingWindow ==
                                                                            'Months1'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),

                                                        backgroundColor: availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                    !.bookingWindow ==
                                                                'Months3'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),),
                                                        onPressed: () {
                                                          //TODO
                                                          print("Months3");

                                                          calendarKey = UniqueKey();

                                                          availabilityDataSnapshot
                                                              .data
                                                          !.car
                                                          !.availability
                                                          !.rentalAvailability
                                                              !.bookingWindow =
                                                          "Months3";

                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);

                                                          /* if (pushNeeded) {
                                                            Navigator.pushNamed(
                                                                context,
                                                                pushRouteName,
                                                                arguments: {
                                                                  'carResponse':
                                                                      createCarResponse,
                                                                  'purpose':
                                                                      purpose
                                                                });
                                                          } else {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator
                                                                .pushReplacementNamed(
                                                              context,
                                                              '/set_your_car_availability_ui',
                                                              arguments: {
                                                                'carResponse':
                                                                    createCarResponse,
                                                                'purpose':
                                                                    purpose
                                                              },
                                                            );
                                                          }*/
                                                          // Navigator.pushReplacementNamed(
                                                          //   context,
                                                          //   '/set_your_car_availability_ui',
                                                          //   arguments: availabilityDataSnapshot
                                                          //       .data,
                                                          // );
                                                        },
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  '3 MONTHS INTO THE FUTURE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'SF Pro Display Bold',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.bookingWindow ==
                                                                            'Months3'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                  backgroundColor: availabilityDataSnapshot
                                                      .data
                                                  !.car
                                                  !.availability
                                                  !.rentalAvailability
                                                      !.bookingWindow ==
                                                      'Months6'
                                                      ? Color(0xFFFF8F62)
                                                      : Color(0xFFE0E0E0)
                                                      .withOpacity(
                                                      0.5),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          8.0)),),
                                                        onPressed: () {
                                                          //TODO
                                                          print("Months6");

                                                          calendarKey = UniqueKey();

                                                          availabilityDataSnapshot
                                                                  .data
                                                                 !.car
                                                                  !.availability
                                                                 !.rentalAvailability
                                                                  !.bookingWindow =
                                                              "Months6";

                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);


                                                          /*availabilityDataSnapshot
                                                                  .data
                                                                 !.car
                                                                  !.availability
                                                                 !.rentalAvailability
                                                                  .bookingWindow =
                                                              "Months6";*/
                                                          /* carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                                  availabilityDataSnapshot
                                                                      .data!);*/

                                                          /*if (pushNeeded) {
                                                            Navigator.pushNamed(
                                                                context,
                                                                pushRouteName,
                                                                arguments: {
                                                                  'carResponse':
                                                                      createCarResponse,
                                                                  'purpose':
                                                                      purpose
                                                                });
                                                          } else {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator
                                                                .pushReplacementNamed(
                                                                    context,
                                                                    '/set_your_car_availability_ui',
                                                                    arguments: {
                                                                  'carResponse':
                                                                      createCarResponse,
                                                                  'purpose':
                                                                      purpose
                                                                });
                                                          }*/
                                                        },

                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  '6 MONTHS INTO THE FUTURE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'SF Pro Display Bold',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.bookingWindow ==
                                                                            'Months6'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                  backgroundColor: availabilityDataSnapshot
                                                      .data
                                                  !.car
                                                  !.availability
                                                  !.rentalAvailability
                                                      !.bookingWindow ==
                                                      'Months12'
                                                      ? Color(0xFFFF8F62)
                                                      : Color(0xFFE0E0E0)
                                                      .withOpacity(
                                                      0.5),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius
                                                          .circular(
                                                          8.0)),),
                                                        onPressed: () {
                                                          //TODO
                                                          print("Months12");

                                                          calendarKey = UniqueKey();
                                                          availabilityDataSnapshot
                                                                  .data
                                                                 !.car
                                                                  !.availability
                                                                 !.rentalAvailability
                                                                  !.bookingWindow =
                                                              "Months12";
                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);

                                                          /* availabilityDataSnapshot
                                                                  .data
                                                                 !.car
                                                                  !.availability
                                                                 !.rentalAvailability
                                                                  .bookingWindow =
                                                              "Months12";*/
                                                          /* carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                                  availabilityDataSnapshot
                                                                      .data!);*/
                                                          /*if (pushNeeded) {
                                                            Navigator.pushNamed(
                                                                context,
                                                                pushRouteName,
                                                                arguments: {
                                                                  'carResponse':
                                                                      createCarResponse,
                                                                  'purpose':
                                                                      purpose
                                                                });
                                                          } else {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator
                                                                .pushReplacementNamed(
                                                              context,
                                                              '/set_your_car_availability_ui',
                                                              arguments: {
                                                                'carResponse':
                                                                    createCarResponse,
                                                                'purpose':
                                                                    purpose
                                                              },
                                                            );
                                                          }*/
                                                          // Navigator.pushReplacementNamed(
                                                          //   context,
                                                          //   '/set_your_car_availability_ui',
                                                          //   arguments: availabilityDataSnapshot
                                                          //       .data,
                                                          // );
                                                        },

                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  '12 MONTHS INTO THE FUTURE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'SF Pro Display Bold',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.bookingWindow ==
                                                                            'Months12'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 5),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        backgroundColor: availabilityDataSnapshot
                                                            .data
                                                        !.car
                                                        !.availability
                                                        !.rentalAvailability
                                                            !.bookingWindow ==
                                                            'DatesUnavailable'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                            .withOpacity(
                                                            0.5),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                8.0)),),
                                                        onPressed: () {
                                                          //TODO
                                                          print(
                                                              "DatesUnavailable");
                                                          calendarKey = UniqueKey();
                                                          availabilityDataSnapshot
                                                                  .data
                                                                 !.car
                                                                  !.availability
                                                                 !.rentalAvailability
                                                                  !.bookingWindow =
                                                              "DatesUnavailable";
                                                          carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                              availabilityDataSnapshot
                                                                  .data!);

                                                          /*  availabilityDataSnapshot
                                                                  .data
                                                                 !.car
                                                                  !.availability
                                                                 !.rentalAvailability
                                                                  .bookingWindow =
                                                              "DatesUnavailable";*/
                                                          /* carAvailabilityBloc
                                                              .changedCarAvailabilityData
                                                              .call(
                                                                  availabilityDataSnapshot
                                                                      .data!);*/
                                                          // Navigator.pushReplacementNamed(
                                                          //   context,
                                                          //   '/set_your_car_availability_ui',
                                                          //   arguments: availabilityDataSnapshot
                                                          //       .data,
                                                          // );
                                                          /*if (pushNeeded) {
                                                            Navigator.pushNamed(
                                                                context,
                                                                pushRouteName,
                                                                arguments: {
                                                                  'carResponse':
                                                                      createCarResponse,
                                                                  'purpose':
                                                                      purpose
                                                                });
                                                          } else {
                                                            Navigator.pop(
                                                                context);
                                                            Navigator
                                                                .pushReplacementNamed(
                                                              context,
                                                              '/set_your_car_availability_ui',
                                                              arguments: {
                                                                'carResponse':
                                                                    createCarResponse,
                                                                'purpose':
                                                                    purpose
                                                              },
                                                            );
                                                          }*/
                                                        },

                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'ALL FUTURE DATES ARE UNAVAILABLE',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'SF Pro Display Bold',
                                                                    fontSize:
                                                                        12,
                                                                    color: availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.bookingWindow ==
                                                                            'DatesUnavailable'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                            .withOpacity(0.5),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            //shortest trip//
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF2F2F2),
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: Container(
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        'Shortest trip',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 16,
                                                          color:
                                                              Color(0xFF371D32),
                                                        ),
                                                      ),
                                                      Text(
                                                        carAvailabilityBloc
                                                            .getShortestTripString(
                                                                availabilityDataSnapshot),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF353B50),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 8.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: SliderTheme(
                                                          data: SliderThemeData(
                                                            thumbColor: Color(
                                                                0xffFFFFFF),
                                                            trackShape:
                                                                RoundedRectSliderTrackShape(),
                                                            trackHeight: 4.0,
                                                            activeTrackColor:
                                                                Color(
                                                                    0xffFF8F62),
                                                            inactiveTrackColor:
                                                                Color(
                                                                    0xFFE0E0E0),
                                                            tickMarkShape:
                                                                RoundSliderTickMarkShape(
                                                                    tickMarkRadius:
                                                                        4.0),
                                                            activeTickMarkColor:
                                                                Color(
                                                                    0xffFF8F62),
                                                            inactiveTickMarkColor:
                                                                Color(
                                                                    0xFFE0E0E0),
                                                            thumbShape:
                                                                RoundSliderThumbShape(
                                                                    enabledThumbRadius:
                                                                        14.0),
                                                          ),
                                                          child: Slider(
                                                            min: 1.0,
                                                            max: 9.0,
                                                            onChanged:
                                                                (values) {
                                                              int _value =
                                                                  values
                                                                      .round();
                                                              availabilityDataSnapshot
                                                                  .data
                                                                 !.car
                                                                  !.availability
                                                                 !.rentalAvailability
                                                                  !.shortestTrip = _value;



                                                              carAvailabilityBloc
                                                                  .changedCarAvailabilityData
                                                                  .call(
                                                                      availabilityDataSnapshot
                                                                          .data!);
                                                              setState(() {
                                                                longMin = carAvailabilityBloc.maintainShortLongTrip(availabilityDataSnapshot);
                                                              });

                                                            },
                                                            value: double.parse(
                                                                availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                    !.shortestTrip
                                                                    .toString()),
                                                            divisions: 9,
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Longest trip
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF2F2F2),
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: Container(
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        'Longest trip',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 16,
                                                          color:
                                                              Color(0xFF371D32),
                                                        ),
                                                      ),
                                                      Text(
                                                        carAvailabilityBloc
                                                            .getLongestTripToString(
                                                                availabilityDataSnapshot),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF353B50),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 8.0),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: SliderTheme(
                                                          data: SliderThemeData(
                                                            thumbColor: Color(
                                                                0xffFFFFFF),
                                                            trackShape:
                                                                RoundedRectSliderTrackShape(),
                                                            trackHeight: 4.0,
                                                            activeTrackColor:
                                                                Color(
                                                                    0xffFF8F62),
                                                            inactiveTrackColor:
                                                                Color(
                                                                    0xFFE0E0E0),
                                                            tickMarkShape:
                                                                RoundSliderTickMarkShape(
                                                                    tickMarkRadius:
                                                                        4.0),
                                                            activeTickMarkColor:
                                                                Color(
                                                                    0xffFF8F62),
                                                            inactiveTickMarkColor:
                                                                Color(
                                                                    0xFFE0E0E0),
                                                            thumbShape:
                                                                RoundSliderThumbShape(
                                                                    enabledThumbRadius:
                                                                        14.0),
                                                          ),
                                                          child: Slider(
                                                            min: longMin,
                                                            max: 30.0,
                                                            onChanged:
                                                                (values) {
                                                              int _value =
                                                                  values
                                                                      .round();
                                                              availabilityDataSnapshot
                                                                  .data
                                                                 !.car
                                                                  !.availability
                                                                 !.rentalAvailability
                                                                  !.longestTrip = _value;
                                                              carAvailabilityBloc
                                                                  .changedCarAvailabilityData
                                                                  .call(
                                                                      availabilityDataSnapshot
                                                                          .data!);
                                                            },
                                                            value: double.parse(
                                                                availabilityDataSnapshot
                                                                    .data
                                                                   !.car
                                                                    !.availability
                                                                   !.rentalAvailability
                                                                    !.longestTrip
                                                                    .toString()),

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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Manage calendar//
                            StreamBuilder<List<DateTime>>(
                                stream: carAvailabilityBloc.blocDates,
                                builder: (context, blocDatesSnapshot) {
                                  this.blocDatesSnapshot = blocDatesSnapshot;
                                  return blocDatesSnapshot.hasData &&
                                          blocDatesSnapshot.data != null
                                      ? Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Color(0xFFF2F2F2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                                child: Padding(
                                                  padding: EdgeInsets.all(16.0),
                                                  child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                            'Manage your calendar',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Roboto',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 5),
                                                      Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'Dates highlighted in grey indicate your vehicle is unavailable for booking',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                        0xFF353B50),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 20),
                                                      //TODO
                                                      //_calendar,
                                                      //
                                                      DayPicker
                                                          .multi(
                                                        key: calendarKey,
                                                        selectedDates: blocDatesSnapshot.data!.length ==
                                                                0
                                                            ? List.generate(
                                                                1,
                                                                (index) => DateTime
                                                                        .now()
                                                                    .subtract(
                                                                        Duration(
                                                                            days:
                                                                                1)))
                                                            : blocDatesSnapshot
                                                                .data as List<DateTime>,
                                                        firstDate:
                                                            DateTime.now()
                                                                .subtract(
                                                                    Duration(
                                                                        days:
                                                                            0)),
                                                        lastDate: _getLastDate(
                                                            status: availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.availability
                                                               !.rentalAvailability
                                                                !.bookingWindow!),
                                                        datePickerStyles:
                                                            styles,
                                                        selectableDayPredicate:
                                                            (date) {
                                                          return availabilityDataSnapshot
                                                                      .data
                                                                     !.car
                                                                      !.availability
                                                                     !.rentalAvailability
                                                                      !.bookingWindow ==
                                                                  'DatesUnavailable'
                                                              ? false
                                                              : !date.isBefore(DateTime
                                                                      .now()
                                                                  .subtract(
                                                                      Duration(
                                                                          days:
                                                                              1)));
                                                        },
                                                        eventDecorationBuilder:
                                                            _eventDecorationBuilder,
                                                        onChanged:
                                                            (List<DateTime>
                                                                newDates) {
                                                          newDates.removeWhere(
                                                              (element) => element
                                                                  .isBefore(DateTime
                                                                          .now()
                                                                      .subtract(
                                                                          Duration(
                                                                              days: 1))));

                                                          print("before:::" +
                                                              newDates.length
                                                                  .toString());

                                                          newDates.forEach(
                                                              (element) {
                                                            print(element
                                                                .toIso8601String());
                                                          });

                                                          newDates.removeWhere(
                                                              (element) =>
                                                                  _isSystemDate(
                                                                      element));

                                                          print("after:::" +
                                                              newDates.length
                                                                  .toString());

                                                          _currentSelected
                                                              .clear();
                                                          newDates.forEach(
                                                              (element) {
                                                            _currentSelected
                                                                .add(DateFormat(
                                                                        'yyyy-MM-dd')
                                                                    .format(element
                                                                        .toLocal())
                                                                    .toString());
                                                          });

                                                          var set1 = Set.from(
                                                              _regularDates);
                                                          var set2 = Set.from(
                                                              _currentSelected);

                                                          _regularDates =
                                                              List.from(set1
                                                                  .difference(
                                                                      set2));

                                                          _selectedDates =
                                                              newDates;
                                                          carAvailabilityBloc
                                                              .changedBlocDates
                                                              .call(newDates);
                                                        },
                                                        datePickerLayoutSettings:
                                                            DatePickerLayoutSettings(
                                                          showPrevMonthEnd:
                                                              false,
                                                          showNextMonthStart:
                                                              false,
                                                          maxDayPickerRowCount:
                                                              6,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container();
                                }),
                            SizedBox(height: 30),
                            // Section header
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: Text(
                                                'Swap area',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 18,
                                                  color: Color(0xFF371D32),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 10)
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Select the maximum distance for visibility of your vehicle by other hosts looking to swap',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Color(0xFF353B50),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 10)
                                : new Container(),
                            // Swap within
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: StreamBuilder<
                                                FetchDailyMileageConfigurationResponse>(
                                            stream: carAvailabilityBloc
                                                .swapWithinConfig,
                                            builder: (context,
                                                swapWithinConfigSnapshot) {
                                              return swapWithinConfigSnapshot
                                                          .hasData &&
                                                      swapWithinConfigSnapshot
                                                              .data !=
                                                          null
                                                  ? Column(
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Color(
                                                                    0xFFF2F2F2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                            child: Container(
                                                              child: Column(
                                                                children: <
                                                                    Widget>[
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            16.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                          'Swap within',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Roboto',
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Color(0xFF371D32),
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          double.parse(availabilityDataSnapshot.data!.car!.availability!.swapAvailability!.swapWithin.toString()).round().toString() +
                                                                              ' km',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Urbanist',
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Color(0xFF353B50),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        bottom:
                                                                            8.0),
                                                                    child: Row(
                                                                      children: <
                                                                          Widget>[
                                                                        Expanded(
                                                                          child:
                                                                              SliderTheme(
                                                                            data:
                                                                                SliderThemeData(
                                                                              thumbColor: Color(0xffFFFFFF),
                                                                              trackShape: RoundedRectSliderTrackShape(),
                                                                              trackHeight: 4.0,
                                                                              activeTrackColor: Color(0xffFF8F62),
                                                                              inactiveTrackColor: Color(0xFFE0E0E0),
                                                                              tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                                                              activeTickMarkColor: Color(0xffFF8F62),
                                                                              inactiveTickMarkColor: Color(0xFFE0E0E0),
                                                                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                                                            ),
                                                                            child:
                                                                                Slider(
                                                                              min: double.parse((swapWithinConfigSnapshot.data!.listCarConfigurables!.swapWithinMaxLimit! ~/ 5).toString()),
                                                                              max: double.parse(swapWithinConfigSnapshot.data!.listCarConfigurables!.swapWithinMaxLimit.toString()),
                                                                              onChanged: (values) {
                                                                                availabilityDataSnapshot.data!.car!.availability!.swapAvailability!.swapWithin = values.toInt();
                                                                                carAvailabilityBloc.changedCarAvailabilityData.call(availabilityDataSnapshot.data!);
                                                                              },
                                                                              value: double.parse(availabilityDataSnapshot.data!.car!.availability!.swapAvailability!.swapWithin.toString()),
                                                                              divisions: 4,
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
                                                      ],
                                                    )
                                                  : Container();
                                            }),
                                      ),
                                    ],
                                  )
                                : new Container(),
                            // Section header
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 30)
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: Text(
                                                'Swap vehicle types',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 18,
                                                  color: Color(0xFF371D32),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 10)
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Select the types of vehicles that you are interested in swapping your vehicle for.',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Color(0xFF353B50),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 10)
                                : new Container(),
                            // Economy
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xFFF2F2F2),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.economy =
                                                        !availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.economy!;
                                                    carAvailabilityBloc
                                                        .changedCarAvailabilityData
                                                        .call(
                                                            availabilityDataSnapshot
                                                                .data!);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          Text(
                                                            'Economy Car',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                        ]),
                                                      ),
                                                      Icon(
                                                        Icons.check,
                                                        size: 20,
                                                        color: availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.availability
                                                                !.swapAvailability
                                                                !.swapVehiclesType
                                                                !.economy!
                                                            ? Color(0xFFFF8F68)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 10)
                                : new Container(),
                            // Mid-Full-Size
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xFFF2F2F2),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.midFullSize =
                                                        !availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.midFullSize!;
                                                    carAvailabilityBloc
                                                        .changedCarAvailabilityData
                                                        .call(
                                                            availabilityDataSnapshot
                                                                .data!);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          Text(
                                                            'Mid/Full-size Car',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                        ]),
                                                      ),
                                                      Icon(
                                                        Icons.check,
                                                        size: 20,
                                                        color: availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.availability
                                                                !.swapAvailability
                                                                !.swapVehiclesType
                                                                !.midFullSize!
                                                            ? Color(0xFFFF8F68)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 10)
                                : new Container(),
                            // Sport
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xFFF2F2F2),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.sports =
                                                        !availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.sports!;
                                                    carAvailabilityBloc
                                                        .changedCarAvailabilityData
                                                        .call(
                                                            availabilityDataSnapshot
                                                                .data!);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          Text(
                                                            'Sports Car',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                        ]),
                                                      ),
                                                      Icon(
                                                        Icons.check,
                                                        size: 20,
                                                        color: availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.availability
                                                                !.swapAvailability
                                                                !.swapVehiclesType
                                                                !.sports!
                                                            ? Color(0xFFFF8F68)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xFFF2F2F2),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.suv =
                                                        !availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.suv!;
                                                    carAvailabilityBloc
                                                        .changedCarAvailabilityData
                                                        .call(
                                                            availabilityDataSnapshot
                                                                .data!);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          Text(
                                                            'SUV',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                        ]),
                                                      ),
                                                      Icon(
                                                        Icons.check,
                                                        size: 20,
                                                        color: availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.availability
                                                                !.swapAvailability
                                                                !.swapVehiclesType
                                                                !.suv!
                                                            ? Color(0xFFFF8F68)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
//                                      Expanded(
//                                        child: new Container(),
//                                      ),
                                    ],
                                  )
                                : new Container(),

                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 10)
                                : new Container(),
                            // Pick-up truck & Minivan
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xFFF2F2F2),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                           ! .swapVehiclesType
                                                            !.pickupTruck =
                                                        !availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                           ! .pickupTruck!;
                                                    carAvailabilityBloc
                                                        .changedCarAvailabilityData
                                                        .call(
                                                            availabilityDataSnapshot
                                                                .data!);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          SizedText(
                                                            deviceWidth: deviceWidth,
                                                            textWidthPercentage: 0.27,
                                                            text: 'Pick-up truck',
                                                            fontFamily:
                                                            'Urbanist',
                                                            fontSize: 16,
                                                            textColor: Color(
                                                                0xFF371D32),
                                                          ),
                                                        ]),
                                                      ),
                                                      Icon(
                                                        Icons.check,
                                                        size: 20,
                                                        color: availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.availability
                                                                !.swapAvailability
                                                                !.swapVehiclesType
                                                                !.pickupTruck!
                                                            ? Color(0xFFFF8F68)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xFFF2F2F2),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.minivan =
                                                        !availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.minivan!;
                                                    carAvailabilityBloc
                                                        .changedCarAvailabilityData
                                                        .call(
                                                            availabilityDataSnapshot
                                                                .data!);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          Text(
                                                            'Minivan',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                        ]),
                                                      ),
                                                      Icon(
                                                        Icons.check,
                                                        size: 20,
                                                        color: availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.availability
                                                                !.swapAvailability
                                                                !.swapVehiclesType
                                                                !.minivan!
                                                            ? Color(0xFFFF8F68)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 10)
                                : new Container(),
                            //Van//
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xFFF2F2F2),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.van =
                                                        !availabilityDataSnapshot
                                                            .data
                                                           !.car
                                                            !.availability
                                                            !.swapAvailability
                                                            !.swapVehiclesType
                                                            !.van!;
                                                    carAvailabilityBloc
                                                        .changedCarAvailabilityData
                                                        .call(
                                                            availabilityDataSnapshot
                                                                .data!);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          Text(
                                                            'Van',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                        ]),
                                                      ),
                                                      Icon(
                                                        Icons.check,
                                                        size: 20,
                                                        color: availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.availability
                                                                !.swapAvailability
                                                                !.swapVehiclesType
                                                                !.van!
                                                            ? Color(0xFFFF8F68)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: new Container(),
                                      ),
                                    ],
                                  )
                                : new Container(),
                            availabilityDataSnapshot
                                    .data!.car!.preference!.listingType!.swapEnabled!
                                ? SizedBox(height: 30)
                                : new Container(),
                            //Next button//
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: StreamBuilder<int>(
                                            stream: carAvailabilityBloc
                                                .progressIndicator,
                                            builder: (context,
                                                progressIndicatorSnapshot) {
                                              return ElevatedButton(style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                backgroundColor: Color(0xFFFF8F62),
                                                padding: EdgeInsets.all(16.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),),
                                                onPressed: progressIndicatorSnapshot
                                                                .data ==
                                                            1 ||
                                                        availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.preference
                                                                !.listingType
                                                                !.swapEnabled! &&
                                                            carAvailabilityBloc
                                                                .checkButtonDisability(
                                                                    availabilityDataSnapshot
                                                                        .data!)
                                                    ? null
                                                    : () async {
                                                        // Set blocked dates
                                                        //TODO
//
                                                        carAvailabilityBloc
                                                            .changedProgressIndicator
                                                            .call(1);

                                                        //


                                                        //

                                                        var res =
                                                            await carAvailabilityBloc
                                                               !.carAvailability(
                                                                    availabilityDataSnapshot
                                                                        .data!);

                                                        await carAvailabilityBloc
                                                            .datesBlock(
                                                            availabilityDataSnapshot
                                                                .data
                                                               !.car
                                                                !.iD!,
                                                            convertedDates);

                                                        if (res != null) {
                                                          if (pushNeeded!) {
                                                            Navigator.pushNamed(
                                                                context,
                                                                pushRouteName!,
                                                                arguments: {
                                                                  'carResponse':
                                                                      res,
                                                                  'purpose':
                                                                      purpose
                                                                });
                                                          } else {
                                                            Navigator.pop(
                                                                context, res);
                                                          }
                                                        }
                                                      },
                                                child: progressIndicatorSnapshot
                                                            .data ==
                                                        0
                                                    ? Text(
                                                        'Next',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    : SizedBox(
                                                        height: 18.0,
                                                        width: 18.0,
                                                        child:
                                                            new CircularProgressIndicator(
                                                                strokeWidth:
                                                                    2.5),
                                                      ),
                                              );
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new CircularProgressIndicator(strokeWidth: 2.5)
                      ],
                    ),
                  );
          }),
    );
  }

  bool _isSelectableDate(DateTime date) {
    bool result =
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

  DateTime _getLastDate({String status = ""}) {
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
    return time;
  }

  void setCalendar(var styles, var blocDatesSnapshot,
      var availabilityDataSnapshot) {
    print("yes yes 11");

    if (blocDatesSnapshot != null) {
      print(_getLastDate(
          status: availabilityDataSnapshot
              .data!.car!.availability!.rentalAvailability!.bookingWindow)
          .toString());
      _calendar = DayPicker.multi(
        key: UniqueKey(),
        selectedDates: blocDatesSnapshot.data.length == 0
            ? List.generate(
            1, (index) => DateTime.now().subtract(Duration(days: 1)))
            : blocDatesSnapshot.data,
        firstDate: DateTime.now().subtract(Duration(days: 0)),
        lastDate: _getLastDate(
            status: availabilityDataSnapshot
                .data!.car!.availability!.rentalAvailability!.bookingWindow),
        datePickerStyles: styles,
        selectableDayPredicate: (date) {
          return availabilityDataSnapshot.data!.car!.availability
             !.rentalAvailability.bookingWindow ==
              'DatesUnavailable'
              ? false
              : !date.isBefore(DateTime.now().subtract(Duration(days: 1)));
        },
        eventDecorationBuilder: _eventDecorationBuilder,
        onChanged: (List<DateTime> newDates) {
          newDates.removeWhere((element) =>
              element.isBefore(DateTime.now().subtract(Duration(days: 1))));

          print("before:::" + newDates.length.toString());

          newDates.forEach((element) {
            print(element.toIso8601String());
          });

          newDates.removeWhere((element) => _isSystemDate(element));

          print("after:::" + newDates.length.toString());

          _currentSelected.clear();
          newDates.forEach((element) {
            _currentSelected.add(DateFormat('yyyy-MM-dd')
                .format(element.toLocal())
                .toString());
          });

          var set1 = Set.from(_regularDates);
          var set2 = Set.from(_currentSelected);

          _regularDates = List.from(set1.difference(set2));

          _selectedDates = newDates;
          carAvailabilityBloc.changedBlocDates.call(newDates);
        },
        datePickerLayoutSettings: DatePickerLayoutSettings(
          showPrevMonthEnd: false,
          showNextMonthStart: false,
          maxDayPickerRowCount: 6,
        ),
      );
    }
  }
}
