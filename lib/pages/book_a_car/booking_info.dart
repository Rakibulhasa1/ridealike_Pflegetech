import 'dart:async';
import 'dart:convert' show Utf8Decoder, json;
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/utils/dateutils.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:ridealike/widgets/sized_text.dart';
import 'booking_insurance.dart';
import 'booking_set_location.dart';
import 'booking_trip_duration.dart';
import 'coupon_response/coupon_response.dart';
import 'trip_booked.dart';

String? address;
String? formattedAddress;

Map _cardData = {};

Future<RestApi.Resp> fetchCarData(param) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getCarUrl,
    json.encode({"CarID": param}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

String carId = '';
String userId = '';

Future<ApiResponse> fetchCoupons(String carId, String userId) async {
  final completer = Completer<ApiResponse>();
  RestApi.callAPI(
    getAvailableCouponUrl,
    json.encode({
      "CarID": carId,
      "UserID": userId,
    }),
  ).then((response) {
    if (response.statusCode == 200) {
      completer
          .complete(ApiResponse.fromJson(json.decode(response.body as String)));
    } else {
      completer.completeError(
          'Failed to load coupons with status code: ${response.statusCode}');
    }
  }).catchError((error) {
    completer.completeError('Failed to load coupons: $error');
  });
  return completer.future;
}

Future<RestApi.Resp> fetchPricingInfo(param) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getPricingUrl,
    json.encode({
      "BookingParams": {
        "CarID": param['_carID'],
        "StartDateTime":
            DateTime.parse(param['_tripStartDate']).toUtc().toIso8601String(),
        "EndDateTime":
            DateTime.parse(param['_tripEndDate']).toUtc().toIso8601String(),
        "PickupReturnLocation": {
          "Address": param['_locationAddress'],
          "FormattedAddress": param['FormattedAddress'],
          "LatLng": {
            "Latitude": param['_locationLat'],
            "Longitude": param['_locationLon']
          },
          "CustomLoc": param['CustomLoc']
        },
        "InsuranceType": param['_insuranceType'],
        "DeliveryNeeded": param['_deliveryNeeded'],
        "CouponCode": param['couponCode'],
        "UserID": param['_userID']
      }
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> fetchCardData(_userID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getCardsByUserIDUrl,
    json.encode({
      "UserID": _userID,
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

class BookingInfo extends StatefulWidget {
  final bookingInfo;
  final double? maxDiscount;

  BookingInfo({this.bookingInfo, this.maxDiscount});

  @override
  State createState() => BookingInfoState(bookingInfo);
}

class BookingInfoState extends State<BookingInfo> {
  var bookingInfo;
  String _error = '';
  String _deliveryErrorText = '';
  bool _deliveryError = false;
  bool _hasError = false;
  final storage = new FlutterSecureStorage();
  var costPrice;
  String? _userID;
  TextEditingController _couponTextController = new TextEditingController();
  List<String> calendarEvents = [];

  DateTime? selectedPeriodStart;
  DateTime? selectedPeriodEnd;
  DateTime? _lastDate;
  String _couponCode = 'RAKIB35';
  bool _fromSearch = false;

  BookingInfoState(this.bookingInfo);

  void showAvailabilityAlert() {
    showDialog(
      barrierDismissible: false,
      barrierColor: Colors.grey,
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('This vehicle has no available dates for booking.'),
          actions: [
            CupertinoDialogAction(
              child: Text('Go To Discover'),
              onPressed: () async {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/discover_tab', (Route<dynamic> route) => false);
              },
            ),
            CupertinoDialogAction(
              child: Text('Back'),
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void updateDaySelectionForSearch() {
    DateTime start =
        DateTime.parse(bookingInfo['startDate'].toString()).toLocal();
    DateTime end = DateTime.parse(bookingInfo['endDate'].toString()).toLocal();
    _lastDate = _getLastDate(bookingInfo['window'].toString());
    while (start.isBefore(_lastDate!)) {
      if (!calendarEvents.contains(DateFormat('yyyy-MM-dd').format(start)) &&
          !(start.month == DateTime.now().month &&
              start.day == DateTime.now().day &&
              (start.toLocal().hour + 2) > 23)) {
        setState(() {
          selectedPeriodStart = start;
        });
        break;
      }
      start = start.add(Duration(days: 1));
    }
    //
    DateTime tempEnd = DateTime(selectedPeriodStart!.year,
        selectedPeriodStart!.month, selectedPeriodStart!.day, end.hour);

    while (tempEnd.isBefore(end.add(Duration(hours: 1)))) {
      print("temp:::" + tempEnd.toString() + ":::before");
      if (!calendarEvents.contains(DateFormat('yyyy-MM-dd').format(tempEnd))) {
        setState(() {
          selectedPeriodEnd = tempEnd;
          print(selectedPeriodEnd);
        });
      } else {
        break;
      }
      tempEnd = tempEnd.add(Duration(days: 1));
      print("temp:::" + tempEnd.toString() + ":::after");
    }

    //
    _bookingData['_tripStartDate'] =
        DateFormat("y-MM-dd").format(selectedPeriodStart!.toUtc()) +
            'T' +
            selectedPeriodStart!.toUtc().hour.toString() +
            ':00:00.000Z';
    _bookingData['_tripEndDate'] =
        DateFormat("y-MM-dd").format(selectedPeriodEnd!.toUtc()) +
            'T' +
            selectedPeriodEnd!.toUtc().hour.toString() +
            ':00:00.000Z';

    print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    print(_bookingData['_tripStartDate']);
    print(_bookingData['_tripEndDate']);
    print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

    maintainPickUpAndReturnTimeForSearch();
  }

  Future<void> applyCouponCode(String couponCode) async {
    _couponTextController.text = couponCode;
    _bookingData['_carID'] = bookingInfo['carID'];
    _bookingData['_locationAddress'] = bookingInfo['locAddress'];
    _bookingData['FormattedAddress'] = bookingInfo['FormattedAddress'];
    _bookingData['_locationLat'] = bookingInfo['locLat'];
    _bookingData['_locationLon'] = bookingInfo['locLong'];
    _bookingData['_insuranceType'] = bookingInfo['insuranceType'];
    _bookingData['couponCode'] = couponCode;
    _bookingData['_userID'] = _userID!;
    var res = await fetchPricingInfo(_bookingData);
    if (res != null && res.statusCode == 200) {
      var responseCoupon = json.decode(res.body!);
      print('response$responseCoupon');
      setState(() {
        _couponCode = responseCoupon['CouponCode'];
        _pricingInfo = responseCoupon['Booking']['Pricing'];
      });
    }
  }

  void updateDaySelection() {
    /* DateTime start =
        DateTime.parse(bookingInfo['startDate'].toString()).toLocal();
    DateTime end = DateTime.parse(bookingInfo['endDate'].toString()).toLocal();*/
    DateTime start = DateTime.now();
    DateTime tempStart = start.subtract(Duration(
      minutes: start.minute,
      seconds: start.second,
      milliseconds: start.millisecond,
      microseconds: start.microsecond,
    ));
    start = tempStart;
    DateTime end = start;
    print("!!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    print(start);
    print(end);
    print("!!+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    _lastDate = _getLastDate(bookingInfo['window'].toString());
    while (start.isBefore(_lastDate!)) {
      print("start while " + start.toString());
      if (!calendarEvents.contains(DateFormat('yyyy-MM-dd').format(start))) {
        if (!calendarEvents.contains(
            DateFormat('yyyy-MM-dd').format(start.add(Duration(days: 1))))) {
          print("hour:::" + start.hour.toString());
          if (!(start.month == DateTime.now().month &&
              start.day == DateTime.now().day &&
              (start.toLocal().hour + 2) > 23)) {
            selectedPeriodStart = start;
            print("break:::" + selectedPeriodStart.toString());
            break;
          }
        } else {
          if (!(start.month == DateTime.now().month &&
              start.day == DateTime.now().day &&
              (start.toLocal().hour + 2) > 19)) {
            selectedPeriodStart = start;
            break;
          }
        }
      }
      start = start.add(Duration(days: 1));
    }
    end = selectedPeriodStart!;
    for (int i = 0; i < 5; i++) {
      if (end != null &&
          !calendarEvents.contains(DateFormat('yyyy-MM-dd').format(end))) {
        setState(() {
          selectedPeriodEnd = end;
        });
      } else {
        break;
      }
      end = end.add(Duration(days: 1));
    }

    print("##+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    print(selectedPeriodStart);
    print(selectedPeriodEnd);
    print("##+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");

    if (selectedPeriodEnd == null || !selectedPeriodEnd!.isBefore(_lastDate!)) {
      showAvailabilityAlert();
    }

    _bookingData['_tripStartDate'] =
        selectedPeriodStart!.toUtc().toIso8601String();
    _bookingData['_tripEndDate'] = selectedPeriodEnd!.toUtc().toIso8601String();

    print("@@+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    print(_bookingData['_tripStartDate']);
    print(_bookingData['_tripEndDate']);
    print("@@+++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
    //
    maintainPickUpAndReturnTime();
  }

  void maintainPickUpAndReturnTime() {
    DateTime start =
        DateTime.parse(_bookingData['_tripStartDate'].toString()).toLocal();

    DateTime end =
        DateTime.parse(_bookingData['_tripEndDate'].toString()).toLocal();

    print("maintainPickUpAndReturnTime()");
    print(start);
    print(end);

    int hours = DateTime.now().toLocal().hour;
    if (start.day == DateTime.now().day && end.difference(start).inDays >= 1) {
      print(
          "start.day == DateTime.now().day && end.difference(start).inDays > 1");
      _bookingData['_tripStartDate'] =
          start.add(Duration(hours: 2)).toUtc().toIso8601String();
      _bookingData['_tripEndDate'] =
          (end.subtract(Duration(hours: end.hour))).toUtc().toIso8601String();
    }
    if (start.day == DateTime.now().day && end.difference(start).inDays < 1) {
      print(
          "start.day == DateTime.now().day && end.difference(start).inDays <= 1##############################################");
      if (hours + 2 > 23) {
        //
      } else {
        if (start.hour <= hours + 2) {
          int diff = (hours + 2) - start.hour;
          start = start.add(Duration(hours: diff));
        }
        _bookingData['_tripStartDate'] = start.toUtc().toIso8601String();
        if (end.difference(start).inDays <= 1) {
          _bookingData['_tripEndDate'] =
              start.add(Duration(hours: 4)).toUtc().toIso8601String();
        }
      }
    }
    if (start.day != DateTime.now().day && end.difference(start).inDays < 1) {
      print(
          "end.difference(start).inDays##############################################");
      DateTime _tempStart = start.subtract(Duration(hours: start.hour));
      _bookingData['_tripStartDate'] = _tempStart.toUtc().toIso8601String();
      _bookingData['_tripEndDate'] =
          (_tempStart.add(Duration(hours: 4))).toUtc().toIso8601String();
    }
    if (start.day != DateTime.now().day && end.difference(start).inDays >= 1) {
      print("end.difference(start).inDays > 1");
      print(
          "end.difference(start).inDays##############################################");
      DateTime _tempStart = start.subtract(Duration(hours: start.hour));
      _bookingData['_tripStartDate'] = _tempStart.toUtc().toIso8601String();
      DateTime _tempEnd = end.subtract(Duration(hours: end.hour));
      _bookingData['_tripEndDate'] = _tempEnd.toUtc().toIso8601String();
    }
    print("44##############################################");
    print(_bookingData['_tripStartDate']);
    print(_bookingData['_tripEndDate']);
    print("44##############################################");
    getPricing();
  }

  void maintainPickUpAndReturnTimeForSearch() {
    DateTime start =
        DateTime.parse(_bookingData['_tripStartDate'].toString()).toLocal();

    DateTime end =
        DateTime.parse(_bookingData['_tripEndDate'].toString()).toLocal();

    print("33##############################################");
    print(start);
    print(end);
    print("33##############################################");

    int hours = DateTime.now().toLocal().hour;

    if (start.day == DateTime.now().day && end.difference(start).inDays <= 1) {
      if (hours + 2 > 23) {
        //
      } else {
        if (start.hour <= hours + 2) {
          int diff = (hours + 2) - start.hour;
          start = start.add(Duration(hours: diff));
        }
        _bookingData['_tripStartDate'] = start.toUtc().toIso8601String();
        if (end.difference(start).inDays <= 1) {
          _bookingData['_tripEndDate'] =
              start.add(Duration(hours: 4)).toUtc().toIso8601String();
        }
      }
    }
    if (end.difference(start).inDays <= 1) {
      _bookingData['_tripStartDate'] = start.toUtc().toIso8601String();
      if (end.difference(start).inHours < 4) {
        _bookingData['_tripEndDate'] =
            start.add(Duration(hours: 4)).toUtc().toIso8601String();
      } else {
        _bookingData['_tripEndDate'] = end.toUtc().toIso8601String();
      }
    }
    print("44##############################################");
    print(_bookingData['_tripStartDate']);
    print(_bookingData['_tripEndDate']);
    print("44##############################################");
    getPricing();
  }

  DateTime _getLastDate(String status) {
    DateTime time = DateTime.now();
    if (status == null || status.isEmpty) {
      time = time.add(Duration(hours: 1));
    } else {
      if (status == "AllFutureDates") {
        time = time.add(Duration(days: 364));
      } else if (status == "Months1") {
        time = time.add(Duration(days: 29));
      } else if (status == "Months3") {
        time = time.add(Duration(days: 89));
      } else if (status == "Months6") {
        time = time.add(Duration(days: 179));
      } else if (status == "Months12") {
        time = time.add(Duration(days: 364));
      } else {
        time = time.add(Duration(days: 364));
      }
    }
    time = time.subtract(
      Duration(
          hours: time.hour,
          minutes: time.minute,
          seconds: time.second,
          milliseconds: time.millisecond,
          microseconds: time.microsecond),
    );
    return time;
  }

  void getCalendarEvents() async {
    try {
      print("calendar events");
      var data = {
        "CalendarID": bookingInfo['calendarID'].toString(),
      };
      final response = await HttpClient.post(viewCalendarEventsUrl, data,
          token: await storage.read(key: 'jwt') as String);

      var status = response["Status"];
      calendarEvents.clear();
      if (status["success"]) {
        var calendar = response["Calendar"];
        List events = calendar["events"];
        for (var eventData in events) {
          var event = eventData["event"];
          print(event);
          List<DateTime> dates = DateUtil.instance.getDaysInBetween(
            DateTime.parse(event["start_datetime"].toString()),
            DateTime.parse(event["end_datetime"].toString()),
          );
          for (DateTime date in dates) {
            calendarEvents.add(DateFormat('yyyy-MM-dd').format(date.toLocal()));
          }
        }
        print("events:::" + calendarEvents.length.toString());
      }
    } catch (e) {
      print(e);
    } finally {
      if (_fromSearch) {
        updateDaySelectionForSearch();
      } else {
        updateDaySelection();
      }
    }
  }

  void handleShowSetLocationModal(context) {
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
        return BookingSetLocation(bookingInfo: bookingInfo);
      },
    );
  }

  void handleShowTripDurationModal(context) {
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
        print("duration:::" +
            bookingInfo['startDate'].toString() +
            ":::" +
            bookingInfo['endDate'].toString());
        return BookingTripDuration(bookingInfo: bookingInfo);
      },
    );
  }

  void handleShowInsuranceModal(context) {
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
        return BookingInsurance(bookingInfo: bookingInfo);
      },
    );
  }

  void handleShowTripBookeddModal(context) {
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
        return TripBooked();
      },
    );
  }

  String getErrorMessage(Map error) {
    var value = (_carDetails['Availability']['RentalAvailability']
            ['SameDayCutOffTime']['hours'])
        .toString();
    var value2 = (num.parse((_carDetails['Availability']['RentalAvailability']
                    ['SameDayCutOffTime']['hours'])
                .toStringAsFixed(2)) >
            11.59
        ? 'PM'
        : 'AM');
    var value3 = ':00';

    switch (error['message']) {
      case 'Atleast 1 day advance notice error':
        return 'Host requires at least 1 day advance notice.';
      case 'Same day cutoff time error':
        return 'This vehicle can not be booked after' +
            ' $value:00' +
            ' $value2 same day.';

      case 'Atleast 3 day advance notice error':
        return 'Host requires at least 3 days advance notice.';
      case 'Atleast 5 day advance notice error':
        return 'Host requires at least 5 days advance notice.';
      case 'Atleast 7 day advance notice error':
        return 'Host requires at least 7 days advance notice.';
      case 'Car is not available during this time':
        return 'This vehicle is unavailable for selected dates. Please select alternate dates.';
      case 'Trip Duration Error':
        return '${error['details'][0]['Message']} Try changing dates.';
      default:
        return error['message'];
    }
  }

  var _bookingData = {
    "_carID": '',
    "_tripStartDate": '',
    "_tripStartTime": '',
    "_tripEndDate": '',
    "_tripEndTime": '',
    "_locationAddress": '',
    "FormattedAddress": '',
    'CustomLoc': false,
    "_locationLat": 0.0,
    "_locationLon": 0.0,
    "_insuranceType": '',
    "_deliveryNeeded": false,
    // "couponCode": '',
    "_userID": '',
    "_calendarID": ''
  };
  bool isVisible = true;

  void _handleRemove() {
    setState(() {
      _bookingData['couponCode'] = '';
      _pricingInfo['CouponApplicable'] = false;
      _pricingInfo['RidealikeCoupon'] = 0;
      _pricingInfo['CouponDiscount'] = 0;
      _pricingInfo['CouponMaxDiscount'] = 0;
      _pricingInfo['Total'] = _pricingInfo['TripPrice'] + _pricingInfo['TripFee'];
    });
  }

  bool _isButtonPressed = false;

  var _pricingInfo;
  var carInfo = {};
  var _carDetails = {};
  var pricingLoaded = false;

  @override
  void initState() {
    super.initState();

    address = bookingInfo['location'];
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Booing Information"});
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      if (bookingInfo["route"] != null &&
          bookingInfo["route"] == "/car_details") {
        _fromSearch = true;
      }

      print("from search:::" + _fromSearch.toString());

      print("date receive:::" + bookingInfo["startDate"]);
      print("date receive:::" + bookingInfo["endDate"]);

      _userID = await storage.read(key: 'user_id');

      _bookingData['_calendarID'] = bookingInfo['calendarID'];
      _bookingData['_carID'] = bookingInfo['carID'];
      _bookingData['_tripStartDate'] = bookingInfo['startDate'];
      _bookingData['_tripEndDate'] = bookingInfo['endDate'];
      _bookingData['_locationAddress'] = bookingInfo['locAddress'];
      _bookingData['FormattedAddress'] = bookingInfo['FormattedAddress'];
      print('bookingData${_bookingData['FormattedAddress']}');
      print('location${bookingInfo['_locationAddress']}');
      print('FormattedAddress${bookingInfo['FormattedAddress']}');

      _bookingData['_locationLat'] = bookingInfo['locLat'];
      _bookingData['_locationLon'] = bookingInfo['locLong'];
      _bookingData['_insuranceType'] = bookingInfo['insuranceType'];
      if (bookingInfo['CustomLoc'] != null) {
        _bookingData['CustomLoc'] = bookingInfo['CustomLoc'];
      }
      // _bookingData['couponCode'] = bookingInfo['couponCode'];
      _bookingData['customDeliveryEnable'] =
          bookingInfo['customDeliveryEnable'];
      _bookingData['_userID'] = _userID as Object;
      if (bookingInfo['deliveryNeeded'] != null) {
        _bookingData['_deliveryNeeded'] = bookingInfo['deliveryNeeded'];
      }

      await getPricing();

      if (bookingInfo['saveData'] == null) {
        getCalendarEvents();
      } else {
        setState(() {
          selectedPeriodStart =
              DateTime.parse(bookingInfo['startDate'].toString()).toLocal();
          selectedPeriodEnd =
              DateTime.parse(bookingInfo['endDate'].toString()).toLocal();
        });
      }

      var response = await fetchCardData(_userID);
      setState(() {
        _cardData = json.decode(response.body!)['CardInfo'][0];
      });
    });
  }

  Widget _couponTextView(Coupon coupon) {
    final textStyle = TextStyle(
      fontSize: 11,
      color: Colors.black,
      fontFamily: 'Urbanist',
    );
    if (coupon.percentageDiscount > 0 &&
        coupon.numberOfDaysDiscount == 0 &&
        coupon.amount == 0) {
      return Text(
        'Minimum \$${coupon.rentalAmountRequired} rental cost \nMinimum ${coupon.rentalDaysRequired} day(s) rental \n${coupon.percentageDiscount}% off up to \$${coupon.maxAmountDiscount}',
        style: textStyle,
      );
    } else if (coupon.percentageDiscount == 0 &&
        coupon.numberOfDaysDiscount > 0 &&
        coupon.amount == 0) {
      return Text(
        'Minimum \$${coupon.rentalAmountRequired} rental cost \nMinimum ${coupon.rentalDaysRequired} day(s) rental \nMaximum Discount \$${coupon.maxAmountDiscount}',
        style: textStyle,
      );
    } else if (coupon.percentageDiscount == 0 &&
        coupon.numberOfDaysDiscount == 0 &&
        coupon.amount > 0) {
      return Text(
        'Minimum \$${coupon.rentalAmountRequired} rental cost \nMinimum ${coupon.rentalDaysRequired} day(s) rental',
        style: textStyle,
      );
    } else {
      return Text("");
    }
  }

  /*'Minimum \$${coupon.rentalAmountRequired} rental cost | Minimum ${coupon.rentalDaysRequired} day(s) rental',
  style:
  TextStyle(
  fontSize:
  11,
  color: Colors
      .black,
  fontFamily:
  'Urbanist',
  ),
  )
      : Text(
  'Minimum \$${coupon.rentalAmountRequired} rental cost | ${coupon.percentageDiscount}% off up to \$${coupon.maxAmountDiscount}',*/

  Future getPricing() async {
    print("*************get pricing*************");
    print(_bookingData['_tripStartDate']);
    print(_bookingData['_tripEndDate']);
    print("*************get pricing*************");
    var res = await fetchPricingInfo(_bookingData);

    setState(() {
      if (res != null && res.statusCode == 200) {
        _pricingInfo = json.decode(res.body!)['Booking']['Pricing'];
        pricingLoaded = true;
      } else {
        if (json.decode(res.body!)['message'] ==
            'could not calcupricing: could not calcupricing: delivery distance limit is 50km') {
          _deliveryErrorText = 'Select location within the limit.';
        } else if (json.decode(res.body!)['message'] == 'Car not found') {
          _deliveryErrorText = 'Vehicle not found';
        } else {
          _deliveryErrorText = json.decode(res.body!)['message'];
        }

        _isButtonPressed = false;
        _deliveryError = true;
        print('customDeli${bookingInfo['customDeliveryEnable']}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    // print(_bookingData);
    return _bookingData['_carID'] != ''
        ? Container(
            alignment: Alignment.bottomLeft,
            color: Color.fromRGBO(64, 64, 64, 1),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height / 2,
                maxHeight: MediaQuery.of(context).size.height - 24,
              ),
              child: Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                // height: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
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
                          Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Text(
                              "Book trip",
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xFF371D32),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              // ModalRoute.withName(bookingInfo["route"]));
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
                    // Booking details
                    Padding(
                      padding:
                          const EdgeInsets.only(right: 16, left: 16, top: 16),
                      child: Text(
                        'BOOKING DETAILS',
                        style: TextStyle(
                            color: Color(0xff371D32).withOpacity(0.5),
                            letterSpacing: 0.2,
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                    Divider(),
                    // Location
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: InkWell(
                          onTap: () => handleShowSetLocationModal(context),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pickup & Return Location',
                                  style: TextStyle(
                                    color: Color(0xff371D32),
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .75,
                                      child: AutoSizeText(
                                        bookingInfo['deliveryNeeded'] == true
                                            ? _bookingData['_locationAddress']
                                                as String
                                            : '${_bookingData['FormattedAddress']}',
                                        style: TextStyle(
                                          color: Color(0xff353B50),
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          .15,
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          width: 16,
                                          child: Icon(
                                              Icons.keyboard_arrow_right,
                                              color: Color(0xff353B50)),
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
                    ),
                    Divider(),
                    // Trip duration
                    Padding(
                      padding: EdgeInsets.only(right: 16, left: 16),
                      child: InkWell(
                        onTap: () => handleShowTripDurationModal(context),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text(
                                'Trip Duration',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(width: 16),
                                (selectedPeriodStart != null &&
                                        selectedPeriodEnd != null)
                                    ? Flexible(
                                        child: Text(
                                          DateFormat('MMM dd').format(
                                                  selectedPeriodStart!
                                                      .toLocal()) +
                                              ' - ' +
                                              DateFormat('MMM dd').format(
                                                  selectedPeriodEnd!.toLocal()),
                                          // child: Text('Sept 21 -22',
                                          style: TextStyle(
                                            color: Color(0xff353B50),
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                SizedBox(width: 8),
                                Container(
                                  width: 16,
                                  child: Icon(Icons.keyboard_arrow_right,
                                      color: Color(0xff353B50)),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                    Divider(),
                    // Insurance
                    Padding(
                      padding: EdgeInsets.only(right: 16, left: 16),
                      child: InkWell(
                        onTap: () => handleShowInsuranceModal(context),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text(
                                'Insurance',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Expanded(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: <Widget>[
                                SizedBox(width: 16),
                                Flexible(
                                  child: Text(
                                    _bookingData['_insuranceType'] == 'Standard'
                                        ? 'Premium'
                                        : 'Standard',
                                    style: TextStyle(
                                      color: Color(0xff353B50),
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Container(
                                  width: 16,
                                  child: Icon(Icons.keyboard_arrow_right,
                                      color: Color(0xff353B50)),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                    ),
                    Divider(),

                    //pricing
                    (!_deliveryError && _pricingInfo != null && pricingLoaded)
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Pricing
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 16, left: 16, top: 24),
                                child: Text(
                                  'PRICING',
                                  style: TextStyle(
                                      color: Color(0xff371D32).withOpacity(0.5),
                                      letterSpacing: 0.2,
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Divider(),
                              // Trip rate
                              Padding(
                                padding: EdgeInsets.only(right: 16, left: 16),
                                child: InkWell(
                                  onTap: () {},
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      //trip rate//
                                      Container(
                                        child: Text(
                                          'Trip Rate',
                                          style: TextStyle(
                                            color: Color(0xff371D32),
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          SizedBox(width: 16),
                                          Flexible(
                                            child: Text(
                                              '${_pricingInfo['TripDurationInString'].toString()}',
                                              style: TextStyle(
                                                color: Color(0xff353B50),
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),

                              /// Trip price
                              Padding(
                                padding: EdgeInsets.only(right: 16, left: 16),
                                child: InkWell(
                                  onTap: () {},
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          'Trip Cost',
                                          style: TextStyle(
                                            color: Color(0xff371D32),
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          SizedBox(width: 16),
                                          Flexible(
                                            child: Text(
                                              (_pricingInfo != null &&
                                                      _pricingInfo[
                                                              'TripPrice'] !=
                                                          null)
                                                  ? '\$${_pricingInfo['TripPrice'].toStringAsFixed(2)}'
                                                  : "",
                                              style: TextStyle(
                                                color: Color(0xff353B50),
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),

                              ///insurance fee//
                              Padding(
                                padding: EdgeInsets.only(right: 16, left: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        'Insurance Fee',
                                        style: TextStyle(
                                          color: Color(0xff371D32),
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        SizedBox(width: 16),
                                        Flexible(
                                          child: Text(
                                            _pricingInfo['InsuranceFee'] != null
                                                ? '\$${_pricingInfo['InsuranceFee'].toStringAsFixed(2)}'
                                                : "",
                                            style: TextStyle(
                                              color: Color(0xff353B50),
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              ),

                              Divider(),

                              /// Trip fee
                              Padding(
                                padding: EdgeInsets.only(right: 16, left: 16),
                                child: InkWell(
                                  onTap: () {},
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Text(
                                          // 'Trip fee',
                                          'Service Fee',
                                          style: TextStyle(
                                            color: Color(0xff371D32),
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          SizedBox(width: 16),
                                          Flexible(
                                            child: Text(
                                              _pricingInfo['TripFee'] != null
                                                  ? '\$${(_pricingInfo['TripFee']).toStringAsFixed(2)}'
                                                  : "",
                                              style: TextStyle(
                                                color: Color(0xff353B50),
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              Divider(),
                              // Delivery fee
                              _pricingInfo['DeliveryFee'] != null &&
                                      _pricingInfo['DeliveryFee'] != '' &&
                                      _pricingInfo['DeliveryFee'] != 0
                                  ? Padding(
                                      padding:
                                          EdgeInsets.only(right: 16, left: 16),
                                      child: InkWell(
                                        onTap: () {},
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            SizedText(
                                              deviceWidth: deviceWidth,
                                              textWidthPercentage: 0.75,
                                              text: _pricingInfo[
                                                              'DeliveryRateInString'] !=
                                                          null &&
                                                      _pricingInfo[
                                                              'DeliveryRateInString'] !=
                                                          ''
                                                  ? 'Delivery Fee (${_pricingInfo['DeliveryRateInString'].toString()})'
                                                  : 'Delivery Fee',
                                              textColor: Color(0xff371D32),
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                            ),
                                            Expanded(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(width: 16),
                                                Flexible(
                                                  child: Text(
                                                    '\$${_pricingInfo['DeliveryFee'].toStringAsFixed(2)}',
                                                    // '${_pricingInfo['DeliveryRateInString'].toString()}',
                                                    style: TextStyle(
                                                      color: Color(0xff353B50),
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              _pricingInfo['DeliveryFee'] != null &&
                                      _pricingInfo['DeliveryFee'] != '' &&
                                      _pricingInfo['DeliveryFee'] != 0
                                  ? Divider()
                                  : Container(),

                              /// Discount
                              _pricingInfo['DiscountPercentage'] != null &&
                                      _pricingInfo['DiscountPercentage'] !=
                                          '' &&
                                      _pricingInfo['DiscountPercentage'] != 0
                                  ? Padding(
                                      padding:
                                          EdgeInsets.only(right: 16, left: 16),
                                      child: InkWell(
                                        onTap: () {},
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                'Host Discount ${_pricingInfo['DiscountPercentage']}% Off',
                                                style: TextStyle(
                                                  color: Color(0xff371D32),
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(width: 16),
                                                Flexible(
                                                  child: Text(
                                                    '\$${_pricingInfo['Discount'].toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      color: Color(0xff353B50),
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              _pricingInfo['DiscountPercentage'] != null &&
                                      _pricingInfo['DiscountPercentage'] !=
                                          '' &&
                                      _pricingInfo['DiscountPercentage'] != 0
                                  ? Divider()
                                  : Container(),

                              ///coupon number//
                              _pricingInfo['RidealikeCoupon'] != null &&
                                      _pricingInfo['RidealikeCoupon'] != '' &&
                                      _pricingInfo['RidealikeCoupon'] != 0
                                  ? Padding(
                                      padding:
                                          EdgeInsets.only(right: 16, left: 16),
                                      child: InkWell(
                                        onTap: () {},
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Text(
                                                // 'Coupon Discount',
                                                'RideAlike Discount',
                                                style: TextStyle(
                                                  color: Color(0xff371D32),
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(width: 16),
                                                Flexible(
                                                  child: Text(
                                                    '\$${_pricingInfo['RidealikeCoupon'].toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      color: Color(0xff353B50),
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                              _pricingInfo['RidealikeCoupon'] != null &&
                                      _pricingInfo['RidealikeCoupon'] != '' &&
                                      _pricingInfo['RidealikeCoupon'] != 0
                                  ? Divider()
                                  : Container(),

                              bookingInfo['mileage'] != null &&
                                      bookingInfo["mileage"]
                                              ['DailyMileageAllowance'] ==
                                          'Limited'
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          top: 4,
                                          right: 16,
                                          left: 16,
                                          bottom: 4),
                                      child: InkWell(
                                        onTap: () {},
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedText(
                                                    deviceWidth:
                                                        SizeConfig.deviceWidth!,
                                                    textWidthPercentage: 0.7,
                                                    text:
                                                        '${bookingInfo["mileage"]['Limit']} Total Kilometers Per Day',
                                                    textColor:
                                                        Color(0xff371D32),
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(width: 16),
                                                Flexible(
                                                  child: Text(
                                                    'Free',
                                                    style: TextStyle(
                                                      color: Color(0xffFF8F68),
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: 8,
                                          right: 16,
                                          left: 16,
                                          bottom: 8),
                                      child: InkWell(
                                        onTap: () {},
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  SizedText(
                                                    deviceWidth:
                                                        SizeConfig.deviceWidth!,
                                                    textWidthPercentage: 0.7,
                                                    text:
                                                        'Unlimited Kilometers Per Day',
                                                    textColor:
                                                        Color(0xff371D32),
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                                child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: <Widget>[
                                                SizedBox(width: 16),
                                                Flexible(
                                                  child: Text(
                                                    'Free',
                                                    style: TextStyle(
                                                      color: Color(0xffFF8F68),
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),
                                    ),
                              bookingInfo['mileage'] != null &&
                                      bookingInfo["mileage"]
                                              ['DailyMileageAllowance'] ==
                                          'Limited'
                                  ? Divider()
                                  : Divider(),

                              ///Total
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8, right: 16, left: 16, bottom: 8),
                                child: InkWell(
                                  onTap: () {},
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'Total',
                                              style: TextStyle(
                                                color: Color(0xff371D32),
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                              ),
                                            ),
                                            _cardData != null
                                                ? Text(
                                                    'Will be charged to ${_cardData['LastFourDigits']}',
                                                    style: TextStyle(
                                                      color: Color(0xff353B50),
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 12,
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                          child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: <Widget>[
                                          SizedBox(width: 16),
                                          Flexible(
                                            child: Text(
                                              '\$${_pricingInfo['Total'].toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: Color(0xff353B50),
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    top: 8, right: 16, left: 16, bottom: 8),
                                child: InkWell(
                                  onTap: () {},
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            _pricingInfo['TripRate'] != null
                                                ? Text(
                                                    'A ${(_pricingInfo['TripRate'] >= 100) ? '\$1000' : '\$500'} Security Deposit will be charged to \nyour payment card and automatically reversed \n48 hours after your trip has ended.',
                                                    style: TextStyle(
                                                      color: Color(0xff371D32),
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Divider(),
                            ],
                          )
                        : Container(),
                    _deliveryError
                        ? SizedBox(
                            height: 10,
                          )
                        : Container(),

                    //Coupon code//
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Text(
                                      'Available coupons',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 18,
                                        color: Color(0xFF353B50),
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Icon(Icons.close,
                                            color: Color(0xFF353B50))),
                                    // onPressed: () {
                                    //   Navigator.of(context).pop();
                                    // },
                                  ),
                                ],
                              ),
                              content: SingleChildScrollView(
                                child: IntrinsicHeight(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        height: 10,
                                      ),
                                      FutureBuilder<ApiResponse>(
                                        future: fetchCoupons(
                                            _bookingData['_carID'] as String,
                                            _userID as String),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Center(
                                                child:
                                                    CircularProgressIndicator());
                                          } else if (snapshot.hasError) {
                                            return Center(child: Text(''));
                                          } else if (!snapshot.hasData ||
                                              snapshot.data!.coupons.isEmpty) {
                                            return Center(
                                              child: Text(
                                                'No Coupons Found',
                                                style: TextStyle(
                                                  color: Color(0xff353B50),
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisSize: MainAxisSize.min,
                                              children: snapshot.data!.coupons
                                                  .map((coupon) {
                                                debugPrint(coupon.toString());
                                                return Container(
                                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                                  margin: EdgeInsets.only(bottom: 10),
                                                  decoration: BoxDecoration(
                                                      image: DecorationImage(image: AssetImage('images/Subtract.png'), fit: BoxFit.fill)
                                                  ),
                                                  child:    Column(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      //SvgPicture.asset('svg/Subtract.svg'),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Text(
                                                            coupon
                                                                .couponCode,
                                                            style:
                                                            TextStyle(
                                                              fontSize:
                                                              14,
                                                              color: Colors
                                                                  .black,
                                                              fontFamily:
                                                              'Urbanist',
                                                            ),
                                                          ),
                                                          Text(
                                                            coupon.numberOfDaysDiscount >
                                                                0
                                                                ? '${coupon.numberOfDaysDiscount} days OFF'
                                                                : (coupon.percentageDiscount ==
                                                                0
                                                                ? '\$${coupon.amount} OFF'
                                                                : '${coupon.percentageDiscount}% OFF'),
                                                            style:
                                                            TextStyle(
                                                              color: Color(
                                                                  0xff353B50),
                                                              fontFamily:
                                                              'Urbanist',
                                                              fontSize:
                                                              14,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 5),
                                                      _couponTextView(
                                                          coupon),
                                                      SizedBox(height: 10),
                                                      Row(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Container(
                                                            height: 20,
                                                            width: 130,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                10),
                                                            decoration:
                                                            BoxDecoration(
                                                              color: Color(
                                                                  0xffFF8F68),
                                                              shape: BoxShape
                                                                  .rectangle,
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  20),
                                                            ),
                                                            alignment:
                                                            Alignment
                                                                .center,
                                                            child: Text(
                                                              'Use by ${coupon.validTill}',
                                                              style:
                                                              TextStyle(
                                                                fontFamily:
                                                                'Urbanist',
                                                                fontSize:
                                                                11,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          InkWell(
                                                            onTap:
                                                                () async {
                                                              var couponNumber =
                                                                  coupon
                                                                      .couponCode;
                                                              _bookingData[
                                                              '_carID'] =
                                                              bookingInfo[
                                                              'carID'];
                                                              _bookingData[
                                                              '_locationAddress'] =
                                                              bookingInfo[
                                                              'locAddress'];
                                                              _bookingData[
                                                              'FormattedAddress'] =
                                                              bookingInfo[
                                                              'FormattedAddress'];
                                                              _bookingData[
                                                              '_locationLat'] =
                                                              bookingInfo[
                                                              'locLat'];
                                                              _bookingData[
                                                              '_locationLon'] =
                                                              bookingInfo[
                                                              'locLong'];
                                                              _bookingData[
                                                              '_insuranceType'] =
                                                              bookingInfo[
                                                              'insuranceType'];
                                                              _bookingData[
                                                              'couponCode'] =
                                                                  couponNumber;
                                                              _bookingData[
                                                              '_userID'] =
                                                              _userID!;
                                                              var res =
                                                              await fetchPricingInfo(
                                                                  _bookingData);
                                                              if (res !=
                                                                  null) {
                                                                var responseCoupon =
                                                                json.decode(
                                                                    res.body!);
                                                                print(
                                                                    'response$responseCoupon');
                                                              }
                                                              setState(() {
                                                                _pricingInfo =
                                                                json.decode(res.body!)['Booking']
                                                                [
                                                                'Pricing'];
                                                                if (_pricingInfo['CouponApplicable'] !=
                                                                    null &&
                                                                    _pricingInfo[
                                                                    'CouponApplicable']) {
                                                                  bookingInfo[
                                                                  'couponCode'] =
                                                                      couponNumber;
                                                                } else {
                                                                  bookingInfo[
                                                                  'couponCode'] = '';
                                                                }
                                                              });
                                                              Navigator.of(
                                                                  context)
                                                                  .pop();
                                                            },
                                                            child:
                                                            Container(
                                                              height: 20,
                                                              width: 80,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                  10),
                                                              decoration:
                                                              BoxDecoration(
                                                                shape: BoxShape
                                                                    .rectangle,
                                                                borderRadius:
                                                                BorderRadius.circular(
                                                                    20),
                                                              ),
                                                              alignment:
                                                              Alignment
                                                                  .center,
                                                              child: Text(
                                                                'Apply',
                                                                style:
                                                                TextStyle(
                                                                  fontFamily:
                                                                  'Urbanist',
                                                                  fontSize:
                                                                  14,
                                                                  color: Color(
                                                                      0xffFF8F68),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            );
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          children: [
                            Image.asset('images/Vector.png'),
                            Padding(
                              padding: const EdgeInsets.only(left: 16.0),
                              child: Text(
                                'Apply Coupon',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Divider(),
                    _bookingData['couponCode'] == null ||
                            _bookingData['couponCode'] == '' ||
                            _pricingInfo['CouponApplicable'] == null
                        ? Container()
                        : _pricingInfo['CouponApplicable'] == true
                            ? Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16),
                                    child: SvgPicture.asset(
                                      'svg/Subtract.svg',
                                      width: MediaQuery.of(context).size.width,
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 12, right: 12),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                children: [
                                                  Image.asset(
                                                      'images/Vector.png'),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _bookingData[
                                                                      'couponCode']
                                                                  as String ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFF353B50),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'Urbanist',
                                                          ),
                                                        ),
                                                        _pricingInfo['RidealikeCoupon'] !=
                                                                    null &&
                                                                _pricingInfo[
                                                                        'RidealikeCoupon'] !=
                                                                    '' &&
                                                                _pricingInfo[
                                                                        'RidealikeCoupon'] !=
                                                                    0
                                                            ? Text(
                                                                '\$${_pricingInfo['RidealikeCoupon'].toStringAsFixed(
                                                                    2)}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xffFF8F68),
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              )
                                                            : Container(),
                                                      ]),
                                                ],
                                              ),
                                              Text(
                                                '${_pricingInfo['CouponDiscount']}% off up to \$${_pricingInfo['CouponMaxDiscount']}',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 50.0, right: 50),
                                          child: Divider(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                SvgPicture.asset(
                                                  'svg/Mask group.svg',
                                                ),
                                                SizedBox(width: 5),
                                                Text(
                                                  'Voucher Applied!',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 15,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  bookingInfo['couponCode'] =
                                                      '';
                                                });
                                                _handleRemove();
                                              },
                                              child: Container(
                                                height: 20,
                                                width: 80,
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.rectangle,
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  'Remove',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 15,
                                                    color: Color(0xffFF8F68),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Visibility(
                                visible: isVisible,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0, right: 16),
                                      child: SvgPicture.asset(
                                        'svg/Subtract.svg',
                                        width:
                                            MediaQuery.of(context).size.width,
                                      ),
                                    ),
                                    Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 12, right: 12),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                        'images/Vector.png'),
                                                    SizedBox(
                                                      width: 8,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          _bookingData[
                                                                      'couponCode']
                                                                  as String ??
                                                              '',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xFF353B50),
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontFamily:
                                                                'Urbanist',
                                                          ),
                                                        ),
                                                        _pricingInfo['RidealikeCoupon'] !=
                                                                    null &&
                                                                _pricingInfo[
                                                                        'RidealikeCoupon'] !=
                                                                    '' &&
                                                                _pricingInfo[
                                                                        'RidealikeCoupon'] !=
                                                                    0
                                                            ? Text(
                                                                '\$${_pricingInfo['RidealikeCoupon']}',
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xffFF8F68),
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontSize: 16,
                                                                ),
                                                              )
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                _pricingInfo['RidealikeCoupon'] !=
                                                            null &&
                                                        _pricingInfo[
                                                                'RidealikeCoupon'] !=
                                                            '' &&
                                                        _pricingInfo[
                                                                'RidealikeCoupon'] !=
                                                            0
                                                    ? Text(
                                                        '\$${_pricingInfo['RidealikeCoupon']}',
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff353B50),
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 16,
                                                        ),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 50.0, right: 50),
                                            child: Divider(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    'svg/Group 17.svg',
                                                    width: 18,
                                                    height: 18,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    'Can’t apply this coupon',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 15,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              InkWell(
                                                onTap: () {
                                                  _handleRemove();
                                                },
                                                child: Container(
                                                  height: 20,
                                                  width: 80,
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10),
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    'Remove',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 15,
                                                      color: Color(0xffFF8F68),
                                                    ),
                                                  ),
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

                    // Container(
                    //   child: Container(
                    //     child: Container(
                    //       child: Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Divider(),
                    //           SizedBox(
                    //             height: 10,
                    //           ),
                    //           GestureDetector(
                    //             onTap: (){
                    //               // Navigator.push(context, MaterialPageRoute(builder: (context)=>CouponPage()));
                    //             },
                    //             child: Padding(
                    //               padding: const EdgeInsets.only(left: 16.0),
                    //               child: Row(
                    //                 children: [
                    //                   Image.asset('images/Vector.png'),
                    //                   Padding(
                    //                     padding: const EdgeInsets.only(left: 16.0),
                    //                     child: Text('Apply RideAlike coupon',
                    //                         style: TextStyle(
                    //                             color: Color(0xff371D32),
                    //                             fontFamily: 'Urbanist',
                    //                             fontSize: 16,
                    //                             fontWeight: FontWeight.w600
                    //                         )),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ),
                    //
                    //           SizedBox(
                    //             height: 10,
                    //           ),
                    //           // Divider(),
                    //           Padding(
                    //             padding:
                    //             const EdgeInsets.only(left: 16, right: 16),
                    //             child: Row(
                    //               children: [
                    //                 Expanded(
                    //                   flex: 7,
                    //                   child: Column(
                    //                     children: [
                    //                       SizedBox(
                    //                         width: double.maxFinite,
                    //                         child: Container(
                    //                           decoration: BoxDecoration(
                    //                               color: Color(0xFFF2F2F2),
                    //                               borderRadius:
                    //                               BorderRadius.circular(
                    //                                   8.0)),
                    //                           child: TextFormField(
                    //                             onChanged: (_) {},
                    //                             controller:
                    //                             _couponTextController,
                    //                             validator: (value) {
                    //                               if (value!.isEmpty) {
                    //                                 return 'Coupon code is required';
                    //                               }
                    //                               return null;
                    //                             },
                    //
                    //                             maxLength: 15,
                    //                             textInputAction:
                    //                             TextInputAction.done,
                    //                             decoration: InputDecoration(
                    //                                 contentPadding:
                    //                                 EdgeInsets.all(18.0),
                    //                                 border: InputBorder.none,
                    //                                 labelText: 'Coupon code',
                    //                                 labelStyle: TextStyle(
                    //                                   fontFamily: 'Urbanist',
                    //                                   fontSize: 12,
                    //                                   color: Color(0xFF353B50),
                    //                                 ),
                    //                                 hintText:
                    //                                 'Enter coupon code',
                    //                                 hintStyle: TextStyle(
                    //                                   fontFamily: 'Urbanist',
                    //                                   fontSize: 14, // Adjust the font size as needed
                    //                                   color: Colors.grey, // You can customize the color as well
                    //                                 ),
                    //                                 counterText: ""),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //                 SizedBox(width: 10),
                    //                 Expanded(
                    //                   flex: 3,
                    //                   child: Column(
                    //                     children: [
                    //                       SizedBox(
                    //                         width: double.maxFinite,
                    //                         // height: 70.0,
                    //                         child: Container(
                    //                           decoration: BoxDecoration(
                    //                               color: Color(0xFFF2F2F2),
                    //                               borderRadius:
                    //                               BorderRadius.circular(
                    //                                   8.0)),
                    //                           child: ElevatedButton(style: ElevatedButton.styleFrom(
                    //                             elevation: 0.0,
                    //                             backgroundColor: Colors.white,
                    //                             // textColor: Color(0xffFF8F68),
                    //                             padding: EdgeInsets.all(16.0),
                    //                             shape: RoundedRectangleBorder(
                    //                                 borderRadius:
                    //                                 BorderRadius.circular(
                    //                                     8.0)),),
                    //                             onPressed: () async {
                    //                               var couponNumber =
                    //                                   _couponTextController
                    //                                       .text;
                    //                               _bookingData['_carID'] =
                    //                               bookingInfo['carID'];
                    //                               /*   _bookingData[
                    //                                       '_tripStartDate'] =
                    //                                   bookingInfo['startDate'];
                    //                               _bookingData['_tripEndDate'] =
                    //                                   bookingInfo['endDate'];*/
                    //                               _bookingData[
                    //                               '_locationAddress'] =
                    //                               bookingInfo['locAddress'];
                    //                               _bookingData[
                    //                               'FormattedAddress'] =
                    //                               bookingInfo[
                    //                               'FormattedAddress'];
                    //                               _bookingData['_locationLat'] =
                    //                               bookingInfo['locLat'];
                    //                               _bookingData['_locationLon'] =
                    //                               bookingInfo['locLong'];
                    //                               _bookingData[
                    //                               '_insuranceType'] =
                    //                               bookingInfo[
                    //                               'insuranceType'];
                    //                               _bookingData['couponCode'] =
                    //                                   couponNumber;
                    //                               _bookingData['_userID'] =
                    //                               _userID!;
                    //                               var res =
                    //                               await fetchPricingInfo(
                    //                                   _bookingData);
                    //                               if (res != null &&
                    //                                   res.statusCode == 200) {
                    //                                 var responseCoupon =
                    //                                 json.decode(res.body!);
                    //                                 print(
                    //                                     'response$responseCoupon');
                    //                               }
                    //                               setState(() {
                    //                                 _pricingInfo = json.decode(
                    //                                     res.body!)['Booking']
                    //                                 ['Pricing'];
                    //                                 if (_pricingInfo[
                    //                                 'CouponApplicable'] !=
                    //                                     null &&
                    //                                     _pricingInfo[
                    //                                     'CouponApplicable']) {
                    //                                   bookingInfo[
                    //                                   'couponCode'] =
                    //                                       couponNumber;
                    //                                 } else {
                    //                                   bookingInfo[
                    //                                   'couponCode'] = Text("");
                    //                                 }
                    //                               });
                    //                             },
                    //                             child: AutoSizeText(
                    //                               'Apply',
                    //                               maxLines: 1,
                    //                               style: TextStyle(
                    //                                   fontFamily:
                    //                                   'Urbanist',
                    //                                   fontSize: 18,
                    //                                   color: Color(0xffFF8F68)),
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ],
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    // Divider(),
                    // _bookingData['couponCode'] == null ||
                    //     _bookingData['couponCode'] == '' ||
                    //     _pricingInfo['CouponApplicable'] == null
                    //     ? Container()
                    //     : _pricingInfo['CouponApplicable'] == true
                    //     ? Align(
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 10),
                    //     child: Text(
                    //       'Coupon code applied successfully.',
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         fontFamily: 'Urbanist',
                    //         fontSize: 14,
                    //         color: Color(0xFF5CAEAC),
                    //       ),
                    //     ),
                    //   ),
                    //   alignment: Alignment.center,
                    // )
                    // //     : _pricingInfo['Total'] > 1000
                    // //     ? Align(
                    // //   child: Padding(
                    // //     padding: const EdgeInsets.only(left: 10),
                    // //     child: Text(
                    // //       'Coupon code applied successfully for orders over 10,000.',
                    // //       textAlign: TextAlign.center,
                    // //       style: TextStyle(
                    // //         fontFamily: 'Urbanist',
                    // //         fontSize: 14,
                    // //         color: Color(0xFF5CAEAC),
                    // //       ),
                    // //     ),
                    // //   ),
                    // //   alignment: Alignment.center,
                    // // )
                    //     : Align(
                    //   child: Padding(
                    //     padding: const EdgeInsets.only(left: 18),
                    //     child: Text(
                    //       'Sorry, Coupon code is not valid.',
                    //       textAlign: TextAlign.center,
                    //       style: TextStyle(
                    //         fontFamily: 'Urbanist',
                    //         fontSize: 14,
                    //         color: Color(0xFFF55A51),
                    //       ),
                    //     ),
                    //   ),
                    //   alignment: Alignment.centerLeft,
                    // ),

                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4, left: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedText(
                            deviceWidth: deviceWidth,
                            textWidthPercentage: 0.86,
                            textAlign: TextAlign.center,
                            text: _pricingInfo != null &&
                                    _pricingInfo['FreeCancelBeforeDateTime'] !=
                                        null &&
                                    DateUtil.instance
                                        .getFreeCancelDateTime(_pricingInfo[
                                            'FreeCancelBeforeDateTime'])
                                        .isAfter(DateTime.now())
                                ? 'Free cancellation before ${DateUtil.instance.formatFreeCancelDateTime(_pricingInfo['FreeCancelBeforeDateTime'])}'
                                : 'You are no longer within the free cancellation period.',
                            textColor: Color(0xFF353B50),
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    _hasError ? SizedBox(height: 10) : new Container(),
                    _hasError
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              _error,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xFFF55A51),
                              ),
                            ),
                          )
                        : new Container(),

                    //delivery error
                    !_deliveryError
                        ? Container()
                        : Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(
                                _deliveryErrorText,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                              ),
                            ),
                          ),
                    _deliveryError
                        ? SizedBox(
                            height: 10,
                          )
                        : Container(),

                    // Next button
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
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
                                    onPressed: _isButtonPressed
                                        ? null
                                        : () async {
                                            setState(() {
                                              _isButtonPressed = true;
                                              _hasError = false;
                                            });

                                            String? userID = await storage.read(
                                                key: 'user_id');

                                            String? _start =
                                                _bookingData['_tripStartDate']
                                                    as String?;
                                            String? _end =
                                                _bookingData['_tripEndDate']
                                                    as String?;

                                            _bookingData['_tripStartDate'] =
                                                DateUtil.instance
                                                    .formatBookDate(_start!);

                                            _bookingData['_tripEndDate'] =
                                                DateUtil.instance
                                                    .formatBookDate(_end!);

                                            if (userID != null) {
                                              var res = await initBooking(
                                                  _bookingData, userID);
                                              print(json.decode(res.body!));

                                              var carRes = await fetchCarData(
                                                  _bookingData['_carID']);

                                              _carDetails = json
                                                  .decode(carRes.body!)['Car'];

                                              if (res.statusCode == 200) {
                                                //TODO
                                                AppEventsUtils.logEvent(
                                                    "booking_successful",
                                                    params: {
                                                      "startDate": _bookingData[
                                                          '_tripStartDate'],
                                                      "endDate": _bookingData[
                                                          '_tripEndDate'],
                                                      "location": _bookingData[
                                                          '_locationAddress'],
                                                      "car_id": _bookingData[
                                                          '_carID'],
                                                      "coupon": _bookingData[
                                                          'couponCode'],
                                                      "car_name": _carDetails[
                                                              'About']['Make'] +
                                                          ' ' +
                                                          _carDetails['About']
                                                              ['Model'],
                                                      "car_rating":
                                                          _carDetails['Rating']
                                                              .toStringAsFixed(
                                                                  1),
                                                      "car_trips": _carDetails[
                                                          'NumberOfTrips'],
                                                    });
                                                Navigator.pushNamed(
                                                    context, '/trip_booked');
                                              } else {
                                                setState(() {
                                                  _error = getErrorMessage(
                                                      json.decode(res.body!));
                                                  _isButtonPressed = false;
                                                  _hasError = true;
                                                });
                                              }
                                            }
                                          },
                                    child: _isButtonPressed
                                        ? SizedBox(
                                            height: 18.0,
                                            width: 18.0,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2.5),
                                          )
                                        : Text(
                                            'Confirm trip',
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
          );
  }
}

Future<RestApi.Resp> initBooking(param, userID) async {
  if (param['_deliveryNeeded']) {
    address = param['_locationAddress'];
  }
  // formattedAddress = param['FormattedAddress'];

  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    initBookingUrl,
    json.encode({
      "BookingParams": {
        "CarID": param['_carID'],
        "StartDateTime": param['_tripStartDate'],
        "EndDateTime": param['_tripEndDate'],
        "PickupReturnLocation": {
          "Address": address,
          "FormattedAddress": param['FormattedAddress'],
          "LatLng": {
            "Latitude": param['_locationLat'],
            "Longitude": param['_locationLon']
          },
          "CustomLoc": param['CustomLoc'],
        },
        "MasterReturnLocation": {
          "Address": address,
          "FormattedAddress": param['FormattedAddress'],
          "LatLng": {
            "Latitude": param['_locationLat'],
            "Longitude": param['_locationLon']
          },
          "CustomLoc": param['CustomLoc'],
        },
        "InsuranceType": param['_insuranceType'],
        "DeliveryNeeded": param['_deliveryNeeded'],
        "CouponCode": param['couponCode'],
        "UserID": userID,
        "GuestUserID": "",
        "HostUserID": ""
      }
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
