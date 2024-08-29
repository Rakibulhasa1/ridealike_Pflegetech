import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> fetchUserProfile( userID) async {

  var userTripsCompleter=Completer<Resp>();
 callAPI(getProfileByUserIDUrl,json.encode(
     {
       "UserID": userID
     }
 )).then((resp){
   userTripsCompleter.complete(resp);
 });
return userTripsCompleter.future;
}

Future<Resp> fetchProfileVerification(profileID) async {
  var userDocVerificationCompleter=Completer<Resp>();
  callAPI(getVerificationStatusByProfileIDUrl, json.encode(
      {
        "ProfileID": profileID
      }
  )).then((resp) {
    userDocVerificationCompleter.complete(resp);
  });
return userDocVerificationCompleter.future;
}

Future<Resp> fetchProfileRatingReviews(profileID) async {
  var ratingReviewCompleter=Completer<Resp>();
  callAPI(getNumberOfRatingsByProfileIDUrl, json.encode(
      {
        "ProfileID": profileID
      }
  )).then((resp){
    ratingReviewCompleter.complete(resp);
  });
return ratingReviewCompleter.future;
}
Future<Resp> fetchUserCars(param) async {
  final completer = Completer<Resp>();
  callAPI(
    getCarsByUserIDUrl,
    json.encode({"UserID": param}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
