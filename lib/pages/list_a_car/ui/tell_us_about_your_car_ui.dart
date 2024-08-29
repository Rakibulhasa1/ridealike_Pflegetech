import 'dart:async';
import 'dart:convert' show json, jsonEncode;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geocoder_plus/distance_google.dart';
import 'package:geocoder_plus/geocoder.model.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:search_map_place/search_map_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    as _googleMapFlutter;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/list_a_car/bloc/tell_us_about_car_bloc.dart';
import 'package:ridealike/pages/list_a_car/request_service/tell_us_about_car_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/utils/address_utils.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:ridealike/utils/year_picker.dart' as yearPicker;
import 'package:ridealike/widgets/sized_text.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';
import 'package:shimmer/shimmer.dart';

import '../../common/location_util.dart';

class TellUsAboutYourCarUI extends StatefulWidget {
  @override
  State createState() => TellUsAboutYourCarUIState();
}

class TellUsAboutYourCarUIState extends State<TellUsAboutYourCarUI> {
  var setAboutCarBloc = SetAboutCarBloc();
  bool exitPressed = false;
  int maxLength = 5;

  var controller = TextEditingController();

  Completer<_googleMapFlutter.GoogleMapController> _mapController = Completer();

  final Set<_googleMapFlutter.Marker> _markers = new Set();

  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context)!.settings.arguments as Map;
    CreateCarResponse receivedData = CreateCarResponse.fromJson(
        (data['carResponse'] as CreateCarResponse).toJson());
    var purpose = data['purpose'];
    bool pushNeeded = data['PUSH'] == null ? false : data['PUSH'];
    String? pushRouteName = data['ROUTE_NAME'];
//    final CreateCarResponse receivedData = ModalRoute.of(context).settings.arguments;

    setAboutCarBloc.changedProgressIndicator.call(0);
    if (receivedData.car!.about!.completed == false) {
      LocationUtil.requestPermission().then((value) {
        if (value == LocationPermission.always ||
            value == LocationPermission.whileInUse) {
          LocationUtil.getCurrentLocation().then((value) {
            receivedData.car!.about!.location!.latLng!.latitude =
                value!.latitude;
            receivedData.car!.about!.location!.latLng!.longitude =
                value!.longitude;
            setAboutCarBloc.changedCarData.call(receivedData);
            AddressUtils.getAddress(
                    receivedData.car!.about!.location!.latLng!.latitude!,
                    receivedData.car!.about!.location!.latLng!.longitude!)
                .then((value) {
              receivedData.car!.about!.location!.address = value;
              setAboutCarBloc.changedCarData.call(receivedData);
            });
          });
        } else {
          receivedData.car!.about!.location!.latLng!.latitude = 43.6532;
          receivedData.car!.about!.location!.latLng!.longitude = 79.3832;
          setAboutCarBloc.changedCarData.call(receivedData);
          AddressUtils.getAddress(
                  receivedData.car!.about!.location!.latLng!.latitude!,
                  receivedData.car!.about!.location!.latLng!.longitude!)
              .then((value) {
            receivedData.car!.about!.location!.address = value;
            setAboutCarBloc.changedCarData.call(receivedData);
          });
        }
      });
    } else {
      setAboutCarBloc.changedCarData.call(receivedData);
    }

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: StreamBuilder<CreateCarResponse>(
            stream: setAboutCarBloc.carData,
            builder: (context, snapshot) {
              return new IconButton(
                icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
                onPressed: () {
                  if (pushNeeded) {
                    Navigator.pushNamed(context, pushRouteName!, arguments: {
                      'carResponse': data['carResponse'],
                      'purpose': purpose
                    });
                  } else {
                    Navigator.pop(context);
                  }
                },
              );
            }),
        centerTitle: true,
        title: Text(
          '1/6',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: Color(0xff371D32),
          ),
        ),
        actions: <Widget>[
          StreamBuilder<CreateCarResponse>(
              stream: setAboutCarBloc.carData,
              builder: (context, carDataSnapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        //TODO
                        if (!exitPressed) {
                          exitPressed = true;
                          var res = await setAbout(carDataSnapshot.data!,
                              completed: false, saveAndExit: true);
                          Navigator.pushNamed(context, '/dashboard_tab',
                              arguments: res);
                          // } else {
                          //   Navigator.pushNamed(context, '/dashboard_tab');
                          // }
                        }
                      },
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(right: 16),
                          child: receivedData.car!.about!.completed!
                              ? Text('')
                              : Text(
                                  'Save & Exit',
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
                );
              }),
        ],
        elevation: 0.0,
      ),

      //Content of tabs
      body: StreamBuilder<CreateCarResponse>(
          stream: setAboutCarBloc.carData,
          builder: (context, dataSnapshot) {
            return dataSnapshot.hasData && dataSnapshot.data != null
                ? Container(
                    child: new SingleChildScrollView(
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
                                          child: Text(
                                            'Tell us about your vehicle',
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 36,
                                                color: Color(0xFF371D32),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Image.asset('icons/Car_Tell-Us-About-Car.png'),
                              ],
                            ),
                            SizedBox(height: 30),
                            // What car do you have?
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              'Vehicle information',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 18,
                                                color: Color(0xFF371D32),
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
                            SizedBox(height: 20),
                            // Type
                            Row(
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
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),
                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                    context, '/car_type_ui',
                                                    arguments:
                                                        dataSnapshot.data)
                                                .then((value) {
                                              //check//
                                              if (value != null) {
                                                setAboutCarBloc.changedCarData
                                                    .call(value
                                                        as CreateCarResponse);
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Row(children: [
                                                  Text(
                                                    'Type',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(0xFF371D32),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                      dataSnapshot.data!.car!
                                                          .about!.carType!,
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF353B50),
                                                      ),
                                                    ),
                                                    Icon(
                                                        Icons
                                                            .keyboard_arrow_right,
                                                        color:
                                                            Color(0xFF353B50)),
                                                  ],
                                                ),
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
                            // Year
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor:
                                                  Color(0xFFF2F2F2),
                                              padding: EdgeInsets.all(16.0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                            ),
                                            onPressed: purpose == 3
                                                ? () => {}
                                                : () => openYearPicker(
                                                    context, dataSnapshot),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Text(
                                                      'Year',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        dataSnapshot.data!.car!
                                                            .about!.year!,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF353B50),
                                                        ),
                                                      ),
                                                      Icon(
                                                          Icons
                                                              .keyboard_arrow_right,
                                                          color: Color(
                                                              0xFF353B50)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Make
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor:
                                                  Color(0xFFF2F2F2),
                                              padding: EdgeInsets.all(16.0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                            ),
                                            onPressed: purpose == 3
                                                ? () => {}
                                                : () {
                                                    Navigator.pushNamed(context,
                                                            '/car_make_ui',
                                                            //                                '/pickup_and_return_location',
                                                            arguments: CreateCarResponse
                                                                .fromJson(
                                                                    dataSnapshot
                                                                        .data!
                                                                        .toJson()))
                                                        .then((value) {
                                                      if (value != null &&
                                                          (value as Map)[
                                                                  'DATA'] !=
                                                              null) {
                                                        setAboutCarBloc
                                                            .changedCarData
                                                            .call(
                                                                (value as Map)[
                                                                    'DATA']);
                                                      }
                                                    });
                                                  },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Text(
                                                      'Make',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        dataSnapshot.data!.car!
                                                            .about!.make!,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF353B50),
                                                        ),
                                                      ),
                                                      Icon(
                                                          Icons
                                                              .keyboard_arrow_right,
                                                          color: Color(
                                                              0xFF353B50)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Model
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
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      8.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Text(
                                                      'Model',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                        dataSnapshot.data!.car!
                                                            .about!.model!,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF353B50),
                                                        ),
                                                      ),
                                                      Icon(
                                                          Icons
                                                              .keyboard_arrow_right,
                                                          color: Color(
                                                              0xFF353B50)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Body trim
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
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      8.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Text(
                                                      'Body trim',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .5,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: AutoSizeText(
                                                            dataSnapshot
                                                                .data!
                                                                .car!
                                                                .about!
                                                                .carBodyTrim!,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF353B50),
                                                            ),
                                                            maxLines: 4,
                                                            textAlign:
                                                                TextAlign.right,
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                          Icons
                                                              .keyboard_arrow_right,
                                                          color: Color(
                                                              0xFF353B50)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Style
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
                                              borderRadius:
                                                  new BorderRadius.circular(
                                                      8.0),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Text(
                                                      'Style',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Container(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .5,
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: AutoSizeText(
                                                            dataSnapshot
                                                                .data!
                                                                .car!
                                                                .about!
                                                                .style!,
                                                            maxLines: 4,
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF353B50),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                          Icons
                                                              .keyboard_arrow_right,
                                                          color: Color(
                                                              0xFF353B50)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 35),
                            // Notes header
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Text(
                                          'Personalize your listing',
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
                            SizedBox(height: 10),
                            // Notes input
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
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Text(
                                                    'Vehicle description (optional)',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(0xFF371D32),
                                                    ),
                                                  ),
                                                  // Text(
                                                  //   dataSnapshot
                                                  //           .data
                                                  //           .car
                                                  //           .about
                                                  //           .vehicleDescription
                                                  //           .length
                                                  //           .toString() +
                                                  //       '/500',
                                                  //   style: TextStyle(
                                                  //     fontFamily: 'Urbanist',
                                                  //     fontSize: 14,
                                                  //     color: Color(0xFF353B50),
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                              Column(
                                                children: <Widget>[
                                                  TextFormField(
                                                    textInputAction:
                                                        TextInputAction.done,
                                                    initialValue: dataSnapshot
                                                        .data!
                                                        .car!
                                                        .about!
                                                        .vehicleDescription,
                                                    onChanged: (value) {
                                                      dataSnapshot
                                                              .data!
                                                              .car!
                                                              .about!
                                                              .vehicleDescription =
                                                          value;
                                                      setAboutCarBloc
                                                          .changedCarData
                                                          .call(dataSnapshot
                                                              .data!);
                                                    },
                                                    minLines: 1,
                                                    maxLines: 5,
                                                    maxLength: 5000,
                                                    // maxLengthEnforced: true,
                                                    keyboardType: TextInputType
                                                        .visiblePassword,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText:
                                                          'You can entice guests to book your vehicle by providing more information, such as “very economical, fun to drive, etc.”',
                                                      hintStyle: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          fontStyle:
                                                              FontStyle.italic),
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
                            SizedBox(height: 35),
                            // vehicle location
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Text(
                                          'Where is your vehicle located?',
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
                            // Text
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Text(
                                          'Enter the address where you would like your guests to pickup and return your vehicle. This information is visible only to Guests who have successfully booked your vehicle.',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            // Google map
                            Container(
                              height: 400,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8)),
                                child: Stack(
                                  children: <Widget>[
                                    GoogleMap(
                                      myLocationButtonEnabled: false,
                                      myLocationEnabled: false,
                                      mapToolbarEnabled: false,
                                      zoomGesturesEnabled: true,
                                      zoomControlsEnabled: true,
                                      scrollGesturesEnabled: true,
                                      gestureRecognizers: <Factory<
                                          OneSequenceGestureRecognizer>>[
                                        new Factory<
                                            OneSequenceGestureRecognizer>(
                                          () => new EagerGestureRecognizer(),
                                        ),
                                      ].toSet(),
                                      initialCameraPosition:
                                          _googleMapFlutter.CameraPosition(
                                        target: _googleMapFlutter.LatLng(
                                            dataSnapshot.data!.car!.about!
                                                .location!.latLng!.latitude!,
                                            dataSnapshot.data!.car!.about!
                                                .location!.latLng!.longitude!),
                                        zoom: 14.4746,
                                      ),
                                      mapType: MapType.normal,
                                      onMapCreated: (GoogleMapController
                                          controller) async {
                                        _mapController.complete(controller);
                                      },
                                      /*onTap: (latLong) {
                                        setAboutCarBloc.setLocation(latLong, dataSnapshot.data);
                                        print('tell us about your car: $latLong ${dataSnapshot.data}');
                                        AddressUtils.getAddress(latLong.latitude, latLong.longitude).then((value) {
                                            dataSnapshot.data!.car!.about!.location!.address = value;
                                            dataSnapshot.data!.car!.about!.location!.formattedAddress = value;
                                            setAboutCarBloc.changedCarData.call(dataSnapshot.data);
                                          });
                                      },*/
                                      markers: this.myMarker(dataSnapshot),
                                    ),
                                    Positioned(
                                      top: 15,
                                      right: 15,
                                      left: 15,
                                      child: SearchMapPlaceWidget(
                                        //TODO
                                        /*placeholder:
                                        dataSnapshot.hasData && dataSnapshot.data!=null && dataSnapshot.data!.car!.about!.location!.formattedAddress!=null && dataSnapshot.data!.car!.about!.location!.formattedAddress!=''?'${dataSnapshot.data!.car!.about!.location!.formattedAddress}':
                                        '${dataSnapshot.data!.car!.about!.location!.address}',*/
                                        placeholder: dataSnapshot.hasData &&
                                                dataSnapshot.data != null &&
                                                dataSnapshot.data!.car!.about!
                                                        .location!.address !=
                                                    null
                                            ? '${dataSnapshot.data!.car!.about!.location!.address}'
                                            : "",
                                        iconColor: Color(0xff371D32),
                                        bgColor: Colors.white,
                                        textColor: Color(0xff371D32),
                                        icon: Icons.search,
                                        // apiKey: "AIzaSyALNTeZ3VJjy58ogMajutj_m_kmDwPAQDA",
                                        apiKey: googleApiKeyUrl,
                                        onSelected: (place) async {
                                          //TODO
                                          final geolocation =
                                              await place.geolocation;
                                          final GoogleMapController controller =
                                              await _mapController.future;
                                          setAboutCarBloc.setLocation(
                                              geolocation!.coordinates,
                                              dataSnapshot.data!);
                                          controller.animateCamera(
                                              CameraUpdate.newLatLng(
                                                  geolocation.coordinates));
                                          controller.animateCamera(
                                              CameraUpdate.newLatLngBounds(
                                                  geolocation.bounds, 0));
                                          dataSnapshot
                                              .data!
                                              .car!
                                              .about!
                                              .location!
                                              .address = place.description;
                                          dataSnapshot.data!.car!.about!
                                                  .location!.formattedAddress =
                                              geolocation
                                                  .fullJSON["formatted_address"]
                                                  .toString();
                                          setAboutCarBloc.changedCarData
                                              .call(dataSnapshot.data!);
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            // Location note
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              color: Color(0xFFF2F2F2),
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Text(
                                                      'Location notes (optional)',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                    // Text(
                                                    //   dataSnapshot.data!.car!.about!.location!.notes.length.toString() +
                                                    //       '/500',
                                                    //   style: TextStyle(
                                                    //     fontFamily: 'Urbanist',
                                                    //     fontSize: 14,
                                                    //     color:
                                                    //         Color(0xFF353B50),
                                                    //   ),
                                                    // ),
                                                  ],
                                                ),
                                                Column(
                                                  children: <Widget>[
                                                    TextFormField(
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      initialValue: dataSnapshot
                                                          .data!
                                                          .car!
                                                          .about!
                                                          .location!
                                                          .notes,
                                                      onChanged: (noteValue) {
                                                        dataSnapshot
                                                            .data!
                                                            .car!
                                                            .about!
                                                            .location!
                                                            .notes = noteValue;
                                                        setAboutCarBloc
                                                            .changedCarData
                                                            .call(dataSnapshot
                                                                .data!);
                                                      },
                                                      minLines: 1,
                                                      maxLines: 3,
                                                      maxLength: 500,
                                                      // maxLengthEnforced: true,
                                                      keyboardType:
                                                          TextInputType
                                                              .visiblePassword,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText:
                                                            'Add notes how to locate your car. For example, what’s the access code to the garage or what’s the underground parking level?',
                                                        hintStyle: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 14,
                                                            fontStyle: FontStyle
                                                                .italic),
                                                        // counterText: '',
                                                      ),
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
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Section header
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Text(
                                          'I’m listing a vehicle owned by',
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
                            SizedBox(height: 20),
                            // Select
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
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                          child: Column(
                                            children: <Widget>[
                                              GestureDetector(
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      height: 26,
                                                      width: 26,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Colors.transparent,
                                                        border: Border.all(
                                                          color:
                                                              Color(0xFF353B50),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(7.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: dataSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .about!
                                                                        .carOwnedBy ==
                                                                    "Myself"
                                                                ? Color(
                                                                    0xFFFF8F62)
                                                                : Colors
                                                                    .transparent,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          Text(
                                                            'Owned or managed by myself',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: purpose == 3
                                                    ? () => {}
                                                    : () {
                                                        dataSnapshot
                                                                .data!
                                                                .car!
                                                                .about!
                                                                .carOwnedBy =
                                                            "Myself";
                                                        setAboutCarBloc
                                                            .changedCarData(
                                                                dataSnapshot
                                                                    .data!);
                                                      },
                                              ),
                                              SizedBox(height: 15),
                                              GestureDetector(
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      height: 26,
                                                      width: 26,
                                                      decoration: BoxDecoration(
                                                        shape: BoxShape.circle,
                                                        color:
                                                            Colors.transparent,
                                                        border: Border.all(
                                                          color:
                                                              Color(0xFF353B50),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(7.0),
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: dataSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .about!
                                                                        .carOwnedBy ==
                                                                    "Business"
                                                                ? Color(
                                                                    0xFFFF8F62)
                                                                : Colors
                                                                    .transparent,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          SizedText(
                                                            deviceWidth:
                                                                SizeConfig
                                                                    .deviceWidth!,
                                                            textWidthPercentage:
                                                                0.75,
                                                            text:
                                                                'This vehicle is owned by a business and is NOT insured on an OAP #4 Garage Policy.',
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 16,
                                                            textColor: Color(
                                                                0xFF371D32),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: purpose == 3
                                                    ? () => {}
                                                    : () {
                                                        dataSnapshot
                                                                .data!
                                                                .car!
                                                                .about!
                                                                .carOwnedBy =
                                                            "Business";
                                                        setAboutCarBloc
                                                            .changedCarData(
                                                                dataSnapshot
                                                                    .data!);
                                                      },
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

                            SizedBox(height: 20),

                            /// Salvage
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
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              GestureDetector(
                                                child: Row(
                                                  children: <Widget>[
                                                    Container(
                                                      height: 26,
                                                      width: 26,
                                                      decoration: BoxDecoration(
                                                        shape:
                                                            BoxShape.rectangle,
                                                        color:
                                                            Colors.transparent,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6.0),
                                                        border: Border.all(
                                                          color:
                                                              Color(0xFF353B50),
                                                          width: 2,
                                                        ),
                                                      ),
                                                      child: Icon(
                                                        Icons.check,
                                                        size: 22,
                                                        color: dataSnapshot
                                                                .data!
                                                                .car!
                                                                .about!
                                                                .neverBrandedOrSalvageTitle!
                                                            ? Color(0xFFFF8F68)
                                                            : Colors
                                                                .transparent,
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text(
                                                            'This vehicle has never had a branded or salvage title',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                onTap: () {
                                                  dataSnapshot.data!.car!.about!
                                                          .neverBrandedOrSalvageTitle =
                                                      !dataSnapshot
                                                          .data!
                                                          .car!
                                                          .about!
                                                          .neverBrandedOrSalvageTitle!;
                                                  setAboutCarBloc
                                                      .changedCarData(
                                                          dataSnapshot.data!);
                                                },
                                              ),
                                              SizedBox(height: 12),
                                              SizedBox(
                                                child: Text(
                                                  'A salvage title is a form of vehicle title branding, which notes that the vehicle has been damaged and/or deemed a total loss by an insurance company that paid a claim on it.',
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
                              children: <Widget>[
                                StreamBuilder<int>(
                                    stream: setAboutCarBloc.progressIndicator,
                                    builder:
                                        (context, progressIndicatorSnapshot) {
                                      return Expanded(
                                        child: Column(
                                          children: <Widget>[
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor:
                                                      Color(0xFFFF8F62),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                ),
                                                onPressed: progressIndicatorSnapshot
                                                                .data ==
                                                            1 ||
                                                        setAboutCarBloc
                                                            .checkButtonDisability(
                                                                dataSnapshot
                                                                    .data!)
                                                    ? null
                                                    : () async {
                                                        setAboutCarBloc
                                                            .changedProgressIndicator
                                                            .call(1);
                                                        //TODO
                                                        /*String address =
                                                            await AddressUtils.getAddress(dataSnapshot.data!.car!.about!.location!.latLng!.latitude, dataSnapshot.data!.car!.about!.location!.latLng!.longitude);*/

                                                        Address address =
                                                            await addressLine(
                                                                dataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .about!
                                                                    .location!
                                                                    .latLng!
                                                                    .latitude!,
                                                                dataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .about!
                                                                    .location!
                                                                    .latLng!
                                                                    .longitude!);

                                                        if (dataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .about!
                                                                    .location!
                                                                    .address ==
                                                                null ||
                                                            dataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .about!
                                                                    .location!
                                                                    .address ==
                                                                "") {
                                                          dataSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .about!
                                                                  .location!
                                                                  .address =
                                                              address
                                                                  .addressLine;
                                                        }
                                                        dataSnapshot
                                                                .data!
                                                                .car!
                                                                .about!
                                                                .location!
                                                                .locality =
                                                            address.locality;
                                                        dataSnapshot
                                                                .data!
                                                                .car!
                                                                .about!
                                                                .location!
                                                                .region =
                                                            address.countryName;
                                                        dataSnapshot
                                                                .data!
                                                                .car!
                                                                .about!
                                                                .location!
                                                                .postalCode =
                                                            address.postalCode;
                                                        if (dataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .about!
                                                                    .location!
                                                                    .formattedAddress ==
                                                                null ||
                                                            dataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .about!
                                                                    .location!
                                                                    .formattedAddress ==
                                                                "") {
                                                          dataSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .about!
                                                                  .location!
                                                                  .formattedAddress =
                                                              address
                                                                  .addressLine;
                                                        }

                                                        var res =
                                                            await setAbout(
                                                                dataSnapshot
                                                                    .data!);
                                                        // print('res${res.body}');

                                                        var arguments =
                                                            CreateCarResponse
                                                                .fromJson(json
                                                                    .decode(res
                                                                        .body!));
                                                        AppEventsUtils.logEvent(
                                                            "view_vehicle_listing",
                                                            params: {
                                                              "carType":
                                                                  arguments
                                                                      .car!
                                                                      .about!
                                                                      .carType,
                                                              "carMake":
                                                                  arguments
                                                                      .car!
                                                                      .about!
                                                                      .make,
                                                              "carModel":
                                                                  arguments
                                                                      .car!
                                                                      .about!
                                                                      .model,
                                                            });
                                                        if (res.statusCode ==
                                                            200) {
                                                          if (pushNeeded) {
                                                            Navigator.pushNamed(
                                                                context,
                                                                pushRouteName!,
                                                                arguments: {
                                                                  'carResponse':
                                                                      arguments,
                                                                  'purpose':
                                                                      purpose
                                                                });
                                                          } else {
                                                            Navigator.pop(
                                                                context,
                                                                arguments);
                                                          }
                                                        } else {
                                                          print(json.decode(
                                                              res.body!));
                                                          // print(res.body!);
                                                        }
                                                      },
                                                child: progressIndicatorSnapshot
                                                            .data ==
                                                        0
                                                    ? Text(
                                                        'Next',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white),
                                                      )
                                                    : SizedBox(
                                                        height: 18.0,
                                                        width: 18.0,
                                                        child:
                                                            new CircularProgressIndicator(
                                                                strokeWidth:
                                                                    2.5),
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          height: 220,
                          width: MediaQuery.of(context).size.width,
                          child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 12.0, right: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10)),
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
                              width: MediaQuery.of(context).size.width / 3,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300],
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
                          width: MediaQuery.of(context).size.width,
                          child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 14,
                              width: MediaQuery.of(context).size.width / 2,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300],
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
                          width: MediaQuery.of(context).size.width,
                          child: Shimmer.fromColors(
                              baseColor: Colors.grey.shade300,
                              highlightColor: Colors.grey.shade100,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              height: 14,
                              width: MediaQuery.of(context).size.width / 2,
                              child: Shimmer.fromColors(
                                  baseColor: Colors.grey.shade300,
                                  highlightColor: Colors.grey.shade100,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 16.0, right: 16),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ));
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Tell Us About Your Car"});
  }

  Set<Marker> myMarker(AsyncSnapshot<CreateCarResponse> dataSnapshot) {
    var location = _googleMapFlutter.LatLng(
        dataSnapshot.data!.car!.about!.location!.latLng!.latitude!,
        dataSnapshot.data!.car!.about!.location!.latLng!.longitude!);
    var _initialCamera = _googleMapFlutter.CameraPosition(
      target: location,
      zoom: 14.4746,
    );
    _markers.clear();
    _markers.add(Marker(
      markerId: MarkerId(_initialCamera.toString()),
      position: location,
      icon: BitmapDescriptor.defaultMarker,
    ));

    return _markers;
  }

  void openYearPicker(context, AsyncSnapshot<CreateCarResponse> dataSnapshot) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) => Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.65,
              child: yearPicker.YearPicker(
                selectedDate: DateTime(int.parse(
                    dataSnapshot.data!.car!.about!.year == ''
                        ? DateTime.now().year.toString()
                        : dataSnapshot.data!.car!.about!.year!)),
                firstDate: DateTime(DateTime.now().year - 14),
                lastDate: DateTime(DateTime.now().year),
                onChanged: (val) {
                  setAboutCarBloc.changeYear(val, dataSnapshot.data!);
                  Navigator.pop(context);
                },
              ),
            ));
  }

  static Future<Address> addressLine(double latitude, double longitude) async {
    final coordinates = new Coordinates(latitude, longitude);
    // var addresses = await Geocoder.google(googleApiKeyUrl).findAddressesFromCoordinates(coordinates);
    var addresses = await await GoogleGeocoding(
      googleApiKeyUrl,
      language: 'en',
    ).findAddressesFromCoordinates(coordinates);
    Address first = addresses.first;
    return first;
  }
}
