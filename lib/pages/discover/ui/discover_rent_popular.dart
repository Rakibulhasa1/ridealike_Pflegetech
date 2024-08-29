import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as location_handler;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/discover/bloc/discover_rent_bloc.dart';
import 'package:ridealike/pages/discover/request_service/discover_rent_request.dart';
import 'package:ridealike/pages/discover/response_model/fetchPopularCarResponse.dart';
import 'package:shimmer/shimmer.dart';

import '../../../widgets/discover_car_style.dart';
import '../../../widgets/shimmer.dart';
import '../../common/location_util.dart';

class DiscoverRentPopular extends StatefulWidget {
  @override
  State createState() => DiscoverRentPopularState();
}

class DiscoverRentPopularState extends State<DiscoverRentPopular> {
  final discoverRentBloc = DiscoverRentBloc();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      discoverRentBloc.callFetchPopularCars(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    discoverRentBloc.changedProgressIndicator.call(0);
    return StreamBuilder<bool>(
        stream: discoverRentBloc.isDataAvailable,
        builder: (context, isDataAvailableSnapshot) {
          return isDataAvailableSnapshot.hasData &&
                  isDataAvailableSnapshot.data!
              ? StreamBuilder<bool>(
                  stream: discoverRentBloc.loggedIn,
                  builder: (context, loggedInSnapshot) {
                    return StreamBuilder<int>(
                        stream: discoverRentBloc.progressIndicator,
                        builder: (context, progressIndicatorSnapshot) {
                          return Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  StreamBuilder<bool>(
                                      stream:
                                          discoverRentBloc.locationPermission,
                                      builder: (context,
                                          locationPermissionSnapshot) {
                                        return locationPermissionSnapshot
                                                .hasData
                                            ? locationPermissionSnapshot.data!
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      StreamBuilder<
                                                              FetchPopularCarResponse>(
                                                          stream: discoverRentBloc
                                                              .popularCarData,
                                                          builder: (context,
                                                              popularCarDataSnapshot) {
                                                            return popularCarDataSnapshot
                                                                    .hasData
                                                                ? Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <Widget>[
                                                                      popularCarDataSnapshot.data!.cars != null &&
                                                                              popularCarDataSnapshot.data!.cars!.length > 0
                                                                          ? Padding(
                                                                              padding: const EdgeInsets.only(left: 12),
                                                                              child: Container(
                                                                                height: MediaQuery.of(context).size.height,
                                                                                child: StreamBuilder<String>(
                                                                                    stream: discoverRentBloc.userId,
                                                                                    builder: (context, userIdSnapshot) {
                                                                                      return ListView.builder(
                                                                                        scrollDirection: Axis.vertical,
                                                                                        shrinkWrap: false,
                                                                                        itemCount: popularCarDataSnapshot.data!.cars!.length,
                                                                                        itemBuilder: (context, index) {
                                                                                          return GestureDetector(
                                                                                            onTap: progressIndicatorSnapshot.data == 1
                                                                                                ? null
                                                                                                : () async {
                                                                                                    if (progressIndicatorSnapshot.data == 0) {
                                                                                                      discoverRentBloc.changedProgressIndicator.call(1);
                                                                                                      if (userIdSnapshot.hasData == true && userIdSnapshot.data != '') {
                                                                                                        await addCarToViewedList(popularCarDataSnapshot.data!.cars![index].id!, userIdSnapshot.data!);
                                                                                                        discoverRentBloc.callFetchOnlyRecentlyViewed();
                                                                                                      }
                                                                                                      Navigator.pushNamed(context, '/car_details_non_search', arguments: popularCarDataSnapshot.data!.cars![index].id).then((value) {
                                                                                                        if (loggedInSnapshot.data == false && value == null) {
                                                                                                          Navigator.pushReplacementNamed(context, '/discover_tab');
                                                                                                        }
                                                                                                        discoverRentBloc.changedProgressIndicator.call(0);
                                                                                                      });
                                                                                                    }
                                                                                                  },
                                                                                            child: Container(
                                                                                              margin: EdgeInsets.only(right: 12, top: 12, bottom: 12),
                                                                                              width: MediaQuery.of(context).size.width,
                                                                                              height: 270,
                                                                                              child: Column(
                                                                                                children: <Widget>[
                                                                                                  ClipRRect(
                                                                                                    borderRadius: BorderRadius.circular(12),
                                                                                                    child: CachedNetworkImage(
                                                                                                      fit: BoxFit.cover,
                                                                                                      height: 220,
                                                                                                      width: MediaQuery.of(context).size.width,
                                                                                                      imageUrl: "$storageServerUrl/${popularCarDataSnapshot.data!.cars![index].imageId}",
                                                                                                      placeholder: (context, url) => Center(
                                                                                                        child: SizedBox(
                                                                                                          height: 270,
                                                                                                          width: MediaQuery.of(context).size.width,
                                                                                                          child: Shimmer.fromColors(
                                                                                                              baseColor: Colors.grey.shade300,
                                                                                                              highlightColor: Colors.grey.shade100,
                                                                                                              child: Padding(
                                                                                                                padding: const EdgeInsets.only(left: 0, right: 0),
                                                                                                                child: Container(
                                                                                                                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                                                                                                                ),
                                                                                                              )),
                                                                                                        ),
                                                                                                      ),
                                                                                                      errorWidget: (context, url, error) => Image.asset(
                                                                                                        'images/car-placeholder.png',
                                                                                                        fit: BoxFit.cover,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    children: <Widget>[
                                                                                                      Column(
                                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: <Widget>[
                                                                                                          Container(
                                                                                                            width: deviceWidth * 0.62,
                                                                                                            child: Text(popularCarDataSnapshot.data!.cars![index].title != ' ' ? popularCarDataSnapshot.data!.cars![index].title! : 'Car title', overflow: TextOverflow.ellipsis, style: carTitleTextStyle),
                                                                                                          ),
                                                                                                          Row(
                                                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                            children: <Widget>[
                                                                                                              // Text(
                                                                                                              //   popularCarDataSnapshot.data!.cars![index].year != '' ? popularCarDataSnapshot.data!.cars![index].year! : '',
                                                                                                              //   style: carYearTextStyle
                                                                                                              // ),
                                                                                                              // Text('.'),
                                                                                                              // SizedBox(
                                                                                                              //   width: 4,
                                                                                                              // ),
                                                                                                              popularCarDataSnapshot.data!.cars![index] != null && popularCarDataSnapshot.data!.cars![index].numberOfTrips != null && popularCarDataSnapshot.data!.cars![index].numberOfTrips != '0'
                                                                                                                  ? Row(
                                                                                                                      children: [
                                                                                                                        // Container(
                                                                                                                        //   width: 2,
                                                                                                                        //   height: 2,
                                                                                                                        //   decoration: new BoxDecoration(
                                                                                                                        //     color: Color(0xff353B50),
                                                                                                                        //     shape: BoxShape.circle,
                                                                                                                        //   ),
                                                                                                                        // ),
                                                                                                                        // SizedBox(
                                                                                                                        //   width: 4,
                                                                                                                        // ),
                                                                                                                      ],
                                                                                                                    )
                                                                                                                  : Container(),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      Column(
                                                                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                                                                        children: <Widget>[
                                                                                                          Text('\$ ' + popularCarDataSnapshot.data!.cars![index].price!, style: carPriceTextStyle),
                                                                                                          Row(
                                                                                                            children: [
                                                                                                              if (popularCarDataSnapshot.data!.cars![index].rating != 0)
                                                                                                                Text(
                                                                                                                  popularCarDataSnapshot.data!.cars![index].rating!.toStringAsFixed(1),
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 13,
                                                                                                                    color: Color(0xffFF8F68),
                                                                                                                  ),
                                                                                                                )
                                                                                                              else
                                                                                                                Text(
                                                                                                                  ''
                                                                                                                ),
                                                                                                              popularCarDataSnapshot.data!.cars![index].rating != 0 && popularCarDataSnapshot.data!.cars![index].rating != 0
                                                                                                                  ? Icon(
                                                                                                                      Icons.star,
                                                                                                                      size: 18,
                                                                                                                      color: Color(0xffFF8F68),
                                                                                                                    )
                                                                                                                  : Icon(
                                                                                                                      Icons.star,
                                                                                                                      size: 0,
                                                                                                                      color: Color(0xffFF8F68),
                                                                                                                    ),
                                                                                                              popularCarDataSnapshot.data!.cars![index] != null && popularCarDataSnapshot.data!.cars![index].numberOfTrips != null && popularCarDataSnapshot.data!.cars![index].numberOfTrips != '0'
                                                                                                                  ? Text(
                                                                                                                      popularCarDataSnapshot.data!.cars![index].numberOfTrips != '1' ? '(${popularCarDataSnapshot.data!.cars![index].numberOfTrips} trips)' : '(${popularCarDataSnapshot.data!.cars![index].numberOfTrips} trip)',
                                                                                                                      style: TextStyle(
                                                                                                                        fontSize: 15,
                                                                                                                        fontWeight: FontWeight.normal,
                                                                                                                        fontFamily: 'Urbanist',
                                                                                                                        color: Color(0xff353B50),
                                                                                                                      ),
                                                                                                                    )
                                                                                                                  : Text(''),
                                                                                                            ],
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                      );
                                                                                    }),
                                                                              ),
                                                                            )
                                                                          : Padding(
                                                                              padding: const EdgeInsets.only(left: 20),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  'Currently no vehicle found.',
                                                                                  style: TextStyle(fontFamily: 'Urbanist', fontSize: 16, fontWeight: FontWeight.bold),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                    ],
                                                                  )
                                                                : Container();
                                                          }),
                                                    ],
                                                  )
                                                : Center(
                                                    child: Container(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            'Permission denied. Please give permission to see list of vehicles in your area.',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              elevation: 0.0,
                                                              backgroundColor:
                                                                  Color(
                                                                      0xFFF2F2F2),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          12.0),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0)),
                                                            ),
                                                            onPressed:
                                                                () async {
                                                              LocationPermission?
                                                                  locationPermission =
                                                                  await LocationUtil
                                                                      .requestPermission();
                                                              if (locationPermission ==
                                                                      LocationPermission
                                                                          .denied ||
                                                                  locationPermission ==
                                                                      LocationPermission
                                                                          .deniedForever) {
                                                                showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (context) {
                                                                    return CupertinoAlertDialog(
                                                                      title: Text(
                                                                          'Location Permission'),
                                                                      content: Text(
                                                                          'This app needs location access'),
                                                                      actions: [
                                                                        CupertinoDialogAction(
                                                                          child:
                                                                              Text('Deny'),
                                                                          onPressed: () =>
                                                                              Navigator.pop(context),
                                                                        ),
                                                                        CupertinoDialogAction(
                                                                          child:
                                                                              Text('Settings'),
                                                                          onPressed:
                                                                              () async {
                                                                            location_handler.openAppSettings().whenComplete(() {
                                                                              return Navigator.pop(context);
                                                                            });
                                                                          },
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                );
                                                              } else {
                                                                discoverRentBloc
                                                                    .callFetchNewCars(
                                                                        context);
                                                              }
                                                            },
                                                            child: Text(
                                                              'Click for permission',
                                                              style: TextStyle(
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                            : Container();
                                      }),
                                ],
                              ),
                            ),
                          );
                        });
                  })
              : SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ShimmerEffect(),
                      ]),
                );
        });
  }
}
