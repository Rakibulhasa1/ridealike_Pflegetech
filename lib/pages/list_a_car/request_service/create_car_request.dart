

import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> createCar(String userID) async {

  var createCarCompleter=Completer<Resp>();
  callAPI(createCarUrl,json.encode(
      {
        "UserID": userID
      }
      )).then((resp) {
    createCarCompleter.complete(resp);
  });

  return createCarCompleter.future;
}
Future<Resp> getPayoutMethod(_userID) async {

  var payoutMethodCompleter=Completer<Resp>();
  callAPI(getPayoutMethodUrl, json.encode(
      {
        "UserID": _userID,
      }
  )).then((resp) {
    payoutMethodCompleter.complete(resp);
  });
  return payoutMethodCompleter.future;
}

Future<Resp> requestToVerifyListedCar(carID) async {

  var payoutMethodCompleter=Completer<Resp>();
  callAPI(requestToVerifyUrl, json.encode(
      {
        "CarID":carID
      }
  )).then((resp) {
    payoutMethodCompleter.complete(resp);
  });
  return payoutMethodCompleter.future;
}