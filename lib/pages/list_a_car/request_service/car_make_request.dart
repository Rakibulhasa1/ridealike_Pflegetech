import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
Future<Resp> fetchCarMake() async {

  var carMakeCompleter=Completer<Resp>();

  callAPI(getAllCarMakeUrl,json.encode(
      {}
  )).then((resp){
    carMakeCompleter.complete(resp);
  });

 return carMakeCompleter.future;

}