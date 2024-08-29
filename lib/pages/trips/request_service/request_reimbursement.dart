import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/response_model/reimbursment_response.dart';

// response
Future<Resp> requestReimbursement(ReimbursementResponse data,String tripID) async {
  var reimbursementCompleter = Completer<Resp>();
  callAPI(
      requestReimbursementUrl,
      json.encode({
          "TripID":tripID,
          "Reimbursement": {
        "ReimbursementDate": "2021-09-03T06:47:27.463Z",
            "Amount": data.reimbursement!.amount,
            "Description":data.reimbursement!.description,
            "ImageIDs": data.reimbursement!.imageIDs
          }
      })).then((resp) {
    reimbursementCompleter.complete(resp);
  });

  return reimbursementCompleter.future;
}

Future<Resp> getTripByID(String tripID) async {
  var getTripByIDCompleter = Completer<Resp>();
  callAPI(getTripByIDUrl, json.encode({"TripID": tripID})).then((resp) {
    getTripByIDCompleter.complete(resp);
  });

  return getTripByIDCompleter.future;
}
Future<Resp>getRentAgreementId(rentAgreementID,userId) async {

  var rentAgreementIdCompleter=Completer<Resp>();
  callAPI(getRentAgreementUrl,
      json.encode(
          {
            "RentAgreementID": rentAgreementID,
            "UserID":userId
          }
      )).then((resp){
    rentAgreementIdCompleter.complete(resp);
  });
  return rentAgreementIdCompleter.future;
}
Future<Resp>getSwapAgreementId(swapAgreementID,userId) async {

  var rentAgreementIdCompleter=Completer<Resp>();
  callAPI(getSwapArgeementTermsUrl,
      json.encode(
          {
            "SwapAgreementID":swapAgreementID,
            "UserID":userId
          }
      )).then((resp){
    rentAgreementIdCompleter.complete(resp);
  });
  return rentAgreementIdCompleter.future;
}
