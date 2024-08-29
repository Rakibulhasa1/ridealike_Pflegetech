import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/pages/dashboard/dashboard.dart' as _dashboardTab;
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/pages/messages/pages/threadlist/threadlistView.dart'
as _threadListView;
import 'package:ridealike/pages/profile/profile_view.dart' as _profileView;
//import 'package:ridealike/pages/trips/trips_view.dart' as _tripsTab;
import 'package:ridealike/pages/trips/ui/trips_view_ui.dart' as _tripsViewUi;
import 'package:ridealike/utils/app_events/app_events_utils.dart';
//profile Status utils
import 'package:ridealike/utils/profile_status.dart';
import 'package:ridealike/widgets/map_button.dart';
//profile incomplete indicator
import 'package:ridealike/widgets/profile_incomplete_indicator.dart';

import '../../../main.dart';
import '../../../tabs/create_profile_or_sign_in_view.dart'
as _createProfileOrSignInViewTab;
import '../../../tabs/discover.dart' as _discoverTab;
import '../../../tabs/list_your_car.dart' as _listYourCarTab;



class DiscoverTab extends StatefulWidget {
  @override
  _DiscoverTabState createState() => _DiscoverTabState();
}

class _DiscoverTabState extends State<DiscoverTab> {
  int _tab = 0;
  // bool _loggedIn;
  // bool _hasCar;
  final storage = new FlutterSecureStorage();


  //variables for floating action button
  final discoverBloc = DiscoverBloc();
  bool _mapClick = false;

  @override
  void initState() {
    super.initState();
    //AppEventsUtils.logEvent("discover_view");
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Discover"});
    // _loggedIn = false;
    // _hasCar = false;
    MapButtonBloc.mapButtonSink.add(true);
    // callFetchLoginState();
  }

  // callFetchLoginState() async {
  //   String userID = await storage.read(key: 'user_id');
  //
  //   if (userID != null) {
  //     var _cars = await fetchUserCars(userID);
  //     if (json.decode(_cars.body!)['Cars'].length > 0) {
  //       setState(() {
  //         _hasCar = true;
  //       });
  //     } else {
  //       setState(() {
  //         _hasCar = false;
  //       });
  //     }
  //
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
    new _listYourCarTab.ListYourCar(),
    new _tripsViewUi.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView(),
  ];

  var _loggedInHadCarPages = [
    new _discoverTab.Discover(),
    new _dashboardTab.Dashboard(),
    new _tripsViewUi.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView(),
  ];

  var _loggedOutPages = [
    new _discoverTab.Discover(),
    new _listYourCarTab.ListYourCar(),
    new _createProfileOrSignInViewTab.CreateProfileOrSignInView(),
  ];

  @override
  Widget build(BuildContext context) {
    return ScaffoldMessenger(
      child: new Scaffold(
        backgroundColor: Color(0xffFFFFFF),
      
        body: (ProfileStatus.isLoggedIn && !ProfileStatus.hasCar)
            ? _loggedInPages[_tab]
            : (ProfileStatus.isLoggedIn && ProfileStatus.hasCar)
            ? _loggedInHadCarPages[_tab]
            : _loggedOutPages[_tab],
        // body: _loggedOutPages[_tab],
      
        //map button
        floatingActionButton: _tab == 0 ?
        StreamBuilder<bool>(
          stream: MapButtonBloc.mapButtonStream,
          builder: (context, snapshot){
            return snapshot.hasData && snapshot.data! ?
            MapButton(
              onPressed: () async {
                // TODO map click issue
                if (!_mapClick) {
                  _mapClick = true;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );
                  var _newCarData =
                  await discoverBloc.callFetchNewCars();
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/discover_car_map',
                      arguments: _newCarData).then((value) => _mapClick = false);
                }
              },
            ) : Container();
          },
        ) : Container(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
        //Tabs
        bottomNavigationBar: NavigationBarTheme(

          data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.all(
                TextStyle(fontFamily: 'Urbanist',fontSize: 11),
              )
          ),
          child: NavigationBar( indicatorColor: Color(0xffFFd2bd),
            backgroundColor: Colors.white,
            selectedIndex: _tab,
            onDestinationSelected: onTap,
            destinations: (ProfileStatus.isLoggedIn && ProfileStatus.hasCar)
                ? [
              NavigationDestination(
                icon: SvgPicture.asset(
                  'svg/discoverIcon.svg',
                  color: Colors.grey,
                  height: 28,
                ),
                selectedIcon: SvgPicture.asset(
                  'svg/discoverIcon.svg',
                  color: Colors.black,
                  height: 28,
                ),
                label:
                  'Discover',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              NavigationDestination(
                icon: Icon(Icons.av_timer,color: Colors.grey,size: 28),
                selectedIcon: Icon(Icons.av_timer,color:Colors.black,size: 28),
                label:
                  'Dashboard',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              NavigationDestination(
                icon: Icon(Icons.compare_arrows,color:Colors.grey,size: 28),
                selectedIcon: Icon(Icons.compare_arrows,color:Colors.black,size: 28),
                label:
                  'Trips',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              /*NavigationDestination(
                              icon: Icon(Icons.message,color:Colors.grey,),
                              selectedIcon: Icon(Icons.message,color:Color(0xffFF8F68),),
                              label: Text(
                                'Chats',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 10,
                                ),
                              ),
                            ),*/
              NavigationDestination(
                icon: ValueListenableBuilder(
                  builder:
                      (BuildContext context, bool value, Widget? child) {
                    return value
                        ? Stack(
                      children: [
                        Icon(Icons.message,color:Colors.grey,size: 28),
                        Positioned(
                          left: 10,
                          child: Container(
                            height: 12.5,
                            width: 12.5,
                            decoration: BoxDecoration(
                              color: Color(0xffFF8F68),
                              border: Border.all(
                                color: Color(0xffFF8F68),
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                        : Icon(Icons.message,color:Colors.grey,size: 28);
                  },
                  valueListenable: newMessage,
                ),
                selectedIcon: Icon(Icons.message,color:Colors.black,size: 28),
                label:
                  'Chats',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              NavigationDestination(
                icon: ProfileStatus.isProfileComplete ? Icon(Icons.account_circle_rounded,color:Colors.grey,size: 28) : ProfileIncompleteIndicator('icons/Profile.png'),
                selectedIcon: ProfileStatus.isProfileComplete ? Icon(Icons.account_circle_rounded,color:Colors.black,size: 28) : ProfileIncompleteIndicator('icons/Profile-Active.png'),
                label:
                  ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
            ]
                : (ProfileStatus.isLoggedIn && !ProfileStatus.hasCar)
                ? [
              NavigationDestination(
                icon: SvgPicture.asset(
                  'svg/discoverIcon.svg',
                  color: Colors.grey,
                  height: 28,
                ),
                selectedIcon: SvgPicture.asset(
                  'svg/discoverIcon.svg',
                  color: Colors.black,
                  height: 28,
                ),
                label:
                  'Discover',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              NavigationDestination(
                icon: Icon(Icons.app_registration,color:Colors.grey,size: 28),
                selectedIcon:
                Icon(Icons.app_registration,color:Colors.black,size: 28),
                label:
                  'List your car',
                  // maxLines: 2,
                  // textAlign: TextAlign.center,
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              NavigationDestination(
                icon: Icon(Icons.compare_arrows,color:Colors.grey,size: 28),
                selectedIcon: Icon(Icons.compare_arrows,color:Colors.black,size: 28),
                label:
                  'Trips',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              NavigationDestination(
                icon: Icon(Icons.message,color:Colors.grey,size: 28),
                selectedIcon:
                Icon(Icons.message,color:Colors.black,size: 28),
                label:
                  'Chats',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              NavigationDestination(
                icon: ProfileStatus.isProfileComplete ? Icon(Icons.account_circle_rounded,color:Colors.grey,size: 28) : ProfileIncompleteIndicator('icons/Profile.png'),
                selectedIcon: ProfileStatus.isProfileComplete ?  Icon(Icons.account_circle_rounded,size: 28,color:Colors.black,) : ProfileIncompleteIndicator('icons/Profile-Active.png'),
                label:
                  ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
            ]
                : [
              NavigationDestination(
                icon: SvgPicture.asset(
                  'svg/discoverIcon.svg',
                  color: Colors.grey,
                  height: 28,
                ),
                selectedIcon: SvgPicture.asset(
                  'svg/discoverIcon.svg',
                  color: Colors.black,
                  height: 28,
                ),
                label:
                  'Discover',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              NavigationDestination(
                icon: Icon(Icons.app_registration,color:Colors.grey,size: 28),
                selectedIcon:
                Icon(Icons.app_registration,color:Colors.black,size: 28),
                label:
                  'List your car',
                  // maxLines: 2,
                  // textAlign: TextAlign.center,
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
              NavigationDestination(
                icon: Icon(Icons.account_circle_rounded,color:Colors.grey,size: 28),
                selectedIcon:
                Icon(Icons.account_circle_rounded,color:Colors.black,size: 28),
                label:
                  ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
                  //style: TextStyle(
          //              fontFamily: 'Urbanist',
           //             fontSize: 10,
           //           ),

              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTap(int tab) {
    if(tab == 4)
      ProfileStatus.init().whenComplete(() => setState(() {}));

    setState(() {
      _tab = tab;
    });
  }
}