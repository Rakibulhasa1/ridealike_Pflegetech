import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/discover/request_service/discover_rent_request.dart';
import 'package:ridealike/pages/discover/response_model/fetchPreviouslyBookedCarResponse.dart';
import 'package:ridealike/pages/discover/response_model/fetchRecentlyViewedCarResponse.dart';
import 'package:rxdart/rxdart.dart';

class DiscoverRentPreviousBloc extends Object with Validators implements BaseBloc {
  final _loggedInController = BehaviorSubject<bool>();
  final _isDataAvailableController = BehaviorSubject<bool>();
  // final _newCarDataController = BehaviorSubject<FetchNewCarResponse>();
  final _currentAddressController = BehaviorSubject<String>();
  final _locationPermissionController = BehaviorSubject<bool>();
  final _userIdController = BehaviorSubject<String>();
  // final _recentlyViewedCarController =
  // BehaviorSubject<FetchRecentlyViewedCarResponse>();
  final _previouslyBookedCarController =
  BehaviorSubject<FetchPreviouslyBookedCarResponse>();
  // final _popularCarController = BehaviorSubject<FetchPopularCarResponse>();

  final storage = new FlutterSecureStorage();

  final _progressIndicatorController = BehaviorSubject<int>();

  Function(String) get changedCurrentAddress =>
      _currentAddressController.sink.add;

  Function(bool) get changedLocationPermission =>
      _locationPermissionController.sink.add;

  Function(bool) get changedLoggedIn => _loggedInController.sink.add;

  // Function(FetchNewCarResponse) get changedNewCarData =>
  //     _newCarDataController.sink.add;
  //
  // Function(FetchPopularCarResponse) get changedPopularCar =>
  //     _popularCarController.sink.add;

  Function(FetchPreviouslyBookedCarResponse) get changedPreviouslyBookedCar =>
      _previouslyBookedCarController.sink.add;

  Function(int) get changedProgressIndicator =>
      _progressIndicatorController.sink.add;
  //
  // Function(FetchRecentlyViewedCarResponse) get changedRecentlyViewedCar =>
  //     _recentlyViewedCarController.sink.add;

  Function(String) get changedUser => _userIdController.sink.add;

  Stream<String> get currentAddress => _currentAddressController.stream;

  Stream<bool> get isDataAvailable => _isDataAvailableController.stream;

  Stream<bool> get locationPermission => _locationPermissionController.stream;

  Stream<bool> get loggedIn => _loggedInController.stream;

  // Stream<FetchNewCarResponse> get newCarData =>
  //     _newCarDataController.stream.transform(fetchNewCarValidator);

  // Stream<FetchPopularCarResponse> get popularCarData =>
  //     _popularCarController.stream;

  Stream<FetchPreviouslyBookedCarResponse> get previouslyBookedCar =>
      _previouslyBookedCarController.stream;

  Stream<int> get progressIndicator => _progressIndicatorController.stream;
  //
  // Stream<FetchRecentlyViewedCarResponse> get recentlyViewedCar =>
  //     _recentlyViewedCarController.stream;

  Stream<String> get userId => _userIdController.stream;

  void callFetchLastData() async {
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var recentlyViewedCarResponse = await fetchRecentlyViewedCarData(userID);
      var _recentlyViewedCarData = FetchRecentlyViewedCarResponse.fromJson(
          json.decode(recentlyViewedCarResponse.body!));
      if (_recentlyViewedCarData != null &&
          _recentlyViewedCarData.cars!.length != null &&
          _recentlyViewedCarData.cars!.length != 0 &&
          _recentlyViewedCarData.cars!.length >= 10) {
        var subListRecent = _recentlyViewedCarData.cars!.sublist(0, 10);
        _recentlyViewedCarData.cars = subListRecent;
      }
      // _recentlyViewedCarController.sink.add(_recentlyViewedCarData);
      // if (_isDataAvailableController.value == null) {
      //   _isDataAvailableController.sink.add(true);
      // }

      var previouslyBookedCarResponse =
      await fetchPreviouslyBookedCarData(userID);
      var _previouslyBookedCarData = FetchPreviouslyBookedCarResponse.fromJson(
          json.decode(previouslyBookedCarResponse.body!));
      if (_previouslyBookedCarData != null &&
          _previouslyBookedCarData.cars!.length != null &&
          _previouslyBookedCarData.cars!.length != 0 &&
          _previouslyBookedCarData.cars!.length >= 10) {
        var subListBooked = _previouslyBookedCarData.cars!.sublist(0, 10);
        _previouslyBookedCarData.cars = subListBooked;
      }
      _previouslyBookedCarController.sink.add(_previouslyBookedCarData);
      if (_isDataAvailableController.value == null) {
        _isDataAvailableController.sink.add(true);
      }

      _loggedInController.sink.add(true);
      _userIdController.sink.add(userID);
    } else {
      _loggedInController.sink.add(false);
    }
  }

  // void callFetchNewCars(context) async {
  //   location_handler.PermissionStatus permissionStatus =
  //   await checkPermission();
  //   if (permissionStatus != location_handler.PermissionStatus.granted) {
  //     permissionStatus = await requestPermission();
  //   }
  //
  //   if (permissionStatus == location_handler.PermissionStatus.granted) {
  //     _locationPermissionController.sink.add(true);
  //     LocationData _locationData;
  //     _locationData = await locationUtil.getCurrentLocation();
  //
  //     if (_locationData != null) {
  //       var newCarRes = await fetchNewCarData(_locationData);
  //       var _newCarData =
  //       FetchNewCarResponse.fromJson(json.decode(newCarRes.body!));
  //       if (_newCarData != null && _newCarData.cars != null) {
  //         _newCarData.cars.shuffle();
  //       }
  //       // _newCarDataController.sink.add(_newCarData);
  //       // if (_isDataAvailableController.value == null) {
  //       //   _isDataAvailableController.sink.add(true);
  //       // }
  //       final coordinates =
  //       new Coordinates(_locationData.latitude, _locationData.longitude);
  //       var first = '';
  //       try {
  //         var addresses =
  //         await Geocoder.local.findAddressesFromCoordinates(coordinates);
  //         first = addresses.first.locality;
  //         if (first == null) {
  //           first = addresses.first.adminArea;
  //         }
  //         _currentAddressController.sink.add(first);
  //       } catch (e) {
  //         print('Exception $e');
  //       }
  //       if (_isDataAvailableController.value == null) {
  //         _isDataAvailableController.sink.add(true);
  //       }
  //
  //       var popularCarRes = await fetchPopularCarData(_locationData);
  //       var _popularCarData =
  //       FetchPopularCarResponse.fromJson(json.decode(popularCarRes.body!));
  //       if (_popularCarData != null && _popularCarData.cars != null) {
  //         _popularCarData.cars.shuffle();
  //       }
  //       // _popularCarController.sink.add(_popularCarData);
  //       // if (_isDataAvailableController.value == null) {
  //       //   _isDataAvailableController.sink.add(true);
  //       // }
  //     }
  //   } else {
  //     _locationPermissionController.sink.add(false);
  //     _isDataAvailableController.sink.add(true);
  //   }
  //   callFetchLastData();
  // }

  // void callFetchOnlyRecentlyViewed() async {
  //   String userID = await storage.read(key: 'user_id');
  //
  //   if (userID != null) {
  //     fetchRecentlyViewedCarData(userID).then((recentlyViewedCarResponse) {
  //       var _recentlyViewedCarData = FetchRecentlyViewedCarResponse.fromJson(
  //           json.decode(recentlyViewedCarResponse.body!));
  //       if (_recentlyViewedCarData.cars.length >= 10) {
  //         var subListRecent = _recentlyViewedCarData.cars.sublist(0, 10);
  //         _recentlyViewedCarData.cars = subListRecent;
  //       }
  //
  //       // _recentlyViewedCarController.sink.add(_recentlyViewedCarData);
  //     });
  //   }
  // }

  @override
  void dispose() {
    _loggedInController.close();
    _isDataAvailableController.close();
    // _newCarDataController.close();
    _currentAddressController.close();
    _userIdController.close();
    // _recentlyViewedCarController.close();
    _previouslyBookedCarController.close();
    // _popularCarController.close();
    _locationPermissionController.close();
    _progressIndicatorController.close();
  }
}
