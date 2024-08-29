import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

Future<Resp> setPreferences(CreateCarResponse _carRules, {bool completed= true, bool saveAndExit = false}) async {
  var carPreferenceCompleter = Completer<Resp>();
  callAPI(
      setPreferenceUrl,
      json.encode({
        "CarID": _carRules.car!.iD,
        "Preference": {
          "IsSmokingAllowed": _carRules.car!.preference!.isSmokingAllowed,
          "IsSuitableForPets": _carRules.car!.preference!.isSuitableForPets,
          "DailyMileageAllowance":
              _carRules.car!.preference!.dailyMileageAllowance,
          "Limit": _carRules.car!.preference!.dailyMileageAllowance == 'Limited'
              ? double.parse(_carRules.car!.preference!.limit.toString()).round().toString()
              : 0,
          "ListingType": {
            "RentalEnabled": _carRules.car!.preference!.listingType!.rentalEnabled,
            "SwapEnabled": _carRules.car!.preference!.listingType!.swapEnabled
          },
          "Completed": completed
        },
        "SaveAndExit": saveAndExit
      })).then((resp) {
    carPreferenceCompleter.complete(resp);
  });
  return carPreferenceCompleter.future;
}

Future<Resp> fetchDailyMileageConfiguration() async {
  var dailyMileageConfigurationCompleter=Completer<Resp>();
  callAPI(getListCarConfigurablesUrl,json.encode(
      {}
  )).then((resp) {
    dailyMileageConfigurationCompleter.complete(resp);
  });
  return dailyMileageConfigurationCompleter.future;

}
