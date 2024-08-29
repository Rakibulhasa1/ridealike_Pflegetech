import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/create_a_profile/ui/create_profile_with_social_view.dart';
import 'package:ridealike/pages/log_in/bloc/social_login_bloc.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

import '../pages/create_a_profile/ui/login_with_social_view.dart';

class CreateProfileOrSignInView extends StatefulWidget {
  @override
  _CreateProfileOrSignInViewState createState() =>
      _CreateProfileOrSignInViewState();
}

class _CreateProfileOrSignInViewState extends State<CreateProfileOrSignInView> {
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
                                  SizedBox(height: 100),
                                  // Logo
                                  Image.asset(
                                    'images/logo black 1.png',
                                    height: 60,
                                  ),

                                  SizedBox(height: 80),

                                  ///RideAlike
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      'Rent and share cars, in one app.',
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
                                  ),
                                  SizedBox(height: 40.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Text(
                                      'Rent a car on demand.\nShare your car and earn up to \$800+ a month.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline6!
                                          .copyWith(
                                            fontFamily: 'Urbanist',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      softWrap: true,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ),

                                  SizedBox(height: 80),

                                  ///Sign up or Sign in button
                                  Row(
                                    children: [
                                      SizedBox(
                                        //height: 55,
                                        width: MediaQuery.of(context).size.width /2.4,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xffFF8F68),
                                            padding: EdgeInsets.all(16.0),
                                            elevation: 0.0,
                                            shape: StadiumBorder()
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CreateProfileWithSocialView()));
                                            // Navigator.of(context)
                                            //     .pushNamed('/create_profile');
                                          },
                                          child: Text(
                                            'Sign up',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Urbanist',
                                                color: Color(0xffFFFFFF),
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      SizedBox(
                                        //height: 55,
                                        width: MediaQuery.of(context).size.width /2.4,
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            backgroundColor: Color(0xFFFFFFFF),
                                            padding: EdgeInsets.all(16.0),
                                            side: BorderSide(
                                                width: 2.0,
                                                color: Color(0xffFF8F68)),
                                            shape: StadiumBorder()
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LoginWithSocialView()));
                                          },
                                          child: Text('Log in',
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600,
                                                  fontFamily: 'Urbanist',
                                                  color: Color(0xff371D32))),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
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
