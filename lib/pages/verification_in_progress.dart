import 'package:flutter/material.dart';
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/widgets/map_button.dart';

import '../tabs/discover.dart' as _discoverTab;
import '../tabs/list_your_car.dart' as _listYourCarTab;
import './verification_in_progress_view.dart' as _verificationInProgressView;
import 'discover/bloc/discover_bloc.dart';

class VerificationInProgress extends StatefulWidget {
  @override
  State createState() => VerificationInProgressState();
}

class VerificationInProgressState extends State<VerificationInProgress> {
  int _tab = 2;
  var pages = [
    new _discoverTab.Discover(),
    new _listYourCarTab.ListYourCar(),
    new _verificationInProgressView.VerificationInProgressView()
  ];

  //variables for floating action button
  final discoverBloc = DiscoverBloc();
  bool _mapClick = false;

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
            icon: _tab == 0 ? Icon(Icons.directions_car,color:Color(0xffFF8F68),) : Image.asset('icons/Discover.png'),
            label: 'Discover',
            //   style: TextStyle(
            //     fontFamily: 'Urbanist',
            //     fontSize: 10,
            //   ),
            // ),
          ),
          NavigationDestination(
            icon: _tab == 1 ? Image.asset('icons/List-a-Car_Active.png') : Icon(Icons.app_registration,color:Colors.grey,),
            label: 'List your\nvehicle',
            //   maxLines: 2,
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontFamily: 'Urbanist',
            //     fontSize: 10,
            //   ),
            // ),
          ),
          NavigationDestination(
            icon: _tab == 2 ? Icon(Icons.account_circle_rounded,color:Color(0xffFF8F68),) : Icon(Icons.account_circle_rounded,color:Colors.grey,),
            label: 'Sign In',

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