import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/dashboard/dashboard.dart' as _dashboard;
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/pages/messages/pages/threadlist/threadlistView.dart'
    as _threadListView;
import 'package:ridealike/pages/profile/profile_view.dart' as _profileView;
import 'package:ridealike/pages/search_a_car/search_car_sort_by.dart'
    as _searchCarSortTab;
//import 'package:ridealike/pages/trips/trips_view.dart' as _tripsPage;
import 'package:ridealike/pages/trips/ui/trips_view_ui.dart' as _tripsViewUi;
//profile Status utils
import 'package:ridealike/utils/profile_status.dart';
//profile incomplete indicator
import 'package:ridealike/widgets/profile_incomplete_indicator.dart';

import '../../main.dart';
import '../../tabs/create_profile_or_sign_in_view.dart'
    as _createProfileOrSignInViewTab;
import '../../tabs/list_your_car.dart' as _listYourCarTab;

Future<http.Response> fetchUserCars(param, jwt) async {
  final response = await http.post(
    Uri.parse(getCarsByUserIDUrl),
    // getCarsByUserIDUrl as Uri,
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({"UserID": param}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

class SearchCarSortByTab extends StatefulWidget {
  SearchCarSortByTabState? object;

  @override
  SearchCarSortByTabState createState() {
    object = SearchCarSortByTabState();
    return object!;
  }
}

class SearchCarSortByTabState extends State<SearchCarSortByTab> {

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

    // _loggedIn = false;
    // _hasCar = false;
    // callFetchLoginState();
  }


  // callFetchLoginState() async {
  //   String token = await storage.read(key: 'user_id');
  //   String jwt = await storage.read(key: 'jwt');
  //
  //   if (token != null) {
  //     if (jwt != null) {
  //       var _cars = await fetchUserCars(token, jwt);
  //
  //       if (json.decode(_cars.body!)['Cars'].length > 0) {
  //         setState(() {
  //           _hasCar = true;
  //         });
  //       } else {
  //         setState(() {
  //           _hasCar = false;
  //         });
  //       }
  //
  //       setState(() {
  //         _loggedIn = true;
  //       });
  //     } else {
  //       setState(() {
  //         _loggedIn = false;
  //       });
  //     }
  //   } else {
  //     setState(() {
  //       _loggedIn = false;
  //     });
  //   }
  // }

  var _loggedInPages = [
    new _searchCarSortTab.SearchCarSortBy(),
    new _listYourCarTab.ListYourCar(),
    new _tripsViewUi.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView(),
  ];

  var _loggedInHadCarPages = [
    new _searchCarSortTab.SearchCarSortBy(),
    new _dashboard.Dashboard(),
    new _tripsViewUi.TripsViewUi(),
    new _threadListView.ThreadListView(),
//    new _tripsPage.TripsView(),
    new _profileView.ProfileView(),
  ];

  var _loggedOutPages = [
    new _searchCarSortTab.SearchCarSortBy(),
    new _listYourCarTab.ListYourCar(),
    new _createProfileOrSignInViewTab.CreateProfileOrSignInView(),
  ];

  @override
  Widget build(BuildContext context) {
    (_loggedOutPages[0] as _searchCarSortTab.SearchCarSortBy).object = widget.object;
    (_loggedInHadCarPages[0] as _searchCarSortTab.SearchCarSortBy).object = widget.object;
    (_loggedInPages[0] as _searchCarSortTab.SearchCarSortBy).object = widget.object;
    return Scaffold(
        backgroundColor: Color(0xffFFFFFF),

        body: (ProfileStatus.isLoggedIn && !ProfileStatus.hasCar)
            ? _loggedInPages[_tab]
            : (ProfileStatus.isLoggedIn && ProfileStatus.hasCar)
            ? _loggedInHadCarPages[_tab]
            : _loggedOutPages[_tab],
        // body: _loggedOutPages[_tab],

        //Tabs
        // bottomNavigationBar: NavigationBarTheme(
        //
        //   data: NavigationBarThemeData(
        //       labelTextStyle: MaterialStateProperty.all(
        //         TextStyle(fontFamily: 'Urbanist'),
        //       )
        //   ),
        //   child: NavigationBar(
        //     indicatorColor: Color(0xffFFd2bd),
        //     backgroundColor: Colors.white,
        //     // selectedItemColor: Color(0xffFF8F68),
        //     // selectedItemColor: Color.fromRGBO(55, 29, 50, 1),
        //     selectedIndex: _tab,
        //     onDestinationSelected: onTap,
        //     destinations: (ProfileStatus.isLoggedIn && ProfileStatus.hasCar)
        //         ? [
        //       NavigationDestination(
        //            icon: Icon(Icons.directions_car,color: Colors.grey,),
        //         selectedIcon: Icon(Icons.directions_car,color: Colors.black,),
        //         label:
        //           'Discover',
        //
        //
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.av_timer,color: Colors.grey,),
        //         selectedIcon: Icon(Icons.av_timer,color:Colors.black,),
        //         label:
        //           'Dashboard',
        //
        //
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.compare_arrows,color:Colors.grey,),
        //         selectedIcon: Icon(Icons.compare_arrows,color:Colors.black,),
        //         label:
        //           'Trips',
        //
        //
        //       ),
        //       /*NavigationDestination(
        //         icon: Icon(Icons.message,color:Colors.grey,),
        //         selectedIcon: Icon(Icons.message,color:Color(0xffFF8F68),),
        //         label: Text(
        //           'Chats',
        //
        //         ),
        //       ),*/
        //       NavigationDestination(
        //         icon: ValueListenableBuilder(
        //           builder:
        //               (BuildContext context, bool value, Widget? child) {
        //             return value
        //                 ? Stack(
        //               children: [
        //                 Icon(Icons.message,color:Colors.grey,),
        //                 Positioned(
        //                   left: 10,
        //                   child: Container(
        //                     height: 12.5,
        //                     width: 12.5,
        //                     decoration: BoxDecoration(
        //                       color: Color(0xffFF8F68),
        //                       border: Border.all(
        //                         color: Color(0xffFF8F68),
        //                       ),
        //                       borderRadius: BorderRadius.all(
        //                         Radius.circular(20),
        //                       ),
        //                     ),
        //                   ),
        //                 ),
        //               ],
        //             )
        //                 : Icon(Icons.message,color:Colors.grey,);
        //           },
        //           valueListenable: newMessage,
        //         ),
        //         selectedIcon: Icon(Icons.message,color:Colors.black,),
        //         label:
        //           'Chats',
        //
        //
        //       ),
        //       NavigationDestination(
        //         icon: ProfileStatus.isProfileComplete ?
        //         Icon(Icons.account_circle_rounded,color:Colors.grey,) : ProfileIncompleteIndicator('icons/Profile.png'),
        //         selectedIcon: ProfileStatus.isProfileComplete ?
        //         Icon(Icons.account_circle_rounded,color:Colors.black,) : ProfileIncompleteIndicator('icons/Profile-Active.png'),
        //         label:
        //           ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
        //
        //
        //       ),
        //     ]
        //         : (ProfileStatus.isLoggedIn && !ProfileStatus.hasCar)
        //         ? [
        //       NavigationDestination(
        //            icon: Icon(Icons.directions_car,color: Colors.grey,),
        //         selectedIcon:
        //         Icon(Icons.directions_car,color:Color(0xffFF8F68),),
        //         label:
        //           'Discover',
        //
        //
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.app_registration,color:Colors.grey,),
        //         selectedIcon:
        //         Icon(Icons.app_registration,color:Color(0xffFF8F68),),
        //         label:
        //           'List your\nvehicle',
        //           // maxLines: 2,
        //           // textAlign: TextAlign.center,
        //
        //
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.compare_arrows,color:Colors.grey,),
        //         selectedIcon: Icon(Icons.compare_arrows,color:Colors.black,),
        //         label:
        //           'Trips',
        //
        //
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.message,color:Colors.grey,),
        //         selectedIcon:
        //         Icon(Icons.message,color:Color(0xffFF8F68),),
        //         label:
        //           'Chats',
        //
        //
        //       ),
        //       NavigationDestination(
        //         icon: ProfileStatus.isProfileComplete ?
        //         Icon(Icons.account_circle_rounded,color:Colors.grey,) : ProfileIncompleteIndicator('icons/Profile.png'),
        //         selectedIcon: ProfileStatus.isProfileComplete ?
        //         Icon(Icons.account_circle_rounded,color:Color(0xffFF8F68),) : ProfileIncompleteIndicator('icons/Profile-Active.png'),
        //         label:
        //           ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
        //
        //
        //       ),
        //     ]
        //         : [
        //       NavigationDestination(
        //            icon: Icon(Icons.directions_car,color: Colors.grey,),
        //         selectedIcon:
        //         Icon(Icons.directions_car,color:Color(0xffFF8F68),),
        //         label:
        //           'Discover',
        //
        //
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.app_registration,color:Colors.grey,),
        //         selectedIcon:
        //         Icon(Icons.app_registration,color:Color(0xffFF8F68),),
        //         label:
        //           'List your\nvehicle',
        //
        //
        //
        //       ),
        //       NavigationDestination(
        //         icon: Icon(Icons.account_circle_rounded,color:Colors.grey,),
        //         selectedIcon:
        //         Icon(Icons.account_circle_rounded,color:Color(0xffFF8F68),),
        //         label:
        //           ProfileStatus.isLoggedIn ? 'Profile' : 'Sign In',
        //
        //
        //       ),
        //     ],
        //   ),
        // ),
      );
}

  void onTap(int tab) {
    setState(() {
      _tab = tab;
    });
  }
}