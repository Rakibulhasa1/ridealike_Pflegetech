import 'dart:async';
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> fetchNewCarData(LatLng position) async {
  var newCarCompleter = Completer<Resp>();
  callAPI(
      getNewCarsUrl,
      json.encode({
        "location": {
          "latitude": position.latitude,
          "longitude": position.longitude
        }
      })).then((resp) {
    newCarCompleter.complete(resp);
  });

  return newCarCompleter.future;
}

Future<Resp> fetchSwapNewCarData() async {
  var newCarCompleter = Completer<Resp>();
  callAPI(getNewSwapCarsList, json.encode({})).then((resp) {
    newCarCompleter.complete(resp);
  });

  return newCarCompleter.future;
}
