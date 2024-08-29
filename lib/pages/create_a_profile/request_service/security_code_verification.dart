
import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> verifyPhone(String profileID, String phoneNumber, String code) async {
  var verifyPhoneCompleter= Completer<Resp>();

  callAPI(verifyPhoneUrl,json.encode(
      {
    "ProfileID": profileID,
    "PhoneNumber": phoneNumber,
    "VerificationCode": code,
  }
  ),
  ).then((resp) {
    verifyPhoneCompleter.complete(resp);

  });
  return verifyPhoneCompleter.future;
}
