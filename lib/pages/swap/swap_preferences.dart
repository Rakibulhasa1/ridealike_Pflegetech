import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/events/swapprefevent.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/list_a_car/response_model/daily_mileage_configuration_response.dart';
import 'package:ridealike/pages/messages/utils/eventbusutils.dart';

import '../../utils/app_events/app_events_utils.dart';

Future<FetchDailyMileageConfigurationResponse>
    callFetchSwapWithinConfiguration() async {
  var response = await fetchDailyMileageConfiguration();
  if (response != null && response.statusCode == 200) {
    var swapWithinConfigRes = FetchDailyMileageConfigurationResponse.fromJson(
        json.decode(response.body!));
    return swapWithinConfigRes;
  } else {
    // return null;
    throw Exception('Failed to fetch daily mileage configuration');
  }
}

Future<RestApi.Resp> fetchDailyMileageConfiguration() async {
  var dailyMileageConfigurationCompleter = Completer<RestApi.Resp>();
  RestApi.callAPI(getListCarConfigurablesUrl, json.encode({})).then((resp) {
    dailyMileageConfigurationCompleter.complete(resp);
  });
  return dailyMileageConfigurationCompleter.future;
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

const textStyle = TextStyle(
    color: Color(0xff371D32),
    fontSize: 36,
    fontFamily: 'Urbanist',
    fontWeight: FontWeight.bold);

class SwapPreferences extends StatefulWidget {
  @override
  State createState() => SwapPreferencesState();
}

class SwapPreferencesState extends State<SwapPreferences> {
  String _userId = '';
  final storage = new FlutterSecureStorage();

  List _carsData = [];
  String _selectedCarID = '';
  Map _selectedCarData = {};

  double _searchWithin = 15.0;
  double _searchWithinMax = 30.0;

  double range = 0.0;

  bool isDataAvailable = false;
  bool _isButtonDisabled = false;

  DateTime today = new DateTime.now();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Swap Preference"});
    loadData();
  }

  void loadData() async {
    FetchDailyMileageConfigurationResponse mileage =
        await callFetchSwapWithinConfiguration();
    print(mileage.listCarConfigurables!.dailyMileageAllowanceLimitRange);
    print(mileage.listCarConfigurables!.swapWithinMaxLimit);
    setState(() {
      range = mileage.listCarConfigurables!.swapWithinMaxLimit!.toDouble();
      // _searchWithin = range / 5.0;
    });
    callFetchGetAllSwapAvailabilityByUserID();
  }

  callFetchGetAllSwapAvailabilityByUserID() async {
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var res = await fetchGetAllSwapAvailabilityByUserID(userID);

      setState(() {
        _userId = userID;
        _carsData = json.decode(res.body!)['SwapAvailabilitys'];
        _selectedCarID = json.decode(res.body!)['CarToSwapID'];

        if (_selectedCarID == null || _selectedCarID == ''){
          if ( _carsData != null && _carsData.length>0){
            _selectedCarID = _carsData[0]['CarID'];
            _selectedCarData = _carsData[0];
            _searchWithin = double.tryParse(_carsData[0]['SwapAvailability']['SwapWithin'].toString())!;
          }
        } else {
          if ( _carsData != null && _carsData.length>0){

            for (int i =0; i<_carsData.length; i++) {
              if(_selectedCarID ==_carsData[i]['CarID'] ) {
                _selectedCarData = _carsData[i];
                _searchWithin = double.tryParse(
                    _carsData[i]['SwapAvailability']['SwapWithin'].toString())!;
                break;
              }
            }
          }
        }



        isDataAvailable = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            // Navigator.pushNamed(context, '/discover_tab',);
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),
      body: _carsData != null
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // Header and plus button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Preferences',
                          style: textStyle,
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    // Sub header
                    Text(
                      'VEHICLE TO SWAP',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        color: Color(0xff371D32).withOpacity(0.5),
                      ),
                    ),
                    Divider(color: Color(0xFFE7EAEB)),
                    SizedBox(height: 10),
                    // Horizontal car list
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: _carsData.length > 0
                            ? <Widget>[
                                for (var item in _carsData)
                                  item['CarTitle'] != ''
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 30, right: 10),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor:
                                              _selectedCarID == item['CarID'] ? Colors.white
                                                  : Color(0xffF2F2F2),
                                              // textColor: Color(0xff371D32),
                                              padding: EdgeInsets.all(16.0),
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                    width: 1,
                                                    color: _selectedCarID == item['CarID'] ? Color(0xffF68E65) : Colors.transparent),
                                                borderRadius:
                                                BorderRadius.circular(8.0),
                                              ),

                                            ),
                                            onPressed: () async {
                                              setState(() {
                                                _selectedCarID = item['CarID'];
                                                _selectedCarData = item;

                                                _searchWithin = item['SwapAvailability']['SwapWithin'].toDouble();
                                                /*if (within < 100.0) {
                                                  _searchWithin = within;
                                                } else {
                                                  _searchWithin = 100.0;
                                                }*/
                                              });
                                              print(json.encode(_selectedCarData).toString());
                                            },
                                            child: Text(
                                              item['CarTitle'],
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xff371D32),
                                              ),
                                            ),
                                          ),
                                        )
                                      : new Container(),
                              ]
                            : <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 30, right: 10),
                                  child: Text(
                                    'No listed Vehicle yet',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                !isDataAvailable
                                    ? Container(
                                        margin: EdgeInsets.all(2.5),
                                        child: SizedBox(
                                          height: 18.0,
                                          width: 18.0,
                                          child: new CircularProgressIndicator(
                                              strokeWidth: 1.0),
                                        ),
                                      )
                                    : new Container(),
                              ],
                      ),
                    ),
                    // Sub header
                    _selectedCarID != ''
                        ? Text(
                            'SEARCH WITHIN',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: Color(0xff371D32).withOpacity(0.5),
                            ),
                          )
                        : new Container(),
                    _selectedCarID != '' ? Divider(color: Color(0xFFE7EAEB)) : new Container(),
                    SizedBox(height: 10),
                    _selectedCarID != ''
                        ? Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xffFFFFFF),
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        child: Container(
                                          child: Column(
                                            children: <Widget>[
                                              Padding(
                                                padding: EdgeInsets.all(16.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      _searchWithin.round().toString() + ' km',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF353B50),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                    bottom: 8.0),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: SliderTheme(
                                                        data: SliderThemeData(
                                                          thumbColor:
                                                              Color(0xffFFFFFF),
                                                          trackShape:
                                                              RoundedRectSliderTrackShape(),
                                                          trackHeight: 4.0,
                                                          activeTrackColor:
                                                              Color(0xffFF8F62),
                                                          inactiveTrackColor:
                                                              Color(0xFFE0E0E0),
                                                          tickMarkShape:
                                                              RoundSliderTickMarkShape(
                                                                  tickMarkRadius:
                                                                      4.0),
                                                          activeTickMarkColor:
                                                              Color(0xffFF8F62),
                                                          inactiveTickMarkColor:
                                                              Color(0xFFE0E0E0),
                                                          thumbShape:
                                                              RoundSliderThumbShape(
                                                                  enabledThumbRadius:
                                                                      14.0),
                                                        ),
                                                        // TODO
                                                        child: Slider(
                                                          // min: 10.0,
                                                          // max: 100.0,
                                                          min: range > 0.0
                                                              ? range / 5.0
                                                              : 0.0,
                                                          max: range,
                                                          onChanged: (values) {
                                                            setState(() {
                                                              _searchWithin = values;
                                                            });
                                                          },
                                                          divisions: 4,
                                                          value: _searchWithin,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
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
                            ],
                          )
                        : new Container(),
                    SizedBox(height: 10),
                    // Sub header
                    _selectedCarID != ''
                        ? Text(
                            'SWAP WITH',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: Color(0xff371D32).withOpacity(0.5),
                            ),
                          )
                        : new Container(),
                    _selectedCarID != ''
                        ? Divider(color: Color(0xFFE7EAEB))
                        : new Container(),
                    SizedBox(height: 10),
                    _selectedCarID != ''
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Vehicles',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontSize: 18,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ],
                          )
                        : new Container(),
                    SizedBox(height: 10),
                    // Economy & Compact // mid-full size
                    _selectedCarID != ''
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Color(0xFFF2F2F2),
                                          padding: EdgeInsets.all(12.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8.0)),

                                        ),
                                         onPressed: () {
                                          setState(() {
                                            _selectedCarData['SwapAvailability']
                                                    ['SwapVehiclesType']
                                                ['Economy'] = !_selectedCarData[
                                                    'SwapAvailability']
                                                ['SwapVehiclesType']['Economy'];
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(children: [
                                                Text(
                                                  'Economy',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            Icon(
                                              Icons.check,
                                              size: 20,
                                              color: _selectedCarData['SwapAvailability']['SwapVehiclesType']['Economy']
                                                  ? Color(0xFFFF8F68)
                                                  : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xFFF2F2F2),
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _selectedCarData['SwapAvailability']
                                                        ['SwapVehiclesType']
                                                    ['MidFullSize'] =
                                                !_selectedCarData[
                                                            'SwapAvailability']
                                                        ['SwapVehiclesType']
                                                    ['MidFullSize'];
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(children: [
                                                Text(
                                                  'Mid/Full-Size',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            Icon(
                                              Icons.check,
                                              size: 20,
                                              color: _selectedCarData[
                                                              'SwapAvailability']
                                                          ['SwapVehiclesType']
                                                      ['MidFullSize']
                                                  ? Color(0xFFFF8F68)
                                                  : Colors.transparent,
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
                        : new Container(),
                    SizedBox(height: 10),
                    // Sport
                    _selectedCarID != ''
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _selectedCarData['SwapAvailability']
                                                    ['SwapVehiclesType']
                                                ['Sports'] = !_selectedCarData[
                                                    'SwapAvailability']
                                                ['SwapVehiclesType']['Sports'];
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(children: [
                                                Text(
                                                  'Sport',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            Icon(
                                              Icons.check,
                                              size: 20,
                                              color: _selectedCarData[
                                                              'SwapAvailability']
                                                          ['SwapVehiclesType']
                                                      ['Sports']
                                                  ? Color(0xFFFF8F68)
                                                  : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: new Container(),
                              ),
                            ],
                          )
                        : new Container(),
                    SizedBox(height: 20),
                    // SUVs
                    _selectedCarID != ''
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'SUVs',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontSize: 18,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ],
                          )
                        : new Container(),
                    SizedBox(height: 10),
                    // Compact SUV & Mid-Size SUV
                    _selectedCarID != ''
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _selectedCarData['SwapAvailability']
                                                    ['SwapVehiclesType']
                                                ['SUV'] = !_selectedCarData[
                                                    'SwapAvailability']
                                                ['SwapVehiclesType']['SUV'];
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(children: [
                                                Text(
                                                  'SUV',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            Icon(
                                              Icons.check,
                                              size: 20,
                                              color: _selectedCarData[
                                                                  'SwapAvailability']
                                                              [
                                                              'SwapVehiclesType'] !=
                                                          null &&
                                                      _selectedCarData[
                                                                      'SwapAvailability']
                                                                  [
                                                                  'SwapVehiclesType']
                                                              ['SUV'] !=
                                                          null &&
                                                      _selectedCarData[
                                                              'SwapAvailability']
                                                          [
                                                          'SwapVehiclesType']['SUV']
                                                  ? Color(0xFFFF8F68)
                                                  : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: new Container(),
                              ),
                            ],
                          )
                        : new Container(),
                    SizedBox(height: 10),
                    // Trucks and vans
                    _selectedCarID != ''
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Trucks and vans',
                                style: TextStyle(
                                  color: Color(0xff371D32),
                                  fontSize: 18,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ],
                          )
                        : new Container(),
                    SizedBox(height: 10),
                    // Pick-up truck & Minivan
                    _selectedCarID != ''
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _selectedCarData['SwapAvailability']
                                                        ['SwapVehiclesType']
                                                    ['PickupTruck'] =
                                                !_selectedCarData[
                                                            'SwapAvailability']
                                                        ['SwapVehiclesType']
                                                    ['PickupTruck'];
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(children: [
                                                Text(
                                                  'Pick-up Truck',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            Icon(
                                              Icons.check,
                                              size: 20,
                                              color: _selectedCarData[
                                                              'SwapAvailability']
                                                          ['SwapVehiclesType']
                                                      ['PickupTruck']
                                                  ? Color(0xFFFF8F68)
                                                  : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child:  ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xFFF2F2F2),
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _selectedCarData['SwapAvailability']
                                                    ['SwapVehiclesType']
                                                ['Minivan'] = !_selectedCarData[
                                                    'SwapAvailability']
                                                ['SwapVehiclesType']['Minivan'];
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(children: [
                                                Text(
                                                  'Minivan',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            Icon(
                                              Icons.check,
                                              size: 20,
                                              color: _selectedCarData[
                                                              'SwapAvailability']
                                                          ['SwapVehiclesType']
                                                      ['Minivan']
                                                  ? Color(0xFFFF8F68)
                                                  : Colors.transparent,
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
                        : new Container(),
                    SizedBox(height: 10),
                    // Van
                    _selectedCarID != ''
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _selectedCarData['SwapAvailability']
                                                    ['SwapVehiclesType']
                                                ['Van'] = !_selectedCarData[
                                                    'SwapAvailability']
                                                ['SwapVehiclesType']['Van'];
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(children: [
                                                Text(
                                                  'Van',
                                                  style: TextStyle(
                                                    fontFamily:
                                                        'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  ),
                                                ),
                                              ]),
                                            ),
                                            Icon(
                                              Icons.check,
                                              size: 20,
                                              color: _selectedCarData[
                                                          'SwapAvailability'][
                                                      'SwapVehiclesType']['Van']
                                                  ? Color(0xFFFF8F68)
                                                  : Colors.transparent,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: new Container(),
                              ),
                            ],
                          )
                        : new Container(),
                    SizedBox(height: 20),
                    // Save button
                    _selectedCarID != ''
                        ? Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child:  ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xffFF8F68),
                                        padding: EdgeInsets.all(16.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),),
                                        onPressed: _isButtonDisabled
                                            ? null
                                            : () async {
                                                setState(() {
                                                  _isButtonDisabled = true;
                                                });
                                                try {
                                                  print(_selectedCarData);
                                                  await setCarToSwap(
                                                      _userId, _selectedCarID);
                                                  await setSwapAvailability(
                                                      _searchWithin,
                                                      _selectedCarData[
                                                              'SwapAvailability']
                                                          ['SwapVehiclesType'],
                                                      _selectedCarID);
                                                } catch (e) {
                                                  print(e);
                                                } finally {
                                                  EventBusUtils.getInstance().fire(SwapPrefEvent());
                                                  print("event fired");
                                                  Navigator.pop(context);
                                                }
                                              },
                                        child: _isButtonDisabled
                                            ? SizedBox(
                                                height: 18.0,
                                                width: 18.0,
                                                child:
                                                    new CircularProgressIndicator(
                                                        strokeWidth: 2.5),
                                              )
                                            : Text(
                                                'Save',
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
                          )
                        : new Container(),
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
}

Future<RestApi.Resp> setCarToSwap(_userID, _carID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    setCarToSwapUrl,
    json.encode({
      "CarToSwap": {"UserID": _userID, "CarID": _carID}
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> setSwapAvailability(_swapWithin, _data, _carID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    setSwapAvailabilityUrl,
    json.encode({
      "SwapAvailability": {
        "SwapWithin": _swapWithin.round(),
        "SwapVehiclesType": {
          "Economy": _data['Economy'],
          "MidFullSize": _data['MidFullSize'],
          "Sports": _data['Sports'],
          "SUV": _data['SUV'],
          "PickupTruck": _data['PickupTruck'],
          "Minivan": _data['Minivan'],
          "Van": _data['Van']
        }
      },
      "CarID": _carID
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
