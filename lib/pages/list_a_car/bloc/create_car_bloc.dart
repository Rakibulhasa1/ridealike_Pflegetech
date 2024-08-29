import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/bloc/status_of_car_listing.dart';
import 'package:ridealike/pages/list_a_car/request_service/create_car_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/list_a_car/response_model/payout_method_response.dart';
import 'package:rxdart/rxdart.dart';

class CreateCarBloc extends Object with Validators implements BaseBloc {
  final _buttonController = BehaviorSubject<bool>();
  final _carDataController = BehaviorSubject<CreateCarResponse>();
  final _statusController = BehaviorSubject<StatusOfCarList>();

  final storage = new FlutterSecureStorage();

  Function(bool) get changedButton => _buttonController.sink.add;
  Function(CreateCarResponse) get changedData => _carDataController.sink.add;
  Function(StatusOfCarList) get changedStatus => _statusController.sink.add;


  Stream<bool> get nextButton => _buttonController.stream;
  Stream<CreateCarResponse> get carData => _carDataController.stream;
  Stream<StatusOfCarList> get status => _statusController.stream;

  //progressIndicator//
  final _progressIndicatorController =BehaviorSubject<int>();
  Function(int) get changedProgressIndicator => _progressIndicatorController.sink.add;
  Stream<int> get progressIndicator => _progressIndicatorController.stream;

  createCarButton() async {

  _buttonController.sink.add(false);
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var responseOfCar = await createCar(userID);
      print('create car response${responseOfCar.body}');
      if (responseOfCar != null && responseOfCar.statusCode == 200) {
        CreateCarResponse createCarResponse = CreateCarResponse.fromJson(json.decode(responseOfCar.body!));
        print("argument$createCarResponse");
        return createCarResponse;
      } else {
        var errorMessage =
            json.decode(responseOfCar.body!)['Status']['error'];
        print('errorMessage$errorMessage');
        return null;
      }
    }
  }



  @override
  void dispose() {
    _progressIndicatorController.close();
    _buttonController.close();
    _carDataController.close();
    _statusController.close();

  }

  void maintainStatus(CreateCarResponse response, int purpose) {
    StatusOfCarList carList = StatusOfCarList(
        StatusValue.turn,
        StatusValue.notAccessible,
        StatusValue.notAccessible,
        StatusValue.notAccessible,
        StatusValue.notAccessible,
        StatusValue.notAccessible,
        1, purpose);

    carList.carAbout = response.car!.about!.completed!? StatusValue.completed : StatusValue.notAccessible;
    carList.imagesAndDocuments = response.car!.imagesAndDocuments!.completed!? StatusValue.completed : StatusValue.notAccessible;
    carList.features = response.car!.features!.completed!? StatusValue.completed : StatusValue.notAccessible;
    carList.preference = response.car!.preference!.completed!? StatusValue.completed : StatusValue.notAccessible;
    carList.availability = response.car!.availability!.completed!? StatusValue.completed : StatusValue.notAccessible;
    carList.pricing = response.car!.pricing!.completed!? StatusValue.completed : StatusValue.notAccessible;

    carList.maintainSelection();
    changedStatus.call(carList);

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
  String headerText(int purpose){
    if(purpose==0){
      return 'It’s easy to list your vehicle';
    }else if(purpose==1){
      return 'Continue your listing';

    }else if(purpose==2){
      return 'Review your listing';

    }else if(purpose==3){
      return 'Edit your listing';

    }
    return '';
  }
  String subHeaderText(int purpose){
    if(purpose==0){
      return 'To list with RideAlike, you follow 6 easy steps in about 10 minutes:';
    }else if(purpose==1){
      return 'Please continue providing details of your vehicle and your preferences. You can always save and exit and come back to it later on.';

    }else if(purpose==2){
      return 'You can review and make changes to any of the steps below, or proceed to publish.';

    }
    return '';
  }
  String buttonText(int purpose){
    if(purpose==0){
      return 'Next';
    }else if(purpose==1){
      return 'Continue your listing';

    }else if(purpose==2 ){
      return 'Save';

    }
    return '';
  }


}
