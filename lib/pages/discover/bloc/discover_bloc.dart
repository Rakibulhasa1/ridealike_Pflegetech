import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/common/location_util.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/discover/request_service/discover_request.dart';
import 'package:ridealike/pages/discover/response_model/fetchNewCarResponse.dart';
import 'package:rxdart/rxdart.dart';

class DiscoverBloc extends Object with Validators implements BaseBloc{

  final onTappedController =BehaviorSubject<bool>();
  final newCarDataController =BehaviorSubject<FetchNewCarResponse>();

  Function(bool) get changedOnTapped=>onTappedController.sink.add;
  Function(FetchNewCarResponse) get changedNewCarData=>newCarDataController.sink.add;

  Stream<bool> get  onTapped=>onTappedController.stream;
  Stream<FetchNewCarResponse> get  newCarData=>newCarDataController.stream.transform(fetchNewCarValidator);


  callFetchNewCars() async {
    Position? _locationData = await LocationUtil.getCurrentLocation();

    if (_locationData!= null) {
      var res = await positionFetchNewCarData(_locationData);
      FetchNewCarResponse _newCarData = FetchNewCarResponse.fromJson(
          json.decode(res.body!));
      newCarDataController.sink.add(_newCarData);
      if ( _newCarData != null){
        _newCarData.latlng = new Latlng();
        _newCarData.latlng!.latitude = _locationData.latitude!;
        _newCarData.latlng!.longitude = _locationData.longitude!;
      }
      return _newCarData;
    }

  }
  @override
  void dispose() {
    onTappedController.close();
    newCarDataController.close();
  }

}