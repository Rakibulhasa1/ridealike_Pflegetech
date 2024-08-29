import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

Future<Resp> setPricing( CreateCarResponse carData, {bool completed= true, bool saveAndExit = false}) async {
  var pricingCompleter=Completer<Resp>();
  callAPI(setPricingUrl, json.encode(
      {
        "CarID": carData.car!.iD,
        "Pricing": {
          "RentalPricing": {
            "PerHour": carData.car!.pricing!.rentalPricing!.perHour!.toInt(),
            "PerDay": carData.car!.pricing!.rentalPricing!.perDay!.toInt(),
            "PerExtraKMOverLimit": carData.car!.pricing!.rentalPricing!.perExtraKMOverLimit,
            "EnableCustomDelivery": carData.car!.pricing!.rentalPricing!.enableCustomDelivery,
            "PerKMRentalDeliveryFee": carData.car!.pricing!.rentalPricing!.perKMRentalDeliveryFee,
            "BookForWeekDiscountPercentage":carData.car!.pricing!.rentalPricing!.bookForWeekDiscountPercentage,
            "BookForMonthDiscountPercentage": carData.car!.pricing!.rentalPricing!.bookForMonthDiscountPercentage,
            "OneTime20DiscountForFirst3Users": carData.car!.pricing!.rentalPricing!.oneTime20DiscountForFirst3Users
          },
          "SwapPricing": {},
          "Completed": completed
        },
        "SaveAndExit": saveAndExit

      })).then((resp) {
    pricingCompleter.complete(resp);
  });
  return pricingCompleter.future;

}




Future<Resp> fetchCarSuggestedData( CreateCarResponse carData) async {
  var carSuggestedDataCompleter=Completer<Resp>();
  callAPI(getSuggestedPricingByCarIDUrl, json.encode(
      {
        "CarID": carData.car!.iD
      }
  )).then((resp){
    carSuggestedDataCompleter.complete(resp);
  });
  return carSuggestedDataCompleter.future;

}