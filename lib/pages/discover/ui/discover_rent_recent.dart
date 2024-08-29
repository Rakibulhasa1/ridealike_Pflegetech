import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/discover/bloc/discover_rent_bloc.dart';
import 'package:ridealike/pages/discover/request_service/discover_rent_request.dart';
import 'package:ridealike/pages/discover/response_model/fetchRecentlyViewedCarResponse.dart';
import 'package:shimmer/shimmer.dart';

import '../../../widgets/discover_car_style.dart';
import '../../../widgets/shimmer.dart';

class DiscoverRentRecent extends StatefulWidget {
  @override
  State createState() => DiscoverRentRecentState();
}

class DiscoverRentRecentState extends State<DiscoverRentRecent> {
  final discoverRentBloc = DiscoverRentBloc();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      //discoverRentBloc.callFetchNewCars(context);
      discoverRentBloc.callFetchOnlyRecentlyViewed();
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
                                              FetchRecentlyViewedCarResponse>(
                                          stream: discoverRentBloc
                                              .recentlyViewedCar,
                                          builder: (context,
                                              recentViewedCarSnapshot) {
                                            return recentViewedCarSnapshot
                                                        .hasData &&
                                                    recentViewedCarSnapshot
                                                            .data !=
                                                        null &&
                                                    recentViewedCarSnapshot
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
                                                                  scrollDirection:
                                                                      Axis.vertical,
                                                                  shrinkWrap:
                                                                      false,
                                                                  itemCount:
                                                                      recentViewedCarSnapshot
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
                                                                                  await addCarToViewedList(recentViewedCarSnapshot.data!.cars![index].id!, userIdSnapshot.data!);
                                                                                  discoverRentBloc.callFetchOnlyRecentlyViewed();
                                                                                }
                                                                                Navigator.pushNamed(context, '/car_details_non_search', arguments: recentViewedCarSnapshot.data!.cars![index].id).then((value) {
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
                                                                            276,
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
                                                                                    imageUrl: "$storageServerUrl/${recentViewedCarSnapshot.data!.cars![index].imageId}",
                                                                                    placeholder: (context, url) => Center(
                                                                                      child: SizedBox(
                                                                                        height: 276,
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
                                                                              ],
                                                                            ),
                                                                            //

                                                                            Expanded(
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(recentViewedCarSnapshot.data!.cars![index].title != '' ? recentViewedCarSnapshot.data!.cars![index].title! : 'Car title', overflow: TextOverflow.ellipsis, style: carTitleTextStyle),
                                                                                      // Row(
                                                                                      //   crossAxisAlignment: CrossAxisAlignment.center,
                                                                                      //   children: <Widget>[
                                                                                      //     Text(
                                                                                      //       recentViewedCarSnapshot.data!.cars![index].year != '' ? recentViewedCarSnapshot.data!.cars![index].year! : '',
                                                                                      //       style: carYearTextStyle
                                                                                      //     ),
                                                                                      //     SizedBox(
                                                                                      //       width: 4,
                                                                                      //     ),
                                                                                      //
                                                                                      //     recentViewedCarSnapshot.data!.cars![index] != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != '0'
                                                                                      //         ? Row(
                                                                                      //             children: [
                                                                                      //               Container(
                                                                                      //                 width: 2,
                                                                                      //                 height: 2,
                                                                                      //                 decoration: new BoxDecoration(
                                                                                      //                   color: Color(0xff353B50),
                                                                                      //                   shape: BoxShape.circle,
                                                                                      //                 ),
                                                                                      //               ),
                                                                                      //               SizedBox(
                                                                                      //                 width: 4,
                                                                                      //               ),
                                                                                      //               recentViewedCarSnapshot.data!.cars![index] != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != '0'
                                                                                      //                   ? Text(
                                                                                      //                       recentViewedCarSnapshot.data!.cars![index].numberOfTrips != '1' ? '${recentViewedCarSnapshot.data!.cars![index].numberOfTrips} trips' : '${recentViewedCarSnapshot.data!.cars![index].numberOfTrips} trip',
                                                                                      //                       style: numOfTrips
                                                                                      //                     )
                                                                                      //                   : Text(''),
                                                                                      //             ],
                                                                                      //           )
                                                                                      //         : Container(),
                                                                                      //   ],
                                                                                      // ),
                                                                                    ],
                                                                                  ),
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                                                    children: <Widget>[
                                                                                      Text(
                                                                                        '\$ ' + recentViewedCarSnapshot.data!.cars![index].price!,
                                                                                        style: carPriceTextStyle,
                                                                                      ),
                                                                                      Row(
                                                                                        children: [
                                                                                          if (recentViewedCarSnapshot.data!.cars![index].rating != 0)
                                                                                            Text(
                                                                                              recentViewedCarSnapshot.data!.cars![index].rating!.toStringAsFixed(1),
                                                                                              style: TextStyle(
                                                                                                fontSize: 13,
                                                                                                color: Color(0xffFF8F68),
                                                                                              ),
                                                                                            )
                                                                                          else
                                                                                            Text(
                                                                                                ''
                                                                                            ),
                                                                                          recentViewedCarSnapshot.data!.cars![index].rating != 0 && recentViewedCarSnapshot.data!.cars![index].rating != 0
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
                                                                                          recentViewedCarSnapshot.data!.cars![index] != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != '0'
                                                                                              ? Text(
                                                                                            recentViewedCarSnapshot.data!.cars![index].numberOfTrips != '1' ? '(${recentViewedCarSnapshot.data!.cars![index].numberOfTrips} trips)' : '(${recentViewedCarSnapshot.data!.cars![index].numberOfTrips} trip)',
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
                                                : Container();
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
                    children: [
                      ShimmerEffect()
                    ],
                  ),
                );
        });
  }
}
