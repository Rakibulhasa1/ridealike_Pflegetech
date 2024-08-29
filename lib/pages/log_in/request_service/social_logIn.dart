import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

import '../../../main.dart';

Future<Resp> socialLogin(String idToken, String socialLoginProvider) async {
  var completer = Completer<Resp>();

  callAPI(
    socialLoginUrl,
    json.encode({
      "IdToken": idToken,
      "SocialLoginProvider": socialLoginProvider,
      "Campaign": firebaseCampaign
    }),
  ).then((resp) {
    completer.complete(resp);
  });

  return completer.future;
}

Future<Resp> appleSocialLogin(String idToken, String firstName, String lastName,
    String socialLoginProvider, String platformName) async {
  var completer = Completer<Resp>();

  callAPI(
    socialLoginUrl,
    json.encode({
      "IdToken": idToken,
      "FirstName": firstName,
      "LastName": lastName,
      "SocialLoginProvider": socialLoginProvider,
      "Platform": platformName,
      "Campaign": firebaseCampaign
    }),
  ).then((resp) {
    completer.complete(resp);
  });

  return completer.future;
}
