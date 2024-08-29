import 'package:flutter/material.dart';
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/pages/dashboard/deactivate_your_listing.dart'
    as _dashboardDeactivateYourListPage;
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/pages/messages/pages/threadlist/threadlistView.dart'
    as _threadListView;
import 'package:ridealike/pages/profile/profile_view.dart' as _profileView;
import 'package:ridealike/pages/trips/ui/trips_view_ui.dart' as _tripsViewUi;
import 'package:ridealike/tabs/discover.dart' as _discoverTab;
import 'package:ridealike/widgets/map_button.dart';

import '../../../main.dart';

class DashboardDeactivateListingTab extends StatefulWidget {
  @override
  _DashboardDeactivateListingTabState createState() =>
      _DashboardDeactivateListingTabState();
}

class _DashboardDeactivateListingTabState
    extends State<DashboardDeactivateListingTab> {
  int _tab = 1;

  //variables for floating action button
  final discoverBloc = DiscoverBloc();
  bool _mapClick = false;

  var pages = [
    new _discoverTab.Discover(),
    new _dashboardDeactivateYourListPage.DeactivateYourListing(),
    new _tripsViewUi.TripsViewUi(),
    new _threadListView.ThreadListView(),
    new _profileView.ProfileView()
  ];
  @override
  Widget build(BuildContext context) => new Scaffold(
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
    //     bottomNavigationBar: NavigationBarTheme(
    //
    //       data: NavigationBarThemeData(
    //           labelTextStyle: MaterialStateProperty.all(
    //             TextStyle(fontFamily: 'Urbanist'),
    //           )
    //       ),
    //       child: NavigationBar(
    //         indicatorColor: Color(0xffFFd2bd),
    //               backgroundColor: Colors.white,
    //               selectedIndex: _tab,
    //         onDestinationSelected: onTap,
    //         destinations: [
    //                 NavigationDestination(
    //                   icon: _tab == 0
    //                       ? Icon(Icons.directions_car,color:Color(0xffFF8F68),)
    //                       : Image.asset('icons/Discover.png'),
    //                   label:
    //                     'Discover',
    //                     // style: TextStyle(
    //                     //   fontFamily: 'Urbanist',
    //                     //   fontSize: 10,
    //                     // ),
    //
    //                 ),
    //                 NavigationDestination(
    //                     icon: _tab == 1
    //                         ? Image.asset('icons/Dashboard_Active.png')
    //                         : Icon(Icons.account_circle_rounded,color:Colors.grey,),
    //                     label:
    //                       'Dashboard',
    //                       // style: TextStyle(
    //                       //   fontFamily: 'Urbanist',
    //                       //   fontSize: 10,
    //                       // ),
    //                     ),
    //                 NavigationDestination(
    //                     icon: _tab == 2
    //                         ? Image.asset('icons/Trips-Active.png')
    //                         : Icon(Icons.compare_arrows,color:Colors.grey,),
    //                     label:
    //                       'Trips',
    //                       // style: TextStyle(
    //                       //   fontFamily: 'Urbanist',
    //                       //   fontSize: 10,
    //                       // ),
    //                     ),
    //                /* NavigationDestination(
    //                     icon: _tab == 3
    //                         ? Icon(Icons.message,color:Color(0xffFF8F68),)
    //                         : Icon(Icons.message,color:Colors.grey,),
    //                     title: Text(
    //                       'Chats',
    //                       style: TextStyle(
    //                         fontFamily: 'Urbanist',
    //                         fontSize: 10,
    //                       ),
    //                     )),*/
    //                 NavigationDestination(
    //                   icon: ValueListenableBuilder(
    //                     builder:
    //                         (BuildContext context, bool value, Widget? child) {
    //                       return value
    //                           ? Stack(
    //                         children: [
    //                           Icon(Icons.message,color:Colors.grey,),
    //                           Positioned(
    //                             left: 10,
    //                             child: Container(
    //                               height: 12.5,
    //                               width: 12.5,
    //                               decoration: BoxDecoration(
    //                                 color: Color(0xffFF8F68),
    //                                 border: Border.all(
    //                                   color: Color(0xffFF8F68),
    //                                 ),
    //                                 borderRadius: BorderRadius.all(
    //                                   Radius.circular(20),
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                       )
    //                           : Icon(Icons.message,color:Colors.grey,);
    //                     },
    //                     valueListenable: newMessage,
    //                   ),
    //                   selectedIcon: Icon(Icons.message,color:Color(0xffFF8F68),),
    //                   label:
    //                     'Chats',
    //                     // style: TextStyle(
    //                     //   fontFamily: 'Urbanist',
    //                     //   fontSize: 10,
    //                     // ),
    //
    //                 ),
    //                 NavigationDestination(
    //                     icon: _tab == 4
    //                         ? Icon(Icons.account_circle_rounded,color:Color(0xffFF8F68),)
    //                         : Icon(Icons.account_circle_rounded,color:Colors.grey,),
    //                     label:
    //                       'Profile',
    //                       // style: TextStyle(
    //                       //   fontFamily: 'Urbanist',
    //                       //   fontSize: 10,
    //                       // ),
    //                     ),
    //               ],
    //             ),
    //     ),
      );

  void onTap(int tab) {
    setState(() {
      _tab = tab;
    });
  }
}
