import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> fetchCarBodyTrim() async {

  var carBodyTrimCompleter=Completer<Resp>();

  callAPI(getAllCarBodyTrimUrl,json.encode(
      {}
  )).then((resp){
    carBodyTrimCompleter.complete(resp);
  });
  return carBodyTrimCompleter.future;

}
Future<Resp> fetchCarBodyTrimForListCar( String modelID) async {

  var carBodyTrimCompleter=Completer<Resp>();

  callAPI(getAllBodyTrimForListACarUrl,json.encode(
      {
        "ModelID": modelID
      }
  )).then((resp){
    carBodyTrimCompleter.complete(resp);
  });
  return carBodyTrimCompleter.future;

}