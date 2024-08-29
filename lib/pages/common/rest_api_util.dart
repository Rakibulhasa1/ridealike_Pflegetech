import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:no_context_navigation/no_context_navigation.dart';

Future<Resp> callAPI(String url, String payload) async {
  var completer = Completer<Resp>();
  var apiUrl = Uri.parse(url);
  var client = HttpClient(); // `new` keyword optional

  final storage = new FlutterSecureStorage();

  // Create request
  print('url: $url');
  print('payload: $payload');
  HttpClientRequest request;

  request = await client.postUrl(apiUrl);
  String? jwt = await storage.read(key: 'jwt');
  request.headers.set('Authorization', 'Bearer $jwt');
  request.headers
      .set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');
  print("jwt $jwt");

  // Write data
  request.write(payload);

  // Send the request
  HttpClientResponse response;
  response = await request.close();

  // Handle the response

  final contents = StringBuffer();
  response.transform(utf8.decoder).listen((data) {
    contents.write(data);
  }, onDone: () async {
//    completer.complete();
    if (jwt != null && response.statusCode == 401) {
      // await storage.deleteAll();
      await storage.delete(key: 'profile_id');
      await storage.delete(key: 'user_id');
      await storage.delete(key: 'jwt');

      navService
          .pushNamedAndRemoveUntil("/signin_ui", args: {'ERROR': 'Auth Error'});
    } else {
      Resp resp =
          Resp(body: contents.toString(), statusCode: response.statusCode);
      String? jwt = json.decode(resp.body!)['JWT'];
      if (jwt != null) {
        await storage.write(key: 'jwt', value: jwt);
      }
      print('response: ${resp.body.toString()}');

      completer.complete(resp);
    }
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
