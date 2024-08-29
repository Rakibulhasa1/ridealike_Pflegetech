import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> fetchCarModel() async {

  var carModelCompleter=Completer<Resp>();
  callAPI(getAllCarModelUrl,json.encode(
      {}
  )).then((resp){
    carModelCompleter.complete(resp);
  });
return carModelCompleter.future;
}
Future<Resp> fetchCarModelForListCar( String makeID) async {

  var carModelCompleter=Completer<Resp>();
  callAPI(getAllModelForListACarUrl,json.encode(
      {
        "MakeID": makeID
      }
  )).then((resp){
    carModelCompleter.complete(resp);
  });
return carModelCompleter.future;
}
