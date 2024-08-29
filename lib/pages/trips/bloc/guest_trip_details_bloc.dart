import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/trips/request_service/guest_trip_details_request.dart';
import 'package:ridealike/pages/trips/response_model/guest_trip_details_response.dart';
import 'package:rxdart/rxdart.dart';

class GuestTripDetailsBloc implements BaseBloc {
  final _startTripDataController = BehaviorSubject<GuestTripDetailsResponse>();

  Function(GuestTripDetailsResponse) get changedStartTripData =>
      _startTripDataController.sink.add;

  Stream<GuestTripDetailsResponse> get startTripData =>
      _startTripDataController.stream;

  final _damageSelectionController = BehaviorSubject<int>();

  Function(int) get changedDamageSelection =>
      _damageSelectionController.sink.add;

  Stream<int> get damageSelection => _damageSelectionController.stream;
  //



  @override
  void dispose() {
    _startTripDataController.close();
    _damageSelectionController.close();
  }

  // Future<GuestTripDetailsResponse> startTripInspectionsMethod(
  //     GuestTripDetailsResponse data) async {
  //   var resp = await guestTripDetails(data);
  //   if (resp != null && resp.statusCode == 200) {
  //     GuestTripDetailsResponse inspectTripStartResponse =
  //     GuestTripDetailsResponse.fromJson(json.decode(resp.body!));
  //     return inspectTripStartResponse;
  //   } else {
  //     return null;
  //   }
  // }

  Future<GuestTripDetailsResponse?> GuestHistoryMethod(tripInspectionData) async {
    var resp = await startTrip(tripInspectionData);
    if (resp != null && resp.statusCode == 200) {
      GuestTripDetailsResponse guestTripDetailsResponse =
      GuestTripDetailsResponse.fromJson(json.decode(resp.body!));
      return guestTripDetailsResponse;
    } else {
      return null;
    }
  }
  // Future<TripStartResponse> startTripMethod(String tripID) async {
  //   var resp = await startTrip(tripID);
  //   if (resp != null && resp.statusCode == 200) {
  //     TripStartResponse tripStartResponse =
  //         TripStartResponse.fromJson(json.decode(resp.body!));
  //     return tripStartResponse;
  //   } else {
  //     return null;
  //   }
  // }
  //
  // checkValidation(GuestTripDetailsResponse data) {
  //   if (data!.tripStartInspection!.isNoticibleDamage) {
  //     if (data!.tripStartInspection!.damageImageIDs![0] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![1] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![2] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![3] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![4] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![5] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![6] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![7] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![8] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![9] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![10] == '' &&
  //         data!.tripStartInspection!.damageImageIDs![11] == '') {
  //       return false;
  //     }
  //   }
  //
  //   if (data!.tripStartInspection!.exteriorCleanliness == null) {
  //     return false;
  //   }
  //   if (data!.tripStartInspection!.interiorCleanliness == null) {
  //     return false;
  //   }
  //   if (data!.tripStartInspection!.isNoticibleDamage) {
  //     if (data!.tripStartInspection!.interiorImageIDs![0] == '' &&
  //         data!.tripStartInspection!.interiorImageIDs![1] == '' &&
  //         data!.tripStartInspection!.interiorImageIDs![2] == '') {
  //       return false;
  //     }
  //   }
  //   // if (data!.tripStartInspection!.interiorImageIDs![0] == '' &&
  //   //     data!.tripStartInspection!.interiorImageIDs![1] == '' &&
  //   //     data!.tripStartInspection!.interiorImageIDs![2] == '') {
  //   //   return false;
  //   // }
  //   if (data!.tripStartInspection!.exteriorImageIDs![0] == '' &&
  //       data!.tripStartInspection!.exteriorImageIDs![1] == '' &&
  //       data!.tripStartInspection!.exteriorImageIDs![2] == '') {
  //     return false;
  //   }
  //
  //   if (data!.tripStartInspection!.mileageImageIDs[0] == '' &&
  //       data!.tripStartInspection!.mileageImageIDs[1] == '') {
  //     return false;
  //   }
  //   if (data!.tripStartInspection!.fuelImageIDs[0] == '' &&
  //       data!.tripStartInspection!.fuelImageIDs[1] == '') {
  //     return false;
  //   }
  //   // if (data!.tripStartInspection!.mileageController == null) {
  //   //   return false;
  //   // }
  //   return true;
  // }
}