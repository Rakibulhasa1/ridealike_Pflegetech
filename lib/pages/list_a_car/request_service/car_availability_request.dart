import 'dart:async';
import 'dart:convert' show json;
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
Future<Resp> fetchSwapWithinConfiguration() async {
  var swapWithinConfigCompleter=Completer<Resp>();
  callAPI(getListCarConfigurablesUrl, json.encode(
      {}
  )).then((resp){
    swapWithinConfigCompleter.complete(resp);

  });
  return swapWithinConfigCompleter.future;

}


Future<Resp> setCarAvailability( CreateCarResponse _carID, {bool completed= true, bool saveAndExit = false}) async {

  var carAvailabilityCompleter=Completer<Resp>();
  callAPI(setAvailabilityUrl,json.encode(
      {
        "CarID": _carID.car!.iD,
        "Availability": {
          "RentalAvailability": {
            "AdvanceNotice": _carID.car!.availability!.rentalAvailability!.advanceNotice,
            "SameDayCutOffTime": {
              "hours":
              double.parse( _carID.car!.availability!.rentalAvailability!.sameDayCutOffTime!.hours.toString()).round().toString(),
              "minutes": double.parse( _carID.car!.availability!.rentalAvailability!.sameDayCutOffTime!.minutes.toString()).round().toString(),
              "seconds": double.parse( _carID.car!.availability!.rentalAvailability!.sameDayCutOffTime!.seconds.toString()).round().toString(),
              "nanos": double.parse( _carID.car!.availability!.rentalAvailability!.sameDayCutOffTime!.nanos.toString()).round().toString()
            },
            "BookingWindow":_carID.car!.availability!.rentalAvailability!.bookingWindow != ''
                ? _carID.car!.availability!.rentalAvailability!.bookingWindow
                : 'BookingWindowUndefined',
            "ShortestTrip":
            double.parse(_carID.car!.availability!.rentalAvailability!.shortestTrip.toString()).round().toString(),
            "LongestTrip":
            double.parse(_carID.car!.availability!.rentalAvailability!.longestTrip.toString()).round().toString()
          },
          "SwapAvailability": {
            "SwapWithin":
            double.parse(_carID.car!.availability!.swapAvailability!.swapWithin.toString()).round().toString(),
            "SwapVehiclesType": {
              "Economy": _carID.car!.availability!.swapAvailability!.swapVehiclesType!.economy,
              "MidFullSize": _carID.car!.availability!.swapAvailability!.swapVehiclesType!.midFullSize,
              "Sports": _carID.car!.availability!.swapAvailability!.swapVehiclesType!.sports,
              "SUV": _carID.car!.availability!.swapAvailability!.swapVehiclesType!.suv,
              "PickupTruck": _carID.car!.availability!.swapAvailability!.swapVehiclesType!.pickupTruck,
              "Minivan": _carID.car!.availability!.swapAvailability!.swapVehiclesType!.minivan,
              "Van": _carID.car!.availability!.swapAvailability!.swapVehiclesType!.van
            }
          },
          "Completed": completed
        },
        "SaveAndExit": saveAndExit
      }
  )).then((resp) {
    carAvailabilityCompleter.complete(resp);
  });
return carAvailabilityCompleter.future;

}

Future<bool?> blockDates(String _carID, List<DateTime> blockedDates) async {
  var completer = Completer();

  // get calendar id
  callAPI(getCalendarByOwnerIDUrl, json.encode(   {
    'owner_id': _carID,
  })).then((resp) {
    var getCalRes=resp;

    var calId;
    try {
      calId = json.decode(getCalRes.body.toString())['calendar']['id'];
    } catch (error) {

    }
    var dateList;
    try {
      dateList = blockedDates.map((element) {
        print(element.toString() + ">>>"+ element.toUtc().toString());
        return element.toUtc().toIso8601String();
      }).toList();
    } catch (err) {}
    callAPI(blockMultipleDaysUrl, json.encode({'calendar_id': calId, 'dates': dateList})).then((resp1) {
      var resp = json.decode(resp1.body.toString());
//      blockCompleter.complete(resp1);
      if (resp['status']['success'] == true) {
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });
    return completer.future;
  });
}


Future<bool?> unblockDates(String _carID, List<DateTime> unblockedDates) async {
  var completer = Completer();

  // get calendar id

  callAPI(getCalendarByOwnerIDUrl, json.encode(   {
    'owner_id': _carID,
  })).then((resp) {
    var getCalRes=resp;

    var calId;
    try {
      calId = json.decode(getCalRes.body.toString())['calendar']['id'];
    } catch (error) {

    }
    var dateList;
    try {
      dateList = unblockedDates.map((element) {
        print(element.toString() + "<<<"+ element.toUtc().toString());
        return element.toUtc().toIso8601String();
      }).toList();
    } catch (err) {}
    callAPI(unBlockMultipleDaysUrl, json.encode({'calendar_id': calId, 'dates': dateList})).then((resp1) {
      var resp = json.decode(resp1.body.toString());
//      blockCompleter.complete(resp1);
      if (resp['status']['success'] == true) {
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });
    return completer.future;

    completer.complete(resp);
  });
//
//  var getCalRes = await http.post(
//      'htps://api.calendar.ridealike.com/v1/calendar.CalendarService/GetCalendarByOwnerID',
//      body: json.encode(
//          {
//        'owner_id': _carID,
//      }
//      ));


//
//  var res = await http.post(
//      blockMultipleDaysIp,
//      body: json.encode({'calendar_id': calId, 'dates': dateList}));
//
//  var resp = json.decode(res.body.toString());
//  if (resp['status']['success'] == true) {
//    completer.complete(true);
//  } else {
//    completer.complete(false);
//  }
//  return completer.future;
}