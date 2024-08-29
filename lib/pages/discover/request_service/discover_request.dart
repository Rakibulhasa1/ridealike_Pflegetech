import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> positionFetchNewCarData(Position position) async {
  var positionFetchNewCarCompleter = Completer<Resp>();
  callAPI(getNewCarsUrl,json.encode( {
    "location": {
      "latitude": position.latitude,
      "longitude": position.longitude
    }
  })).then((resp){
    positionFetchNewCarCompleter.complete(resp);
  });

  return positionFetchNewCarCompleter.future;

}