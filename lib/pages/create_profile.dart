import 'package:flutter/material.dart';
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/pages/create_a_profile/ui/create_profile_ui.dart' as _createProfileUi;
import 'package:ridealike/widgets/map_button.dart';

import '../tabs/discover.dart' as _discoverTab;
import '../tabs/list_your_car.dart' as _listYourCarTab;
import 'discover/bloc/discover_bloc.dart';

class CreateProfile extends StatefulWidget {
  @override
  State createState() => CreateProfileState();
}

class CreateProfileState extends State<CreateProfile> {
  int _tab = 2;

  //variables for floating action button
  final discoverBloc = DiscoverBloc();
  bool _mapClick = false;

  var pages = [
    new _discoverTab.Discover(),
    new _listYourCarTab.ListYourCar(),
//    new _createProfileViewPage.CreateProfileView()
    new _createProfileUi.CreateProfileUI()

  ];

  @override
  Widget build (BuildContext context) => new Scaffold(
    backgroundColor: Color(0xffFFFFFF),

    body: pages[_tab],

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
    // bottomNavigationBar: Theme(
    //   data:ThemeData(
    //       textTheme: TextTheme(
    //           labelSmall:TextStyle(
    //             fontFamily: 'Urbanist',
    //           )
    //       )
    //   ),
    //
    //   child: NavigationBarTheme(
    //     data: NavigationBarThemeData(
    //         labelTextStyle: MaterialStateProperty.all(
    //           TextStyle(fontFamily: 'Urbanist'),
    //         )
    //     ),
    //     child: NavigationBar(
    //     backgroundColor: Colors.white,
    //       indicatorColor:Color(0xffFFd2bd),
    //       selectedIndex: _tab,
    //       destinations: [
    //         NavigationDestination(
    //
    //           icon: Icon(Icons.directions_car, color: Colors.grey),
    //           selectedIcon: Icon(Icons.directions_car, color: Colors.black),
    //           label: 'Discover',
    //         ),
    //         NavigationDestination(
    //           icon: Icon(Icons.app_registration,color:Colors.grey),
    //           selectedIcon: Icon(Icons.app_registration, color: Colors.black),
    //           label: 'List your vehicle',
    //
    //         ),
    //         NavigationDestination(
    //           icon: Icon(Icons.account_circle_rounded, color: Colors.grey),
    //           selectedIcon: Icon(Icons.account_circle_rounded, color: Colors.black),
    //
    //           label: 'Sign In',
    //         ),
    //       ],
    //       onDestinationSelected: (index) {
    //         setState(() {
    //           _tab = index;
    //         });
    //       },
    //
    //     ),
    //   ),
    // )

  );

  void onTap(int tab) {
    setState(() {
      _tab = tab;
    });
  }
}