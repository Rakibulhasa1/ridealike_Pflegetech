import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/dashboard/dashboard.dart' as _dashboard;
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/pages/messages/pages/threadlist/threadlistView.dart'
    as _threadListView;
import 'package:ridealike/pages/profile/profile_view.dart' as _profileView;
import 'package:ridealike/pages/search_a_car/search.dart' as _searchCarTab;
import 'package:ridealike/pages/trips/trips.dart' as _tripsPage;
//profile Status utils
import 'package:ridealike/utils/profile_status.dart';
//profile incomplete indicator
import 'package:ridealike/widgets/profile_incomplete_indicator.dart';

import '../../tabs/create_profile_or_sign_in_view.dart'
    as _createProfileOrSignInViewTab;
import '../../tabs/list_your_car.dart' as _listYourCarTab;

class MessagesChatRoomTab extends StatefulWidget {
  @override
  _MessagesChatRoomTabState createState() => _MessagesChatRoomTabState();
}

class _MessagesChatRoomTabState extends State<MessagesChatRoomTab> {
  int _tab = 3;
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
    new _searchCarTab.Search(),
    new _dashboard.Dashboard(),
    new _tripsPage.TripsTab(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView()
  ];

  var _loggedOutPages = [
    new _searchCarTab.Search(),
    new _listYourCarTab.ListYourCar(),
    new _tripsPage.TripsTab(),
    new _threadListView.ThreadListView(),
    new _createProfileOrSignInViewTab.CreateProfileOrSignInView()
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Color(0xffFFFFFF),

        body: ProfileStatus.isLoggedIn ? _loggedInPages[_tab] : _loggedOutPages[_tab],


    //Tabs
        bottomNavigationBar: NavigationBarTheme(

          data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.all(
                TextStyle(fontFamily: 'Urbanist'),
              )
          ),
          child: NavigationBar( indicatorColor: Color(0xffFFd2bd),
                  backgroundColor: Colors.white,
                  selectedIndex: _tab,
            onDestinationSelected: onTap,
            destinations: [
                    NavigationDestination(
                      icon: _tab == 0
                          ? Icon(Icons.directions_car,color:Color(0xffFF8F68),)
                          : Image.asset('icons/Discover.png'),
                      label:
                        'Discover',

                    ),
                    NavigationDestination(
                      icon: _tab == 1
                          ? Image.asset('icons/List-a-Car_Active.png')
                          : Icon(Icons.app_registration,color:Colors.grey,),
                      label:
                        'List your\nvehicle',

                    ),
                    NavigationDestination(
                        icon: _tab == 2
                            ? Image.asset('icons/Trips-Active.png')
                            : Icon(Icons.compare_arrows,color:Colors.grey,),
                        label:
                          'Trips',
                         ),
                    NavigationDestination(
                        icon: _tab == 3
                            ? Icon(Icons.message,color:Color(0xffFF8F68),)
                            : Icon(Icons.message,color:Colors.grey,),
                        label:
                          'Chats',
                         ),
                    NavigationDestination(
                        icon: _tab == 4
                            ? ProfileStatus.isProfileComplete ?
                                Icon(Icons.account_circle_rounded,color:Color(0xffFF8F68),) :
                                ProfileIncompleteIndicator('icons/Profile-Active.png')
                            : ProfileStatus.isProfileComplete ?
                                Icon(Icons.account_circle_rounded,color:Colors.grey,) :
                                ProfileIncompleteIndicator('icons/Profile.png'),
                        label:
                          ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
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
