import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/pages/list_a_car/ui/what_will_happen_next_ui.dart'
    as _editListingPage;
import 'package:ridealike/pages/messages/pages/threadlist/threadlistView.dart'
    as _threadListView;
import 'package:ridealike/pages/profile/profile_view.dart' as _profileView;
import 'package:ridealike/pages/trips/ui/trips_view_ui.dart' as _tripsViewUi;
import 'package:ridealike/tabs/discover.dart' as _discoverTab;
//profile Status utils
import 'package:ridealike/utils/profile_status.dart';
import 'package:ridealike/widgets/map_button.dart';
//profile incomplete indicator
import 'package:ridealike/widgets/profile_incomplete_indicator.dart';

import '../../../main.dart';

class DashboardEditYorListingTab extends StatefulWidget {
  @override
  _DashboardEditYorListingTabState createState() =>
      _DashboardEditYorListingTabState();
}

class _DashboardEditYorListingTabState
    extends State<DashboardEditYorListingTab> {
  int _tab = 1;
  // bool _loggedIn;
  // bool _hasCar;
 bool? dataFetchComplete;
  final storage = new FlutterSecureStorage();

  //variables for floating action button
  final discoverBloc = DiscoverBloc();
  bool _mapClick = false;

  @override
  void initState() {
    super.initState();
    // _loggedIn = false;
    // _hasCar = false;
    // dataFetchComplete = false;
    // callFetchLoginState();
  }

  // callFetchLoginState() async {
  //   String userID = await storage.read(key: 'user_id');
  //   String jwt = await storage.read(key: 'jwt');
  //
  //   if (userID != null) {
  //     var _cars = await fetchUserCars(userID, jwt);
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
  //       dataFetchComplete = true;
  //     });
  //   } else {
  //     setState(() {
  //       _loggedIn = false;
  //       dataFetchComplete = true;
  //     });
  //   }
  // }

//  var pages = [
//    new _discoverTab.Discover(),
////    new _dashboardEditListing.EditYourListing(),
//    new _editListingPage.WhatHappensNextUi(),
//    new _tripsViewUi.TripsViewUi(),
//    new _profileView.ProfileView()
//  ];
  var _loggedInPages = [
    new _discoverTab.Discover(),
    new _editListingPage.WhatHappensNextUi(),
    new _tripsViewUi.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView(),
  ];

  var _loggedInHadCarPages = [
    new _discoverTab.Discover(),
    new _editListingPage.WhatHappensNextUi(),
    new _tripsViewUi.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Color(0xffFFFFFF),

        body: (ProfileStatus.isLoggedIn && ProfileStatus.hasCar)
            ? _loggedInHadCarPages[_tab]
            : (ProfileStatus.isLoggedIn && !ProfileStatus.hasCar)
                ? _loggedInPages[_tab]
                : _loggedInPages[_tab],

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
                var _newCarData =
                await discoverBloc.callFetchNewCars();
                Navigator.pushNamed(context, '/discover_car_map',
                    arguments: _newCarData).then((value) => _mapClick = false);
              }
            },
          ) : Container();
        },
      ) : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      //Tabs
      //   bottomNavigationBar: NavigationBarTheme(
      //
      //     data: NavigationBarThemeData(
      //         labelTextStyle: MaterialStateProperty.all(
      //           TextStyle(fontFamily: 'Urbanist'),
      //         )
      //     ),
      //     child: NavigationBar( indicatorColor: Color(0xffFFd2bd),
      //             backgroundColor: Colors.white,
      //             selectedIndex: _tab,
      //       onDestinationSelected: onTap,
      //       destinations: [
      //               NavigationDestination(
      //                 icon: _tab == 0
      //                     ? Icon(Icons.directions_car,color:Color(0xffFF8F68),)
      //                     : Image.asset('icons/Discover.png'),
      //                 label:
      //                   'Discover',
      //                   // style: TextStyle(
      //                   //   fontFamily: 'Urbanist',
      //                   //   fontSize: 10,
      //                   // ),
      //
      //               ),
      //               NavigationDestination(
      //                   icon: _tab == 1
      //                       ? Image.asset('icons/Dashboard_Active.png')
      //                       : Image.asset('icons/Dashboard.png'),
      //                   label:
      //                     'Dashboard',
      //                     // style: TextStyle(
      //                     //   fontFamily: 'Urbanist',
      //                     //   fontSize: 10,
      //                     // ),
      //                   ),
      //               NavigationDestination(
      //                   icon: _tab == 2
      //                       ? Image.asset('icons/Trips-Active.png')
      //                       : Icon(Icons.compare_arrows,color:Colors.grey,),
      //                   label:
      //                     'Trips',
      //                     // style: TextStyle(
      //                     //   fontFamily: 'Urbanist',
      //                     //   fontSize: 10,
      //                     // ),
      //                   ),
      //               /*NavigationDestination(
      //                   icon: _tab == 3
      //                       ? Icon(Icons.message,color:Color(0xffFF8F68),)
      //                       : Icon(Icons.message,color:Colors.grey,),
      //                   title: Text(
      //                     'Chats',
      //                     style: TextStyle(
      //                       fontFamily: 'Urbanist',
      //                       fontSize: 10,
      //                     ),
      //                   )),*/
      //               NavigationDestination(
      //                 icon: ValueListenableBuilder(
      //                   builder:
      //                       (BuildContext context, bool value, Widget? child) {
      //                     return value
      //                         ? Stack(
      //                       children: [
      //                         Icon(Icons.message,color:Colors.grey,),
      //                         Positioned(
      //                           left: 10,
      //                           child: Container(
      //                             height: 12.5,
      //                             width: 12.5,
      //                             decoration: BoxDecoration(
      //                               color: Color(0xffFF8F68),
      //                               border: Border.all(
      //                                 color: Color(0xffFF8F68),
      //                               ),
      //                               borderRadius: BorderRadius.all(
      //                                 Radius.circular(20),
      //                               ),
      //                             ),
      //                           ),
      //                         ),
      //                       ],
      //                     )
      //                         : Icon(Icons.message,color:Colors.grey,);
      //                   },
      //                   valueListenable: newMessage,
      //                 ),
      //                 selectedIcon: Icon(Icons.message,color:Color(0xffFF8F68),),
      //                 label:
      //                   'Chats',
      //                   // style: TextStyle(
      //                   //   fontFamily: 'Urbanist',
      //                   //   fontSize: 10,
      //                   // ),
      //
      //               ),
      //               NavigationDestination(
      //                   icon: _tab == 4
      //                       ? ProfileStatus.isProfileComplete ?
      //                         Icon(Icons.account_circle_rounded,color:Color(0xffFF8F68),) :
      //                         ProfileIncompleteIndicator('icons/Profile-Active.png')
      //                       : ProfileStatus.isProfileComplete ?
      //                         Icon(Icons.account_circle_rounded,color:Colors.grey,) :
      //                         ProfileIncompleteIndicator('icons/Profile.png'),
      //                   label:
      //                     'Profile',
      //
      //                   ),
      //             ],
      //           ),
      //   ),
      );
  }

  void onTap(int tab) {
    setState(() {
      _tab = tab;
    });
  }
}

Future<http.Response> fetchUserCars(param, jwt) async {
  final response = await http.post(
    Uri.parse(getCarsByUserIDUrl),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({"UserID": param}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}
