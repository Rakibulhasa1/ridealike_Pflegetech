import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridealike/pages/trips/change_request/guest_ui/widgets/change_request_custom_location_widget.dart';



class ChangeLocation extends StatefulWidget {
  final bookingInfo;


  ChangeLocation({this.bookingInfo});

  @override
  State createState() => ChangeLocationState(bookingInfo);
}

class ChangeLocationState extends State<ChangeLocation> {
  var bookingInfo;

  ChangeLocationState(this.bookingInfo);

  void handleShowCustomLocationModal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        bookingInfo["defaultAddress"] = _defaultFreeLocation;
        bookingInfo["defaultLat"] = _defaultLocation!.latitude;
        bookingInfo["defaultLon"] = _defaultLocation!.longitude;
        return ChangeRequestCustomLocation(
          bookingInfo: bookingInfo,
        ) ;
        // BookingCustomLocation(
        //   bookingInfo: bookingInfo,
        // );
      },
    ).then((value) => changeLocation(value));
  }

  // void handleShowBookingInfoModal() {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(10),
  //         topRight: Radius.circular(10),
  //       ),
  //     ),
  //     context: context,
  //     builder: (context) {
  //       return BookingInfo(
  //         bookingInfo: bookingInfo,
  //       );
  //     },
  //   );
  // }

  Completer<GoogleMapController> _mapController = Completer();

 String? _freelocation;
   var location;
  Set<Marker>? _markers;
  Set<Circle>? _circles;
   CameraPosition? _initialCamera;
   String? _defaultFreeLocation;
   LatLng? _defaultLocation;
   bool delivery=false;

 void changeLocation(changeBookingInfo){
   setState(() {
     print("====$bookingInfo");
     print("===========$changeBookingInfo");
     bookingInfo = changeBookingInfo;
   });
 }

  @override
  void initState() {
    super.initState();

    print(bookingInfo);

    _freelocation = bookingInfo['locAddress'];

    if (bookingInfo["defaultAddress"] != null) {
      _defaultFreeLocation = bookingInfo["defaultAddress"];
    } else {
      _defaultFreeLocation = _freelocation;
      bookingInfo["defaultAddress"] = _defaultFreeLocation;
    }

    location = LatLng(bookingInfo['locLat'], bookingInfo['locLong']);

    if (bookingInfo["defaultLat"] != null &&
        bookingInfo["defaultLon"] != null) {
      _defaultLocation =
          LatLng(bookingInfo['defaultLat'], bookingInfo['defaultLon']);
    } else {
      _defaultLocation = location;
      bookingInfo["defaultLon"] = _defaultLocation!.longitude;
      bookingInfo["defaultLat"] = _defaultLocation!.latitude;
    }

    print(_freelocation);
    print(location);

    print("********************");
    print(_defaultFreeLocation);
    print(_defaultLocation);

    _markers = new Set();
    _circles = new Set();
    _initialCamera = CameraPosition(target: location, zoom: 14.4746);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      color: Color.fromRGBO(64, 64, 64, 1),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height / 1.5,
          // maxHeight: MediaQuery.of(context).size.height - 24,
        ),
        child: Container(
          margin:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                padding: const EdgeInsets.all(16),
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
                      child: Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
                    ),
                    // Align(
                    //   alignment: Alignment.centerRight,
                    //   child: InkWell(
                    //     onTap: () {
                    //       Navigator.of(context).pop();
                    //       showModalBottomSheet(
                    //         isScrollControlled: true,
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.only(
                    //             topLeft: Radius.circular(10),
                    //             topRight: Radius.circular(10),
                    //           ),
                    //         ),
                    //         context: context,
                    //         builder: (context) {
                    //           bookingInfo['deliveryNeeded'] = false;
                    //           bookingInfo['CustomLoc'] = false;
                    //
                    //           return ChangeLocation(
                    //               bookingInfo: bookingInfo);
                    //         },
                    //       );
                    //     },
                    //     child: Text(
                    //       "Reset",
                    //       style: TextStyle(
                    //         color: Color(0xffFF8F68),
                    //       ),
                    //     ),
                    //   ),
                    // )
                  ],
                ),
              ),
              // Sub header
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 16, top: 16),
                child: Text(
                  'PICKUP AND RETURN LOCATION',
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
                padding: EdgeInsets.only(right: 16, left: 16, bottom: 16),
                child: Container(
                  height: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: GoogleMap(
                      myLocationButtonEnabled: false,
                      myLocationEnabled: false,
                      mapToolbarEnabled: false,
                      zoomGesturesEnabled: true,
                      zoomControlsEnabled: true,
                      scrollGesturesEnabled: true,
                      gestureRecognizers:
                      <Factory<OneSequenceGestureRecognizer>>[
                        new Factory<OneSequenceGestureRecognizer>(
                              () => new EagerGestureRecognizer(),
                        ),
                      ].toSet(),
                      initialCameraPosition: _initialCamera!,
                      mapType: MapType.normal,
                      onMapCreated: (GoogleMapController controller) {
                        _mapController.complete(controller);
                        myCircle();
                      },
                      // markers: this.myMarker(),
                      circles: _circles!,
                    ),
                  ),
                ),
              ),
              /// Free location
              Padding(
                padding:
                EdgeInsets.only(top: 8, right: 16, left: 16, bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      bookingInfo['deliveryNeeded'] = false;
                      bookingInfo['CustomLoc'] = false;
                      bookingInfo['locAddress'] = _defaultFreeLocation;
                      location = _defaultLocation;
                    });

                    _mapController.future.then((controller) {
                      controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(target: location, zoom: 14.4746),
                        ),
                      );
                      setState(() {
                        _markers!.clear();
                        _markers!.add(Marker(
                          markerId: MarkerId(_initialCamera.toString()),
                          position: location,
                          icon: BitmapDescriptor.defaultMarker,
                        ));
                      });
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: !bookingInfo['deliveryNeeded']
                          ? Border.all(
                          width: 1.0, color: const Color(0xFFEA9A62))
                          : Border.all(color: Colors.transparent),
                      color: bookingInfo['deliveryNeeded']
                          ? Color(0xffF2F2F2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              //TODO
                              Text(
                                'Near ' + _defaultFreeLocation.toString(),
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Free',
                                style: TextStyle(
                                  color: Color(0xff353B50),
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        !bookingInfo['deliveryNeeded']
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 16,
                              child: Icon(Icons.check,
                                  color: Color(0xFFEA9A62)),
                            ),
                          ],
                        )
                            : new Container(),
                      ],
                    ),
                  ),
                ),
              ),
              // Custom delivery
              bookingInfo['customDeliveryEnable'] != null &&
                  bookingInfo['customDeliveryEnable'] == true
                  ? Padding(
                padding: EdgeInsets.only(
                    top: 8, right: 16, left: 16, bottom: 8),
                child: GestureDetector(
                  onTap: () => handleShowCustomLocationModal(context),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: bookingInfo['deliveryNeeded']
                          ? Border.all(
                          width: 1.0, color: const Color(0xFFEA9A62))
                          : Border.all(color: Colors.transparent),
                      color: !bookingInfo['deliveryNeeded']
                          ? Color(0xffF2F2F2)
                          : Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Delivery Location',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                bookingInfo['deliveryNeeded']
                                    ? bookingInfo['locAddress']
                                    : 'Enter the address to calculate delivery fee.',
                                style: TextStyle(
                                  color: Color(0xff353B50),
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        bookingInfo['deliveryNeeded']
                            ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 16,
                              child: Icon(Icons.check,
                                  color: Color(0xFFEA9A62)),
                            ),
                          ],
                        )
                            : new Container(),
                      ],
                    ),
                  ),
                ),
              )
                  : Container(),

              bookingInfo['customDeliveryEnable'] != null &&
                  bookingInfo['customDeliveryEnable'] == true
                  ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 25),
                child: Text(
                  'Delivery available within 50 km.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              )
                  : Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 20),
                child: Text(
                  'Delivery not available.',
                  style: TextStyle(
                    color: Colors.red,
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(height: 16),
              Divider(),
              Padding(
                padding:
                EdgeInsets.only(right: 16, left: 16, bottom: 16, top: 8),
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
                                    borderRadius: BorderRadius.circular(8.0)),

                              ),
                              onPressed: () {
                                print("========$bookingInfo ========0000");
                                Navigator.pop(context , bookingInfo);

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
    );
  }

  Set<Circle>? myCircle(){
    final String circleIdVal = 'circle_id_1';
    setState(() {
      _circles!.add(Circle(
          circleId: CircleId(circleIdVal),
          center: LatLng(bookingInfo['locLat'], bookingInfo['locLong']),
          radius: 500,
          fillColor: Color.fromRGBO(234, 154, 98, 0.15),
          strokeWidth: 2,
          strokeColor: Color(0xFFEA9A62)));
    });
  }

  Set<Marker> myMarker() {
    setState(() {
      _markers!.add(Marker(
        markerId: MarkerId(_initialCamera.toString()),
        position: location,
        icon: BitmapDescriptor.defaultMarker,
      ));
    });

    return _markers!;
  }
}
