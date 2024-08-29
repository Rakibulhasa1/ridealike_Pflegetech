import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/location_util.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';
import 'package:ridealike/pages/search_a_car/search_car_tab.dart';
import 'package:ridealike/utils/address_utils.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

class FrontSearch extends StatefulWidget {
  SearchTabState? object;

  @override
  _FrontSearchState createState() => _FrontSearchState();
}

class _FrontSearchState extends State<FrontSearch> {
  Position? _currentPosition;
  String? _currentAddress;
  Map? receivedData;
  var currentAddressValue;
  LocationPermission? locationPermission;
  bool locationGetSuccess = false;
  bool locationFetched = false;
  bool showLocation = false;

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

  List? _carTypeData;

  List<String> _selectedCarTypes = [];

  bool dataFetched = false;

  bool showExtraFields = true;
  bool carMakeSelected = false;

  var selectedRange = RangeValues(1, 999);
  RangeLabels _labels = RangeLabels('1', '999');
  SearchData? _searchData;

  @override
  Widget build(BuildContext context) {
    final SearchData? receivedData =
        ModalRoute.of(context)!.settings.arguments as SearchData?;

    if (receivedData != null && dataFetched == false) {
      dataFetched = true;
      List temp = receivedData.carType!;
      if (temp != null) {
        for (var i in temp) {
          _selectedCarTypes.add(i);
        }
      }
    }
    if (_searchData == null) {
      //TODO hour issue
      DateTime _start = DateTime.now().add(Duration(hours: 2));
      DateTime _temp = DateTime.now().add(Duration(days: 4));
      //DateTime _end = _temp.subtract(Duration(hours: DateTime.now().hour));
      DateTime _end = _temp.add(Duration(hours: 2));
      _searchData = SearchData(
        tripStartDate: _start,
        tripEndDate: _end,
        sortBy: 'None',
        carType: [],
        carMake: [],
        carModel: [],
        greenFeature: [],
        totalTripCostLowerRange: 0,
        totalTripCostUpperRange: 999,
      );
    }

    return

        // locationFetched
        //     ?
        SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            border: Border.all(
              color: Color(0xffFF8F68),
              width: 3.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SizedBox(height: 20),

                // Pickup and Return
                InkWell(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/search_car_location',
                      arguments: _searchData,
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          showLocation = (value as Map)['showLocation'];
                          _searchData = (value)['searchData'];
                        });
                      }
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup and Return',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color(0xffFF8F68),
                            width: 2.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 14.0,
                            right: 14,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/search_car_location',
                                    arguments: _searchData,
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        showLocation =
                                            (value as Map)['showLocation'];
                                        _searchData =
                                            (value as Map)['searchData'];
                                      });
                                    }
                                  });
                                },
                                child: Row(
                                  children: [
                                    SvgPicture.asset(
                                      'svg/pickup.svg',
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      width: 185,
                                      child: Text(
                                        _searchData!.locationAddressForShow,overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          color: Colors.black,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/search_car_location',
                                    arguments: _searchData,
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        showLocation =
                                            (value as Map)['showLocation'];
                                        _searchData =
                                            (value as Map)['searchData'];
                                      });
                                    }
                                  });
                                },
                                child: Text(
                                  'EDIT',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xffFF8F68),
                                    fontSize: 18.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8),
                Divider(),

                // Trip duration
                InkWell(
                  onTap: () {
                    _searchData!.read = true;
                    Navigator.pushNamed(
                      context,
                      '/search_car_trip_duration',
                      arguments: _searchData,
                    ).then((value) {
                      if (value != null) {
                        setState(() {
                          _searchData = value as SearchData?;
                        });
                      }
                    });
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trip Duration',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 50.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(
                            color: Color(0xffFF8F68),
                            width: 2.0,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 14.0,
                            right: 14,
                          ),
                          child: InkWell(
                            onTap: () {
                              _searchData!.read = true;
                              Navigator.pushNamed(
                                context,
                                '/search_car_trip_duration',
                                arguments: _searchData,
                              ).then((value) {
                                if (value != null) {
                                  setState(() {
                                    _searchData = value as SearchData?;
                                  });
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                            SvgPicture.asset(
                                'svg/duration.svg',
                            ),
                                    SizedBox(width: 8),
                                    Text(
                                      _searchData!.tripStartDate != null
                                          ? DateFormat('MMM dd').format(
                                                _searchData!.tripStartDate!,
                                              ) +
                                              ' - ' +
                                              DateFormat('MMM dd').format(
                                                _searchData!.tripEndDate!,
                                              )
                                          : 'select dates',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        color: Colors.black,
                                        fontSize: 18.0,
                                      ),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ],
                                ),
                                Text(
                                  'EDIT',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xffFF8F68),
                                    fontSize: 18.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Additional fields

                SizedBox(height: 20),

                // Next button
                SizedBox(
                  width: double.maxFinite,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      primary: _searchData!.locationAddress == null ||
                          _searchData!.locationAddress == '' ||
                          _searchData!.tripStartDate == null ||
                          _searchData!.tripEndDate == null
                          ? Colors.grey
                          : Color(0xffFF8F68),
                    ),
                    onPressed: _searchData!.locationAddress == null ||
                        _searchData!.locationAddress == '' ||
                        _searchData!.tripStartDate == null ||
                        _searchData!.tripEndDate == null
                        ? null
                        : () {
                      Navigator.pushNamed(
                        context,
                        '/search_car_sort_tab',
                        arguments: _searchData,
                      ).then((value) {
                        if (widget.object != null) {
                          //TODO
                        }
                      });
                      print(_searchData);
                    },
                    child: Text(
                      _searchData!.locationAddress == null ||
                          _searchData!.locationAddress == '' ||
                          _searchData!.tripStartDate == null ||
                          _searchData!.tripEndDate == null
                          ? 'Finding your location. . .'
                          : 'Search',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
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
          _searchData!.locationLat = _currentPosition!.latitude;
          _searchData!.lat = _currentPosition!.latitude;
          _searchData!.locationLon = _currentPosition!.longitude;
          _searchData!.long = _currentPosition!.longitude;
          _searchData!.locationAddress = _currentAddress;
          _searchData!.formattedLocationAddress = _currentAddress;
          currentAddressValue = _currentAddress;
          print('recevCurrent${_currentAddress}');
          locationFetched = true;
          print('location fetched $locationFetched');
          locationGetSuccess = true;
          _searchData!.locationAddressForShow = 'Current Location';
        });
      }
    } catch (e) {
      setState(() {
        locationFetched = true;
      });
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    // _getLocation();
    // callFetchCarType();
    //AppEventsUtils.logEvent("front_search");
    if (locationPermission == null) {
      LocationUtil.requestPermission().then((value) {
        locationPermission = value;
        if (locationPermission == LocationPermission.denied ||
            locationPermission == LocationPermission.deniedForever) {
          setState(() {
            _searchData!.locationAddressForShow = 'Select Location';
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
          print("granted");
          fetchLocation();
          print('after fetching location');
        } else {
          setState(() {
            locationFetched = true;
            _searchData!.locationAddressForShow = 'Select Location';
          });
        }
      });
    }
  }
}
