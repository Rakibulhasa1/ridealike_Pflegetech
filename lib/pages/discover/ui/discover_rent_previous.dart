import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lottie/lottie.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/discover/bloc/discover_rent_bloc.dart';
import 'package:ridealike/pages/discover/request_service/discover_rent_request.dart';
import 'package:ridealike/pages/discover/response_model/fetchPreviouslyBookedCarResponse.dart';
import 'package:shimmer/shimmer.dart';

import '../../../widgets/discover_car_style.dart';
import '../../../widgets/shimmer.dart';

class DiscoverRentPrevious extends StatefulWidget {
  @override
  State createState() => DiscoverRentPreviousState();
}

class DiscoverRentPreviousState extends State<DiscoverRentPrevious> {
  final discoverRentBloc = DiscoverRentBloc();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      //discoverRentBloc.callFetchNewCars(context);
      discoverRentBloc.callFetchLastData();
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
                                  loggedInSnapshot.hasData &&
                                          loggedInSnapshot.data!
                                      ? StreamBuilder<
                                              FetchPreviouslyBookedCarResponse>(
                                          stream: discoverRentBloc
                                              .previouslyBookedCar,
                                          builder: (context,
                                              previouslyBookedCarSnapshot) {
                                            return previouslyBookedCarSnapshot
                                                        .hasData &&
                                                    previouslyBookedCarSnapshot
                                                            .data!
                                                            .cars!
                                                            .length >
                                                        0
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 12.0),
                                                        child: Container(
                                                          height: MediaQuery.of(
                                                                  context)
                                                              .size
                                                              .height,
                                                          child: StreamBuilder<
                                                                  String>(
                                                              stream:
                                                                  discoverRentBloc
                                                                      .userId,
                                                              builder: (context,
                                                                  userIdSnapshot) {
                                                                return ListView
                                                                    .builder(
                                                                  shrinkWrap:
                                                                      false,
                                                                  itemCount:
                                                                      previouslyBookedCarSnapshot
                                                                          .data!
                                                                          .cars!
                                                                          .length,
                                                                  itemBuilder:
                                                                      (context,
                                                                          index) {
                                                                    return GestureDetector(
                                                                      onTap: progressIndicatorSnapshot.data ==
                                                                              1
                                                                          ? null
                                                                          : () async {
                                                                              if (progressIndicatorSnapshot.data == 0) {
                                                                                discoverRentBloc.changedProgressIndicator.call(1);
                                                                                if (userIdSnapshot.hasData == true && userIdSnapshot.data != '') {
                                                                                  await addCarToViewedList(previouslyBookedCarSnapshot.data!.cars![index].id!, userIdSnapshot.data!);
                                                                                  discoverRentBloc.callFetchOnlyRecentlyViewed();
                                                                                }
                                                                                Navigator.pushNamed(context, '/car_details_non_search', arguments: previouslyBookedCarSnapshot.data!.cars![index].id).then((value) {
                                                                                  if (loggedInSnapshot.data == false && value == null) {
                                                                                    Navigator.pushReplacementNamed(context, '/discover_tab');
                                                                                  }
                                                                                  discoverRentBloc.changedProgressIndicator.call(0);
                                                                                });
                                                                              }
                                                                            },
                                                                      child:
                                                                          Container(
                                                                        margin: EdgeInsets.only(
                                                                            top:
                                                                                12,
                                                                            bottom:
                                                                                12,
                                                                            right:
                                                                                12),
                                                                        width: MediaQuery.of(context)
                                                                            .size
                                                                            .width,
                                                                        height:
                                                                            270,
                                                                        child:
                                                                            Column(
                                                                          children: <Widget>[
                                                                            Stack(
                                                                              children: <Widget>[
                                                                                ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  child: CachedNetworkImage(
                                                                                    fit: BoxFit.cover,
                                                                                    height: 220,
                                                                                    width: MediaQuery.of(context).size.width,
                                                                                    imageUrl: "$storageServerUrl/${previouslyBookedCarSnapshot.data!.cars![index].imageId}",
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
                                                                                // Positioned(
                                                                                //   right: 15,
                                                                                //   bottom: 15,
                                                                                //   child: Container(
                                                                                //     height: 20,
                                                                                //     width: 80,
                                                                                //     decoration: BoxDecoration(color: Color(0xffFFFFFF), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(4)),
                                                                                //     child: Align(
                                                                                //       alignment: Alignment.center,
                                                                                //       child: Text(
                                                                                //         '\$ ' + previouslyBookedCarSnapshot.data!.cars![index].price!,
                                                                                //         style: TextStyle(
                                                                                //           color: Color(0xff353B50),
                                                                                //           fontFamily: 'Urbanist',
                                                                                //           fontWeight: FontWeight.bold,
                                                                                //           fontSize: 10,
                                                                                //           letterSpacing: 0.2,
                                                                                //         ),
                                                                                //       ),
                                                                                //     ),
                                                                                //   ),
                                                                                // )
                                                                              ],
                                                                            ),
                                                                            Expanded(
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(previouslyBookedCarSnapshot.data!.cars![index].title != '' ? previouslyBookedCarSnapshot.data!.cars![index].title! : 'Car title', overflow: TextOverflow.ellipsis, style: carTitleTextStyle),
                                                                                    ],
                                                                                  ),
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                    children: <Widget>[
                                                                                      Text(
                                                                                        '\$ ' + previouslyBookedCarSnapshot.data!.cars![index].price!,
                                                                                        style: carPriceTextStyle,
                                                                                      ),
                                                                                      Row(
                                                                                        children: [
                                                                                          if (previouslyBookedCarSnapshot.data!.cars![index].rating != 0)
                                                                                            Text(
                                                                                              previouslyBookedCarSnapshot.data!.cars![index].rating!.toStringAsFixed(1),
                                                                                              style: TextStyle(
                                                                                                fontSize: 13,
                                                                                                color: Color(0xffFF8F68),
                                                                                              ),
                                                                                            )
                                                                                          else
                                                                                            Text(
                                                                                                ''
                                                                                            ),
                                                                                          previouslyBookedCarSnapshot.data!.cars![index].rating != 0 && previouslyBookedCarSnapshot.data!.cars![index].rating != 0
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
                                                                                          previouslyBookedCarSnapshot.data!.cars![index] != null && previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips != null && previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips != '0'
                                                                                              ? Text(
                                                                                            previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips != '1' ? '(${previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips} trips)' : '(${previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips} trip)',
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
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  },
                                                                );
                                                              }),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20),
                                                    child: Center(
                                                        child: Column(
                                                      children: [
                                                        Lottie.asset(
                                                            'images/road.json'),
                                                      ],
                                                    )),
                                                  );
                                          })
                                      : new Container(),
                                ],
                              ),
                            ),
                          );
                        });
                  })
              : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [ShimmerEffect()],
                  ),
                );
        });
  }
}
