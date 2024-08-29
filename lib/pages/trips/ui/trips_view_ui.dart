import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ridealike/pages/messages/events/messageEvent.dart';
import 'package:ridealike/pages/messages/utils/eventbusutils.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/ui/trips_car_card_ui.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';


//TripsResponse _listOfTripsInfo;
List<Trips> upComingTrip = [];
List<Trips> currentTrip = [];
List<Trips> pastTrip = [];

class TripsViewUi extends StatefulWidget {
  int? initialIndex=0;
  String? tripId;

  TripsViewUi({ this.initialIndex,  this.tripId});

//  TripsViewUi() : super();
  @override
  _TripsViewUiState createState() => _TripsViewUiState(initialIndex: initialIndex,tripId: this.tripId);

}

class _TripsViewUiState extends State<TripsViewUi> with SingleTickerProviderStateMixin {
  String userId = "";
  bool loadData = false;
 StreamSubscription? messageSubscription;

 TabController? _tabController;
  final List<Tab> tabs = <Tab>[
    Tab(
      child: Text(
        "Upcoming",
        style: TextStyle(fontFamily: "Urbanist",fontSize: 13 ,fontWeight: FontWeight.w600),
      ),
    ),
  Tab(
  child: Text(
  "Current",
  style: TextStyle(fontFamily: "Urbanist",fontSize: 13,fontWeight: FontWeight.w600 ),
  ),
  ),
    Tab(
      child: Text(
        "Past",
        style: TextStyle(fontFamily: "Urbanist",fontSize: 13,fontWeight: FontWeight.w600 ),
      ),
    ),
    Tab(
      child: Text(
        "Cancelled",
        style: TextStyle(fontFamily: "Urbanist",fontSize: 13,fontWeight: FontWeight.w600 ),
      ),
    ),
  ];

  var initialIndex;
  String? tripId;

  _TripsViewUiState({this.initialIndex, this.tripId});

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Trips"});
    messageSubscription =
        EventBusUtils.getInstance().on<MessageEvent>().listen((event) {
      print("trips_view_ui:::MessageListener:::");
    });
    _tabController = TabController(
        vsync: this,
        length: tabs.length,
        initialIndex: initialIndex == null ? 0 : widget.initialIndex!);
//    callFetchTripsData();
  }

  @override
  void dispose() {
    messageSubscription!.cancel();
    _tabController!.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        title: Text('Trips',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 36,
            color: Color(0xFF371D32),
            fontWeight: FontWeight.bold
          ),
        ),
        elevation: 0.0,
        bottom: TabBar(physics: BouncingScrollPhysics(),
          tabAlignment:TabAlignment.start,
          indicatorSize: TabBarIndicatorSize.label,
          labelPadding: EdgeInsets.symmetric(horizontal: 26.0, ),
          isScrollable: true,
          unselectedLabelColor: Color(0xff371D32),
          labelColor: Color(0xffF68E65),
          controller: _tabController,
          tabs:tabs,
        ),
      ),

      body:  TabBarView(
        controller: _tabController,
        children: <Widget>[
          TripsCarCardUi(tripType: "Upcoming", tripId: tripId,),
          TripsCarCardUi( tripType: "Current", tripId: tripId,),
          TripsCarCardUi(tripType: "Past", tripId: tripId, dataToRemove: 'C',),
          TripsCarCardUi(tripType: "Past", tripId: tripId, dataToRemove: 'A',),
        ],
      )
    );
        //   elevation: 0.0,
        //   bottom: TabBar(
        //     unselectedLabelColor: Color(0xff371D32),
        //     labelColor: Color(0xffF68E65),
        //     controller: _tabController,
        //     tabs: tabs,
        //   ),
        // ),
        // body: TabBarView(
        //   controller: _tabController,
        //   children: <Widget>[
        //     TripsCarCardUi(
        //       tripType: "Upcoming",
        //       tripId: tripId,
        //     ),
        //     TripsCarCardUi(
        //       tripType: "Current",
        //       tripId: tripId,
        //     ),
        //     TripsCarCardUi(
        //       tripType: "Past",
        //       tripId: tripId,
        //     ),
        //   ],
        // ));
  }
}
