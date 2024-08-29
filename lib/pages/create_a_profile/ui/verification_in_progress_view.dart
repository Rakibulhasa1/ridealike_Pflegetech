import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
//profile Status utils
import 'package:ridealike/utils/profile_status.dart';
class VerificationInProgressView extends StatelessWidget {
  final storage = new FlutterSecureStorage();

  @override
  Widget build(BuildContext context) {
//    final Map _receivedData = ModalRoute.of(context).settings.arguments;
    final CreateProfileResponse createProfileResponse =
        ModalRoute.of(context)!.settings.arguments as CreateProfileResponse;

    return Scaffold(
      backgroundColor: Colors.white,
      //Content of tabs
      body: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'icons/Verification-in-Progress.png',
                  height: MediaQuery.of(context).size.width / 2,
                  width: MediaQuery.of(context).size.width / 2,
                  fit: BoxFit.fill,
                )
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Proceed to Profile to complete a few more steps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 30,
                          color: Color(0xFF371D32),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      Text(
                        // "It may take up to 1 business day to verify your profile. We'll send you a message once it's reviewed and approved.",
                        "Thank you for creating your profile with RideAlike. It may take up to 2 business days to verify your information. We’ll send you a message once it’s reviewed and approved. Meanwhile, enjoy browsing RideAlike.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF353B50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Spacer(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                            backgroundColor: Color(0xffFF8F68),
                          ),



                          onPressed: () async {
                            await storage.delete(key: 'profile_id');
                            await storage.write(key: 'profile_id', value: createProfileResponse.user!.profileID);
                            await storage.write(key: 'user_id', value: createProfileResponse.user!.userID);
                            await storage.write(key: 'user_email_id', value: createProfileResponse.user!.registrationStatus!.emailVerified.toString());
                            await ProfileStatus.init();
                             /*AppEventsUtils.logEvent("profile_created_successful",
                                                     params: {"profileCreated": "true",
                                                                }
                                         );*/
                            Navigator.pushNamed(context, '/profile');
                          },
                          child: Text(
                            'Ok',
                            style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
