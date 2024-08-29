import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ridealike/pages/common/constant_url.dart';



Future<Resp> socialLogin(String idToken, String socialLoginProvider) async {
  var completer = Completer<Resp>();

  callAPI(
    socialLoginUrl,
    json.encode({
      "IdToken": idToken,
      "SocialLoginProvider": socialLoginProvider,
    }),
  ).then((resp) {
    completer.complete(resp);
  });

  return completer.future;
}

class Resp {
  int? statusCode;
  String? body;

  Resp({
    this.statusCode,
    this.body,
  });
}

Future<Resp> callAPI(String url, String payload) async {
  var completer = Completer<Resp>();
  var apiUrl = Uri.parse(url);
  var client = HttpClient(); // `new` keyword optional

  // Create request
  HttpClientRequest request;
  request = await client.postUrl(apiUrl);

  // Write data
  request.write(payload);

  // Send the request
  HttpClientResponse response;
  response = await request.close();

  // Handle the response
  var resStream = response.transform(Utf8Decoder());
  await for (var data in resStream) {
    completer.complete(Resp(body: data, statusCode: response.statusCode));
    break;
  }

  return completer.future;
}
