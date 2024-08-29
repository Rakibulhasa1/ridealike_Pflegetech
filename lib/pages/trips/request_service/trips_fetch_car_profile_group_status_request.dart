
import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
Future<Resp> tripFetchCarData(_carIDs) async {
  var completer=Completer<Resp>();
  callAPI(getCarsByCarIDsUrl, json.encode(
      {"carIDs": _carIDs}
      )).then((resp){
        completer.complete(resp);
  });
  return completer.future;

}
Future<Resp> getCarData(_carID) async {
  var completer=Completer<Resp>();
  callAPI(getCarUrl, json.encode(
      {"CarID": _carID}
      )).then((resp){
        completer.complete(resp);
  });
  return completer.future;

}

Future<Resp> fetchProfileData(_profileUserIDs) async {
  var profileUserCompleter=Completer<Resp>();
  callAPI(getProfilesByUserIDsUrl, json.encode(
      { "UserIDs": _profileUserIDs,}
      )).then((resp){
        profileUserCompleter.complete(resp);
  });
  return profileUserCompleter.future;

}


Future<Resp> fetchAllUsersTripsByStatusGroupData(_limit, _skip,_userID,_tripStatusGroup) async {
  var tripsStatusGroupCompleter=Completer<Resp>();
  callAPI(getAllUserTripsByStatusGroupUrl, json.encode(
      {
        "Limit": _limit,
        "Skip":_skip,
        "UserID": _userID,
        "TripStatusGroup":_tripStatusGroup
      }
      )).then((resp){
        tripsStatusGroupCompleter.complete(resp);
  });
  return tripsStatusGroupCompleter.future;

}
Future<Resp> fetchUserPastTripsData(_userID, _carID) async {
  final completer = Completer<Resp>();
  callAPI(
    getAllUserTripsByStatusGroupUrl,
    json.encode({
      "Limit": "100",
      "Skip": "0",
      "UserID": _userID,
      "CarID": _carID,
      "TripStatusGroup": "Past"
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}