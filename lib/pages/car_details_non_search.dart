import 'dart:async';
import 'dart:collection';
import 'dart:convert' show json;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/pages/profile/response_service/payment_card_info.dart';
import 'package:ridealike/pages/profile/response_service/profile_verification_response.dart';
import 'package:ridealike/utils/TimeUtils.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/sized_text.dart';
import 'package:share_plus/share_plus.dart';

import 'book_a_car/add_card.dart';
import 'book_a_car/booking_info.dart';
import 'messages/widgets/imagedetails.dart';

Future<RestApi.Resp> fetchCarData(param) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    // 'https://api.car!.ridealike.com/v1/car.CarService/GetCar',
    getCarUrl,
    json.encode({"CarID": param}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> fetchLocationStatus(userID, carID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    showLocationUrl,
    json.encode({"UserID": userID, "CarID": carID}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> fetchCarReviews(param) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    // 'https://api.car!.ridealike.com/v1/car.CarService/GetAllReviewByCarID',
    getAllReviewByCarIDUrl,
    json.encode({"CarID": param, "Limit": "0", "Skip": "0"}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> fetchProfileData(param) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    // 'https://api.profile.ridealike.com/v1/profile.ProfileService/GetProfileByUserID',
    getProfileByUserIDUrl,
    json.encode({"UserID": param}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> profileVerificationData(_profileID) async {
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

Future<RestApi.Resp> fetchCardInfo(param) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    // 'https://api.payment.ridealike.com/v1/payment.PaymentService/GetCardsByUserID',
    getCardsByUserIDUrl,
    json.encode({"UserID": param}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> getProfileData(_profileID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    // 'https://api.profile.ridealike.com/v1/profile.ProfileService/GetProfile',
    getProfileUrl,
    json.encode({
      "ProfileID": _profileID,
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

class CarDetailsNonSearch extends StatefulWidget {
  @override
  CarDetailsNonSearchState createState() => CarDetailsNonSearchState();
}

class CarDetailsNonSearchState extends State<CarDetailsNonSearch> {
  Map _carDetails = {};
  Map _profileDetails = {};
  List? _carReviews;
  List? _userTrips;
  bool _loggedIn = true;
  String _loggedInUser = '';
  bool showLocation = false;
  String? userID;
  Map? _ownProfileData;
  String? _carID;
  ProfileVerificationResponse? profileVerificationResponse;
  var ownProfileEmailID;
  PaymentCardInfo? cardInfo;
  var errorMessages;
  var deliveryLimit;
  var hour;
  List<String> imgList = [
    'https://source.unsplash.com/YApiWyp0lqo/1600x900',
  ];

  List<String> carImgList = [];

  List? _slideImages;

  List _features = [];

  var _bookingInfo = {
    "carID": '',
    "userID": '',
    "location": '',
    "locAddress": '',
    "locLat": '',
    "locLong": '',
    "startDate": '',
    "endDate": '',
    "insuranceType": 'Minimum',
    "deliveryNeeded": false,
    "calendarID": ''
  };

  String address = '';
  String text = '';
  var bookingButton = true;

  void handleShowAddCardModal() {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        // TODO
        print("date pass:::" + (_bookingInfo["startDate"]?.toString() ?? "N/A"));
        print("date pass:::" + (_bookingInfo["endDate"]?.toString() ?? "N/A"));

        // print("date pass:::" + _bookingInfo["startDate"]);
        // print("date pass:::" + _bookingInfo["endDate"]);
        _bookingInfo["route"] = "/car_details_non_search";
        _bookingInfo["window"] =
            _carDetails['Availability']['RentalAvailability']['BookingWindow'];
        _bookingInfo["mileage"] = _carDetails['Preference'];
        _bookingInfo['FormattedAddress'] =
            _carDetails['About']['Location']['FormattedAddress'];

        if (!_cardAdded) {
          AppEventsUtils.logEvent("card_added_false");
          return AddCard(bookingInfo: _bookingInfo);
        } else {
          AppEventsUtils.logEvent("card_added_true");
          return BookingInfo(bookingInfo: _bookingInfo);
        }
      },
    );
  }

  int _current = 0;

  int _circleIdCounter = 1;

  final storage = new FlutterSecureStorage();

  Completer<GoogleMapController> _mapController = Completer();

  static var location = LatLng(40.730610, -73.935242);

  Set<Circle> _circles = new HashSet<Circle>();
  Set<Marker> _markers = new HashSet<Marker>();

  CameraPosition _initialCamera =
      CameraPosition(target: location, zoom: 14.4746);

  //Card default null
  bool _cardAdded = false;
  TimeOfDay now = TimeOfDay.now();
  var value;
  var value2;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      //AppEventsUtils.logEvent("car_details_view", params: {"type": "browse"});
      AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Car Details"});
      var value = ModalRoute.of(context)!.settings.arguments;
      if (value is String) {
        _carID = value;
      } else {
        print('Map ');
        _carID = (value as Map)['carID'];
        setState(() {
          bookingButton = (value as Map)['bookingButton'];
        });
      }
      String? profileID = await storage.read(key: 'profile_id');
      userID = (await storage.read(key: 'user_id'));

//      if(profileID!=null){
//      profileRes = await fetchOwnProfileData(profileID);
//      }
      var ownProfileRes;
      var res = await fetchCarData(_carID);
      var res2 = await fetchProfileData(json.decode(res.body!)['Car']['UserID']);
      var res4 = await fetchCarReviews(_carID);
      if (profileID != null) {
        ownProfileRes = await getProfileData(profileID);
      }
      var response;
      if (profileID != null) {
        response = await profileVerificationData(profileID);
      }
      var resShowLocation;
      if (userID != null && _carID != null) {
        resShowLocation = await fetchLocationStatus(userID, _carID);
      }
//      var res5 = await fetchUserTrips(json.decode(res.body!)['Car']['UserID']);

      setState(() {
        _carDetails = json.decode(res.body!)['Car'];
        _profileDetails = json.decode(res2.body!)['Profile'];
        if (response != null) {
          profileVerificationResponse =
              ProfileVerificationResponse.fromJson(json.decode(response.body!));
        }
        if (ownProfileRes != null &&
            json.decode(ownProfileRes.body!).isNotEmpty) {
          _ownProfileData = json.decode(ownProfileRes.body!)['Profile'];
          print('ownDtaa${_ownProfileData.toString()}');
        }

        print('verification${profileVerificationResponse}');
        _carReviews = json.decode(res4.body!)['CarRatingReviews'];
//        _userTrips = json.decode(res5.body!)['Trips'];
        if (resShowLocation != null) {
          showLocation = json.decode(resShowLocation.body!)['Show'] == null
              ? false
              : json.decode(resShowLocation.body!)['Show'];
        }
        String postalCode =
            _carDetails['About']['Location']['PostalCode'] != null &&
                    _carDetails['About']['Location']['PostalCode'] != ''
                ? _carDetails['About']['Location']['PostalCode']
                : '';
        String region = _carDetails['About']['Location']['Region'] != null &&
                _carDetails['About']['Location']['Region'] != ''
            ? _carDetails['About']['Location']['Region']
            : '';
        String locality =
            _carDetails['About']['Location']['Locality'] != null &&
                    _carDetails['About']['Location']['Locality'] != ''
                ? _carDetails['About']['Location']['Locality']
                : '';

        if (postalCode.length > 3) {
          postalCode = postalCode.substring(0, 3);
        }
        address = postalCode + ', ' + locality + ', ' + region;
        address = address.trim();
        address = address.replaceAll(', ,', ', ');
        while (address.startsWith(',')) {
          address = address.substring(1);
          address = address.trim();
        }
        while (address.endsWith(',')) {
          address = address.substring(0, address.length - 1);
          address = address.trim();
        }
        var value = (_carDetails['Availability']['RentalAvailability']
                ['SameDayCutOffTime']['hours']) %
            12;
        if (value == 0) {
          hour = 12;
        } else {
          hour = value;
        }
        print('hour$hour');

        _bookingInfo["locAddress"] = address;

        deliveryLimit =
            _carDetails['Pricing']['RentalPricing']['EnableCustomDelivery'];
        _initialCamera = CameraPosition(
            target: _carDetails['About']['Location']['LatLng'] != null
                ? LatLng(
                    _carDetails['About']['Location']['LatLng']['Latitude']
                        .toDouble(),
                    _carDetails['About']['Location']['LatLng']['Longitude']
                        .toDouble())
                : location,
            zoom: 14.4746);

        if (!_carDetails['ImagesAndDocuments']['Images']['MainImageID'].isEmpty)
          carImgList
              .add(_carDetails['ImagesAndDocuments']['Images']['MainImageID']);
        if (!_carDetails['ImagesAndDocuments']['Images']['AdditionalImages']
                ['ImageID1']
            .isEmpty)
          carImgList.add(_carDetails['ImagesAndDocuments']['Images']
              ['AdditionalImages']['ImageID1']);

        if (!_carDetails['ImagesAndDocuments']['Images']['AdditionalImages']
                ['ImageID2']
            .isEmpty)
          carImgList.add(_carDetails['ImagesAndDocuments']['Images']
              ['AdditionalImages']['ImageID2']);
        if (!_carDetails['ImagesAndDocuments']['Images']['AdditionalImages']
                ['ImageID3']
            .isEmpty)
          carImgList.add(_carDetails['ImagesAndDocuments']['Images']
              ['AdditionalImages']['ImageID3']);
        if (!_carDetails['ImagesAndDocuments']['Images']['AdditionalImages']
                ['ImageID4']
            .isEmpty)
          carImgList.add(_carDetails['ImagesAndDocuments']['Images']
              ['AdditionalImages']['ImageID4']);
        if (!_carDetails['ImagesAndDocuments']['Images']['AdditionalImages']
                ['ImageID5']
            .isEmpty)
          carImgList.add(_carDetails['ImagesAndDocuments']['Images']
              ['AdditionalImages']['ImageID5']);
        if (!_carDetails['ImagesAndDocuments']['Images']['AdditionalImages']
                ['ImageID6']
            .isEmpty)
          carImgList.add(_carDetails['ImagesAndDocuments']['Images']
              ['AdditionalImages']['ImageID6']);
        if (!_carDetails['ImagesAndDocuments']['Images']['AdditionalImages']
                ['ImageID7']
            .isEmpty)
          carImgList.add(_carDetails['ImagesAndDocuments']['Images']
              ['AdditionalImages']['ImageID7']);
        if (!_carDetails['ImagesAndDocuments']['Images']['AdditionalImages']
                ['ImageID8']
            .isEmpty)
          carImgList.add(_carDetails['ImagesAndDocuments']['Images']
              ['AdditionalImages']['ImageID8']);
        if (!_carDetails['ImagesAndDocuments']['Images']['AdditionalImages']
                ['ImageID9']
            .isEmpty)
          carImgList.add(_carDetails['ImagesAndDocuments']['Images']
              ['AdditionalImages']['ImageID9']);

        if (carImgList.length > 0) {
          _slideImages = map<Widget>(
            carImgList,
            (index, i) {
              return Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: NetworkImage('$storageServerUrl/$i'),
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

        print("calendar:::carnonsearch:::" + _carDetails['CalendarID']);

        _bookingInfo['calendarID'] = _carDetails['CalendarID'];
        _bookingInfo['carID'] = _carDetails['ID'];
        _bookingInfo['userID'] = _carDetails['UserID'];
        _bookingInfo['location'] = _carDetails['About']['Location']['Address'];
        // _bookingInfo['locAddress'] = _carDetails['About']['Location']['Address'];
        _bookingInfo['locLat'] =
            _carDetails['About']['Location']['LatLng']['Latitude'];
        _bookingInfo['locLong'] =
            _carDetails['About']['Location']['LatLng']['Longitude'];
        _bookingInfo['customDeliveryEnable'] =
            _carDetails['Pricing']['RentalPricing']['EnableCustomDelivery'];

        //TODO
        DateTime _start = DateTime.now().add(Duration(hours: 2));
        DateTime _temp = DateTime.now().add(Duration(days: 4));
        //DateTime _end = _temp.subtract(Duration(hours: DateTime.now().hour));
        DateTime _end = _temp;
        //
        /*_bookingInfo['startDate'] =
            DateFormat("y-MM-dd").format(
                _start.toUtc()) +
                'T' +
                _start.toUtc().hour.toString() +
                ':00:00.000Z';
        _bookingInfo['endDate'] =
            DateFormat("y-MM-dd").format(
                _end.toUtc()) +
                'T' +
                _end.toUtc().hour.toString() +
                ':00:00.000Z';*/
        String tempPickup = TimeUtils.getSliderTime(_start.toUtc().hour);
        String tempReturn = TimeUtils.getSliderTime(_end.toUtc().hour);
        _bookingInfo['startDate'] =
            DateFormat("y-MM-dd").format(_start.toUtc()) +
                'T' +
                tempPickup +
                ':00:00.000Z';
        _bookingInfo['endDate'] = DateFormat("y-MM-dd").format(_end.toUtc()) +
            'T' +
            tempReturn +
            ':00:00.000Z';

        //

        //_bookingInfo["startDate"] = _start.toUtc().toIso8601String();
        //_bookingInfo["endDate"] =  _end.toUtc().toIso8601String();

        // print("date set:::" + _bookingInfo["startDate"]);
        // print("date set:::" + _bookingInfo["endDate"]);
        print("date set:::" + (_bookingInfo["startDate"]?.toString() ?? "N/A"));
        print("date set:::" + (_bookingInfo["endDate"]?.toString() ?? "N/A"));

        // Interior
        if (_carDetails['Features']['Interior']['HasAndroidAuto']) {
          _features.add({'image': 'Android-2.png', 'text': 'Android auto'});
        }
        if (_carDetails['Features']['Interior']['HasAppleCarPlay']) {
          _features.add({'image': 'Apple-2.png', 'text': 'Apple CarPlay'});
        }
        if (_carDetails['Features']['Interior']['HasAirConditioning']) {
          _features.add({'image': 'AC-2.png', 'text': 'Air conditioning'});
        }
        if (_carDetails['Features']['Interior']['HasBluetoothAudio']) {
          _features
              .add({'image': 'Bluetooth-2.png', 'text': 'Bluetooth audio'});
        }
        if (_carDetails['Features']['Interior']['HasHeatedSeats']) {
          _features
              .add({'image': 'Heated-seats-2.png', 'text': 'Heated seats'});
        }
        if (_carDetails['Features']['Interior']['HasSunroof']) {
          _features.add({'image': 'Sunroof-2.png', 'text': 'Sunroof'});
        }
        if (_carDetails['Features']['Interior']['HasUsbChargingPort']) {
          _features.add({'image': 'USB-2.png', 'text': 'USB charging port'});
        }
        if (_carDetails['Features']['Interior']['HasVentilatedSeats']) {
          _features.add(
              {'image': 'Ventilated-seats-2.png', 'text': 'Ventilated seats'});
        }

        // Exterior
        if (_carDetails['Features']['Exterior']['HasAllWheelDrive']) {
          _features.add(
              {'image': 'All-wheel_drive-2.png', 'text': 'All-wheel drive'});
        }
        if (_carDetails['Features']['Exterior']['HasBikeRack']) {
          _features.add({'image': 'Bike-rack-2.png', 'text': 'Bike rack'});
        }
        if (_carDetails['Features']['Exterior']['HasSkiRack']) {
          _features.add({'image': 'Ski-rack-2.png', 'text': 'Ski rack'});
        }
        if (_carDetails['Features']['Exterior']['HasSnowTires']) {
          _features.add({'image': 'Spare-tire-2.png', 'text': 'Snow tires'});
        }

        // Comfort
        if (_carDetails['Features']['Comfort']['RemoteStart']) {
          _features.add({'image': 'WiFi-2.png', 'text': 'Free Wi-Fi'});
        }
        if (_carDetails['Features']['Comfort']['FreeWifi']) {
          _features
              .add({'image': 'Remote-start-2.png', 'text': 'Remote start'});
        }

        // Exterior
        if (_carDetails['Features']['SafetyAndPrivacy']['HasChildSeat']) {
          _features.add({'image': 'Child-seat-2.png', 'text': 'Child seat'});
        }
        if (_carDetails['Features']['SafetyAndPrivacy']['HasDashCamera']) {
          _features.add({'image': 'Dash-camera-2.png', 'text': 'Dash camera'});
        }
        if (_carDetails['Features']['SafetyAndPrivacy']
            ['HasGPSTrackingDevice']) {
          _features
              .add({'image': 'GPS-tracking-2.png', 'text': 'GPS tracking'});
        }
        if (_carDetails['Features']['SafetyAndPrivacy']['HasSpareTire']) {
          _features.add(
              {'image': 'Spare-tire-2.png', 'text': 'Spare tire included'});
        }

        // Custom
        if (_carDetails['Features']['CustomFeatures'].length > 0) {
          for (var i = 0;
              i < _carDetails['Features']['CustomFeatures'].length;
              i++)
            _features.add({
              'image': 'Custom-feature-2.png',
              'text': _carDetails['Features']['CustomFeatures'][i]['Name']
            });
        }
      });

      value = (_carDetails['Availability']['RentalAvailability']
              ['SameDayCutOffTime']['hours'])
          .toString();
      value2 = (num.parse((_carDetails['Availability']['RentalAvailability']
                      ['SameDayCutOffTime']['hours'])
                  .toStringAsFixed(2)) >
              11.59
          ? 'PM'
          : 'AM');

//      String userID = await storage.read(key: 'user_id');
      AppEventsUtils.logEvent("car_viewed",params: {
        "car_name": _carDetails['About']['Make'] +
            ' ' +
            _carDetails['About']['Model'],
        "location": _carDetails['About']['Location']['Address'],
        "car_rating": _carDetails['Rating']
            .toStringAsFixed(1),
        "car_trips": _carDetails[
        'NumberOfTrips'],
        "host_rating": _profileDetails['ProfileRating'].toStringAsFixed(1),
        "host_trips": _profileDetails['NumberOfTrips'],
      });
      if (userID != null) {
        var res3 = await fetchCardInfo(userID);

        print("*************card info************");
        print(json.decode(res3.body!)['CardInfo']);
        setState(() {
          cardInfo = PaymentCardInfo.fromJson(json.decode(res3.body!));
          if (cardInfo != null && cardInfo!.cardInfo!.length > 0) {
            _cardAdded = true;
          } else {
            _cardAdded = false;
          }
          //
          _loggedIn = true;
          _loggedInUser = userID!;
        });
      } else {
        setState(() {
          _loggedIn = false;
        });
      }
    });
  }

  shortestTrip(Map _carDetails) {
    switch (_carDetails['Availability']['RentalAvailability']['ShortestTrip']) {
      case 1:
        return '4 hours';
      case 2:
        return '6 hours';
      case 3:
        return '8 hours';
      case 4:
        return '1 day';
      case 5:
        return '3 days';
      case 6:
        return '5 days';
      case 7:
        return '7 days';
    }
    return '';
  }

  getLongestTripToString(Map _carDetails) {
    if (_carDetails['Availability']['RentalAvailability']['LongestTrip'] == 1) {
      return '${_carDetails['Availability']['RentalAvailability']['LongestTrip']} day';
    } else {
      return '${_carDetails['Availability']['RentalAvailability']['LongestTrip']} days';
    }
  }

  getCurrentMileage(Map _carDetails) {
    switch (_carDetails['ImagesAndDocuments']['CurrentKilometers']) {
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
    }
    return '';
  }

  getAdvanceNotice(Map _carDetails) {
    switch (_carDetails['Availability']['RentalAvailability']
        ['AdvanceNotice']) {
      case 'AtLeast1Day':
        return 'at least 1 day';
      case 'AtLeast3Day':
        return 'at least 3 days';
      case 'AtLeast5Day':
        return 'at least 5 days';

      case 'AtLeast7Day':
        return 'at least 7 days';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30.0),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: _loggedIn
              ? userID != _carDetails['UserID']
                  ? bookingButton
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 90,
                          child: Container(
                              width: 200,
                            height: 250,
                            color: Colors.white,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '\$' +
                                          double.parse(_carDetails[
                                          'Pricing']
                                          [
                                          'RentalPricing']
                                          ['PerDay']
                                              .toString())
                                              .round()
                                              .toString(),
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xffFF8F68),
                                      ),
                                    ),SizedBox(width: 4,),
                                    Text(
                                      'PER DAY',
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 13,
                                          color: Color(0xff353B50)),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  width:MediaQuery.of(context).size.width/2,

                                  height: 50,
                                  child: FloatingActionButton(
                                    elevation: 0.0,
                                    backgroundColor: Color(0xffFF8F68),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    onPressed: profileVerificationResponse
                                                    !.verification!
                                                    .phoneVerification!
                                                    .verificationStatus ==
                                                'Verified' &&
                                            profileVerificationResponse
                                                    !.verification!
                                                    .emailVerification!
                                                    .verificationStatus ==
                                                'Verified' &&
                                            _ownProfileData!['VerificationStatus'] ==
                                                'Verified' &&
                                            _carDetails['Availability']
                                                        ['RentalAvailability']
                                                    ['BookingWindow'] !=
                                                'DatesUnavailable' &&
                                            (_carDetails['Verification'] != null &&
                                                _carDetails['Verification']
                                                        ['VerificationStatus'] !=
                                                    'Updated')
                                        ? () async {
                                            String? profileID =
                                                await storage.read(key: 'profile_id');

                                            if (profileID != null) {
                                              // Card null check
                                              fetchCardInfo(userID).then((value) {
                                                setState(() {
                                                  cardInfo = PaymentCardInfo.fromJson(
                                                      json.decode(value.body!));
                                                  if (cardInfo != null &&
                                                      cardInfo!.cardInfo!.length > 0) {
                                                    _cardAdded = true;
                                                  } else {
                                                    _cardAdded = false;
                                                  }
                                                  _loggedIn = true;
                                                  _loggedInUser = userID!;
                                                });
                                                handleShowAddCardModal();
                                              });
                                            } else {
                                              Navigator.pushNamed(context,
                                                  '/create_profile_or_sign_in');
                                            }
                                          }
                                        : null,
                                    child: Text(
                                      'Continue booking',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 8),
                          child: Text(
                            'You cannot book your own vehicle',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xFF353B50),
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                      ],
                    )
              : SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom( elevation: 0.0,
                      backgroundColor: Color(0xffFF8F68),
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                   onPressed: () {
                      //todo
                      Navigator.pushNamed(context, '/create_profile_or_sign_in',
                          arguments: {
                            'ROUTE': '/car_details_non_search',
                            'ARGUMENTS': _carID,
                          });
                    },
                    child: Text(
                      'Reserve a vehicle',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
        ),
      ),
      backgroundColor: Colors.white,
      body: _bookingInfo['userID'] != ''
          ? SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height,
                    child: ListView(
                      scrollDirection: Axis.vertical,
                      children: <Widget>[
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            // Slider
                            Container(
                              width: double.maxFinite,
                              child: Stack(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => ImageDetails(
                                              images: carImgList.map((img) => storageServerUrl + "/" + img).toList(),
                                              initialIndex: _current,
                                            ),),
                                      );
                                    },
                                    child: CarouselSlider(
                                      items: _slideImages as List<Widget>,
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
                                     ),
                                  ),
                                  // Back button
                                  Positioned(
                                      top: 15,
                                      left: 15,
                                      right: 15,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .35,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              height: 32,
                                              width: 32,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xffFFFFFF),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.black
                                                          .withOpacity(0.1),
                                                      blurRadius: 4),
                                                ],
                                              ),
                                              child: IconButton(
                                                icon: Image.asset(
                                                    'icons/Back.png'),
                                                onPressed: () {
                                                  // Navigator.pushNamed(
                                                  //   context,
                                                  //   '/discover_tab',
                                                  // );
                                                  Navigator.pop(context);
                                                  // Navigator.popUntil(context, ModalRoute.withName('/discover_tab'));
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                  // Ratings///
                                  Positioned(
                                      top: 150,
                                      left: 15,
                                      right: 15,
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .35,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
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
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          _carDetails['Rating']
                                                              .toStringAsFixed(
                                                                  1),
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff353B50),
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Urbanist'),
                                                        ),
                                                        SizedBox(
                                                          width: 4,
                                                        ),
                                                        Center(
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
                                                        Text(
                                                          _carDetails[
                                                                  'NumberOfTrips'] +
                                                              ' TRIPS',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xff353B50),
                                                              fontSize: 12,
                                                              fontFamily:
                                                                  'Urbanist'),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: map<Widget>(
                                                carImgList,
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
                                                            : Color(
                                                                0xffE0E0E0)),
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
                            SizedBox(height: 15),
                            Container(
                              margin: EdgeInsets.only(left: 16.0, right: 16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  // Car name
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: Text(
                                                _carDetails['About']['Make'] +
                                                    ' ' +
                                                    _carDetails['About']
                                                        ['Model'],
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 30,
                                                    color: Color(0xFF371D32),
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Ink(
                                        decoration: ShapeDecoration(
                                          color: Color(0xffFF8F68),
                                          shape: CircleBorder(),
                                        ),
                                        child: IconButton(
                                          icon: Icon(Icons.share),
                                          color: Colors.white,
                                          onPressed: () {
                                            String completeShareMessage = '$carDetailsLink$_carID';
                                            Share.share(completeShareMessage);


                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // About car
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
                                                  _carDetails['About']
                                                              ['Year'] !=
                                                          ''
                                                      ? Chip(
                                                          label: Text(
                                                            _carDetails['About']
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
                                                  Chip(
                                                    label: Text(
                                                      '${getCurrentMileage(_carDetails)}',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14),
                                                    ),
                                                    backgroundColor:
                                                        Color(0xffF2F2F2),
                                                  ),
                                                  _carDetails['Features']
                                                              ['FuelType'] !=
                                                          ''
                                                      ? Chip(
                                                          label: Text(
                                                            '${_carDetails['Features']['FuelType'] == '91-94 premium' ? 'Premium fuel' : _carDetails['Features']['FuelType'] == '87 regular' ? 'Regular fuel' : _carDetails['Features']['FuelType'] == 'electric' ? 'Electric' : _carDetails['Features']['FuelType'] == 'diesel' ? 'Diesel fuel' : _carDetails['Features']['FuelType']}',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 14),
                                                          ),
                                                          backgroundColor:
                                                              Color(0xffF2F2F2),
                                                        )
                                                      : new Container(),
                                                  _carDetails['Features'][
                                                              'Transmission'] !=
                                                          ''
                                                      ? Chip(
                                                          label: Text(
                                                            '${_carDetails['Features']['Transmission'] == 'automatic' ? 'Automatic' : _carDetails['Features']['Transmission'] == 'manual' ? 'Manual' : _carDetails['Features']['Transmission']} transmission',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 14),
                                                          ),
                                                          backgroundColor:
                                                              Color(0xffF2F2F2),
                                                        )
                                                      : new Container(),
                                                  _carDetails['Features'][
                                                              'NumberOfDoors'] !=
                                                          ''
                                                      ? Chip(
                                                          label: Text(
                                                            _carDetails['Features']
                                                                        [
                                                                        'NumberOfDoors']
                                                                    .toString() +
                                                                ' Doors',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 14),
                                                          ),
                                                          backgroundColor:
                                                              Color(0xffF2F2F2),
                                                        )
                                                      : new Container(),
                                                  _carDetails['Features'][
                                                              'NumberOfSeats'] !=
                                                          ''
                                                      ? Chip(
                                                          label: Text(
                                                            _carDetails['Features']
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
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          shape: BoxShape.rectangle,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 8,
                                              child: GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                      context, '/user_profile',
                                                      arguments:
                                                          _profileDetails);
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    _profileDetails[
                                                                'ImageID'] !=
                                                            ''
                                                        ? Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: 70,
                                                            width: 70,
                                                            decoration:
                                                                BoxDecoration(
                                                                    image:
                                                                        DecorationImage(
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      image: NetworkImage(
                                                                          '$storageServerUrl/${_profileDetails['ImageID']}'),
                                                                    ),
                                                                    color: Color(
                                                                        0xffF2F2F2),
                                                                    shape: BoxShape
                                                                        .circle),
                                                          )
                                                        : Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: 70,
                                                            width: 70,
                                                            decoration: BoxDecoration(
                                                                image: DecorationImage(
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    image: AssetImage(
                                                                        'images/user.png')),
                                                                color: Color(
                                                                    0xffF2F2F2),
                                                                shape: BoxShape
                                                                    .circle),
                                                          ),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          // _loggedIn?
                                                          // Text(
                                                          //   _profileDetails['FirstName'] + ' ' +
                                                          //       _profileDetails['LastName'],
                                                          //   style: TextStyle(
                                                          //       fontFamily:
                                                          //           'Roboto',
                                                          //       fontSize: 18),
                                                          // ):
                                                          Text(
                                                            _profileDetails[
                                                                    'FirstName'] +
                                                                ' ' +
                                                                '${_profileDetails['LastName'][0]}.',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 18),
                                                          ),
                                                          SizedBox(height: 8),
                                                          Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Container(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            5.0),
                                                                decoration: BoxDecoration(
                                                                    shape: BoxShape
                                                                        .rectangle,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                6),
                                                                    color: Color(
                                                                        0xffFFFFFF)),
                                                                child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                      Icons
                                                                          .star,
                                                                      color: Color(
                                                                          0xff7CB7B6),
                                                                      size: 12,
                                                                    ),
                                                                    SizedBox(
                                                                        width:
                                                                            3.0),
                                                                    Container(
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                            '${_profileDetails['ProfileRating'].toStringAsFixed(1)} ',
                                                                            style: TextStyle(
                                                                                color: Color(0xff353B50),
                                                                                fontSize: 12,
                                                                                fontFamily: 'Urbanist'),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          Container(
                                                                            width:
                                                                                2,
                                                                            height:
                                                                                2,
                                                                            decoration:
                                                                                new BoxDecoration(
                                                                              color: Color(0xff353B50),
                                                                              shape: BoxShape.circle,
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                4,
                                                                          ),
                                                                          Text(
                                                                            ' ${_profileDetails['NumberOfTrips']} TRIPS',
                                                                            style: TextStyle(
                                                                                color: Color(0xff353B50),
                                                                                fontSize: 12,
                                                                                fontFamily: 'Urbanist'),
                                                                          ),
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
                                            _loggedIn &&
                                                    (_profileDetails[
                                                            'UserID'] !=
                                                        _loggedInUser)
                                                ? Expanded(
                                                    flex: 2,
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            Container(
                                                              height: 48,
                                                              width: 48,
                                                              decoration: BoxDecoration(
                                                                color: Color(0xffFF8F68),
                                                                borderRadius: BorderRadius.circular(30.0),
                                                              ),
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  Thread threadData = Thread(
                                                                    id: "1123571113",
                                                                    userId: _profileDetails['UserID'],
                                                                    image: _profileDetails['ImageID'] != "" ? _profileDetails['ImageID'] : "",
                                                                    name: _profileDetails['FirstName'] + ' ' + _profileDetails['LastName'],
                                                                    message: '',
                                                                    time: '',
                                                                    messages: [],
                                                                  );

                                                                  Navigator.push(
                                                                    context,
                                                                    MaterialPageRoute(
                                                                      settings: RouteSettings(name: "/messages"),
                                                                      builder: (context) => MessageListView(
                                                                        thread: threadData,
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                                child: Center(
                                                                  child: Image.asset(
                                                                    'icons/Message-3.png',
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : new Container(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 30),
                                  // Features header

                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Features',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 24,
                                                          color:
                                                              Color(0xFF371D32),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Features
                                      SizedBox(height: 10),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GridView.builder(
                                                  itemCount: _features.length,
                                                  primary: false,
                                                  shrinkWrap: true,
                                                  gridDelegate:
                                                      SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisSpacing: 1,
                                                    mainAxisSpacing: 1,
                                                    crossAxisCount: 2,
                                                    childAspectRatio: 16 / 3,
                                                  ),
                                                  itemBuilder:
                                                      (BuildContext context,
                                                          int index) {
                                                    return Column(
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          // width: MediaQuery.of(context).size.width*.75,
                                                          // height:MediaQuery.of(context).size.height*.048,

                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Image.asset('icons/' +
                                                                  _features[
                                                                          index]
                                                                      [
                                                                      'image']),
                                                              SizedBox(
                                                                  width: 6),
                                                              Expanded(
                                                                child:
                                                                    AutoSizeText(
                                                                  _features[
                                                                          index]
                                                                      ['text'],
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                        0xFF353B50),
                                                                  ),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 1,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Insurance header
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          // Expanded(
                                          //   child: Column(
                                          //     children: [
                                          //       // SizedBox(
                                          //       //   width: double.maxFinite,
                                          //       //   child: Align(
                                          //       //     alignment:
                                          //       //         Alignment.centerLeft,
                                          //       //     child: Text(
                                          //       //       'Insurance',
                                          //       //       style: TextStyle(
                                          //       //           fontFamily:
                                          //       //               'Urbanist',
                                          //       //           fontSize: 24,
                                          //       //           color:
                                          //       //               Color(0xFF371D32),
                                          //       //           fontWeight:
                                          //       //               FontWeight.bold),
                                          //       //     ),
                                          //       //   ),
                                          //       // ),
                                          //     ],
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      // Insurance button
                                      SizedBox(height: 10),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child:  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                    elevation: 0.0,
                                                    backgroundColor: Color(0xFFF2F2F2),
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),),
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/insurance_policy',
                                                      );
                                                    },
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: <Widget>[
                                                        Column(
                                                          children: <Widget>[
                                                            Text(
                                                              'Insurance policy',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xFF371D32),
                                                              ),
                                                            ),
                                                            // Text('Insurance policy.',
                                                            //   style: TextStyle(
                                                            //     fontFamily: 'Urbanist',
                                                            //     fontSize: 14,
                                                            //     color: Color(0xFF353B50),
                                                            //   ),
                                                            // ),
                                                          ],
                                                        ),
                                                        Icon(
                                                            Icons
                                                                .keyboard_arrow_right,
                                                            color: Color(
                                                                0xFF353B50)),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Car rules
                                      SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Vehicle rules',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 22,
                                                          color:
                                                              Color(0xFF371D32),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Rules
                                      SizedBox(height: 10),

                                      // First row
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          !_carDetails['Preference']
                                                  ['IsSmokingAllowed']
                                              ? Expanded(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        width: double.maxFinite,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Image.asset(
                                                                'icons/No-smoking.png'),
                                                            SizedBox(
                                                                width: 5.0),
                                                            Container(
                                                              child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'No smoking',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontSize:
                                                                            14,
                                                                        color: Color(
                                                                            0xFF353B50),
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : new Container(),
                                          !_carDetails['Preference']
                                                  ['IsSuitableForPets']
                                              ? Expanded(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        width: double.maxFinite,
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: <Widget>[
                                                            Image.asset(
                                                                'icons/No-Pets.png'),
                                                            SizedBox(
                                                                width: 5.0),
                                                            Container(
                                                              child: Row(
                                                                  children: [
                                                                    Text(
                                                                      'No pets',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontSize:
                                                                            14,
                                                                        color: Color(
                                                                            0xFF353B50),
                                                                      ),
                                                                    ),
                                                                  ]),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : new Container(),
                                        ],
                                      ),
                                      !_carDetails['Preference']
                                                  ['IsSmokingAllowed'] ||
                                              !_carDetails['Preference']
                                                  ['IsSuitableForPets']
                                          ? SizedBox(height: 10)
                                          : new Container(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: <Widget>[
                                                      Image.asset(
                                                          'icons/Mileage.png'),
                                                      SizedBox(width: 5.0),
                                                      Expanded(
                                                        child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              _carDetails['Preference']
                                                                          [
                                                                          'DailyMileageAllowance'] ==
                                                                      "Limited"
                                                                  ? SizedText(
                                                                      deviceWidth:
                                                                          deviceWidth,
                                                                      textWidthPercentage:
                                                                          0.85,
                                                                      text: _carDetails['Preference']['Limit']
                                                                              .toString() +
                                                                          ' km allowed daily, extra mileage is \$' +
                                                                          _carDetails['Pricing']['RentalPricing']['PerExtraKMOverLimit']
                                                                              .toStringAsFixed(2) +
                                                                          '/km',
                                                                      textColor:
                                                                          Color(
                                                                              0xFF353B50),
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      fontSize:
                                                                          14,
                                                                    )
                                                                  : Text(
                                                                      'Unlimited mileage allowance',
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontSize:
                                                                            14,
                                                                        color: Color(
                                                                            0xFF353B50),
                                                                      ),
                                                                    ),
                                                            ]),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Image.asset(
                                                          'icons/Fuel-2.png'),
                                                      SizedBox(width: 5.0),
                                                      SizedText(
                                                        deviceWidth:
                                                            deviceWidth,
                                                        textWidthPercentage:
                                                            0.85,
                                                        text: _carDetails[
                                                                        'Features']
                                                                    [
                                                                    'FuelType'] !=
                                                                null
                                                            ? 'Refuel with ${_carDetails['Features']['FuelType'] == '91-94_PREMIUM' ? 'Premium' : _carDetails['Features']['FuelType'] == '91-94 premium' ? 'Premium' : _carDetails['Features']['FuelType'] == '87_REGULAR' ? 'Regular' : _carDetails['Features']['FuelType'] == '87 regular' ? 'Regular' : _carDetails['Features']['FuelType'] == 'electric' ? 'Electric' : _carDetails['Features']['FuelType'] == 'ELECTRIC' ? 'Electric' : _carDetails['Features']['FuelType'] == 'diesel' ? 'Diesel' : _carDetails['Features']['FuelType'] == 'DIESEL' ? 'Diesel' : _carDetails['Features']['FuelType']} only'
                                                            : '',
                                                        textColor:
                                                            Color(0xFF353B50),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Image.asset(
                                                          'icons/Fuel-2.png'),
                                                      SizedBox(width: 5.0),
                                                      SizedText(
                                                        deviceWidth:
                                                            deviceWidth,
                                                        textWidthPercentage:
                                                            0.85,
                                                        text:
                                                            'Return with the same fuel level',
                                                        textColor:
                                                            Color(0xFF353B50),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Image.asset(
                                                          'icons/Cleanliness-2.png'),
                                                      SizedBox(width: 5.0),
                                                      SizedText(
                                                        deviceWidth:
                                                            deviceWidth,
                                                        textWidthPercentage:
                                                            0.82,
                                                        text:
                                                            'Return in the same state of cleanliness',
                                                        textColor:
                                                            Color(0xFF353B50),
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                      //booking rules//
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Booking rules',
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 22,
                                                color: Color(0xFF371D32),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Icon(Icons.adjust_rounded),
                                              SizedBox(width: 8),
                                              Text(
                                                'Minimum trip ${shortestTrip(_carDetails)}',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF353B50),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          //Maximum trip//
                                          Row(
                                            children: [
                                              Icon(Icons.adjust_rounded),
                                              SizedBox(width: 8),
                                              Text(
                                                'Maximum trip ${getLongestTripToString(_carDetails)}',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF353B50),
                                                ),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          //advanced notice && same day cut off//

                                          Row(
                                            children: [
                                              Icon(Icons.adjust_rounded),
                                              SizedBox(width: 8),
                                              _carDetails['Availability'][
                                                                  'RentalAvailability']
                                                              [
                                                              'AdvanceNotice'] !=
                                                          null &&
                                                      _carDetails['Availability']
                                                                  [
                                                                  'RentalAvailability']
                                                              [
                                                              'AdvanceNotice'] ==
                                                          'SameDay'
                                                  ? SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .75,
                                                      child: AutoSizeText(
                                                        'Cannot be booked after' +
                                                            ' ' +
                                                            hour.toString() +
                                                            ':00' +
                                                            ' ' +
                                                            (num.parse((_carDetails['Availability']['RentalAvailability']['SameDayCutOffTime']
                                                                            [
                                                                            'hours'])
                                                                        .toStringAsFixed(
                                                                            2)) >
                                                                    11.59
                                                                ? 'PM'
                                                                : 'AM') +
                                                            ' ' +
                                                            'same day',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF353B50),
                                                        ),
                                                        maxLines: 2,
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .75,
                                                      child: AutoSizeText(
                                                          'Host requires ${getAdvanceNotice(_carDetails)} ' +
                                                              'advance notice.',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFF353B50),
                                                          ),
                                                          maxLines: 2),
                                                    )
                                            ],
                                          ),
                                        ],
                                      ),
                                      // Pickup and return
                                      SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Pickup and return location',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 22,
                                                          color:
                                                              Color(0xFF371D32),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      //postal code address//
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: address != ''
                                                        ? Text(
                                                            'Near' +
                                                                ' ' +
                                                                '$address',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          )
                                                        : Text(
                                                            'No address found',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Map
                                      SizedBox(height: 10),
                                      Container(
                                        height: 200,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                          child: GoogleMap(
                                            myLocationButtonEnabled: false,
                                            myLocationEnabled: false,
                                            mapToolbarEnabled: false,
                                            zoomGesturesEnabled: true,
                                            zoomControlsEnabled: true,
                                            scrollGesturesEnabled: true,
                                            gestureRecognizers: <
                                                Factory<
                                                    OneSequenceGestureRecognizer>>[
                                              new Factory<
                                                  OneSequenceGestureRecognizer>(
                                                () =>
                                                    new EagerGestureRecognizer(),
                                              ),
                                            ].toSet(),
                                            initialCameraPosition:
                                                _initialCamera,
                                            mapType: MapType.normal,
                                            onMapCreated: (GoogleMapController
                                                controller) {
                                              _mapController
                                                  .complete(controller);
                                              setState(() {
                                                if (showLocation) {
                                                  _setmarker(_bookingInfo);
                                                } else {
                                                  _setCircles(_bookingInfo);
                                                }
                                              });
                                            },
                                            // onTap: (latLong) {
                                            //   // print("lat  ${latLong.latitude}");
                                            //   // print("long  ${latLong.longitude}");
                                            //   setState(() {
                                            //     location = latLong;
                                            //   });
                                            // },
                                            circles: _circles,
                                            markers: _markers,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      //delivery limit//
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset('icons/Location-2.png'),
                                          SizedBox(width: 5),
                                          SizedText(
                                            deviceWidth: deviceWidth,
                                            textWidthPercentage: 0.85,
                                            text: deliveryLimit == false
                                                ? 'Delivery not available'
                                                : 'Delivery available within 50 km at \$${_carDetails['Pricing']['RentalPricing']['PerKMRentalDeliveryFee']}/km',
                                            textColor: Color(0xFF371D32),
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                          ),
                                        ],
                                      ),

                                      // Row(
                                      //   mainAxisAlignment:
                                      //       MainAxisAlignment.start,
                                      //   children: <Widget>[
                                      //     Expanded(
                                      //       child: Column(
                                      //         children: [
                                      //           SizedBox(
                                      //             width: double.maxFinite,
                                      //             child: Row(
                                      //               mainAxisAlignment:
                                      //                   MainAxisAlignment.start,
                                      //               children: <Widget>[
                                      //                 Image.asset(
                                      //                     'icons/Location-2.png'),
                                      //                 SizedBox(width: 5),
                                      //                 Text(
                                      //                   'Delivery available within 50 km. Delivery available within 50 km. Delivery available within 50 km.',
                                      //                   style: TextStyle(
                                      //                     fontFamily: 'Urbanist',
                                      //                     fontSize: 14,
                                      //                     color:
                                      //                         Color(0xFF371D32),
                                      //                   ),
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //           ),
                                      //         ],
                                      //       ),
                                      //     ),
                                      //   ],
                                      // ),

                                      // Notes header
                                      _carDetails['About']['Location']
                                                      ['Notes'] !=
                                                  null &&
                                              _carDetails['About']['Location']
                                                      ['Notes'] !=
                                                  ''
                                          ? SizedBox(height: 30)
                                          : Container(),
                                      _carDetails['About']['Location']
                                                      ['Notes'] !=
                                                  null &&
                                              _carDetails['About']['Location']
                                                      ['Notes'] !=
                                                  ''
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Expanded(
                                                  child: Column(
                                                    children: [
                                                      SizedBox(
                                                        width: double.maxFinite,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            'Notes',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'Roboto',
                                                                fontSize: 24,
                                                                color: Color(
                                                                    0xFF371D32),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      _carDetails['About']['Location']
                                                      ['Notes'] !=
                                                  null &&
                                              _carDetails['About']['Location']
                                                      ['Notes'] !=
                                                  ''
                                          ? SizedBox(height: 10)
                                          : Container(),
                                      _carDetails['About']['Location']
                                                      ['Notes'] !=
                                                  null &&
                                              _carDetails['About']['Location']
                                                      ['Notes'] !=
                                                  ''
                                          ? Container(
                                              width: double.maxFinite,
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF2F2F2),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8)),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Text(
                                                  _carDetails['About']
                                                                  ['Location']
                                                              ['Notes'] !=
                                                          null
                                                      ? _carDetails['About']
                                                          ['Location']['Notes']
                                                      : 'Default note',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF353B50),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Container(),
                                      // Cancellation policy header
                                      SizedBox(height: 30),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Cancellation policy',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 24,
                                                          color:
                                                              Color(0xFF371D32),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child:  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      elevation: 0.0,
                                                      backgroundColor: Color(0xFFF2F2F2),
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),),
                                                      onPressed: () {},
                                                      child: Row(
                                                        children: <Widget>[
                                                          Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                'Flexible',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Roboto',
                                                                  fontSize: 16,
                                                                  color: Color(
                                                                      0xFF371D32),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                  height: 10),
                                                              SizedText(
                                                                deviceWidth:
                                                                    deviceWidth,
                                                                textWidthPercentage:
                                                                    0.8,
                                                                text:
                                                                    'Full refund 24 hours prior to the trip',
                                                                textColor: Color(
                                                                    0xFF353B50),
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 14,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Car reviews header
                                      SizedBox(height: 22),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Vehicle reviews',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 24,
                                                          color:
                                                              Color(0xFF371D32),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child:  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      elevation: 0.0,
                                                      backgroundColor: Color(0xFFF2F2F2),
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0)),),
                                                      onPressed: () {
                                                        Navigator.pushNamed(
                                                            context,
                                                            '/car_reviews',
                                                            arguments:
                                                                _carReviews);
                                                      },
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Image.asset(
                                                                  'icons/Rating.png'),
                                                              SizedBox(
                                                                  width: 5),
                                                              Text(
                                                                _carDetails[
                                                                        'Rating']
                                                                    .toStringAsFixed(
                                                                        1),
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Roboto',
                                                                    fontSize:
                                                                        24,
                                                                    color: Color(
                                                                        0xFF371D32),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedText(
                                                            deviceWidth:
                                                                deviceWidth,
                                                            textWidthPercentage:
                                                                0.58,
                                                            text: 'Based on ' +
                                                                _carReviews
                                                                    !.length
                                                                    .toString() +
                                                                ' reviews',
                                                            textColor: Color(
                                                                0xFF353B50),
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 14,
                                                          ),
                                                          Container(
                                                            child: Icon(
                                                                Icons
                                                                    .keyboard_arrow_right,
                                                                color: Color(
                                                                    0xFF353B50)),
                                                          ),
                                                        ],
                                                      )),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      // Overlay if not logged in
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                '\$' +
                                                    double.parse(_carDetails[
                                                                        'Pricing']
                                                                    [
                                                                    'RentalPricing']
                                                                ['PerDay']
                                                            .toString())
                                                        .round()
                                                        .toString(),
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xff371D32),
                                                ),
                                              ),
                                              Text(
                                                'PER DAY',
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 12,
                                                    color: Color(0xff353B50)),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Image.asset(
                                                      'icons/Hourly-Trip.png'),
                                                  SizedBox(width: 6.0),
                                                  SizedText(
                                                    deviceWidth: deviceWidth,
                                                    textWidthPercentage: 0.65,
                                                    text: _carDetails[
                                                                            'Availability']
                                                                        [
                                                                        'RentalAvailability']
                                                                    [
                                                                    'ShortestTrip'] ==
                                                                1 ||
                                                            _carDetails['Availability']
                                                                        [
                                                                        'RentalAvailability']
                                                                    [
                                                                    'ShortestTrip'] ==
                                                                2 ||
                                                            _carDetails['Availability']
                                                                        [
                                                                        'RentalAvailability']
                                                                    [
                                                                    'ShortestTrip'] ==
                                                                3
                                                        ? 'Hourly trips available'
                                                        : 'Hourly trips not available',
                                                    textColor:
                                                        Color(0xff353B50),
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 5),
                                              Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Image.asset(
                                                      'icons/Long-term-Trip.png'),
                                                  SizedBox(width: 6.0),
                                                  SizedText(
                                                    deviceWidth: deviceWidth,
                                                    textWidthPercentage: 0.62,
                                                    text: _carDetails['Availability']
                                                                    [
                                                                    'RentalAvailability']
                                                                [
                                                                'LongestTrip'] >=
                                                            7
                                                        ? 'Long-term trips available'
                                                        : 'Long-term trips not available',
                                                    textColor:
                                                        Color(0xff353B50),
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
//                        profileVerificationResponse.verification.phoneVerification.verificationStatus=='Verified'
//                            && profileVerificationResponse.verification.emailVerification.verificationStatus=='Verified'?SizedBox(height: 20):SizedBox(height: 15),
                                      // Reserve a car button
                                      SizedBox(height: 8),
                                      // _loggedIn
                                      //     ? userID != _carDetails['UserID']
                                      //         ? bookingButton
                                      //             ? Align(
                                      //                 alignment: Alignment.center,
                                      //                 child: SizedBox(
                                      //                   width: double.maxFinite,
                                      //                   child: FloatingActionButton(
                                      //                       elevation: 0.0,
                                      //                       backgroundColor:
                                      //                           Color(0xffFF8F68),
                                      //                       // padding:
                                      //                       //     EdgeInsets.all(
                                      //                       //         16.0),
                                      //                       shape: RoundedRectangleBorder(
                                      //                           borderRadius:
                                      //                               BorderRadius.circular(
                                      //                                   8.0)),
                                      //                       onPressed: profileVerificationResponse
                                      //                                       .verification
                                      //                                       .phoneVerification
                                      //                                       .verificationStatus ==
                                      //                                   'Verified' &&
                                      //                               profileVerificationResponse
                                      //                                       .verification
                                      //                                       .emailVerification
                                      //                                       .verificationStatus ==
                                      //                                   'Verified' &&
                                      //                               _ownProfileData['VerificationStatus'] ==
                                      //                                   'Verified' &&
                                      //                               _carDetails['Availability']['RentalAvailability']
                                      //                                       ['BookingWindow'] !=
                                      //                                   'DatesUnavailable' &&
                                      //                               (_carDetails['Verification'] != null && _carDetails['Verification']['VerificationStatus'] != 'Updated')
                                      //                           ? () async {
                                      //                               String
                                      //                                   profileID =
                                      //                                   await storage
                                      //                                       .read(
                                      //                                           key: 'profile_id');
                                      //
                                      //                               if (profileID !=
                                      //                                   null) {
                                      //                                 // Card null check
                                      //                                 fetchCardInfo(
                                      //                                         userID)
                                      //                                     .then(
                                      //                                         (value) {
                                      //                                   setState(
                                      //                                       () {
                                      //                                     cardInfo =
                                      //                                         PaymentCardInfo.fromJson(json.decode(value.body!));
                                      //                                     if (cardInfo !=
                                      //                                             null &&
                                      //                                         cardInfo.cardInfo.length >
                                      //                                             0) {
                                      //                                       _cardAdded =
                                      //                                           true;
                                      //                                     } else {
                                      //                                       _cardAdded =
                                      //                                           false;
                                      //                                     }
                                      //                                     //
                                      //                                     _loggedIn =
                                      //                                         true;
                                      //                                     _loggedInUser =
                                      //                                         userID;
                                      //                                   });
                                      //                                   handleShowAddCardModal();
                                      //                                 });
                                      //                               } else {
                                      //                                 Navigator.pushNamed(
                                      //                                     context,
                                      //                                     '/create_profile_or_sign_in');
                                      //                               }
                                      //                             }
                                      //                           : null,
                                      //                       child: Text(
                                      //                         'Continue booking',
                                      //                         style: TextStyle(
                                      //                             fontFamily:
                                      //                                 'Urbanist',
                                      //                             fontSize: 18,
                                      //                             color: Colors
                                      //                                 .white),
                                      //                       )),
                                      //                 ),
                                      //               )
                                      //             : Container()
                                      //         : Column(
                                      //             children: [
                                      //               Padding(
                                      //                 padding:
                                      //                     const EdgeInsets.only(
                                      //                         left: 8, right: 8),
                                      //                 child: Text(
                                      //                   'You can not book your own vehicle',
                                      //                   style: TextStyle(
                                      //                     fontFamily: 'Urbanist',
                                      //                     fontSize: 14,
                                      //                     color:
                                      //                         Color(0xFF353B50),
                                      //                   ),
                                      //                 ),
                                      //               ),
                                      //               SizedBox(height: 5),
                                      //             ],
                                      //           )
                                      //     : Align(
                                      //         alignment: Alignment.center,
                                      //         child: SizedBox(
                                      //           width: double.maxFinite,
                                      //           child: ElevatedButton(style: ElevatedButton.styleFrom(
                                      //             elevation: 0.0,
                                      //             color: Color(0xffFF8F68),
                                      //             padding: EdgeInsets.all(16.0),
                                      //             shape: RoundedRectangleBorder(
                                      //                 borderRadius:
                                      //                     BorderRadius.circular(
                                      //                         8.0)),
                                      //             onPressed: () {
                                      //               //todo
                                      //
                                      //               Navigator.pushNamed(context,
                                      //                   '/create_profile_or_sign_in',
                                      //                   arguments: {
                                      //                     'ROUTE':
                                      //                         '/car_details_non_search',
                                      //                     'ARGUMENTS': _carID,
                                      //                   });
                                      //             },
                                      //             child: Text(
                                      //               'Reserve a vehicle',
                                      //               style: TextStyle(
                                      //                   fontFamily:
                                      //                       'Urbanist',
                                      //                   fontSize: 18,
                                      //                   color: Colors.white),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ),
                                      SizedBox(height: 30),
                                      SizedBox(height: 80),

                                      _loggedIn
                                          ? userID != _carDetails['UserID']
                                              ? profileVerificationResponse
                                                              !.verification!
                                                              .phoneVerification!
                                                              .verificationStatus ==
                                                          'Verified' &&
                                                      profileVerificationResponse
                                                              !.verification!
                                                              .emailVerification!
                                                              .verificationStatus ==
                                                          'Verified' &&
                                                      _ownProfileData!['VerificationStatus'] ==
                                                          'Verified' &&
                                                      _carDetails['Availability']
                                                                  ['RentalAvailability'][
                                                              'BookingWindow'] !=
                                                          'DatesUnavailable' &&
                                                      (_carDetails['Verification'] !=
                                                              null &&
                                                          _carDetails['Verification']['VerificationStatus'] !=
                                                              'Updated')
                                                  ? Container()
                                                  : _carDetails['Availability']
                                                                      ['RentalAvailability']
                                                                  ['BookingWindow'] ==
                                                              'DatesUnavailable' ||
                                                          (_carDetails['Verification'] != null && _carDetails['Verification']['VerificationStatus'] == 'Updated')
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 8,
                                                                  right: 8),
                                                          child: Text(
                                                            'This vehicle is currently unavailable for booking.',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF353B50),
                                                            ),
                                                          ),
                                                        )
                                                      : _ownProfileData!['VerificationStatus'] == 'Blocked'
                                                          ? Padding(
                                                              padding: const EdgeInsets.only(left: 8, right: 8),
                                                              child: Text(
                                                                'RideAlike has temporarily blocked your profile. Please contact admin@ridealike.com',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xFF353B50),
                                                                ),
                                                              ))
                                                          : profileVerificationResponse!.verification!.phoneVerification!.verificationStatus == 'Verified' &&
                                                                  profileVerificationResponse!.verification!.emailVerification!.verificationStatus == 'Verified'
                                                                  // && _ownProfileData['AboutMe']!='' && (cardInfo!=null && cardInfo.cardInfo.length>0)
                                                                  &&
                                                                  _ownProfileData!['VerificationStatus'] != 'Verified'
                                                              ? Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      left: 8,
                                                                      right: 8),
                                                                  child: Text(
                                                                    'Verification of your profile is in progress. RideAlike will email you when completed.',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      fontSize:
                                                                          14,
                                                                      color: Color(
                                                                          0xFF353B50),
                                                                    ),
                                                                  ),
                                                                )
                                                              : Padding(
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 12,
                                                                      left: 8,
                                                                      right: 8),
                                                                  child: Text(
                                                                    'Please complete your Profile details to enable RideAlike to verify your profile.',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      fontSize:
                                                                          14,
                                                                      color: Color(
                                                                          0xFF353B50),
                                                                    ),
                                                                  ),
                                                                )
                                              : (_carDetails['Verification'] != null && _carDetails['Verification']['VerificationStatus'] == 'Updated') || _carDetails['Availability']['RentalAvailability']['BookingWindow'] == 'DatesUnavailable'
                                                  ? Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 8,
                                                              right: 8),
                                                      child: Text(
                                                        'This vehicle is currently unavailable for booking.',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF353B50),
                                                        ),
                                                      ),
                                                    )
                                                  : Container()
                                          : Container(),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // If not logged in
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

  void _setCircles(_bookingInfo) {
    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;

    setState(() {
      _markers.clear();
      _circles.clear();
      _circles.add(
        Circle(
            circleId: CircleId(circleIdVal),
            center: LatLng(_bookingInfo['locLat'], _bookingInfo['locLong']),
            radius: 500,
            fillColor: Color.fromRGBO(234, 154, 98, 0.15),
            strokeWidth: 2,
            strokeColor: Color(0xFFEA9A62)),
      );
    });
  }

  void _setmarker(_bookingInfo) {
    final String circleIdVal = 'circle_id_$_circleIdCounter';
    _circleIdCounter++;

    setState(() {
      _circles.clear();
      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(circleIdVal),
        position: LatLng(_bookingInfo['locLat'], _bookingInfo['locLong']),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }
}
