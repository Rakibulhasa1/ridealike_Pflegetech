import 'dart:convert';

import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/request_service/car_features_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:rxdart/rxdart.dart';

class CarFeaturesBloc extends Object with Validators implements BaseBloc{
  final _carFeatureDataController=BehaviorSubject<CreateCarResponse>();

  Function(CreateCarResponse) get changedCarFeaturesData=>_carFeatureDataController.sink.add;
  Stream<CreateCarResponse> get carFeaturesData=>_carFeatureDataController.stream;
  //progressIndicator//
  final _progressIndicatorController =BehaviorSubject<int>();
  Function(int) get changedProgressIndicator => _progressIndicatorController.sink.add;
  Stream<int> get progressIndicator => _progressIndicatorController.stream;


  @override
  void dispose() {
    _carFeatureDataController.close();
    _progressIndicatorController.close();
  }



  setCarFeatures(CreateCarResponse data, {bool completed= true, bool saveAndExit = false}) async {
    var response = await setFeatures(data, completed: completed, saveAndExit: saveAndExit);
    if(response!=null && response.statusCode==200){
       var carFeatureResponse=CreateCarResponse.fromJson(json.decode(response.body!));
       changedCarFeaturesData.call(carFeatureResponse);
       return carFeatureResponse;
    }else{
      return  null;
    }
  }

}