import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> fetchNewCarData(Position position) async {
  var newCarCompleter = Completer<Resp>();
  callAPI(getNewCarsUrl,json.encode({
    "location": {
      "latitude": position.latitude,
      "longitude": position.longitude
    }
  })).then((resp){
    newCarCompleter.complete(resp);
  });

return newCarCompleter.future;


}

Future<Resp> fetchPopularCarData(Position position) async {
  var popularCarCompleter = Completer<Resp>();
  callAPI(getPopularCarsUrl,json.encode(    {
    "location": {
      "latitude": position.latitude,
      "longitude": position.longitude
    }
  })).then((resp) {
    popularCarCompleter.complete(resp);
  });

  return popularCarCompleter.future;
}

Future<Resp> fetchRecentlyViewedCarData(String userID) async {

  var recentlyViewedCarCompleter = Completer<Resp>();
  callAPI(getLastViewedCarsUrl,json.encode( {
    "user_id": userID
  })).then((resp){
    recentlyViewedCarCompleter.complete(resp);
  });
 return recentlyViewedCarCompleter.future;
}

Future<Resp> fetchPreviouslyBookedCarData(String userID) async {
  var previouslyBookedCarCompleter = Completer<Resp>();
  callAPI(getLastBookedCarsUrl,json.encode({
    "user_id": userID
  })).then((resp){
    previouslyBookedCarCompleter.complete(resp);
  });
return previouslyBookedCarCompleter.future;
}

Future<Resp> addCarToViewedList(String carID, String userID) async {
  var addCarToViewedListCompleter = Completer<Resp>();


  callAPI(addCarToViewedListUrl,json.encode( {
    "car_id": carID,
    "user_id": userID
  })).then((resp){
    addCarToViewedListCompleter.complete(resp);
  });
 return addCarToViewedListCompleter.future;
}