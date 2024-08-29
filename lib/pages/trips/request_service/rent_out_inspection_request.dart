import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_guest_request.dart';
import 'package:ridealike/pages/trips/response_model/rent_out_inspect_trips_response.dart';


Future<Resp> inspectTripEndRentout(InspectTripEndRentoutResponse data) async {
  var completer = Completer<Resp>();



  callAPI(inspectTripEndRentoutUrl,
    json.encode(
        {
          "TripEndInspectionRentout": {
            "IsNoticibleDamage": data.tripEndInspectionRentout!.isNoticibleDamage,
            "DamageImageIDs": data.tripEndInspectionRentout!.damageImageIDs,
            "DamageDesctiption": data.tripEndInspectionRentout!.damageDesctiption,
            "InteriorCleanliness": data.tripEndInspectionRentout!.interiorCleanliness,
            "ExteriorCleanliness": data.tripEndInspectionRentout!.exteriorCleanliness,
            "ExteriorImageIDs": data.tripEndInspectionRentout!.exteriorImageIDs,
            "InteriorImageIDs": data.tripEndInspectionRentout!.interiorImageIDs,
            "FuelImageIDs": data.tripEndInspectionRentout!.fuelImageIDs,
            "MileageImageIDs": data.tripEndInspectionRentout!.mileageImageIDs,
            "FuelReceiptImageIDs": data.tripEndInspectionRentout!.fuelReceiptImageIDs,
            "FuelLevel": data.tripEndInspectionRentout!.fuelLevel,
            "Mileage": data.tripEndInspectionRentout!.mileage,
            "PickUpFee": data.tripEndInspectionRentout!.pickUpFee,
            "DropOffFee": data.tripEndInspectionRentout!.dropOffFee,
            "FuelFee": data.tripEndInspectionRentout!.fuelFee,
            "KMfee": data.tripEndInspectionRentout!.kmFee,
            "InteriorCleanFee": data.tripEndInspectionRentout!.interiorCleanFee,
            "ExteriorCleanFee": data.tripEndInspectionRentout!.exteriorCleanFee,
          //  "RequestedCleaningFee": data.tripEndInspectionRentout.requestedCleaningFee==-1? 0:data.tripEndInspectionRentout.requestedCleaningFee,
            "IsFuelSameLevelAsBefore": data.tripEndInspectionRentout!.isFuelSameLevelAsBefore,
            "RequestedChargeForFuel": data.tripEndInspectionRentout!.requestedChargeForFuel,
            "IsAddedMileageWithinAllocated": data.tripEndInspectionRentout!.isAddedMileageWithinAllocated,
            "KmOverTheLimit": data.tripEndInspectionRentout!.kmOverTheLimit,
            "IsTicketsTolls": data.tripEndInspectionRentout!.isTicketsTolls,
            "TicketsTollsReimbursement": {
              "ReimbursementDate": "2021-09-03T04:34:18.975Z",
              "Amount": data.tripEndInspectionRentout!.ticketsTollsReimbursement!.amount,
              "Description": data.tripEndInspectionRentout!.ticketsTollsReimbursement!.description,
              "ImageIDs": data.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs,
            },
            "TripID": data.tripEndInspectionRentout!.tripID,
            "InspectionByUserID": data.tripEndInspectionRentout!.inspectionByUserID
          }
        }
    ),
  ).then((resp) {
    completer.complete(resp);
  }
  );

  return completer.future;
}

Future<Resp> rentOutRateTripGuest(RateTripGuestRequest rateTripGuestRequest ) async {

  var rentOutGuestRateCompleter=Completer<Resp>();
  callAPI(rateTripGuestUrl, json.encode(rateTripGuestRequest.toJson())).then((resp){
    rentOutGuestRateCompleter.complete(resp);
  });
  return rentOutGuestRateCompleter.future;
}
Future<Resp> getSwapAgreementTerms(_swapAgreementID, _userID) async {
  final completer = Completer<Resp>();
  callAPI(
    getSwapArgeementTermsUrl,
    json.encode({"SwapAgreementID": _swapAgreementID, "UserID": _userID}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}


