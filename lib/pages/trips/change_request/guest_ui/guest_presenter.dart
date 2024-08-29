import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';

import 'guest_interface.dart';


class GuestPresenter {
 GuestInterface? _interface;

  GuestPresenter(GuestInterface interface) {
    _interface = interface;
  }

  final storage = new FlutterSecureStorage();

  Future<void> getChangeRequestCalculation(Map data) async {
    var response;
    try {
      _interface!.onDataLoadStarted(true);
      response = await HttpClient.post(createChangeRequestUrl, data,
          token: await storage.read(key: 'jwt')as String);
      print("response of calculation$response");
      bool responseStatus = response["Status"]["success"];
      double? guestPrice = double.tryParse(response['GuestPrice'].toString());
      print("$guestPrice ============");
      print("====$responseStatus");

      if (responseStatus) {
        _interface!.onDataLoadSuccess(guestPrice!);
        _interface!.onDataLoadFail(null);
        _interface!.onDataLoadStarted(false);
      } else {
        _interface!.onDataLoadFail(response);
        print("=====##$response");
        _interface!.onDataLoadStarted(false);
      }
    } catch (e) {
      _interface!.onDataLoadFail(response);
      print("=====##$response");
      _interface!.onDataLoadStarted(false);
    }
  }

  Future<void> getChangeRequestSubmit(Map data) async {
    try {
      _interface!.onSubmitStart(true);
      final response = await HttpClient.post(createChangeRequestUrl, data,
          token: await storage.read(key: 'jwt')as String);
      bool responseStatus = response["Status"]["success"];
      print("submit response$responseStatus");
      if (responseStatus) {
        _interface!.onSubmitSuccess(responseStatus);
        _interface!.onSubmitStart(false);
      } else {
        _interface!.onSubmitSuccess(responseStatus);
        _interface!.onSubmitStart(false);
      }
    } catch (e) {
      print("====$e");
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }



}
