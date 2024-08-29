import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/main.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../create_a_profile/ui/create_profile_with_social_view.dart';
import '../create_a_profile/ui/login_with_social_view.dart';

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        //background image
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/intro_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        padding: EdgeInsets.only(
          left: SizeConfig.deviceWidth!* 0.05,
          right: SizeConfig.deviceWidth!* 0.025,
          bottom: SizeConfig.deviceHeight!* 0.017,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //icon
            Container(
              //padding: EdgeInsets.symmetric(vertical: SizeConfig.deviceHeight!* 0.1),
              child: Image.asset(
                'images/ridealike_white.png',
                height: SizeConfig.deviceHeight!* 0.3,
                width: SizeConfig.deviceWidth!* 0.5,
              ),
            ),

            //SizedBox(height: SizeConfig.deviceHeight!* 0.03,),

            //intro lines
            Image.asset(
              'images/intro1.png',
              width: SizeConfig.deviceWidth!* 0.8,
            ),
            SizedBox(
              height: SizeConfig.deviceHeight!* 0.05,
            ),
            Image.asset(
              'images/intro2.png',
              width: SizeConfig.deviceWidth!* 0.8,
            ),
            SizedBox(
              height: SizeConfig.deviceHeight!* 0.05,
            ),
            Image.asset(
              'images/intro3.png',
              width: SizeConfig.deviceWidth!* 0.8,
            ),

            //get started button
            Spacer(),
            SizedBox(
              width: MediaQuery.of(context).size.width / 1.5,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0.0,
                  backgroundColor: Color(0xffFF8F68),
                  padding: EdgeInsets.all(16.0),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),

                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('first_run', false);
                  AppEventsUtils.logEvent("onboarding_completed");
                  //Navigator.of(context).pushNamed('/create_profile');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              CreateProfileWithSocialView()));
                },
                child: Text(
                  'Sign Up',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 24,
                      color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: SizeConfig.deviceHeight!* 0.01,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('first_run', false);
                    AppEventsUtils.logEvent("onboarding_completed");
                    /*Navigator.of(context)
                        .pushNamed('/signin_ui');*/
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LoginWithSocialView()));
                  },
                  child: Text(
                    'Log In',
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Urbanist',
                        decoration: TextDecoration.underline,
                        color: Colors.white),
                  ),
                ),
                Text(
                  'or',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                TextButton(
                  child: Text(
                    'Start Browsing',
                    style: TextStyle(
                      // fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                      decoration: TextDecoration.underline,
                      color: Colors.white,
                      fontSize: 18
                    ),
                  ),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('first_run', false);
                    AppEventsUtils.logEvent("onboarding_completed");
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) {
                          return Tabs();
                        }));
                  },
                )
              ],
            ),
            SizedBox(
              height: SizeConfig.deviceHeight!* 0.02,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("onboarding_started");
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Intro"});
    FlutterSecureStorage storage = FlutterSecureStorage();
    storage.deleteAll();
  }
}
