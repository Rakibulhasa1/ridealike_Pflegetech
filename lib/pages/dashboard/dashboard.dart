import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../widgets/dashboard_shimmer.dart';
import '../../widgets/shimmer.dart';

Future<http.Response> fetchCarData(_userID, jwt) async {
  final response = await http.post(
    Uri.parse(getCarsByUserIDUrl),
    // getCarsByUserIDUrl as Uri,
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({
      "UserID": _userID,
    }),
  );

  if (response.statusCode == 200) {
    print('carResponse$response');
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<http.Response> fetchUserTransactionData(_userID, jwt) async {
  final response = await http.post(
    Uri.parse(getAllTransactionByUserIDUrl),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({"UserID": _userID, "Limit": "0", "Skip": "0"}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<http.Response> fetchCarTransactionData(_carID, jwt) async {
  final response = await http.post(
    Uri.parse(getAllTransactionByCarIDUrl),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({"CarID": _carID, "Limit": "0", "Skip": "0"}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<http.Response> fetchCarsRatingData(_carIDs, jwt) async {
  final response = await http.post(
    Uri.parse(getAllReviewByCarIDsUrl),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({"CarIDs": _carIDs, "Limit": "0", "Skip": "0"}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<http.Response> fetchCarRatingData(_carID, jwt) async {
  final response = await http.post(
    Uri.parse(getAllReviewByCarIDUrl),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({"CarID": _carID, "Limit": "0", "Skip": "0"}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<RestApi.Resp> fetchUserPastTripsData(_userID, _carID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getAllUserTripsByStatusGroupUrl,
    json.encode({
      "Limit": "100",
      "Skip": "0",
      "UserID": _userID,
      "CarID": _carID,
      "TripStatusGroup": "Past"
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<Resp> attemptToDeleteCar(_carID) async {
  var deleteCarCompleter = Completer<Resp>();

  callAPI(
    deleteCarUrl,
    json.encode({"CarID": _carID}),
  ).then((resp) {
    deleteCarCompleter.complete(resp);
  });

  return deleteCarCompleter.future;
}

const textStyle = TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontFamily: 'Urbanist',
    fontWeight: FontWeight.bold);

class Dashboard extends StatefulWidget {
  @override
  State createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  var groupStatusResp;
  String _userId = '';
  CreateCarResponse? createCarResponseData;
  List _carsData = [];
  String _selectedCarID = '';
  Map _selectedCarData = {};
  List _pastTrips = [];
  String? _carID;
  Map _overallTransactionData = {};
  Map _specificTransactionData = {};
  String _overallIncome = '';
  String _specificIncome = '';

  List _overallCarReviewData = [];
  List _specificCarReviewData = [];
  String _overallRating = '';
  String _specificRating = '';

  List _overallTripsData = [];

  // List _specificCarTripsData = [];
  TripAllUserStatusGroupResponse? _specificCarTripsData;
  String _overallTrips = '';
  var _specificTrips;

  bool _listingCompleted = true;
  bool loader = false;
  final storage = new FlutterSecureStorage();

  bool isDataAvailable = false;

  DateTime today = new DateTime.now();

  int? numberOfTotalTrips;

  int numberOfCanceledTrips = 0;

  bool _calendarClicked = false;
  CreateCarResponse? createCarResponse;

  late num specificIncome;

  @override
  void initState() {
    super.initState();

    //AppEventsUtils.logEvent("dashboard_view");
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Dashboard"});

    callFetchProfileData().then((value) {
      Future.delayed(Duration.zero, () async {
        dynamic receivedData = ModalRoute.of(context)!.settings.arguments;
        if (receivedData != null && receivedData['SELECTED_CAR_ID'] != null) {
          _selectedCarID = receivedData['SELECTED_CAR_ID'];
          var item;
          for (var carData in _carsData) {
            if (carData['ID'] == _selectedCarID) {
              item = carData;
              break;
            }
          }

          setState(() {
            loader = true;
          });
          String? jwt = await storage.read(key: 'jwt');

          int tempTotal = item['NumberOfTrips'] != null
              ? int.parse(item['NumberOfTrips'])
              : 0;
          int tempCanceledTrips = item['NumberOfCancelledTrips'] != null
              ? int.parse(item['NumberOfCancelledTrips'])
              : 0;

          var res4 = await fetchCarTransactionData(item['ID'], jwt);
          var res5 = await fetchCarRatingData(item['ID'], jwt);
          var res6 = await fetchUserPastTripsData(_userId, item['ID']);

          specificIncome = json.decode(res4.body)['ThisMonthsIncome'];
          print("Spe$specificIncome");
          // List _tempTripData = json.d;ecode(res6.body!)['Trips'];
          groupStatusResp =
              TripAllUserStatusGroupResponse.fromJson(json.decode(res6.body!));
          setState(() {
            loader = false;
            _selectedCarID = item['ID'];
            _selectedCarData = item;

            numberOfTotalTrips = tempTotal;
            numberOfCanceledTrips = tempCanceledTrips;

            if (item['About']['Completed'] &&
                item['ImagesAndDocuments']['Completed'] &&
                item['Features']['Completed'] &&
                item['Preference']['Completed'] &&
                item['Availability']['Completed'] &&
                item['Pricing']['Completed']) {
              _listingCompleted = true;

              _specificTransactionData = json.decode(res4.body!);
              _specificCarReviewData =
                  json.decode(res5.body!)['CarRatingReviews'];
              _specificCarTripsData = groupStatusResp;

              _specificIncome = specificIncome!.toStringAsFixed(2);
              _specificRating = item['Rating'].toStringAsFixed(1);
              _specificTrips = _specificCarTripsData;
            } else {
              _listingCompleted = false;
            }
          });
        }
      });
    });
  }

  Future<void> callFetchProfileData() async {
    String? userID = await storage.read(key: 'user_id');
    print('UserID$userID');
    String? jwt = await storage.read(key: 'jwt');

    if (userID != null) {
      var res = await fetchCarData(userID, jwt);
      print('cardata${res.body}');

      var res1 = await fetchUserTransactionData(userID, jwt);
      var _tempCarIds = [];

      var tempTotal = 0;
      var tempCanceledTrips = 0;
      for (int z = 0; z < json.decode(res.body!)['Cars'].length; z++) {
        _tempCarIds.add(json.decode(res.body!)['Cars'][z]['ID']);

        if (json.decode(res.body!)['Cars'][z]['NumberOfTrips'] != null) {
          tempTotal +=
              int.parse(json.decode(res.body!)['Cars'][z]['NumberOfTrips']);
        }
        if (json.decode(res.body!)['Cars'][z]['NumberOfCancelledTrips'] !=
            null) {
          tempCanceledTrips += int.parse(
              json.decode(res.body!)['Cars'][z]['NumberOfCancelledTrips']);
        }
      }

      var res2 = await fetchCarsRatingData(_tempCarIds, jwt);
      var res3 = await fetchUserPastTripsData(userID, "");

      num overallIncome = 0;
      num overallRating = 0;

      overallIncome = json.decode(res1.body!)['ThisMonthsIncome'];
      for (int j = 0;
          j < json.decode(res2.body!)['CarRatingReviews'].length;
          j++) {
        overallRating +=
            json.decode(res2.body!)['CarRatingReviews'][j]['Rating'];
      }

      _pastTrips = json.decode(res3.body!)['Trips'];
      if (mounted) {
        setState(() {
          _userId = userID;
          numberOfTotalTrips = tempTotal;
          numberOfCanceledTrips = tempCanceledTrips;

          _carsData = json.decode(res.body!)['Cars'];
          _carsData.removeWhere((element) => element["About"]["Make"] == "");

          _overallTransactionData = json.decode(res1.body!);
          _overallCarReviewData = json.decode(res2.body!)['CarRatingReviews'];
          print('overAllrating$_overallCarReviewData');
          _overallTripsData = _pastTrips;

          _overallIncome = overallIncome.toStringAsFixed(2);
          _overallRating = _overallCarReviewData.length > 0
              ? (overallRating / _overallCarReviewData.length)
                  .toStringAsFixed(1)
              : '0.0';
          _overallTrips = _overallTripsData.length.toString();
          isDataAvailable = true;
        });
      }

      if (_carsData.length == 1) {
        Future.delayed(Duration.zero, () async {
          _selectedCarID = _carsData[0]['ID'];
          var item = _carsData[0];

          setState(() {
            loader = true;
          });
          String? jwt = await storage.read(key: 'jwt');

          int tempTotal = item['NumberOfTrips'] != null
              ? int.parse(item['NumberOfTrips'])
              : 0;
          int tempCanceledTrips = item['NumberOfCancelledTrips'] != null
              ? int.parse(item['NumberOfCancelledTrips'])
              : 0;

          var res4 = await fetchCarTransactionData(item['ID'], jwt);
          var res5 = await fetchCarRatingData(item['ID'], jwt);
          var res6 = await fetchUserPastTripsData(_userId, item['ID']);

          // double specificIncome;
          specificIncome = json.decode(res4.body!)['ThisMonthsIncome'];
          print("specificIncome $specificIncome");

          groupStatusResp =
              TripAllUserStatusGroupResponse.fromJson(json.decode(res6.body!));
          var trips = <Trips>[];
          for (Trips t in groupStatusResp.trips) {
            trips.add(t);
          }
          groupStatusResp.trips = trips;
          groupStatusResp.userID = userID;

          setState(() {
            loader = false;
            _selectedCarID = item['ID'];
            _selectedCarData = item;

            numberOfTotalTrips = tempTotal;
            numberOfCanceledTrips = tempCanceledTrips;

            if (item['About']['Completed'] &&
                item['ImagesAndDocuments']['Completed'] &&
                item['Features']['Completed'] &&
                item['Preference']['Completed'] &&
                item['Availability']['Completed'] &&
                item['Pricing']['Completed']) {
              _listingCompleted = true;

              _specificTransactionData = json.decode(res4.body!);
              _specificCarReviewData =
                  json.decode(res5.body!)['CarRatingReviews'];
              _specificCarTripsData = groupStatusResp;
              _specificIncome = specificIncome!.toStringAsFixed(2);
              _specificRating = item['Rating'].toStringAsFixed(1);
              print('specificRating$_specificCarReviewData');
              _specificTrips = _specificCarTripsData;
            } else {
              _listingCompleted = false;
            }
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFDFDFD),
      body: _overallTrips != null || _specificTrips != null
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Stack(
                    children: [
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(height: 40),
                              // Header and plus button
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12, top: 12),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'Dashboard',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 28,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Column(
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pushNamed(
                                              context,
                                              '/what_will_happen_next_ui',
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            primary: Color(0xffFF8F68),
                                          ),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                'icons/plus.png',
                                              ),
                                              SizedBox(width: 8),
                                              Text(
                                                'List your vehicle',
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                          // backgroundColor: Color(0xffFFFFFF),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6),
                              // Sub header
                              // Padding(
                              //   padding: const EdgeInsets.only(
                              //       left: 12.0, right: 12),
                              //   child: Text(
                              //     'MY VEHICLES',
                              //     style: TextStyle(
                              //         fontFamily: 'Urbanist',
                              //         fontSize: 16,
                              //         color: Colors.black,
                              //         fontWeight: FontWeight.w600),
                              //   ),
                              // ),
                              // SizedBox(
                              //   height: 10,
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12),
                                child: Text(
                                  'Select a vehicle to manage its calendar or edit its listing.',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              SizedBox(height: 5),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: _carsData.length > 0
                                      ? [
                                          _carsData.length > 1
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10,
                                                          bottom: 12,
                                                          right: 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        loader = true;
                                                      });
                                                      int tempCanceledTrips = 0;
                                                      int tempTotal = 0;
                                                      for (var car
                                                          in _carsData) {
                                                        if (car['NumberOfTrips'] !=
                                                            null) {
                                                          tempTotal +=
                                                              int.parse(car[
                                                                  'NumberOfTrips']);
                                                        }
                                                        if (car['NumberOfCancelledTrips'] !=
                                                            null) {
                                                          tempCanceledTrips +=
                                                              int.parse(car[
                                                                  'NumberOfCancelledTrips']);
                                                        }
                                                      }

                                                      setState(() {
                                                        loader = false;
                                                        _selectedCarID = '';
                                                        numberOfTotalTrips =
                                                            tempTotal;
                                                        numberOfCanceledTrips =
                                                            tempCanceledTrips;
                                                        _listingCompleted =
                                                            true;
                                                        // _selectedCarData = {};
                                                      });
                                                      // print(_selectedCarID);
                                                    },
                                                    child: Container(
                                                      width: 140,
                                                      height: 165,
                                                      decoration: BoxDecoration(
                                                        color: _selectedCarID ==
                                                                ''
                                                            ? Colors.white
                                                            : Color(0xffF2F2F2),
                                                        border: Border.all(
                                                          width: 1,
                                                          color: _selectedCarID ==
                                                                  ''
                                                              ? Color(
                                                                  0xffF68E65)
                                                              : Colors
                                                                  .transparent,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16.0),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2),
                                                            spreadRadius: 2,
                                                            blurRadius: 2,
                                                            offset:
                                                                Offset(0, 2),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              topLeft: Radius
                                                                  .circular(
                                                                      16.0),
                                                              topRight: Radius
                                                                  .circular(
                                                                      16.0),
                                                            ),
                                                            child: Image.asset(
                                                              'images/overAllCar.png',
                                                              height: 122,
                                                              width: 140,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                          ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .only(
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      16.0),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          16.0),
                                                            ),
                                                            child: Container(
                                                              height: 40,
                                                              width: 140,
                                                              color: Color(
                                                                  0xffF68E65),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                'Overall',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : new Container(),
                                          for (var item in _carsData)
                                            item['About']['Make'] != ''
                                                ? Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                bottom: 12,
                                                                right: 10),
                                                        child: Container(
                                                          width: 140,
                                                          height: 165,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _selectedCarID ==
                                                                    item['ID']
                                                                ? Color(
                                                                    0xffF68E65)
                                                                : Colors.white,
                                                            border: Border.all(
                                                              width: 1,
                                                              color: _selectedCarID ==
                                                                      item['ID']
                                                                  ? Color(
                                                                      0xffF68E65)
                                                                  : Colors
                                                                      .transparent,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        16.0),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color: Colors
                                                                    .black
                                                                    .withOpacity(
                                                                        0.2),
                                                                spreadRadius: 2,
                                                                blurRadius: 4,
                                                                offset: Offset(
                                                                    0, 2),
                                                              ),
                                                            ],
                                                          ),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () async {
                                                              setState(() {
                                                                loader = true;
                                                              });
                                                              String? jwt =
                                                                  await storage
                                                                      .read(
                                                                          key:
                                                                              'jwt');

                                                              int tempTotal = item[
                                                                          'NumberOfTrips'] !=
                                                                      null
                                                                  ? int.parse(item[
                                                                      'NumberOfTrips'])
                                                                  : 0;
                                                              int tempCanceledTrips =
                                                                  item['NumberOfCancelledTrips'] !=
                                                                          null
                                                                      ? int.parse(
                                                                          item[
                                                                              'NumberOfCancelledTrips'])
                                                                      : 0;

                                                              var res4 =
                                                                  await fetchCarTransactionData(
                                                                      item[
                                                                          'ID'],
                                                                      jwt);
                                                              var res5 =
                                                                  await fetchCarRatingData(
                                                                      item[
                                                                          'ID'],
                                                                      jwt);
                                                              var res6 =
                                                                  await fetchUserPastTripsData(
                                                                      _userId,
                                                                      item[
                                                                          'ID']);

                                                              specificIncome = json
                                                                      .decode(res4
                                                                          .body!)[
                                                                  'ThisMonthsIncome'];
                                                              groupStatusResp =
                                                                  TripAllUserStatusGroupResponse
                                                                      .fromJson(
                                                                          json.decode(
                                                                              res6.body!));

                                                              setState(() {
                                                                loader = false;
                                                                _selectedCarID =
                                                                    item['ID'];
                                                                _selectedCarData =
                                                                    item;
                                                                numberOfTotalTrips =
                                                                    tempTotal;
                                                                numberOfCanceledTrips =
                                                                    tempCanceledTrips;

                                                                if (item['About']['Completed'] &&
                                                                    item['ImagesAndDocuments']
                                                                        [
                                                                        'Completed'] &&
                                                                    item['Features']
                                                                        [
                                                                        'Completed'] &&
                                                                    item['Preference']
                                                                        [
                                                                        'Completed'] &&
                                                                    item['Availability']
                                                                        [
                                                                        'Completed'] &&
                                                                    item['Pricing']
                                                                        [
                                                                        'Completed']) {
                                                                  _listingCompleted =
                                                                      true;
                                                                  _specificTransactionData =
                                                                      json.decode(
                                                                          res4.body);
                                                                  _specificCarReviewData =
                                                                      json.decode(
                                                                              res5.body)[
                                                                          'CarRatingReviews'];
                                                                  _specificCarTripsData =
                                                                      groupStatusResp;

                                                                  specificIncome ==
                                                                          0.0
                                                                      ? _specificIncome =
                                                                          'You have no earnings yet'
                                                                      : _specificIncome =
                                                                          '\$${specificIncome.toStringAsFixed(2)}';

                                                                  item['Rating'] ==
                                                                          0.0
                                                                      ? _specificRating =
                                                                          'You have no reviews yet'
                                                                      : _specificRating = item[
                                                                              'Rating']
                                                                          .toStringAsFixed(
                                                                              1);

                                                                  _specificTrips =
                                                                      _specificCarTripsData;
                                                                } else {
                                                                  _listingCompleted =
                                                                      false;
                                                                }
                                                              });
                                                            },
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Stack(
                                                                  children: [
                                                                    // Image Section
                                                                    ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .only(
                                                                        topLeft:
                                                                            Radius.circular(16.0),
                                                                        topRight:
                                                                            Radius.circular(16.0),
                                                                      ),
                                                                      child: item['ImagesAndDocuments']['Images']['MainImageID'] !=
                                                                              ""
                                                                          ? Image
                                                                              .network(
                                                                              '$storageServerUrl/${item['ImagesAndDocuments']['Images']['MainImageID']}',
                                                                              height: 122,
                                                                              width: 140,
                                                                              fit: BoxFit.cover,
                                                                            )
                                                                          : Image
                                                                              .asset(
                                                                              'images/car-placeholder.png',
                                                                              height: 122,
                                                                              width: 140,
                                                                              fit: BoxFit.cover,
                                                                            ),
                                                                    ),

                                                                    Positioned(
                                                                        top: 8,
                                                                        left: 8,
                                                                        child: item['Verification'] != null &&
                                                                                item['Verification']['VerificationStatus'] != null
                                                                            ? item['Verification']['VerificationStatus'] == 'Verified'
                                                                                ? Image.asset('images/verified.png', width: 25, height: 25)
                                                                                : item['Verification']['VerificationStatus'] == 'Rejected'
                                                                                    ? SvgPicture.asset('svg/Group 17.svg', width: 25, height: 25)
                                                                                    : item['Verification']['VerificationStatus'] == 'Blocked'
                                                                                        ? SvgPicture.asset('svg/blocked.svg', width: 25, height: 25)
                                                                                        : SvgPicture.asset('svg/incomplete.svg', width: 25, height: 25)
                                                                            : Text(
                                                                                'Incomplete',
                                                                                style: TextStyle(
                                                                                  fontFamily: 'Urbanist',
                                                                                  fontSize: 16,
                                                                                  color: Colors.black,
                                                                                  fontWeight: FontWeight.w600,
                                                                                ),
                                                                              )),
                                                                  ],
                                                                ),
                                                                Container(
                                                                  height: 40,
                                                                  width: 100,
                                                                  color: _selectedCarID ==
                                                                          item[
                                                                              'ID']
                                                                      ? Color(
                                                                          0xffF68E65)
                                                                      : Colors
                                                                          .white,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              8.0),
                                                                  child: Text(
                                                                    item['About']['Year'] +
                                                                        ' ' +
                                                                        item['About']
                                                                            [
                                                                            'Make'] +
                                                                        ' ' +
                                                                        item['About']
                                                                            [
                                                                            'Model'],
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      fontSize:
                                                                          14,
                                                                      color: _selectedCarID ==
                                                                              item[
                                                                                  'ID']
                                                                          ? Colors
                                                                              .white
                                                                          : Colors
                                                                              .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),

                                                      ///car status//
                                                      // _selectedCarID ==
                                                      //         item['ID']
                                                      //     ? item['Verification']
                                                      //                     [
                                                      //                     'VerificationStatus'] !=
                                                      //                 null &&
                                                      //             item['Verification']
                                                      //                     [
                                                      //                     'VerificationStatus'] !=
                                                      //                 'Pending'
                                                      //         ? Text(
                                                      //             item['Verification']
                                                      //                 [
                                                      //                 'VerificationStatus'],
                                                      //             style: TextStyle(
                                                      //                 fontFamily:
                                                      //                     'Urbanist',
                                                      //                 fontSize:
                                                      //                     14,
                                                      //                 color: Colors
                                                      //                     .black,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .w600),
                                                      //           )
                                                      //         : Text(
                                                      //             'Incomplete',
                                                      //             style: TextStyle(
                                                      //                 fontFamily:
                                                      //                     'Urbanist',
                                                      //                 fontSize:
                                                      //                     14,
                                                      //                 color: Colors
                                                      //                     .black,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .w600),
                                                      //           )
                                                      //     : Container(),
                                                    ],
                                                  )
                                                :
                                                //unnamed car//
                                                _selectedCarID != null
                                                    ? Column(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    bottom: 5,
                                                                    right: 10),
                                                            child:
                                                                ElevatedButton(
                                                              style:
                                                                  ElevatedButton
                                                                      .styleFrom(
                                                                elevation: 0.0,
                                                                backgroundColor:
                                                                    _selectedCarID ==
                                                                            item[
                                                                                'ID']
                                                                        ? Colors
                                                                            .white
                                                                        : Color(
                                                                            0xffF2F2F2),
                                                                // textColor: Color(
                                                                //     0xff371D32),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            10.0),
                                                                shape:
                                                                    RoundedRectangleBorder(
                                                                  side: BorderSide(
                                                                      width: 1,
                                                                      color: _selectedCarID ==
                                                                              item[
                                                                                  'ID']
                                                                          ? Color(
                                                                              0xffF68E65)
                                                                          : Colors
                                                                              .transparent),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0),
                                                                ),
                                                              ),
                                                              onPressed:
                                                                  () async {
                                                                setState(() {
                                                                  loader = true;
                                                                });
                                                                String? jwt =
                                                                    await storage
                                                                        .read(
                                                                            key:
                                                                                'jwt');

                                                                var res4 =
                                                                    await fetchCarTransactionData(
                                                                        item[
                                                                            'ID'],
                                                                        jwt);
                                                                var res5 =
                                                                    await fetchCarRatingData(
                                                                        item[
                                                                            'ID'],
                                                                        jwt);
                                                                var res6 =
                                                                    await fetchUserPastTripsData(
                                                                        _userId,
                                                                        item[
                                                                            'ID']);

                                                                // num specificIncome = 0;

                                                                for (int a = 0;
                                                                    a <
                                                                        json
                                                                            .decode(res4.body)['Transactions']
                                                                            .length;
                                                                    a++) {
                                                                  if (json.decode(res4.body)['Transactions']
                                                                              [
                                                                              a]
                                                                          [
                                                                          'PayeeUserID'] ==
                                                                      _userId) {
                                                                    specificIncome +=
                                                                        json.decode(res4.body)['Transactions']
                                                                            [
                                                                            a]!['TripPrice'];
                                                                  }
                                                                }

                                                                groupStatusResp =
                                                                    TripAllUserStatusGroupResponse.fromJson(
                                                                        json.decode(
                                                                            res6.body!));

                                                                setState(() {
                                                                  loader =
                                                                      false;
                                                                  _selectedCarID =
                                                                      item[
                                                                          'ID'];
                                                                  _selectedCarData =
                                                                      item;

                                                                  if (item['About']['Completed'] &&
                                                                      item['ImagesAndDocuments']
                                                                          [
                                                                          'Completed'] &&
                                                                      item['Features']
                                                                          [
                                                                          'Completed'] &&
                                                                      item['Preference']
                                                                          [
                                                                          'Completed'] &&
                                                                      item['Availability']
                                                                          [
                                                                          'Completed'] &&
                                                                      item['Pricing']
                                                                          [
                                                                          'Completed']) {
                                                                    _listingCompleted =
                                                                        true;

                                                                    _specificTransactionData =
                                                                        json.decode(
                                                                            res4.body!);
                                                                    _specificCarReviewData =
                                                                        json.decode(
                                                                            res5.body!)['CarRatingReviews'];
                                                                    _specificCarTripsData =
                                                                        groupStatusResp;

                                                                    specificIncome ==
                                                                            0.0
                                                                        ? _specificIncome =
                                                                            'You have no earnings yet'
                                                                        : _specificIncome =
                                                                            '\$${specificIncome!.toStringAsFixed(2)}';
                                                                    item['Rating'] ==
                                                                            0.0
                                                                        ? _specificRating =
                                                                            'You have no reviews yet'
                                                                        : _specificRating =
                                                                            item['Rating'].toStringAsFixed(1);
                                                                    _specificTrips =
                                                                        _specificCarTripsData;
                                                                  } else {
                                                                    _listingCompleted =
                                                                        false;
                                                                  }
                                                                });
                                                              },
                                                              child: Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Text(
                                                                    'No name',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      fontSize:
                                                                          16,
                                                                      color: Color(
                                                                          0xff371D32),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),

                                                          //incomplete Not Found Text//

                                                          _selectedCarID ==
                                                                  item['ID']
                                                              ? item['Verification']
                                                                              [
                                                                              'VerificationStatus'] !=
                                                                          null &&
                                                                      item['Verification']
                                                                              [
                                                                              'VerificationStatus'] ==
                                                                          'Pending'
                                                                  ? Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          .1,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                      child:
                                                                          Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            right:
                                                                                12),
                                                                        child: Text(
                                                                            'Incomplete',
                                                                            style:
                                                                                TextStyle(
                                                                              fontFamily: 'Urbanist',
                                                                              fontSize: 12,
                                                                              color: Color(0xff371D32),
                                                                            )),
                                                                      ),
                                                                    )
                                                                  : Container()
                                                              : Container(),
                                                        ],
                                                      )
                                                    : Container(),
                                        ]
                                      : <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 12,
                                                    bottom: 10,
                                                    right: 12),
                                                child: Text(
                                                  'No listed vehicle yet',
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black),
                                                ),
                                              ),
                                              !isDataAvailable
                                                  ? SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.vertical,
                                                      child: DashboardShimmer())
                                                  : new Container(),
                                            ],
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
                  loader
                      ? SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [ShimmerEffect()],
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Transactions///
                            SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.only(left: 12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _carsData.map((item) {
                                  if (item['About']['Make'] != '') {
                                    return _selectedCarID == item['ID']
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5, right: 10),
                                            child: GestureDetector(
                                              onTap: () async {
                                                setState(() {
                                                  loader = true;
                                                });

                                                setState(() {
                                                  loader = false;
                                                });
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                height: 110,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          16.0),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.2),
                                                      spreadRadius: 2,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    // Car Image Section
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(
                                                                16.0),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                16.0),
                                                        topRight:
                                                            Radius.circular(
                                                                16.0),
                                                        bottomRight:
                                                            Radius.circular(
                                                                16.0),
                                                      ),
                                                      child: item['ImagesAndDocuments']
                                                                      ['Images']
                                                                  [
                                                                  'MainImageID'] !=
                                                              ""
                                                          ? Image.network(
                                                              '$storageServerUrl/${item['ImagesAndDocuments']['Images']['MainImageID']}',
                                                              height: 150,
                                                              width: 120,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Image.asset(
                                                              'images/car-placeholder.png',
                                                              height: 150,
                                                              width: 120,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                    SizedBox(width: 10),

                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          SizedBox(height: 10),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Container(
                                                                width:MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                    2,
                                                                child: Text(
                                                                  item['About'][
                                                                          'Year'] +
                                                                      ' ' +
                                                                      item['About']
                                                                          [
                                                                          'Make'] +
                                                                      ' ' +
                                                                      item['About']
                                                                          [
                                                                          'Model'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize: 20,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            4.0),
                                                                child:
                                                                    Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    shape: BoxShape
                                                                        .circle,
                                                                    color: Color(
                                                                        0xffF68E65),
                                                                  ),
                                                                  child:
                                                                      IconButton(
                                                                    icon: Icon(Icons
                                                                        .share),
                                                                    color: Colors
                                                                        .white,
                                                                    onPressed:
                                                                        () {
                                                                      String
                                                                          completeShareMessage =
                                                                          '$carDetailsLink$_selectedCarID';
                                                                      Share.share(
                                                                          completeShareMessage);
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 5),
                                                          Row(
                                                            children: [
                                                              SizedBox(
                                                                  width: 5),
                                                              _selectedCarID ==
                                                                      item['ID']
                                                                  ? item['Verification'] !=
                                                                              null &&
                                                                          item['Verification']['VerificationStatus'] !=
                                                                              null
                                                                      ? item['Verification']['VerificationStatus'] ==
                                                                              'Verified'
                                                                          ? Image.asset(
                                                                              'images/verified.png',
                                                                              width: 25,
                                                                              height: 25)
                                                                          : item['Verification']['VerificationStatus'] == 'Rejected'
                                                                              ? SvgPicture.asset('svg/Group 17.svg', width: 25, height: 25)
                                                                              : item['Verification']['VerificationStatus'] == 'Blocked'
                                                                                  ? SvgPicture.asset('svg/blocked.svg', width: 25, height: 25)
                                                                                  : SvgPicture.asset('svg/incomplete.svg', width: 25, height: 25)
                                                                      : Text(
                                                                          'Incomplete',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Urbanist',
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Colors.black,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        )
                                                                  : Container(),
                                                              SizedBox(
                                                                  width: 5),
                                                              _selectedCarID ==
                                                                      item['ID']
                                                                  ? item['Verification']['VerificationStatus'] !=
                                                                              null &&
                                                                          item['Verification']['VerificationStatus'] !=
                                                                              'Pending'
                                                                      ? Text(
                                                                          item['Verification']
                                                                              [
                                                                              'VerificationStatus'],
                                                                          style: TextStyle(
                                                                              fontFamily: 'Urbanist',
                                                                              fontSize: 16,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                        )
                                                                      : Text(
                                                                          'Incomplete',
                                                                          style: TextStyle(
                                                                              fontFamily: 'Urbanist',
                                                                              fontSize: 16,
                                                                              color: Colors.black,
                                                                              fontWeight: FontWeight.w600),
                                                                        )
                                                                  : Container(),
                                                              SizedBox(
                                                                  width: 5),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox();
                                  } else {
                                    return SizedBox();
                                  }
                                }).toList(),
                              ),
                            ),
                            SizedBox(height: 2),
                            _selectedCarID == ''
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16.0),
                                            bottomLeft: Radius.circular(16.0),
                                            topRight: Radius.circular(16.0),
                                            bottomRight: Radius.circular(16.0),
                                          ),
                                          child: Image.asset(
                                            'images/overAllCar.png',
                                            height: 100,
                                            width: 140,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          'Overall',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 24,
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                      ],
                                    ),
                                  )
                                : Container(),
                            _selectedCarID == ''
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12),
                                    child: Divider(
                                        thickness: 2, color: Colors.black),
                                  )
                                : Container(),
                            _selectedCarID == ''
                                ? Padding(
                                    padding: const EdgeInsets.only(left: 12.0),
                                    child: Text(
                                      'Progress',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 24,
                                          fontFamily: 'Urbanist',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 10),

                            _listingCompleted
                                ? _selectedCarID == ''
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.2,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.4,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (_selectedCarID ==
                                                            '') {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/transactions',
                                                              arguments:
                                                                  _overallTransactionData);
                                                        } else {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/transactions',
                                                              arguments:
                                                                  _specificTransactionData);
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFFFFFFF),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          border: Border.all(
                                                            color: Color(
                                                                0xffFF8F68),
                                                            width: 2.0,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      'svg/_x31__px.svg',
                                                                      // color: Colors.white,
                                                                      width: 50,
                                                                      height:
                                                                          50,
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      _selectedCarID ==
                                                                              ''
                                                                          ? '\$' +
                                                                              _overallIncome
                                                                          : _specificIncome,
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Color(
                                                                            0xffFF8F68),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  DateFormat("MMMM")
                                                                          .format(
                                                                              today) +
                                                                      ' income',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        18,
                                                                    color: Color(
                                                                        0xff353B50),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomRight,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (_selectedCarID ==
                                                                            '') {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/transactions',
                                                                              arguments: _overallTransactionData);
                                                                        } else {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/transactions',
                                                                              arguments: _specificTransactionData);
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                          'Transactions',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Urbanist',
                                                                          )),
                                                                      style: ElevatedButton.styleFrom(
                                                                          primary: Color(0xffFF8F68),
                                                                          onPrimary: Colors.white,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  _listingCompleted
                                                      ? _selectedCarID == ''
                                                          ? Row(
                                                              children: <Widget>[
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.2,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.4,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          if (_selectedCarID ==
                                                                              '') {
                                                                            Navigator.pushNamed(
                                                                              context,
                                                                              '/dashboard_past_trips',
                                                                              arguments: {
                                                                                'CarID': _selectedCarID,
                                                                                'DataToRemove': 'C'
                                                                              },
                                                                            );
                                                                          } else {
                                                                            Navigator.pushNamed(
                                                                              context,
                                                                              '/dashboard_past_trips',
                                                                              arguments: {
                                                                                'CarID': _selectedCarID,
                                                                                'DataToRemove': 'C'
                                                                              },
                                                                            );
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          padding: EdgeInsets.only(
                                                                              left: 16.0,
                                                                              top: 12),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(0xFFFFFFFF),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                            border:
                                                                                Border.all(
                                                                              color: Color(0xffFF8F68),
                                                                              width: 2.0,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      SvgPicture.asset(
                                                                                        'svg/Layer_2.svg',
                                                                                        width: 50,
                                                                                        height: 50,
                                                                                      ),
                                                                                      SizedBox(width: 10),
                                                                                      Text(
                                                                                        numberOfTotalTrips != null ? numberOfTotalTrips.toString() : '0',
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Urbanist',
                                                                                          fontSize: 20,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          color: Color(0xFF6A994E),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(height: 6),
                                                                                  Text(
                                                                                    'Completed trips',
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontFamily: 'Urbanist',
                                                                                      fontSize: 18,
                                                                                      color: Color(0xff353B50),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 6),
                                                                                  ElevatedButton(
                                                                                    onPressed: () {
                                                                                      if (_selectedCarID == '') {
                                                                                        Navigator.pushNamed(
                                                                                          context,
                                                                                          '/dashboard_past_trips',
                                                                                          arguments: {
                                                                                            'CarID': _selectedCarID,
                                                                                            'DataToRemove': 'C'
                                                                                          },
                                                                                        );
                                                                                      } else {
                                                                                        Navigator.pushNamed(
                                                                                          context,
                                                                                          '/dashboard_past_trips',
                                                                                          arguments: {
                                                                                            'CarID': _selectedCarID,
                                                                                            'DataToRemove': 'C'
                                                                                          },
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                    child: Text(
                                                                                      'Past Trips',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'Urbanist',
                                                                                      ),
                                                                                    ),
                                                                                    style: ElevatedButton.styleFrom(
                                                                                        primary: Color(0xffFF8F68),
                                                                                        onPrimary: Colors.white,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(8),
                                                                                        )),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            )
                                                          : Row(
                                                              children: <Widget>[
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.3,
                                                                      height:
                                                                          MediaQuery.of(context).size.width /
                                                                              2,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap: _specificCarReviewData.length !=
                                                                                0
                                                                            ? () {
                                                                                if (_selectedCarID == '') {
                                                                                  Navigator.pushNamed(context, '/dashboard_reviews_tab', arguments: _overallCarReviewData);
                                                                                } else {
                                                                                  Navigator.pushNamed(context, '/dashboard_reviews_tab', arguments: _specificCarReviewData);
                                                                                }
                                                                              }
                                                                            : () {},
                                                                        child:
                                                                            Container(
                                                                          padding:
                                                                              EdgeInsets.all(16.0),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(0xFFFFFFFF),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                            boxShadow: [
                                                                              BoxShadow(
                                                                                color: Colors.grey.withOpacity(0.5),
                                                                                spreadRadius: 2,
                                                                                blurRadius: 5,
                                                                                offset: Offset(0, 3),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: <Widget>[
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Row(
                                                                                    children: <Widget>[
                                                                                      Image.asset(
                                                                                        'icons/Rating.png',
                                                                                        color: Color(0xff5BC0EB),
                                                                                      ),
                                                                                      SizedBox(width: 10),
                                                                                      Text(
                                                                                        _selectedCarID == ''
                                                                                            ? _overallRating
                                                                                            : _specificCarReviewData.length != 0
                                                                                                ? _specificRating
                                                                                                : 'You have no reviews yet',
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Urbanist',
                                                                                          fontSize: 16,
                                                                                          color: Color(0xff371D32),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(height: 10),
                                                                                  _specificCarReviewData.length != 0
                                                                                      ? Text(
                                                                                          'Rating',
                                                                                          style: TextStyle(
                                                                                            fontFamily: 'Urbanist',
                                                                                            fontSize: 14,
                                                                                            color: Color(0xff353B50),
                                                                                          ),
                                                                                        )
                                                                                      : Container(),
                                                                                ],
                                                                              ),
                                                                              _specificCarReviewData.length != 0
                                                                                  ? Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                                                      children: [
                                                                                        Text(
                                                                                          'Reviews',
                                                                                          style: TextStyle(
                                                                                            fontFamily: 'Urbanist',
                                                                                            fontSize: 14,
                                                                                            color: Color(0xff353B50),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          width: 8,
                                                                                          child: Icon(
                                                                                            Icons.keyboard_arrow_right,
                                                                                            color: Color(0xFF353B50),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  : Container(),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            )
                                                      : new Container(),
                                                  _listingCompleted
                                                      ? SizedBox(height: 10)
                                                      : new Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.2,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            2.4,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        if (_selectedCarID ==
                                                            '') {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/transactions',
                                                              arguments:
                                                                  _overallTransactionData);
                                                        } else {
                                                          Navigator.pushNamed(
                                                              context,
                                                              '/transactions',
                                                              arguments:
                                                                  _specificTransactionData);
                                                        }
                                                      },
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFFFFFFF),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          border: Border.all(
                                                            color: Color(
                                                                0xffFF8F68),
                                                            width: 2.0,
                                                          ),
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    SvgPicture
                                                                        .asset(
                                                                      'svg/_x31__px.svg',
                                                                      // color: Colors.white,
                                                                      width: 50,
                                                                      height:
                                                                          50,
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            10),
                                                                    Text(
                                                                      _selectedCarID == ''
                                                                          ? '\$' +
                                                                              _overallIncome
                                                                          : '\$' +
                                                                              '0.0',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: Color(
                                                                            0xffFF8F68),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                  DateFormat("MMMM")
                                                                          .format(
                                                                              today) +
                                                                      ' income',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        18,
                                                                    color: Color(
                                                                        0xff353B50),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    height: 5),
                                                                Expanded(
                                                                  child: Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .bottomRight,
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        if (_selectedCarID ==
                                                                            '') {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/transactions',
                                                                              arguments: _overallTransactionData);
                                                                        } else {
                                                                          Navigator.pushNamed(
                                                                              context,
                                                                              '/transactions',
                                                                              arguments: _specificTransactionData);
                                                                        }
                                                                      },
                                                                      child: Text(
                                                                          'Transactions',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Urbanist',
                                                                          )),
                                                                      style: ElevatedButton.styleFrom(
                                                                          primary: Color(0xffFF8F68),
                                                                          onPrimary: Colors.white,
                                                                          shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                          )),
                                                                    ),
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  _listingCompleted
                                                      ? _selectedCarID == ''
                                                          ? Row(
                                                              children: <Widget>[
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.2,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.4,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          if (_selectedCarID ==
                                                                              '') {
                                                                            Navigator.pushNamed(
                                                                              context,
                                                                              '/dashboard_past_trips',
                                                                              arguments: {
                                                                                'CarID': _selectedCarID,
                                                                                'DataToRemove': 'C'
                                                                              },
                                                                            );
                                                                          } else {
                                                                            Navigator.pushNamed(
                                                                              context,
                                                                              '/dashboard_past_trips',
                                                                              arguments: {
                                                                                'CarID': _selectedCarID,
                                                                                'DataToRemove': 'C'
                                                                              },
                                                                            );
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          padding: EdgeInsets.only(
                                                                              left: 16.0,
                                                                              top: 12),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(0xFFFFFFFF),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                            border:
                                                                                Border.all(
                                                                              color: Color(0xffFF8F68),
                                                                              width: 2.0,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      SvgPicture.asset(
                                                                                        'svg/Layer_2.svg',
                                                                                        width: 50,
                                                                                        height: 50,
                                                                                      ),
                                                                                      SizedBox(width: 10),
                                                                                      Text(
                                                                                        numberOfTotalTrips != null ? numberOfTotalTrips.toString() : '0',
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Urbanist',
                                                                                          fontSize: 20,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          color: Color(0xFF6A994E),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(height: 6),
                                                                                  Text(
                                                                                    'Completed trips',
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontFamily: 'Urbanist',
                                                                                      fontSize: 18,
                                                                                      color: Color(0xff353B50),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 6),
                                                                                  ElevatedButton(
                                                                                    onPressed: () {
                                                                                      if (_selectedCarID == '') {
                                                                                        Navigator.pushNamed(
                                                                                          context,
                                                                                          '/dashboard_past_trips',
                                                                                          arguments: {
                                                                                            'CarID': _selectedCarID,
                                                                                            'DataToRemove': 'C'
                                                                                          },
                                                                                        );
                                                                                      } else {
                                                                                        Navigator.pushNamed(
                                                                                          context,
                                                                                          '/dashboard_past_trips',
                                                                                          arguments: {
                                                                                            'CarID': _selectedCarID,
                                                                                            'DataToRemove': 'C'
                                                                                          },
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                    child: Text(
                                                                                      'Past Trips',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'Urbanist',
                                                                                      ),
                                                                                    ),
                                                                                    style: ElevatedButton.styleFrom(
                                                                                        primary: Color(0xffFF8F68),
                                                                                        onPrimary: Colors.white,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(8),
                                                                                        )),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            )
                                                          : Row(
                                                              children: <Widget>[
                                                                Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  children: [
                                                                    SizedBox(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.2,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2.4,
                                                                      child:
                                                                          GestureDetector(
                                                                        onTap:
                                                                            () {
                                                                          if (_selectedCarID ==
                                                                              '') {
                                                                            Navigator.pushNamed(
                                                                              context,
                                                                              '/dashboard_past_trips',
                                                                              arguments: {
                                                                                'CarID': _selectedCarID,
                                                                                'DataToRemove': 'C'
                                                                              },
                                                                            );
                                                                          } else {
                                                                            Navigator.pushNamed(
                                                                              context,
                                                                              '/dashboard_past_trips',
                                                                              arguments: {
                                                                                'CarID': _selectedCarID,
                                                                                'DataToRemove': 'C'
                                                                              },
                                                                            );
                                                                          }
                                                                        },
                                                                        child:
                                                                            Container(
                                                                          padding: EdgeInsets.only(
                                                                              left: 16.0,
                                                                              top: 12),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Color(0xFFFFFFFF),
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                            border:
                                                                                Border.all(
                                                                              color: Color(0xffFF8F68),
                                                                              width: 2.0,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.start,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: <Widget>[
                                                                              Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Row(
                                                                                    children: [
                                                                                      SvgPicture.asset(
                                                                                        'svg/Layer_2.svg',
                                                                                        width: 50,
                                                                                        height: 50,
                                                                                      ),
                                                                                      SizedBox(width: 10),
                                                                                      Text(
                                                                                        numberOfTotalTrips != null ? numberOfTotalTrips.toString() : '0',
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Urbanist',
                                                                                          fontSize: 20,
                                                                                          fontWeight: FontWeight.w600,
                                                                                          color: Color(0xFF6A994E),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  SizedBox(height: 6),
                                                                                  Text(
                                                                                    'Completed trips',
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.w600,
                                                                                      fontFamily: 'Urbanist',
                                                                                      fontSize: 18,
                                                                                      color: Color(0xff353B50),
                                                                                    ),
                                                                                  ),
                                                                                  SizedBox(height: 6),
                                                                                  ElevatedButton(
                                                                                    onPressed: () {
                                                                                      if (_selectedCarID == '') {
                                                                                        Navigator.pushNamed(
                                                                                          context,
                                                                                          '/dashboard_past_trips',
                                                                                          arguments: {
                                                                                            'CarID': _selectedCarID,
                                                                                            'DataToRemove': 'C'
                                                                                          },
                                                                                        );
                                                                                      } else {
                                                                                        Navigator.pushNamed(
                                                                                          context,
                                                                                          '/dashboard_past_trips',
                                                                                          arguments: {
                                                                                            'CarID': _selectedCarID,
                                                                                            'DataToRemove': 'C'
                                                                                          },
                                                                                        );
                                                                                      }
                                                                                    },
                                                                                    child: Text(
                                                                                      'Past Trips',
                                                                                      style: TextStyle(
                                                                                        fontFamily: 'Urbanist',
                                                                                      ),
                                                                                    ),
                                                                                    style: ElevatedButton.styleFrom(
                                                                                        primary: Color(0xffFF8F68),
                                                                                        onPrimary: Colors.white,
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(8),
                                                                                        )),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            )
                                                      : new Container(),
                                                  _listingCompleted
                                                      ? SizedBox(height: 10)
                                                      : new Container(),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                : new Container(),
                            _listingCompleted
                                ? SizedBox(height: 5)
                                : new Container(),

                            SizedBox(
                              height: 5,
                            ),

                            _listingCompleted
                                ? _selectedCarID == ''
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12.0, right: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.2,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.4,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          if (_selectedCarID ==
                                                              '') {
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/dashboard_reviews_tab',
                                                                arguments:
                                                                    _overallCarReviewData);
                                                          } else {
                                                            Navigator.pushNamed(
                                                                context,
                                                                '/dashboard_reviews_tab',
                                                                arguments:
                                                                    _specificCarReviewData);
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 16.0,
                                                                  top: 12),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFFFFFFF),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                            border: Border.all(
                                                              color: Color(
                                                                  0xffFF8F68),
                                                              width: 2.0,
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Image
                                                                          .asset(
                                                                        'images/image 14.png',
                                                                        width:
                                                                            50,
                                                                        height:
                                                                            50,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              10),
                                                                      Text(
                                                                        _selectedCarID ==
                                                                                ''
                                                                            ? _overallRating
                                                                            : _specificRating,
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Urbanist',
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.w600,
                                                                          color:
                                                                              Color(0xffFF8F68),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              10),
                                                                      SvgPicture
                                                                          .asset(
                                                                        'svg/Vector.svg',
                                                                        width:
                                                                            30,
                                                                        height:
                                                                            30,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  SizedBox(
                                                                      height:
                                                                          10),
                                                                  Text(
                                                                    'Ratings',
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600,
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      fontSize:
                                                                          18,
                                                                      color: Color(
                                                                          0xff353B50),
                                                                    ),
                                                                  ),
                                                                  ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      if (_selectedCarID ==
                                                                          '') {
                                                                        Navigator.pushNamed(
                                                                            context,
                                                                            '/dashboard_reviews_tab',
                                                                            arguments:
                                                                                _overallCarReviewData);
                                                                      } else {
                                                                        Navigator.pushNamed(
                                                                            context,
                                                                            '/dashboard_reviews_tab',
                                                                            arguments:
                                                                                _specificCarReviewData);
                                                                      }
                                                                    },
                                                                    child: Text(
                                                                        'Reviews',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Urbanist',
                                                                        )),
                                                                    style: ElevatedButton.styleFrom(
                                                                        primary: Color(0xffFF8F68),
                                                                        onPrimary: Colors.white,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        )),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    _listingCompleted
                                                        ? _selectedCarID == ''
                                                            ? Row(
                                                                children: <Widget>[
                                                                  Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        width: MediaQuery.of(context).size.width /
                                                                            2.2,
                                                                        height: MediaQuery.of(context).size.width /
                                                                            2.4,
                                                                        child:
                                                                            GestureDetector(
                                                                          onTap:
                                                                              () {
                                                                            if (_selectedCarID ==
                                                                                '') {
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/dashboard_past_trips',
                                                                                arguments: {
                                                                                  'CarID': _selectedCarID,
                                                                                  'DataToRemove': 'A'
                                                                                },
                                                                              );
                                                                            } else {
                                                                              Navigator.pushNamed(
                                                                                context,
                                                                                '/dashboard_past_trips',
                                                                                arguments: {
                                                                                  'CarID': _selectedCarID,
                                                                                  'DataToRemove': 'A'
                                                                                },
                                                                              );
                                                                            }
                                                                          },
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.only(left: 16.0, top: 12),
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Color(0xFFFFFFFF),
                                                                              borderRadius: BorderRadius.circular(8.0),
                                                                              border: Border.all(
                                                                                color: Color(0xffFF8F68),
                                                                                width: 2.0,
                                                                              ),
                                                                            ),
                                                                            child:
                                                                                Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Column(
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Row(
                                                                                      children: [
                                                                                        SvgPicture.asset(
                                                                                          'svg/cancell.svg',
                                                                                          width: 50,
                                                                                          height: 50,
                                                                                        ),
                                                                                        SizedBox(width: 10),
                                                                                        AutoSizeText(
                                                                                          numberOfCanceledTrips.toString(),
                                                                                          style: TextStyle(
                                                                                            fontFamily: 'Urbanist',
                                                                                            fontSize: 20,
                                                                                            fontWeight: FontWeight.w600,
                                                                                            color: Color(0xffE63946),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    SizedBox(height: 10),
                                                                                    Text(
                                                                                      'Cancelled trips',
                                                                                      maxLines: 2,
                                                                                      textAlign: TextAlign.center,
                                                                                      style: TextStyle(
                                                                                        fontWeight: FontWeight.w600,
                                                                                        fontFamily: 'Urbanist',
                                                                                        fontSize: 18,
                                                                                        color: Color(0xff353B50),
                                                                                      ),
                                                                                    ),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        if (_selectedCarID == '') {
                                                                                          Navigator.pushNamed(
                                                                                            context,
                                                                                            '/dashboard_past_trips',
                                                                                            arguments: {
                                                                                              'CarID': _selectedCarID,
                                                                                              'DataToRemove': 'A'
                                                                                            },
                                                                                          );
                                                                                        } else {
                                                                                          Navigator.pushNamed(
                                                                                            context,
                                                                                            '/dashboard_past_trips',
                                                                                            arguments: {
                                                                                              'CarID': _selectedCarID,
                                                                                              'DataToRemove': 'A'
                                                                                            },
                                                                                          );
                                                                                        }
                                                                                      },
                                                                                      child: Text('Cancelled trips',
                                                                                          style: TextStyle(
                                                                                            fontFamily: 'Urbanist',
                                                                                          )),
                                                                                      style: ElevatedButton.styleFrom(
                                                                                          primary: Color(0xffFF8F68),
                                                                                          onPrimary: Colors.white,
                                                                                          shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(8),
                                                                                          )),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                SizedBox(width: 10),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              )
                                                            : Row(
                                                                children: <Widget>[
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        SizedBox(
                                                                          width:
                                                                              double.maxFinite,
                                                                          child:
                                                                              GestureDetector(
                                                                            onTap: numberOfCanceledTrips != null && numberOfCanceledTrips != 0
                                                                                ? () {
                                                                                    if (_selectedCarID == '') {
                                                                                      Navigator.pushNamed(
                                                                                        context,
                                                                                        '/dashboard_past_trips',
                                                                                        arguments: {
                                                                                          'CarID': _selectedCarID,
                                                                                          'DataToRemove': 'A'
                                                                                        },
                                                                                      );
                                                                                    } else {
                                                                                      Navigator.pushNamed(
                                                                                        context,
                                                                                        '/dashboard_past_trips',
                                                                                        arguments: {
                                                                                          'CarID': _selectedCarID,
                                                                                          'DataToRemove': 'A'
                                                                                        },
                                                                                      );
                                                                                    }
                                                                                  }
                                                                                : () {},
                                                                            child:
                                                                                Container(
                                                                              padding: EdgeInsets.all(16.0),
                                                                              decoration: BoxDecoration(
                                                                                color: Color(0xFFF2F2F2),
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                boxShadow: [
                                                                                  BoxShadow(
                                                                                    color: Colors.grey.withOpacity(0.5),
                                                                                    spreadRadius: 2,
                                                                                    blurRadius: 5,
                                                                                    offset: Offset(0, 3),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: <Widget>[
                                                                                  Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                                        children: <Widget>[
                                                                                          Container(
                                                                                            width: 40,
                                                                                            // Adjust the width as needed
                                                                                            height: 40,
                                                                                            // Adjust the height as needed
                                                                                            decoration: BoxDecoration(
                                                                                              shape: BoxShape.circle,
                                                                                              color: Color(0xffE63946),
                                                                                            ),
                                                                                            child: ClipOval(
                                                                                              child: Image.asset(
                                                                                                'icons/Vector1.png',
                                                                                                color: Colors.white,
                                                                                                // Icon color
                                                                                                width: 40,
                                                                                                height: 40,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(width: 10),
                                                                                          AutoSizeText(
                                                                                            numberOfCanceledTrips != null && numberOfCanceledTrips == 0
                                                                                                ? _selectedCarID == ''
                                                                                                    ? '0'
                                                                                                    : 'You have no cancelled trips yet'
                                                                                                : numberOfCanceledTrips.toString(),
                                                                                            style: TextStyle(
                                                                                              fontFamily: 'Urbanist',
                                                                                              fontSize: 16,
                                                                                              color: Color(0xff371D32),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                      SizedBox(height: 10),
                                                                                      numberOfCanceledTrips != null && numberOfCanceledTrips != 0
                                                                                          ? SizedBox(
                                                                                              // width: 150,
                                                                                              child: AutoSizeText(
                                                                                                'Number of cancelled trips',
                                                                                                maxLines: 2,
                                                                                                style: TextStyle(
                                                                                                  fontFamily: 'Urbanist',
                                                                                                  fontSize: 14,
                                                                                                  color: Color(0xff353B50),
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          : Container(),
                                                                                    ],
                                                                                  ),
                                                                                  numberOfCanceledTrips != null && numberOfCanceledTrips != 0
                                                                                      ? Row(
                                                                                          children: [
                                                                                            SizedBox(
                                                                                              width: 100,
                                                                                              height: 50,
                                                                                              child: Align(
                                                                                                alignment: Alignment.center,
                                                                                                child: AutoSizeText(
                                                                                                  'Cancelled trips',
                                                                                                  maxLines: 3,
                                                                                                  style: TextStyle(
                                                                                                    fontFamily: 'Urbanist',
                                                                                                    fontSize: 14,
                                                                                                    color: Color(0xff353B50),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            Container(
                                                                                              width: 8,
                                                                                              child: Icon(
                                                                                                Icons.keyboard_arrow_right,
                                                                                                color: Color(0xFF353B50),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                      : Container(),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                        : Container(),
                                                    _listingCompleted
                                                        ? SizedBox(height: 20)
                                                        : Container(),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: <Widget>[],
                                      )
                                : new Container(),
                            _listingCompleted
                                ? SizedBox(height: 0)
                                : new Container(),

                            /// Reviews//
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                /// Reviews Section ///
                                _listingCompleted && _selectedCarID != ''
                                    ? Padding(
                                        padding:
                                            const EdgeInsets.only(left: 16.0),
                                        child: GestureDetector(
                                          onTap: () {
                                            if (_selectedCarID == '') {
                                              Navigator.pushNamed(
                                                context,
                                                '/dashboard_reviews_tab',
                                                arguments:
                                                    _overallCarReviewData,
                                              );
                                            } else {
                                              Navigator.pushNamed(
                                                context,
                                                '/dashboard_reviews_tab',
                                                arguments:
                                                    _specificCarReviewData,
                                              );
                                            }
                                          },
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.2,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.4,
                                            child: Container(
                                              padding: EdgeInsets.all(16.0),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFFFFFFF),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                                border: Border.all(
                                                  color: Color(0xffFF8F68),
                                                  width: 2.0,
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Image.asset(
                                                            'images/image 14.png',
                                                            width: 50,
                                                            height: 50,
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text(
                                                            _selectedCarID == ''
                                                                ? _overallRating
                                                                : _specificCarReviewData
                                                                            .length !=
                                                                        0
                                                                    ? _specificRating
                                                                    : '0.0',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 20,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                  0xffFF8F68),
                                                            ),
                                                          ),
                                                          SizedBox(width: 10),
                                                          SvgPicture.asset(
                                                            'svg/Vector.svg',
                                                            width: 30,
                                                            height: 30,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        'Ratings',
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 18,
                                                          color:
                                                              Color(0xff353B50),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          if (_selectedCarID ==
                                                              '') {
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/dashboard_reviews_tab',
                                                              arguments:
                                                                  _overallCarReviewData,
                                                            );
                                                          } else {
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/dashboard_reviews_tab',
                                                              arguments:
                                                                  _specificCarReviewData,
                                                            );
                                                          }
                                                        },
                                                        child: Text(
                                                          'Reviews',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                          ),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary:
                                                              Color(0xffFF8F68),
                                                          onPrimary:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),

                                /// Cancelled Trip Section ///
                                _listingCompleted && _selectedCarID != ''
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 0, right: 16),
                                        child: GestureDetector(
                                          onTap: numberOfCanceledTrips !=
                                                      null &&
                                                  numberOfCanceledTrips != 0
                                              ? () {
                                                  if (_selectedCarID == '') {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/dashboard_past_trips',
                                                      arguments: {
                                                        'CarID': _selectedCarID,
                                                        'DataToRemove': 'A'
                                                      },
                                                    );
                                                  } else {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/dashboard_past_trips',
                                                      arguments: {
                                                        'CarID': _selectedCarID,
                                                        'DataToRemove': 'A'
                                                      },
                                                    );
                                                  }
                                                }
                                              : () {},
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.2,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2.4,
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 12.0, top: 12),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Color(0xffFF8F68),
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              ),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          SvgPicture.asset(
                                                              'svg/cancell.svg',
                                                              width: 50,
                                                              height: 50),
                                                          SizedBox(width: 10),
                                                          AutoSizeText(
                                                            numberOfCanceledTrips !=
                                                                        null &&
                                                                    numberOfCanceledTrips ==
                                                                        0
                                                                ? _selectedCarID ==
                                                                        ''
                                                                    ? '0'
                                                                    : '0'
                                                                : numberOfCanceledTrips
                                                                    .toString(),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 18,
                                                              color: Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 10),
                                                      Text(
                                                        'Cancelled Trips',
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color:
                                                              Color(0xff353B50),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          if (_selectedCarID ==
                                                              '') {
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/dashboard_past_trips',
                                                              arguments: {
                                                                'CarID':
                                                                    _selectedCarID,
                                                                'DataToRemove':
                                                                    'A'
                                                              },
                                                            );
                                                          } else {
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/dashboard_past_trips',
                                                              arguments: {
                                                                'CarID':
                                                                    _selectedCarID,
                                                                'DataToRemove':
                                                                    'A'
                                                              },
                                                            );
                                                          }
                                                        },
                                                        child: Text(
                                                          'Cancelled trips',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                          ),
                                                        ),
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary:
                                                              Color(0xffFF8F68),
                                                          onPrimary:
                                                              Colors.white,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ],
                            ),

                            _listingCompleted
                                ? SizedBox(height: 10)
                                : new Container(),

                            ///Manage calendar//
                            _listingCompleted && _selectedCarID != ''
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                        left: 12.0, right: 12),
                                    child: Text('Manage Vehicle',
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w600)),
                                  )
                                : Container(),
                            SizedBox(height: 5),
                            _listingCompleted && _selectedCarID != ''
                                ? Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 12.0,
                                              ),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.4,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.6,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          if (!_calendarClicked) {
                                                            _calendarClicked =
                                                                true;
                                                            CreateCarResponse
                                                                createCarResponse =
                                                                await getCar(
                                                                    _selectedCarID);
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/dashboard_calendar_tab',
                                                              arguments:
                                                                  createCarResponse,
                                                            ).then((value) =>
                                                                _calendarClicked =
                                                                    false);
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 12.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: Color(
                                                                  0xffFF8F68),
                                                              width: 2.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <Widget>[
                                                                  // SVG icon for managing calendar
                                                                  Image.asset(
                                                                      'images/image 15.png',
                                                                      width: 30,
                                                                      height:
                                                                          30),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  // Adjust space between icon and text
                                                                  Flexible(
                                                                    child: Text(
                                                                      'Update your car’s availability',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontSize:
                                                                            16,
                                                                        color: Color(
                                                                            0xff371D32),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 8),
                                                              ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  if (!_calendarClicked) {
                                                                    _calendarClicked =
                                                                        true;
                                                                    CreateCarResponse
                                                                        createCarResponse =
                                                                        await getCar(
                                                                            _selectedCarID);
                                                                    Navigator
                                                                        .pushNamed(
                                                                      context,
                                                                      '/dashboard_calendar_tab',
                                                                      arguments:
                                                                          createCarResponse,
                                                                    ).then((value) =>
                                                                        _calendarClicked =
                                                                            false);
                                                                  }
                                                                },
                                                                child: Text(
                                                                    'Manage Calendar',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                    )),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        primary:
                                                                            Color(
                                                                                0xffFF8F68),
                                                                        onPrimary:
                                                                            Colors
                                                                                .white,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        )),
                                                              ),
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
                                          SizedBox(width: 6),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.2,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              2.6,
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          CreateCarResponse
                                                              createCarResponse =
                                                              await getCar(
                                                                  _selectedCarID);
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/edit_your_listing_tab',
                                                            arguments: {
                                                              'carResponse':
                                                                  createCarResponse,
                                                              'purpose': 3
                                                            },
                                                          );
                                                        },
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 12.0),
                                                          decoration:
                                                              BoxDecoration(
                                                            border: Border.all(
                                                              color: Color(
                                                                  0xffFF8F68),
                                                              width: 2.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0),
                                                          ),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <Widget>[
                                                                  Image.asset(
                                                                      'images/solid_line.png',
                                                                      width: 30,
                                                                      height:
                                                                          30),
                                                                  SizedBox(
                                                                      width: 8),
                                                                  Flexible(
                                                                    child: Text(
                                                                      'Edit car details such as photos, insurance, etc.',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontSize:
                                                                            16,
                                                                        color: Color(
                                                                            0xff371D32),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                  height: 8),
                                                              ElevatedButton(
                                                                onPressed:
                                                                    () async {
                                                                  CreateCarResponse
                                                                      createCarResponse =
                                                                      await getCar(
                                                                          _selectedCarID);
                                                                  Navigator
                                                                      .pushNamed(
                                                                    context,
                                                                    '/edit_your_listing_tab',
                                                                    arguments: {
                                                                      'carResponse':
                                                                          createCarResponse,
                                                                      'purpose':
                                                                          3
                                                                    },
                                                                  );
                                                                },
                                                                child: Text(
                                                                    'Edit details',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                    )),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                        primary:
                                                                            Color(
                                                                                0xffFF8F68),
                                                                        onPrimary:
                                                                            Colors
                                                                                .white,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                        )),
                                                              ),
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
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  )
                                : SizedBox(height: 0),

                            _selectedCarID != '' && !_listingCompleted
                                ? Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12.0, right: 12),
                                          child: Column(
                                            children: [
                                              SizedBox(
                                                width: double.maxFinite,
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0.0,
                                                    backgroundColor:
                                                        Color(0xFFF2F2F2),
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                  ),
                                                  onPressed: () async {
                                                    createCarResponse =
                                                        await getCar(
                                                            _selectedCarID);

                                                    if (createCarResponse!.car!
                                                                .saveAndExitInfo !=
                                                            null &&
                                                        createCarResponse!
                                                            .car!
                                                            .saveAndExitInfo!
                                                            .saveAndExit!) {
                                                      String? routeName = getRouteName(
                                                          createCarResponse!
                                                              .car!
                                                              .saveAndExitInfo!
                                                              .saveAndExitStatus!);
                                                      var argument = getArgument(
                                                          createCarResponse!
                                                              .car!
                                                              .saveAndExitInfo!
                                                              .saveAndExitStatus!,
                                                          createCarResponse!,
                                                          1,
                                                          true,
                                                          '/edit_your_listing_tab');
                                                      Navigator.pushNamed(
                                                        context,
                                                        routeName!,
                                                        arguments: argument,
                                                      );
                                                    } else {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/edit_your_listing_tab',
                                                        arguments: {
                                                          'carResponse':
                                                              createCarResponse,
                                                          'purpose': 1
                                                        },
                                                      );
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text(
                                                          'Continue your listing',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 16,
                                                            color: Color(
                                                                0xff371D32),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 8,
                                                        child: Icon(
                                                            Icons
                                                                .keyboard_arrow_right,
                                                            color: Color(
                                                                0xff353B50)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: 15,
                            ),

                            ///delete car //
                            for (var item in _carsData)
                              _selectedCarID == item['ID']
                                  ? item['About']['Make'] == ''
                                      ? Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 0.0,
                                                        backgroundColor:
                                                            Color(0xFFF2F2F2),
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return CupertinoAlertDialog(
                                                              title: new Text(
                                                                  'Are you sure to delete your listing?'),
                                                              actions: [
                                                                CupertinoDialogAction(
                                                                  child: Text(
                                                                      'No'),
                                                                  onPressed: () =>
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(),
                                                                ),
                                                                CupertinoDialogAction(
                                                                  child: Text(
                                                                      'Yes'),
                                                                  onPressed:
                                                                      () async {
                                                                    // setState(() {
                                                                    //   loader=true;
                                                                    //
                                                                    // });
                                                                    var deleteRes =
                                                                        await attemptToDeleteCar(
                                                                            item['ID']);
                                                                    // setState(() {
                                                                    //   loader=false;
                                                                    //   // _selectedCarID='';
                                                                    // });
                                                                    if (deleteRes !=
                                                                            null &&
                                                                        deleteRes.statusCode ==
                                                                            200) {
                                                                      // var statusRes=deleteRes.body;
                                                                      // if(statusRes=='success'){
                                                                      Navigator.pushNamed(
                                                                          context,
                                                                          '/dashboard_tab');

                                                                      // }
                                                                    }
                                                                    // Navigator.of(context).pop();
                                                                  },
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Container(
                                                            child: Text(
                                                              'Delete your listing',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xff371D32),
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: 8,
                                                            child: Icon(
                                                                Icons
                                                                    .keyboard_arrow_right,
                                                                color: Color(
                                                                    0xff353B50)),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Container()
                                  : Container()
                          ],
                        ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[new CircularProgressIndicator()],
              ),
            ),
    );
  }

  Future<CreateCarResponse> getCar(String carId) async {
    var completer = Completer<CreateCarResponse>();

    callAPI(
      getCarUrl,
      json.encode({"CarID": carId}),
    ).then((resp) {
      var res = CreateCarResponse.fromJson(json.decode(resp.body!));
      completer.complete(res);
    });

    return completer.future;
  }

  Future<Resp> getSaveExitStatus(CreateCarResponse carId) async {
    var completer = Completer<Resp>();
    callAPI(getCarUrl, json.encode({"CarID": carId.car?.iD}))
        .then((resp) => {completer.complete(resp)});
    return completer.future;
  }

  String? getRouteName(String saveAndExitStatus) {
    switch (saveAndExitStatus) {
      case 'SaveAndExitStatus_Undefined':
        return '';
      case 'SetAbout':
        return '/tell_us_about_your_car_ui';
      case 'SetImagesAndDocuments':
        return '/add_photos_to_your_listing_ui';
      case 'SetFeatures':
        return '/what_features_do_you_have_ui';
      case 'SetPreference':
        return '/set_your_car_rules_ui';
      case 'SetAvailability':
        return '/set_your_car_availability_ui';
      case 'SetPricing':
        return '/price_your_car_ui';
    }
  }

  getArgument(String saveAndExitStatus, CreateCarResponse createCarResponse,
      int purpose, bool pushNeeded, String nextRoute) {
    switch (saveAndExitStatus) {
      case 'SaveAndExitStatus_Undefined':
        return '';
      case 'SetAbout':
        return {
          'carResponse': createCarResponse,
          'purpose': purpose,
          'PUSH': pushNeeded,
          'ROUTE_NAME': nextRoute
        };
      case 'SetImagesAndDocuments':
        return {
          'carResponse': createCarResponse,
          'purpose': purpose,
          'PUSH': pushNeeded,
          'ROUTE_NAME': nextRoute
        };
      case 'SetFeatures':
        return {
          'carResponse': createCarResponse,
          'purpose': purpose,
          'PUSH': pushNeeded,
          'ROUTE_NAME': nextRoute
        };
      case 'SetPreference':
        return {
          'carResponse': createCarResponse,
          'purpose': purpose,
          'PUSH': pushNeeded,
          'ROUTE_NAME': nextRoute
        };
      case 'SetAvailability':
        return {
          'carResponse': createCarResponse,
          'purpose': purpose,
          'PUSH': pushNeeded,
          'ROUTE_NAME': nextRoute
        };
      case 'SetPricing':
        return {
          'carResponse': createCarResponse,
          'purpose': purpose,
          'PUSH': pushNeeded,
          'ROUTE_NAME': nextRoute
        };
    }
  }
}
