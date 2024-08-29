import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';



Future<Resp> addPhoneNumber(String profileID, String phone) async {
  var addPhoneNumberCompleter = Completer<Resp>();

  callAPI(addPhoneNumberUrl,
    json.encode( {
      "ProfileID": profileID,
      "PhoneNumber": phone,
    })
  ).then((resp) {
    addPhoneNumberCompleter.complete(resp);
  });
return addPhoneNumberCompleter.future;
}

Future<Resp> sendPhoneVerificationCode(String profileID) async {
  var sendPhoneVerificationCodeCompleter=Completer<Resp>();

  callAPI(sendPhoneVerificationCodeUrl,
    json.encode(
        {
      "ProfileID": profileID,
    }
    )
  ).then((resp){
    sendPhoneVerificationCodeCompleter.complete(resp);
  } );
return sendPhoneVerificationCodeCompleter.future;
}