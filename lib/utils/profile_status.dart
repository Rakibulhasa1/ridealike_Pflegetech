import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';

class ProfileStatus {
  static bool isProfileComplete = true;
  static bool isLoggedIn = false;
  static bool hasCar = false;

  static Future getVerificationData(String profileId) {
    return callAPI(
      getProfileVerificationUrl,
      json.encode({
        "ProfileID": profileId,
      }),
    );
  }

  static Future<void> init() async {
    final storage = FlutterSecureStorage();
    String? profileID = await storage.read(key: 'profile_id');
    if (profileID != null) {
      //logged in
      isLoggedIn = true;

      var response = await getVerificationData(profileID);
      var responseData = json.decode(response.body!);
      print("Profile Status Utils: " + responseData.toString());

      //has car
      if (responseData['Others'] != null && responseData['Others']['TotalCars'] != null &&
          responseData['Others']['TotalCars'] > 0) {
        hasCar = true;
      } else {
        hasCar = false;
      }

      //profile incomplete
      if (responseData['Verification'] == null || responseData['Others'] == null ||
          responseData['Verification']['VerificationStatus'] == 'Rejected' ||
          responseData['Verification']['EmailVerification']['VerificationStatus'] != 'Verified'
      // ||  responseData['Others']['AboutMeStatus'] != 'Verified' ||
          // responseData['Others']['PaymentMethodStatus'] != 'Verified'
      ) {
        isProfileComplete = false;
      } else {
        isProfileComplete = true;
      }
    } else {
      isLoggedIn = false;
    }

    print('isLoggedIn ' + isLoggedIn.toString());
    print('isProfileComplete ' + isProfileComplete.toString());
    print('hasCar ' + hasCar.toString());
  }
}
