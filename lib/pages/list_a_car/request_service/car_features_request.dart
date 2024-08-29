import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';


Future<Resp> setFeatures( CreateCarResponse carFeatures, {bool completed= true, bool saveAndExit = false}) async {

  var carFeaturesCompleter=Completer<Resp>();

  callAPI(setFeaturesUrl, json.encode( {
    "CarID": carFeatures.car!.iD,
    "Features": {
      "FuelType": carFeatures.car!.features!.fuelType,
      "Transmission": carFeatures.car!.features!.transmission,
      "GreenFeature" : carFeatures.car!.features!.greenFeature,
      "NumberOfDoors": carFeatures.car!.features!.numberOfDoors,
      "NumberOfSeats": carFeatures.car!.features!.numberOfSeats!.round(),
      "TruckBoxSize": carFeatures.car!.features!.truckBoxSize,
      "Interior": {
        "HasAirConditioning": carFeatures.car!.features!.interior!.hasAirConditioning,
        "HasHeatedSeats": carFeatures.car!.features!.interior!.hasHeatedSeats,
        "HasVentilatedSeats": carFeatures.car!.features!.interior!.hasVentilatedSeats,
        "HasBluetoothAudio": carFeatures.car!.features!.interior!.hasBluetoothAudio,
        "HasAppleCarPlay": carFeatures.car!.features!.interior!.hasAppleCarPlay,
        "HasAndroidAuto": carFeatures.car!.features!.interior!.hasAndroidAuto,
        "HasSunroof": carFeatures.car!.features!.interior!.hasSunroof,
        "HasUsbChargingPort": carFeatures.car!.features!.interior!.hasUsbChargingPort
      },
      "Exterior": {
        "HasAllWheelDrive": carFeatures.car!.features!.exterior!.hasAllWheelDrive,
        "HasBikeRack": carFeatures.car!.features!.exterior!.hasBikeRack,
        "HasSkiRack": carFeatures.car!.features!.exterior!.hasSkiRack,
        "HasSnowTires": carFeatures.car!.features!.exterior!.hasSnowTires
      },
      "Comfort": {
        "RemoteStart": carFeatures.car!.features!.comfort!.remoteStart,
        "FreeWifi": carFeatures.car!.features!.comfort!.freeWifi
      },
      "SafetyAndPrivacy": {
        "HasChildSeat": carFeatures.car!.features!.safetyAndPrivacy!.hasChildSeat,
        "HasSpareTire": carFeatures.car!.features!.safetyAndPrivacy!.hasSpareTire,
        "HasGPSTrackingDevice": carFeatures.car!.features!.safetyAndPrivacy!.hasGPSTrackingDevice,
        "HasDashCamera": carFeatures.car!.features!.safetyAndPrivacy!.hasDashCamera
      },
      "CustomFeatures": carFeatures.car!.features!.customFeatures,
      "Completed": completed
    },
    "SaveAndExit": saveAndExit
  })).then((resp) {
    carFeaturesCompleter.complete(resp);
  });
return carFeaturesCompleter.future;
}