import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:info_popup/info_popup.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/discover/bloc/discover_rent_bloc.dart';
import 'package:ridealike/pages/discover/request_service/discover_rent_request.dart';
import 'package:ridealike/pages/search_a_car/response_model/make_response_model.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';
import 'package:ridealike/pages/search_a_car/search.dart';
import 'package:ridealike/pages/search_a_car/search_car_sort_tab.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

import '../../utils/address_utils.dart';
import '../../widgets/slider_box.dart';
import '../common/location_util.dart';

class SearchCarSortBy extends StatefulWidget {
  SearchCarSortByTabState? object;

  SearchCarSortBy();

  @override
  _SearchCarSortByState createState() => _SearchCarSortByState();
}

class _SearchCarSortByState extends State<SearchCarSortBy> {
  final discoverRentBloc = DiscoverRentBloc();
  List _searchResultsMain = [];
  List _searchResults = [];
  bool carFetched = false;
  bool exitPressed = false;
  final storage = new FlutterSecureStorage();
  Position? _currentPosition;
  String? _currentAddress;
  LocationPermission? locationPermission;
  SearchData? _receivedData;
  double _distance = 0.0;
  String _sortBy = '';
  bool _showSuperHost = false;
  Set<int> selectedFilterIndex = {};
  int selectedCarFilterIndex = 0;
  RangeValues selectedPriceRange = RangeValues(0, 999);
  RangeValues _values = const RangeValues(0, 100);
  SearchData? _searchData;
  RangeLabels _labels = RangeLabels('0', '999');
  String _carType = "";
  List<String> _carTypeList = [];
  bool _hostWeeklyDiscount = false;
  bool _hostMonthlyDiscount = false;
  bool _hasDelivery = false;

  var textStyle = TextStyle(
      fontSize: 16,
      color: Color(0xff371D32),
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.normal);

  List<Map<String, dynamic>>? filters;

  // TODO filter
  void applyFilter() {
    print("Main:::${_searchResultsMain.length}");
    print("Search:::${_searchResults.length}");
    // Reset Data
    _searchResults.clear();
    _searchResults.addAll(_searchResultsMain.toList());
    // Sort
    if (_receivedData!.sortBy == 'LowToHigh') {
      _searchResults.sort((a, b) {
        return double.parse(a['Price'].toString().replaceAll('/day', '')) <
                double.parse(b['Price'].toString().replaceAll('/day', ''))
            ? -1
            : 1;
      });
    } else if (_receivedData!.sortBy == 'HighToLow') {
      _searchResults.sort((a, b) {
        return double.parse(a['Price'].toString().replaceAll('/day', '')) <
                double.parse(b['Price'].toString().replaceAll('/day', ''))
            ? 1
            : -1;
      });
    } else if (_receivedData!.sortBy == 'NearestToFarthest') {
      var longDecimal = _currentPosition!.longitude.toStringAsFixed(7);
      _searchResults.sort((a, b) {
        double valueA = distance(
            a['LatLng']['Latitude'],
            a['LatLng']['Longitude'],
            _currentPosition!.latitude,
            double.parse(longDecimal));
        double valueB = distance(
            b['LatLng']['Latitude'],
            b['LatLng']['Longitude'],
            _currentPosition!.latitude,
            double.parse(longDecimal));
        return valueA < valueB ? -1 : 1;
      });
    } else if (_receivedData!.sortBy == 'MostRecent') {
      _searchResults.sort((a, b) {
        return DateTime.parse(b['CreatedAt'])
            .compareTo(DateTime.parse(a['CreatedAt']));
      });
    } else if (_receivedData!.sortBy == 'VehicleMake') {
      _searchResults.sort((a, b) => a['Title']
          .toString()
          .toLowerCase()
          .compareTo(b['Title'].toString().toLowerCase()));
    }
    // Price
    _searchResults.removeWhere((element) =>
        double.parse(element['Price'].toString().replaceAll('/day', '')) <
            selectedPriceRange.start ||
        double.parse(element['Price'].toString().replaceAll('/day', '')) >
            selectedPriceRange.end);
    // Type
    if(_carTypeList.isNotEmpty){
      _searchResults.removeWhere((car) => !_carTypeList.contains(car['Type']));
    }
    // Host Discount
    if (_hostWeeklyDiscount) {
      _searchResults.removeWhere((element) {
        var pricing = element['Pricing']['RentalPricing'];
        return pricing['BookForWeekDiscountPercentage'] == 0;
      });
    }
    if (_hostMonthlyDiscount) {
      _searchResults.removeWhere((element) {
        var pricing = element['Pricing']['RentalPricing'];
        return pricing['BookForMonthDiscountPercentage'] == 0;
      });
    }
    // Super Host
    if (_showSuperHost) {
      _searchResults.removeWhere((car) => car['SuperHost'] == false);
    }
    if (_hasDelivery) {
      _searchResults.removeWhere((car) => car['Delivery'] == false);
    }
    setState(() {});
  }

  Color getBackgroundColor(int index) {
    if (index == 0) {
      return Colors.white;
    } else if (index == 1 &&
        _receivedData!.sortBy.isNotEmpty &&
        _receivedData!.sortBy != 'None') {
      return Color(0xffFF8F68);
    } else if (index == 2 &&
        (selectedPriceRange.start != 0 || selectedPriceRange.end != 999)) {
      return Color(0xffFF8F68);
    } else if (index == 3 && _carTypeList.isNotEmpty) {
      return Color(0xffFF8F68);
    } else if (index == 4 && (_hostMonthlyDiscount || _hostWeeklyDiscount)) {
      return Color(0xffFF8F68);
    } else {
      return selectedFilterIndex.contains(index)
          ? Color(0xffFF8F68)
          : Colors.white;
    }
  }

  Color getTextColor(int index) {
    if (index == 0) {
      return Colors.black;
    } else if (index == 1 &&
        _receivedData!.sortBy.isNotEmpty &&
        _receivedData!.sortBy != 'None') {
      return Colors.white;
    } else if (index == 2 &&
        (selectedPriceRange.start != 0 || selectedPriceRange.end != 999)) {
      return Colors.white;
    } else if (index == 3 && _carTypeList.isNotEmpty) {
      return Colors.white;
    } else if (index == 4 && (_hostMonthlyDiscount || _hostWeeklyDiscount)) {
      return Colors.white;
    } else {
      return selectedFilterIndex.contains(index) ? Colors.white : Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_receivedData == null) {
      _receivedData = ModalRoute.of(context)!.settings.arguments as SearchData;
    }
    double deviceFontSize = MediaQuery.of(context).textScaleFactor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 12.0, right: 12),
          child: Column(
            children: <Widget>[
              // Header

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          _receivedData!.sortBy = 'None';
                          Navigator.of(context).pop();
                        },
                        icon: new Icon(Icons.arrow_back,
                            color: Color(0xffFF8F68)),
                      ),
                      Text(
                        'Search',
                        style: TextStyle(
                            color: Color(0xff371D32),
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.2,
                            fontFamily: 'Urbanist',
                            fontSize: 28),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(
                height: 40,
                child: _searchResultsMain != null &&
                        _searchResultsMain.length > 0
                    ? ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters!.length,
                        itemBuilder: (context, index) {
                          if (index == 0){
                            return Container();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: selectedFilterIndex.contains(index)
                                      ? Color(0xffFF8F68)
                                      : Colors.white,
                                ),
                              ),
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  primary: Colors.black,
                                  /*backgroundColor:
                                      selectedFilterIndex.contains(index)
                                          ? Color(0xffFF8F68)
                                          : Colors.white,*/
                                  backgroundColor: getBackgroundColor(index),
                                  side: BorderSide(color: Colors.grey.shade400),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onPressed: () {
                                  filters![index]['onPressed']();
                                  if (index == 0) {
                                    return;
                                  } else if (index > 0 && index < 5) {
                                    return;
                                  } else {
                                    if (selectedFilterIndex.contains(index)) {
                                      selectedFilterIndex.remove(index);
                                    } else {
                                      selectedFilterIndex.add(index);
                                    }
                                  }
                                  setState(() {});
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      filters![index]['label'],
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: 'Urbanist',
                                        color: getTextColor(index),
                                        /*color:
                                            selectedFilterIndex.contains(index)
                                                ? Colors.white
                                                : Color(0xff353B50),*/
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    if (filters![index]['label'] == 'Filter')
                                      Image.asset(
                                        'icons/filter.png',
                                        width: 24,
                                        height: 24,
                                        color:
                                            selectedFilterIndex.contains(index)
                                                ? Colors.white
                                                : null,
                                      ),
                                    if (filters![index]['label'] == 'Sort By' ||
                                        filters![index]['label'] == 'Price' ||
                                        filters![index]['label'] ==
                                            'Car Type' ||
                                        filters![index]['label'] ==
                                            'Host Discount')
                                      Image.asset(
                                        'icons/arrow.png',
                                        width: 24,
                                        height: 24,
                                        color: getTextColor(index),
                                      )
                                    /*selectedFilterIndex.contains(index)
                                          ? Image.asset(
                                              'icons/arrow.png',
                                              width: 24,
                                              height: 24,
                                              color: Colors.white,
                                            )
                                          : Image.asset(
                                              'icons/arrow.png',
                                              width: 24,
                                              height: 24,
                                            )*/
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(),
              ),
              SizedBox(height: 10),
              // Cars list
              Expanded(
                child: _searchResults != null && _searchResults.length > 0
                    ? ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: false,
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          var latitude =
                              _searchResults[index]['LatLng']['Latitude'];
                          var longitude =
                              _searchResults[index]['LatLng']['Longitude'];
                          double distance = calculateDistance(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                            latitude,
                            longitude,
                          );
                          return GestureDetector(
                            onTap: () async {
                              String startDate = (_receivedData!.tripStartDate)!
                                  .toIso8601String();
                              String endDate = (_receivedData!.tripEndDate)!
                                  .toIso8601String();
                              var arguments = {
                                "CarID": _searchResults[index]['ID'],
                                "StartDate": startDate,
                                "EndDate": endDate,
                                "searchLatitude": _receivedData!.locationLat!,
                                "searchLongitude": _receivedData!.locationLon!,
                                "searchFormattedAddress":
                                    _receivedData!.formattedLocationAddress
                              };
                              String? userID =
                                  await storage.read(key: 'user_id');
                              if (userID != null) {
                                await addCarToViewedList(
                                    _searchResults[index]['ID'], userID);
                                discoverRentBloc.callFetchOnlyRecentlyViewed();
                              }
                              if (!exitPressed) {
                                exitPressed = true;
                                Navigator.pushNamed(context, '/car_details',
                                        arguments: arguments)
                                    .then((value) {
                                  exitPressed = false;
                                });
                              }
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 8),
                              width: double.maxFinite,
                              height: 276,
                              child: Column(
                                children: <Widget>[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        Image(
                                          height: 215,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .95,
                                          image: _searchResults[index]
                                                      ['ImageID'] ==
                                                  ""
                                              ? AssetImage(
                                                  'images/car-placeholder.png')
                                              : NetworkImage(
                                                  '$storageServerUrl/${_searchResults[index]['ImageID']}',
                                                ) as ImageProvider,
                                          fit: BoxFit.cover,
                                          errorBuilder: (BuildContext context,
                                              Object exception,
                                              StackTrace? stackTrace) {
                                            return Image.asset(
                                              'images/car-placeholder.png',
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .95,
                                              height: 215,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                        Align(
                                            alignment: Alignment.topLeft,
                                            child: _searchResults[index]
                                                    ['SuperHost']
                                                ? GestureDetector(
                                                    onTap: () {},
                                                    child: Container(
                                                      width: 140,
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      margin:
                                                          EdgeInsets.all(8.0),
                                                      decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withOpacity(0.9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          border: Border.all(
                                                              color: Color(
                                                                  0xffFF8F68),
                                                              width: 2.0)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Text(
                                                            _searchResults[
                                                                        index][
                                                                    'SuperHost']
                                                                ? 'Super Host'
                                                                : '',
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    Colors.black,
                                                                fontFamily:
                                                                    'Urbanist'),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          InfoPopupWidget(
                                                            arrowTheme:
                                                                InfoPopupArrowTheme(
                                                              color: Color(
                                                                  0xffFF8F68),
                                                              arrowDirection:
                                                                  ArrowDirection
                                                                      .up,
                                                            ),
                                                            contentTheme:
                                                                InfoPopupContentTheme(
                                                              infoContainerBackgroundColor:
                                                                  Color(
                                                                      0xFF575757),
                                                              infoTextStyle: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontSize: 16),
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              contentBorderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              10)),
                                                              infoTextAlign:
                                                                  TextAlign
                                                                      .start,
                                                            ),
                                                            contentTitle:
                                                                'Superhosts are the hosts who provide the ultimate rental experience. They own 3 or more cars, and are unlikely to cancel trip bookings.',
                                                            child: SvgPicture
                                                                .asset(
                                                              'svg/icon-i.svg',
                                                              width: 24,
                                                              height: 24,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container()),
                                      ],
                                    ),
                                  ),
                                  // SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                1.5,
                                            child: Text(
                                              _searchResults[index]['Title'],
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'Urbanist',
                                                color: Color(0xff353B50),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              SvgPicture.asset(
                                                'svg/location_orange.svg',
                                                width: 20,
                                                height: 20,
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              Row(
                                                children: [
                                                  Text(
                                                    '${distance.toStringAsFixed(1)} KM',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: 'Urbanist',
                                                      color: Color(0xff353B50),
                                                    ),
                                                  ),
                                                  Text(
                                                    ' away',
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: 'Urbanist',
                                                      color: Color(0xff353B50),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                width: 4,
                                              ),
                                              _searchResults[index] != null &&
                                                      _searchResults[index][
                                                              'NumberOfTrips'] !=
                                                          null &&
                                                      _searchResults[index][
                                                              'NumberOfTrips'] !=
                                                          '0'
                                                  ? Row(
                                                      children: [
                                                        Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Container(
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
                                                        ),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                      ],
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: <Widget>[
                                          Text(
                                            '\$' +
                                                _searchResults[index]['Price'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Urbanist',
                                              color: Color(0xff353B50),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                _searchResults[index]
                                                            ['Rating'] !=
                                                        0
                                                    ? _searchResults[index]
                                                            ['Rating']
                                                        .toStringAsFixed(1)
                                                    : '',
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black,
                                                    fontFamily: 'Urbanist',
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              _searchResults[index] != null &&
                                                      _searchResults[index][
                                                              'NumberOfTrips'] !=
                                                          null &&
                                                      _searchResults[index][
                                                              'NumberOfTrips'] !=
                                                          '0'
                                                  ? Icon(
                                                      Icons.star,
                                                      size: 18,
                                                      color: Color(0xffFF8F68),
                                                    )
                                                  : Icon(
                                                      Icons.star,
                                                      size: 0,
                                                      color: Color(0xffFF8F68),
                                                    ),
                                              _searchResults[index] != null &&
                                                      _searchResults[index][
                                                              'NumberOfTrips'] !=
                                                          null &&
                                                      _searchResults[index][
                                                              'NumberOfTrips'] !=
                                                          '0'
                                                  ? Text(
                                                      _searchResults[index][
                                                                  'NumberOfTrips'] !=
                                                              '1'
                                                          ? '(${_searchResults[index]['NumberOfTrips']} trips)'
                                                          : '(${_searchResults[index]['NumberOfTrips']} trip)',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontFamily: 'Urbanist',
                                                        color:
                                                            Color(0xff353B50),
                                                      ),
                                                    )
                                                  : Text(''),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : carFetched == true
                        ? Center(
                            child: Text(
                            'No results found. Please change your search criteria to show available vehicles.',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 20.0,
                                // fontWeight: FontWeight.bold,
                                fontFamily: 'Urbanist'),
                          ))
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new CircularProgressIndicator(strokeWidth: 2.5)
                              ],
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Visibility(
        visible: _searchResults != null && _searchResults.length > 0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            elevation: 5,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            backgroundColor: Color(0xff5BC0EB),
          ),
          child: SizedBox(
            width: deviceFontSize * 60,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  'MAP',
                  style: TextStyle(
                    color: Color(0xffFFFFFF),
                    letterSpacing: 0.4,
                    fontSize: 14,
                    fontFamily: 'Urbanist',
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Image.asset('icons/map.png'),
              ],
            ),
          ),
          onPressed: () {
            var arguments = {
              "_searchResults": _searchResults,
              "_receivedData": _receivedData
            };

            Navigator.pushNamed(context, '/search_car_map',
                    arguments: arguments)
                .then((value) {
              // if(widget.object != null) {
              //   widget.object.callFetchLoginState();
              // }
            });
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  double calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
            startLatitude, startLongitude, endLatitude, endLongitude) /
        1000;
  }

  Future callCurrentPosition() async {
    try {
      _currentPosition = await _getCurrentLocation();
      String geoLocation = await AddressUtils.getAddress(
          _currentPosition!.latitude, _currentPosition!.longitude);
      print(geoLocation);
      _currentAddress = geoLocation;
    } catch (e) {
      print(e);
    }
  }

  void checkLocation() {
    LocationUtil.requestPermission().then((value) {
      locationPermission = value;
      if (locationPermission == LocationPermission.denied ||
          locationPermission == LocationPermission.deniedForever) {
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
                  },
                ),
                CupertinoDialogAction(
                  child: Text('Settings'),
                  onPressed: () async {
                    Geolocator.openAppSettings().whenComplete(() {
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
      } else {}
    });
  }

  void dailyTripCost(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        context: context,
        builder: (_) {
          return Container(
            child: Wrap(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8.0),
                      topLeft: Radius.circular(8.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Daily Trip Cost',
                              style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Urbanist'),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.clear)),
                        ],
                      ),
                      RangeSliderBottomSheet(
                        selectedRange: selectedPriceRange,
                        onRangeSelected: (RangeValues range) {
                          selectedPriceRange = range;
                          print(
                              "${selectedPriceRange.start}::${selectedPriceRange.end}");
                          applyFilter();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  double deg2rad(double deg) {
    return (deg * math.pi / 180.0);
  }

  distance(double lat1, double lon1, double lat2, double lon2) {
    double theta = lon1 - lon2;
    double dist = math.sin(deg2rad(lat1)) * math.sin(deg2rad(lat2)) +
        math.cos(deg2rad(lat1)) *
            math.cos(deg2rad(lat2)) *
            math.cos(deg2rad(theta));
    dist = math.acos(dist);
    dist = rad2deg(dist);
    dist = dist * 60 * 1.1515;
    return (dist);
  }

  Future<http.Response> fetchAllCarResult(SearchData param) async {
    Map<String, CarMakes> carMakeMap = {};
    List<String> carMakeName = [];
    List<String> carModelName = [];

    if (param.carMake != null && param.carMake!.length != 0) {
      for (var i in param.carMake!) {
        carMakeMap[i.makeID!] = i;
      }
    }

    if (param.carModel != null && param.carModel!.length != 0) {
      for (var i in param.carModel!) {
        carModelName.add(i.name!);
        if (carMakeMap[i.makeID] != null) {
          carMakeMap.remove(i.makeID);
        }
      }
    }

    if (carMakeMap.keys.isNotEmpty) {
      for (var i in carMakeMap.keys) {
        carMakeName.add(carMakeMap[i]!.name!);
      }
    }

    AppEventsUtils.logEvent("car_searched", params: {
      "location": param.formattedLocationAddress,
      "start_date": param.tripStartDate != null
          ? param.tripStartDate!.toUtc().toIso8601String()
          : DateTime.now().toUtc().toIso8601String(),
      "end_date": param.tripEndDate != null
          ? param.tripEndDate!.toUtc().toIso8601String()
          : DateTime.now().add(Duration(days: 1)).toUtc().toIso8601String(),
      "number_of_days":
          (param.tripEndDate != null && param.tripStartDate != null)
              ? param.tripEndDate!.difference(param.tripStartDate!).inDays
              : 0
    });
    var body = json.encode({
      "Location": {
        "Latitude": param.locationLat,
        "Longitude": param.locationLon,
        "FormattedAddress": param.formattedLocationAddress
      },
      "TripDuration": {
        "StartDateTime": param.tripStartDate != null
            ? param.tripStartDate!.toUtc().toIso8601String()
            : DateTime.now().toUtc().toIso8601String(),
        "EndDateTime": param.tripEndDate != null
            ? param.tripEndDate!.toUtc().toIso8601String()
            : DateTime.now().add(Duration(days: 1)).toUtc().toIso8601String(),
      },
      "CarType": param.carType,
      "CarMake": carMakeName,
      "CarModel": carModelName,
      "GreenFeature": param.greenFeature,
      "NumberOfTrips": {
        "LowerRange": param.totalTripNumberLowerRange,
        "UpperRange": param.totalTripNumberUpperRange
      },
      "Seats": {
        "LowerRange": param.totalTripSeatsLowerRange,
        "UpperRange": param.totalTripSeatsUpperRange
      },
      "TotalTripCostRange": {
        "LowerRange": param.totalTripCostLowerRange,
        "UpperRange": param.totalTripCostUpperRange
      },
      "Mileage": {
        "LowerRange": param.totalTripMileageLowerRange,
        "UpperRange": param.totalTripMileageUpperRange
      },
      "Limit": "1000",
      "Skip": "0",
      "SortBy": param.sortBy,
      "SuperHost": param.superHost,
      "Delivery": param.deliveryAvailable,
      "Favourite": param.favourite,
      "Preference": {"IsSuitableForPets": param.isSuitableForPets}
    });
    print("Request Data $body");
    final response = await http.post(
      Uri.parse(searchCarUrl),
      body: body,
    );
    print("Response Data ${response.body}");

    if (response.statusCode == 200) {
      return response;
    } else {
      throw Exception('Failed to load data');
    }
  }

  fetchData() async {
    try {
      var res = await fetchAllCarResult(_receivedData!);
      print(json.decode(res.body)['Cars']);
      AppEventsUtils.logEvent("search_successful", params: {
        "carType": _receivedData!.carType,
        "carMake": _receivedData!.carMake,
        "searchStartDate": (_receivedData!.tripStartDate)!.toIso8601String(),
        "searchEndDate": (_receivedData!.tripEndDate)!.toIso8601String(),
        "searchLowPriceRange": _receivedData!.totalTripCostLowerRange,
        "searchMAxPriceRange": _receivedData!.totalTripCostUpperRange,
        "superHost": _receivedData!.superHost,
      });

      if (json.decode(res.body)['Cars'] != null) {
        setState(() {
          _searchResultsMain = json.decode(res.body)['Cars'];
          _searchResults.addAll(_searchResultsMain.toList());
          carFetched = true;
        });
        List<String> carIds = [];
        if (_searchResults != null) {
          _searchResults.forEach((element) {
            carIds.add(element['ID']);
          });
        }
        AppEventsUtils.logEvent("search_results_viewed", params: {
          "number_of_search_results":
              _searchResults == null ? 0 : _searchResults.length,
          "location": _receivedData!.formattedLocationAddress,
          "view_type": "List View",
          "car_ids_in_search": carIds,
          "start_date": (_receivedData!.tripStartDate)!.toIso8601String(),
          "end_date": (_receivedData!.tripEndDate)!.toIso8601String(),
        });
      } else {
        setState(() {
          _searchResultsMain = [];
          _searchResults.addAll(_searchResultsMain.toList());
          carFetched = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  fetchLocation() async {
    try {
      await callCurrentPosition();
      if (_currentPosition != null && _currentAddress != null) {
        var res = await fetchAllCarResult(
          _receivedData!,
        );
        print(json.decode(res.body)['Cars']);
        AppEventsUtils.logEvent("search_successful", params: {
          "carType": _receivedData!.carType,
          "carMake": _receivedData!.carMake,
          "searchStartDate": (_receivedData!.tripStartDate)!.toIso8601String(),
          "searchEndDate": (_receivedData!.tripEndDate)!.toIso8601String(),
          "searchLowPriceRange": _receivedData!.totalTripCostLowerRange,
          "searchMAxPriceRange": _receivedData!.totalTripCostUpperRange,
          "superHost": _receivedData!.superHost,
          "delivery": _receivedData!.deliveryAvailable,
          "favourite": _receivedData!.favourite,
          "Preference": {"IsSuitableForPets": _receivedData!.isSuitableForPets}
        });

        if (json.decode(res.body)['Cars'] != null) {
          setState(() {
            _searchResultsMain = json.decode(res.body)['Cars'];
            _searchResults.addAll(_searchResultsMain.toList());
            carFetched = true;
          });
        } else {
          setState(() {
            _searchResultsMain = [];
            _searchResults.addAll(_searchResultsMain.toList());
            carFetched = true;
          });
        }
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("search_car_sort_by");
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      // TODO filter
      filters = [
        {
          'label': 'Filter',
          'icon': 'icons/filter.png',
          'onPressed': () => modalBottomSheetMenu()
        },
        {
          'label': 'Sort By',
          'icon': 'icons/arrow.png',
          'onPressed': () => searchBottomMenu()
        },
        {
          'label': 'Price',
          'icon': 'icons/arrow.png',
          'onPressed': () {
            dailyTripCost(context);
          }
        },
        {
          'label': 'Car Type',
          'icon': 'icons/arrow.png',
          'onPressed': () => showModalBottomSheet(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              context: context,
              builder: (_) {
                return StatefulBuilder(builder: (BuildContext context,
                    StateSetter setModalState /*You can rename this!*/) {
                  return Container(
                    child: Wrap(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8.0),
                              topLeft: Radius.circular(8.0),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        /*Text(
                                        'Sort by',
                                        style: TextStyle(
                                          color: Color(0xff371D32),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Urbanist',
                                        ),
                                      ),
                                      SizedBox(
                                        width: 4,
                                      ),
                                      SvgPicture.asset(
                                        'svg/icon-i.svg',
                                        width: 20,
                                        height: 20,
                                      ),*/
                                        Text(
                                          'Select Car Type',
                                          style: TextStyle(
                                            color: Color(0xff371D32),
                                            fontSize: 18,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: 'Urbanist',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Icon(Icons.clear),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Wrap(
                                alignment: WrapAlignment.start,
                                children: [
                                  //Economy Car//
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _carTypeList
                                          .contains('Economy Car')
                                          ? Color(0xffFF8F68)
                                          : Colors.white,
                                      primary: Colors.black,
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    onPressed: () {
                                      if (_carTypeList
                                          .contains('Economy Car')) {
                                        _carTypeList.remove('Economy Car');
                                      } else {
                                        _carTypeList.add('Economy Car');
                                      }
                                      setModalState(() {});
                                    },
                                    child:
                                        Text('Economy Car', style: textStyle),
                                  ),

                                  SizedBox(
                                    width: 5,
                                  ),
                                  //Mid/Full Size Car//
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                      _carTypeList
                                          .contains('Mid/Full Size Car')
                                              ? Color(0xffFF8F68)
                                              : Colors.white,
                                      primary: Colors.black,
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    onPressed: () {
                                      if (_carTypeList
                                          .contains('Mid/Full Size Car')) {
                                        _carTypeList
                                            .remove('Mid/Full Size Car');
                                      } else {
                                        _carTypeList.add('Mid/Full Size Car');
                                      }
                                      setModalState((){});
                                    },
                                    child: Text('Mid/Full Size Car',
                                        style: textStyle),
                                  ),

                                  SizedBox(
                                    width: 5,
                                  ),
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _carTypeList.contains('SUV')
                                          ? Color(0xffFF8F68)
                                          : Colors.white,
                                      primary: Colors.black,
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    onPressed: () {
                                      if (_carTypeList.contains('SUV')) {
                                        _carTypeList.remove('SUV');
                                      } else {
                                        _carTypeList.add('SUV');
                                      }
                                      setModalState((){});
                                    },
                                    child: Text('SUV', style: textStyle),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  //Mini Van//
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _carTypeList.contains('Mini Van')
                                          ? Color(0xffFF8F68)
                                          : Colors.white,
                                      primary: Colors.black,
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    onPressed: () {
                                      if (_carTypeList.contains('Mini Van')) {
                                        _carTypeList.remove('Mini Van');
                                      } else {
                                        _carTypeList.add('Mini Van');
                                      }
                                      setModalState((){});
                                    },
                                    child: Text('Mini Van', style: textStyle),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  //Van//
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _carTypeList.contains('Van')
                                          ? Color(0xffFF8F68)
                                          : Colors.white,
                                      primary: Colors.black,
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    onPressed: () {
                                      if (_carTypeList.contains('Van')) {
                                        _carTypeList.remove('Van');
                                      } else {
                                        _carTypeList.add('Van');
                                      }
                                      setModalState((){});
                                    },
                                    child: Text('Van', style: textStyle),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  //Pickup Truck//
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor:
                                      _carTypeList
                                          .contains('Pickup Truck')
                                              ? Color(0xffFF8F68)
                                              : Colors.white,
                                      primary: Colors.black,
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    onPressed: () {
                                      if (_carTypeList
                                          .contains('Pickup Truck')) {
                                        _carTypeList.remove('Pickup Truck');
                                      } else {
                                        _carTypeList.add('Pickup Truck');
                                      }
                                      setModalState((){});
                                    },
                                    child:
                                        Text('Pickup Truck', style: textStyle),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
// Sports Car //
                                  OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      backgroundColor: _carTypeList.contains('Sports Car')
                                          ? Color(0xffFF8F68)
                                          : Colors.white,
                                      primary: Colors.black,
                                      side: BorderSide(
                                          color: Colors.grey.shade400),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                    ),
                                    onPressed: () {
                                      if (_carTypeList.contains('Sports Car')) {
                                        _carTypeList.remove('Sports Car');
                                      } else {
                                        _carTypeList.add('Sports Car');
                                      }
                                      setModalState((){});
                                    },
                                    child: Text('Sports Car', style: textStyle),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              // TODO
                              SizedBox(
                                height: 45,
                                width: MediaQuery.of(context).size.width,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 8.0, right: 8),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xffFF8F68)),
                                    onPressed: () {
                                      _carTypeList.forEach((element) {
                                        debugPrint(element);
                                      });
                                      applyFilter();
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Apply',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          fontFamily: 'Urbanist'),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
              })
        },
        {
          'label': 'Host Discount',
          'icon': 'icons/arrow.png',
          'onPressed': () => showModalBottomSheet(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
              ),
              context: context,
              builder: (_) {
                return StatefulBuilder(builder: (BuildContext context,
                    StateSetter setModalState /*You can rename this!*/) {
                  return Container(
                    child: Wrap(
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(8.0),
                              topLeft: Radius.circular(8.0),
                            ),
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Align(
                                    alignment: Alignment.center,
                                    child: Row(
                                      children: [
                                        Text(
                                          'Host Discount',
                                          style: TextStyle(
                                              color: Color(0xff371D32),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Urbanist'),
                                        ),
                                        /*SizedBox(
                                        width: 4,
                                      ),
                                      SvgPicture.asset(
                                        'svg/icon-i.svg',
                                        width: 20,
                                        height: 20,
                                      ),*/
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Icon(Icons.clear)),
                                ],
                              ),
                              SizedBox(height: 20),
                              //weekly discount//
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Weekly Discount',
                                    style: textStyle,
                                  ),
                                  CupertinoSwitch(
                                    activeColor: Color(0xffFF8F62),
                                    trackColor: Colors.grey,
                                    value: _hostWeeklyDiscount,
                                    onChanged: (value) {
                                      setModalState(() {
                                        _hostWeeklyDiscount = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Divider(
                                  thickness: 1, color: Colors.grey.shade300),
                              //monthly discount//
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    'Monthly Discount',
                                    style: textStyle,
                                  ),
                                  CupertinoSwitch(
                                    activeColor: Color(0xffFF8F62),
                                    trackColor: Colors.grey,
                                    value: _hostMonthlyDiscount,
                                    onChanged: (value) {
                                      setModalState(() {
                                        _hostMonthlyDiscount = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Divider(
                                  thickness: 1, color: Colors.grey.shade300),
                              SizedBox(
                                height: 6,
                              ),
                              SizedBox(
                                height: 45,
                                width: MediaQuery.of(context).size.width,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xffFF8F68),
                                  ),
                                  onPressed: () {
                                    applyFilter();
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Apply',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Urbanist'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                });
              })
        },
        // {
        //   'label': 'Eco-friendly',
        //   'icon': 'icons/arrow.png',
        //   'onPressed': () => showModalBottomSheet(
        //       backgroundColor: Colors.transparent,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.only(
        //             topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        //       ),
        //       context: context,
        //       builder: (_) {
        //         return Container(
        //           child: Wrap(
        //             children: <Widget>[
        //               Container(
        //                 padding: EdgeInsets.all(16),
        //                 decoration: BoxDecoration(
        //                   color: Colors.white,
        //                   borderRadius: BorderRadius.only(
        //                     topRight: Radius.circular(8.0),
        //                     topLeft: Radius.circular(8.0),
        //                   ),
        //                 ),
        //                 child: Column(
        //                   children: <Widget>[
        //                     Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       children: <Widget>[
        //                         Align(
        //                           alignment: Alignment.center,
        //                           child: Text(
        //                             'Eco-Friendly',
        //                             style: TextStyle(
        //                                 color: Color(0xff371D32),
        //                                 fontSize: 18,
        //                                 fontWeight: FontWeight.w600,
        //                                 fontFamily: 'Urbanist'),
        //                           ),
        //                         ),
        //                         GestureDetector(
        //                             onTap: () {
        //                               Navigator.pop(context);
        //                             },
        //                             child: Icon(Icons.clear)),
        //                       ],
        //                     ),
        //                     SizedBox(height: 20),
        //                     InkWell(
        //                       onTap: () async {
        //                         Navigator.pop(context);
        //                       },
        //                       child: Row(
        //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                         children: <Widget>[
        //                           Text(
        //                             'Electric',
        //                             style: textStyle,
        //                           ),
        //                           _receivedData!.sortBy == 'GreenFeature'
        //                               ? Radio(
        //                                   value: 'GreenFeature',
        //                                   groupValue: _receivedData!.ecoSortBy,
        //                                   onChanged: (value) {
        //                                     setState(() {
        //                                       _receivedData!.ecoSortBy =
        //                                           value.toString();
        //                                     });
        //                                   },
        //                                 )
        //                               : Container(),
        //                         ],
        //                       ),
        //                     ),
        //                     Divider(),
        //                     InkWell(
        //                       onTap: () async {
        //                         Navigator.pop(context);
        //                       },
        //                       child: Row(
        //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                         children: <Widget>[
        //                           Text(
        //                             'Hybrid',
        //                             style: textStyle,
        //                           ),
        //                           _receivedData!.sortBy == 'GreenFeature'
        //                               ? Radio(
        //                                   value: 'GreenFeature',
        //                                   groupValue: _receivedData!.sortBy,
        //                                   onChanged: (value) {
        //                                     setState(() {
        //                                       _receivedData!.sortBy =
        //                                           value.toString();
        //                                     });
        //                                   },
        //                                 )
        //                               : Container(),
        //                         ],
        //                       ),
        //                     ),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //         );
        //       })
        // },
        {
          'label': 'Super Host',
          'icon': 'icons/arrow.png',
          'onPressed': () {
            _showSuperHost = !_showSuperHost;
            applyFilter();
          }
        },
        {
          'label': 'Delivery Available',
          'icon': 'icons/arrow.png',
          'onPressed': () {
            _hasDelivery = !_hasDelivery;
            applyFilter();
          }
        },
      ];
      //fetchData();
      checkLocation();
    });
  }

  void modalBottomSheetMenu() {
    showModalBottomSheet(
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (_) {
          return FractionallySizedBox(heightFactor: 8 / 10, child: Search());
        });
  }

  double rad2deg(double rad) {
    return (rad * 180.0 / math.pi);
  }

  void searchBottomMenu() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        ),
        context: context,
        builder: (_) {
          return Container(
            child: Wrap(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8.0),
                      topLeft: Radius.circular(8.0),
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Sort By',
                              style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Urbanist'),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(Icons.clear)),
                        ],
                      ),
                      SizedBox(height: 20),
                      // Low to high//
                      InkWell(
                        onTap: () async {
                          _receivedData!.sortBy = 'LowToHigh';
                          applyFilter();
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Price: low to high',
                              style: textStyle,
                            ),
                            Radio(
                              value: 'LowToHigh',
                              groupValue: _receivedData!.sortBy,
                              onChanged: (value) {
                                setState(() {
                                  _receivedData!.sortBy = value.toString();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      //Divider(),
                      // High to low
                      InkWell(
                        onTap: () async {
                          _receivedData!.sortBy = 'HighToLow';
                          applyFilter();
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Price: high to low',
                              style: textStyle,
                            ),
                            Radio(
                              value: 'HighToLow',
                              groupValue: _receivedData!.sortBy,
                              onChanged: (value) {
                                setState(() {
                                  _receivedData!.sortBy = value.toString();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      //Divider(),
                      // Nearest to farthest
                      InkWell(
                        onTap: () async {
                          _receivedData!.sortBy = 'NearestToFarthest';
                          applyFilter();
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Distance: nearest to farthest',
                              style: textStyle,
                            ),
                            Radio(
                              value: 'NearestToFarthest',
                              groupValue: _receivedData!.sortBy,
                              onChanged: (value) {
                                setState(() {
                                  _receivedData!.sortBy = value.toString();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      //Divider(),
                      //most recent//
                      InkWell(
                        onTap: () async {
                          _receivedData!.sortBy = 'MostRecent';
                          applyFilter();
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Most recent',
                              style: textStyle,
                            ),
                            Radio(
                              value: 'MostRecent',
                              groupValue: _receivedData!.sortBy,
                              onChanged: (value) {
                                setState(() {
                                  _receivedData!.sortBy = value.toString();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      //Divider(),

                      //vehicle make//
                      InkWell(
                        onTap: () async {
                          _receivedData!.sortBy = 'VehicleMake';
                          applyFilter();
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Vehicle make',
                              style: textStyle,
                            ),
                            Radio(
                              value: 'VehicleMake',
                              groupValue: _receivedData!.sortBy,
                              onChanged: (value) {
                                setState(() {
                                  _receivedData!.sortBy = value.toString();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<Position> _getCurrentLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }
}
