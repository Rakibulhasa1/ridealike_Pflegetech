import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
// import 'package:search_map_place/search_map_place.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/utils/address_utils.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';
var first;


Future<Position> _getCurrentLocation() async {
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.best,
  );
}
// Future<Position> _getCurrentLocation() {
//   final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
//
//   return geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
// }



class ChangeRequestCustomLocation extends StatefulWidget {
  final bookingInfo;

  ChangeRequestCustomLocation({this.bookingInfo});

  @override
  State createState() => ChangeRequestCustomLocationState(bookingInfo);
}

class ChangeRequestCustomLocationState extends State<ChangeRequestCustomLocation> {
  var bookingInfo;

  ChangeRequestCustomLocationState(this.bookingInfo);

 Position? _currentPosition;
 String? _currentAddress;

 ProgressDialog? pr;
  bool isValid = true;

  @override
  void initState() {
    super.initState();
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.normal,
    );
    pr!.style(
      message: "Please wait...",
      progressWidget: Container(
        padding: EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future callCurrentPosition() async {
    try {
      _currentPosition = await _getCurrentLocation();
      String geoLocation = await AddressUtils.getAddress(_currentPosition!.latitude, _currentPosition!.longitude);
      print(geoLocation);
      _currentAddress = geoLocation;

    } catch (e) {
      print(e);
    }
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // void handleShowSetLocationModal(context) {
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
  //       return ChangeRequestSetLocation(
  //         bookingInfo: bookingInfo,
  //       );
  //     },
  //   );
  // }

  static var location = LatLng(40.730610, -73.935242);
  var locationName;
  var formattedAddressName;
 double? distance;

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
                    InkWell(
                      onTap: () {
                        Navigator.pop(context,bookingInfo);
                        // Navigator.pushNamed(
                        //   context,
                        //   '/car_details',
                        //   // arguments: receivedData['_carData'],
                        // );
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFFF68E65),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16, left: 16),
                child: Text(
                  'Location',
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 36,
                      color: Color(0xFF371D32),
                      letterSpacing: -0.2,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: SearchMapPlaceWidget(
                  placeholder: 'Search city, address, airport or hotel',
                  iconColor:Color(0xff371D32),
                  bgColor: Colors.white,
                  textColor:Color(0xff371D32),
                  icon: Icons.search,
                  apiKey: googleApiKeyUrl,
                  onSelected: (place) async {
                    final geolocation = await place.geolocation;
                    var locationName = place.description;
                    setState(() {
                      location = geolocation!.coordinates;
                      formattedAddressName = geolocation.fullJSON["address"].toString();
                      this.locationName = locationName;
                      distance =  calculateDistance(bookingInfo['locLat'],bookingInfo['locLong'],location.latitude,location.longitude);
                    });
                    this.locationName = locationName;

                    //TODO address



                  if(distance!>50){
                    setState(() {
                      isValid =false;
                    });
                  }else{
                    bookingInfo['locLat'] = location.latitude;
                    bookingInfo['locLong'] = location.longitude;
                    bookingInfo['locAddress'] = locationName;
                    bookingInfo['FormattedAddress'] = formattedAddressName;
                    bookingInfo['deliveryNeeded'] = true;
                    bookingInfo['CustomLoc'] = true;
                    Navigator.pop(context,bookingInfo);
                  }

                    print("clicked location$locationName");
                  },
                ),
              ),

              !isValid?Padding(
                padding:EdgeInsets.only(right: 16, bottom: 8, left: 16, top: 8) ,
                child: Text("Please select location within 50 KM",style:  TextStyle(color: Colors.red,fontSize: 16),),
              ): Container(),
              Padding(
                padding:
                EdgeInsets.only(right: 16, bottom: 8, left: 16, top: 8),
                child: Row(
                  children: <Widget>[
                    Image.asset('icons/My-Location.png'),
                    SizedBox(
                      width: 10,
                    ),
                    InkWell(
                      onTap: () async {
                        try {
                          await pr!.show();
                          await callCurrentPosition();
                          await pr!.hide();
                          if (_currentPosition != null &&
                              _currentAddress != null) {
                            //TODO address
                            distance =  calculateDistance(bookingInfo['locLat'],bookingInfo['locLong'],location.latitude,location.longitude);
                            if(distance!>50){
                              setState(() {
                                isValid = false;
                              });
                            }else{
                              bookingInfo['locLat'] = _currentPosition!.latitude;
                              bookingInfo['locLong'] = _currentPosition!.longitude;
                              bookingInfo['locAddress'] = _currentAddress;
                              bookingInfo['FormattedAddress'] = _currentAddress;
                              bookingInfo['deliveryNeeded'] = true;
                              bookingInfo['CustomLoc'] = true;
                              Navigator.pop(context,bookingInfo);
                            }

                          }
                        } catch (e) {
                          await pr!.hide();
                          print(e);
                        }

                      },
                      child: Text('Use current location'),
                    ),
                  ],
                ),
              ),
              // Padding(
              //   padding:
              //   EdgeInsets.only(right: 16, bottom: 8, left: 16, top: 8),
              //   child: locationName != null
              //       ? ListView.separated(
              //       scrollDirection: Axis.vertical,
              //       shrinkWrap: true,
              //       itemBuilder: (context, index) {
              //         return Row(
              //           children: <Widget>[
              //             Icon(
              //               Icons.location_on,
              //               color: Color(0xff371D32),
              //             ),
              //             SizedBox(width: 10),
              //             Expanded(
              //               child: GestureDetector(
              //                 onTap: () async {
              //                   //TODO address
              //                   bookingInfo['locLat'] = location.latitude;
              //                   bookingInfo['locLong'] = location.longitude;
              //                   bookingInfo['locAddress'] = locationName;
              //                   bookingInfo['FormattedAddress'] = formattedAddressName;
              //                   bookingInfo['deliveryNeeded'] = true;
              //                   bookingInfo['CustomLoc'] = true;
              //                   Navigator.pop(context,bookingInfo);
              //                 },
              //                 child: Text('$locationName'),
              //               ),
              //             ),
              //           ],
              //         );
              //       },
              //       separatorBuilder: (context, index) {
              //         return Divider();
              //       },
              //       itemCount: 1)
              //       : new Container(),
              // ),
              Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
