import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';
import 'package:ridealike/utils/address_utils.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';

import '../common/location_util.dart';

class SearchCarLocation extends StatefulWidget {
  @override
  _SearchCarLocationState createState() => _SearchCarLocationState();
}

class _SearchCarLocationState extends State<SearchCarLocation> {
  SearchData? receivedData;

  var searchResultText = TextStyle(
      color: Color(0xff371D32),
      fontWeight: FontWeight.normal,
      fontFamily: 'Urbanist',
      fontSize: 16,
      letterSpacing: -0.4);
  Position? _currentPosition;
  String? _currentAddress;

  bool locationFetched = false;
  ProgressDialog? pr;

  var currentAddressValue;

  LocationPermission? locationPermission;

  var locationName;
  var location;

  @override
  Widget build(BuildContext context) {
    receivedData = ModalRoute.of(context)!.settings.arguments as SearchData;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
      ),
      body: locationFetched
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Location',
                    style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 36,
                        color: Color(0xFF371D32),
                        letterSpacing: -0.2,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  SearchMapPlaceWidget(
                    placeholder: 'Search city, address, airport or hotel',
                    iconColor: Color(0xff371D32),
                    icon: Icons.search,
                    bgColor: Colors.white,
                    textColor: Color(0xff371D32),
                    apiKey: googleApiKeyUrl,
                    onSelected: (place) async {
                      final geolocation = await place.geolocation;
                      var locationName = place.description;
                      setState(() {
                        location = geolocation!.coordinates;
                        this.locationName = locationName;
                      });
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  currentAddressValue != null
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                if (_currentPosition != null &&
                                    _currentAddress != null) {
                                  receivedData!.locationLat =
                                      _currentPosition!.latitude;
                                  receivedData!.locationLon =
                                      _currentPosition!.longitude;
                                  receivedData!.locationAddress =
                                      _currentAddress;
                                  receivedData!.formattedLocationAddress =
                                      _currentAddress;
                                  receivedData!.locationAddressForShow =
                                      'Current Location';
                                  print(receivedData!.formattedLocationAddress);
                                  print(receivedData!.locationLat);
                                  print(receivedData!.locationLon);
                                  Navigator.pop(context, {
                                    'searchData': receivedData,
                                    'showLocation': false,
                                  });
                                }
                              },
                              child: SizedBox(
                                height: 50,
                                width: 200,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: AutoSizeText(
                                    // 'Current location: $currentAddressValue',
                                    'Current location',
                                    style: searchResultText,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(),
                  Divider(),
                  locationName != null
                      ? Expanded(
                          child: ListView.separated(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Row(
                                  children: <Widget>[
                                    Image.asset('icons/Location-2.png'),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () async {
                                          //TODO
                                          receivedData!.locationLat =
                                              location.latitude;
                                          receivedData!.locationLon =
                                              location.longitude;

                                          receivedData!.locationAddress =
                                              locationName;
                                          receivedData!
                                                  .formattedLocationAddress =
                                              locationName;

                                          receivedData!.locationAddressForShow =
                                              locationName;
                                          print(receivedData!.formattedLocationAddress);
                                          print(receivedData!.locationLat);
                                          print(receivedData!.locationLon);
                                          Navigator.pop(context, {
                                            'searchData': receivedData,
                                            'showLocation': true,
                                          });
                                        },
                                        child: Text('$locationName',
                                            style: searchResultText),
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider();
                              },
                              itemCount: 1),
                        )
                      : new Container(),
                ],
              ),
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

  Future callCurrentPosition() async {
    try {
      _currentPosition = await LocationUtil.getCurrentLocation();
      String geoLocation = await AddressUtils.getAddress(
          _currentPosition!.latitude, _currentPosition!.longitude);
      print(geoLocation);
      _currentAddress = geoLocation;
    } catch (e) {
      print(e);
    }
  }

  fetchLocation() async {
    // TODO location fetch
    try {
      await callCurrentPosition();

      if (_currentPosition != null && _currentAddress != null) {
        setState(() {
          receivedData!.locationLat = _currentPosition!.latitude;
          receivedData!.lat = _currentPosition!.latitude;
          receivedData!.locationLon = _currentPosition!.longitude;
          receivedData!.long = _currentPosition!.longitude;
          receivedData!.locationAddress = _currentAddress;
          receivedData!.formattedLocationAddress = _currentAddress;
          receivedData!.locationAddressForShow = 'Current Location';
          currentAddressValue = receivedData!.locationAddress;
          print('receved${receivedData!.locationAddress}');
          print('recevCurrent $_currentAddress');
          locationFetched = true;
        });
      } else {
        setState(() {
          locationFetched = true;
        });
      }
    } catch (e) {
      print(e);
      setState(() {
        locationFetched = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    if (locationPermission == null) {
      LocationUtil.requestPermission().then((value) {
        locationPermission = value;
        if (locationPermission == LocationPermission.denied ||
            locationPermission == LocationPermission.deniedForever) {
          setState(() {
            locationFetched = true;
          });
          showDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text('Location Permission'),
                content: Text('This app needs location access'),
                actions: [
                  CupertinoDialogAction(
                    child: Text('Deny'),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        locationFetched = true;
                      });
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text('Settings'),
                    onPressed: () async {
                      Geolocator.openAppSettings().whenComplete(() {
                        setState(() {
                          locationFetched = true;
                        });
                        return Navigator.pop(context);
                      });
                    },
                  ),
                ],
              );
            },
          );
        } else if (locationPermission! == LocationPermission.always ||
            locationPermission! == LocationPermission.whileInUse) {
          fetchLocation();
        } else {
          setState(() {
            locationFetched = true;
          });
        }
      });
    }

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
}
