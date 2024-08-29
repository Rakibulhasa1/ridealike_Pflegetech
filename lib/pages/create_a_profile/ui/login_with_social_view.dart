import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

import '../../../utils/profile_status.dart';
import '../../log_in/bloc/social_login_bloc.dart';
import '../response_model/create_profile_response_model.dart';

class LoginWithSocialView extends StatefulWidget {
  @override
  _LoginWithSocialViewState createState() => _LoginWithSocialViewState();
}

class _LoginWithSocialViewState extends State<LoginWithSocialView> {
  final socialLogInBloc = SocialLogInBloc();

  final storage = new FlutterSecureStorage();

  Map? receivedData;
  bool available = false;
  bool loader = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //AppEventsUtils.logEvent("signin_view");
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Create Profile or Sign In"});
    setState(() {
      loader = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    try {
      receivedData = ModalRoute.of(context)!.settings.arguments as Map;
    } catch (e) {}
    socialLogInBloc.changedProgressIndicator.call(0);
    return loader == true
        ? CircularProgressIndicator()
        : Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              elevation: 0,
            ),
            backgroundColor: Colors.white,

            //Content of tabs
            body: StreamBuilder<int>(
                stream: socialLogInBloc.progressIndicator,
                builder: (context, progressIndicatorSnapshot) {
                  return progressIndicatorSnapshot.hasData &&
                          progressIndicatorSnapshot.data == 0
                      ? Container(
                          child: new SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.only(left: 25.0, right: 25),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 120),

                                  ///RideAlike
                                  Image.asset(
                                    'images/logo black 1.png',
                                    height: 60,
                                  ),
                                  SizedBox(height: 60),
                                  Text(
                                    'Welcome Back.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline6!
                                        .copyWith(
                                            fontFamily: 'Urbanist',
                                            fontSize: 40,
                                            fontWeight: FontWeight.w700),
                                    softWrap: true,
                                    overflow: TextOverflow.visible,
                                  ),
                                  SizedBox(height: 160.0),

                                  ///Sign up or Google, Apple button
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: 60,
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xffFF8F68),
                                            padding: EdgeInsets.all(16.0),
                                            elevation: 0.0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                          ),
                                          onPressed: () {
                                            if (receivedData != null) {
                                              Navigator.of(context)
                                                  .pushReplacementNamed(
                                                      '/signin_ui',
                                                      arguments: receivedData);
                                            } else {
                                              Navigator.of(context)
                                                  .pushNamed('/signin_ui');
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                'svg/Vector (1).svg',
                                                width: 20,
                                                height: 20,
                                              ),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                'Continue with Email',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    color: Color(0xffFFFFFF),
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      SizedBox(
                                        height: 60,
                                        width: double.maxFinite,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Color(0xFFFFFFFF),
                                            padding: EdgeInsets.all(16.0),
                                            side: BorderSide(
                                                width: 1.5,
                                                color: Color(0xff000000)),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                          ),
                                          onPressed: () async {
                                            //TODO
                                            socialLogInBloc
                                                .changedProgressIndicator
                                                .call(1);
                                            CreateProfileResponse?
                                                googleResponse =
                                                await socialLogInBloc
                                                    .socialLogWithGoogle();
                                            socialLogInBloc
                                                .changedProgressIndicator
                                                .call(0);
                                            debugPrint(
                                                "googleResponse received");
                                            if (googleResponse != null &&
                                                googleResponse.status == null) {
                                              if (googleResponse.message ==
                                                  'Email already exists') {
                                                Navigator.of(context).pushNamed(
                                                    '/signin_ui',
                                                    arguments: {
                                                      'MESSAGE': googleResponse
                                                          .message,
                                                      'EMAIL': googleResponse
                                                          .details![0].value
                                                    });
                                              }
                                            } else if (googleResponse != null &&
                                                !(googleResponse
                                                    .user!
                                                    .registrationStatus!
                                                    .termsAndConditionAccepted!)) {
                                              var arguments = googleResponse;

                                              Navigator.pushNamed(
                                                context,
                                                '/terms_and_conditions_ui',
                                                arguments: arguments,
                                              );
                                            } else if (googleResponse != null &&
                                                !(googleResponse
                                                    .user!
                                                    .registrationStatus!
                                                    .phoneVerified!)) {
                                              var arguments = googleResponse;

                                              Navigator.pushNamed(context,
                                                  '/verify_phone_number_ui',
                                                  arguments: arguments);
                                            } else if (googleResponse != null &&
                                                !(googleResponse
                                                    .user!
                                                    .registrationStatus!
                                                    .dLDocumentsSubmitted!)) {
                                              var arguments = googleResponse;

                                              Navigator.pushNamed(
                                                context,
                                                '/verify_identity_ui',
                                                arguments: json
                                                    .encode(arguments.toJson()),
                                              );
                                            } else {
                                              if (googleResponse != null) {
                                                await storage.deleteAll();

                                                await storage.write(
                                                    key: 'profile_id',
                                                    value: googleResponse!
                                                        .user!.profileID);
                                                await storage.write(
                                                    key: 'user_id',
                                                    value: googleResponse
                                                        .user!.userID);
                                                await storage.write(
                                                    key: 'jwt',
                                                    value: googleResponse.jWT);

                                                // Navigator.pushNamed(context, '/profile');
                                                if (receivedData != null &&
                                                    receivedData!['ROUTE'] !=
                                                        null) {
                                                  Navigator.pushReplacementNamed(
                                                          context,
                                                          receivedData![
                                                              'ROUTE'],
                                                          arguments:
                                                              receivedData![
                                                                  'ARGUMENTS'])
                                                      .then((value) => {
                                                            socialLogInBloc
                                                                .changedProgressIndicator
                                                                .call(1)
                                                          });

                                                  return;
                                                } else {
                                                  await ProfileStatus.init();
                                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                                      '/discover_tab', (Route<dynamic> route) => false);
                                                }
                                              }
                                            }
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SvgPicture.asset(
                                                  'svg/Social icon.svg'),
                                              SizedBox(
                                                width: 8,
                                              ),
                                              Text('Continue with Google',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Urbanist',
                                                      color:
                                                          Color(0xff371D32))),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // SizedBox(height: 15),
                                      // SizedBox(
                                      //   height: 60,
                                      //   width: double.maxFinite,
                                      //   child: OutlinedButton(
                                      //     style: OutlinedButton.styleFrom(
                                      //       backgroundColor: Color(0xFFFFFFFF),
                                      //       padding: EdgeInsets.all(16.0),
                                      //       side: BorderSide(
                                      //           width: 1.5,
                                      //           color: Color(0xff000000)),
                                      //       shape: RoundedRectangleBorder(
                                      //           borderRadius:
                                      //               BorderRadius.circular(8.0)),
                                      //     ),
                                      //     onPressed: () {},
                                      //     child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.center,
                                      //       children: [
                                      //         SvgPicture.asset(
                                      //             'svg/Social icon (1).svg'),
                                      //         SizedBox(
                                      //           width: 8,
                                      //         ),
                                      //         Text('Continue with Apple',
                                      //             style: TextStyle(
                                      //                 fontSize: 18,
                                      //                 fontWeight:
                                      //                     FontWeight.w500,
                                      //                 fontFamily: 'Urbanist',
                                      //                 color:
                                      //                     Color(0xff371D32))),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: 180),
                                  Text(
                                      'By creating an account or continuing to use RideAlike, you agree to the Terms of Service and the Privacy Policy.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Urbanist',
                                          color: Color(0xff371D32)))
                                  // or
                                ],
                              ),
                            ),
                          ),
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new CircularProgressIndicator(strokeWidth: 2.5)
                            ],
                          ),
                        );
                }),
          );
  }
}
