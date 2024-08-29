import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

Future<Resp> attemptSignIn(String email, String password) async {

  var logIncompleter = Completer<Resp>();

  callAPI(
    loginUrl,
    json.encode(
        {
          "Email": email,
          "Password": password
        }
    ),
  ).then((resp) {
    logIncompleter.complete(resp);
  }
  );

  return logIncompleter.future;
}