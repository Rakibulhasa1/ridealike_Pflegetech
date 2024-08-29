
import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> cancelTrip(_tripID, _cancellationReason) async {

  var tripCancelCompleter=Completer<Resp>();

  callAPI(cancelTripUrl, json.encode(   {
    "TripID": _tripID,
    "Reason": _cancellationReason,
  })).then((resp) {
    tripCancelCompleter.complete(resp);
  });
  return tripCancelCompleter.future;

}