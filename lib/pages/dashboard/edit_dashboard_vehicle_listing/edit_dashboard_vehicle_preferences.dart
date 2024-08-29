import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';

import '../../../utils/app_events/app_events_utils.dart';

Map<String, dynamic> _vehiclePreferences = {
  "_carID": '',
  "_isSmokingAllowed": false,
  "_isSuitableForPets": false,
  "_dailyMileageAllowance": true,
  "_limit": 200.0,
  "_rentalEnabled": false,
  "_swapEnabled": false,
  "_bothEnabled": true
};

String _limitToString = '';



class EditDashboardVehiclePreferences extends StatefulWidget {
  @override
  State createState() => EditDashboardVehiclePreferencesState();
}

class EditDashboardVehiclePreferencesState
    extends State<EditDashboardVehiclePreferences> {

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Edit Dashboard Vehicle Preference"});
      final Map _receivedData = ModalRoute
          .of(context)
          !.settings
          .arguments as Map;

      setState(() {
        _vehiclePreferences['_carID'] = _receivedData['ID'];
        _vehiclePreferences['_isSmokingAllowed'] =
        _receivedData['Preference']['IsSmokingAllowed'];
        _vehiclePreferences['_isSuitableForPets'] =
        _receivedData['Preference']['IsSuitableForPets'];
        _vehiclePreferences['_dailyMileageAllowance'] =
        _receivedData['Preference']['DailyMileageAllowance'];
        _vehiclePreferences['_limit'] =
            _receivedData['Preference']['Limit'].toDouble();
        _vehiclePreferences['_rentalEnabled'] =
        _receivedData['Preference']['ListingType']['RentalEnabled'];
        _vehiclePreferences['_swapEnabled'] =
        _receivedData['Preference']['ListingType']['SwapEnabled'];
        _vehiclePreferences['_bothEnabled'] =
            !_vehiclePreferences['_rentalEnabled'] &&
                !_vehiclePreferences['_swapEnabled'];
      });

      switch (_vehiclePreferences['_limit']) {
        case 200:
          _limitToString = '200 KM';
          break;
        case 400:
          _limitToString = '400 KM';
          break;
        case 600:
          _limitToString = '600 KM';
          break;
        case 800:
          _limitToString = '800 KM';
          break;
        case 1000:
          _limitToString = '1000 KM';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map receivedData = ModalRoute
        .of(context)
        !.settings
        .arguments as Map;

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/edit_your_listing_tab',
              arguments: receivedData,
            );
          },
        ),
        centerTitle: true,
        title: Text('4/6',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: Color(0xff371D32),
          ),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(
                      context,
                      '/dashboard_tab'
                  );
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text('Save & Exit',
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
        ],
        elevation: 0.0,
      ),

      //Content of tabs
      body: _vehiclePreferences['_carID'] != '' ? new SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            child: Text('Set preferences for your vehicle',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 36,
                                  color: Color(0xFF371D32),
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('icons/Info_Car-Rules.png'),
                ],
              ),
              SizedBox(height: 30),
              // Smoking
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    Text('Smoking allowed?',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          padding: EdgeInsets.all(16.0),

                                          backgroundColor: _vehiclePreferences['_isSmokingAllowed']
                                              ? Color(0xFFFF8F62)
                                              : Color(0xFFE0E0E0).withOpacity(
                                              0.5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _vehiclePreferences['_isSmokingAllowed'] =
                                            !_vehiclePreferences['_isSmokingAllowed'];
                                          });
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                Text('YES',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 12,
                                                    color: _vehiclePreferences['_isSmokingAllowed']
                                                        ? Color(0xFFFFFFFF)
                                                        : Color(0xFF353B50)
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          padding: EdgeInsets.all(16.0),

                                          backgroundColor: _vehiclePreferences['_isSmokingAllowed']
                                              ? Color(0xFFE0E0E0).withOpacity(
                                              0.5)
                                              : Color(0xFFFF8F62),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _vehiclePreferences['_isSmokingAllowed'] =
                                            !_vehiclePreferences['_isSmokingAllowed'];
                                          });
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                Text('NO',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 12,
                                                    color: _vehiclePreferences['_isSmokingAllowed'] as bool
                                                        ? Color(0xFF353B50)
                                                        .withOpacity(0.5)
                                                        : Color(0xFFFFFFFF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
              SizedBox(height: 10),
              // Pets
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Text('Suitable for pets?',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          padding: EdgeInsets.all(16.0),

                                          backgroundColor: _vehiclePreferences['_isSuitableForPets']as bool
                                              ? Color(0xFFFF8F62)
                                              : Color(0xFFE0E0E0).withOpacity(
                                              0.5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _vehiclePreferences['_isSuitableForPets'] =
                                            !_vehiclePreferences['_isSuitableForPets'];
                                          });
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                Text('YES',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 12,
                                                    color: _vehiclePreferences['_isSuitableForPets']as bool
                                                        ? Color(0xFFFFFFFF)
                                                        : Color(0xFF353B50)
                                                        .withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          padding: EdgeInsets.all(16.0),

                                          backgroundColor: _vehiclePreferences['_isSuitableForPets']as bool
                                              ? Color(0xFFE0E0E0).withOpacity(
                                              0.5)
                                              : Color(0xFFFF8F62),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _vehiclePreferences['_isSuitableForPets'] =
                                            !_vehiclePreferences['_isSuitableForPets'];
                                          });
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                Text('NO',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 12,
                                                    color: _vehiclePreferences['_isSuitableForPets']as bool
                                                        ? Color(0xFF353B50)
                                                        .withOpacity(0.5)
                                                        : Color(0xFFFFFFFF),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
              SizedBox(height: 10),
              // Daily mileage
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    Text('Daily mileage allowance',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            "Set a daily mileage limit and if your guest exceeds this limit, you will be able to charge an extra fee for every additional kilometer.",
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xFF353B50),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          padding: EdgeInsets.all(16.0),

                                          backgroundColor: _vehiclePreferences['_dailyMileageAllowance'] ==
                                              'Unlimited'
                                              ? Color(0xFFFF8F62)
                                              : Color(0xFFE0E0E0).withOpacity(
                                              0.5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _vehiclePreferences['_dailyMileageAllowance'] =
                                            'Unlimited';
                                          });
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                Text('UNLIMITED',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 12,
                                                    color: _vehiclePreferences['_dailyMileageAllowance'] ==
                                                        'Unlimited' ? Color(
                                                        0xFFFFFFFF) : Color(
                                                        0xFF353B50).withOpacity(
                                                        0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          padding: EdgeInsets.all(16.0),

                                          backgroundColor: _vehiclePreferences['_dailyMileageAllowance'] ==
                                              'Limited'
                                              ? Color(0xFFFF8F62)
                                              : Color(0xFFE0E0E0).withOpacity(
                                              0.5),
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius
                                                  .circular(8.0)),),
                                        onPressed: () {
                                          setState(() {
                                            _vehiclePreferences['_dailyMileageAllowance'] =
                                            'Limited';
                                          });
                                        },
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: <Widget>[
                                                Text('SET A LIMIT',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 12,
                                                    color: _vehiclePreferences['_dailyMileageAllowance'] ==
                                                        'Limited' ? Color(
                                                        0xFFFFFFFF) : Color(
                                                        0xFF353B50).withOpacity(
                                                        0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
              SizedBox(height: 10),
              // Limit
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            decoration: new BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: new BorderRadius.circular(8.0),
                            ),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        Text("What should be the limit?",
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                        Text(_limitToString,
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                              thumbColor: Color(0xffFFFFFF),
                                              trackShape: RoundedRectSliderTrackShape(),
                                              trackHeight: 4.0,
                                              activeTrackColor: Color(
                                                  0xffFF8F62),
                                              inactiveTrackColor: Color(
                                                  0xFFE0E0E0),
                                              tickMarkShape: RoundSliderTickMarkShape(
                                                  tickMarkRadius: 4.0),
                                              activeTickMarkColor: Color(
                                                  0xffFF8F62),
                                              inactiveTickMarkColor: Color(
                                                  0xFFE0E0E0),
                                              thumbShape: RoundSliderThumbShape(
                                                  enabledThumbRadius: 14.0),
                                            ),
                                            child: Slider(
                                              min: _vehiclePreferences['_dailyMileageAllowance'] ==
                                                  'Limited' ? 200.0 : 0.0,
                                              max: 1000.0,
                                              onChanged: _vehiclePreferences['_dailyMileageAllowance'] ==
                                                  'Limited' ? (values) {
                                                setState(() {
                                                  int _value = values.round();

                                                  switch (_value) {
                                                    case 200:
                                                      _limitToString = '200 KM';
                                                      break;
                                                    case 400:
                                                      _limitToString = '400 KM';
                                                      break;
                                                    case 600:
                                                      _limitToString = '600 KM';
                                                      break;
                                                    case 800:
                                                      _limitToString = '800 KM';
                                                      break;
                                                    case 1000:
                                                      _limitToString =
                                                      '1000 KM';
                                                      break;
                                                  }
                                                  _vehiclePreferences['_limit'] =
                                                      values;
                                                });
                                              } : null,
                                              value: _vehiclePreferences['_limit'],
                                              divisions: 4,
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
              ),
              SizedBox(height: 30),
              // Select listing type
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            'Select a type of listing for your vehicle',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 18,
                              color: Color(0xFF371D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Rental only
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: new BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: new BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        height: 26,
                                        width: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.transparent,
                                          border: Border.all(
                                            color: Color(0xFF353B50),
                                            width: 2,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(7.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _vehiclePreferences['_rentalEnabled']
                                                  ? Color(0xFFFF8F62)
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Text('Rental only',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _vehiclePreferences['_rentalEnabled'] =
                                      true;
                                      _vehiclePreferences['_swapEnabled'] =
                                      false;
                                      _vehiclePreferences['_bothEnabled'] =
                                      false;
                                    });
                                    // _checkButtonDisability();
                                  },
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  child: Text(
                                    'Your vehicle will be available for rentals and you are not looking for another vehicle in exchange.',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xFF353B50),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Swap only
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: new BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: new BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        height: 26,
                                        width: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.transparent,
                                          border: Border.all(
                                            color: Color(0xFF353B50),
                                            width: 2,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(7.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _vehiclePreferences['_swapEnabled']
                                                  ? Color(0xFFFF8F62)
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Text('Swap only',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _vehiclePreferences['_rentalEnabled'] =
                                      false;
                                      _vehiclePreferences['_swapEnabled'] =
                                      true;
                                      _vehiclePreferences['_bothEnabled'] =
                                      false;
                                    });
                                    // _checkButtonDisability();
                                  },
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  child: Text(
                                    'Your vehicle will only be available when another host has a vehicle to offer for exchange.',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xFF353B50),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Rental & Swap
              SizedBox(height: 10),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: new BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: new BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                GestureDetector(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        height: 26,
                                        width: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.transparent,
                                          border: Border.all(
                                            color: Color(0xFF353B50),
                                            width: 2,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.all(7.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _vehiclePreferences['_bothEnabled']
                                                  ? Color(0xFFFF8F62)
                                                  : Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Text('Both rental and swap',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _vehiclePreferences['_rentalEnabled'] =
                                      false;
                                      _vehiclePreferences['_swapEnabled'] =
                                      false;
                                      _vehiclePreferences['_bothEnabled'] =
                                      true;
                                    });
                                    // _checkButtonDisability();
                                  },
                                ),
                                SizedBox(height: 12),
                                SizedBox(
                                  child: Text(
                                    'Your vehicle will be available for both rental and swap.',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xFF353B50),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Next button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                      SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(style: ElevatedButton.styleFrom(
                        elevation: 0.0,
                        backgroundColor: Color(0xFFFF8F62),
                        padding: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),),
                        onPressed: () async {
                          var res = await setPreferences();

                          var arguments = json.decode(res.body!)['Car'];

                          Navigator.pushNamed(
                              context,
                              '/edit_your_listing_tab',
                              arguments: arguments
                          );
                        },
                        child: Text('Next',
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 18,
                              color: Colors.white
                          ),
                        ),
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
      )
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[new CircularProgressIndicator()],
        ),
      ),
    );
  }
}

Future<http.Response> setPreferences() async {
  var res;

  try {
    res = await http.post(
      Uri.parse(setPreferenceUrl),
      // setPreferenceUrl as Uri,
      body: json.encode(
          {
            "CarID": _vehiclePreferences['_carID'],
            "Preference": {
              "IsSmokingAllowed": _vehiclePreferences['_isSmokingAllowed'],
              "IsSuitableForPets": _vehiclePreferences['_isSuitableForPets'],
              "DailyMileageAllowance": _vehiclePreferences['_dailyMileageAllowance'],
              "Limit": _vehiclePreferences['_dailyMileageAllowance'] ==
                  'Limited'
                  ? double.parse(_vehiclePreferences['_limit'].toString())
                  .round()
                  .toString()
                  : 0,
              "ListingType": {
                "RentalEnabled": _vehiclePreferences['_rentalEnabled'],
                "SwapEnabled": _vehiclePreferences['_swapEnabled']
              },
              "Completed": true
            }
          }
      ),
    );
  } catch (error) {

  }

  return res;
}
