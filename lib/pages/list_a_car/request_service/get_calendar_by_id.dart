import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

Future<Resp>getCalendar( CreateCarResponse carResponse)async{
  var calendarCompleter=Completer<Resp>();
  callAPI(getCalendarUrl,json.encode({
    "id":carResponse.car!.calendarID,
  })).then((resp) {
    calendarCompleter.complete(resp);
  });
return calendarCompleter.future;
}