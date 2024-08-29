// /*
// import 'dart:io';
//
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
// import 'package:ridealike/pages/discover/bloc/discover_rent_bloc.dart';
// import 'package:ridealike/pages/discover/request_service/discover_rent_request.dart';
// import 'package:ridealike/pages/discover/response_model/fetchNewCarResponse.dart';
// import 'package:ridealike/pages/discover/response_model/fetchPopularCarResponse.dart';
// import 'package:ridealike/pages/discover/response_model/fetchPreviouslyBookedCarResponse.dart';
// import 'package:ridealike/pages/discover/response_model/fetchRecentlyViewedCarResponse.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:ridealike/pages/common/location_util.dart' as locationUtil;
// import 'package:permission_handler/permission_handler.dart' as location_handler;
// import 'package:ridealike/pages/common/constant_url.dart';
// import 'package:shimmer/shimmer.dart';
//
// class DiscoverRent extends StatefulWidget {
//   @override
//   State createState() => DiscoverRentState();
// }
//
// class DiscoverRentState extends State<DiscoverRent> {
//   final discoverRentBloc = DiscoverRentBloc();
//
//   @override
//   void initState() {
//     super.initState();
//     SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
//       discoverRentBloc.callFetchNewCars(context);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     double deviceWidth = MediaQuery.of(context).size.width;
//     discoverRentBloc.changedProgressIndicator.call(0);
//     return StreamBuilder<bool>(
//         stream: discoverRentBloc.isDataAvailable,
//         builder: (context, isDataAvailableSnapshot) {
//           return isDataAvailableSnapshot.hasData && isDataAvailableSnapshot.data!
//               ? StreamBuilder<bool>(
//                   stream: discoverRentBloc.loggedIn,
//                   builder: (context, loggedInSnapshot) {
//                     return StreamBuilder<int>(
//                         stream: discoverRentBloc.progressIndicator,
//                         builder: (context, progressIndicatorSnapshot) {
//                           return Container(
//                             color: Colors.white,
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 StreamBuilder<bool>(
//                                     stream: discoverRentBloc.locationPermission,
//                                     builder:
//                                         (context, locationPermissionSnapshot) {
//                                       return locationPermissionSnapshot.hasData
//                                           ? locationPermissionSnapshot.data!
//                                               ? Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: <Widget>[
//                                                     StreamBuilder<
//                                                             FetchNewCarResponse>(
//                                                         stream: discoverRentBloc
//                                                             .newCarData,
//                                                         builder: (context,
//                                                             fetchNewCarSnapshot) {
//                                                           return fetchNewCarSnapshot
//                                                                       .hasData &&
//                                                                   fetchNewCarSnapshot
//                                                                           .data !=
//                                                                       null
//                                                               ? Column(
//                                                                   crossAxisAlignment:
//                                                                       CrossAxisAlignment
//                                                                           .start,
//                                                                   children: <
//                                                                       Widget>[
//                                                                     StreamBuilder<
//                                                                             String>(
//                                                                         stream: discoverRentBloc
//                                                                             .currentAddress,
//                                                                         builder:
//                                                                             (context,
//                                                                                 currentAddressSnapshot) {
//                                                                           return AutoSizeText(
//                                                                             currentAddressSnapshot.hasData
//                                                                                 ? 'New vehicles closest to ${currentAddressSnapshot.data}'
//                                                                                 : 'New vehicles closest to ...',
//                                                                             style: TextStyle(
//                                                                                 fontFamily: 'Urbanist',
//                                                                                 fontSize: 24,
//                                                                                 fontWeight: FontWeight.bold),
//                                                                             maxLines:
//                                                                                 2,
//                                                                           );
//                                                                         }),
//                                                                     SizedBox(
//                                                                         height:
//                                                                             15),
//                                                                     fetchNewCarSnapshot.data!.cars !=
//                                                                                 null &&
//                                                                             fetchNewCarSnapshot.data!.cars!.length >
//                                                                                 0
//                                                                         ? Container(
//                                                                             height:
//                                                                                 276,
//                                                                             child: StreamBuilder<String>(
//                                                                                 stream: discoverRentBloc.userId,
//                                                                                 builder: (context, userIdSnapshot) {
//                                                                                   return ListView.builder(
//                                                                                     scrollDirection: Axis.vertical,
//                                                                                     shrinkWrap: false,
//                                                                                     itemCount: fetchNewCarSnapshot.data!.cars!.length,
//                                                                                     itemBuilder: (context, index) {
//                                                                                       return GestureDetector(
//                                                                                         onTap: progressIndicatorSnapshot.data == 1
//                                                                                             ? null
//                                                                                             : () async {
//                                                                                                 if (progressIndicatorSnapshot.data == 0) {
//                                                                                                   discoverRentBloc.changedProgressIndicator.call(1);
//
//                                                                                                   if (userIdSnapshot.hasData == true && userIdSnapshot.data != '') {
//                                                                                                     await addCarToViewedList(fetchNewCarSnapshot.data!.cars![index].id!, userIdSnapshot.data!);
//                                                                                                     discoverRentBloc.callFetchOnlyRecentlyViewed();
//                                                                                                   }
//                                                                                                   Navigator.pushNamed(context, '/car_details_non_search', arguments: fetchNewCarSnapshot.data!.cars![index].id).then((value) {
//                                                                                                     if (loggedInSnapshot.data == false && value == null) {
//                                                                                                       Navigator.pushReplacementNamed(context, '/discover_tab');
//                                                                                                     }
//                                                                                                     discoverRentBloc.changedProgressIndicator.call(0);
//                                                                                                   });
//                                                                                                 }
//                                                                                               },
//                                                                                         child: Container(
//                                                                                           margin: EdgeInsets.only(right: 16),
//                                                                                           width: deviceWidth * .85,
//                                                                                           height: 276,
//                                                                                           child: Column(
//                                                                                             children: <Widget>[
//                                                                                               */
// /*ClipRRect(
//                                                                                                 borderRadius: BorderRadius.circular(12),
//                                                                                                 child: Image(
//                                                                                                   height: 200,
//                                                                                                   width: MediaQuery.of(context).size.width * .90,
//                                                                                                   image: fetchNewCarSnapshot.data!.cars![index].imageId == ""
//                                                                                                       ? AssetImage('images/car-placeholder.png')
//                                                                                                       : NetworkImage(
//                                                                                                           '$storageServerUrl/${fetchNewCarSnapshot.data!.cars![index].imageId}',
//                                                                                                         ),
//                                                                                                   fit: BoxFit.cover,
//                                                                                                 ),
//                                                                                               ),*//*
//
//                                                                                               ClipRRect(
//                                                                                                 borderRadius: BorderRadius.circular(12),
//                                                                                                 child: CachedNetworkImage(
//                                                                                                   fit: BoxFit.cover,
//                                                                                                   height: 200,
//                                                                                                   width: MediaQuery.of(context).size.width * .90,
//                                                                                                   imageUrl: "$storageServerUrl/${fetchNewCarSnapshot.data!.cars![index].imageId}",
//                                                                                                   placeholder: (context, url) => SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 220,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 12.0, right: 12),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           SizedBox(
//                             height: 20,
//                             width: MediaQuery.of(context).size.width / 3,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 250,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16.0, right: 16),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 8,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             height: 14,
//                             width: MediaQuery.of(context).size.width / 2,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 250,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16.0, right: 16),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             height: 14,
//                             width: MediaQuery.of(context).size.width / 2,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                                                                                                   errorWidget: (context, url, error) => Image.asset(
//                                                                                                     'images/car-placeholder.png',
//                                                                                                     fit: BoxFit.cover,
//                                                                                                   ),
//                                                                                                 ),
//                                                                                               ),
//                                                                                               SizedBox(height: 8),
//                                                                                               Row(
//                                                                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                 children: <Widget>[
//                                                                                                   Column(
//                                                                                                     mainAxisAlignment: MainAxisAlignment.start,
//                                                                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                                                                     children: <Widget>[
//                                                                                                       Container(
//                                                                                                         width: deviceWidth * 0.62,
//                                                                                                         child: Text(
//                                                                                                           fetchNewCarSnapshot.data!.cars![index].title != '' ? fetchNewCarSnapshot.data!.cars![index].title! : 'Car title',
//                                                                                                           overflow: TextOverflow.ellipsis,
//                                                                                                           style: TextStyle(
//                                                                                                             fontWeight: FontWeight.w600,
//                                                                                                             fontFamily: 'Urbanist',
//                                                                                                           )
//                                                                                                         ),
//                                                                                                       ),
//                                                                                                       Row(
//                                                                                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                                         children: <Widget>[
//                                                                                                           Text(
//                                                                                                             fetchNewCarSnapshot.data!.cars![index].year != '' ? fetchNewCarSnapshot.data!.cars![index].year! : '',
//                                                                                                             style: TextStyle(
//                                                                                                               fontSize: 12,
//                                                                                                               fontWeight: FontWeight.normal,
//                                                                                                               fontFamily: 'Urbanist',
//                                                                                                               color: Color(0xff353B50),
//                                                                                                             ),
//                                                                                                           ),
//                                                                                                           SizedBox(
//                                                                                                             width: 4,
//                                                                                                           ),
//                                                                                                           fetchNewCarSnapshot.data!.cars![index] != null && fetchNewCarSnapshot.data!.cars![index].numberOfTrips != null && fetchNewCarSnapshot.data!.cars![index].numberOfTrips != '0'
//                                                                                                               ? Row(
//                                                                                                                   children: [
//                                                                                                                     Container(
//                                                                                                                       width: 2,
//                                                                                                                       height: 2,
//                                                                                                                       decoration: new BoxDecoration(
//                                                                                                                         color: Color(0xff353B50),
//                                                                                                                         shape: BoxShape.circle,
//                                                                                                                       ),
//                                                                                                                     ),
//                                                                                                                     SizedBox(
//                                                                                                                       width: 4,
//                                                                                                                     ),
//                                                                                                                     // ignore: unrelated_type_equality_checks
//                                                                                                                     fetchNewCarSnapshot.data!.cars![index] != null && fetchNewCarSnapshot.data!.cars![index].numberOfTrips != null && fetchNewCarSnapshot.data!.cars![index].numberOfTrips != '0'
//                                                                                                                         ? Text(
//                                                                                                                             fetchNewCarSnapshot.data!.cars![index].numberOfTrips != '1' ? '${fetchNewCarSnapshot.data!.cars![index].numberOfTrips} trips' : '${fetchNewCarSnapshot.data!.cars![index].numberOfTrips} trip',
//                                                                                                                             style: TextStyle(
//                                                                                                                               fontSize: 12,
//                                                                                                                               fontWeight: FontWeight.normal,
//                                                                                                                               fontFamily: 'Urbanist',
//                                                                                                                               color: Color(0xff353B50),
//                                                                                                                             ),
//                                                                                                                           )
//                                                                                                                         : Text(""),
//                                                                                                                   ],
//                                                                                                                 )
//                                                                                                               : SizedBox(),
//                                                                                                         ],
//                                                                                                       ),
//                                                                                                     ],
//                                                                                                   ),
//                                                                                                   Column(
//                                                                                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                                                                                     children: <Widget>[
//                                                                                                       Text(
//                                                                                                         '\$ ' + '${fetchNewCarSnapshot.data!.cars![index].price}',
//                                                                                                         style: Theme.of(context).textTheme.headline3!.copyWith(color: Color(0xff353B50)),
//                                                                                                       ),
//                                                                                                       Row(
//                                                                                                         mainAxisSize: MainAxisSize.min,
//                                                                                                         children: fetchNewCarSnapshot.data!.cars![index].rating != 0
//                                                                                                             ? List.generate(5, (indexIcon) {
//                                                                                                                 return Icon(
//                                                                                                                   Icons.star,
//                                                                                                                   size: 13,
//                                                                                                                   color: indexIcon < fetchNewCarSnapshot.data!.cars![index].rating!.round() ? Color(0xff5BC0EB).withOpacity(0.8) : Colors.grey,
//                                                                                                                 );
//                                                                                                               })
//                                                                                                             : List.generate(5, (index) {
//                                                                                                                 return Icon(
//                                                                                                                   Icons.star,
//                                                                                                                   size: 0,
//                                                                                                                   color: Colors.white,
//                                                                                                                 );
//                                                                                                               }),
//                                                                                                       ),
//                                                                                                     ],
//                                                                                                   ),
//                                                                                                 ],
//                                                                                               ),
//                                                                                             ],
//                                                                                           ),
//                                                                                         ),
//                                                                                       );
//                                                                                     },
//                                                                                   );
//                                                                                 }),
//                                                                           )
//                                                                         : Padding(
//                                                                             padding:
//                                                                                 const EdgeInsets.only(left: 20),
//                                                                             child:
//                                                                                 Text(
//                                                                               'Currently no vehicle is listed in your location.',
//                                                                               style: TextStyle(fontFamily: 'Urbanist', fontSize: 16, fontWeight: FontWeight.normal),
//                                                                             ),
//                                                                           ),
//                                                                     SizedBox(
//                                                                         height:
//                                                                             30),
//                                                                   ],
//                                                                 )
//                                                               : Container();
// //
//                                                         }),
//
//
//
//
//                                                     StreamBuilder<
//                                                             FetchPopularCarResponse>(
//                                                         stream: discoverRentBloc
//                                                             .popularCarData,
//                                                         builder: (context,
//                                                             popularCarDataSnapshot) {
//                                                           return popularCarDataSnapshot
//                                                                   .hasData
//                                                               ? Column(
//                                                                   crossAxisAlignment:
//                                                                       CrossAxisAlignment
//                                                                           .start,
//                                                                   children: <
//                                                                       Widget>[
//                                                                     Text(
//                                                                       'Popular this month',
//                                                                       style: TextStyle(
//                                                                           fontFamily: 'Urbanist',
//                                                                           fontSize:
//                                                                               24,
//                                                                           fontWeight:
//                                                                               FontWeight.bold),
//                                                                     ),
//                                                                     SizedBox(
//                                                                         height:
//                                                                             15),
//                                                                     popularCarDataSnapshot.data!.cars !=
//                                                                                 null &&
//                                                                             popularCarDataSnapshot.data!.cars!.length >
//                                                                                 0
//                                                                         ? Container(
//                                                                             height:
//                                                                                 276,
//                                                                             child: StreamBuilder<String>(
//                                                                                 stream: discoverRentBloc.userId,
//                                                                                 builder: (context, userIdSnapshot) {
//                                                                                   return ListView.builder(
//                                                                                     scrollDirection: Axis.vertical,
//                                                                                     shrinkWrap: false,
//                                                                                     itemCount: popularCarDataSnapshot.data!.cars!.length,
//                                                                                     itemBuilder: (context, index) {
//                                                                                       return GestureDetector(
//                                                                                         onTap: progressIndicatorSnapshot.data == 1
//                                                                                             ? null
//                                                                                             : () async {
//                                                                                                 if (progressIndicatorSnapshot.data == 0) {
//                                                                                                   discoverRentBloc.changedProgressIndicator.call(1);
//                                                                                                   if (userIdSnapshot.hasData == true && userIdSnapshot.data != '') {
//                                                                                                     await addCarToViewedList(popularCarDataSnapshot.data!.cars![index].id!, userIdSnapshot.data!);
//                                                                                                     discoverRentBloc.callFetchOnlyRecentlyViewed();
//                                                                                                   }
//                                                                                                   Navigator.pushNamed(context, '/car_details_non_search', arguments: popularCarDataSnapshot.data!.cars![index].id).then((value) {
//                                                                                                     if (loggedInSnapshot.data == false && value == null) {
//                                                                                                       Navigator.pushReplacementNamed(context, '/discover_tab');
//                                                                                                     }
//                                                                                                     discoverRentBloc.changedProgressIndicator.call(0);
//                                                                                                   });
//                                                                                                 }
//                                                                                               },
//                                                                                         child: Container(
//                                                                                           margin: EdgeInsets.only(right: 16),
//                                                                                           width: MediaQuery.of(context).size.width * .85,
//                                                                                           height: 276,
//                                                                                           child: Column(
//                                                                                             children: <Widget>[
//                                                                                               */
// /*ClipRRect(
//                                                                                                 borderRadius: BorderRadius.circular(12),
//                                                                                                 child: Image(
//                                                                                                   height: 200,
//                                                                                                   width: MediaQuery.of(context).size.width * .90,
//                                                                                                   image: popularCarDataSnapshot.data!.cars![index].imageId == "" ? AssetImage('images/car-placeholder.png') : NetworkImage('$storageServerUrl/${popularCarDataSnapshot.data!.cars![index].imageId}'),
//                                                                                                   fit: BoxFit.cover,
//                                                                                                 ),
//                                                                                               ),*//*
//
//                                                                                               ClipRRect(
//                                                                                                 borderRadius: BorderRadius.circular(12),
//                                                                                                 child: CachedNetworkImage(
//                                                                                                   fit: BoxFit.cover,
//                                                                                                   height: 200,
//                                                                                                   width: MediaQuery.of(context).size.width * .90,
//                                                                                                   imageUrl: "$storageServerUrl/${popularCarDataSnapshot.data!.cars![index].imageId}",
//                                                                                                   placeholder: (context, url) => SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 220,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 12.0, right: 12),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           SizedBox(
//                             height: 20,
//                             width: MediaQuery.of(context).size.width / 3,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 250,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16.0, right: 16),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 8,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             height: 14,
//                             width: MediaQuery.of(context).size.width / 2,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 250,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16.0, right: 16),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             height: 14,
//                             width: MediaQuery.of(context).size.width / 2,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                                                                                                   errorWidget: (context, url, error) => Image.asset(
//                                                                                                     'images/car-placeholder.png',
//                                                                                                     fit: BoxFit.cover,
//                                                                                                   ),
//                                                                                                 ),
//                                                                                               ),
//                                                                                               SizedBox(height: 8),
//                                                                                               Row(
//                                                                                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                                                                                 children: <Widget>[
//                                                                                                   Column(
//                                                                                                     mainAxisAlignment: MainAxisAlignment.start,
//                                                                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                                                                     children: <Widget>[
//                                                                                                       Container(
//                                                                                                         width: deviceWidth * 0.62,
//                                                                                                         child: Text(
//                                                                                                           popularCarDataSnapshot.data!.cars![index].title != ' ' ? popularCarDataSnapshot.data!.cars![index].title! : 'Car title',
//                                                                                                           overflow: TextOverflow.ellipsis,
//                                                                                                           style: TextStyle(
//                                                                                                             fontFamily: 'Urbanist',
//                                                                                                             fontWeight: FontWeight.w600,
//                                                                                                           )
//                                                                                                         ),
//                                                                                                       ),
//                                                                                                       Row(
//                                                                                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                                         children: <Widget>[
//                                                                                                           Text(
//                                                                                                             popularCarDataSnapshot.data!.cars![index].year != '' ? popularCarDataSnapshot.data!.cars![index].year! : '',
//                                                                                                             style: TextStyle(
//                                                                                                               fontSize: 12,
//                                                                                                               fontWeight: FontWeight.normal,
//                                                                                                               fontFamily: 'Urbanist',
//                                                                                                               color: Color(0xff353B50),
//                                                                                                             ),
//                                                                                                           ),
//                                                                                                           // Text('.'),
//                                                                                                           SizedBox(
//                                                                                                             width: 4,
//                                                                                                           ),
//                                                                                                           popularCarDataSnapshot.data!.cars![index] != null && popularCarDataSnapshot.data!.cars![index].numberOfTrips != null && popularCarDataSnapshot.data!.cars![index].numberOfTrips != '0'
//                                                                                                               ? Row(
//                                                                                                                   children: [
//                                                                                                                     Container(
//                                                                                                                       width: 2,
//                                                                                                                       height: 2,
//                                                                                                                       decoration: new BoxDecoration(
//                                                                                                                         color: Color(0xff353B50),
//                                                                                                                         shape: BoxShape.circle,
//                                                                                                                       ),
//                                                                                                                     ),
//                                                                                                                     SizedBox(
//                                                                                                                       width: 4,
//                                                                                                                     ),
//                                                                                                                     popularCarDataSnapshot.data!.cars![index] != null && popularCarDataSnapshot.data!.cars![index].numberOfTrips != null && popularCarDataSnapshot.data!.cars![index].numberOfTrips != '0'
//                                                                                                                         ? Text(
//                                                                                                                             popularCarDataSnapshot.data!.cars![index].numberOfTrips != '1' ? '${popularCarDataSnapshot.data!.cars![index].numberOfTrips} trips' : '${popularCarDataSnapshot.data!.cars![index].numberOfTrips} trip',
//                                                                                                                             style: TextStyle(
//                                                                                                                               fontSize: 12,
//                                                                                                                               fontWeight: FontWeight.normal,
//                                                                                                                               fontFamily: 'Urbanist',
//                                                                                                                               color: Color(0xff353B50),
//                                                                                                                             ),
//                                                                                                                           )
//                                                                                                                         : Text(''),
//                                                                                                                   ],
//                                                                                                                 )
//                                                                                                               : Container(),
//                                                                                                         ],
//                                                                                                       ),
//                                                                                                     ],
//                                                                                                   ),
//                                                                                                   Column(
//                                                                                                     crossAxisAlignment: CrossAxisAlignment.end,
//                                                                                                     children: <Widget>[
//                                                                                                       Text(
//                                                                                                         '\$ ' + popularCarDataSnapshot.data!.cars![index].price!,
//                                                                                                         style: Theme.of(context).textTheme.headline3!.copyWith(color: Color(0xff353B50)),
//                                                                                                       ),
//                                                                                                       Row(
//                                                                                                         mainAxisSize: MainAxisSize.min,
//                                                                                                         children: popularCarDataSnapshot.data!.cars![index].rating != 0
//                                                                                                             ? List.generate(5, (indexIcon) {
//                                                                                                                 return Icon(
//                                                                                                                   Icons.star,
//                                                                                                                   size: 13,
//                                                                                                                   color: indexIcon < popularCarDataSnapshot.data!.cars![index].rating!.round() ? Color(0xff5BC0EB).withOpacity(0.8) : Colors.grey,
//                                                                                                                 );
//                                                                                                               })
//                                                                                                             : List.generate(5, (index) {
//                                                                                                                 return Icon(
//                                                                                                                   Icons.star,
//                                                                                                                   size: 0,
//                                                                                                                   color: Colors.white,
//                                                                                                                 );
//                                                                                                               }),
//                                                                                                       ),
//                                                                                                     ],
//                                                                                                   ),
//                                                                                                 ],
//                                                                                               ),
//                                                                                             ],
//                                                                                           ),
//                                                                                         ),
//                                                                                       );
//                                                                                     },
//                                                                                   );
//                                                                                 }),
//                                                                           )
//                                                                         : Padding(
//                                                                             padding:
//                                                                                 const EdgeInsets.only(left: 20),
//                                                                             child:
//                                                                                 Text(
//                                                                               'Currently no vehicle found.',
//                                                                               style: TextStyle(fontFamily: 'Urbanist', fontSize: 16, fontWeight: FontWeight.bold),
//                                                                             ),
//                                                                           ),
//                                                                   ],
//                                                                 )
//                                                               : Container();
//                                                         }),
//                                                   ],
//                                                 )
//                                               : Center(
//                                                   child: Container(
//                                                     child: Column(
//                                                       crossAxisAlignment:
//                                                           CrossAxisAlignment
//                                                               .center,
//                                                       children: <Widget>[
//                                                         Text(
//                                                           'Permission denied. Please give permission to see list of vehicles in your area.',
//                                                           style: TextStyle(
//                                                               fontFamily:
//                                                                   'Roboto',
//                                                               fontSize: 16,
//                                                               fontWeight:
//                                                                   FontWeight
//                                                                       .w500),
//                                                         ),
//                                                         ElevatedButton(style: ElevatedButton.styleFrom(
//                                                           elevation: 0.0,
//                                                           backgroundColor:
//                                                               Color(0xFFF2F2F2),
//                                                           padding:
//                                                               EdgeInsets.all(
//                                                                   12.0),
//                                                           shape: RoundedRectangleBorder(
//                                                               borderRadius:
//                                                                   BorderRadius
//                                                                       .circular(
//                                                                           8.0)),),
//                                                           onPressed: () async {
//                                                             location_handler
//                                                                     .PermissionStatus
//                                                                 permissionStatus =
//                                                                 await locationUtil
//                                                                     .checkPermission();
//                                                             if (permissionStatus ==
//                                                                 location_handler
//                                                                     .PermissionStatus
//                                                                     .permanentlyDenied) {
//                                                               showDialog(
//                                                                 context:
//                                                                     context,
//                                                                 builder:
//                                                                     (context) {
//                                                                   return CupertinoAlertDialog(
//                                                                     title: Text(
//                                                                         'Location Permission'),
//                                                                     content: Text(
//                                                                         'This app needs location access'),
//                                                                     actions: [
//                                                                       CupertinoDialogAction(
//                                                                         child: Text(
//                                                                             'Deny'),
//                                                                         onPressed:
//                                                                             () =>
//                                                                                 Navigator.pop(context),
//                                                                       ),
//                                                                       CupertinoDialogAction(
//                                                                         child: Text(
//                                                                             'Settings'),
//                                                                         onPressed:
//                                                                             () async {
//                                                                           location_handler
//                                                                               .openAppSettings()
//                                                                               .whenComplete(() {
//                                                                             return Navigator.pop(context);
//                                                                           });
//                                                                         },
//                                                                       ),
//                                                                     ],
//                                                                   );
//                                                                 },
//                                                               );
//                                                             } else if (Platform
//                                                                     .isIOS &&
//                                                                 permissionStatus ==
//                                                                     location_handler
//                                                                         .PermissionStatus
//                                                                         .denied) {
//                                                               showDialog(
//                                                                 context:
//                                                                     context,
//                                                                 builder:
//                                                                     (context) {
//                                                                   return CupertinoAlertDialog(
//                                                                     title: Text(
//                                                                         'Location Permission'),
//                                                                     content: Text(
//                                                                         'This app needs location access'),
//                                                                     actions: [
//                                                                       CupertinoDialogAction(
//                                                                         child: Text(
//                                                                             'Deny'),
//                                                                         onPressed:
//                                                                             () =>
//                                                                                 Navigator.pop(context),
//                                                                       ),
//                                                                       CupertinoDialogAction(
//                                                                         child: Text(
//                                                                             'Settings'),
//                                                                         onPressed:
//                                                                             () async {
//                                                                           location_handler
//                                                                               .openAppSettings()
//                                                                               .whenComplete(() {
//                                                                             return Navigator.pop(context);
//                                                                           });
//                                                                         },
//                                                                       ),
//                                                                     ],
//                                                                   );
//                                                                 },
//                                                               );
//                                                             } else {
//                                                               discoverRentBloc
//                                                                   .callFetchNewCars(
//                                                                       context);
//                                                             }
//                                                           },
//                                                           child: Text(
//                                                             'Click for permission',
//                                                             style: TextStyle(
//                                                                 fontFamily:
//                                                                     'Urbanist',
//                                                                 fontSize: 16,
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .normal),
//                                                           ),
//                                                         )
//                                                       ],
//                                                     ),
//                                                   ),
//                                                 )
//                                           : Container();
//                                     }),
//
//
//
//
//                                 loggedInSnapshot.hasData &&
//                                         loggedInSnapshot.data!
//                                     ? StreamBuilder<
//                                             FetchRecentlyViewedCarResponse>(
//                                         stream:
//                                             discoverRentBloc.recentlyViewedCar,
//                                         builder:
//                                             (context, recentViewedCarSnapshot) {
//                                           return recentViewedCarSnapshot
//                                                       .hasData &&
//                                                   recentViewedCarSnapshot
//                                                           .data !=
//                                                       null &&
//                                                   recentViewedCarSnapshot
//                                                           .data!.cars!.length >
//                                                       0
//                                               ? Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: <Widget>[
//                                                     SizedBox(height: 20),
//                                                     Text(
//                                                       'Recently viewed',
//                                                       style: TextStyle(
//                                                           fontFamily: 'Urbanist',
//                                                           fontSize: 24,
//                                                           fontWeight:
//                                                               FontWeight.bold),
//                                                     ),
//                                                     SizedBox(height: 15),
//                                                     Container(
//                                                       height: 176,
//                                                       child: StreamBuilder<
//                                                               String>(
//                                                           stream:
//                                                               discoverRentBloc
//                                                                   .userId,
//                                                           builder: (context,
//                                                               userIdSnapshot) {
//                                                             return ListView
//                                                                 .builder(
//                                                               scrollDirection:
//                                                                   Axis.horizontal,
//                                                               shrinkWrap: false,
//                                                               itemCount:
//                                                                   recentViewedCarSnapshot
//                                                                       .data!
//                                                                       .cars!
//                                                                       .length,
//                                                               itemBuilder:
//                                                                   (context,
//                                                                       index) {
//                                                                 return GestureDetector(
//                                                                   onTap: progressIndicatorSnapshot
//                                                                               .data ==
//                                                                           1
//                                                                       ? null
//                                                                       : () async {
//                                                                           if (progressIndicatorSnapshot.data ==
//                                                                               0) {
//                                                                             discoverRentBloc.changedProgressIndicator.call(1);
//                                                                             if (userIdSnapshot.hasData == true &&
//                                                                                 userIdSnapshot.data != '') {
//                                                                               await addCarToViewedList(recentViewedCarSnapshot.data!.cars![index].id!, userIdSnapshot.data!);
//                                                                               discoverRentBloc.callFetchOnlyRecentlyViewed();
//                                                                             }
//                                                                             Navigator.pushNamed(context, '/car_details_non_search', arguments: recentViewedCarSnapshot.data!.cars![index].id).then((value) {
//                                                                               if (loggedInSnapshot.data == false && value == null) {
//                                                                                 Navigator.pushReplacementNamed(context, '/discover_tab');
//                                                                               }
//                                                                               discoverRentBloc.changedProgressIndicator.call(0);
//                                                                             });
//                                                                           }
//                                                                         },
//                                                                   child:
//                                                                       Container(
//                                                                     margin: EdgeInsets.only(
//                                                                         right:
//                                                                             16),
//                                                                     width: MediaQuery.of(context)
//                                                                             .size
//                                                                             .width *
//                                                                         .50,
//                                                                     height: 176,
//                                                                     child:
//                                                                         Column(
//                                                                       children: <
//                                                                           Widget>[
//                                                                         Stack(
//                                                                           children: <
//                                                                               Widget>[
//                                                                             */
// /*ClipRRect(
//                                                                               borderRadius: BorderRadius.circular(12),
//                                                                               child: Image(
//                                                                                 height: 100,
//                                                                                 width: MediaQuery.of(context).size.width * .50,
//                                                                                 image: recentViewedCarSnapshot.data!.cars![index].imageId == "" ? AssetImage('images/car-placeholder.png') : NetworkImage('$storageServerUrl/${recentViewedCarSnapshot.data!.cars![index].imageId}'),
//                                                                                 fit: BoxFit.cover,
//                                                                               ),
//                                                                             ),*//*
//
//                                                                             ClipRRect(
//                                                                               borderRadius: BorderRadius.circular(12),
//                                                                               child: CachedNetworkImage(
//                                                                                 fit: BoxFit.cover,
//                                                                                 height: 100,
//                                                                                 width: MediaQuery.of(context).size.width * .50,
//                                                                                 imageUrl: "$storageServerUrl/${recentViewedCarSnapshot.data!.cars![index].imageId}",
//                                                                                 placeholder: (context, url) => SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 220,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 12.0, right: 12),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           SizedBox(
//                             height: 20,
//                             width: MediaQuery.of(context).size.width / 3,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 250,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16.0, right: 16),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 8,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             height: 14,
//                             width: MediaQuery.of(context).size.width / 2,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 250,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16.0, right: 16),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             height: 14,
//                             width: MediaQuery.of(context).size.width / 2,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                                                                                 errorWidget: (context, url, error) => Image.asset(
//                                                                                   'images/car-placeholder.png',
//                                                                                   fit: BoxFit.cover,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                             Positioned(
//                                                                               right: 15,
//                                                                               bottom: 15,
//                                                                               child: Container(
//                                                                                 height: 20,
//                                                                                 width: 80,
//                                                                                 decoration: BoxDecoration(color: Color(0xffFFFFFF), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(4)),
//                                                                                 child: Align(
//                                                                                   alignment: Alignment.center,
//                                                                                   child: Text(
//                                                                                     '\$ ' + recentViewedCarSnapshot.data!.cars![index].price!,
//                                                                                     style: TextStyle(
//                                                                                       color: Color(0xff353B50),
//                                                                                       fontFamily: 'Urbanist',
//                                                                                       fontWeight: FontWeight.bold,
//                                                                                       fontSize: 10,
//                                                                                       letterSpacing: 0.2,
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                               ),
//                                                                             )
//                                                                           ],
//                                                                         ), //
//                                                                         SizedBox(
//                                                                             height:
//                                                                                 8),
//                                                                         Expanded(
//                                                                           child:
//                                                                               Column(
//                                                                             crossAxisAlignment:
//                                                                                 CrossAxisAlignment.start,
//                                                                             children: [
//                                                                               Text(
//                                                                                 recentViewedCarSnapshot.data!.cars![index].title != '' ? recentViewedCarSnapshot.data!.cars![index].title! : 'Car title',
//                                                                                 overflow: TextOverflow.ellipsis,
//                                                                                 style: TextStyle(
//                                                                                   fontFamily: 'Urbanist',
//                                                                                   fontWeight: FontWeight.w600
//                                                                                 )
//                                                                               ),
//                                                                               Row(
//                                                                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                 children: <Widget>[
//                                                                                   Text(
//                                                                                     recentViewedCarSnapshot.data!.cars![index].year != '' ? recentViewedCarSnapshot.data!.cars![index].year! : '',
//                                                                                     style: TextStyle(
//                                                                                       fontSize: 12,
//                                                                                       fontWeight: FontWeight.normal,
//                                                                                       fontFamily: 'Urbanist',
//                                                                                       color: Color(0xff353B50),
//                                                                                     ),
//                                                                                   ),
//                                                                                   // Text('.'),
//                                                                                   SizedBox(
//                                                                                     width: 4,
//                                                                                   ),
//
//                                                                                   recentViewedCarSnapshot.data!.cars![index] != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != '0'
//                                                                                       ? Row(
//                                                                                           children: [
//                                                                                             Container(
//                                                                                               width: 2,
//                                                                                               height: 2,
//                                                                                               decoration: new BoxDecoration(
//                                                                                                 color: Color(0xff353B50),
//                                                                                                 shape: BoxShape.circle,
//                                                                                               ),
//                                                                                             ),
//                                                                                             SizedBox(
//                                                                                               width: 4,
//                                                                                             ),
//                                                                                             recentViewedCarSnapshot.data!.cars![index] != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != null && recentViewedCarSnapshot.data!.cars![index].numberOfTrips != '0'
//                                                                                                 ? Text(
//                                                                                                     recentViewedCarSnapshot.data!.cars![index].numberOfTrips != '1' ? '${recentViewedCarSnapshot.data!.cars![index].numberOfTrips} trips' : '${recentViewedCarSnapshot.data!.cars![index].numberOfTrips} trip',
//                                                                                                     style: TextStyle(
//                                                                                                       fontSize: 12,
//                                                                                                       fontWeight: FontWeight.normal,
//                                                                                                       fontFamily: 'Urbanist',
//                                                                                                       color: Color(0xff353B50),
//                                                                                                     ),
//                                                                                                   )
//                                                                                                 : Text(''),
//                                                                                           ],
//                                                                                         )
//                                                                                       : Container(),
//                                                                                 ],
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 );
//                                                               },
//                                                             );
//                                                           }),
//                                                     ),
//                                                   ],
//                                                 )
//                                               : Container();
//                                         })
//                                     : new Container(),
//
//
//
//
//
//
//                                 loggedInSnapshot.hasData &&
//                                         loggedInSnapshot.data!
//                                     ? StreamBuilder<
//                                             FetchPreviouslyBookedCarResponse>(
//                                         stream: discoverRentBloc
//                                             .previouslyBookedCar,
//                                         builder: (context,
//                                             previouslyBookedCarSnapshot) {
//                                           return previouslyBookedCarSnapshot
//                                                       .hasData &&
//                                                   previouslyBookedCarSnapshot
//                                                           .data!.cars!.length >
//                                                       0
//                                               ? Column(
//                                                   crossAxisAlignment:
//                                                       CrossAxisAlignment.start,
//                                                   children: <Widget>[
//                                                     SizedBox(height: 15),
//                                                     Text(
//                                                       'Previously booked',
//                                                       style: TextStyle(
//                                                           fontFamily: 'Urbanist',
//                                                           fontSize: 24,
//                                                           fontWeight:
//                                                               FontWeight.bold),
//                                                     ),
//                                                     SizedBox(height: 15),
//                                                     Container(
//                                                       height: 176,
//                                                       child: StreamBuilder<
//                                                               String>(
//                                                           stream:
//                                                               discoverRentBloc
//                                                                   .userId,
//                                                           builder: (context,
//                                                               userIdSnapshot) {
//                                                             return ListView
//                                                                 .builder(
//                                                               scrollDirection:
//                                                                   Axis.horizontal,
//                                                               shrinkWrap: false,
//                                                               itemCount:
//                                                                   previouslyBookedCarSnapshot
//                                                                       .data!
//                                                                       .cars!
//                                                                       .length,
//                                                               itemBuilder:
//                                                                   (context,
//                                                                       index) {
//                                                                 return GestureDetector(
//                                                                   onTap: progressIndicatorSnapshot
//                                                                               .data ==
//                                                                           1
//                                                                       ? null
//                                                                       : () async {
//                                                                           if (progressIndicatorSnapshot.data ==
//                                                                               0) {
//                                                                             discoverRentBloc.changedProgressIndicator.call(1);
//                                                                             if (userIdSnapshot.hasData == true &&
//                                                                                 userIdSnapshot.data != '') {
//                                                                               await addCarToViewedList(previouslyBookedCarSnapshot.data!.cars![index].id!, userIdSnapshot.data!);
//                                                                               discoverRentBloc.callFetchOnlyRecentlyViewed();
//                                                                             }
//                                                                             Navigator.pushNamed(context, '/car_details_non_search', arguments: previouslyBookedCarSnapshot.data!.cars![index].id).then((value) {
//                                                                               if (loggedInSnapshot.data == false && value == null) {
//                                                                                 Navigator.pushReplacementNamed(context, '/discover_tab');
//                                                                               }
//                                                                               discoverRentBloc.changedProgressIndicator.call(0);
//                                                                             });
//                                                                           }
//                                                                         },
//                                                                   child:
//                                                                       Container(
//                                                                     margin: EdgeInsets.only(
//                                                                         right:
//                                                                             16),
//                                                                     width: MediaQuery.of(context)
//                                                                             .size
//                                                                             .width *
//                                                                         .50,
//                                                                     height: 176,
//                                                                     child:
//                                                                         Column(
//                                                                       children: <
//                                                                           Widget>[
//                                                                         Stack(
//                                                                           children: <
//                                                                               Widget>[
//                                                                             */
// /*ClipRRect(
//                                                                               borderRadius: BorderRadius.circular(12),
//                                                                               child: Image(
//                                                                                 height: 100,
//                                                                                 width: MediaQuery.of(context).size.width * .50,
//                                                                                 image: previouslyBookedCarSnapshot.data!.cars![index].imageId == "" ? AssetImage('images/car-placeholder.png') : NetworkImage('$storageServerUrl/${previouslyBookedCarSnapshot.data!.cars![index].imageId}'),
//                                                                                 fit: BoxFit.cover,
//                                                                               ),
//                                                                             ),*//*
//
//                                                                             ClipRRect(
//                                                                               borderRadius: BorderRadius.circular(12),
//                                                                               child: CachedNetworkImage(
//                                                                                 fit: BoxFit.cover,
//                                                                                 height: 100,
//                                                                                 width: MediaQuery.of(context).size.width * .50,
//                                                                                 imageUrl: "$storageServerUrl/${previouslyBookedCarSnapshot.data!.cars![index].imageId}",
//                                                                                 placeholder: (context, url) => SingleChildScrollView(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 220,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 12.0, right: 12),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 15,
//                       ),
//                       SizedBox(
//                         height: 5,
//                       ),
//                       Row(
//                         children: [
//                           SizedBox(
//                             height: 20,
//                             width: MediaQuery.of(context).size.width / 3,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 250,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16.0, right: 16),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 8,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             height: 14,
//                             width: MediaQuery.of(context).size.width / 2,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       SizedBox(
//                         height: 250,
//                         width: MediaQuery.of(context).size.width,
//                         child: Shimmer.fromColors(
//                             baseColor: Colors.grey.shade300,
//                             highlightColor: Colors.grey.shade100,
//                             child: Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 16.0, right: 16),
//                               child: Container(
//                                 decoration: BoxDecoration(
//                                     color: Colors.grey[300],
//                                     borderRadius: BorderRadius.circular(10)),
//                               ),
//                             )),
//                       ),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           SizedBox(
//                             height: 14,
//                             width: MediaQuery.of(context).size.width / 2,
//                             child: Shimmer.fromColors(
//                                 baseColor: Colors.grey.shade300,
//           highlightColor: Colors.grey.shade100,
//                                 child: Padding(
//                                   padding: const EdgeInsets.only(
//                                       left: 16.0, right: 16),
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                         color: Colors.grey[300],
//                                         borderRadius:
//                                             BorderRadius.circular(10)),
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                                                                                 errorWidget: (context, url, error) => Image.asset(
//                                                                                   'images/car-placeholder.png',
//                                                                                   fit: BoxFit.cover,
//                                                                                 ),
//                                                                               ),
//                                                                             ),
//                                                                             Positioned(
//                                                                               right: 15,
//                                                                               bottom: 15,
//                                                                               child: Container(
//                                                                                 height: 20,
//                                                                                 width: 80,
//                                                                                 decoration: BoxDecoration(color: Color(0xffFFFFFF), shape: BoxShape.rectangle, borderRadius: BorderRadius.circular(4)),
//                                                                                 child: Align(
//                                                                                   alignment: Alignment.center,
//                                                                                   child: Text(
//                                                                                     '\$ ' + previouslyBookedCarSnapshot.data!.cars![index].price!,
//                                                                                     style: TextStyle(
//                                                                                       color: Color(0xff353B50),
//                                                                                       fontFamily: 'Urbanist',
//                                                                                       fontWeight: FontWeight.bold,
//                                                                                       fontSize: 10,
//                                                                                       letterSpacing: 0.2,
//                                                                                     ),
//                                                                                   ),
//                                                                                 ),
//                                                                               ),
//                                                                             )
//                                                                           ],
//                                                                         ),
//                                                                         SizedBox(
//                                                                             height:
//                                                                                 8),
//                                                                         Expanded(
//                                                                           child:
//                                                                               Column(
//                                                                             crossAxisAlignment:
//                                                                                 CrossAxisAlignment.start,
//                                                                             children: [
//                                                                               Text(
//                                                                                 previouslyBookedCarSnapshot.data!.cars![index].title != '' ? previouslyBookedCarSnapshot.data!.cars![index].title! : 'Car title',
//                                                                                 overflow: TextOverflow.ellipsis,
//                                                                                   style: TextStyle(
//                                                                                       fontFamily: 'Urbanist',
//                                                                                       fontWeight: FontWeight.w600
//                                                                                   )
//                                                                               ),
//                                                                               Row(
//                                                                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                                                                 children: <Widget>[
//                                                                                   Text(
//                                                                                     previouslyBookedCarSnapshot.data!.cars![index].year != '' ? previouslyBookedCarSnapshot.data!.cars![index].year! : '',
//                                                                                     style: TextStyle(
//                                                                                       fontSize: 12,
//                                                                                       fontWeight: FontWeight.normal,
//                                                                                       fontFamily: 'Urbanist',
//                                                                                       color: Color(0xff353B50),
//                                                                                     ),
//                                                                                   ),
//                                                                                   // Text('.'),
//                                                                                   SizedBox(
//                                                                                     width: 4,
//                                                                                   ),
//                                                                                   previouslyBookedCarSnapshot.data!.cars![index] != null && previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips != null && previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips != '0'
//                                                                                       ? Row(
//                                                                                           children: [
//                                                                                             Container(
//                                                                                               width: 2,
//                                                                                               height: 2,
//                                                                                               decoration: new BoxDecoration(
//                                                                                                 color: Color(0xff353B50),
//                                                                                                 shape: BoxShape.circle,
//                                                                                               ),
//                                                                                             ),
//                                                                                             SizedBox(
//                                                                                               width: 4,
//                                                                                             ),
//                                                                                             previouslyBookedCarSnapshot.data!.cars![index] != null && previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips != null && previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips != '0'
//                                                                                                 ? Text(
//                                                                                                     previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips != '1' ? '${previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips} trips' : '${previouslyBookedCarSnapshot.data!.cars![index].numberOfTrips} trip',
//                                                                                                     style: TextStyle(
//                                                                                                       fontSize: 12,
//                                                                                                       fontWeight: FontWeight.normal,
//                                                                                                       fontFamily: 'Urbanist',
//                                                                                                       color: Color(0xff353B50),
//                                                                                                     ),
//                                                                                                   )
//                                                                                                 : Text(''),
//                                                                                           ],
//                                                                                         )
//                                                                                       : Container(),
//                                                                                 ],
//                                                                               ),
//                                                                             ],
//                                                                           ),
//                                                                         ),
//                                                                       ],
//                                                                     ),
//                                                                   ),
//                                                                 );
//                                                               },
//                                                             );
//                                                           }),
//                                                     ),
//                                                   ],
//                                                 )
//                                               : Container();
//                                         })
//
//
//
//
//
//
//                                     : new Container(),
//                               ],
//                             ),
//                           );
//                         });
//                   })
//               : Center(
//                   child: CircularProgressIndicator(),
//                 );
//         });
//   }
// }
// */
