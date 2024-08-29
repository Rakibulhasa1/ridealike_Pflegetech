///Cluster map///
import 'dart:async';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:widget_to_image/widget_to_image.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/discover/bloc/discover_car_map_bloc.dart';
import 'package:ridealike/pages/discover/response_model/fetchNewCarResponse.dart';
import 'package:ridealike/utils/cluster_utils.dart';
import 'package:ridealike/widgets/map_marker.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../../../utils/app_events/app_events_utils.dart';
import '../../../widgets/bubble_widget.dart';

final discoverCarMapBloc = DiscoverCarMapBloc();


class DiscoverCarMap extends StatefulWidget {
  @override
  _DiscoverCarMapState createState() => _DiscoverCarMapState();
}

class _DiscoverCarMapState extends State<DiscoverCarMap> {
  GoogleMapController? mapController;
  Completer<GoogleMapController> _mapController = Completer();

  Set<Marker> _markers = new Set();
  CameraPosition? _initialCamera;
  BitmapDescriptor? mapMarkers;

  bool showCarDetails = false;
  int carIndex = 0;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Discover Car Map"});
    setCustomMarker();
    discoverCarMapBloc.changedNewLocation.call(LatLng(40.730610, -73.935242));
    discoverCarMapBloc.changedLocation.call(LatLng(40.730610, -73.935242));
    discoverCarMapBloc.changedShowDetails.call(0);
    _initialCamera = CameraPosition(
      target: LatLng(40.730610, -73.935242),
      zoom: ClusterUtils.currentZoom,
    );
    Future.delayed(Duration.zero, () async {
      FetchNewCarResponse _data = ModalRoute.of(context)!.settings.arguments as FetchNewCarResponse;
      if (_data == null) {
        _data = FetchNewCarResponse();
        _data.cars = [];
      }
      discoverCarMapBloc.changedNewCar.call(_data);
      if (_data != null) {
        discoverCarMapBloc.changedLocation.call(LatLng(
            _data.latlng!.latitude!.toDouble(),
            _data.latlng!.longitude!.toDouble()));
        discoverCarMapBloc.changedNewLocation.call(LatLng(
            _data.latlng!.latitude!.toDouble(),
            _data.latlng!.longitude!.toDouble()));
        _initialCamera = CameraPosition(
          target: LatLng(_data.latlng!.latitude!.toDouble(),
              _data.latlng!.longitude!.toDouble()),
          zoom: ClusterUtils.currentZoom,
        );
      }
    });

    // set initial zoom level
    ClusterUtils.currentZoom = 11.0;
  }

  void setCustomMarker() async {
    mapMarkers = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(10, 10)),
      "icons/output-onlinepngtools-4.png",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<FetchNewCarResponse>(
          stream: discoverCarMapBloc.newCarData,
          builder: (context, snapshot) {
            return snapshot.hasData
                ? Stack(
              children: <Widget>[
                GoogleMap(
                  zoomControlsEnabled: false,
                  zoomGesturesEnabled: true,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  initialCameraPosition: _initialCamera!,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController.complete(controller);
                    myMarker(snapshot);
                  },
                  onCameraMove: (newPosition) async {
                    // print(newPosition);
                    discoverCarMapBloc.changedShowSearchHereButton
                        .call(true);
                    discoverCarMapBloc.changedNewLocation
                        .call(newPosition.target);

                    //update markers
                    updateMarkers(snapshot, newPosition.zoom);
                  },
                  onTap: (latLong) {
                    discoverCarMapBloc.changedLocation.call(latLong);

                    closeSingleCarCard();
                  },
                  markers: _markers,
                ),
                Positioned(
                  top: 25,
                  right: 15,
                  left: 15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ClipOval(
                          child: Container(
                            color: Color(0xffFFFFFF), // button color
                            child: GestureDetector(
                              child: SizedBox(
                                width: 50,
                                height: 50,
                                child: Icon(
                                  Icons.clear,
                                  color: Color(0xff371D32),
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                      ),
//                       StreamBuilder<bool>(
//                           stream: discoverCarMapBloc.showSearchHereButton,
//                           builder: (context, showSearchSnapshot) {
//                             return showSearchSnapshot.hasData
//                                 ? FloatingActionButton.extended(
//                               label: SizedBox(
//                                 child: Row(
//                                   mainAxisAlignment:
//                                   MainAxisAlignment.center,
//                                   children: <Widget>[
//                                     Text(
//                                       'Search here',
//                                       style: TextStyle(
//                                         color: Color(0xff371D32),
//                                         fontSize: 14,
//                                         fontFamily: 'Urbanist',
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               heroTag: "btn13",
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.all(
//                                       Radius.circular(16.0))),
//                               backgroundColor: Colors.white,
//                               onPressed: () async {
//                                 print(snapshot.data!.cars.length);
//                                 var res = await discoverCarMapBloc
//                                     .callFetchNewCars();
//                                 print('responseCraDataMap${res}');

//                                 myMarker(snapshot);
//                               },
//                             )
//                                 : new Container();
//                           }),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: ClipOval(
                          child: Container(
                            color: Color(0xffFFFFFF), // button color
                            child: GestureDetector(
                              child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.search,
                                    color: Color(0xff371D32),
                                  )),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, '/search_car_tab');
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // StreamBuilder<dynamic>(
                //   stream: discoverCarMapBloc.showDetails,
                //   builder: (context, showDetailsSnapshot) {
                //     if (showDetailsSnapshot.hasData &&
                //         showDetailsSnapshot.data >= 0 &&
                //         showDetailsSnapshot.data < snapshot.data!.cars!.length) {
                //       var carDetails = snapshot.data!.cars![showDetailsSnapshot.data];
                //       return GestureDetector(
                //         onTap: () {
                //           Navigator.pushNamed(
                //             context, '/car_details_non_search',
                //             arguments: carDetails.id,
                //           );
                //         },
                //         child: Align(
                //           alignment: Alignment.bottomLeft,
                //           child: Container(
                //             width: MediaQuery.of(context).size.width * 0.77,
                //             height: 73,
                //             margin: EdgeInsets.all(10),
                //             decoration: BoxDecoration(
                //               color: Colors.white,
                //               shape: BoxShape.rectangle,
                //               borderRadius: BorderRadius.circular(8.0),
                //             ),
                //             child: Row(
                //               children: <Widget>[
                //                 Expanded(
                //                   child: Column(
                //                     children: [
                //                       SizedBox(
                //                         width: double.maxFinite,
                //                         child: Container(
                //                           height: 73,
                //                           decoration: BoxDecoration(
                //                             color: Colors.white,
                //                             shape: BoxShape.rectangle,
                //                             borderRadius: BorderRadius.circular(8.0),
                //                           ),
                //                           child: Row(
                //                             children: <Widget>[
                //                               Expanded(
                //                                 flex: 3,
                //                                 child: Column(
                //                                   mainAxisAlignment: MainAxisAlignment.center,
                //                                   crossAxisAlignment: CrossAxisAlignment.start,
                //                                   children: <Widget>[
                //                                     ClipRRect(
                //                                       borderRadius: BorderRadius.only(
                //                                         topLeft: Radius.circular(8),
                //                                         bottomLeft: Radius.circular(8),
                //                                       ),
                //                                       child: CachedNetworkImage(
                //                                         imageUrl: carDetails.imageId!.isEmpty
                //                                             ? 'images/car-placeholder.png'
                //                                             : '$storageServerUrl/${carDetails.imageId}',
                //                                         width: 110,
                //                                         height: 73,
                //                                         fit: BoxFit.cover,
                //                                       ),
                //                                     ),
                //                                   ],
                //                                 ),
                //                               ),
                //                               SizedBox(width: 5),
                //                               Expanded(
                //                                 flex: 3,
                //                                 child: Column(
                //                                   mainAxisAlignment: MainAxisAlignment.center,
                //                                   crossAxisAlignment: CrossAxisAlignment.start,
                //                                   children: <Widget>[
                //                                     Text(
                //                                       carDetails.title!,
                //                                       style: TextStyle(
                //                                         fontSize: 16,
                //                                         fontFamily: 'Urbanist',
                //                                         color: Color(0xff371D32),
                //                                       ),
                //                                       overflow: TextOverflow.ellipsis,
                //                                     ),
                //                                     Text(
                //                                       '${carDetails.year} . ${carDetails.numberOfTrips} trip${carDetails.numberOfTrips != '1' ? 's' : ''}',
                //                                       style: TextStyle(
                //                                         fontSize: 14,
                //                                         fontFamily: 'Urbanist',
                //                                         color: Color(0xff353B50),
                //                                       ),
                //                                     ),
                //                                   ],
                //                                 ),
                //                               ),
                //                               Expanded(
                //                                 flex: 3,
                //                                 child: Column(
                //                                   mainAxisAlignment: MainAxisAlignment.center,
                //                                   children: <Widget>[
                //                                     Text(
                //                                       '\$${carDetails.price}',
                //                                       style: TextStyle(
                //                                         color: Color(0xff371D32),
                //                                         fontFamily: 'Urbanist',
                //                                         fontSize: 16,
                //                                       ),
                //                                     ),
                //                                     Row(
                //                                       mainAxisAlignment: MainAxisAlignment.center,
                //                                       children: List.generate(
                //                                         5,
                //                                             (indexIcon) {
                //                                           return Icon(
                //                                             Icons.star,
                //                                             size: 13,
                //                                             color: indexIcon < carDetails.rating!.round()
                //                                                 ? Color(0xff5BC0EB).withOpacity(0.8)
                //                                                 : Colors.grey,
                //                                           );
                //                                         },
                //                                       ),
                //                                     ),
                //                                   ],
                //                                 ),
                //                               ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       );
                //     } else {
                //       return Container(); // or return null
                //     }
                //   },
                // ),

                // StreamBuilder<dynamic>(
                //     stream: discoverCarMapBloc.showDetails,
                //     builder: (context, showDetailsSnapshot) {
                //       return showDetailsSnapshot.hasData
                //           ? GestureDetector(
                //         onTap: () {
                //           //todo
                //           Navigator.pushNamed(
                //               context, '/car_details_non_search',
                //               arguments: snapshot
                //                   .data
                //                   !.cars![showDetailsSnapshot.data]
                //                   .id);
                //         },
                //         child: Align(
                //           alignment: Alignment.bottomLeft,
                //           child: Container(
                //             width:
                //             MediaQuery.of(context).size.width *
                //                 .77,
                //             height: 73,
                //             margin: EdgeInsets.all(10),
                //             decoration: BoxDecoration(
                //                 color: Colors.white,
                //                 shape: BoxShape.rectangle,
                //                 borderRadius:
                //                 BorderRadius.circular(8.0)),
                //             child: Row(
                //               children: <Widget>[
                //                 Expanded(
                //                   child: Column(
                //                     children: [
                //                       SizedBox(
                //                         width: double.maxFinite,
                //                         child: Container(
                //                           height: 73,
                //                           decoration: BoxDecoration(
                //                             color: Colors.white,
                //                             shape:
                //                             BoxShape.rectangle,
                //                             borderRadius:
                //                             BorderRadius
                //                                 .circular(8.0),
                //                           ),
                //                           child: Row(
                //                             children: <Widget>[
                //                               Expanded(
                //                                 flex: 3,
                //                                 child: Column(
                //                                   mainAxisAlignment:
                //                                   MainAxisAlignment
                //                                       .center,
                //                                   crossAxisAlignment:
                //                                   CrossAxisAlignment
                //                                       .start,
                //                                   children: <
                //                                       Widget>[
                //                                     ClipRRect(
                //                                       borderRadius: BorderRadius.only(
                //                                           topLeft: Radius
                //                                               .circular(
                //                                               8),
                //                                           bottomLeft:
                //                                           Radius.circular(
                //                                               8)),
                //                                       child: Image(
                //                                         width: 110,
                //                                         height: 73,
                //                                         image: snapshot.data!.cars![showDetailsSnapshot.data].imageId ==
                //                                             ""
                //                                             ? AssetImage(
                //                                             'images/car-placeholder.png')
                //                                             : NetworkImage(
                //                                             '$storageServerUrl/${snapshot.data!.cars![showDetailsSnapshot.data].imageId}') as ImageProvider,
                //                                         fit: BoxFit
                //                                             .cover,
                //                                       ),
                //                                     ),
                //                                   ],
                //                                 ),
                //                               ),
                //                               // VerticalDivider(),
                //                               SizedBox(width: 5),
                //                               Expanded(
                //                                 flex: 3,
                //                                 child: Column(
                //                                   mainAxisAlignment:
                //                                   MainAxisAlignment
                //                                       .center,
                //                                   crossAxisAlignment:
                //                                   CrossAxisAlignment
                //                                       .start,
                //                                   children: <
                //                                       Widget>[
                //                                     Text(
                //                                       snapshot
                //                                           .data
                //                                           !.cars![showDetailsSnapshot
                //                                           .data]
                //                                           .title!,
                //                                       style:
                //                                       TextStyle(
                //                                         fontSize:
                //                                         16,
                //                                         fontFamily: 'Urbanist',
                //                                         color: Color(
                //                                             0xff371D32),
                //                                       ),
                //                                     ),
                //                                     Text(
                //                                       snapshot.data!.cars![showDetailsSnapshot.data].year! + ' . ' + snapshot.data!.cars![showDetailsSnapshot.data].numberOfTrips! !=
                //                                           '1'
                //                                           ? snapshot
                //                                           .data
                //                                           !.cars![showDetailsSnapshot
                //                                           .data]
                //                                           .numberOfTrips! +
                //                                           'trips'
                //                                           : snapshot
                //                                           .data
                //                                           !.cars![showDetailsSnapshot.data]
                //                                           .numberOfTrips! +
                //                                           'trip',
                //                                       style:
                //                                       TextStyle(
                //                                         fontSize:
                //                                         14,
                //                                         fontFamily:
                //                                         'Urbanist',
                //                                         color: Color(
                //                                             0xff353B50),
                //                                       ),
                //                                     ),
                //                                   ],
                //                                 ),
                //                               ),
                //                               // VerticalDivider(),
                //                               Expanded(
                //                                 flex: 3,
                //                                 child: Column(
                //                                   mainAxisAlignment:
                //                                   MainAxisAlignment
                //                                       .center,
                //                                   children: <
                //                                       Widget>[
                //                                     Text(
                //                                       '\$' +
                //                                           snapshot
                //                                               .data
                //                                               !.cars![
                //                                           showDetailsSnapshot.data]
                //                                               .price!,
                //                                       style: TextStyle(
                //                                           color: Color(
                //                                               0xff371D32),
                //                                           fontFamily:
                //                                           'Roboto',
                //                                           fontSize:
                //                                           16),
                //                                     ),
                //                                     Row(
                //                                       mainAxisAlignment:
                //                                       MainAxisAlignment
                //                                           .center,
                //                                       children: snapshot
                //                                           .data
                //                                           !.cars![showDetailsSnapshot
                //                                           .data]
                //                                           .rating !=
                //                                           0
                //                                           ? List.generate(
                //                                           5,
                //                                               (indexIcon) {
                //                                             return Icon(
                //                                               Icons.star,
                //                                               size:
                //                                               13,
                //                                               color: indexIcon < snapshot.data!.cars![showDetailsSnapshot.data].rating!.round()
                //                                                   ? Color(0xff5BC0EB).withOpacity(0.8)
                //                                                   : Colors.grey,
                //                                             );
                //                                           })
                //                                           : List.generate(
                //                                           5,
                //                                               (index) {
                //                                             return Icon(
                //                                               Icons.star,
                //                                               size:
                //                                               0,
                //                                               color:
                //                                               Colors.grey,
                //                                             );
                //                                           }),
                //                                     ),
                //                                   ],
                //                                 ),
                //                               ),
                //                             ],
                //                           ),
                //                         ),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ),
                //       )
                //           : new Container();
                //     }),
                showCarDetails
                    ? GestureDetector(
                  onTap: () {
                    //todo
                    Navigator.pushNamed(
                        context, '/car_details_non_search',
                        arguments: snapshot.data!.cars![carIndex].id);
                  },
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width:
                      MediaQuery.of(context).size.width * .95,
                      height: 73,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8.0)),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.maxFinite,
                                  child: Container(
                                    height: 73,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.rectangle,
                                      borderRadius:
                                      BorderRadius.circular(
                                          8.0),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: <Widget>[
                                              ClipRRect(
                                                borderRadius: BorderRadius.only(
                                                    topLeft: Radius
                                                        .circular(
                                                        8),
                                                    bottomLeft: Radius
                                                        .circular(
                                                        8)),
                                                child: Image(
                                                  width: 110,
                                                  height: 73,
                                                  image: snapshot
                                                      .data
                                                      !.cars![
                                                  carIndex]
                                                      .imageId ==
                                                      ""
                                                      ? AssetImage(
                                                      'images/car-placeholder.png')
                                                      : NetworkImage(
                                                      '$storageServerUrl/${snapshot.data!.cars![carIndex].imageId}') as ImageProvider,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // VerticalDivider(),
                                        SizedBox(width: 5),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            crossAxisAlignment:
                                            CrossAxisAlignment
                                                .start,
                                            children: <Widget>[
                                              Text(
                                                snapshot
                                                    .data
                                                    !.cars![carIndex]
                                                    .title.toString(),
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontFamily:
                                                  'Roboto',
                                                  color: Color(
                                                      0xff371D32),
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    snapshot
                                                        .data
                                                        !.cars![
                                                    carIndex]
                                                        .year!,
                                                    style:
                                                    TextStyle(
                                                      fontSize: 14,
                                                      fontFamily:
                                                      'Urbanist',
                                                      color: Color(
                                                          0xff353B50),
                                                    ),
                                                  ),
                                                  snapshot.data!.cars![
                                                  carIndex] !=
                                                      null &&
                                                      snapshot
                                                          .data
                                                          !.cars![
                                                      carIndex]
                                                          .numberOfTrips !=
                                                          null &&
                                                      snapshot
                                                          .data!
                                                          .cars![carIndex]
                                                          .numberOfTrips !=
                                                          '0'
                                                      ? Row(
                                                    children: [
                                                      Container(
                                                        width:
                                                        2,
                                                        height:
                                                        2,
                                                        decoration:
                                                        new BoxDecoration(
                                                          color:
                                                          Color(0xff353B50),
                                                          shape:
                                                          BoxShape.circle,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width:
                                                        4,
                                                      ),
                                                      Text(
                                                        snapshot.data!.cars![carIndex].numberOfTrips != '1'
                                                            ? '${snapshot.data!.cars![carIndex].numberOfTrips} trips'
                                                            : '${snapshot.data!.cars![carIndex].numberOfTrips} trip',
                                                        style:
                                                        TextStyle(
                                                          fontSize:
                                                          14,
                                                          fontFamily:
                                                          'Urbanist',
                                                          color:
                                                          Color(0xff353B50),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                      : SizedBox(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // VerticalDivider(),
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                            children: <Widget>[
                                              Text(
                                                '\$' +
                                                    snapshot
                                                        .data!
                                                        .cars![
                                                    carIndex]
                                                        .price!,
                                                style: TextStyle(
                                                    color: Color(
                                                        0xff371D32),
                                                    fontFamily:
                                                    'Urbanist',
                                                    fontSize: 16),
                                              ),
                                              Row(
                                                mainAxisSize:
                                                MainAxisSize
                                                    .min,
                                                children: snapshot
                                                    .data
                                                    !.cars![
                                                carIndex]
                                                    .rating !=
                                                    0
                                                    ? List.generate(
                                                    5,
                                                        (indexIcon) {
                                                      return Icon(
                                                        Icons
                                                            .star,
                                                        size: 13,
                                                        color: indexIcon <
                                                            snapshot.data!.cars![carIndex].rating
                                                                !.round()
                                                            ? Color(0xff5BC0EB).withOpacity(
                                                            0.8)
                                                            : Colors
                                                            .grey,
                                                      );
                                                    })
                                                    : List.generate(
                                                    5, (index) {
                                                  return Icon(
                                                    Icons
                                                        .star,
                                                    size: 0,
                                                    color: Colors
                                                        .grey,
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                    : new Container(),
              ],
            )
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(strokeWidth: 2.5)
                ],
              ),
            );
          }),
    );
  }

  // Future<Uint8List> getBytesFromCanvas(
  //     int width, int height, String price) async {
  //   final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   final Paint paint = Paint()..color = Color(0xffF68E65);
  //   final Radius radius = Radius.circular(10.0);
  //   canvas.drawRRect(
  //       RRect.fromRectAndCorners(
  //         Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
  //         topLeft: radius,
  //         topRight: radius,
  //         bottomLeft: radius,
  //         bottomRight: radius,
  //       ),
  //       paint);
  //   TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
  //   painter.text = TextSpan(
  //     text: price,
  //     style: TextStyle(fontSize: 40.0, color: Colors.white),
  //   );
  //   painter.layout();
  //   painter.paint(
  //       canvas,
  //       Offset((width * 0.5) - painter.width * 0.5,
  //           (height * 0.5) - painter.height * 0.5));
  //   final img = await pictureRecorder.endRecording().toImage(width, height);
  //   final data = await img.toByteData(format: ui.ImageByteFormat.png);
  //   return data.buffer.asUint8List();
  // }

  void myMarker(AsyncSnapshot<FetchNewCarResponse> snapshot) async {
    Set<MapMarker> _tempMarkers = new Set();
    var tempMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(10, 10)),
      "icons/Location-Pin.png",
    );
    for (var i = 0; i < snapshot.data!.cars!.length; i++) {
      var newItem = LatLng(snapshot.data!.cars![i].latlng!.latitude!.toDouble(),
          snapshot.data!.cars![i].latlng!.longitude!.toDouble());

      // final Uint8List markerIcon = await getBytesFromCanvas(
      //     150, 100, "\$" + snapshot.data!.cars![i].price.split("/")[0]);

      ByteData data = await _callWidgetToImage(
          "\$" + snapshot.data!.cars![i].price!.split("/")[0]);

      final Uint8List mar = data.buffer.asUint8List();

      _tempMarkers.add(MapMarker(
          position: newItem,
          id: i,
          icon: tempMarker,
          //icon: BitmapDescriptor.fromBytes(mar),
          onTap: () {
            setState(() {
              showCarDetails = true;
              carIndex = i;
            });
          }));
    }

    //fluster initialization
    ClusterUtils.initFluster(
        markers: _tempMarkers.toList(),
        context: context,
        stream: discoverCarMapBloc.newCarData,
        onModalClose: closeSingleCarCard);

    //update markers
    updateMarkers(snapshot);
  }

  void updateMarkers(AsyncSnapshot<FetchNewCarResponse> snapshot,
      [double? updatedZoom]) async {
    List<Marker>? updatedMarkers = await ClusterUtils.updateMarkers(
      updatedZoom,
    );
    if (updatedMarkers == null) {
      print("null");
      updatedMarkers = [];
    } else {
      print("not null $updatedMarkers");
    }

    var newItem = LatLng(snapshot.data!.latlng!.latitude!.toDouble(),
        snapshot.data!.latlng!.longitude!.toDouble());
    MapMarker mapMarker = MapMarker(
        pointsSize: 40,
        position: newItem,
        id: 500,
        icon: mapMarkers,
        isSelfLocation: true,
        onTap: () {});
    var addMapMarkerToMap = mapMarker.toMarker();
    if (updatedMarkers != null && updatedMarkers.length != 0) {
      updatedMarkers.add(addMapMarkerToMap);
      setState(() {
        _markers
          ..clear()
          ..addAll(updatedMarkers as Iterable<Marker>);
      });
    } else {
      List<Marker> newList = [];
      newList.add(addMapMarkerToMap);
      setState(() {
        _markers
        // ..clear()
          ..addAll(newList);
      });
    }
  }

  void closeSingleCarCard() {
    if (showCarDetails) {
      setState(() {
        showCarDetails = false;
      });
    }
  }

  _callWidgetToImage(String title) async {
    ByteData byteData = await WidgetToImage.widgetToImage(BubbleWidget(
      arrowHeight: 0,
      arrowWidth: 0,
      borderRadius: 20,
      padding: EdgeInsets.all(15),
      color: Color(0xffF68E65),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              title,
              style: TextStyle(fontSize: 45.0, color: Colors.white),
            )),
      ),
    ));
    return byteData;
  }
}
