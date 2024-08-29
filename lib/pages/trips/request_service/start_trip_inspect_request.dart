import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/response_model/start_trip_inspect_rental_response.dart';
// Future<Resp> startTripInspections(InspectTripStartResponse inspectTripStartResponse) async {
//
// var startTripInspectCompleter=Completer<Resp>();
// callAPI(inspectTripStartUrl, json.encode( {
//   "TripStartInspection": {
//     "IsNoticibleDamage": inspectTripStartResponse.tripStartInspection.isNoticibleDamage,
//     "DamageImageIDs": inspectTripStartResponse.tripStartInspection.damageImageIDs,
//     "DashboardImageIDs": inspectTripStartResponse.tripStartInspection.dashboardImageIDs,
//     "Cleanliness": inspectTripStartResponse.tripStartInspection.exteriorCleanliness,
//     "Cleanliness": inspectTripStartResponse.tripStartInspection.interiorCleanliness,
//     "TripID": inspectTripStartResponse.tripStartInspection.tripID,
//     "InspectionByUserID": inspectTripStartResponse.tripStartInspection.inspectionByUserID
//   }
// })).then((resp) {
//   startTripInspectCompleter.complete(resp);
// });
// return startTripInspectCompleter.future;
//
// }


Future<Resp> startTrip(_tripInspectionData) async {
  var startTripCompleter=Completer<Resp>();

callAPI(guestgetInspectionInfoUrl, json.encode(
    {
      "TripStartInspection": _tripInspectionData
    }
)).then((resp){
  startTripCompleter.complete(resp);
});
return startTripCompleter.future;

}



Future<Resp> startTripAfterInspection(String tripID)async{
  var startTripCompleter = Completer<Resp>();
  callAPI(startTripUrl,json.encode({
    "TripID": tripID
  })).then((value) => startTripCompleter.complete(value));
  return startTripCompleter.future;
}


Future<Resp> startTripInspections(
    InspectTripStartResponse inspectTripStartResponse) async {
  var startTripInspectCompleter = Completer<Resp>();
  callAPI(
      inspectTripStartUrl,
      json.encode({
        "TripStartInspection": {
          "IsNoticibleDamage":
          inspectTripStartResponse.tripStartInspection!.isNoticibleDamage,
          "DamageImageIDs":
          inspectTripStartResponse.tripStartInspection!.damageImageIDs,
          "ExteriorImageIDs":
          inspectTripStartResponse.tripStartInspection!.exteriorImageIDs,
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