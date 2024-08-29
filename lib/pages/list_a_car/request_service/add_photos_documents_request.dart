import 'dart:async';
import 'dart:convert' show json;
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

final storage = new FlutterSecureStorage();

Future<Resp> setImagesAndDocuments(CreateCarResponse _carPhotos,
    {bool completed = true, bool saveAndExit = false}) async {
  var imagesAndDocumentsCompleter = Completer<Resp>();

  callAPI(
      setImagesAndDocumentsUrl,
      json.encode({
        "CarID": _carPhotos.car!.iD,
        "ImagesAndDocuments": {
          "License": {
            "Province": _carPhotos.car!.imagesAndDocuments!.license!.province,
            "PlateNumber": _carPhotos.car!.imagesAndDocuments!.license!.plateNumber
          },
          "CurrentKilometers":
              double.parse(_carPhotos.car!.imagesAndDocuments!.currentKilometers!)
                  .round()
                  .toString(),
          "CarOwnershipDocumentID":
              _carPhotos.car!.imagesAndDocuments!.carOwnershipDocumentID,
          "InsuranceDocumentID":
              _carPhotos.car!.imagesAndDocuments!.insuranceDocumentID,
          "InsuranceCertID": _carPhotos.car!.imagesAndDocuments!.insuranceCertID,
          "Vin": _carPhotos.car!.imagesAndDocuments!.vin,
          "Images": {
            "MainImageID": _carPhotos.car!.imagesAndDocuments!.images!.mainImageID,
            "AdditionalImages": {
              "ImageID1": _carPhotos
                  .car!.imagesAndDocuments!.images!.additionalImages!.imageID1,
              "ImageID2": _carPhotos
                  .car!.imagesAndDocuments!.images!.additionalImages!.imageID2,
              "ImageID3": _carPhotos
                  .car!.imagesAndDocuments!.images!.additionalImages!.imageID3,
              "ImageID4": _carPhotos
                  .car!.imagesAndDocuments!.images!.additionalImages!.imageID4,
              "ImageID5": _carPhotos
                  .car!.imagesAndDocuments!.images!.additionalImages!.imageID5,
              "ImageID6": _carPhotos
                  .car!.imagesAndDocuments!.images!.additionalImages!.imageID6,
              "ImageID7": _carPhotos
                  .car!.imagesAndDocuments!.images!.additionalImages!.imageID7,
              "ImageID8": _carPhotos
                  .car!.imagesAndDocuments!.images!.additionalImages!.imageID8,
              "ImageID9": _carPhotos
                  .car!.imagesAndDocuments!.images!.additionalImages!.imageID9
            }
          },
          "Completed": completed
        },
        "SaveAndExit": saveAndExit
      })).then((resp) {
    imagesAndDocumentsCompleter.complete(resp);
  });
  return imagesAndDocumentsCompleter.future;
}

uploadImage(filename) async {
  var stream = new http.ByteStream(DelegatingStream.typed(filename.openRead()));
  var length = await filename.length();

  var uri = Uri.parse(uploadUrl);
  var request = new http.MultipartRequest("POST", uri);
  var multipartFile = new http.MultipartFile('files', stream, length,
      filename: basename(filename.path));

  String? jwt = await storage.read(key: 'jwt');
  Map<String, String> headers = {"Authorization": "Bearer $jwt"};
  request.headers.addAll(headers);

  request.files.add(multipartFile);
  var response = await request.send();

  var response2 = await http.Response.fromStream(response);

  return response2;
}
