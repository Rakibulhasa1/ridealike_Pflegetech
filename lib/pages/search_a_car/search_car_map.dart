import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';
import 'package:ridealike/utils/cluster_utils.dart';
import 'package:ridealike/widgets/map_marker.dart';
import 'package:widget_to_image/widget_to_image.dart';

import '../../utils/app_events/app_events_utils.dart';
import '../../widgets/bubble_widget.dart';

class SearchCarMap extends StatefulWidget {
  @override
  _SearchCarMapState createState() => _SearchCarMapState();
}

class _SearchCarMapState extends State<SearchCarMap> {
  List _carData = [];
  SearchData? receivedData;

  //WidgetsToImageController controller = WidgetsToImageController();

  bool showCarDetails = false;
  int carIndex = 0;

  // static var location = LatLng(_carData[0]['LatLng']['Latitude'], _carData[0]['LatLng']['Longitude']);
  // static var location = LatLng(40.730610, -73.935242);
  var location = LatLng(40.730610, -73.935242);
  GoogleMapController? mapController;

  Completer<GoogleMapController> _mapController = Completer();

  Set<Marker> _markers = new Set();
  CameraPosition? _initialCamera;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Search Car Map"});
    // set initial zoom level
    ClusterUtils.currentZoom = 11.0;

    Future.delayed(Duration.zero, () async {
      final Map _data = ModalRoute.of(context)!.settings.arguments as Map;

      setState(() {
        _carData = _data['_searchResults'];
        receivedData = _data['_receivedData'];
      });
      List<String> carIds = [];
      if( _carData!= null){
        _carData!.forEach((element) {
          carIds.add(element['ID']);
        });
      }
      AppEventsUtils.logEvent("search_results_viewed", params: {
        "number_of_search_results":
        _carData == null ? 0 : _carData!.length,
        "location": receivedData!.formattedLocationAddress,
        "view_type": "Map View",
        "car_ids_in_search": carIds,
        "start_date": (receivedData!.tripStartDate)!.toIso8601String(),
        "end_date": (receivedData!.tripEndDate)!.toIso8601String(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carData != null && _carData.length > 0) {
      location = LatLng(_carData[0]['LatLng']['Latitude'],
          _carData[0]['LatLng']['Longitude']);
      _initialCamera = CameraPosition(
        target: location,
        zoom: ClusterUtils.currentZoom,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: _carData.length > 0
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
                    myMarker();
                  },
                  onCameraMove: (newPosition) async {
                    //update markers
                    updateMarkers(newPosition.zoom);
                  },
                  onTap: (latLong) {
                    setState(() {
                      print(latLong);
                      location = latLong;
                    });
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
                                Navigator.pushNamed(context, '/search_car_tab');
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Positioned(bottom: 130, right: 30,
                //   child: Padding(
                //     padding: const EdgeInsets.only(top: 10),
                //     child: ClipOval(
                //       child: Container(
                //         color: Color(0xffFFFFFF), // button color
                //         child: GestureDetector(
                //           child: SizedBox(width: 50,
                //             height: 50,
                //             child: Image.asset('icons/My-Location.png', width: 25, height: 25,),),
                //           onTap: () {},
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                showCarDetails
                    ? GestureDetector(
                        onTap: () {
//              String startDate = intl.DateFormat("y-MM-dd").format(receivedData['_tripStartDate']) + 'T' + (receivedData['_tripStartTime'] as double).floor().toString() + ':00:00.000Z';
//              String endDate = intl.DateFormat("y-MM-dd").format(receivedData['_tripEndDate']) + 'T' + (receivedData['_tripEndTime'] as double).floor().toString() + ':00:00.000Z';
                          String startDate =
                              (receivedData!.tripStartDate)!.toIso8601String();
                          String endDate =
                              (receivedData!.tripEndDate)!.toIso8601String();

                          var arguments = {
                            "CarID": _carData[carIndex]['ID'],
                            "StartDate": startDate,
                            "EndDate": endDate
                          };

                          Navigator.pushNamed(context, '/car_details',
                              arguments: arguments);
                        },
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: MediaQuery.of(context).size.width * .95,
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
                                                BorderRadius.circular(8.0),
                                          ),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(8),
                                                              bottomLeft: Radius
                                                                  .circular(8)),
                                                      child: Image(
                                                        width: 110,
                                                        height: 73,
                                                        image: _carData[carIndex]
                                                                    [
                                                                    'ImageID'] ==
                                                                ""
                                                            ? AssetImage(
                                                                'images/car-placeholder.png')
                                                            : NetworkImage(
                                                                    '$storageServerUrl/${_carData[carIndex]['ImageID']}')
                                                                as ImageProvider,
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
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Text(
                                                      _carData[carIndex]
                                                          ['Title'],
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontFamily: 'Urbanist',
                                                        color:
                                                            Color(0xff371D32),
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          _carData[carIndex]
                                                              ['Year'],
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Urbanist',
                                                            color: Color(
                                                                0xff353B50),
                                                          ),
                                                        ),
                                                        _carData[carIndex] !=
                                                                    null &&
                                                                _carData[carIndex]
                                                                        [
                                                                        'NumberOfTrips'] !=
                                                                    null &&
                                                                _carData[carIndex]
                                                                        [
                                                                        'NumberOfTrips'] !=
                                                                    '0'
                                                            ? Row(
                                                                children: [
                                                                  Container(
                                                                    width: 2,
                                                                    height: 2,
                                                                    decoration:
                                                                        new BoxDecoration(
                                                                      color: Color(
                                                                          0xff353B50),
                                                                      shape: BoxShape
                                                                          .circle,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    _carData[carIndex]['NumberOfTrips'] !=
                                                                            '1'
                                                                        ? '${_carData[carIndex]['NumberOfTrips']} trips'
                                                                        : '${_carData[carIndex]['NumberOfTrips']} trip',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      color: Color(
                                                                          0xff353B50),
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
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      '\$' +
                                                          _carData[carIndex]
                                                              ['Price'],
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff371D32),
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 16),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: _carData[
                                                                      carIndex]
                                                                  ['Rating'] !=
                                                              0
                                                          ? List.generate(5,
                                                              (indexIcon) {
                                                              return Icon(
                                                                Icons.star,
                                                                size: 13,
                                                                color: indexIcon <
                                                                        _carData[carIndex]['Rating']
                                                                            .round()
                                                                    ? Color(0xff5BC0EB)
                                                                        .withOpacity(
                                                                            0.8)
                                                                    : Colors
                                                                        .grey,
                                                              );
                                                            })
                                                          : List.generate(5,
                                                              (index) {
                                                              return Icon(
                                                                Icons.star,
                                                                size: 0,
                                                                color:
                                                                    Colors.grey,
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
            ),
    );
  }

  // Future<Uint8List> getBytesFromCanvas(
  //     int width, int height, String price) async {
  //   final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  //   final Canvas canvas = Canvas(pictureRecorder);
  //   final Paint paint = Paint()..color = Color(0xffF68E65);
  //   final Radius radius = Radius.circular(20.0);
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

  Future<Set<Marker>?> myMarker() async {
    Set<MapMarker> _tempMarkers = new Set();
    var tempMarker = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(10, 10)),
      "icons/Location-Pin.png",
    );
    for (var i = 0; i < _carData.length; i++) {
      var newItem = LatLng(_carData[i]['LatLng']['Latitude'],
          _carData[i]['LatLng']['Longitude']);

      // final Uint8List markerIcon = await getBytesFromCanvas(
      //     150, 100, "\$" + _carData[i]['Price'].split("/")[0]);

      ByteData data =
          await _callWidgetToImage("\$" + _carData[i]['Price'].split("/")[0]);

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
        carData: _carData,
        onModalClose: closeSingleCarCard,
        startDate: (receivedData!.tripStartDate)!.toIso8601String(),
        endDate: (receivedData!.tripEndDate)!.toIso8601String());

    //update markers
    updateMarkers();
    return null;

    // setState(()
    // {
    //   _markers = _markers;
    // });
    //
    // return _markers;
  }

  void updateMarkers([double? updatedZoom]) async {
    final updatedMarkers = await ClusterUtils.updateMarkers(updatedZoom);
    var newItem = LatLng(receivedData!.lat!, receivedData!.long!);

    MapMarker mapMarker = MapMarker(
        position: newItem,
        id: 500,
        icon: BitmapDescriptor.defaultMarker,
        isSelfLocation: true,
        onTap: () {});
    var addMapMarkerToMap = mapMarker.toMarker();
    if (updatedMarkers != null && updatedMarkers.length != 0) {
      updatedMarkers.add(addMapMarkerToMap);
      setState(() {
        _markers
          ..clear()
          ..addAll(updatedMarkers);
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
