import 'dart:async';
import 'dart:convert' show json;
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';


final storage = new FlutterSecureStorage();

uploadImage(filename) async {
  var stream = new http.ByteStream(DelegatingStream.typed(filename.openRead()));
  var length = await filename.length();

  var uri = Uri.parse(uploadUrl);
  var request = new http.MultipartRequest("POST", uri);
  var multipartFile = new http.MultipartFile('files', stream, length,
      filename: basename(filename.path));

  String? jwt = await storage.read(key: 'jwt');
  print(jwt);
  Map<String, String> headers = { "Authorization": "Bearer $jwt"};
  request.headers.addAll(headers);

  request.files.add(multipartFile);
  var response = await request.send();

  var response2 = await http.Response.fromStream(response);

  return response2;
}

Future<Resp> addIdentityImages(profileID, faceImageID, dLFrontID, dlBackID) async {
  var addDLBackImageCompleter = Completer<Resp>();

  callAPI(
      addIdentityImageUrl,
      json.encode({
        "ProfileID": profileID,
        "ImageID": faceImageID,
      })).then((resp1) {
    callAPI(
        addDLFrontImageUrl,
        json.encode({
          "ProfileID": profileID,
          "ImageID": dLFrontID,
        })).then((resp2) {
      callAPI(
          addDLBackImageUrl,
          json.encode({
            "ProfileID": profileID,
            "ImageID": dlBackID,
          })).then((resp3) {
            print('Length of body ${resp3.body!.length}');
        addDLBackImageCompleter.complete(resp3);

      });
    });
  });


  return addDLBackImageCompleter.future;
}


Future<Resp> welcomeEmailProfile(String userID) async {
  var termsCompleter = Completer<Resp>();
  callAPI(
      sendWelcomeEmailUrl,
      json.encode({
        "UserID": userID,
      })).then((resp) => {termsCompleter.complete(resp)});
  return termsCompleter.future;
}
Future<Resp> submitProfileStatus(String profileID, String heardFrom) async {
  var termsCompleter = Completer<Resp>();
  callAPI(
      submitProfileStatusUrl,
      json.encode({
        "ProfileID": profileID,
        "HeardFrom": heardFrom
      })).then((resp) => {termsCompleter.complete(resp)});
  return termsCompleter.future;
}
Future<Resp> fetchDropDownList() async {

  var bannerCompleter=Completer<Resp>();

  callAPI(getDropDownValueUrl,json.encode(
      {}
  )).then((resp){
    bannerCompleter.complete(resp);

  });
  return bannerCompleter.future;
}
