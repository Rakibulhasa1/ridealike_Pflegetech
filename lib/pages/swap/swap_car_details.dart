import 'dart:async';
import 'dart:convert' show json;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

Future<RestApi.Resp> fetchProfileData(param) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getProfileByUserIDUrl,
    json.encode({"UserID": param}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> fetchUserTrips(param) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getTripsByUserIDUrl,
    json.encode({"UserID": param}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

class SwapCarDetails extends StatefulWidget {
  @override
  SwapCarDetailsState createState() => SwapCarDetailsState();
}

class SwapCarDetailsState extends State<SwapCarDetails> {
  Map? _carDetails;
  Map? _hostProfileData;
  var _userTrips;
  bool _isDataAvailable = false;

  int _current = 0;
  List? _slideImages;
  List<String> _carImgList = [];

  List<String> imgList = [
    'https://source.unsplash.com/YApiWyp0lqo/1600x900',
  ];

  final storage = new FlutterSecureStorage();

  List? _recommendedCars;
  var _recommendedCarsLength;
  var _currentShownRecommendation;
  var _skipValue;
  String? _error;
  String _carToSwapID = '';

  Location location = new Location();
  LocationData? _locationData;
  bool isDataAvailable = false;
  bool buttonVisible = true;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Car Details"});
      final Map _receivedData = ModalRoute.of(context)!.settings.arguments as Map;

      setState(() {
        _carDetails = _receivedData;
      });

      print('------');
      print(_carDetails);
      print('-------');

      for (int i = 0; i < _carDetails!['ImageIDs'].length; i++) {
        if (!_carDetails!['ImageIDs'][i].isEmpty) {
          _carImgList.add(_carDetails!['ImageIDs'][i]);
        }
      }

      print(_carImgList);

      if (_carImgList.length > 0) {
        _slideImages = map<Widget>(
          _carImgList,
          (index, i) {
            return Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(
                        '$storageServerUrl/$i'),
                    fit: BoxFit.cover),
              ),
            );
          },
        ).toList();
      } else {
        _slideImages = map<Widget>(
          imgList,
          (index, i) {
            return Container(
              width: double.maxFinite,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('images/car-placeholder.png'),
                    fit: BoxFit.cover),
              ),
            );
          },
        ).toList();
      }

      if (_carDetails!['HostUserID'] != null) {
        fetchHostDetails(_carDetails!['HostUserID']);
      }

      _recommendedCars = [];
      _recommendedCarsLength = 0;
      _currentShownRecommendation = 0;
      _skipValue = 0;
      _error = '';

      callFetchSwapRecommendations();
    });
  }

  fetchHostDetails(_userID) async {
    var res = await fetchProfileData(_userID);
    var res2 = await fetchUserTrips(_userID);

    setState(() {
      _hostProfileData = json.decode(res.body!)['Profile'];
      _userTrips = json.decode(res2.body!)['Trips'];
      _isDataAvailable = true;
    });
    AppEventsUtils.logEvent("car_viewed",params: {
      "car_name": _carDetails!['About']['Make'] +
          ' ' +
          _carDetails!['About']['Model'],
      "location": _carDetails!['About']['Location']['Address'],
      "car_rating": _carDetails!['Rating']
          .toStringAsFixed(1),
      "car_trips": _carDetails![
      'NumberOfTrips'],
      "host_rating": _hostProfileData!['ProfileRating'].toStringAsFixed(1),
      "host_trips": _hostProfileData!['NumberOfTrips'],
    });
  }

  String currentKilometersMapping(String currentKilometers) {
    switch (currentKilometers) {
      case '0':
        return '0-50k km';
      case '50':
        return '50-100k km';

      case '100':
        return '100-150k km';

      case '150':
        return '150-200k km';

      case '200':
        return '200k+ km';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isDataAvailable
          ? SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    Container(
                      width: double.maxFinite,
                      child: Stack(
                        children: <Widget>[
                          CarouselSlider(
                            options: CarouselOptions(
                              viewportFraction: 1.0,
                              aspectRatio: 2.0,
                              autoPlay: true,
                              enlargeCenterPage: true,
                              onPageChanged: (index, CarouselPageChangedReason reason) {
                                setState(() {
                                  _current = index;
                                });
                              },
                            ),
                            items: _slideImages as List<Widget>,

                          ),
                          // Back button
                          Positioned(
                              top: 15,
                              left: 15,
                              right: 15,
                              child: Container(
                                width: MediaQuery.of(context).size.width * .35,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      height: 32,
                                      width: 32,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xffFFFFFF),
                                        boxShadow: [
                                          BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.1),
                                              blurRadius: 4),
                                        ],
                                      ),
                                      child: IconButton(
                                        icon: Image.asset('icons/Back.png'),
                                        onPressed: () {
                                          // Navigator.pushNamed(
                                          //   context,
                                          //   '/discover_tab',
                                          // );
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                          // Ratings
                          Positioned(
                              top: 150,
                              left: 15,
                              right: 15,
                              child: Container(
                                width: MediaQuery.of(context).size.width * .35,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(5.0),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          color: Color(0xffFFFFFF)),
                                      child: Row(
                                        children: <Widget>[
                                          Icon(
                                            Icons.star,
                                            color: Color(0xff7CB7B6),
                                            size: 12,
                                          ),
                                          SizedBox(width: 3.0),
                                          Container(
                                            child: Text(
                                              _carDetails!['Rating']
                                                      .toStringAsFixed(1) +
                                                  ' . ' +
                                                  _carDetails!['NumberOfTrips'] +
                                                  ' TRIPS',
                                              style: TextStyle(
                                                  color: Color(0xff353B50),
                                                  fontSize: 12,
                                                  fontFamily:
                                                      'Urbanist'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: map<Widget>(
                                        _carImgList,
                                        (index, url) {
                                          return Container(
                                            width: 8.0,
                                            height: 8.0,
                                            margin: EdgeInsets.only(
                                                left: 4, right: 4),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _current == index
                                                    ? Color(0xffFF8F68)
                                                    : Color(0xffE0E0E0)),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Car name
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Text(
                                        _carDetails!['Title'],
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 30,
                                            color: Color(0xFF371D32),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          // About car
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Wrap(
                                        alignment: WrapAlignment.start,
                                        spacing: 5.0,
                                        runSpacing: 1.0,
                                        direction: Axis.horizontal,
                                        children: <Widget>[
                                          _carDetails!['Year'] != ''
                                              ? Chip(
                                                  label: Text(
                                                    _carDetails!['Year'],
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Urbanist',
                                                        fontSize: 14),
                                                  ),
                                                  backgroundColor:
                                                      Color(0xffF2F2F2),
                                                )
                                              : new Container(),
                                          _carDetails!['CurrentKilometers'] != ''
                                              ? Chip(
                                                  label: Text(
                                                    currentKilometersMapping(_carDetails!['CurrentKilometers']),
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Urbanist',
                                                        fontSize: 14),
                                                  ),
                                                  backgroundColor:
                                                      Color(0xffF2F2F2),
                                                )
                                              : new Container(),
                                          _carDetails!['NumberOfSeats'] != ''
                                              ? Chip(
                                                  label: Text(
                                                    _carDetails!['NumberOfSeats']
                                                            .toString() +
                                                        ' seats',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Urbanist',
                                                        fontSize: 14),
                                                  ),
                                                  backgroundColor:
                                                      Color(0xffF2F2F2),
                                                )
                                              : new Container(),
                                          _carDetails!['Transmission'] != ''
                                              ? Chip(
                                                  label: Text('${
                                                      _carDetails!['Transmission'] == 'automatic' ?
                                                      'Automatic' : _carDetails!['Transmission'] == 'manual' ?
                                                  'Manual' : _carDetails!['Transmission']} transmission',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Urbanist',
                                                        fontSize: 14),
                                                  ),
                                                  backgroundColor:
                                                      Color(0xffF2F2F2),
                                                )
                                              : new Container(),
                                          _carDetails!['FuelType'] != ''
                                              ? Chip(
                                                  label: Text(
                                                    _carDetails!['FuelType'] == '91-94 premium' ?
                                                    'Premium fuel' : _carDetails!['FuelType'] == '87 regular' ?
                                                    'Regular fuel' : _carDetails!['FuelType'] == 'diesel' ?
                                                    'Diesel fuel' : _carDetails!['FuelType'] == 'electric' ?
                                                    'Electric' : _carDetails!['FuelType'],
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Urbanist',
                                                        fontSize: 14),
                                                  ),
                                                  backgroundColor:
                                                      Color(0xffF2F2F2),
                                                )
                                              : new Container(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          // Host header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Text(
                                        'Host',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 24,
                                            color: Color(0xFF371D32),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Host details
                          Container(
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Color(0xFFF2F2F2),
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 8,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushNamed(
                                              context, '/user_profile',
                                              arguments: _hostProfileData);
                                        },
                                        child: Row(
                                          children: <Widget>[
                                            _hostProfileData!['ImageID'] != ''
                                                ? Container(
                                                    alignment: Alignment.center,
                                                    height: 70,
                                                    width: 70,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: NetworkImage(
                                                              '$storageServerUrl/${_hostProfileData!['ImageID']}'),
                                                        ),
                                                        color:
                                                            Color(0xffF2F2F2),
                                                        shape: BoxShape.circle),
                                                  )
                                                : Container(
                                                    alignment: Alignment.center,
                                                    height: 70,
                                                    width: 70,
                                                    decoration: BoxDecoration(
                                                        image: DecorationImage(
                                                            fit: BoxFit.cover,
                                                            image: AssetImage(
                                                                'images/user.png')),
                                                        color:
                                                            Color(0xffF2F2F2),
                                                        shape: BoxShape.circle),
                                                  ),
                                            SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  _hostProfileData![
                                                          'FirstName'] +
                                                      ' ' +
                                                      _hostProfileData![
                                                          'LastName'],
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 18),
                                                ),
                                                SizedBox(height: 8),
                                                Container(
                                                  padding: EdgeInsets.all(5.0),
                                                  decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6),
                                                      color: Color(0xffFFFFFF)),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.star,
                                                        color:
                                                            Color(0xff7CB7B6),
                                                        size: 12,
                                                      ),
                                                      SizedBox(width: 3.0),
                                                      Container(
                                                        child: Text(
                                                          '${_hostProfileData!['ProfileRating'].toStringAsFixed(1)} . ${_userTrips == null ? 0 : _userTrips.length} TRIPS',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff353B50),
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Urbanist'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: <Widget>[
                                              Container(
                                                height: 48,
                                                width: 48,
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    Thread threadData = new Thread(
                                                        id: "1123571113",
                                                        userId:
                                                            _hostProfileData![
                                                                'UserID'],
                                                        image: _hostProfileData![
                                                                    'ImageID'] !=
                                                                ""
                                                            ? _hostProfileData![
                                                                'ImageID']
                                                            : "",
                                                        name: _hostProfileData![
                                                                'FirstName'] +
                                                            ' ' +
                                                            _hostProfileData![
                                                                'LastName'],
                                                        message: '',
                                                        time: '',
                                                        messages: []);

                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        settings: RouteSettings(name: "/messages"),
                                                        builder: (context) =>
                                                            MessageListView(
                                                          thread: threadData,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Image.asset(
                                                      'icons/Message-3.png',
                                                      color: Colors.white),
                                                  elevation: 0.0,
                                                  backgroundColor:
                                                      Color(0xffFF8F62),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 30),
                          // Feature header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Text(
                                        'Features',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 24,
                                            color: Color(0xFF371D32),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Divider(color: Color(0xFFABABAB)),
                          // Your car
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Your car: \$${_carDetails!['YourCarPricePerDay'].toInt()}/day',
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Color(0xff353B50)),
                              ),
                              Text(
                                _carDetails!['YourCarPricePerDay']>=_carDetails!['PricePerDay']?
                                'Daily income':'Daily cost',
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Color(0xff353B50)),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          // Selected car0
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Selected car: \$${_carDetails!['PricePerDay'].toInt()}/day',
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Color(0xff353B50)),
                              ),
                              Text(
                                '\$${double.tryParse((_carDetails!['YourCarPricePerDay'] - _carDetails!['PricePerDay']).toString())?.abs()}',
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 24,
                                    color: Color(0xff371D32)),
                              ),
                            ],
                          ),
                          Visibility(
                            visible: buttonVisible,
                            child: Container(
                              margin: const EdgeInsets.only(top: 25.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 15),
                                          child: Center(
                                            child: Text(
                                              "SKIP",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  color: Color(0xff371D32),
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10.0),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        String? userID =
                                            await storage.read(key: 'user_id');

                                        print(_recommendedCars![
                                            _currentShownRecommendation]);
                                        if (userID != null) {
                                          var res = await swapCar(
                                              _carDetails!['ID'],
                                              userID, "Like");
                                          if (json.decode(res.body!)['Match']) {
                                            var arguments = await getProfileDataByUserId(
                                                _carDetails!['HostUserID']);
                                              var args = json.decode(
                                              arguments.body!)['Profile'];
                                          args['otherCarID'] = _carImgList[0];
                                          args["myCarID"] = _carDetails!["myCarID"];
                                            Navigator.pushNamed(
                                                context, '/chance_to_swap',
                                                arguments: args).then((value) =>  Navigator.of(context).pop());
                                          } else {
                                            setState(() {
                                              buttonVisible = false;
                                            });
                                          }
                                          /*var arguments = await getProfileData(
                                              _recommendedCars[
                                              _currentShownRecommendation]
                                              ['HostUserID']);

                                          var args = json.decode(
                                              arguments.body!)['Profile'];
                                          args['otherCarID'] = _carImgList[0];
                                          args["myCarID"] = _carDetails!["myCarID"];
                                          Navigator.pushNamed(
                                              context, '/chance_to_swap',
                                              arguments: args).then((value) =>  Navigator.of(context).pop());*/
                                        } else {
                                          setState(() {
                                            buttonVisible = false;
                                          });
                                        }
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Color(0xffFF8F62),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 15),
                                          child: Center(
                                            child: Text(
                                              "LIKE",
                                              style: TextStyle(
                                                  fontFamily:
                                                      'Urbanist',
                                                  color: Color(0xffFFFFFF),
                                                  fontSize: 18),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    // Like or skip to be implemented
                  ],
                ),
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

  Future<RestApi.Resp> getProfileDataByUserId(param) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getProfileByUserIDUrl,
      json.encode({"UserID": param}),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  Future<RestApi.Resp> fetchGetAllSwapAvailabilityByUserID(_userID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getAllSwapAvailabilityByUserIDUrl,
      json.encode({
        "UserID": _userID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  Future<RestApi.Resp> fetchSwapRecommendations(
      LocationData position, String userId, num skip) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getSwapRecommendationUrl,
      json.encode({
        "UserID": userId,
        "LatLng": {
          "Latitude": position.latitude,
          "Longitude": position.longitude
        },
        "Skip": skip
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  callFetchSwapRecommendations() async {
    _locationData = await location.getLocation();

    if (_locationData != null) {
      String? userID = await storage.read(key: 'user_id');

      if (userID != null) {
        var res = await fetchGetAllSwapAvailabilityByUserID(userID);

        print(json.decode(res.body!));

        if (json.decode(res.body!)['CarToSwapID'] != '') {
          setState(() {
            _carToSwapID = json.decode(res.body!)['CarToSwapID'];
          });

          var res2 =
              await fetchSwapRecommendations(_locationData!, userID, _skipValue);

          if (json.decode(res2.body!)['Cars'].length > 0) {
            setState(() {
              _recommendedCars = json.decode(res2.body!)['Cars'];
              _recommendedCarsLength = json.decode(res2.body!)['Cars'].length;
            });
          } else {
            setState(() {
              _error = 'No more cars found.';
            });
          }
        } else {
          setState(() {
            _error = 'You need to set a car to swap from preferences.';
          });
        }
      }

      setState(() {
        isDataAvailable = true;
      });
    }
  }

  Future<RestApi.Resp> swapCar(_carID, _userID, _swapType) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      swapCarUrl,
      json.encode({"CarID": _carID, "UserID": _userID, "SwapType": _swapType}),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }
}
