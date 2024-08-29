import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/widgets/map_button.dart';

import '../tabs/discover.dart' as _discoverTab;
import '../tabs/list_your_car.dart' as _listYourCarTab;
import 'create_profile_or_sign_in_view.dart' as _createProfileOrSignInViewPage;

class CreateProfileOrSignIn extends StatefulWidget {
  @override
  State createState() => CreateProfileOrSignInState();
}

class CreateProfileOrSignInState extends State<CreateProfileOrSignIn> {
  int _tab = 2;
  var pages = [
    new _discoverTab.Discover(),
    new _listYourCarTab.ListYourCar(),
    new _createProfileOrSignInViewPage.CreateProfileOrSignInView()

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
    bottomNavigationBar: Theme.of(context).platform == TargetPlatform.iOS ? NavigationBarTheme(

      data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontFamily: 'Urbanist',fontSize: 11),
          )
      ),
      child: new NavigationBar(
        backgroundColor: Colors.white, indicatorColor: Color(0xffFFd2bd),
        selectedIndex: _tab,
        onDestinationSelected: onTap,
        destinations: [
          NavigationDestination(
            icon: _tab == 0 ? SvgPicture.asset(
              'svg/discoverIcon.svg',
              color: Colors.black,
              height: 28,
            ) : SvgPicture.asset(
              'svg/discoverIcon.svg',
              color: Colors.grey,
              height: 28,
            ),
            label: 'Discover',

          ),
          NavigationDestination(
            icon: _tab == 1 ? Icon(Icons.app_registration,color:Colors.black) : Icon(Icons.app_registration,color:Colors.grey,),
            label: 'List your car',

          ),
          NavigationDestination(
            icon: _tab == 2 ? Icon(Icons.account_circle_rounded,color:Colors.black,) : Icon(Icons.account_circle_rounded,color:Colors.grey,),
            label: 'Sign In',

          ),
        ],
      ),
    ) :
    NavigationBarTheme(

      data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontFamily: 'Urbanist',fontSize: 11),
          )
      ),
      child: new NavigationBar(
        indicatorColor: Color(0xffFFd2bd),
        backgroundColor: Colors.white,
        // selectedItemColor: Color(0xffFF8F68),
        // selectedItemColor: Color.fromRGBO(55, 29, 50, 1),
        selectedIndex: _tab,
        onDestinationSelected: onTap,
        destinations: [
          NavigationDestination(
            icon: _tab == 0 ? SvgPicture.asset(
              'svg/discoverIcon.svg',
              color: Colors.black,
              height: 28,
            ) : SvgPicture.asset(
              'svg/discoverIcon.svg',
              color: Colors.grey,
              height: 28,
            ),
            label: 'Discover',

          ),
          NavigationDestination(
            icon: _tab == 1 ? Icon(Icons.app_registration,color:Colors.black,) : Icon(Icons.app_registration,color:Colors.grey,),
            label: 'List your car',

          ),
          NavigationDestination(
            icon: _tab == 2 ? Icon(Icons.account_circle_rounded,color:Colors.black,) : Icon(Icons.account_circle_rounded,color:Colors.grey,),
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
