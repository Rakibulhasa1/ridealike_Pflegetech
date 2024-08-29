import 'dart:convert';

import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/discover/request_service/discover_car_map_request.dart';
import 'package:ridealike/pages/discover/response_model/fetchNewCarResponse.dart';
import 'package:rxdart/rxdart.dart';


class SwapCarMapBloc extends Object with Validators implements BaseBloc {
  final _newCarDataController = BehaviorSubject<FetchNewCarResponse>();
  final _showCarDetailsController = BehaviorSubject<num>();
  final _showSearchHereButtonController = BehaviorSubject<bool>();
  final _newLocationController = BehaviorSubject<LatLng>();
  final _locationController = BehaviorSubject<LatLng>();

  Function(FetchNewCarResponse) get changedNewCar => _newCarDataController.sink.add;
  Function(num) get changedShowDetails => _showCarDetailsController.sink.add;
  Function(bool) get changedShowSearchHereButton => _showSearchHereButtonController.sink.add;
  Function(LatLng) get changedNewLocation => _newLocationController.sink.add;
  Function(LatLng) get changedLocation => _locationController.sink.add;

  Stream<FetchNewCarResponse> get newCarData => _newCarDataController.stream;
  Stream<num> get showDetails => _showCarDetailsController.stream.transform(numValidator);
  Stream<LatLng> get newLocation => _newLocationController.stream;
  Stream<LatLng> get location => _locationController.stream;
  Stream<bool> get showSearchHereButton =>_showSearchHereButtonController.stream.transform(showSearchHereValidator);

  callFetchNewSwapCars() async {
    var newCarRes = await fetchSwapNewCarData();
    var _newCarData = FetchNewCarResponse.fromJson(json.decode(newCarRes.body!));
    _newCarDataController.sink.add(_newCarData);
    if ( _newCarData != null){
      _newCarData.latlng = new Latlng();
      _newCarData.latlng!.latitude = _newCarData.cars!.first.latlng!.latitude;
      _newCarData.latlng!.longitude = _newCarData.cars!.first.latlng!.longitude;
    }
    return _newCarData;
  }

  @override
  void dispose() {
    _newCarDataController.close();
    _showCarDetailsController.close();
    _showSearchHereButtonController.close();
    _newLocationController.close();
    _locationController.close();
  }
}
