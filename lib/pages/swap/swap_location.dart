import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridealike/pages/swap/swap_custom_location.dart';

import '../../utils/app_events/app_events_utils.dart';

class SwapLocation extends StatefulWidget {
  @override
  State createState() => SwapLocationState();
}

class SwapLocationState extends State<SwapLocation> {
  Completer<GoogleMapController> _mapController = Completer();

  //String _area = "Area";
  String _address = "Address";
  LatLng? location;
  Set<Marker> _markers = Set();
  CameraPosition? _initialCamera;

  Map? receivedData;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Swap Location"});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        receivedData = ModalRoute.of(context)!.settings.arguments as Map;
        print(receivedData);
        print("location data");
        print(receivedData!["_locationAddress"]);
        print("location data");
        if (receivedData!["_locationAddress"] != null &&
            receivedData!['_locationLat'] != null &&
            receivedData!['_locationLon'] != null) {
          print("any not null");
          _address = receivedData!["_locationAddress"];
          receivedData!['_locationLat'] = receivedData!["_locationLat"];
          receivedData!['_locationLon'] = receivedData!["_locationLon"];
        } else {
          receivedData!['_locationLat'] = 0.0;
          receivedData!['_locationLon'] = 0.0;
        }

        location =
            LatLng(receivedData!['_locationLat'], receivedData!['_locationLon']);
        _initialCamera = CameraPosition(target: location!, zoom: 14.4746);

        _markers.clear();
        _markers.add(Marker(
          markerId: MarkerId(_initialCamera.toString()),
          position: location!,
          icon: BitmapDescriptor.defaultMarker,
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: receivedData != null
          ? Container(
              alignment: Alignment.bottomLeft,
              color: Color.fromRGBO(64, 64, 64, 1),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height / 1.5,
                  // maxHeight: MediaQuery.of(context).size.height - 24,
                ),
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  // height: MediaQuery.of(context).size.height / 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    shrinkWrap: true,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16.0, right: 16.0, bottom: 10.0),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text(
                                'Location',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Color(0xFF371D32),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Icon(Icons.arrow_back,
                                  color: Color(0xffFF8F68)),
                            ),
                          ],
                        ),
                      ),
                      // Sub header
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 16, left: 16, top: 0),
                        child: Text(
                          'Select a location where you would be comfortable to make a Swap. We suggest meeting up at a gas station, so it\'s more secure and you can also fill up your vehicle to a full tank.',
                          style: TextStyle(
                              color: Color(0xff371D32).withOpacity(0.5),
                              letterSpacing: 0.2,
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Divider(),
                      // Map
                      Padding(
                        padding:
                            EdgeInsets.only(right: 16, left: 16, bottom: 8),
                        child: Container(
                          height: 350,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            child: Stack(
                              children: [
                                GoogleMap(
                                  zoomControlsEnabled: false,
                                  zoomGesturesEnabled: true,
                                  myLocationEnabled: false,
                                  myLocationButtonEnabled: false,
                                  mapToolbarEnabled: false,
                                  scrollGesturesEnabled: true,
                                  gestureRecognizers:
                                      <Factory<OneSequenceGestureRecognizer>>[
                                    new Factory<OneSequenceGestureRecognizer>(
                                      () => new EagerGestureRecognizer(),
                                    ),
                                  ].toSet(),
                                  initialCameraPosition: _initialCamera!,
                                  mapType: MapType.normal,
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _mapController.complete(controller);
                                  },
                                  markers: _markers,
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Card(
                                      margin: EdgeInsets.all(10),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(_address),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      //SizedBox(height: 16),
                      Divider(),
                      Padding(
                        padding: EdgeInsets.only(
                          right: 16,
                          left: 16,
                          bottom: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xffFF8F68),
                                        padding: EdgeInsets.all(16.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8.0)),

                                      ),
                                        onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SwapCustomLocation()),
                                        ).then((value) {
                                          if (value != null) {
                                            var data = value;
                                            LatLng _location = data["location"];
                                            setState(() {
                                              _address = data["address"];
                                              location = _location;
                                              _markers.clear();
                                              _markers.add(Marker(
                                                markerId: MarkerId(
                                                    _initialCamera.toString()),
                                                position: location!,
                                                icon: BitmapDescriptor
                                                    .defaultMarker,
                                              ));
                                            });
                                            _mapController.future
                                                .then((controller) async {
                                              await controller.animateCamera(
                                                CameraUpdate.newCameraPosition(
                                                  CameraPosition(
                                                      target: location!,
                                                      zoom: 14.4746),
                                                ),
                                              );
                                            });
                                          }
                                        });
                                      },
                                      child: Text(
                                        'Set Custom Location',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            right: 16, left: 16, bottom: 8, top: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xffFF8F68),
                                        padding: EdgeInsets.all(16.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(8.0)),

                                      ),
                                       onPressed: () {
                                        receivedData!['_locationAddress'] =
                                            _address;
                                        receivedData!['_locationLat'] =
                                            location!.latitude;
                                        receivedData!['_locationLon'] =
                                            location!.longitude;

                                        if (receivedData!["route"] != null &&
                                            receivedData!["route"] ==
                                                "/agree_with_swap_terms") {
                                          Navigator.pop(context, receivedData);
                                        } else {
                                          Navigator.of(context).pop();
                                          Navigator.pushNamed(
                                              context, '/swap_arrange_terms',
                                              arguments: receivedData);
                                        }
                                      },
                                      child: Text(
                                        'Save',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
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
          : Container(),
    );
  }

  void setMarker() {
    setState(() {
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(_initialCamera.toString()),
        position: location!,
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }
}
