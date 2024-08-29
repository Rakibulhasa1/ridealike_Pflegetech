import 'dart:convert';

import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/request_service/car_preference_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/list_a_car/response_model/daily_mileage_configuration_response.dart';
import 'package:rxdart/rxdart.dart';

class CarPreferenceBloc extends Object with Validators implements BaseBloc{

  final _carPreferenceController=BehaviorSubject<CreateCarResponse>();
  final _dailyMileageConfigController=BehaviorSubject<FetchDailyMileageConfigurationResponse>();


  Function(CreateCarResponse) get changedCarPreferenceData=>_carPreferenceController.sink.add;
  Function(FetchDailyMileageConfigurationResponse) get changedDailyMileageConfig=>_dailyMileageConfigController.sink.add;
  Stream<CreateCarResponse> get carPreferenceData =>_carPreferenceController.stream;
  Stream<FetchDailyMileageConfigurationResponse> get dailyMileageConfig =>_dailyMileageConfigController.stream;

  //progressIndicator//
  final _progressIndicatorController =BehaviorSubject<int>();
  Function(int) get changedProgressIndicator => _progressIndicatorController.sink.add;
  Stream<int> get progressIndicator => _progressIndicatorController.stream;

  @override
  void dispose() {
    _carPreferenceController.close();
    _dailyMileageConfigController.close();
    _progressIndicatorController.close();
  }

  carPreferences(CreateCarResponse data, {bool completed= true, bool saveAndExit = false}) async {
    var response= await setPreferences(data, completed: completed, saveAndExit: saveAndExit);
    if(response!=null && response.statusCode==200){
     var  preferenceResponse=CreateCarResponse.fromJson(json.decode(response.body!));
     changedCarPreferenceData.call(preferenceResponse);
     return preferenceResponse;
    }else{
      return null;
    }
  }
  Future<FetchDailyMileageConfigurationResponse?> callFetchDailyMileageConfiguration() async {
    var response =await fetchDailyMileageConfiguration();
    if(response!=null && response.statusCode==200){
      var dailyMileageConfigResponse=FetchDailyMileageConfigurationResponse.fromJson(json.decode(response.body!));
      return dailyMileageConfigResponse;
    }else{
      return null ;
    }
  }


}