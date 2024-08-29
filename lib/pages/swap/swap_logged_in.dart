import 'dart:async';
import 'dart:convert' show json;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:location/location.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

// import 'package:progress_dialog/progress_dialog.dart';
import 'package:ridealike/events/swap_car_event.dart';
import 'package:ridealike/events/swap_no_car_event.dart';
import 'package:ridealike/events/swapprefevent.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/utils/eventbusutils.dart';
import 'package:shimmer/shimmer.dart';

Future<RestApi.Resp> fetchDiscoverBanner() async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getSwapBannerUrl,
    json.encode({}),
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

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

class SwapLoggedIn extends StatefulWidget {
  @override
  _SwapLoggedInState createState() => _SwapLoggedInState();
}

class _SwapLoggedInState extends State<SwapLoggedIn> {
  int _current = 0;

  List _swapBanners = [];
  Location location = new Location();
  LocationData? _locationData;

  List? _recommendedCars;
  var _recommendedCarsLength;
  var _currentShownRecommendation;
  var _skipValue;
  String? _error;
  String _errorDescription = '';
  String _carToSwapID = '';
  String _carToSwapImageID = '';
  bool isDataAvailable = false;
  final storage = new FlutterSecureStorage();
  StreamSubscription? saveSubscription;
  ProgressDialog? pr;

  bool likePressed = false;
  bool skipPressed = false;
  String phoneStatus = "";
  String emailStatus = "";
  Map? _ownProfileData;
  String userId = "";
  List<String> texts = [
    "Swap your daily driver for a bigger car, truck or van for moving or vacation",
    "Swap your car with a lower-value car, and earn extra income",
    "Drive great vehicles for a fraction of the rental prices"
  ];

  int currentTextIndex = 0;

  getSwapBanners() async {
    var res = await fetchDiscoverBanner();

    if (mounted) {
      setState(() {
        _swapBanners = json.decode(res.body!)['ImageIDs'];
      });
    }
  }

  @override
  void dispose() {
    saveSubscription!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getSwapBanners();
    resetData();
    saveSubscription =
        EventBusUtils.getInstance().on<SwapPrefEvent>().listen((event) {
      resetData();
      Future.delayed(Duration(seconds: 1), () {
        print("event received");
        callFetchSwapRecommendations();
      });
    });
    Future.delayed(Duration(seconds: 1), () async {
      userId = (await storage.read(key: 'user_id'))!;
      callVerificationData();
      //callFetchSwapRecommendations();
    });
  }

  void resetData() {
    setState(() {
      _recommendedCars = [];
      _recommendedCarsLength = 0;
      _currentShownRecommendation = 0;
      _skipValue = 0;
      _error = '';
      _errorDescription = '';
      isDataAvailable = false;
    });
  }

  void callVerificationData() async {
    var profileID = await storage.read(key: 'profile_id');
    if (profileID != null) {
      var verificationStatus =
          await getVerificationStatusByProfileID(profileID);
      phoneStatus = json
          .decode(verificationStatus.body!)['Verification']['PhoneVerification']
              ['VerificationStatus']
          .toString();
      emailStatus = json
          .decode(verificationStatus.body!)['Verification']['EmailVerification']
              ['VerificationStatus']
          .toString();
      var ownProfileverificationStatus = await getProfileData(profileID);
      _ownProfileData =
          json.decode(ownProfileverificationStatus.body!)['Profile'];
      callFetchSwapRecommendations();
    }
  }

  Future<RestApi.Resp> getVerificationStatusByProfileID(_profileID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getVerificationStatusByProfileIDUrl,
      json.encode({
        "ProfileID": _profileID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  Future<RestApi.Resp> getProfileData(_profileID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getProfileUrl,
      json.encode({
        "ProfileID": _profileID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  callFetchSwapRecommendations() async {
    try {
      _locationData = await location.getLocation();

      if (_locationData != null) {
        String? userID = await storage.read(key: 'user_id');

        if (userID != null) {
          var res = await fetchGetAllSwapAvailabilityByUserID(userID);

          if (json.decode(res.body!)['CarToSwapID'] != '') {
            EventBusUtils.getInstance().fire(SwapCarEvent());
            List availDataList = json.decode(res.body!)['SwapAvailabilitys'];

            print(availDataList.length);

            if (availDataList.length > 0) {
              _carToSwapID = json.decode(res.body!)['CarToSwapID'];
              _carToSwapImageID =
                  json.decode(res.body!)['CarToSwapMainImageID'];

              List carIDs = [];

              for (var data in availDataList) {
                carIDs.add(data["CarID"]);
              }

              if (carIDs.contains(_carToSwapID)) {
                var res2 = await fetchSwapRecommendations(
                    _locationData!, userID, _skipValue);

                if (json.decode(res2.body!)['Cars'].length > 0) {
                  _recommendedCars = json.decode(res2.body!)['Cars'];
                  _recommendedCarsLength = _recommendedCars!.length;
                  print("Size Before Filter" +
                      ":::" +
                      _recommendedCarsLength.toString());
                  // removing user's own car
                  _recommendedCars!.removeWhere(
                      (element) => element["HostUserID"].toString() == userId);

                  _recommendedCarsLength = _recommendedCars!.length;
                  // test
                  print("Size After Filter" +
                      ":::" +
                      _recommendedCarsLength.toString());
                } else {
                  print("No Car Found!");
                  setState(() {
                    _error = 'Sorry! No more vehicles found';
                    _errorDescription =
                        "Please adjust preference criteria for wider search result";
                    isDataAvailable = true;
                    _recommendedCars = [];
                  });
                }
              }
            }
          } else {
            EventBusUtils.getInstance().fire(SwapNoCarEvent());
          }
        }

        setState(() {
          isDataAvailable = true;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Sorry! No more vehicles found';
        _errorDescription =
            "Please adjust preference criteria for wider search result";
        isDataAvailable = true;
      });
      print(e);
    }
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

  Widget swapBanner() {
    return _swapBanners.length > 0
        ? Container(
            width: MediaQuery.of(context).size.width,
            // margin: EdgeInsets.only(left: 16.0, right: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Slider
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: CarouselSlider(
                              options: CarouselOptions(
                                height: 450,
                                autoPlay: true,
                                viewportFraction: 2.0,
                                enlargeCenterPage: true,
                                onPageChanged:
                                    (index, CarouselPageChangedReason reason) {
                                  setState(() {
                                    _current = index;
                                  });
                                },
                              ),
                              items: map<Widget>(
                                _swapBanners,
                                (index, i) {
                                  var container = Container(
                                    height: 350,
                                    width: MediaQuery.of(context).size.width,
                                    child: Column(
                                      children: <Widget>[
                                        /*Container(
                                          child: i['ImageID'] != null &&
                                                  i['ImageID'] != ''
                                              ? ClipRRect(
                                                  child: Image(
                                                    image: NetworkImage(
                                                        '$storageServerUrl/${i['ImageID']}'),
                                                    fit: BoxFit.cover,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                )
                                              : Icon(
                                                  Icons.image,
                                                  color: Color(0xFFABABAB),
                                                  size: 50.0,
                                                ),
                                          height: 200,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                        ),*/
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            fit: BoxFit.cover,
                                            height: 200,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .90,
                                            imageUrl:
                                                "$storageServerUrl/${i['ImageID']}",
                                            placeholder: (context, url) =>
                                                SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    height: 220,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey.shade300,
                                                        highlightColor: Colors
                                                            .grey.shade100,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 12.0,
                                                                  right: 12),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        height: 20,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            3,
                                                        child:
                                                            Shimmer.fromColors(
                                                                baseColor: Colors
                                                                    .grey
                                                                    .shade300,
                                                                highlightColor:
                                                                    Colors.grey
                                                                        .shade100,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          16.0,
                                                                      right:
                                                                          16),
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey[
                                                                            300],
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                  ),
                                                                )),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    height: 250,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey.shade300,
                                                        highlightColor: Colors
                                                            .grey.shade100,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 16.0,
                                                                  right: 16),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    height: 8,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        height: 14,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child:
                                                            Shimmer.fromColors(
                                                                baseColor: Colors
                                                                    .grey
                                                                    .shade300,
                                                                highlightColor:
                                                                    Colors.grey
                                                                        .shade100,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          16.0,
                                                                      right:
                                                                          16),
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey[
                                                                            300],
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                  ),
                                                                )),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  SizedBox(
                                                    height: 250,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey.shade300,
                                                        highlightColor: Colors
                                                            .grey.shade100,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 16.0,
                                                                  right: 16),
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .grey[300],
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10)),
                                                          ),
                                                        )),
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      SizedBox(
                                                        height: 14,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child:
                                                            Shimmer.fromColors(
                                                                baseColor: Colors
                                                                    .grey
                                                                    .shade300,
                                                                highlightColor:
                                                                    Colors.grey
                                                                        .shade100,
                                                                child: Padding(
                                                                  padding: const EdgeInsets
                                                                      .only(
                                                                      left:
                                                                          16.0,
                                                                      right:
                                                                          16),
                                                                  child:
                                                                      Container(
                                                                    decoration: BoxDecoration(
                                                                        color: Colors.grey[
                                                                            300],
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                  ),
                                                                )),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Image.asset(
                                              'images/car-placeholder.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.9,
                                          child: Text(
                                            i['Title'],
                                            style: TextStyle(
                                                color: Color(0xff371D32),
                                                fontSize: 24,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        Expanded(
                                          child: SizedBox(
                                            child: AutoSizeText(
                                              i['SubTitle'],
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xff371D32),
                                              ),
                                              maxLines: 8,
                                            ),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.9,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                  return container;
                                },
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: map<Widget>(
                                  _swapBanners,
                                  (index, url) {
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin:
                                          EdgeInsets.only(left: 4, right: 4),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _current == index
                                              ? Color(0xffFF8F68)
                                              : Color(0xffE0E0E0)),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Color(0xFFFF8F62),
                      padding: EdgeInsets.all(15.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () async {
                      Navigator.pushNamed(
                        context,
                        '/list_your_car',
                      );
                    },
                    child: Text(
                      'List your vehicle',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Colors.white),
                    ))
              ],
            ),
          )
        : Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[new CircularProgressIndicator()],
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return _recommendedCars!.isNotEmpty
        ? Container(
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0, right: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                    child: Card(
                      child: Column(
                        children: [
                          Container(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  alignment: Alignment.center,
                                  height: 220,
                                  decoration: new BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(5.0),
                                        topRight: Radius.circular(5.0)),
                                    image: DecorationImage(
                                      image: _recommendedCars![
                                                      _currentShownRecommendation]
                                                  ['ImageIDs'][0] !=
                                              ''
                                          ? NetworkImage(
                                                  '$storageServerUrl/${_recommendedCars![_currentShownRecommendation]['ImageIDs'][0]}')
                                              as ImageProvider
                                          : AssetImage('images/user.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 15.0,
                                  right: 15.0,
                                  child: Container(
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Container(
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10.0),
                                      child: Text(
                                        _recommendedCars![_currentShownRecommendation]
                                                        ['YourCarPricePerDay'] -
                                                    _recommendedCars![
                                                            _currentShownRecommendation]
                                                        ['PricePerDay'] >
                                                0
                                            ? 'GET \$${(_recommendedCars![_currentShownRecommendation]['YourCarPricePerDay'] - _recommendedCars![_currentShownRecommendation]['PricePerDay']).toInt()}' +
                                                '/DAY'
                                            : 'PAY \$${(_recommendedCars![_currentShownRecommendation]['PricePerDay'] - _recommendedCars![_currentShownRecommendation]['YourCarPricePerDay']).toInt()}' +
                                                '/DAY',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.0),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    if (phoneStatus == "Verified" &&
                                        emailStatus == "Verified" &&
                                        _ownProfileData![
                                                'VerificationStatus'] ==
                                            'Verified') {
                                      var args = _recommendedCars![
                                          _currentShownRecommendation];
                                      args["myCarID"] = _carToSwapImageID;
                                      Navigator.pushNamed(
                                              context, '/swap_car_details',
                                              arguments: args)
                                          .whenComplete(() {
                                        Future.delayed(
                                            Duration(milliseconds: 500), () {
                                          skipCar();
                                        });
                                      });
                                    }
                                  },
                                  child: Text(
                                    '${_recommendedCars![_currentShownRecommendation]['Title']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                _recommendedCars![
                                                                _currentShownRecommendation]
                                                            ['Year'] !=
                                                        ''
                                                    ? Chip(
                                                        label: Text(
                                                          _recommendedCars![
                                                                  _currentShownRecommendation]
                                                              ['Year'],
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14),
                                                        ),
                                                        backgroundColor:
                                                            Color(0xffF2F2F2),
                                                      )
                                                    : new Container(),
                                                _recommendedCars![
                                                                _currentShownRecommendation]
                                                            [
                                                            'CurrentKilometers'] !=
                                                        ''
                                                    ? Chip(
                                                        label: Text(
                                                          currentKilometersMapping(
                                                              _recommendedCars![
                                                                      _currentShownRecommendation]
                                                                  [
                                                                  'CurrentKilometers']),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14),
                                                        ),
                                                        backgroundColor:
                                                            Color(0xffF2F2F2),
                                                      )
                                                    : new Container(),
                                                _recommendedCars![
                                                                _currentShownRecommendation]
                                                            ['NumberOfSeats'] !=
                                                        ''
                                                    ? Chip(
                                                        label: Text(
                                                          _recommendedCars![
                                                                          _currentShownRecommendation]
                                                                      [
                                                                      'NumberOfSeats']
                                                                  .toString() +
                                                              ' Seats',
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14),
                                                        ),
                                                        backgroundColor:
                                                            Color(0xffF2F2F2),
                                                      )
                                                    : new Container(),
                                                _recommendedCars![
                                                                _currentShownRecommendation]
                                                            ['Transmission'] !=
                                                        ''
                                                    ? Chip(
                                                        label: Text(
                                                          _recommendedCars![
                                                                          _currentShownRecommendation]
                                                                      [
                                                                      'Transmission'] ==
                                                                  'AUTOMATIC'
                                                              ? 'Automatic transmission'
                                                              : _recommendedCars![
                                                                              _currentShownRecommendation]
                                                                          [
                                                                          'Transmission'] ==
                                                                      'automatic'
                                                                  ? 'Automatic transmission'
                                                                  : _recommendedCars![_currentShownRecommendation]
                                                                              [
                                                                              'Transmission'] ==
                                                                          'MANUAL'
                                                                      ? 'Manual transmission'
                                                                      : _recommendedCars![_currentShownRecommendation]['Transmission'] ==
                                                                              'manual'
                                                                          ? 'Manual transmission'
                                                                          : _recommendedCars![_currentShownRecommendation]
                                                                              [
                                                                              'Transmission'],
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14),
                                                        ),
                                                        backgroundColor:
                                                            Color(0xffF2F2F2),
                                                      )
                                                    : new Container(),
                                                _recommendedCars![
                                                                _currentShownRecommendation]
                                                            ['FuelType'] !=
                                                        ''
                                                    ? Chip(
                                                        label: Text(
                                                          _recommendedCars![
                                                                          _currentShownRecommendation]
                                                                      [
                                                                      'FuelType'] ==
                                                                  '91-94_PREMIUM'
                                                              ? 'Premium fuel'
                                                              : _recommendedCars![
                                                                              _currentShownRecommendation]
                                                                          [
                                                                          'FuelType'] ==
                                                                      '91-94 premium'
                                                                  ? 'Premium fuel'
                                                                  : _recommendedCars![_currentShownRecommendation]
                                                                              [
                                                                              'FuelType'] ==
                                                                          '87_REGULAR'
                                                                      ? 'Regular fuel'
                                                                      : _recommendedCars![_currentShownRecommendation]['FuelType'] ==
                                                                              '87 regular'
                                                                          ? 'Regular fuel'
                                                                          : _recommendedCars![_currentShownRecommendation]['FuelType'] == 'electric'
                                                                              ? 'Electric'
                                                                              : _recommendedCars![_currentShownRecommendation]['FuelType'] == 'ELECTRIC'
                                                                                  ? 'Electric'
                                                                                  : _recommendedCars![_currentShownRecommendation]['FuelType'] == 'diesel'
                                                                                      ? 'Diesel fuel'
                                                                                      : _recommendedCars![_currentShownRecommendation]['FuelType'] == 'DIESEL'
                                                                                          ? 'Diesel fuel'
                                                                                          : _recommendedCars![_currentShownRecommendation]['FuelType'],
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
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  phoneStatus == "Verified" &&
                          emailStatus == "Verified" &&
                          _ownProfileData!['VerificationStatus'] == 'Verified'
                      ? Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 25.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {
                                        skipCar();
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
                                        if (!likePressed) {
                                          likePressed = true;
                                          String? userID = await storage.read(
                                              key: 'user_id');
                                          print(_recommendedCars![
                                              _currentShownRecommendation]);
                                          if (userID != null) {
                                            try {
                                              pr = ProgressDialog(
                                                context,
                                                type: ProgressDialogType.normal,
                                              );
                                              pr!.style(
                                                message: "Please wait...",
                                                progressWidget: Container(
                                                  padding: EdgeInsets.all(8.0),
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                              await pr!.show();
                                              var res = await swapCar(
                                                  _recommendedCars![
                                                          _currentShownRecommendation]
                                                      ['ID'],
                                                  userID,
                                                  "Like");
                                              await pr!.hide();
                                              if (res != null &&
                                                  json.decode(
                                                      res.body!)['Match']) {
                                                var arguments =
                                                    await getProfileDataByUserId(
                                                        _recommendedCars![
                                                                _currentShownRecommendation]
                                                            ['HostUserID']);

                                                var args = json.decode(
                                                    arguments.body!)['Profile'];

                                                args["myCarID"] =
                                                    _carToSwapImageID;
                                                args["otherCarID"] =
                                                    _recommendedCars![
                                                                _currentShownRecommendation]
                                                            ['ImageIDs'][0] ??
                                                        "";
                                                Navigator.pushNamed(context,
                                                        '/chance_to_swap',
                                                        arguments: args)
                                                    .then((value) => skipCar());
                                              } else {
                                                if (_currentShownRecommendation +
                                                        1 ==
                                                    _recommendedCarsLength) {
                                                  print("if");
                                                  setState(() {
                                                    _currentShownRecommendation =
                                                        0;
                                                    _skipValue =
                                                        _skipValue + 20;
                                                  });

                                                  callFetchSwapRecommendations();
                                                } else {
                                                  if (_currentShownRecommendation +
                                                          1 ==
                                                      _recommendedCarsLength) {
                                                    setState(() {
                                                      _recommendedCarsLength =
                                                          0;
                                                    });
                                                  } else {
                                                    setState(() {
                                                      _currentShownRecommendation =
                                                          _currentShownRecommendation +
                                                              1;
                                                    });
                                                  }
                                                }
                                              }
                                            } catch (e) {
                                              await pr!.hide();
                                              print(e);
                                            } finally {
                                              likePressed = false;
                                            }
                                          }
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
                                                  fontFamily: 'Urbanist',
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
                            Divider(),
                            SizedBox(height: 100,),
                            Container(
                              margin: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(
                                    12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      texts[currentTextIndex],
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        color: Colors.black,
                                        fontSize: 18,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    SvgPicture.asset('svg/swap a 1.svg'),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      : Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 25.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () async {},
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
                                                  color: Colors.black26,
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
                                      onTap: () async {},
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
                                              "LIKE",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  color: Colors.black26,
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
                            SizedBox(
                              height: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Color(0xFF353B50),
                                  ),
                                  children: <TextSpan>[
                                    TextSpan(
                                      text:
                                          'Please validate your email address and phone number first from ',
                                    ),
                                    TextSpan(
                                      text: 'Profile, ',
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.pushNamed(
                                              context, '/profile');
                                        },
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFF55A51)),
                                    ),
                                    TextSpan(
                                        text: 'then you can return to swap.'),
                                  ]),
                            )
                          ],
                        ),
                ],
              ),
            ),
          )
        : Center(
            child: Column(
              children: [
                !isDataAvailable
                    ? Container(
                        margin: EdgeInsets.only(left: 12, right: 12),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 320,
                              width: MediaQuery.of(context).size.width,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                            SizedBox(
                              height: 120,
                              width: MediaQuery.of(context).size.width,
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 18,
                            ),
                          ],
                        ),
                      )
                    : _error != null && _error!.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: 15),
                            child: Column(
                              children: [
                                Text(
                                  _error!,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(_errorDescription,
                                    textAlign: TextAlign.center)
                              ],
                            ),
                          )
                        : swapBanner(),
              ],
            ),
          );
  }

  void skipCar() async {
    if (!skipPressed) {
      skipPressed = true;
      String? userID = await storage.read(key: 'user_id');
      if (userID != null) {
        try {
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
          await pr!.show();
          await swapCar(_recommendedCars![_currentShownRecommendation]['ID'],
              userID, "Skip");
          await pr!.hide();
          setState(() {
            currentTextIndex = (currentTextIndex + 1) % texts.length;
          });
          if (_currentShownRecommendation + 1 == _recommendedCars!.length) {
            setState(() {
              _currentShownRecommendation = 0;
              _skipValue = _skipValue + 20;
            });

            callFetchSwapRecommendations();
          } else {
            if (_currentShownRecommendation + 1 == _recommendedCarsLength) {
              setState(() {
                _recommendedCarsLength = 0;
              });
            } else {
              setState(() {
                _currentShownRecommendation = _currentShownRecommendation + 1;
              });
            }
          }
        } catch (e) {
          await pr!.hide();
          print(e);
        } finally {
          skipPressed = false;
        }
      }
    } else {
      print("please wait");
    }
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
