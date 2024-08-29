import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/request_service/create_car_request.dart';
import 'package:ridealike/pages/list_a_car/request_service/set_car_pricing_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/car_suggested_data_response.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/list_a_car/response_model/payout_method_response.dart';
import 'package:rxdart/rxdart.dart';



class CarPricingBloc extends Object with Validators implements BaseBloc {
  final _carPricingDataController = BehaviorSubject<CreateCarResponse>();
  final _carSuggestedPriceController = BehaviorSubject<FetchCarSuggestedDataResponse>();

  final storage = new FlutterSecureStorage();
  //progressIndicator//
  final _progressIndicatorController =BehaviorSubject<int>();
  Function(int) get changedProgressIndicator => _progressIndicatorController.sink.add;
  Stream<int> get progressIndicator => _progressIndicatorController.stream;

  Function(CreateCarResponse) get changedCarPricingData =>
      _carPricingDataController.sink.add;

  Function(FetchCarSuggestedDataResponse) get changedCarSuggestedPrice =>
      _carSuggestedPriceController.sink.add;

  Stream<CreateCarResponse> get carPricingData =>
      _carPricingDataController.stream;

  Stream<FetchCarSuggestedDataResponse> get carSuggestedPrice =>
      _carSuggestedPriceController.stream;

  Future<FetchCarSuggestedDataResponse?> getCarSuggestedPriceData(
      CreateCarResponse data) async {
    var response = await fetchCarSuggestedData(data);
    print('response${response.body}');
    if (response != null && response.statusCode == 200) {
      var suggestedPriceDataResp =
          FetchCarSuggestedDataResponse.fromJson(json.decode(response.body!));
      return suggestedPriceDataResp;
    } else {
      return null;
    }
  }

  setCarPricing(CreateCarResponse createCarResponse, {bool completed= true, bool saveAndExit = false}) async {
    var resp = await setPricing(createCarResponse, completed: completed, saveAndExit: saveAndExit);
    if (resp != null && resp.statusCode == 200) {
      var carPricingResp = CreateCarResponse.fromJson(json.decode(resp.body!));
      return carPricingResp;
    } else {
      return null;
    }
  }
  Future<FetchPayoutMethodResponse> callFetchPayoutMethod() async {
    var completer = Completer<FetchPayoutMethodResponse>();
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var res = await getPayoutMethod(userID);

      if (res != null && res.statusCode == 200) {
        var payoutMethodResp =
        FetchPayoutMethodResponse.fromJson(json.decode(res.body!));
        completer.complete(payoutMethodResp);
      }
    }

    return completer.future;
  }

  @override
  void dispose() {
    _carPricingDataController.close();
    _carSuggestedPriceController.close();
    _progressIndicatorController.close();
  }
}
