import 'dart:async';
import 'dart:convert' show Utf8Decoder, json;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/models/swap_calendar_events_response.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/utils/dateutils.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/pages/messages/utils/stringutils.dart';
import 'package:ridealike/widgets/sized_text.dart';

Future<RestApi.Resp> getSwapArgeementTerms(_swapAgreementID, _userID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getSwapArgeementTermsUrl,
    json.encode({"SwapAgreementID": _swapAgreementID, "UserID": _userID}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

class AgreeWithSwapTerms extends StatefulWidget {
  @override
  _AgreeWithSwapTermsState createState() => _AgreeWithSwapTermsState();
}

class _AgreeWithSwapTermsState extends State<AgreeWithSwapTerms> {
  Map _swapAgreementTerms = {};
  String _error = '';
  bool _hasError = false;
  bool _isButtonPressed2 = false;
  final storage = new FlutterSecureStorage();
  final oCcy = NumberFormat("#,##0.00", "en_US");

  double receivable = 0.0;
  double payable = 0.0;
  double income = 0.0;
  double insurance = 0.0;
  double fee = 0.0;
  double discountPer = 0.0;
  double discountAmount = 0.0;
  double discountProvided = 0.0;
  double total = 0.0;

  String startTime = "";
  String endTime = "";

  String address = "";
  String formattedAddress = "";
  double lat = 0.0;
  double lon = 0.0;

  String theirCarId = "";
  String userID = "";
  String insuranceType = "";
  String payableString = "";
  String receivableString = "";

  bool enableSubmit = true;
  bool enableSuggest = true;

  String _carName = "";
  String myCarName = "";
  int limit = 0;
  var freeKilometer;
  String fuel = "";
  var extraKilometerOverLimit;
  bool petAllowed = false;
  bool smokingAllowed = false;

  String _myCalendarId = "";
  String _theirCalendarId = "";
  List<String> _calendarEvents = [];

  DateTime? selectedPeriodStart;
  DateTime? selectedPeriodEnd;

  bool _locationChanged = false;
  bool _startTimeChanged = false;
  bool _endTimeChanged = false;

  Future<void> getCalendarEvents(bool dayCheck) async {
    try {
      var data = {
        "CalendarAID": _myCalendarId,
        "CalendarBID": _theirCalendarId
      };
      print(data);
      final response = await HttpClient.post(getSwapCalendarEventsUrl, data,
          token: await storage.read(key: 'jwt') as String);

      SwapCalendarEventsResponse res =
      SwapCalendarEventsResponse.fromJson(response);

      List<CalendarEvent> calendarData = [];

      if (res.status!.success!) {
        print(res.calendarA!.events!.length.toString());
        print(res.calendarB!.events!.length.toString());
        for (CalendarEvents calA in res.calendarA!.events!) {
          if (calA.event!.creator == "system") {
            calendarData.add(calA.event!);
          }
        }
        for (CalendarEvents calB in res.calendarB!.events!) {
          if (calB.event!.creator == "system") {
            calendarData.add(calB.event!);
          }
        }
        print(calendarData.length.toString());
        for (CalendarEvent cal in calendarData) {
          List<DateTime> dates = DateUtil.instance.getDaysInBetween(
            DateTime.parse(cal.startDatetime!),
            DateTime.parse(cal.endDatetime!),
          );
          for (DateTime date in dates) {
            String eventDate = DateFormat('yyyy-MM-dd').format(date.toLocal());
            if (!_calendarEvents.contains(eventDate)) {
              _calendarEvents.add(eventDate);
            }
          }
        }
        print(_calendarEvents.toString());
        //_calendarEvents.add("2021-08-16");
        //_calendarEvents.add("2021-08-17");
        bool valid = _isValidRange(
            DateTime.parse(_swapAgreementTerms['StartDateTime']).toLocal(),
            DateTime.parse(_swapAgreementTerms['EndDateTime']).toLocal());
        print(valid);
        if (dayCheck && !valid) {
          updateDaySelection();
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void updateDaySelection() {
    DateTime start;
    DateTime end;
    start = DateTime.now().add(Duration(hours: 2));
    DateTime tempStart = start.subtract(Duration(
      minutes: start.minute,
      seconds: start.second,
      milliseconds: start.millisecond,
      microseconds: start.microsecond,
    ));
    start = tempStart;
    end = start;

    while (start.isBefore(DateTime.now().add(Duration(days: 350)))) {
      print("start:::$start");
      if (!_calendarEvents.contains(DateFormat('yyyy-MM-dd').format(start))) {
        print("start:::current:::$start");
        if (!_calendarEvents.contains(
            DateFormat('yyyy-MM-dd').format(start.add(Duration(days: 1))))) {
          print("start:::next1:::$start");
          if (!(start.month == DateTime.now().month &&
              start.day == DateTime.now().day &&
              (start.toLocal().hour + 2) > 23)) {
            selectedPeriodStart = start;
            break;
          }
        } else {
          print("start:::next2:::$start");
          if (!(start.month == DateTime.now().month &&
              start.day == DateTime.now().day &&
              (start.toLocal().hour + 2) > 19) &&
              selectedPeriodStart != null) {
            selectedPeriodStart = start;
            break;
          }
        }
      }
      //
      start = start.add(Duration(days: 1));
      print("start:::$start:::done");
    }
    end = selectedPeriodStart!;
    for (int i = 0; i < 5; i++) {
      if (!_calendarEvents.contains(DateFormat('yyyy-MM-dd').format(end))) {
        selectedPeriodEnd = end;
      } else {
        break;
      }
      end = end.add(Duration(days: 1));
    }

    if (selectedPeriodStart!.day != DateTime.now().day) {
      DateTime tempSelectedPeriodStart = selectedPeriodStart
          !.subtract(Duration(hours: selectedPeriodStart!.hour));
      DateTime tempSelectedPeriodEnd =
      selectedPeriodEnd!.subtract(Duration(hours: selectedPeriodEnd!.hour));
      selectedPeriodStart = tempSelectedPeriodStart;
      selectedPeriodEnd = tempSelectedPeriodEnd;
    }

    print("start:::$selectedPeriodStart");
    print("end:::$selectedPeriodEnd");
    _swapAgreementTerms['StartDateTime'] =
        selectedPeriodStart!.toUtc().toIso8601String();
    _swapAgreementTerms['EndDateTime'] = selectedPeriodEnd!.toUtc().toIso8601String();
    print("start1:::${_swapAgreementTerms['StartDateTime']}");
    print("end1:::${_swapAgreementTerms['EndDateTime']}");
    setState(() {
      startTime =
          DateFormat('MMM dd, hh:00 a').format(selectedPeriodStart!.toLocal());
      endTime =
          DateFormat('MMM dd, hh:00 a').format(selectedPeriodEnd!.toLocal());
    });

  }

  Future<RestApi.Resp> fetchPricingInfo(param) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      calcSwapArgeementTermsPricingUrl,
      json.encode({
        "SwapAgreementID": param['SwapAgreementID'],
        "StartDateTime": param['StartDateTime'],
        "EndDateTime": param['EndDateTime'],
        "Location": {
          "Address": param['Location']['Address'],
          "FormattedAddress": param['Location']['Address'],
          "LatLng": {
            "Latitude": param['Location']['LatLng']['Latitude'],
            "Longitude": param['Location']['LatLng']['Longitude']
          }
        },
        "InsuranceType": param['InsuranceType'],
        "UserID": userID
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  void updatePricing(bool checkDay) async {
    var res = await fetchPricingInfo(_swapAgreementTerms);
    if (res != null && res.statusCode == 200) {
      _swapAgreementTerms = json.decode(res.body!)['SwapAgreementTerms'];
      setSwapData(checkDay);
    }
  }

  void setSwapData(bool checkDay) {
    setState(() {
      if (_swapAgreementTerms["PreviousTerm"] != null && checkDay) {
        var changes = _swapAgreementTerms["PreviousTerm"]["Changes"];
        print(changes);
        _startTimeChanged = changes["StartDateTime"];
        _endTimeChanged = changes["EndDateTime"];
        _locationChanged = changes["Location"];
      }
      var _carData = _swapAgreementTerms["TheirCar"];
      _myCalendarId = _swapAgreementTerms["MyCar"]["CalendarID"];
      _theirCalendarId =
      _swapAgreementTerms["TheirCar"]["CalendarID"];
      theirCarId = _carData["ID"];
      var carAInsurance = _swapAgreementTerms["CarAInsurance"];
      var carBInsurance = _swapAgreementTerms["CarBInsurance"];
      var carAPricing = _swapAgreementTerms["PricingForCarAOwner"];
      var carBPricing = _swapAgreementTerms["PricingForCarBOwner"];
      if (theirCarId == carAInsurance["carID"]) {
        receivableString = carBPricing["RecievableInString"].toString();
        payableString = carBPricing["PayableInString"].toString();
        receivable = double.parse(carBPricing["Recievable"].toString());
        payable = double.parse(carBPricing["Payable"].toString());
        income = double.parse(carBPricing["income"].toString());
        insurance = double.parse(carBPricing["insuranceFee"].toString());
        fee = double.parse(carBPricing["RidealikeFee"].toString());
        discountPer = double.parse(carBPricing["DiscountPercentage"].toString());
        discountAmount = double.parse(carBPricing["Discount"].toString());
        discountProvided = double.parse(carBPricing["ProvidedDiscount"].toString());
        total = double.parse(carBPricing["Total"].toString());
        insuranceType = carBInsurance["InsuranceType"];
        _swapAgreementTerms["InsuranceType"] = insuranceType;
      } else if (theirCarId == carBInsurance["carID"]) {
        receivableString = carAPricing["RecievableInString"].toString();
        payableString = carAPricing["PayableInString"].toString();
        receivable = double.parse(carAPricing["Recievable"].toString());
        payable = double.parse(carAPricing["Payable"].toString());
        income = double.parse(carAPricing["income"].toString());
        insurance = double.parse(carAPricing["insuranceFee"].toString());
        fee = double.parse(carAPricing["RidealikeFee"].toString());
        discountPer = double.parse(carAPricing["DiscountPercentage"].toString());
        discountAmount = double.parse(carAPricing["Discount"].toString());
        discountProvided = double.parse(carAPricing["ProvidedDiscount"].toString());
        total = double.parse(carAPricing["Total"].toString());
        insuranceType = carAInsurance["InsuranceType"];
        _swapAgreementTerms["InsuranceType"] = insuranceType;
      }
      startTime = DateFormat('MMM dd, hh:00 a').format(
          DateTime.parse(_swapAgreementTerms['StartDateTime']).toLocal());
      endTime = DateFormat('MMM dd, hh:00 a').format(DateTime.parse(_swapAgreementTerms['EndDateTime']).toLocal());
      address = _swapAgreementTerms['Location']['Address'];
      formattedAddress= _swapAgreementTerms['Location']['Address'];

      DateTime givenTime = DateTime.parse(_swapAgreementTerms['StartDateTime']).toLocal();

      if (!DateUtil.instance.isValidTime(givenTime)) {
        enableSuggest = false;
        enableSubmit = false;
        _error = "Please change your trip duration to continue.";
      }

      var _carAbout = _carData["About"];
      var _pref = _carData["Preference"];
      var carPricing = _carData['Pricing'];
      var _feat = _carData["Features"];

      freeKilometer = _pref["DailyMileageAllowance"];
      smokingAllowed = _pref["IsSmokingAllowed"];
      petAllowed = _pref["IsSuitableForPets"];
      limit = _pref["Limit"];

      if (carPricing['RentalPricing']['PerExtraKMOverLimit'] != null) {
        extraKilometerOverLimit = carPricing['RentalPricing']['PerExtraKMOverLimit'];
      }

      fuel = _feat["FuelType"];
      _carName = _carAbout["Make"] + " " + _carAbout["Model"];

      myCarName = _swapAgreementTerms["MyCarTitle"];

      bool isNumber = StringUtils.isNumeric(myCarName.substring(0, 3));
      if (isNumber) {
        myCarName = myCarName.substring(5);
      }
    });
    if(checkDay){
      getCalendarEvents(true);
    }
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      userID = (await storage.read(key: 'user_id'))!;
      dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

      var res = await getSwapArgeementTerms(
          receivedData['SwapAgreementID'], receivedData['UserID']);

      _swapAgreementTerms = json.decode(res.body!)['SwapAgreementTerms'];
      setSwapData(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: _swapAgreementTerms.isNotEmpty
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
                  ),
                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    shrinkWrap: true,
                    children: [
                      // Header
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, bottom: 16),
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: Text(
                                "Agree with swap terms",
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
                      ///Pick and return
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 16, left: 16, top: 16),
                        child: Text(
                          'PICKUP AND RETURN',
                          style: TextStyle(
                              color: Color(0xff371D32).withOpacity(0.5),
                              letterSpacing: 0.2,
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      Divider(),
                      ///Duration
                      /*Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: InkWell(
                          onTap: () {
                            _swapAgreementTerms["events"] = _calendarEvents;
                            _swapAgreementTerms["_startDateTime"] =
                                _swapAgreementTerms['StartDateTime'];
                            _swapAgreementTerms["_endDateTime"] =
                                _swapAgreementTerms['EndDateTime'];
                            _swapAgreementTerms["route"] =
                                "/agree_with_swap_terms";
                            Navigator.pushNamed(context, '/swap_duration',
                                    arguments: _swapAgreementTerms)
                                .then((v) {
                              if (v != null) {
                                Map value = v;
                                if (value["StartDateTime"] != null &&
                                    value["EndDateTime"] != null) {
                                  print(value["StartDateTime"]);
                                  print(value["EndDateTime"]);

                                  setState(() {
                                    enableSubmit = false;
                                    _swapAgreementTerms['StartDateTime'] =
                                        value["StartDateTime"];

                                    _swapAgreementTerms['EndDateTime'] =
                                        value["EndDateTime"];

                                    startTime = DateFormat('MMM dd, hh:00 a')
                                        .format(DateTime.parse(
                                                value["StartDateTime"])
                                            .toLocal());
                                    endTime = DateFormat('MMM dd, hh:00 a')
                                        .format(
                                            DateTime.parse(value["EndDateTime"])
                                                .toLocal());

                                    DateTime givenTime =
                                        DateTime.parse(value['StartDateTime'])
                                            .toLocal();

                                    if (DateUtils.instance
                                        .isValidTime(givenTime)) {
                                      enableSuggest = true;
                                    } else {
                                      enableSuggest = false;
                                    }
                                  });
                                  //TODO
                                  updatePricing(false);
                                }
                              }
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'Duration',
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
                                        startTime + ' - ' + endTime,
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
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),*/
                      Card(
                        margin: EdgeInsets.only(right: 10, left: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        elevation: (_startTimeChanged || _endTimeChanged) ? 5 : 0,
                        color: (_startTimeChanged || _endTimeChanged) ? Color(0xFFF68E65): Colors.white,
                        child: Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(right: 2, left: 2),
                          padding: EdgeInsets.only(right: 4, left: 4,top: 2,bottom: 2),
                          child: InkWell(
                            onTap: () {
                              _swapAgreementTerms["events"] = _calendarEvents;
                              _swapAgreementTerms["_startDateTime"] =
                              _swapAgreementTerms['StartDateTime'];
                              _swapAgreementTerms["_endDateTime"] =
                              _swapAgreementTerms['EndDateTime'];
                              _swapAgreementTerms["route"] =
                              "/agree_with_swap_terms";
                              Navigator.pushNamed(context, '/swap_duration',
                                  arguments: _swapAgreementTerms)
                                  .then((v) {
                                if (v != null) {
                                  Map value = v as Map<dynamic, dynamic>;
                                  if (value["StartDateTime"] != null &&
                                      value["EndDateTime"] != null) {
                                    print(value["StartDateTime"]);
                                    print(value["EndDateTime"]);

                                    setState(() {
                                      enableSubmit = false;
                                      _startTimeChanged = false;
                                      _endTimeChanged = false;
                                      _swapAgreementTerms['StartDateTime'] =
                                      value["StartDateTime"];

                                      _swapAgreementTerms['EndDateTime'] =
                                      value["EndDateTime"];

                                      startTime = DateFormat('MMM dd, hh:00 a')
                                          .format(DateTime.parse(
                                          value["StartDateTime"])
                                          .toLocal());
                                      endTime = DateFormat('MMM dd, hh:00 a')
                                          .format(
                                          DateTime.parse(value["EndDateTime"])
                                              .toLocal());

                                      DateTime givenTime =
                                      DateTime.parse(value['StartDateTime'])
                                          .toLocal();

                                      if (DateUtil.instance
                                          .isValidTime(givenTime)) {
                                        enableSuggest = true;
                                      } else {
                                        enableSuggest = false;
                                      }
                                    });
                                    //TODO
                                    updatePricing(false);
                                  }
                                }
                              });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    'Duration',
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
                                          startTime + ' - ' + endTime,
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
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Divider(),
                      /// Location
                      /*Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: InkWell(
                          onTap: () {
                            _swapAgreementTerms["route"] = "/agree_with_swap_terms";
                            _swapAgreementTerms['_locationAddress'] = _swapAgreementTerms['Location']['Address'];
                            _swapAgreementTerms['_locationLat'] = _swapAgreementTerms['Location']['LatLng']['Latitude'];
                            _swapAgreementTerms['_locationLon'] = _swapAgreementTerms['Location']['LatLng']['Longitude'];
                            Navigator.pushNamed(context, '/swap_location', arguments: _swapAgreementTerms)
                                .then((value) {
                              if (value != null) {
                                Map receivedData = value;
                                if (receivedData['_locationAddress'] != null) {
                                  setState(() {
                                    enableSubmit = false;
                                    _swapAgreementTerms['Location']['Address'] = receivedData['_locationAddress'];
                                    _swapAgreementTerms['Location']['LatLng']['Latitude'] = receivedData['_locationLat'];
                                    _swapAgreementTerms['Location']['LatLng']['Longitude'] = receivedData['_locationLon'];
                                    address = receivedData['_locationAddress'];
                                    lat = receivedData['_locationLat'];
                                    lon = receivedData['_locationLon'];
                                  });
                                  updatePricing(false);
                                }
                              }
                            });
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Text(
                                        'Location',
                                        style: TextStyle(
                                          color: Color(0xff371D32),
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Text(
                                        address,
                                        style: TextStyle(
                                          color: Color(0xff353B50),
                                          fontFamily: 'Urbanist',
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
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
                      ),*/
                      Card(
                        margin: EdgeInsets.only(right: 10, left: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0.0),
                        ),
                        elevation: _locationChanged ? 5 : 0,
                        color: _locationChanged ? Color(0xFFF68E65): Colors.white,
                        child: Container(
                          color: Colors.white,
                          margin: EdgeInsets.only(right: 2, left: 2),
                          padding: EdgeInsets.only(right: 4, left: 4,top: 2,bottom: 2),
                          child: InkWell(
                            onTap: () {
                            _swapAgreementTerms["route"] = "/agree_with_swap_terms";
                              _swapAgreementTerms['_locationAddress'] = _swapAgreementTerms['Location']['Address'];
                          _swapAgreementTerms['_locationLat'] = _swapAgreementTerms['Location']['LatLng']['Latitude'];
                          _swapAgreementTerms['_locationLon'] = _swapAgreementTerms['Location']['LatLng']['Longitude'];
                          Navigator.pushNamed(context, '/swap_location', arguments: _swapAgreementTerms)
                              .then((value) {
                            if (value != null) {
                              Map receivedData = value as Map<dynamic, dynamic>;
                              if (receivedData['_locationAddress'] != null) {
                                setState(() {
                                  enableSubmit = false;
                                  _locationChanged = false;
                                  _swapAgreementTerms['Location']['Address'] = receivedData['_locationAddress'];
                                  _swapAgreementTerms['Location']['LatLng']['Latitude'] = receivedData['_locationLat'];
                                  _swapAgreementTerms['Location']['LatLng']['Longitude'] = receivedData['_locationLon'];
                                  address = receivedData['_locationAddress'];
                                  lat = receivedData['_locationLat'];
                                  lon = receivedData['_locationLon'];
                                });
                                updatePricing(false);
                              }
                            }
                          });
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  flex: 9,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        child: Text(
                                          'Location',
                                          style: TextStyle(
                                            color: Color(0xff371D32),
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          address,
                                          style: TextStyle(
                                            color: Color(0xff353B50),
                                            fontFamily: 'Urbanist',
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
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
                      ),
                      Divider(),
                      // Insurance
                      Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: InkWell(
                          onTap: () {
                            _swapAgreementTerms["route"] = "/agree_with_swap_terms";
                            _swapAgreementTerms['_insuranceType'] = insuranceType;
                            Navigator.pushNamed(context, '/swap_insurance', arguments: _swapAgreementTerms)
                                .then((value) {
                              if (value != null) {
                                Map receivedData = value as Map<dynamic, dynamic>;
                                if (receivedData['_insuranceType'] != null) {
                                  setState(() {
                                    enableSubmit = false;
                                    _swapAgreementTerms["InsuranceType"] =
                                        receivedData['_insuranceType'];
                                    insuranceType =
                                        receivedData['_insuranceType'];
                                    print(":::$insuranceType:::");
                                  });
                                  updatePricing(false);
                                }
                              }
                            });
                          },
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
                                      insuranceType == 'Standard'
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
                      // Pricing
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 16, left: 16, top: 24),
                        child: Text(
                          'TRIP RULES FOR ${_carName.toUpperCase()}',
                          style: TextStyle(
                              color: Color(0xff371D32).withOpacity(0.5),
                              letterSpacing: 0.2,
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Container(
                        color: Color(0xfff2f2f2),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  petAllowed == true
                                      ? Container()
                                      : Row(
                                          children: <Widget>[
                                            Image.asset('icons/No-Pets.png'),
                                            SizedBox(width: 5.0),
                                            Text(
                                              'No pets',
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF353B50)),
                                            ),
                                          ],
                                        ),
                                  SizedBox(height: 7.5),
                                  smokingAllowed == true
                                      ? Container()
                                      : Row(
                                          children: <Widget>[
                                            Image.asset('icons/No-smoking.png'),
                                            SizedBox(width: 5.0),
                                            Text(
                                              'No smoking',
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF353B50)),
                                            ),
                                          ],
                                        ),
                                  SizedBox(height: 7.5),
                                  freeKilometer == 'Limited'
                                      ? Row(
                                          children: <Widget>[
                                            Image.asset('icons/Mileage.png'),
                                            SizedBox(width: 5.0),
                                            Expanded(
                                              child: Text(
                                                '$limit km allowed daily, extra mileage is \$${oCcy.format(extraKilometerOverLimit)}/km',
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF353B50)),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: <Widget>[
                                            Image.asset('icons/Mileage.png'),
                                            SizedBox(width: 5.0),
                                            Expanded(
                                              child: Text(
                                                'Unlimited mileage allowance',
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF353B50)),
                                              ),
                                            ),
                                          ],
                                        )
                                  // Visibility(
                                  //     visible: limit > 0,
                                  //     child: SizedBox(height: 7.5)),

                                  // Visibility(
                                  //     visible: limit == 0,
                                  //     child: SizedBox(height: 7.5)),
                                  // Visibility(
                                  //   visible: limit == 0,
                                  //   child: Row(
                                  //     children: <Widget>[
                                  //       Image.asset('icons/Mileage.png'),
                                  //       SizedBox(width: 5.0),
                                  //       Expanded(
                                  //         child: Text(
                                  //           'Unlimited mileage allowance',
                                  //           style: TextStyle(
                                  //               fontFamily: 'Urbanist',
                                  //               fontSize: 14,
                                  //               color: Color(0xFF353B50)),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  ,
                                  SizedBox(height: 7.5),
                                  Row(
                                    children: <Widget>[
                                      Image.asset('icons/Fuel-2.png'),
                                      SizedBox(width: 5.0),
                                      Text(
                                        'Refuel with ${fuel == '91-94 premium' ? 'Premium' : fuel == '87 regular' ? 'Regular' : fuel == 'electric' ? 'Electric' : fuel == 'diesel' ? 'Diesel' : fuel} only',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 7.5),
                                  Row(
                                    children: <Widget>[
                                      Image.asset('icons/Fuel-2.png'),
                                      SizedBox(width: 5.0),
                                      Text(
                                        'Return with the same fuel level',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50)),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 7.5),
                                  Row(
                                    children: <Widget>[
                                      Image.asset('icons/Cleanliness-2.png'),
                                      SizedBox(width: 5.0),
                                      Text(
                                        'Return with the same cleanliness',
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Divider(),
                      /// Pricing
                      Padding(
                        padding:
                            const EdgeInsets.only(right: 16, left: 16, top: 24),
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
                      // Receivable
                      Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * .6,
                                child: Text(
                                  "$myCarName (" + receivableString + ")",
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
                                      "\$${oCcy.format(receivable)}",
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

                      // Payable
                      Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                width: MediaQuery.of(context).size.width * .6,
                                child: Text(
                                  "$_carName (" + payableString + ")",
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
                                      "\$${oCcy.format(payable)}",
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
                      // Income
                      Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  income < 0 ? 'Trip Cost' : 'Trip Income',
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
                                      "\$${oCcy.format(income).replaceAll("-", "")}",
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
                      // Insurance
                      Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'Trip Insurance',
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
                                      "\$${oCcy.format(insurance)}",
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
                      //  service Fee
                      Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text(
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
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  SizedBox(width: 16),
                                  Flexible(
                                    child: Text(
                                      "\$${oCcy.format(fee)}",
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
                      //free kilometer//
                      Padding(
                        padding: EdgeInsets.only(right: 16, left: 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: freeKilometer == 'Limited'
                                  ? Text(
                                      '$limit Total Kilometers Per Day',
                                      style: TextStyle(
                                        color: Color(0xff371D32),
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                      ),
                                    )
                                  : Text(
                                      'Unlimited Kilometers Per Day',
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
                                    "Free",
                                    style: TextStyle(
                                      color: Color(0xffFF8F68),
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
                      // Total
                      Padding(
                        padding: EdgeInsets.only(
                            top: 8, right: 16, left: 16, bottom: 8),
                        child: InkWell(
                          onTap: () {},
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Text(
                                  total < 0
                                      ? 'Net Trip Cost'
                                      : 'Net Trip Income',
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
                                      '\$${oCcy.format(total).replaceAll("-", "")}',
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
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(right: 16, left: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: SizedText(
                                deviceWidth: deviceWidth,
                                textWidthPercentage: 0.86,
                                textColor: Color(0xFF353B50),
                                fontFamily: 'Urbanist',
                                textAlign: TextAlign.center,
                                text: _swapAgreementTerms[
                                                'FreeCancelBeforeDateTime'] !=
                                            null &&
                                        DateUtil.instance
                                            .getFreeCancelDateTime(
                                                _swapAgreementTerms[
                                                    'FreeCancelBeforeDateTime'])
                                            .isAfter(DateTime.now())
                                    ? 'Free cancellation before ${DateUtil.instance.formatFreeCancelDateTime(_swapAgreementTerms['FreeCancelBeforeDateTime'])}'
                                    : 'You are no longer within the free cancellation period.',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(),
                      // constant message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('Click on a term above to change it, or click below to continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF353B50),
                            fontFamily: 'Urbanist',
                          ),),
                      ),
                      Divider(),
                      _hasError ? SizedBox(height: 10) : new Container(),
                      _hasError
                          ? Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        _error,
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xFFF55A51),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : new Container(),
                      // Next button
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: ElevatedButton(style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Color(0xffFF8F68),
                                      padding: EdgeInsets.all(16.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0)),),
                                      onPressed: enableSubmit
                                          ? () async {
                                              setState(() {
                                                enableSubmit = false;
                                                _hasError = false;
                                              });

                                              String? userID = await storage.read(key: 'user_id');

                                              if (userID != null) {
                                                var res = await agreeSwapAgreement(receivedData, _swapAgreementTerms);

                                                if (res.statusCode == 200) {
                                                  Navigator.pushNamed(context, '/swap_trip_booked');
                                                } else {
                                                  setState(() {
                                                    enableSubmit = true;
                                                    _error = json.decode(res.body!)['details'][0]['Message'];
                                                    _hasError = true;
                                                  });
                                                }
                                              }
                                            }
                                          : null,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Spacer(),
                                          Text(
                                            'Agree and book a trip',
                                            style: TextStyle(
                                                fontFamily:
                                                    'Urbanist',
                                                fontSize: 18,
                                                color: Colors.white),
                                          ),
                                          Spacer(),
                                          Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Once you agree, this will book a trip',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xff353B50),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _hasError || !enableSuggest
                          ? SizedBox(height: 10)
                          : new Container(),
                      _hasError || !enableSuggest
                          ? Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        _error,
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xFFF55A51),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : new Container(),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: ElevatedButton(style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Color(0xffFF8F68),
                                      padding: EdgeInsets.all(16.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0)),),
                                      onPressed: enableSuggest
                                          ? () async {
                                              var param = _swapAgreementTerms;
                                              var r = {
                                                "SwapAgreementID": param['SwapAgreementID'],
                                                "StartDateTime": param['StartDateTime'],
                                                "EndDateTime": param['EndDateTime'],
                                                "Location": {
                                                  "Address": param['Location']['Address'],
                                                "FormattedAddress": param['Location']['Address'],
                                                  "LatLng": {
                                                    "Latitude": param['Location']['LatLng']['Latitude'],
                                                    "Longitude": param['Location']['LatLng']['Longitude']
                                                  }
                                                },
                                                "InsuranceType": param['InsuranceType'],
                                                "UserID": "as"
                                              };
                                              print(r);
                                              setState(() {
                                                _isButtonPressed2 = true;
                                              });
                                              var res =
                                                  await updateSwapAgreementTerms(_swapAgreementTerms);

                                              print(res.toString());

                                              if (res.statusCode == 200) {
                                                Navigator.pop(context);
                                              } else {
                                                setState(() {
                                                  _error = json.decode(
                                                          res.body!)['details']
                                                      [0]['Message'];
                                                  _isButtonPressed2 = false;
                                                  _hasError = true;
                                                });
                                              }
                                            }
                                          : null,
                                      child: _isButtonPressed2
                                          ? SizedBox(
                                              height: 18.0,
                                              width: 18.0,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                backgroundColor: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Suggest terms',
                                              style: TextStyle(
                                                  fontFamily:
                                                      'Urbanist',
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
            ),
    );
  }

  Future<RestApi.Resp> updateSwapAgreementTerms(param) async {
    final completer = Completer<RestApi.Resp>();

    RestApi.callAPI(
      updateSwapArgeementTermsUrl,
      json.encode({
        "SwapAgreementID": param['SwapAgreementID'],
        "StartDateTime": param['StartDateTime'],
        "EndDateTime": param['EndDateTime'],
        "Location": {
          "Address": param['Location']['Address'],
          "FormattedAddress": param['Location']['Address'],
          "LatLng": {
            "Latitude": param['Location']['LatLng']['Latitude'],
            "Longitude": param['Location']['LatLng']['Longitude']
          }
        },
        "InsuranceType": param['InsuranceType'],
        "UserID": userID
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  Future<RestApi.Resp> agreeSwapAgreement(param1, param2) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      agreeSwapAgreementUrl,
      json.encode({
        "SwapAgreementID": param1['SwapAgreementID'],
        "UserID": param1['UserID'],
        "Hash": param2['Hash']
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  bool _isValidRange(DateTime start, DateTime end) {
    bool validity = true;

    List<DateTime> dates = DateUtil.instance.getDaysInBetween(start, end);

    for (DateTime date in dates) {
      if (_isBlockedDate(date)) {
        validity = false;
      }
    }
    return validity;
  }

  bool _isBlockedDate(DateTime date) {
    return date.isBefore(DateTime.now()) ||
        _calendarEvents.contains(DateFormat('yyyy-MM-dd').format(date)) ||
        ((_calendarEvents.contains(DateFormat('yyyy-MM-dd')
            .format(date.subtract(Duration(days: 1)))) &&
            _calendarEvents.contains(DateFormat('yyyy-MM-dd')
                .format(date.add(Duration(days: 1)))) ||
            (DateFormat('yyyy-MM-dd').format(date) ==
                DateFormat('yyyy-MM-dd').format(DateTime.now())) &&
                _calendarEvents.contains(DateFormat('yyyy-MM-dd')
                    .format(date.add(Duration(days: 1))))));
  }
}
