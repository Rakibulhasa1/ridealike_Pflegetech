import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/trips/request_service/trips_fetch_car_profile_group_status_request.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_by_user_ids_response.dart';
import 'package:ridealike/pages/trips/response_model/trips_get_car_by_ids_response.dart';
import 'package:rxdart/rxdart.dart';

class TripsBloc implements BaseBloc {
  final _tripsGroupStatusController =
      BehaviorSubject<TripAllUserStatusGroupResponse>();

  Function(TripAllUserStatusGroupResponse) get changedTripGroupStatus =>
      _tripsGroupStatusController.sink.add;

  Stream<TripAllUserStatusGroupResponse> get tripGroupStatus =>
      _tripsGroupStatusController.stream;
  final storage = new FlutterSecureStorage();

  Future<TripAllUserStatusGroupResponse?> allTripsGroupStatus(
      _limit, _skip, groupStatus) async {
    String? userID = await storage.read(key: 'user_id');
    var response = await fetchAllUsersTripsByStatusGroupData(
        _limit, _skip, userID, groupStatus);
    if (response != null && response.statusCode == 200) {
      var groupStatusResp =
          TripAllUserStatusGroupResponse.fromJson(json.decode(response.body!));
      var trips = List<Trips>.from([]);
      for(Trips t in groupStatusResp.trips ?? []){
//        if(t.hostUserID != userID){
          trips.add(t);
//        }
      }
      groupStatusResp.trips = trips;
      groupStatusResp.userID = userID;
      return groupStatusResp;

    } else {
      return null;
    }
  }

Future<TripAllUserStatusGroupResponse?> specificTripStatus(
    _userID, _carID) async {
    String? userID = await storage.read(key: 'user_id');
    var response = await fetchUserPastTripsData(userID, _carID);
    if (response != null && response.statusCode == 200) {
      var groupStatusResp =
          TripAllUserStatusGroupResponse.fromJson(json.decode(response.body!));
      var trips = List<Trips>.empty();
      // var trips = <Trips>[];
      // List<Trips>.empty();
      for(Trips t in groupStatusResp.trips!){
//        if(t.hostUserID != userID){
          trips.add(t);
//        }
      }
      groupStatusResp.trips = trips;
      groupStatusResp.userID = userID;
      return groupStatusResp;
    } else {
      return null;
    }
  }

  tripGetCarData(_carId) async {
    var response = await tripFetchCarData(_carId);
    if (response != null && response.statusCode == 200) {
      var carDataResponse =
          GetCarsByCarIDsResponse.fromJson(json.decode(response.body!));
      return carDataResponse;
    } else {
      return null;
    }
  }

  tripsGetProfileData(_profileUserId) async {
    var response = await fetchProfileData(_profileUserId);
    if (response != null && response.statusCode == 200) {
      var profileDataResp =
          ProfileByUserIdsResponse.fromJson(json.decode(response.body!));
      return profileDataResp;
    } else {
      return null;
    }
  }

  @override
  void dispose() {
    _tripsGroupStatusController.close();
  }
}
