import 'dart:convert';

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
import 'package:http/http.dart' as http;
import '../../widgets/shimmer.dart';
import '../common/constant_url.dart';

class Search extends StatefulWidget {
  SearchTabState? object;

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Position? _currentPosition;
  String? _currentAddress;
  Map? receivedData;
  var currentAddressValue;
  LocationPermission? locationPermission;
  bool locationGetSuccess = false;
  bool locationFetched = false;
  bool showLocation = false;
  bool _isHybridChecked = false;
  bool _isElectricChecked = false;
  bool isSelected = false;
  List? _carTypeData;

  List<String> _selectedCarTypes = [];

  var arrowTextStyle = TextStyle(
      color: Colors.grey,
      fontSize: 14,
      fontFamily: 'Urbanist',
      fontWeight: FontWeight.normal,
      letterSpacing: -0.2);
  var textStyle = TextStyle(
      color: Colors.black,
      letterSpacing: 0.2,
      fontFamily: 'Urbanist',
      fontSize: 16,
      fontWeight: FontWeight.w500);

  bool dataFetched = false;
  bool showExtraFields = true;
  bool carMakeSelected = false;
  var selectedRange = RangeValues(1, 999);
  var dailyMileageSelectedRange = RangeValues(0, 3000);
  var numberOfSeatsSelectedRange = RangeValues(2, 10);
  var numberOfTripsSelectedRange = RangeValues(0, 50);
  RangeLabels _numberOfTripsLabels = RangeLabels('1', '50');
  RangeLabels _numberOfSeatsLabels = RangeLabels('2', '10');
  RangeLabels _labels = RangeLabels('1', '999');
  SearchData? _searchData;
  bool value = false;
  bool _petFriendlySwitchValue = false;
  bool _deliverySwitchValue = false;
  bool _favouriteSwitchValue = false;
  bool _superHostSwitchValue = false;
  bool _weeklySwitchValue = false;
  bool _monthlySwitchValue = false;
  bool _electricSwitchValue = false;
  bool _hybridSwitchValue = false;
  List<String> greenFeature = [];
  List<String> carType = [];

  @override
  Widget build(BuildContext context) {
    final SearchData? receivedData =
        ModalRoute.of(context)?.settings.arguments as SearchData?;

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
          totalTripSeatsLowerRange: 2,
          totalTripSeatsUpperRange: 10,
          totalTripCostUpperRange: 999,
          totalTripNumberLowerRange: 1,
          totalTripNumberUpperRange: 50,
          superHost: false,
          deliveryAvailable: false,
          favourite: false,
          isSuitableForPets: false);
    }

    void toggleFeature(String feature) {
      setState(() {
        if (greenFeature.contains(feature)) {
          greenFeature.remove(feature);
        } else {
          greenFeature.add(feature);
        }
        _searchData!.greenFeature = greenFeature;
      });
    }

    void toggleCarType(String type) {
      setState(() {
        if (carType.contains(type)) {
          carType.remove(type);
        } else {
          carType.add(type);
        }
        _searchData!.carType = carType;
      });
    }

    Future<List<String>> fetchCarType() async {
      final response = await http.post(
        Uri.parse(getAllEnlistedCarTypesUrl),
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        List<dynamic> carTypes = json.decode(response.body)['CarTypes'];
        return carTypes.map((type) => type.toString()).toList();
      } else {
        throw Exception('Failed to load data');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          'Search',
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 26,
              fontFamily: 'Urbanist',
              letterSpacing: -0.2,
              color: Color(0xff371D32)),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: new Icon(
                  Icons.clear,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ],
        elevation: 0.0,
      ),
      body: locationFetched
          ? SingleChildScrollView(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PICKUP AND RETURN',
                                style: TextStyle(
                                    color: Color(0xff371D32).withOpacity(0.5),
                                    letterSpacing: 0.2,
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    //TODO hour issue
                                    DateTime _start =
                                        DateTime.now().add(Duration(hours: 2));
                                    DateTime _temp =
                                        DateTime.now().add(Duration(days: 4));
                                    //DateTime _end = _temp.subtract(Duration(hours: DateTime.now().hour));
                                    DateTime _end =
                                        _temp.add(Duration(hours: 2));
                                    _searchData = SearchData(
                                        locationLat: _currentPosition!.latitude,
                                        locationLon:
                                            _currentPosition!.longitude,
                                        locationAddress: _currentAddress,
                                        tripStartDate: _start,
                                        tripEndDate: _end,
                                        sortBy: 'None',
                                        carType: [],
                                        carMake: [],
                                        carModel: [],
                                        greenFeature: [],
                                        totalTripCostLowerRange: 1,
                                        totalTripCostUpperRange: 999,
                                        totalTripNumberLowerRange: 0,
                                        totalTripNumberUpperRange: 50,
                                        superHost: false,
                                        deliveryAvailable: false,
                                        favourite: false,
                                        isSuitableForPets: false);
                                    showLocation = false;
                                    _superHostSwitchValue = false;
                                    _deliverySwitchValue = false;
                                    numberOfSeatsSelectedRange =
                                        RangeValues(2, 10);
                                    selectedRange = RangeValues(1, 999);
                                    numberOfTripsSelectedRange =
                                        RangeValues(0, 50);
                                    dailyMileageSelectedRange =
                                        RangeValues(0, 3000);
                                    _labels = RangeLabels('1', '999');
                                  });
                                },
                                child: Center(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 0),
                                    child: Text(
                                      'Reset search',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFFFF8F62),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(),
                          // Location
                          InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                      context, '/search_car_location',
                                      arguments: _searchData)
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    showLocation =
                                        (value as Map)['showLocation'];
                                    _searchData = (value)['searchData'];
                                  });
                                }
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Text('Location',
                                      style: TextStyle(
                                        color: Color(0xff371D32),
                                        fontSize: 20,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.normal,
                                      )),
                                ),
                                Expanded(
                                    child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    SizedBox(width: 16),
                                    Flexible(
                                      child: Text(
                                          _searchData!.locationAddressForShow,
                                          textAlign: TextAlign.right,
                                          //     showLocation ==false && currentAddressValue!=''? 'Current location':_searchData!.locationAddress != '' ?
                                          // _searchData!.locationAddress : 'Select location',
                                          // overflow: TextOverflow.clip,
                                          // softWrap: false,
                                          style: TextStyle(
                                            color: Color(0xff371D32),
                                            fontSize: 20,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.normal,
                                          )),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      width: 16,
                                      child: Icon(Icons.keyboard_arrow_right,
                                          color: Color(0xff353B50)),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Trip duration
                          InkWell(
                            onTap: () {
                              _searchData!.read = true;
                              Navigator.pushNamed(
                                      context, '/search_car_trip_duration',
                                      arguments: _searchData)
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    _searchData = value as SearchData;
                                  });
                                }
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Text('Trip duration',
                                      style: TextStyle(
                                        color: Color(0xff371D32),
                                        fontSize: 20,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.normal,
                                      )),
                                ),
                                Row(
                                  children: <Widget>[
                                    Text(
                                      _searchData!.tripStartDate != null
                                          ? DateFormat('MMM dd').format(
                                                  _searchData!.tripStartDate!) +
                                              ' - ' +
                                              DateFormat('MMM dd').format(
                                                  _searchData!.tripEndDate!)
                                          : 'select dates',
                                      style: TextStyle(
                                        color: Color(0xff371D32),
                                        fontSize: 20,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      width: 16,
                                      child: Icon(Icons.keyboard_arrow_right,
                                          color: Color(0xff353B50)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Visibility(
                            visible: showExtraFields,
                            child: Text(
                              'DAILY TRIP COST',
                              style: TextStyle(
                                  color: Color(0xff371D32).withOpacity(0.5),
                                  letterSpacing: 0.2,
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 6,
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '\$${selectedRange.start.floor().toString()}',
                                style: TextStyle(
                                    color: Color(0xff371D32),
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2),
                              ),
                              Text(
                                ' to \$${selectedRange.end.floor().toString()}' +
                                    '/day',
                                style: TextStyle(
                                    color: Color(0xff371D32),
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: -0.2),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: showExtraFields,
                            child: SliderTheme(
                              data: SliderThemeData(
                                thumbColor: Color(0xffFFFFFF),
                                minThumbSeparation: 1.2,
                                trackShape: RoundedRectSliderTrackShape(),
                                trackHeight: 2.0,
                                activeTrackColor: Color(0xffFF8F62),
                                inactiveTrackColor: Color(0xFFE0E0E0),
                                tickMarkShape: RoundSliderTickMarkShape(
                                    tickMarkRadius: 4.0),
                                activeTickMarkColor: Color(0xffFF8F62),
                                inactiveTickMarkColor: Color(0xFFE0E0E0),
                                showValueIndicator: ShowValueIndicator.always,
                                valueIndicatorColor: Colors.white,
                                valueIndicatorTextStyle: TextStyle(
                                    color: Color(0xff353B50),
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: -0.2),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 10.0,
                                  elevation: 3.0,
                                ),
                              ),
                              child: RangeSlider(
                                  min: 1,
                                  max: 999,
                                  values: selectedRange,
                                  // labels: _labels,
                                  onChanged: (newRangeValues) {
                                    double startNew =
                                        (newRangeValues.start / 5);
                                    double endNew = (newRangeValues.end / 5);
                                    startNew = startNew.round() * 5.0;
                                    endNew = endNew.round() * 5.0;

                                    if (startNew == 0) {
                                      startNew = 1.0;
                                    }

                                    if (endNew == 1000) {
                                      endNew = 999.0;
                                    }
                                    setState(() {
                                      selectedRange =
                                          RangeValues(startNew, endNew);
                                      _labels = RangeLabels(
                                          '\$${selectedRange.start.toInt().toString()}',
                                          '\$${selectedRange.end.toInt().toString()}');
                                      _searchData!.totalTripCostLowerRange =
                                          selectedRange.start;
                                      _searchData!.totalTripCostUpperRange =
                                          selectedRange.end;
                                    });
                                  }),
                            ),
                          ),

                          ExpansionTile(
                            trailing: Image.asset(
                              "icons/arrow (1).png",
                              width: 25,
                              height: 25,
                            ),
                            title: Text(
                              'CAR TYPE',
                              style: TextStyle(
                                  color: Color(0xff371D32).withOpacity(0.5),
                                  letterSpacing: 0.2,
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                            children: [
                              SingleChildScrollView(
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final maxWidth = constraints.maxWidth;
                                    final minWidthForHorizontal = 200.0;

                                    return ListTile(
                                      title: FutureBuilder<List<String>>(
                                        future: fetchCarType(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            List<String> carTypes =
                                                snapshot.data ?? [];
                                            final canDisplayHorizontally =
                                                maxWidth >=
                                                    minWidthForHorizontal;

                                            return canDisplayHorizontally
                                                ? Wrap(
                                                    spacing: 8.0,
                                                    runSpacing: 8.0,
                                                    children:
                                                        carTypes.map((type) {
                                                      return InkWell(
                                                        onTap: () {
                                                          toggleCarType(type);
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey
                                                                    .shade300),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          child: Text(
                                                            type,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xff371D32),
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  )
                                                : Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .stretch,
                                                    children:
                                                        carTypes.map((type) {
                                                      return InkWell(
                                                        onTap: () {
                                                          toggleCarType(type);
                                                        },
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                                color: Colors
                                                                    .grey),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          padding:
                                                              EdgeInsets.all(
                                                                  8.0),
                                                          margin:
                                                              EdgeInsets.only(
                                                                  bottom: 8.0),
                                                          child: Text(
                                                            type,
                                                            style: TextStyle(
                                                              color: Color(
                                                                  0xff371D32),
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                  );
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Text('Type',
                                          style: TextStyle(
                                            color: Color(0xff371D32),
                                            fontSize: 20,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.normal,
                                          )),
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Text(
                                          _searchData!.carType == null ||
                                                  _searchData!
                                                          .carType!.length ==
                                                      0
                                              ? 'Select type'
                                              : _searchData!.carType!.length ==
                                                      1
                                                  ? _searchData!.carType![0]
                                                  : 'Multiple',
                                          style: TextStyle(
                                            color: Color(0xff371D32),
                                            fontSize: 20,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              Divider(
                                color: Colors.grey,
                              ),
                              // Car makes
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        if (_searchData!.carType != null &&
                                            (_searchData!.carType)!.length >
                                                0) {
                                          Navigator.pushNamed(
                                                  context, '/search_car_make',
                                                  arguments: _searchData)
                                              .then((value) {
                                            if (value != null) {
                                              setState(() {
                                                _searchData =
                                                    value as SearchData;
                                              });
                                            }
                                          });
                                        }
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text('Make',
                                              style: TextStyle(
                                                color: Color(0xff371D32),
                                                fontSize: 20,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.normal,
                                              )),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                _searchData!.carMake == null ||
                                                        _searchData!.carMake!
                                                                .length ==
                                                            0
                                                    ? 'Select make'
                                                    : _searchData!.carMake!
                                                                .length ==
                                                            1
                                                        ? _searchData!
                                                            .carMake![0]
                                                            .name as String
                                                        : 'Multiple',
                                                style: TextStyle(
                                                  color: Color(0xff371D32),
                                                  fontSize: 20,
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              SizedBox(width: 8.0),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: Colors.grey,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        if (_searchData!.carType != null &&
                                            (_searchData!.carType)!.length >
                                                0 &&
                                            _searchData!.carMake != null &&
                                            (_searchData!.carMake)!.length > 0)
                                          Navigator.pushNamed(
                                                  context, '/search_car_model',
                                                  arguments: _searchData)
                                              .then((value) {
                                            if (value != null) {
                                              setState(() {
                                                _searchData =
                                                    value as SearchData;
                                              });
                                            }
                                          });
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Container(
                                            child: Text('Model',
                                                style: TextStyle(
                                                  color: Color(0xff371D32),
                                                  fontSize: 20,
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.normal,
                                                )),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                  _searchData!.carModel ==
                                                              null ||
                                                          _searchData!.carModel!
                                                                  .length ==
                                                              0
                                                      ? 'Select model'
                                                      : _searchData!.carModel!
                                                                  .length ==
                                                              1
                                                          ? _searchData!
                                                              .carModel![0]
                                                              .name as String
                                                          : 'Multiple',
                                                  style: TextStyle(
                                                    color: Color(0xff371D32),
                                                    fontSize: 20,
                                                    fontFamily: 'Urbanist',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                  )),
                                              SizedBox(width: 8),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
                          // Car types

                          ExpansionTile(
                            trailing: Image.asset(
                              "icons/arrow (1).png",
                              width: 25,
                              height: 25,
                            ),
                            title: Text('DOORS AND SEATS',
                                style: TextStyle(
                                    color: Color(0xff371D32).withOpacity(0.5),
                                    letterSpacing: 0.2,
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                            children: [
                              ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                      value: false,
                                                      onChanged:
                                                          (bool? value) {},
                                                    ),
                                                    Text(
                                                      '2+ ',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff371D32),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                        checkColor:
                                                            Colors.white,
                                                        value: true,
                                                        onChanged:
                                                            (bool? value) {}),
                                                    Text(
                                                      '4+',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff371D32),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Checkbox(
                                                        checkColor:
                                                            Colors.white,
                                                        value: true,
                                                        onChanged:
                                                            (bool? value) {}),
                                                    Text(
                                                      '6+',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff371D32),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          ExpansionTile(
                            trailing: Image.asset(
                              "icons/arrow (1).png",
                              width: 25,
                              height: 25,
                            ),
                            title: Text('HOST DISCOUNT',
                                style: TextStyle(
                                    color: Color(0xff371D32).withOpacity(0.5),
                                    letterSpacing: 0.2,
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                            children: [
                              ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Weekly ',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff371D32),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    CupertinoSwitch(
                                                      activeColor:
                                                          Color(0xffFF8F62),
                                                      trackColor: Colors.grey,
                                                      value: _weeklySwitchValue,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _weeklySwitchValue =
                                                              value;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Monthly',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff371D32),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    CupertinoSwitch(
                                                      activeColor:
                                                          Color(0xffFF8F62),
                                                      trackColor: Colors.grey,
                                                      value:
                                                          _monthlySwitchValue,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _monthlySwitchValue =
                                                              value;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
                          ExpansionTile(
                            trailing: Image.asset(
                              "icons/arrow (1).png",
                              width: 25,
                              height: 25,
                            ),
                            title: Text('GREEN FEATURE',
                                style: TextStyle(
                                    color: Color(0xff371D32).withOpacity(0.5),
                                    letterSpacing: 0.2,
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500)),
                            children: [
                              ListTile(
                                title: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Electric',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff371D32),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    CupertinoSwitch(
                                                      activeColor:
                                                          Color(0xffFF8F62),
                                                      trackColor: Colors.grey,
                                                      value:
                                                          _electricSwitchValue,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _electricSwitchValue =
                                                              value;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'Hybrid',
                                                      style: TextStyle(
                                                        color:
                                                            Color(0xff371D32),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                    CupertinoSwitch(
                                                      activeColor:
                                                          Color(0xffFF8F62),
                                                      trackColor: Colors.grey,
                                                      value: _hybridSwitchValue,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          _hybridSwitchValue =
                                                              value;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),

                          Divider(
                            color: Colors.grey,
                          ),
                          /*InkWell(
                            onTap: () {
                              Navigator.pushNamed(
                                      context, '/search_car_green_feature',
                                      arguments: _searchData)
                                  .then((value) {
                                if (value != null) {
                                  setState(() {
                                    _searchData = value as SearchData;
                                  });
                                }
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left:12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Text('ECO-FRIENDLY',
                                        style: TextStyle(
                                            color: Color(0xff371D32)
                                                .withOpacity(0.5),
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left:12.0),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _searchData!.greenFeature == null ||
                                              _searchData!.greenFeature!.length ==
                                                  0
                                          ? 'Select Green Feature'
                                          : _searchData!.greenFeature!.length > 1
                                              ? 'Multiple'
                                              : _searchData!.greenFeature![0],
                                      style: TextStyle(
                                        color: Color(0xff371D32),
                                        fontSize: 20,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),*/
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text('NUMBER OF SEATS', style: textStyle),
                          //     Row(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         CircleWithText(
                          //           text: '2+',
                          //           size: 35.0,
                          //           textColor: Color(0xff353B50),
                          //           backgroundColor: Colors.white,
                          //           borderColor: Colors.grey.shade300,
                          //           borderWidth: 1.0, onPressed: () {  },
                          //         ),
                          //         CircleWithText(
                          //           text: '4+',
                          //           size: 35.0,
                          //           textColor: Color(0xff353B50),
                          //           backgroundColor: Colors.white,
                          //           borderColor: Colors.grey.shade300,
                          //           borderWidth: 1.0, onPressed: () {
                          //
                          //         },
                          //         ),
                          //         CircleWithText(
                          //           text: '5+',
                          //           size: 35.0,
                          //           textColor: Color(0xff353B50),
                          //           backgroundColor: Colors.white,
                          //           borderColor: Colors.grey.shade300,
                          //           borderWidth: 1.0, onPressed: () {  },
                          //         ),
                          //
                          //         CircleWithText(
                          //           text: '6+',
                          //           size: 35.0,
                          //           textColor: Color(0xff353B50),
                          //           backgroundColor: Colors.white,
                          //           borderColor: Colors.grey.shade300,
                          //           borderWidth: 1.0, onPressed: () {  },
                          //         ),
                          //       ],
                          //     ),
                          //
                          //   ],
                          // ),
                          //Divider(thickness:1,color: Colors.grey.shade300,),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.start,
                          //   children: [
                          //     Text('NUMBER OF DOORS', style: textStyle),
                          //     Row(
                          //       mainAxisAlignment: MainAxisAlignment.start,
                          //       crossAxisAlignment: CrossAxisAlignment.start,
                          //       children: [
                          //         CircleWithText(
                          //           text: '2+',
                          //           size: 35.0,
                          //           textColor: Color(0xff353B50),
                          //           backgroundColor: Colors.white,
                          //           borderColor: Colors.grey.shade300,
                          //           borderWidth: 1.0, onPressed: () {  },
                          //         ),
                          //         CircleWithText(
                          //           text: '4+',
                          //           size: 35.0,
                          //           textColor: Color(0xff353B50),
                          //           backgroundColor: Colors.white,
                          //           borderColor: Colors.grey.shade300,
                          //           borderWidth: 1.0, onPressed: () {
                          //
                          //         },
                          //         ),
                          //
                          //       ],
                          //     ),
                          //
                          //   ],
                          // ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              'Number Of Seats',
                              style: TextStyle(
                                  color: Color(0xff371D32).withOpacity(0.5),
                                  letterSpacing: 0.2,
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${numberOfSeatsSelectedRange.start.floor().toString()}',
                                style: TextStyle(
                                    color: Color(0xff371D32),
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2),
                              ),
                              Text(
                                ' to ${numberOfSeatsSelectedRange.end.floor().toString()}' +
                                    ' Seats',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontSize: 16,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                            child: SliderTheme(
                              data: SliderThemeData(
                                thumbColor: Color(0xffFFFFFF),
                                minThumbSeparation: 1.2,
                                trackShape: RoundedRectSliderTrackShape(),
                                trackHeight: 2.0,
                                activeTrackColor: Color(0xffFF8F62),
                                inactiveTrackColor: Color(0xFFE0E0E0),
                                tickMarkShape: RoundSliderTickMarkShape(
                                    tickMarkRadius: 4.0),
                                activeTickMarkColor: Color(0xffFF8F62),
                                inactiveTickMarkColor: Color(0xFFE0E0E0),
                                showValueIndicator: ShowValueIndicator.always,
                                valueIndicatorColor: Colors.white,
                                valueIndicatorTextStyle: TextStyle(
                                    color: Color(0xff353B50),
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: -0.2),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 10.0,
                                  elevation: 3.0,
                                ),
                              ),
                              child: RangeSlider(
                                  min: 2,
                                  max: 10,
                                  values: numberOfSeatsSelectedRange,
                                  onChanged: (newRangeValues) {
                                    double startNew = newRangeValues.start;
                                    double endNew = newRangeValues.end;
                                    if (startNew == 0) {
                                      startNew = 1.0;
                                    }
                                    setState(() {
                                      numberOfSeatsSelectedRange =
                                          RangeValues(startNew, endNew);
                                      _numberOfSeatsLabels = RangeLabels(
                                          '\$${numberOfSeatsSelectedRange.start.toInt().toString()}',
                                          '\$${numberOfSeatsSelectedRange.end.toInt().toString()}');
                                      _searchData!.totalTripSeatsLowerRange =
                                          numberOfSeatsSelectedRange.start;
                                      _searchData!.totalTripSeatsLowerRange =
                                          numberOfSeatsSelectedRange.end;
                                    });
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              'DAILY MILEAGE',
                              style: TextStyle(
                                  color: Color(0xff371D32).withOpacity(0.5),
                                  letterSpacing: 0.2,
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${dailyMileageSelectedRange.start.floor().toString()}',
                                style: TextStyle(
                                    color: Color(0xff371D32),
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2),
                              ),
                              Text(
                                ' to ${dailyMileageSelectedRange.end.floor().toString()}' +
                                    ' KM per day limit',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontSize: 16,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                            child: SliderTheme(
                              data: SliderThemeData(
                                thumbColor: Color(0xffFFFFFF),
                                minThumbSeparation: 1.2,
                                trackShape: RoundedRectSliderTrackShape(),
                                trackHeight: 2.0,
                                activeTrackColor: Color(0xffFF8F62),
                                inactiveTrackColor: Color(0xFFE0E0E0),
                                tickMarkShape: RoundSliderTickMarkShape(
                                    tickMarkRadius: 4.0),
                                activeTickMarkColor: Color(0xffFF8F62),
                                inactiveTickMarkColor: Color(0xFFE0E0E0),
                                showValueIndicator: ShowValueIndicator.always,
                                valueIndicatorColor: Colors.white,
                                valueIndicatorTextStyle: TextStyle(
                                    color: Color(0xff353B50),
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: -0.2),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 10.0,
                                  elevation: 3.0,
                                ),
                              ),
                              child: RangeSlider(
                                  min: 0,
                                  max: 3000,
                                  values: dailyMileageSelectedRange,
                                  onChanged: (newRangeValues) {
                                    double startNew =
                                        (newRangeValues.start / 5);
                                    double endNew = (newRangeValues.end / 5);
                                    startNew = startNew.round() * 5.0;
                                    endNew = endNew.round() * 5.0;
                                    if (startNew == 0) {
                                      startNew = 1.0;
                                    }
                                    setState(() {
                                      dailyMileageSelectedRange =
                                          RangeValues(startNew, endNew);
                                      _labels = RangeLabels(
                                          '\$${dailyMileageSelectedRange.start.toInt().toString()}',
                                          '\$${dailyMileageSelectedRange.end.toInt().toString()}');
                                      _searchData!.totalTripMileageLowerRange =
                                          dailyMileageSelectedRange.start;
                                      _searchData!.totalTripMileageUpperRange =
                                          dailyMileageSelectedRange.end;
                                    });
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 12.0),
                            child: Text(
                              'Number Of Trips',
                              style: TextStyle(
                                  color: Color(0xff371D32).withOpacity(0.5),
                                  letterSpacing: 0.2,
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${numberOfTripsSelectedRange.start.floor().toString()}',
                                style: TextStyle(
                                    color: Color(0xff371D32),
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 2),
                              ),
                              Text(
                                ' to ${numberOfTripsSelectedRange.end.floor().toString()}' +
                                    ' completed trips',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontSize: 16,
                                  fontFamily: 'Urbanist',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Visibility(
                            child: SliderTheme(
                              data: SliderThemeData(
                                thumbColor: Color(0xffFFFFFF),
                                minThumbSeparation: 1.2,
                                trackShape: RoundedRectSliderTrackShape(),
                                trackHeight: 2.0,
                                activeTrackColor: Color(0xffFF8F62),
                                inactiveTrackColor: Color(0xFFE0E0E0),
                                tickMarkShape: RoundSliderTickMarkShape(
                                    tickMarkRadius: 4.0),
                                activeTickMarkColor: Color(0xffFF8F62),
                                inactiveTickMarkColor: Color(0xFFE0E0E0),
                                showValueIndicator: ShowValueIndicator.always,
                                valueIndicatorColor: Colors.white,
                                valueIndicatorTextStyle: TextStyle(
                                    color: Color(0xff353B50),
                                    fontSize: 16,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.normal,
                                    letterSpacing: -0.2),
                                thumbShape: RoundSliderThumbShape(
                                  enabledThumbRadius: 10.0,
                                  elevation: 3.0,
                                ),
                              ),
                              child: RangeSlider(
                                  min: 0,
                                  max: 50,
                                  values: numberOfTripsSelectedRange,
                                  onChanged: (newRangeValues) {
                                    double startNew =
                                        (newRangeValues.start / 1);
                                    double endNew = (newRangeValues.end / 1);
                                    startNew = startNew.round() * 1.0;
                                    endNew = endNew.round() * 1.0;

                                    if (startNew == 0) {
                                      startNew = 1.0;
                                    }
                                    setState(() {
                                      numberOfTripsSelectedRange =
                                          RangeValues(startNew, endNew);
                                      _numberOfTripsLabels = RangeLabels(
                                          '\$${numberOfTripsSelectedRange.start.toInt().toString()}',
                                          '\$${numberOfTripsSelectedRange.end.toInt().toString()}');
                                      _searchData!.totalTripNumberLowerRange =
                                          numberOfTripsSelectedRange.start;
                                      _searchData!.totalTripNumberUpperRange =
                                          numberOfTripsSelectedRange.end;
                                    });
                                  }),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  shape: BoxShape.rectangle),
                              height: 45,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset('svg/super_host.svg'),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Row(
                                          children: [
                                            Text('Super Host',
                                                style: textStyle),
                                            SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: CupertinoSwitch(
                                      activeColor: Color(0xffFF8F62),
                                      trackColor: Colors.grey,
                                      value: _superHostSwitchValue,
                                      onChanged: (value) {
                                        setState(() {
                                          _superHostSwitchValue = value;
                                          _searchData!.superHost = value;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  shape: BoxShape.rectangle),
                              height: 45,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset('svg/Layer_1.svg'),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Row(
                                          children: [
                                            Text('Delivery Available',
                                                style: textStyle),
                                            SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: CupertinoSwitch(
                                      activeColor: Color(0xffFF8F62),
                                      trackColor: Colors.grey,
                                      value: _deliverySwitchValue,
                                      onChanged: (value) {
                                        setState(() {
                                          _deliverySwitchValue = value;
                                          _searchData!.deliveryAvailable =
                                              value;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          /*SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  shape: BoxShape.rectangle),
                              height: 45,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                            'svg/ic_twotone-favorite.svg'),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Row(
                                          children: [
                                            Text('Favourites',
                                                style: textStyle),
                                            SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: CupertinoSwitch(
                                      activeColor: Color(0xffFF8F62),
                                      trackColor: Colors.grey,
                                      value: _favouriteSwitchValue,
                                      onChanged: (value) {
                                        setState(() {
                                          _favouriteSwitchValue = value;
                                          _searchData!.favourite = value;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  shape: BoxShape.rectangle),
                              height: 45,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15),
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                            'svg/pet-friendly.svg'),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Row(
                                          children: [
                                            Text('Pet-Friendly',
                                                style: textStyle),
                                            SizedBox(
                                              width: 5,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 15),
                                    child: CupertinoSwitch(
                                      activeColor: Color(0xffFF8F62),
                                      trackColor: Colors.grey,
                                      value: _petFriendlySwitchValue,
                                      onChanged: (value) {
                                        setState(() {
                                          _petFriendlySwitchValue = value;
                                          _searchData!.isSuitableForPets =
                                              value;
                                        });
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),*/
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),

                      // Next button
                      Row(
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
                                    onPressed:
                                        _searchData!.locationAddress == null ||
                                                _searchData!.locationAddress ==
                                                    '' ||
                                                _searchData!.tripStartDate ==
                                                    null ||
                                                _searchData!.tripEndDate == null
                                            ? null
                                            : () {
                                                Navigator.pushNamed(context,
                                                        '/search_car_sort_tab',
                                                        arguments: _searchData)
                                                    .then((value) {
                                                  if (widget.object != null) {
                                                    //TODO
                                                  }
                                                });
                                                print(_searchData);
                                              },
                                    child: Text(
                                      'Search',
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              child: ShimmerEffect(),
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
    AppEventsUtils.logEvent("page_viewed", params: {"page_name": "Search"});
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
