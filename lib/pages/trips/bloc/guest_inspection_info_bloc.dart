import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';

import '../response_model/host_start_inspect_rental_response.dart';

class ButtonInspectionInfoBloc implements BaseBloc {
  final storage = new FlutterSecureStorage();
  final _inspectionInfoStreamController = StreamController<HostInspectTripStartResponse>();

  StreamSink<HostInspectTripStartResponse> get inspectionInfoSink =>
      _inspectionInfoStreamController.sink;

  Stream<HostInspectTripStartResponse> get inspectionInfoStream =>
      _inspectionInfoStreamController.stream;


  Future<void> getGuestInspectionInfoByTripID(String tripID) async {
    try {
      print("before calling api$inspectionInfoStream");

      String? jwtToken = await storage.read(key: 'jwt');

      if (jwtToken != null) {
        var response = await HttpClient.post(
          guestgetInspectionInfoUrl,
          {"TripID": tripID},
          token: jwtToken,
        );

        var inspectionInfo = HostInspectTripStartResponse.fromJson(response);

        inspectionInfoSink.add(inspectionInfo);

        print("after calling api$inspectionInfoStream");
      } else {
        // Handle the case where jwtToken is null
        print("JWT token is null");
      }
    } catch (e) {
      throw e;
    }
  }

  // Future<void> getGuestInspectionInfoByTripID(String tripID) async {
  //   try {
  //     print("before calling api$inspectionInfoStream");
  //     var response = await HttpClient.post(
  //         guestgetInspectionInfoUrl, {"TripID": tripID},
  //         token: await storage.read(key: 'jwt'));
  //
  //     var inspectionInfo = HostInspectTripStartResponse.fromJson(response);
  //
  //     inspectionInfoSink.add(inspectionInfo);
  //
  //     print("after calling api$inspectionInfoStream");
  //   } catch (e) {
  //     throw e;
  //   }
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    _inspectionInfoStreamController.close();
  }
}
