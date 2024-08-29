import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//profile Status utils
import 'package:ridealike/utils/profile_status.dart';
import 'package:ridealike/widgets/map_button.dart';
//profile incomplete indicator
import 'package:ridealike/widgets/profile_incomplete_indicator.dart';

import '../tabs/create_profile_or_sign_in_view.dart' as _createProfileOrSignInViewTab;
import '../tabs/discover.dart' as _discoverTab;
import './verify_your_car_view.dart' as _verifyYourCarView;
import 'discover/bloc/discover_bloc.dart';
import 'profile/profile_view.dart' as _profileView;

class VerifyCar extends StatefulWidget {
  @override
  State createState() => VerifyCarState();
}

class VerifyCarState extends State<VerifyCar> {
  int _tab = 1;
  // bool _loggedIn;
  final storage = new FlutterSecureStorage();

  //variables for floating action button
  final discoverBloc = DiscoverBloc();
  bool _mapClick = false;

  @override
  void initState() {
    super.initState();

    // _loggedIn = false;
    // callFetchLoginState();
  }

  // callFetchLoginState() async {
  //   String profileID = await storage.read(key: 'profile_id');
  //
  //   if (profileID != null) {
  //     setState(() {
  //       _loggedIn = true;
  //     });
  //   } else {
  //     setState(() {
  //       _loggedIn = false;
  //     });
  //   }
  // }

  var _loggedInPages = [
    new _discoverTab.Discover(),
    new _verifyYourCarView.VerifyCarView(),
    new _profileView.ProfileView()
  ];

  var _loggedOutPages = [
    new _discoverTab.Discover(),
    new _verifyYourCarView.VerifyCarView(),
    new _createProfileOrSignInViewTab.CreateProfileOrSignInView()

  ];

  @override
  Widget build (BuildContext context) => new Scaffold(
    backgroundColor: Color(0xffFFFFFF),

    body: ProfileStatus.isLoggedIn ? _loggedInPages[_tab] : _loggedOutPages[_tab],

    //map button
    floatingActionButton: _tab == 0 ? MapButton(
      onPressed: () async {
        // TODO map click issue
        if (!_mapClick) {
          _mapClick = true;
          var _newCarData =
          await discoverBloc.callFetchNewCars();
          Navigator.pushNamed(context, '/discover_car_map',
              arguments: _newCarData).then((value) => _mapClick = false);
        }
      },
    ) : Container(),
    floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    //Tabs
    bottomNavigationBar: NavigationBarTheme(
      data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontFamily: 'Urbanist'),
          )
      ),
      child: NavigationBar(
        indicatorColor: Color(0xffFFd2bd),
         selectedIndex: _tab,
         onDestinationSelected: onTap,
        destinations: [
          NavigationDestination(
            icon: _tab == 0
                ? Icon(Icons.directions_car, color: Color(0xffFF8F68))
                : Icon(Icons.directions_car, color: Colors.black),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: _tab == 1
                ? Icon(Icons.app_registration, color: Color(0xffFF8F68))
                : Icon(Icons.app_registration, color: Colors.black),
            label: 'List your\nvehicle',
          ),
          NavigationDestination(
            icon: _tab == 2
                ? ProfileStatus.isProfileComplete
                ? Icon(Icons.account_circle_rounded, color: Color(0xffFF8F68))
                : ProfileIncompleteIndicator('icons/Profile-Active.png')
                : ProfileStatus.isProfileComplete
                ? Icon(Icons.account_circle_rounded, color: Colors.black)
                : ProfileIncompleteIndicator('icons/Profile.png'),
            label: ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
          ),
        ],
      ),
    ),

  );

  void onTap(int tab) {
    setState(() {
      _tab = tab;
    });
  }
}