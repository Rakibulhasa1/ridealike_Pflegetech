
import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_car_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_host_request.dart';
import 'package:ridealike/pages/trips/response_model/end_trip_inspect_rental_response.dart';



Future<Resp> endTripInspections(InspectTripEndRentalResponse inspectTripEndRentalResponse ) async {
  var completer = Completer<Resp>();

  callAPI(inspectTripEndRentalUrl,
    json.encode(
        {
          "TripEndInspectionRental": {
            "IsNoticibleDamage": inspectTripEndRentalResponse.tripEndInspectionRental!.isNoticibleDamage,
            "DamageImageIDs":
              inspectTripEndRentalResponse.tripEndInspectionRental!.damageImageIDs,
            "DamageDesctiption": inspectTripEndRentalResponse.tripEndInspectionRental!.damageDesctiption,
            "ExteriorImageIDs":
            inspectTripEndRentalResponse.tripEndInspectionRental!.exteriorImageIDs,
            "InteriorImageIDs":
            inspectTripEndRentalResponse.tripEndInspectionRental!.interiorImageIDs,
            "InteriorCleanliness":
            inspectTripEndRentalResponse.tripEndInspectionRental!.interiorCleanliness,
            "ExteriorCleanliness":
            inspectTripEndRentalResponse.tripEndInspectionRental!.exteriorCleanliness,
            "FuelLevel":
            inspectTripEndRentalResponse.tripEndInspectionRental!.fuelLevel,
            "Mileage":
            inspectTripEndRentalResponse.tripEndInspectionRental!.mileage,
            "FuelImageIDs":
            inspectTripEndRentalResponse.tripEndInspectionRental!.fuelImageIDs,
            "MileageImageIDs":
            inspectTripEndRentalResponse.tripEndInspectionRental!.mileageImageIDs,
            "FuelReceiptImageIDs": inspectTripEndRentalResponse.tripEndInspectionRental!.fuelReceiptImageIDs,
            "TripID": inspectTripEndRentalResponse.tripEndInspectionRental!.tripID,
            "InspectionByUserID": inspectTripEndRentalResponse.tripEndInspectionRental!.inspectionByUserID
          }
        }
    ),
  ).then((resp) {
    completer.complete(resp);
  }
  );

  return completer.future;
}
Future<Resp> endTrip(_tripID) async {
  var endTripCompleter=Completer<Resp>();
  callAPI(endTripUrl, json.encode(
      {
        "TripID": _tripID
      }
  )).then((resp){
    endTripCompleter.complete(resp);
  });
return endTripCompleter.future;
}

Future<Resp> rentalRateTripCar(RateTripCarRequest rateTripCarRequest) async {
  var endTripCompleter=Completer<Resp>();
  callAPI(rateTripCarUrl, json.encode(rateTripCarRequest.toJson())).then((resp){
    endTripCompleter.complete(resp);
  });
return endTripCompleter.future;
}


Future<Resp> rentalRateTripHost(RateTripHostRequest rateTripHostRequest) async {
  var endTripCompleter=Completer<Resp>();
  callAPI(rateTripHostUrl, json.encode(rateTripHostRequest.toJson())).then((resp){
    endTripCompleter.complete(resp);
  });
return endTripCompleter.future;
}