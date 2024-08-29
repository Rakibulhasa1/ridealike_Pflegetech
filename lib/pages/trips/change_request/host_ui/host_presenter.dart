import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';

import 'host_interface.dart';

class HostPresenter {
 HostInterface? _interface;

  HostPresenter(HostInterface interface) {
    _interface = interface;
  }
  FlutterSecureStorage storage= FlutterSecureStorage();
 void getChangeRequest(tripID) async {
   try {
     final token = await storage.read(key: 'jwt') ?? ''; // Provide a default value if null
     final response = await HttpClient.post(
       getChangeRequestUrl,
       {"TripID": "$tripID"},
       token: token,
     );
     print(response);
     _interface!.onDataLoadSuccess(response);
     _interface!.onDataLoading(false);
   } catch (e) {
     print("====$e");
   }
 }

  // void getChangeRequest(tripID)async {
  //   try {
  //     final response = await HttpClient.post(getChangeRequestUrl, {"TripID": "$tripID"},
  //         token: await storage.read(key: 'jwt'));
  //     print(response);
  //     _interface!.onDataLoadSuccess(response);
  //     _interface!.onDataLoading(false);
  //
  //
  //   } catch (e) {
  //   print("====$e");
  //   }
  // }
 Future<void> getChangeRequestAccepted(tripID) async {
   try {
     final token = await storage.read(key: 'jwt') ?? ''; // Provide a default value if null
     _interface!.onAcceptRequest(true);
     final response = await HttpClient.post(
       getChangeRequestAcceptUrl,
       {"TripID": "$tripID"},
       token: token,
     );
     print(response);
     if (response['Status']["success"] != null) {
       _interface!.onAcceptRequest(response['Status']["success"]);
     } else {
       _interface!.onAcceptRequest(false);
     }
   } catch (e) {
     _interface!.onAcceptRequest(false);
     print("====$e");
   }
 }


 // Future<void> getChangeRequestAccepted(tripID)async {
  //   try {
  //     _interface!.onAcceptRequest(true);
  //     final response = await HttpClient.post(getChangeRequestAcceptUrl, {"TripID": "$tripID"},
  //         token: await storage.read(key: 'jwt'));
  //     print(response);
  //    if(response['Status']["success"]){
  //      _interface!.onAcceptRequest(true);
  //    }else{
  //      _interface!.onAcceptRequest(false);
  //    }
  //   } catch (e) {
  //     _interface!.onAcceptRequest(false);
  //     print("====$e");
  //   }
  // }

 Future<void> getChangeRequestRejected(tripID) async {
   try {
     final token = await storage.read(key: 'jwt') ?? ''; // Provide a default value if null
     _interface!.onCancelRequest(true);
     final response = await HttpClient.post(
       getChangeRequestRejectUrl,
       {"TripID": "$tripID"},
       token: token,
     );
     if (response['Status']["success"] != null) {
       _interface!.onCancelRequest(response['Status']["success"]);
     } else {
       _interface!.onCancelRequest(false);
     }
   } catch (e) {
     _interface!.onCancelRequest(false);
     print("====$e");
   }
 }

  // Future<void> getChangeRequestRejected(tripID)async {
  //   try {
  //     _interface!.onCancelRequest(true);
  //     final response = await HttpClient.post(getChangeRequestRejectUrl, {"TripID": "$tripID"},
  //         token: await storage.read(key: 'jwt'));
  //     // _interface!.onAcceptRequest();
  //     if(response['Status']["success"]){
  //       _interface!.onCancelRequest(true);
  //     }else{
  //       _interface!.onCancelRequest(false);
  //     }
  //
  //   } catch (e) {
  //     _interface!.onCancelRequest(false);
  //     print("====$e");
  //   }
  // }
}
