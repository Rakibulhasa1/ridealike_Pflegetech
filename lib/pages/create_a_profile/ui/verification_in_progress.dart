import 'package:flutter/material.dart';
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/widgets/map_button.dart';

import '../../../tabs/discover.dart' as _discoverTab;
import '../../list_a_car/ui/list_your_car.dart' as _listYourCarTab;
import 'verification_in_progress_view.dart' as _verificationInProgressView;

class VerificationInProgress extends StatefulWidget {
  @override
  State createState() => VerificationInProgressState();
}

class VerificationInProgressState extends State<VerificationInProgress> {
  int _tab = 2;

  //variables for floating action button
  final discoverBloc = DiscoverBloc();
  bool _mapClick = false;

  var pages = [
    new _discoverTab.Discover(),
    new _listYourCarTab.ListYourCar(),
    new _verificationInProgressView.VerificationInProgressView()
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
    //     // // selectedItemColor: Color(0xffFF8F68),
    //     // // selectedItemColor: Color.fromRGBO(55, 29, 50, 1),
    //     selectedIndex: _tab,
    //     onDestinationSelected: onTap,
    //     destinations: [
    //       NavigationDestination(
    //         icon: _tab == 0 ? Icon(Icons.directions_car,color:Color(0xffFF8F68),) : Image.asset('icons/Discover.png'),
    //         label: 'Discover', // Use label instead of title
    //       ),
    //       NavigationDestination(
    //         icon: _tab == 1 ? Icon(Icons.app_registration,color:Color(0xffFF8F68)) : Icon(Icons.app_registration,color:Colors.black,),
    //         // title: Text('List your\nvehicle',
    //         //   maxLines: 2,
    //         //   textAlign: TextAlign.center,
    //         //   style: TextStyle(
    //         //     fontFamily: 'Urbanist',
    //         //     fontSize: 10,
    //         //   ),
    //         // ),
    //         label: 'List your\nvehicle',
    //       ),
    //       NavigationDestination(
    //         icon: _tab == 2 ? Icon(Icons.account_circle_rounded,color:Color(0xffFF8F68),) : Icon(Icons.account_circle_rounded,color:Colors.black,),
    //         // title: Text('Sign In',
    //         //   style: TextStyle(
    //         //     fontFamily: 'Urbanist',
    //         //     fontSize: 10,
    //         //   ),
    //         // )
    //         label: 'Sign In',
    //       ),
    //     ],
    //   ),
    // ),
  );

  void onTap(int tab) {
    setState(() {
      _tab = tab;
    });
  }
}