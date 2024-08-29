import 'dart:async';
import 'dart:convert' show Utf8Decoder, json;
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

import '../../../main.dart';

Future<Resp> attemptSignUp(
    String firstName, String lastName, String email, String password, bool promotionalValue) async {
  var completer = Completer<Resp>();

  callAPI(
    registerUrl,
    json.encode({
      "Email": email,
      "Password": password,
      "FirstName": firstName,
      "LastName": lastName,
      "PromoAccepted": promotionalValue,
      "Campaign": firebaseCampaign
    }),
  ).then((resp) {
    completer.complete(resp);
  });

  return completer.future;
}
Future<Resp> acceptTermsPolicy(String profileID) async {
  var termsCompleter = Completer<Resp>();
  callAPI(
      acceptTermsAndConditionsUrl_profileServer,
      json.encode({
        "ProfileID": profileID,
      })).then((resp) => {termsCompleter.complete(resp)});
  return termsCompleter.future;
}

// Future<Resp> acceptPromotion(String profileID) async {
//   var promotionsCompleter = Completer<Resp>();
//   callAPI(
//       acceptPromotionalUpdatesUrl_profileServer,
//       json.encode({
//         "ProfileID": profileID,
//       })).then((resp) => {promotionsCompleter.complete(resp)});
//   return promotionsCompleter.future;
//
//
// }
