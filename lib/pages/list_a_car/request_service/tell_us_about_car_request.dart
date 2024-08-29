import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

Future<Resp> setAbout( CreateCarResponse carData, {bool completed= true, bool saveAndExit = false}) async {
  var setAboutCompleter = Completer<Resp>();

  callAPI(
    setAboutUrl,
    json.encode({
      "CarID": carData.car!.iD,
      "About": {
        "Year": carData.car!.about!.year,
        "CarType": carData.car!.about!.carType,
        "Make": carData.car!.about!.make,
        "Model": carData.car!.about!.model,
        "CarBodyTrim": carData.car!.about!.carBodyTrim,
        "Style":  carData.car!.about!.style,
        "VehicleDescription": carData.car!.about!.vehicleDescription,
        "Location": {
          "Address":  carData.car!.about!.location!.address,
          "FormattedAddress": carData.car!.about!.location!.formattedAddress,
          "Locality":  carData.car!.about!.location!.locality,
          "Region":  carData.car!.about!.location!.region,
          "PostalCode":  carData.car!.about!.location!.postalCode,
          "LatLng": {
            "Latitude": carData.car!.about!.location!.latLng!.latitude,
            "Longitude": carData.car!.about!.location!.latLng!.longitude
          },
          "Notes": carData.car!.about!.location!.notes,
        },
        "NeverBrandedOrSalvageTitle": carData.car!.about!.neverBrandedOrSalvageTitle,
        "CarOwnedBy": carData.car!.about!.carOwnedBy,
        "Completed": completed
      },
      "SaveAndExit": saveAndExit
    }),
  ).then((resp) {
    setAboutCompleter.complete(resp);
  }
  );

  return setAboutCompleter.future;
}
