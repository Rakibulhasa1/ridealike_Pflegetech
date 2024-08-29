import 'package:flutter/material.dart';
import 'package:ridealike/widgets/logo.dart';

class CreateProfileOrSignIn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      //Content of tabs
      body: new SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 100),
              // Logo
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Logo(),
                      ],
                    ),
                  ),
                ],
              ),
              // RideAlike
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 10.0),
                              Text('RideAlike',
                                style: Theme.of(context).textTheme.headline1!.copyWith(
                                  fontFamily: 'Urbanist',
                                  fontSize: 44,
                                  color: Color(0xffFF8F68)
                                ),
                              ),
                              SizedBox(height: 5.0),
                              Text('Go farther.',
                                style: Theme.of(context).textTheme.headline6!.copyWith(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 120),
              // Sign up or Sign in button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffFF8F68),
                            padding: EdgeInsets.all(16.0),
                            elevation: 0.0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),  onPressed: () {
                              Navigator.of(context).pushNamed('/create_profile');
                            },
                            child: Text('Create a profile',
                              style: Theme.of(context).textTheme.headline4!.copyWith(
                                fontSize: 16
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFFFFF),
                            padding: EdgeInsets.all(16.0),
                            // borderSide: BorderSide(width: 2.0, color: Color(0xffFF8F68)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {
                              Navigator.of(context).pushNamed('/signin');
                            },
                            child: Text('Sign In',
                              style: Theme.of(context).textTheme.headline4!.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Urbanist',color: Color(0xff371D32)
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // or
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('- or -',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      color: Color(0xFF353B50),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10),
              // Facebook
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xFF3B5998),
                            // textColor: Colors.white,
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Sign in with Facebook',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                Image.asset('icons/Facebook.png'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Google
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child:  ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFFFFF),
                            padding: EdgeInsets.all(16.0),
                            // borderSide: BorderSide(width: 1.0, color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Sign in with Google',
                                  style: Theme.of(context).textTheme.headline4!.copyWith(
                                    color: Color(0xff9B9B9B)
                                  ),
                                ),
                                Image.asset('icons/Google.png'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // LinkedIn
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child:  ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFFFFF),
                            padding: EdgeInsets.all(16.0),
                            // borderSide: BorderSide(width: 1.0, color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),  onPressed: () {},
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Sign in with LinkedIn',
                                  style: Theme.of(context).textTheme.headline4!.copyWith(
                                    color: Color(0xff9B9B9B)
                                  ),
                                ),
                                Image.asset('icons/Google.png'),
                              ],
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
      ),
    );
  }
}
