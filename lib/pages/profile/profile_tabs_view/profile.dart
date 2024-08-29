import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/dashboard/dashboard.dart' as _dashboardTab;
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/pages/messages/pages/threadlist/threadlistView.dart' as _threadListView;
import 'package:ridealike/pages/profile/profile_view.dart'as _profileView ;
//import 'package:ridealike/pages/trips/trips_view.dart' as _tripsTab;
import 'package:ridealike/pages/trips/ui/trips_view_ui.dart' as _tripsViewUi;
import 'package:ridealike/tabs/discover.dart' as _discoverTab;
import 'package:ridealike/tabs/list_your_car.dart' as _listYourCarTab;
//profile Status utils
import 'package:ridealike/utils/profile_status.dart';
import 'package:ridealike/widgets/map_button.dart';
//profile incomplete indicator
import 'package:ridealike/widgets/profile_incomplete_indicator.dart';

import '../../../main.dart';


Future<Resp> fetchUserCars(param) async  {

  var completer = Completer<Resp>();

  callAPI(
    getCarsByUserIDUrl,
    json.encode(
        {
          "UserID": param
        }
    ),

  ).then((resp) {
    completer.complete(resp);
  }
  );

  return completer.future;
}

class Profile extends StatefulWidget {
  @override
  State createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  int _tab = 4;
  // bool _hasCar;
  final storage = new FlutterSecureStorage();

  //variables for floating action button
  final discoverBloc = DiscoverBloc();
  bool _mapClick = false;

  @override
  void initState() {
    super.initState();

    ProfileStatus.init().whenComplete(() => setState(() {}));
    // _hasCar = false;
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
  //         _tab = 4;
  //       });
  //     } else {
  //       setState(() {
  //         _hasCar = false;
  //         _tab = 4;
  //       });
  //     }
  //   }
  // }

  var _notHasCarPages = [
    new _discoverTab.Discover(),
    new _listYourCarTab.ListYourCar(),
    new _tripsViewUi.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView()
  ];

  var _hasCarPages = [
    new _discoverTab.Discover(),
    new _dashboardTab.Dashboard(),
    new _tripsViewUi.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView(),
  ];

  @override
  Widget build (BuildContext context) => new Scaffold(
    extendBody: true,
    backgroundColor: Color(0xffFFFFFF),

    body: ProfileStatus.hasCar ? _hasCarPages[_tab] : _notHasCarPages[_tab],

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
    bottomNavigationBar: NavigationBarTheme(

      data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontFamily: 'Urbanist'),
          )
      ),
      child: NavigationBar(
        indicatorColor: Color(0xffFFd2bd),
        backgroundColor: Colors.white,
        // selectedItemColor: Color(0xffFF8F68),
        // selectedItemColor: Color.fromRGBO(55, 29, 50, 1),
        selectedIndex: _tab,
        onDestinationSelected: onTap,
        destinations: ProfileStatus.hasCar ? [
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
              label: 'Discover',
              //   style: TextStyle(
              //     fontFamily: 'Urbanist',
              //     fontSize: 10,
              //   ),
              // ),
            ),
            NavigationDestination(
              icon: Icon(Icons.av_timer,color: Colors.grey,),
              selectedIcon: Icon(Icons.av_timer,color:Colors.black,),
              label: 'Dashboard',
              //   style: TextStyle(
              //     fontFamily: 'Urbanist',
              //     fontSize: 10,
              //   ),
              // ),
            ),
            NavigationDestination(
              icon: Icon(Icons.compare_arrows,color:Colors.grey,),
              selectedIcon: Icon(Icons.compare_arrows,color:Colors.black,),
              label: 'Trips',
              //   style: TextStyle(
              //     fontFamily: 'Urbanist',
              //     fontSize: 10,
              //   ),
              // ),
            ),
          /*NavigationDestination(
            icon: Icon(Icons.message,color:Colors.grey,),
            selectedIcon: Icon(Icons.message,color:Color(0xffFF8F68),),
            label: Text('Chats',
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
                    Icon(Icons.message,color:Colors.grey,),
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
                    : Icon(Icons.message,color:Colors.grey,);
              },
              valueListenable: newMessage,
            ),
            selectedIcon: Icon(Icons.message,color:Colors.black),
            label:
              'Inbox',
            //   style: TextStyle(
            //     fontFamily: 'Urbanist',
            //     fontSize: 10,
            //   ),
            // ),
          ),
            NavigationDestination(
              icon: ProfileStatus.isProfileComplete ?
              Icon(Icons.account_circle_rounded,color:Colors.grey,size: 20) : Icon(Icons.account_circle_rounded,color:Colors.grey,size: 20) ,
              selectedIcon: ProfileStatus.isProfileComplete ?
              Icon(Icons.account_circle_rounded,color:Colors.black,size: 20) : Icon(Icons.account_circle_rounded,color:Colors.black,size: 20),
              label: 'Profile',
              //   style: TextStyle(
              //     fontFamily: 'Urbanist',
              //     fontSize: 10,
              //   ),
              // ),
            ),
          ] : [
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
              label: 'Discover',
              //   style: TextStyle(
              //     fontFamily: 'Urbanist',
              //     fontSize: 10,
              //   ),
              // ),
            ),
            NavigationDestination(
              icon: Icon(Icons.app_registration,color:Colors.grey,size: 20),
              selectedIcon: Icon(Icons.app_registration,color:Colors.black,size: 20),
              label: 'List your car',
              //   maxLines: 2,
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //     fontFamily: 'Urbanist',
              //     fontSize: 10,
              //   ),
              // ),
            ),
            NavigationDestination(
            icon: Icon(Icons.compare_arrows,color:Colors.grey,size: 20),
            selectedIcon: Icon(Icons.compare_arrows,color:Colors.black,size: 20),
            label: 'Trips',
            //   style: TextStyle(
            //     fontFamily: 'Urbanist',
            //     fontSize: 10,
            //   ),
            // ),
          ),
            NavigationDestination(
            icon: Icon(Icons.message,color:Colors.grey,size: 20),
            selectedIcon: Icon(Icons.message,color:Colors.black,size: 20),
            label: 'Inbox',
            //   style: TextStyle(
            //     fontFamily: 'Urbanist',
            //     fontSize: 10,
            //   ),
            // ),
          ),
            NavigationDestination(
              icon: ProfileStatus.isProfileComplete ?
              Icon(Icons.account_circle_rounded,color:Colors.grey,size: 20) : Icon(Icons.account_circle_rounded,color:Colors.grey,size: 20),
              selectedIcon: ProfileStatus.isProfileComplete ?
              Icon(Icons.account_circle_rounded,color:Colors.black,size: 20) : Icon(Icons.account_circle_rounded,color:Colors.black,size: 20),
              label: 'Profile',
              //   style: TextStyle(
              //     fontFamily: 'Urbanist',
              //     fontSize: 10,
              //   ),
              // ),
            ),
          ],
      ),
    ),
  );

  void onTap(int tab) {
    if(tab == 4)
      ProfileStatus.init().whenComplete(() => setState(() {}));

    setState(() {
      _tab = tab;
    });
  }
}
