import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/response_model/guest_trip_details_response.dart';

final storage = new FlutterSecureStorage();
Future<Resp> guestTripDetails(
    GuestTripDetailsResponse inspectTripStartResponse) async {
  var startTripInspectCompleter = Completer<Resp>();
  callAPI(
      getInspectionInfoUrl,
      json.encode({
        "TripStartInspection": {
          "IsNoticibleDamage":
          inspectTripStartResponse.tripStartInspection!.isNoticibleDamage,
          "DamageImageIDs":
          inspectTripStartResponse.tripStartInspection!.damageImageIDs,
          "ExteriorImageIDs":
          inspectTripStartResponse.tripStartInspection!.exteriorImageIDs,
          "DamageDesctiption":
          inspectTripStartResponse.tripStartInspection!.damageDesctiption,
          "InteriorImageIDs":
          inspectTripStartResponse.tripStartInspection!.interiorImageIDs,
          "ExteriorCleanliness":
          inspectTripStartResponse.tripStartInspection!.exteriorCleanliness,
          "InteriorCleanliness":
          inspectTripStartResponse.tripStartInspection!.interiorCleanliness,
          "FuelLevel": inspectTripStartResponse.tripStartInspection!.fuelLevel,
          "Mileage": inspectTripStartResponse.tripStartInspection!.mileage,
          // "mileageController":
          // inspectTripStartResponse.tripStartInspection.mileageController,
          "FuelImageIDs":
          inspectTripStartResponse.tripStartInspection!.fuelImageIDs,
          "MileageImageIDs":
          inspectTripStartResponse.tripStartInspection!.mileageImageIDs,
          "TripID": inspectTripStartResponse.tripStartInspection!.tripID,
          "InspectionByUserID":
          inspectTripStartResponse.tripStartInspection!.inspectionByUserID,
          "Status": {"success": true, "error": ""}
        }
      })).then((resp) {
    startTripInspectCompleter.complete(resp);
  });
  return startTripInspectCompleter.future;
}

Future<Resp> startTrip(_tripID) async {
  var startTripCompleter = Completer<Resp>();

  callAPI(getInspectionInfoUrl, json.encode({"TripID": _tripID})).then((resp) {
    startTripCompleter.complete(resp);
  });
  return startTripCompleter.future;
}

// Future<Resp> startTripAfterInspection(String tripID) async {
//   var startTripCompleter = Completer<Resp>();
//   callAPI(startTripUrl, json.encode({"TripID": tripID}))
//       .then((value) => startTripCompleter.complete(value));
//   return startTripCompleter.future;
// }