import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:progress_dialog/progress_dialog.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/utils/address_utils.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';

class SwapCustomLocation extends StatefulWidget {
  @override
  State createState() => SwapCustomLocationState();
}

class SwapCustomLocationState extends State<SwapCustomLocation> {
  Position? _currentPosition;
  ProgressDialog? pr;

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }
  // Future<Position> _getCurrentLocation() {
  //   final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  //
  //   return geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.best);
  // }

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
    } catch (e) {
      print(e);
    }
  }

  Completer<GoogleMapController> _mapController = Completer();

  static var location = LatLng(40.730610, -73.935242);
  var _locationName;

  //var _areaName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      Navigator.pop(context);
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
                iconColor: Color(0xff371D32),
                bgColor: Colors.white,
                textColor:Color(0xff371D32),
                icon: Icons.search,
                apiKey: googleApiKeyUrl,
                onSelected: (place) async {
                  final geolocation = await place.geolocation;
                  var locationName = place.description;
                  if (mounted) {
                    setState(() {
                      location = geolocation!.coordinates;
                      _locationName = locationName;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 16, bottom: 8, left: 16, top: 8),
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
                        if (_currentPosition != null) {
                          LatLng _location = LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude);
                          String address = await AddressUtils.getAddress(_currentPosition!.latitude,
                              _currentPosition!.longitude);
                          var data = {"location": _location, "address": address};
                          Navigator.pop(context, data);
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
            Padding(
              padding: EdgeInsets.only(right: 16, bottom: 8, left: 16, top: 8),
              child: _locationName != null
                  ? ListView.separated(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Row(
                          children: <Widget>[
                            Icon(
                              Icons.location_on,
                              color: Color(0xff371D32),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  var data = {
                                    "location": location,
                                    "address": _locationName
                                  };
                                  Navigator.pop(context, data);
                                },
                                child: Text('$_locationName'),
                              ),
                            ),
                          ],
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Divider();
                      },
                      itemCount: 1)
                  : new Container(),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

}
