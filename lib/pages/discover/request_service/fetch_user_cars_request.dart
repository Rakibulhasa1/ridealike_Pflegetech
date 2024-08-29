import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> fetchUserCars(param) async {
  var userCarCompleter = Completer<Resp>();
  callAPI(getCarsByUserIDUrl,json.encode( {
    "UserID": param
  })).then((resp) {
    userCarCompleter.complete(resp);
  });

return userCarCompleter.future;
}