import 'dart:collection';
import 'dart:convert';

import 'package:flutter/src/widgets/async.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/request_service/car_availability_request.dart';
import 'package:ridealike/pages/list_a_car/request_service/car_preference_request.dart';
import 'package:ridealike/pages/list_a_car/request_service/get_calendar_by_id.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/list_a_car/response_model/daily_mileage_configuration_response.dart';
import 'package:ridealike/pages/list_a_car/response_model/get_calendar_response.dart';
import 'package:ridealike/pages/messages/utils/dateutils.dart';
import 'package:rxdart/rxdart.dart';

class CarAvailabilityBloc extends Object with Validators implements BaseBloc {
  final _carAvailabilityDataController = BehaviorSubject<CreateCarResponse>();
  final _swapWithinConfigController =
      BehaviorSubject<FetchDailyMileageConfigurationResponse>();
  final _blocDatesController = BehaviorSubject<List<DateTime>>();
  final _swapEnableController = BehaviorSubject<bool>();

  List<DateTime> storeDates = <DateTime>[];

  Function(CreateCarResponse) get changedCarAvailabilityData =>
      _carAvailabilityDataController.sink.add;

  Function(FetchDailyMileageConfigurationResponse)
      get changedSwapWithinConfig => _swapWithinConfigController.sink.add;

  Function(List<DateTime>) get changedBlocDates =>
      _blocDatesController.sink.add;

  Function(bool) get changedSwapEnable => _swapEnableController.sink.add;

  Stream<CreateCarResponse> get carAvailabilityData =>
      _carAvailabilityDataController.stream;

  Stream<FetchDailyMileageConfigurationResponse> get swapWithinConfig =>
      _swapWithinConfigController.stream;

  Stream<List<DateTime>> get blocDates => _blocDatesController.stream;

  Stream<bool> get swapEnable => _swapEnableController.stream;

  //progressIndicator//
  final _progressIndicatorController = BehaviorSubject<int>();

  Function(int) get changedProgressIndicator =>
      _progressIndicatorController.sink.add;

  Stream<int> get progressIndicator => _progressIndicatorController.stream;

  @override
  void dispose() {
    _carAvailabilityDataController.close();
    _swapWithinConfigController.close();
    _blocDatesController.close();
    _swapEnableController.close();
    _progressIndicatorController.close();
  }

  datesBlock(String iD,List<DateTime> stored) async {
    print("block dates");
    await blockDates(iD, _blocDatesController.stream.value);
    print("unblock dates");
    List<DateTime> newBlockedDates = _blocDatesController.stream.value;

    newBlockedDates.forEach((element) {print("newsBlocks:::"+element.toIso8601String());});

    List<DateTime> unblockedDates = <DateTime>[];

    storeDates = stored;

    for (DateTime dateTime in storeDates) {
      print("storeDates:::" + dateTime.toIso8601String());
      if (!newBlockedDates.contains(dateTime)) {
        unblockedDates.add(dateTime);
      }
    }

    if (unblockedDates.length > 0) {
      await unblockDates(iD, unblockedDates);
    }
  }

  datesBlockDefault(String iD) async {
    await blockDates(iD, _blocDatesController.stream.value);

    List<DateTime> newBlockedDates = _blocDatesController.stream.value;


    List<DateTime> unblockedDates = <DateTime>[];

    for (DateTime dateTime in storeDates) {
      if (!newBlockedDates.contains(dateTime)) {
        unblockedDates.add(dateTime);
      }
    }

    if (unblockedDates.length > 0) {
      await unblockDates(iD, unblockedDates);
    }
  }

  Future<FetchDailyMileageConfigurationResponse?>
      callFetchSwapWithinConfiguration() async {
    var response = await fetchDailyMileageConfiguration();
    if (response != null && response.statusCode == 200) {
      var swapWithinConfigRes = FetchDailyMileageConfigurationResponse.fromJson(
          json.decode(response.body!));
      return swapWithinConfigRes;
    } else {
      return null;
    }
  }

  getShortestTripString(AsyncSnapshot<CreateCarResponse> availabilityDataSnapshot) {
    switch (availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.shortestTrip) {
      case 1:
        return '4 hours';
      case 2:
        return '8 hours';
      case 3:
        return '12 hours';
      case 4:
        return '1 day';
      case 5:
        return '2 days';
      case 6:
        return '3 days';
      case 7:
        return '4 days';
      case 8:
        return '5 days';
      case 9:
        return '6 days';
    }
    return '';
  }

  getLongestTripToString(
      AsyncSnapshot<CreateCarResponse> availabilityDataSnapshot) {
    if(availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.longestTrip == 1) {
      return '${availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.longestTrip} day';
    } else{
      return '${availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.longestTrip} days';
    }
  }

  carAvailability(CreateCarResponse data, {bool completed= true, bool saveAndExit = false}) async {
    var response = await setCarAvailability(data, completed: completed, saveAndExit: saveAndExit);
    if (response != null && response.statusCode == 200) {
      var carAvailableRes =
          CreateCarResponse.fromJson(json.decode(response.body!));
      return carAvailableRes;
    } else {
      return null;
    }
  }

  Future<List<Events>?> carGetCalendarEvents(
      CreateCarResponse createCarResponse) async {
    var res = await getCalendar(createCarResponse);
    if (res != null && res.statusCode == 200) {
      print(res.toString());
      GetCalendarResponse calendarResponse =
      GetCalendarResponse.fromJson(json.decode(res.body!));
      List<Events> events = calendarResponse.calendar!.events!;
      return events;
    } else {
      return null;
    }
  }

  Future<List<DateTime>?> carGetCalendar(
      CreateCarResponse createCarResponse) async {
    var res = await getCalendar(createCarResponse);
    HashSet<String> uniqueDates = HashSet<String>();
    if (res != null && res.statusCode == 200) {
      print(res.toString());
      GetCalendarResponse calendarResponse =
          GetCalendarResponse.fromJson(json.decode(res.body!));
      List<DateTime> dates = <DateTime>[];
      if (calendarResponse != null) {
        for (Events events in calendarResponse.calendar!.events!) {
          DateTime startDateTime = DateTime.parse(events.event!.startDatetime!);
          DateTime endDateTime = DateTime.parse(events.event!.endDatetime!);
          List<DateTime> eventDateTimes = DateUtil.instance.getDaysInBetween(startDateTime, endDateTime);
          for(DateTime dateTime in eventDateTimes){
            String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
            if (!uniqueDates.contains(formattedDate)) {
              uniqueDates.add(formattedDate);
              dates.add(dateTime);
            }
          }


        }
      }
      for (DateTime d in dates) {
        print("storeDatesAdd:::"+d.toIso8601String());
        storeDates.add(d.toLocal());
      }

      return dates;
    } else {
      return null;
    }
  }

  double  maintainShortLongTrip(
      AsyncSnapshot<CreateCarResponse> availabilityDataSnapshot) {
    switch (availabilityDataSnapshot
        .data!.car!.availability!.rentalAvailability!.shortestTrip) {
      case 1:
      case 2:
      case 3:
        return 1.0;

     /* case 3:
        if (availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.longestTrip < 2) {
          availabilityDataSnapshot.data!.car!.availability!.rentalAvailability!.longestTrip = 2;
        }
        changedCarAvailabilityData.call(availabilityDataSnapshot.data);
        return 2.0;*/
      case 4:
        if (availabilityDataSnapshot
            .data!.car!.availability!.rentalAvailability!.longestTrip! <
            4) {
          availabilityDataSnapshot
              .data!.car!.availability!.rentalAvailability!.longestTrip = 4;
        }
        changedCarAvailabilityData.call(availabilityDataSnapshot.data!);
        return 4.0;
      case 5:
        if (availabilityDataSnapshot
            .data!.car!.availability!.rentalAvailability!.longestTrip! <
            6) {
          availabilityDataSnapshot
              .data!.car!.availability!.rentalAvailability!.longestTrip = 6;
        }
        changedCarAvailabilityData.call(availabilityDataSnapshot.data!);

        return 6.0;
      case 6:
        if (availabilityDataSnapshot
            .data!.car!.availability!.rentalAvailability!.longestTrip! <
            7) {
          availabilityDataSnapshot
              .data!.car!.availability!.rentalAvailability!.longestTrip = 7;
        }
        changedCarAvailabilityData.call(availabilityDataSnapshot.data!);

        return 7.0;
      case 7:
        if (availabilityDataSnapshot
            .data!.car!.availability!.rentalAvailability!.longestTrip! <
            8) {
          availabilityDataSnapshot
              .data!.car!.availability!.rentalAvailability!.longestTrip = 8;
        }
        changedCarAvailabilityData.call(availabilityDataSnapshot.data!);
        return 8.0;
      case 8:
        if (availabilityDataSnapshot
            .data!.car!.availability!.rentalAvailability!.longestTrip! <
            9) {
          availabilityDataSnapshot
              .data!.car!.availability!.rentalAvailability!.longestTrip = 9;
        }
        changedCarAvailabilityData.call(availabilityDataSnapshot.data!);
        return 9.0;
      case 9:
        if (availabilityDataSnapshot
            .data!.car!.availability!.rentalAvailability!.longestTrip! <
            10) {
          availabilityDataSnapshot
              .data!.car!.availability!.rentalAvailability!.longestTrip = 10;
        }
        changedCarAvailabilityData.call(availabilityDataSnapshot.data!);
        return 10.0;
    }
    return 1.0;
  }

  checkButtonDisability( CreateCarResponse carData) {
    if (carData.car!.availability!.swapAvailability!.swapVehiclesType!.economy! ||
        carData.car!.availability!.swapAvailability!.swapVehiclesType!.midFullSize!||
        carData.car!.availability!.swapAvailability!.swapVehiclesType!.suv!||
        carData.car!.availability!.swapAvailability!.swapVehiclesType!.sports!||
        carData.car!.availability!.swapAvailability!.swapVehiclesType!.pickupTruck!||
        carData.car!.availability!.swapAvailability!.swapVehiclesType!.minivan!||
        carData.car!.availability!.swapAvailability!.swapVehiclesType!.van!
    ) {

      return false;
    } else {
      return true;

    }

  }
}
