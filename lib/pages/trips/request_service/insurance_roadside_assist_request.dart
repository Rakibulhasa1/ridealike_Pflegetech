import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> insuranceAndRoadSideAssistNumberRequest() async {

  var userTripsCompleter=Completer<Resp>();
  callAPI(getInsuranceAndRoadSideAssistNumbersUrl,json.encode(
      {}
  )).then((resp){
    userTripsCompleter.complete(resp);
  });
  return userTripsCompleter.future;
}
Future<Resp> insuranceAndInfoCardRequest() async {

  var userTripsCompleter=Completer<Resp>();
  callAPI(getInsuranceAndInfoCardUrl,json.encode(
      {}
  )).then((resp){
    userTripsCompleter.complete(resp);
  });
  return userTripsCompleter.future;
}