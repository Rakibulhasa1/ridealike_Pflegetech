import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/payout_method_response.dart';

Future<Resp> setPayoutMethod(_userID, FetchPayoutMethodResponse payoutMethodResponse) async {
  var payOutMethodCompleter = Completer<Resp>();

  callAPI(
    setPayoutMethodUrl,
    json.encode(
        {
          "PayoutMethod": {
            "UserID": _userID,
            "PayoutMethodType": payoutMethodResponse.payoutMethod!.payoutMethodType,
            "PaypalData": {
              "email":payoutMethodResponse.payoutMethod!.paypalData!.email
            },
            "InteracETransferData": {
              "email": payoutMethodResponse.payoutMethod!.interacETransferData!.email
            },
            "DirectDepositData": {
              "Address": payoutMethodResponse.payoutMethod!.directDepositData!.address,
              "City": payoutMethodResponse.payoutMethod!.directDepositData!.city,
              "Province": payoutMethodResponse.payoutMethod!.directDepositData!.province,
              "PostalCode": payoutMethodResponse.payoutMethod!.directDepositData!.postalCode,
              "Country": payoutMethodResponse.payoutMethod!.directDepositData!.country,
              "Name": payoutMethodResponse.payoutMethod!.directDepositData!.name,
              "IBAN": payoutMethodResponse.payoutMethod!.directDepositData!.iBAN
            }
          }
        }
    ),
  ).then((resp) {
    payOutMethodCompleter.complete(resp);
  }
  );

  return payOutMethodCompleter.future;
}