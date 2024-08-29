import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:ridealike/bloc/map_button_bloc.dart';
import 'package:ridealike/events/swap_car_event.dart';
import 'package:ridealike/events/swap_no_car_event.dart';
import 'package:ridealike/main.dart' as Main;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/pages/discover/ui/discover_rent_hello.dart';
import 'package:ridealike/pages/discover/ui/discover_rent_nearby.dart';
import 'package:ridealike/pages/discover/ui/discover_rent_popular.dart';
import 'package:ridealike/pages/discover/ui/discover_rent_previous.dart';
import 'package:ridealike/pages/discover/ui/discover_rent_recent.dart';
import 'package:ridealike/pages/discover/ui/discover_swap.dart';
import 'package:ridealike/pages/messages/utils/eventbusutils.dart';
import 'package:ridealike/utils/push_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/url_launcher.dart';

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover>
    with SingleTickerProviderStateMixin {
  final discoverBloc = DiscoverBloc();
  final storage = new FlutterSecureStorage();
  bool _swapSettingsEnabled = true;
  bool? _loggedIn;
  int _current = 0;
  int selectedTabIndex = 0;
  TabController? tabController;

  Future<RestApi.Resp> checkUnreadNotificationStatus(userID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      changeUnreadNotificationStatusUrl,
      json.encode({
        "UserID": userID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  @override
  void initState() {
    tabController = TabController(length: 5, vsync: this);
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      checkLoginStatus();
      MapButtonBloc.mapButtonSink.add(true);
      discoverBloc.changedOnTapped.call(false);
      EventBusUtils.getInstance().on<SwapCarEvent>().listen((event) {
        setState(() {
          _swapSettingsEnabled = true;
        });
      });

      EventBusUtils.getInstance().on<SwapNoCarEvent>().listen((event) {
        if (mounted) {
          setState(() {
            _swapSettingsEnabled = false;
          });
        }
      });
      PushNotifications.initNotification().then((fcmToken) {
        if (fcmToken != null) {
          storage.read(key: 'user_id').then((userID) {
            if (userID != null) {
              getPushNotification(userID, fcmToken);
            }
          });
        }
      });
      /*PushNotifications.setupFirebase().then((fcmToken) {
        if (fcmToken != null) {
          storage.read(key: 'user_id').then((userID) {
            if (userID != null) {
              getPushNotification(userID, fcmToken);
            }
          });
        }
      });*/
    });
  }

  void launchUrl(String url) async {
    if (await canLaunch(url) != null) {
      launch(url);
    } else {
      throw "Could not launch $url";
    }
  }

  final List<Map<String, dynamic>> carouselData = [
    {
      'image': 'images/CO2 uitstoot wagens 1.png',
      'text': 'Invite a friend, get \$50 discount on your next trip.',
      'color': Color(0xffFF8F68)
    },
    {
      'image': 'images/10285521 1.png',
      'text': 'Every trip is insured with \$2M Liability Insurance',
      'color': Colors.black
    },
  ];

  checkLoginStatus() async {
    String? userID = await storage.read(key: 'user_id');
    if (userID != null) {
      setState(() {
        _loggedIn = true;
      });
    } else {
      setState(() {
        _loggedIn = false;
      });
    }
  }

  FocusNode _damageDesctiptionfocusNode = FocusNode();
  FocusNode _mileagefocusNode = FocusNode();

  @override
  void dispose() {
    tabController!.dispose();
    _damageDesctiptionfocusNode.dispose();
    super.dispose();
  }

  void _handleTapOutside() {
    _damageDesctiptionfocusNode.unfocus();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTapOutside,
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: new Scaffold(
          appBar: AppBar(
            elevation: 2,
            toolbarHeight: 210.0,
            automaticallyImplyLeading: false,
            bottom: TabBar(
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              physics: BouncingScrollPhysics(),
              controller: tabController,
              labelPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              isScrollable: true,
              indicatorWeight: 2.0,
              unselectedLabelColor: Colors.grey,
              labelColor: Colors.black,
              onTap: (index) {
                setState(() {
                  selectedTabIndex = index;
                });
              },
              tabs: [
                Tab(
                  child: Column(
                    children: [
                      Image.asset(
                        selectedTabIndex == 0
                            ? 'images/R1 2.png'
                            : 'images/R1 2.png',
                        width: 28,
                        height: 28,
                        color: Color(0xffFF8F68),
                      ),
                      Text(
                        "Hello",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            fontFamily: 'Urbanist'),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    children: [
                      Image.asset(
                        selectedTabIndex == 1
                            ? 'images/nearby.png'
                            : 'images/unnearby.png',
                        width: 28,
                        height: 28,
                      ),
                      Text(
                        "Cars nearby",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            fontFamily: 'Urbanist'),
                      ),
                    ],
                  ),
                ),
                Tab(
                  child: Column(
                    children: [
                      Image.asset(
                        selectedTabIndex == 2
                            ? 'images/car.png'
                            : 'images/uncar.png',
                        width: 28,
                        height: 28,
                      ),
                      Text(
                        "Top cars this month",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            fontFamily: 'Urbanist'),
                      ),
                    ],
                  ),
                ),
                if(_loggedIn == true)
                  Tab(
                    child: Column(
                      children: [
                        Image.asset(
                          selectedTabIndex == 3
                              ? 'images/tap.png'
                              : 'images/untap.png',
                          width: 28,
                          height: 28,
                        ),
                        Text(
                          "Recently viewed",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              fontFamily: 'Urbanist'),
                        ),
                      ],
                    ),
                  ),
                if(_loggedIn == true)
                  Tab(
                    child: Column(
                      children: [
                        Image.asset(
                          selectedTabIndex == 4
                              ? 'images/history.png'
                              : 'images/unhistory.png',
                          width: 28,
                          height: 28,
                        ),
                        Text(
                          "Previously booked",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              fontFamily: 'Urbanist'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            title: StreamBuilder<bool>(
                stream: discoverBloc.onTapped,
                builder: (context, onTappedSnapshot) {
                  return onTappedSnapshot.hasData
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 30),

                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 0.0),
                                      child: Container(
                                        width: 240,
                                        height: 40,
                                        decoration: BoxDecoration(
                                            color: Color(0xffF2F2F2),
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(16)),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            // ToggleSwitch(
                                            //   cornerRadius: 20.0,
                                            //   inactiveBgColor: Colors.grey.shade200,
                                            //   minWidth: 115.0,
                                            //   activeBgColor: Color(0xffFF8F68),
                                            //   activeFgColor: Colors.white,
                                            //   initialLabelIndex: 0,
                                            //   labels: ['RENT', 'SWAP',],
                                            //   onToggle: (index) {
                                            //     print('switched to: $index');
                                            //     if (index == 1) {
                                            //           MapButtonBloc.mapButtonSink
                                            //               .add(false);
                                            //           discoverBloc.changedOnTapped
                                            //               .call(!onTappedSnapshot
                                            //                   .data);
                                            //
                                            //       Navigator.of(context).push(MaterialPageRoute(
                                            //         builder: (context) => DiscoverSwap(),
                                            //       ));
                                            //     }
                                            //   },
                                            // ),
                                            GestureDetector(
                                              onTap: () {
                                                // MapButtonBloc.mapButtonSink
                                                //     .add(true);
                                                // return discoverBloc.changedOnTapped
                                                //     .call(!onTappedSnapshot.data);
                                              },
                                              child: Container(
                                                alignment: Alignment.center,
                                                height: 36,
                                                width: 120,
                                                decoration: BoxDecoration(
                                                    boxShadow: onTappedSnapshot
                                                            .data!
                                                        ? null
                                                        : [
                                                            BoxShadow(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      0,
                                                                      0,
                                                                      0,
                                                                      0.1),
                                                              blurRadius: 8,
                                                              // has the effect of softening the shadow
                                                              spreadRadius: 0,
                                                              // has the effect of extending the shadow
                                                              offset: Offset(
                                                                0,
                                                                // horizontal, move right 10
                                                                4, // vertical, move down 10
                                                              ),
                                                            ),
                                                          ],
                                                    color:
                                                        onTappedSnapshot.data!
                                                            ? null
                                                            : Color(0xffFF8F68),
                                                    borderRadius: onTappedSnapshot
                                                            .data!
                                                        ? BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    16),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    16))
                                                        : BorderRadius.circular(
                                                            16),
                                                    shape: BoxShape.rectangle),
                                                child: Text(
                                                  'RENT',
                                                  style: onTappedSnapshot.data!
                                                      ? Theme.of(context)
                                                          .textTheme
                                                          .headline4!
                                                          .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xff371D32),
                                                          )
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .headline4!
                                                          .copyWith(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Color(
                                                                0xffFFFFFF),
                                                          ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // MapButtonBloc.mapButtonSink
                                                //     .add(false);
                                                // discoverBloc.changedOnTapped
                                                //     .call(!onTappedSnapshot
                                                //         .data);
                                                Navigator.of(context)
                                                    .push(MaterialPageRoute(
                                                  builder: (context) =>
                                                      DiscoverSwap(),
                                                ));

                                                // print("swap tap");
                                              },
                                              child: Container(
                                                width: 120,
                                                height: 36,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: onTappedSnapshot.data!
                                                      ? Color(0xffFF8F68)
                                                      : null,
                                                  shape: BoxShape.rectangle,
                                                  borderRadius: onTappedSnapshot
                                                          .data!
                                                      ? BorderRadius.circular(
                                                          16)
                                                      : BorderRadius.only(
                                                          topRight:
                                                              Radius.circular(
                                                                  16),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  16)),
                                                ),
                                                child: Text(
                                                  'SWAP',
                                                  style: onTappedSnapshot.data!
                                                      ? Theme.of(context)
                                                          .textTheme
                                                          .headline4!
                                                          .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700)
                                                      : Theme.of(context)
                                                          .textTheme
                                                          .headline4!
                                                          .copyWith(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color: Color(
                                                                  0xff371D32)),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    //search button
                                    /*Stack(
                                      // overflow: Overflow.visible,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 6,
                                          ),
                                          child: GestureDetector(
                                              onTap: () {
                                                Navigator.pushNamed(
                                                    context, '/search_car_tab');
                                                // print("search tapped");
                                              },
                                              child: ClipOval(child:Container(
                                                height: 42,
                                                width: 42,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey,
                                                      blurRadius: 5.0,
                                                      offset: Offset(0, 3),
                                                    ),
                                                  ],
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(7.0),
                                                  child: SvgPicture.asset(
                                                    'svg/search.svg',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ),
                                              ))),
                                        ),
                                      ],
                                    ),*/

                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 10,
                                          ),
                                          child: ClipOval(
                                            child: Container(
                                              height: 42,
                                              width: 42,
                                              child: FloatingActionButton(
                                                  backgroundColor: Colors.white,
                                                  onPressed: () async {
                                                    storage
                                                        .read(key: 'user_id')
                                                        .then((userID) {
                                                      checkUnreadNotificationStatus(
                                                              userID)
                                                          .then((response) async {
                                                        Main.notificationCount
                                                            .value = 0;
                                                        final prefs =
                                                            await SharedPreferences
                                                                .getInstance();
                                                        await prefs.setString(
                                                            "count",
                                                            Main.notificationCount
                                                                .value
                                                                .toString());
                                                        /*await storage.write(
                                                    key: "count",
                                                    value: Main
                                                        .notificationCount.value
                                                        .toString());*/
                                                        FlutterAppBadger
                                                            .updateBadgeCount(Main
                                                                .notificationCount
                                                                .value);
                                                      });
                                                    });
                                            
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/profile_notifications',
                                                    );
                                                  },
                                                  child: SvgPicture.asset(
                                                      'svg/Group 162.svg')
                                                  // backgroundColor:
                                                  //     Color(0xffFFFFFF),
                                                  ),
                                            ),
                                          ),
                                        ),
                                        ValueListenableBuilder(
                                            valueListenable:
                                                Main.notificationCount,
                                            builder: (BuildContext context,
                                                int value, Widget? child) {
                                              return value != 0
                                                  ? Positioned(
                                                      left: 26,
                                                      bottom: 27,
                                                      child: Container(
                                                        height: 24,
                                                        width: 24,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xffFF8F68),
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(
                                                              value.toString(),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white,
                                                              )),
                                                        ),
                                                      ))
                                                  : Container();
                                            })
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            CarouselSlider(
                              items: carouselData.map((item) {
                                return Row(
                                  children: [
                                    // Left Container with Red Background and Text
                                    GestureDetector(
                                      onTap: () {
                                        if (item['text'] ==
                                            'Invite a friend, get \$50 discount on your next trip.') {
                                          UrlLauncher.launchUrl(referAFriend);
                                        } else if (item['text'] ==
                                            'Every trip is insured with \$2M Liability Insurance') {
                                          UrlLauncher.launchUrl(
                                              insurancePolicyUrl);
                                        }
                                        // Add more conditions as needed for other text values
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.45,
                                        height: 95,
                                        decoration: BoxDecoration(
                                          color: item['color'],
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12.0),
                                            bottomLeft: Radius.circular(12.0),
                                          ),
                                        ),
                                        padding: EdgeInsets.only(
                                            left: 16.0, right: 16, top: 7),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['text'],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.0,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Urbanist',
                                              ),
                                              maxLines: 4,
                                            ),
                                            SizedBox(
                                              height: 8,
                                            ),
                                            Row(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    if (item['text'] ==
                                                        'Invite a friend, get \$50 discount on your next trip.') {
                                                      UrlLauncher.launchUrl(
                                                          referAFriend);
                                                    } else if (item['text'] ==
                                                        'Every trip is insured with \$2M Liability Insurance') {
                                                      UrlLauncher.launchUrl(
                                                          insurancePolicyUrl);
                                                    }
                                                  },
                                                  child: Text(
                                                    'Learn More',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.0,
                                                      fontFamily: 'Urbanist',
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ),
                                                SvgPicture.asset(
                                                  'svg/clarity_arrow-line.svg',
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Right Container with Image
                                    GestureDetector(
                                      onTap: () {
                                        if (item['text'] ==
                                            'Invite a friend, get \$50 discount on your next trip.') {
                                          UrlLauncher.launchUrl(referAFriend);
                                        } else if (item['text'] ==
                                            'Every trip is insured with \$2M Liability Insurance') {
                                          UrlLauncher.launchUrl(
                                              insurancePolicyUrl);
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.26,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(12.0),
                                            bottomRight: Radius.circular(12.0),
                                          ),
                                          child: Image.asset(
                                            item['image'],
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                              options: CarouselOptions(
                                height: 120,
                                aspectRatio: 20 / 10,
                                onPageChanged: (int index,
                                    CarouselPageChangedReason reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                },
                                viewportFraction: 0.8,
                                initialPage: 0,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 5),
                                autoPlayAnimationDuration:
                                    Duration(milliseconds: 1000),
                                autoPlayCurve: Curves.fastOutSlowIn,
                                // pauseAutoPlayOnTouch: Duration(seconds: 10),
                                enlargeCenterPage: true,
                                scrollDirection: Axis.horizontal,
                              ),
                            ),

                            // SizedBox(height: 4),
                            Container(
                              height:
                                  10,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  carouselData.length,
                                  (index) {
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin:
                                          EdgeInsets.only(left: 4, right: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _current == index
                                            ? Color(0xffFF8F68)
                                            : Color(0xffE0E0E0),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            SizedBox(height: 6),

                            // !onTappedSnapshot.data
                            //     ? Container()
                            //
                            //     // DiscoverRentNearby()
                            //     : DiscoverSwap(),
                          ],
                        )
                      : Container();
                }),
          ),
          backgroundColor: Colors.white,
          body: TabBarView(
            controller: tabController,
            children: [
              //TODO location issue
              DiscoverRentHello(),
              DiscoverRentNearby(),
              DiscoverRentPopular(),
              DiscoverRentRecent(),
              DiscoverRentPrevious(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<RestApi.Resp> getPushNotification(String userID, String fcmToken) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    setNotificationTokenUrl,
    json.encode({"UserID": userID, "Token": fcmToken}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
