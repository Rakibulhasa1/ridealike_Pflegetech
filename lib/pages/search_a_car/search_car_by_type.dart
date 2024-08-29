import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder_plus/geocoder_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';

import '../../utils/address_utils.dart';
import '../common/constant_url.dart';
import '../common/location_util.dart';

class CarSearchByType extends StatefulWidget {
  final String? image;
  final String? type;

  const CarSearchByType({Key? key, required this.image, required this.type})
      : super(key: key);

  @override
  _CarSearchByTypeState createState() => _CarSearchByTypeState();
}

class _CarSearchByTypeState extends State<CarSearchByType> {
  Map? receivedData;
  ProgressDialog? pr;
  bool dataFetched = false;
  bool showExtraFields = true;
  bool carMakeSelected = false;
  var selectedRange = RangeValues(1, 999);

  SearchData? _searchData;

  var textStyle = TextStyle(
      color: Color(0xff371D32),
      fontSize: 16,
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.normal,
      letterSpacing: -0.4);
  var arrowTextStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.normal,
      letterSpacing: -0.2);

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

  void fetchLocation() async {
    try {
      pr!.show();
      LocationPermission? locationPermission =
          await LocationUtil.requestPermission();
      if (locationPermission == LocationPermission.always ||
          locationPermission == LocationPermission.whileInUse) {
        Position? _locationData;
        _locationData = await LocationUtil.getCurrentLocation();

        if (_locationData != null) {
          /*final coordinates = new Coordinates(
              _locationData.latitude, _locationData.longitude);*/

          String? address = await AddressUtils.getAddress(
              _locationData.latitude,  _locationData.longitude);

          /*var addresses = await GoogleGeocoding(
            googleApiKeyUrl,
            language: 'en',
          ).findAddressesFromCoordinates(coordinates);
          address = addresses.first.locality;
          if (address == null) {
            address = addresses.first.adminArea;
          }*/
          DateTime _start = DateTime.now().add(Duration(hours: 2));
          DateTime _temp = DateTime.now().add(Duration(days: 4));
          DateTime _end = _temp.add(Duration(hours: 2));
          _searchData = SearchData(
            locationLat: _locationData.latitude,
            locationLon: _locationData.longitude,
            locationAddress: address,
            formattedLocationAddress: address,
            tripStartDate: _start,
            tripEndDate: _end,
            sortBy: 'None',
            carType: [widget.type!],
            carMake: [],
            carModel: [],
            greenFeature: [],
            totalTripCostLowerRange: 1,
            totalTripCostUpperRange: 999,
          );
          pr!.hide();
          Navigator.pushNamed(
            context,
            '/search_car_sort_tab',
            arguments: _searchData,
          );
        }
      } else {
        pr!.hide();
        showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Location Permission'),
              content: Text('This app needs location access'),
              actions: [
                CupertinoDialogAction(
                  child: Text('Deny'),
                  onPressed: () => Navigator.pop(context),
                ),
                CupertinoDialogAction(
                  child: Text('Settings'),
                  onPressed: () async {
                    Geolocator.openLocationSettings();
                  },
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      pr!.hide();
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // Car image and text container
              GestureDetector(
                onTap: () {
                  // Call the button function here or navigate to a new screen
                  fetchLocation();
                  /*DateTime _start = DateTime.now().add(Duration(hours: 2));
                  DateTime _temp = DateTime.now().add(Duration(days: 4));
                  DateTime _end = _temp.add(Duration(hours: 2));
                  _searchData = SearchData(
                    tripStartDate: _start,
                    tripEndDate: _end,
                    sortBy: 'None',
                    carType: [widget.type!],
                    carMake: [],
                    carModel: [],
                    greenFeature: [],
                    totalTripCostLowerRange: 0,
                    totalTripCostUpperRange: 999,
                  );
                  Navigator.pushNamed(
                    context,
                    '/search_car_sort_tab',
                    arguments: _searchData,
                  );*/
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  child: Container(
                    width: 140,
                    height: 155,
                    decoration: BoxDecoration(
                      color: Color(0xffF2F2F2),
                      border: Border.all(
                        width: 1,
                        color: Color(0xffF68E65),
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                      // boxShadow: [
                      //   BoxShadow(
                      //     color: Colors.black.withOpacity(0.2),
                      //     spreadRadius: 2,
                      //     blurRadius: 4,
                      //     offset: Offset(0, 2),
                      //   ),
                      // ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Image Section
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(8.0),
                          ),
                          child: Image.asset(
                            widget.image!,
                            // Replace with your image URL
                            height: 117,
                            width: 150, // Set your preferred height
                            fit: BoxFit.cover,
                          ),
                        ),

                        // Text Section with White Background
                        Container(
                          height: 35,
                          width: 100,
                          color: Color(0xffF2F2F2),
                          // Background color for the text container
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            widget.type!,
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: Color(0xff371D32),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
