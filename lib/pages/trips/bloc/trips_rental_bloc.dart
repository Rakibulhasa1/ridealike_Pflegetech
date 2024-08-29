import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/trips/request_service/request_reimbursement.dart';
import 'package:ridealike/pages/trips/request_service/trips_fetch_car_profile_group_status_request.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/rent_agree_carinfo_response.dart';
import 'package:ridealike/pages/trips/response_model/swap_agree_carinfo_response.dart';
import 'package:rxdart/rxdart.dart';
class TripsRentalBloc implements BaseBloc {
  final _tripsController = BehaviorSubject<Trips>();
  final _swapTripsController = BehaviorSubject<Trips>();
  final _tripsTypeController = BehaviorSubject<String>();
  final _cancellationNoteController = BehaviorSubject<String>();

  Function(Trips) get changedTripsData => _tripsController.sink.add;
  Function(Trips) get changedSwapTripsData => _swapTripsController.sink.add;

  Function(String) get changedTripsTypeData => _tripsTypeController.sink.add;

  Function(String) get changedCancellationNote =>
      _cancellationNoteController.sink.add;

  Stream<Trips> get tripsData => _tripsController.stream;
  Stream<Trips> get swapTripsData => _swapTripsController.stream;

  Stream<String> get tripsType => _tripsTypeController.stream;

  Stream<String> get cancellationNote => _cancellationNoteController.stream;

  //progressIndicator//
  final _progressIndicatorController = BehaviorSubject<int>();

  Function(int) get changedProgressIndicator =>
      _progressIndicatorController.sink.add;

  Stream<int> get progressIndicator => _progressIndicatorController.stream;

  //PaddingController//
  final _paddingHeightController = BehaviorSubject<double>();

  Function(double) get changePaddingHeight => _paddingHeightController.sink.add;

  Stream<double> get paddingHeight => _paddingHeightController.stream;
  final storage = new FlutterSecureStorage();

  Future<Trips?> getTripByIdMethod(Trips tripDetails) async {
    var resp = await getTripByID(tripDetails.tripID!);
    if (resp != null && resp.statusCode == 200) {
      tripDetails.fromJsonTrips(json.decode(resp.body!)['Trip']);
      changedTripsData.call(tripDetails);
      return tripDetails;
    } else {
      return null;
    }
  }
  Future<Trips?> _getTripByIdMethodInternal(Trips tripDetails) async {
    var resp = await getTripByID(tripDetails.tripID!);
    if (resp != null && resp.statusCode == 200) {
      tripDetails.fromJsonTrips(json.decode(resp.body!)['Trip']);
      return tripDetails;
    } else {
      return null;
    }
  }
  Future<Trips?> getTripByIdSwap(Trips tripDetails) async {
    var resp = await getTripByID(tripDetails.swapData!.otherTripID!);
    if (resp != null && resp.statusCode == 200) {
      Trips trips = Trips.fromJson(json.decode(resp.body!)['Trip']);
      changedSwapTripsData.call(trips);
      return trips;
    } else {
      return null;
    }
  }

  Future<Trips?> rentAgreeIdCarInfo(Trips tripDetails) async {
    String? userId = await storage.read(key: 'user_id');
    if(userId != null) {
      _getTripByIdMethodInternal(tripDetails).then((value) async {
        if (value != null ) {
          tripDetails = value;
        }
        if (tripDetails.tripType != 'Swap') {
          var response = await getRentAgreementId(tripDetails.rentAgreementID, userId);
          RentAgreementCarInfoResponse rentAgreementCarInfoResponse;
          if (response != null && response.statusCode == 200) {
            rentAgreementCarInfoResponse = RentAgreementCarInfoResponse.fromJson(json.decode(response.body!));
            tripDetails.car = rentAgreementCarInfoResponse.rentAgreement!.car;
          }
          changedTripsData.call(tripDetails);
        } else {
          getTripByIdSwap(tripDetails).then((value) async {
            if(value != null ) {
              var response = await getSwapAgreementId(tripDetails.swapAgreementID, userId);
              SwapAgreementCarInfoResponse swapAgreementCarInfoResponse;
              if (response != null && response.statusCode == 200) {
                swapAgreementCarInfoResponse = SwapAgreementCarInfoResponse.fromJson(json.decode(response.body!));
                tripDetails.car = swapAgreementCarInfoResponse.swapAgreementTerms!.theirCar;
                tripDetails.myCarForSwap = swapAgreementCarInfoResponse.swapAgreementTerms!.myCar;
                value.car =swapAgreementCarInfoResponse.swapAgreementTerms!.myCar;
                value.myCarForSwap =swapAgreementCarInfoResponse.swapAgreementTerms!.theirCar;
                changedSwapTripsData.call(value);
                changedTripsData.call(tripDetails);
              }
            }
          });


          // print('agrremt$rentAgreementCarInfoResponse');

        }
        return tripDetails;

      });

    }else {
      return null;
    }
  }



  // Future<Trips> rentAgreeIdCarInfo(Trips tripDetails) async {
  //   String userId = await storage.read(key: 'user_id');
  //   if(userId != null) {
  //       var response = await getRentAgreementId(tripDetails.rentAgreementID, userId);
  //       RentAgreementCarInfoResponse rentAgreementCarInfoResponse;
  //       if (response != null && response.statusCode == 200) {
  //         rentAgreementCarInfoResponse = RentAgreementCarInfoResponse.fromJson(json.decode(response.body!));
  //         tripDetails.car = rentAgreementCarInfoResponse.rentAgreement.car;
  //       }
  //     changedTripsData.call(tripDetails);
  //     return tripDetails;
  //   }else {
  //     return null;
  //   }
  // }

  checkButtonsVisibility(Trips tripDetails) {
    var currentTime = DateTime.now().toLocal();
    int minutesStart =
        currentTime.difference(tripDetails.startDateTime!).inMinutes;
    int minutesEnd = currentTime.difference(tripDetails.endDateTime!).inMinutes;
    if (minutesStart > -60 && minutesEnd <= 0) {
      return true;
    } else {
      return false;
    }
  }

  checkButtonVisibility(Trips tripDetails) {
    DateTime startTime = tripDetails.startDateTime!;
    startTime = startTime.subtract(Duration(
        minutes: startTime.minute,
        seconds: startTime.second,
        milliseconds: startTime.millisecond,
        microseconds: startTime.microsecond));
    var currentTime = DateTime.now().toUtc();
    int minutesStart = currentTime.difference(startTime).inMinutes;
    int minutesEnd = currentTime.difference(tripDetails.endDateTime!).inMinutes;
    if (minutesStart > -60 && minutesEnd <= 0) {
      return true;
    } else {
      return false;
    }
  }
  checkCancelButtonVisibility(Trips tripDetails) {
    DateTime startTime = tripDetails.startDateTime!;
    startTime = startTime.subtract(Duration(
        minutes: startTime.minute,
        seconds: startTime.second,
        milliseconds: startTime.millisecond,
        microseconds: startTime.microsecond));
    var currentTime = DateTime.now().toUtc();
    int minutesStart = currentTime.difference(startTime).inMinutes;
    int minutesEnd = currentTime.difference(tripDetails.endDateTime!).inMinutes;
    if (minutesStart <= 240 ) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void dispose() {
    _tripsController.close();
    _tripsTypeController.close();
    _progressIndicatorController.close();
    _paddingHeightController.close();
    _cancellationNoteController.close();
  }

  Future<CreateCarResponse?> getOwnCarImageId(Trips tripDetails) async {
    var res = await getCarData(tripDetails.swapData!.myCarID);
    if (res != null && res.statusCode == 200) {
      CreateCarResponse createCarResponse =
          CreateCarResponse.fromJson(json.decode(res.body!));
      return createCarResponse;
    }
    return null;
  }

  String getTextForSwappedCar(Trips tripDetails) {
    String myCar = tripDetails.myCarForSwap!.about!.year == null
        ? ''
        : 'My ' +
            tripDetails.myCarForSwap!.about!.year! +
            ' ' +
            tripDetails.myCarForSwap!.about!.make! +
            ' ' +
            tripDetails.myCarForSwap!.about!.model!;

    String hostCar = tripDetails.car!.about!.year == null
        ? ''
        : '${tripDetails.hostProfile!.firstName}\'s ' +
            tripDetails.car!.about!.year! +
            ' ' +
            tripDetails.car!.about!.make! +
            ' ' +
            tripDetails.car!.about!.model!;
    String carName = '$myCar  ➞  $hostCar';
    return carName;
  }
}
