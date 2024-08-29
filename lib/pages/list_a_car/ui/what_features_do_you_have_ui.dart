import 'package:flutter/material.dart';
import 'package:ridealike/pages/list_a_car/bloc/car_features_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/utils/empty_cheker.dart';
import 'package:ridealike/widgets/fuel_type_chip.dart';
import 'package:ridealike/widgets/sized_text.dart';

import '../../../utils/app_events/app_events_utils.dart';

class WhatFeaturesYouHaveUi extends StatefulWidget {
  @override
  State createState() => WhatFeaturesYouHaveUiState();
}

class WhatFeaturesYouHaveUiState extends State<WhatFeaturesYouHaveUi> {
  var carFeaturesBloc = CarFeaturesBloc();
  bool exitPressed = false;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "What Features Do You Have"});
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceFontSize = MediaQuery.of(context).textScaleFactor;
    Map routeData = ModalRoute.of(context)!.settings.arguments as Map;
    CreateCarResponse createCarResponse = CreateCarResponse.fromJson(
        (routeData['carResponse'] as CreateCarResponse).toJson());

    var purpose = routeData['purpose'];
    bool pushNeeded = routeData['PUSH'] == null ? false : routeData['PUSH'];
    String? pushRouteName = routeData['ROUTE_NAME'];
//    CreateCarResponse createCarResponse = ModalRoute.of(context).settings.arguments;
    if (createCarResponse.car!.features!.completed == false) {
      if (isEmpty(createCarResponse.car!.features!.numberOfSeats!)) {
        createCarResponse.car!.features!.numberOfSeats = 5;
      }
      if (isEmpty(createCarResponse.car!.features!.numberOfDoors!)) {
        createCarResponse.car!.features!.numberOfDoors = 4;
      }
      if (isEmptyString(createCarResponse.car!.features!.fuelType!)) {
        createCarResponse.car!.features!.fuelType = '87 regular';
      }
      if (isEmptyString(createCarResponse.car!.features!.transmission!)) {
        createCarResponse.car!.features!.transmission = 'automatic';
      }
      if (isEmptyString(createCarResponse.car!.features!.greenFeature!)) {
        createCarResponse.car!.features!.greenFeature = 'none';
      }
      if (isEmptyString(createCarResponse.car!.features!.truckBoxSize!)) {
        // createCarResponse.car!.features!.truckBoxSize = 'STANDARD';
        createCarResponse.car!.features!.truckBoxSize = 'standard';
      }
    }

    carFeaturesBloc.changedCarFeaturesData.call(createCarResponse);
    carFeaturesBloc.changedProgressIndicator.call(0);

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            if (pushNeeded) {
              Navigator.pushNamed(context, pushRouteName!, arguments: {
                'carResponse': routeData['carResponse'],
                'purpose': purpose
              });
            } else {
              Navigator.pop(context);
            }
//            Navigator.pushNamed(
//              context,
//              '/add_photos_to_your_listing',
////              arguments: receivedData
//            );
          },
        ),
        centerTitle: true,
        title: Text(
          '3/6',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: Color(0xff371D32),
          ),
        ),
        actions: <Widget>[
          StreamBuilder<CreateCarResponse>(
              stream: carFeaturesBloc.carFeaturesData,
              builder: (context, carFeaturesDataSnapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        if (!exitPressed) {
                          exitPressed = true;
                          var response = await carFeaturesBloc.setCarFeatures(
                              carFeaturesDataSnapshot.data!,
                              completed: false,
                              saveAndExit: true);
                          Navigator.pushNamed(context, '/dashboard_tab',
                              arguments: response);
//                      Navigator.pushNamed(context, '/dashboard_tab');
                        }
                      },
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(right: 16),
                          child: createCarResponse.car!.features!.completed!
                              ? Text('')
                              : Text(
                                  'Save & Exit',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xffFF8F68),
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
          stream: carFeaturesBloc.carFeaturesData,
          builder: (context, carFeaturesDataSnapshot) {
            return carFeaturesDataSnapshot.hasData &&
                    carFeaturesDataSnapshot.data! != null
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Container(
                                          child: Text(
                                            'Select vehicle\'s features',
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
                                Image.asset('icons/Star-Features.png'),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Header text
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        'We have preselected features based on your VIN, but you can make changes or additions below.',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF353B50),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Fuel type
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              child: Container(
                                width: double.infinity,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Text(
                                        'Fuel type',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    deviceFontSize > 1.15
                                        ? Column(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: FuelTypeChip(
                                                        onTap: purpose == 3 || carFeaturesDataSnapshot
                                                            .data!
                                                            .car!
                                                    .features!
                                                    .greenFeature == 'electric'
                                                            ? () => {}
                                                            : () {
                                                                carFeaturesDataSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .features!
                                                                        .fuelType =
                                                                    '87 regular';
                                                                carFeaturesBloc
                                                                    .changedCarFeaturesData
                                                                    .call(carFeaturesDataSnapshot
                                                                        .data!);
                                                              },
                                                        boxColor: carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .fuelType ==
                                                                '87 regular'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        text: '87 \nREGULAR',
                                                        textColor: carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .fuelType ==
                                                                '87 regular'
                                                            ? Color(0xFFFFFFFF)
                                                            : Color(0xFF353B50)
                                                                .withOpacity(
                                                                    0.5),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: FuelTypeChip(
                                                        onTap: purpose == 3 || carFeaturesDataSnapshot
                                                            .data!
                                                            .car!
                                                            .features!
                                                            .greenFeature == 'electric'
                                                            ? () => {}
                                                            : () {
                                                                carFeaturesDataSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .features!
                                                                        .fuelType =
                                                                    '91-94 premium';
                                                                carFeaturesBloc
                                                                    .changedCarFeaturesData
                                                                    .call(carFeaturesDataSnapshot
                                                                        .data!);
                                                              },
                                                        boxColor: carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .fuelType ==
                                                                '91-94 premium'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        text: '91-94 \nPREMIUM',
                                                        textColor: carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .fuelType ==
                                                                '91-94 premium'
                                                            ? Color(0xFFFFFFFF)
                                                            : Color(0xFF353B50)
                                                                .withOpacity(
                                                                    0.5),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 16.0,
                                                        vertical: 8),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: FuelTypeChip(
                                                        onTap: purpose == 3 || carFeaturesDataSnapshot
                                                            .data!
                                                            .car!
                                                            .features!
                                                            .greenFeature == 'electric'
                                                            ? () => {}
                                                            : () {
                                                                carFeaturesDataSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .features!
                                                                        .fuelType =
                                                                    'diesel';
                                                                carFeaturesBloc
                                                                    .changedCarFeaturesData
                                                                    .call(carFeaturesDataSnapshot
                                                                        .data!);
                                                              },
                                                        boxColor: carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .fuelType ==
                                                                'diesel'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        text: 'DIESEL',
                                                        textColor: carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .fuelType ==
                                                                'diesel'
                                                            ? Color(0xFFFFFFFF)
                                                            : Color(0xFF353B50)
                                                                .withOpacity(
                                                                    0.5),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      child: FuelTypeChip(
                                                        onTap: purpose == 3
                                                            ? () => {}
                                                            : () {
                                                                carFeaturesDataSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .features!
                                                                        .fuelType =
                                                                    'electric';
                                                                carFeaturesBloc
                                                                    .changedCarFeaturesData
                                                                    .call(carFeaturesDataSnapshot
                                                                        .data!);
                                                              },
                                                        boxColor: carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .fuelType ==
                                                                'electric'
                                                            ? Color(0xFFFF8F62)
                                                            : Color(0xFFE0E0E0)
                                                                .withOpacity(
                                                                    0.5),
                                                        text: 'ELECTRIC',
                                                        textColor: carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .fuelType ==
                                                                'electric'
                                                            ? Color(0xFFFFFFFF)
                                                            : Color(0xFF353B50)
                                                                .withOpacity(
                                                                    0.5),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: <Widget>[
                                              FuelTypeChip(
                                                onTap: purpose == 3 || carFeaturesDataSnapshot
                                                    .data!
                                                    .car!
                                                    .features!
                                                    .greenFeature == 'electric'
                                                    ? () => {}
                                                    : () {
                                                        carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType =
                                                            '87 regular';
                                                        carFeaturesBloc
                                                            .changedCarFeaturesData
                                                            .call(
                                                                carFeaturesDataSnapshot
                                                                    .data!);
                                                      },
                                                boxColor:
                                                    carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType ==
                                                            '87 regular'
                                                        ? Color(0xFFFF8F62)
                                                        : Color(0xFFE0E0E0)
                                                            .withOpacity(0.5),
                                                text: '87 \nREGULAR',
                                                textColor:
                                                    carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType ==
                                                            '87 regular'
                                                        ? Color(0xFFFFFFFF)
                                                        : Color(0xFF353B50)
                                                            .withOpacity(0.5),
                                              ),
                                              FuelTypeChip(
                                                onTap: purpose == 3 || carFeaturesDataSnapshot
                                                    .data!
                                                    .car!
                                                    .features!
                                                    .greenFeature == 'electric'
                                                    ? () => {}
                                                    : () {
                                                        carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType =
                                                            '91-94 premium';
                                                        carFeaturesBloc
                                                            .changedCarFeaturesData
                                                            .call(
                                                                carFeaturesDataSnapshot
                                                                    .data!);
                                                      },
                                                boxColor:
                                                    carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType ==
                                                            '91-94 premium'
                                                        ? Color(0xFFFF8F62)
                                                        : Color(0xFFE0E0E0)
                                                            .withOpacity(0.5),
                                                text: '91-94 \nPREMIUM',
                                                textColor:
                                                    carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType ==
                                                            '91-94 premium'
                                                        ? Color(0xFFFFFFFF)
                                                        : Color(0xFF353B50)
                                                            .withOpacity(0.5),
                                              ),
                                              FuelTypeChip(
                                                onTap: purpose == 3 || carFeaturesDataSnapshot
                                                    .data!
                                                    .car!
                                                    .features!
                                                    .greenFeature == 'electric'
                                                    ? () => {}
                                                    : () {
                                                        carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType =
                                                            'diesel';
                                                        carFeaturesBloc
                                                            .changedCarFeaturesData
                                                            .call(
                                                                carFeaturesDataSnapshot
                                                                    .data!);
                                                      },
                                                boxColor:
                                                    carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType ==
                                                            'diesel'
                                                        ? Color(0xFFFF8F62)
                                                        : Color(0xFFE0E0E0)
                                                            .withOpacity(0.5),
                                                text: 'DIESEL',
                                                textColor:
                                                    carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType ==
                                                            'diesel'
                                                        ? Color(0xFFFFFFFF)
                                                        : Color(0xFF353B50)
                                                            .withOpacity(0.5),
                                              ),
                                              FuelTypeChip(
                                                onTap: purpose == 3
                                                    ? () => {}
                                                    : () {
                                                        carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType =
                                                            'electric';
                                                        carFeaturesBloc
                                                            .changedCarFeaturesData
                                                            .call(
                                                                carFeaturesDataSnapshot
                                                                    .data!);
                                                      },
                                                boxColor:
                                                    carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType ==
                                                            'electric'
                                                        ? Color(0xFFFF8F62)
                                                        : Color(0xFFE0E0E0)
                                                            .withOpacity(0.5),
                                                text: 'ELECTRIC',
                                                textColor:
                                                    carFeaturesDataSnapshot
                                                                .data!
                                                                .car!
                                                                .features!
                                                                .fuelType ==
                                                            'electric'
                                                        ? Color(0xFFFFFFFF)
                                                        : Color(0xFF353B50)
                                                            .withOpacity(0.5),
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            // Transmission
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
                                                  BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(children: [
                                                        Text(
                                                          'Transmission',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 16,
                                                            color: Color(
                                                                0xFF371D32),
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          elevation: 0.0,
                                                          padding: EdgeInsets.all(
                                                              16.0),
                                                          backgroundColor: carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .transmission ==
                                                              'automatic'
                                                              ? Color(0xFFFF8F62)
                                                              : Color(0xFFE0E0E0)
                                                              .withOpacity(
                                                              0.5),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0)),


                                                        ),
                                                        onPressed: purpose == 3
                                                            ? () => {}
                                                            : () {
                                                                carFeaturesDataSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .features!
                                                                        .transmission =
                                                                    'automatic';
                                                                carFeaturesBloc
                                                                    .changedCarFeaturesData
                                                                    .call(carFeaturesDataSnapshot
                                                                        .data!);
                                                              },
                                                         child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'AUTOMATIC',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: carFeaturesDataSnapshot.data!.car!.features!.transmission ==
                                                                            'automatic'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
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
                                                          backgroundColor: carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .transmission ==
                                                              'manual'
                                                              ? Color(0xFFFF8F62)
                                                              : Color(0xFFE0E0E0)
                                                              .withOpacity(
                                                              0.5),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0)),

                                                          padding: EdgeInsets.all(
                                                            16.0),),
                                                        onPressed: purpose == 3
                                                            ? () => {}
                                                            : () {
                                                                carFeaturesDataSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .features!
                                                                        .transmission =
                                                                    'manual';
                                                                carFeaturesBloc
                                                                    .changedCarFeaturesData
                                                                    .call(carFeaturesDataSnapshot
                                                                        .data!);
                                                              },
                                                                 child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'MANUAL',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: carFeaturesDataSnapshot.data!.car!.features!.transmission ==
                                                                            'manual'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
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
                            SizedBox(height: 10),
                            // Number of doors
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
                                                  BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(children: [
                                                        Text(
                                                          'Number of doors',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 16,
                                                            color: Color(
                                                                0xFF371D32),
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                          backgroundColor: carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .numberOfDoors ==
                                                              2
                                                              ? Color(0xFFFF8F62)
                                                              : Color(0xFFE0E0E0)
                                                              .withOpacity(
                                                              0.5),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0)),

                                                          padding: EdgeInsets.all(
                                                            16.0),),
                                                        onPressed: () {
                                                          carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .numberOfDoors = 2;
                                                          carFeaturesBloc
                                                              .changedCarFeaturesData
                                                              .call(
                                                                  carFeaturesDataSnapshot
                                                                      .data!);
                                                        },
                                                           child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  '2',
                                                                  style:
                                                                      TextStyle(

                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: carFeaturesDataSnapshot.data!.car!.features!.numberOfDoors ==
                                                                            2
                                                                        ? Color(
                                                                            0xFFFFFFFF)
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
                                                          backgroundColor: carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .numberOfDoors ==
                                                              4
                                                              ? Color(0xFFFF8F62)
                                                              : Color(0xFFE0E0E0)
                                                              .withOpacity(
                                                              0.5),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0)),

                                                          padding: EdgeInsets.all(
                                                            16.0),),

                                                        onPressed: () {
                                                          carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .numberOfDoors = 4;
                                                          carFeaturesBloc
                                                              .changedCarFeaturesData
                                                              .call(
                                                                  carFeaturesDataSnapshot
                                                                      .data!);
                                                        },
                                                              child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  '4',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: carFeaturesDataSnapshot.data!.car!.features!.numberOfDoors ==
                                                                            4
                                                                        ? Color(
                                                                            0xFFFFFFFF)
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
                            SizedBox(height: 10),
                            // Number of seats
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
                                            borderRadius:
                                                new BorderRadius.circular(8.0),
                                          ),
                                          child: Container(
                                            child: Column(
                                              children: <Widget>[
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 16.0,
                                                      bottom: 8.0,
                                                      left: 16.0,
                                                      top: 16.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Text(
                                                        'Number of seats',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 16,
                                                          color:
                                                              Color(0xFF371D32),
                                                        ),
                                                      ),
                                                      Text(
                                                        double.parse(
                                                                carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .numberOfSeats
                                                                    .toString())
                                                            .round()
                                                            .toString(),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
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
                                                            thumbColor: Color(
                                                                0xffFFFFFF),
                                                            trackShape:
                                                                RoundedRectSliderTrackShape(),
                                                            trackHeight: 4.0,
                                                            activeTrackColor:
                                                                Color(
                                                                    0xffFF8F62),
                                                            inactiveTrackColor:
                                                                Color(
                                                                    0xFFE0E0E0),
                                                            tickMarkShape:
                                                                RoundSliderTickMarkShape(
                                                                    tickMarkRadius:
                                                                        4.0),
                                                            activeTickMarkColor:
                                                                Color(
                                                                    0xffFF8F62),
                                                            inactiveTickMarkColor:
                                                                Color(
                                                                    0xFFE0E0E0),
                                                            thumbShape:
                                                                RoundSliderThumbShape(
                                                                    enabledThumbRadius:
                                                                        14.0),
                                                          ),
                                                          child: Slider(
                                                            min: 2.0,
                                                            max: 8.0,
                                                            onChanged:
                                                                purpose == 3
                                                                    ? (values) =>
                                                                        {}
                                                                    : (values) {
                                                                        carFeaturesDataSnapshot
                                                                            .data!
                                                                            .car!
                                                                            .features!
                                                                            .numberOfSeats = values.toInt();
                                                                        carFeaturesBloc
                                                                            .changedCarFeaturesData
                                                                            .call(carFeaturesDataSnapshot.data!);
                                                                      },
                                                            value: double.parse(
                                                                carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .numberOfSeats
                                                                    .toString()),
                                                            divisions: 6,
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
                            SizedBox(height: 10),
                            // Truck box size
                            carFeaturesDataSnapshot.data!.car!.about!.carType ==
                                    'Pickup Truck'
                                ? Container(
                                    decoration: BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Container(
                                                child: Row(children: [
                                                  Text(
                                                    'Truck box size',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(0xFF371D32),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    elevation: 0.0,
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 16.0,
                                                        horizontal: 8),
                                                    backgroundColor: carFeaturesDataSnapshot
                                                        .data!
                                                        .car!
                                                        .features!
                                                        .truckBoxSize ==
                                                        'short'
                                                        ? Color(0xFFFF8F62)
                                                        : Color(0xFFE0E0E0)
                                                        .withOpacity(0.5),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),


                                                  ),
                                                  onPressed: () {
                                                    if (carFeaturesDataSnapshot
                                                            .data!
                                                            .car!
                                                            .features!
                                                            .truckBoxSize !=
                                                        "short") {
                                                      carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .truckBoxSize =
                                                          'short';
                                                    } else {
                                                      carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .truckBoxSize = '';
                                                    }

                                                    carFeaturesBloc
                                                        .changedCarFeaturesData
                                                        .call(
                                                            carFeaturesDataSnapshot
                                                                .data!);
                                                  },
                                                     child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            'SHORT',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 12,
                                                              color: carFeaturesDataSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .features!
                                                                          .truckBoxSize ==
                                                                      'short'
                                                                  ? Color(
                                                                      0xFFFFFFFF)
                                                                  : Color(0xFF353B50)
                                                                      .withOpacity(
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
                                                  style:ElevatedButton.styleFrom(
                                                    elevation: 0.0,
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 16.0,
                                                        horizontal: 8),
                                                    backgroundColor: carFeaturesDataSnapshot
                                                        .data!
                                                        .car!
                                                        .features!
                                                        .truckBoxSize ==
                                                        'standard'
                                                        ? Color(0xFFFF8F62)
                                                        : Color(0xFFE0E0E0)
                                                        .withOpacity(0.5),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),


                                                  ),
                                                  onPressed: () {
                                                    if (carFeaturesDataSnapshot
                                                            .data!
                                                            .car!
                                                            .features!
                                                            .truckBoxSize !=
                                                        'standard') {
                                                      carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .truckBoxSize =
                                                          'standard';
                                                    } else {
                                                      carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .truckBoxSize = '';
                                                    }
                                                    carFeaturesBloc
                                                        .changedCarFeaturesData
                                                        .call(
                                                            carFeaturesDataSnapshot
                                                                .data!);
                                                  },
                                                   child: SizedText(
                                                    deviceWidth: deviceWidth,
                                                    textWidthPercentage: 0.3,
                                                    text: 'STANDARD',
                                                    fontFamily:
                                                        'Urbanist',
                                                    fontSize: 12,
                                                    textColor:
                                                        carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .truckBoxSize ==
                                                                'standard'
                                                            ? Color(0xFFFFFFFF)
                                                            : Color(0xFF353B50)
                                                                .withOpacity(
                                                                    0.5),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(

                                                    elevation: 0.0,
                                                    padding: EdgeInsets.symmetric(
                                                        vertical: 16.0,
                                                        horizontal: 8),
                                                    backgroundColor: carFeaturesDataSnapshot
                                                        .data!
                                                        .car!
                                                        .features!
                                                        .truckBoxSize ==
                                                        'long'
                                                        ? Color(0xFFFF8F62)
                                                        : Color(0xFFE0E0E0)
                                                        .withOpacity(0.5),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),


                                                  ),
                                                  onPressed: () {
                                                    if (carFeaturesDataSnapshot
                                                            .data!
                                                            .car!
                                                            .features!
                                                            .truckBoxSize !=
                                                        'long') {
                                                      carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .truckBoxSize =
                                                          'long';
                                                    } else {
                                                      carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .truckBoxSize = '';
                                                    }
                                                    carFeaturesBloc
                                                        .changedCarFeaturesData
                                                        .call(
                                                            carFeaturesDataSnapshot
                                                                .data!);
                                                  },
                                                    child: Column(
                                                    children: <Widget>[
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          Text(
                                                            'LONG',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 12,
                                                              color: carFeaturesDataSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .features!
                                                                          .truckBoxSize ==
                                                                      'long'
                                                                  ? Color(
                                                                      0xFFFFFFFF)
                                                                  : Color(0xFF353B50)
                                                                      .withOpacity(
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
                                  )
                                : Container(),
                            // GreenFeature
                            SizedBox(height:10),
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
                                                  BorderRadius.circular(8)),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.0),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(children: [
                                                        Text(
                                                          'Green feature',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 16,
                                                            color: Color(
                                                                0xFF371D32),
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  padding: EdgeInsets.all(
                                                      16.0),
                                                              backgroundColor: carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .greenFeature ==
                                                              'electric'
                                                              ? Color(0xFFFF8F62)
                                                              : Color(0xFFE0E0E0)
                                                              .withOpacity(
                                                              0.5),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0)),


                                                        ),
                                                        onPressed: carFeaturesDataSnapshot
                                                            .data!
                                                            .car!
                                                            .features!.fuelType=='electric'?() {
                                                          // carFeaturesDataSnapshot
                                                          //     .data!
                                                          //     .car!
                                                          //     .features!
                                                          //     .greenFeature ==
                                                          //     'electric'
                                                          //     ? carFeaturesDataSnapshot
                                                          //     .data!
                                                          //     .car!
                                                          //     .features!
                                                          //     .greenFeature =
                                                          // ""
                                                          //     :
                                                          carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .greenFeature =
                                                          'electric';
                                                          carFeaturesBloc
                                                              .changedCarFeaturesData
                                                              .call(
                                                                  carFeaturesDataSnapshot
                                                                      .data!);
                                                        }:(){},
                                                          child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'ELECTRIC',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: carFeaturesDataSnapshot.data!.car!.features!.greenFeature ==
                                                                            'electric'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
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
                                                        style:ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                          backgroundColor: carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .greenFeature ==
                                                              'hybrid'
                                                              ? Color(0xFFFF8F62)
                                                              : Color(0xFFE0E0E0)
                                                              .withOpacity(
                                                              0.5),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0)),

                                                          padding: EdgeInsets.all(
                                                            16.0),),
                                                        onPressed: () {
                                                          // carFeaturesDataSnapshot
                                                          //             .data!
                                                          //             .car!
                                                          //             .features!
                                                          //             .greenFeature ==
                                                          //         'hybrid'
                                                          //     ? carFeaturesDataSnapshot
                                                          //             .data!
                                                          //             .car!
                                                          //             .features!
                                                          //             .greenFeature =
                                                          //         ""
                                                          //     :
                                                          carFeaturesDataSnapshot
                                                                      .data!
                                                                      .car!
                                                                      .features!
                                                                      .greenFeature =
                                                                  'hybrid';
                                                          carFeaturesBloc
                                                              .changedCarFeaturesData
                                                              .call(
                                                                  carFeaturesDataSnapshot
                                                                      .data!);
                                                        },
                                                         child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'HYBRID',
                                                                  style:
                                                                      TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        12,
                                                                    color: carFeaturesDataSnapshot.data!.car!.features!.greenFeature ==
                                                                            'hybrid'
                                                                        ? Color(
                                                                            0xFFFFFFFF)
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
                                                        style:ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                          backgroundColor: carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .greenFeature ==
                                                              'none'
                                                              ? Color(0xFFFF8F62)
                                                              : Color(0xFFE0E0E0)
                                                              .withOpacity(
                                                              0.5),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0)),
                                                        padding: EdgeInsets.all(
                                                            16.0),),
                                                        onPressed: () {
                                                          // carFeaturesDataSnapshot
                                                          //     .data!
                                                          //     .car!
                                                          //     .features!
                                                          //     .greenFeature ==
                                                          //     'none'
                                                          //     ? carFeaturesDataSnapshot
                                                          //     .data!
                                                          //     .car!
                                                          //     .features!
                                                          //     .greenFeature =
                                                          // ""
                                                          //     :
                                                          carFeaturesDataSnapshot
                                                              .data!
                                                              .car!
                                                              .features!
                                                              .greenFeature =
                                                          'none';
                                                          carFeaturesBloc
                                                              .changedCarFeaturesData
                                                              .call(
                                                              carFeaturesDataSnapshot
                                                                  .data!);
                                                        },

                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                              children: <
                                                                  Widget>[
                                                                Text(
                                                                  'NONE',
                                                                  style:
                                                                  TextStyle(
                                                                    fontFamily:
                                                                    'Urbanist',
                                                                    fontSize:
                                                                    12,
                                                                    color: carFeaturesDataSnapshot.data!.car!.features!.greenFeature ==
                                                                        'none'
                                                                        ? Color(
                                                                        0xFFFFFFFF)
                                                                        : Color(0xFF353B50)
                                                                        .withOpacity(0.5),
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
                            // Interior
                            SizedBox(
                              width: double.maxFinite,
                              child: Text(
                                'Interior features',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Urbanist',
                                  fontSize: 18,
                                  color: Color(0xFF371D32),
                                ),
                              ),
                            ),

                            SizedBox(height: 10),
                            //air conditioning//
                            SizedBox(
                              width: double.maxFinite,
                              child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Color(0xFFF2F2F2),
                                  padding: EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),),
                                  onPressed: () {
                                    carFeaturesDataSnapshot.data!.car!.features!
                                            .interior!.hasAirConditioning =
                                        !carFeaturesDataSnapshot
                                            .data!
                                            .car!
                                            .features!
                                            .interior!
                                            .hasAirConditioning!;
                                    carFeaturesBloc.changedCarFeaturesData
                                        .call(carFeaturesDataSnapshot.data!);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Row(children: [
                                          Image.asset('icons/AC.png'),
                                          SizedBox(width: 10),
                                          Text(
                                            'Air conditioning',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32),
                                            ),
                                          ),
                                        ]),
                                      ),
                                      Icon(
                                        Icons.check,
                                        size: 20,
                                        color: carFeaturesDataSnapshot
                                                .data!
                                                .car!
                                                .features!
                                                .interior!
                                                .hasAirConditioning!
                                            ? Color(0xFFFF8F68)
                                            : Colors.transparent,
                                      ),
                                    ],
                                  )),
                            ),
                            SizedBox(height: 10),
                            // Android auto//
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasAndroidAuto =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasAndroidAuto!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Android.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Android auto',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .interior!
                                                          .hasAndroidAuto!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            //apple car-play//
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasAppleCarPlay =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasAppleCarPlay!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Apple.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Apple CarPlay',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .interior!
                                                          .hasAppleCarPlay!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasBluetoothAudio =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasBluetoothAudio!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Bluetooth.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Bluetooth audio',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .interior!
                                                          .hasBluetoothAudio!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasHeatedSeats =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasHeatedSeats!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Heated_Seats.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Heated seats',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .interior!
                                                          .hasHeatedSeats!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasSunroof =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasSunroof!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Sun.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Sunroof',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .interior!
                                                          .hasSunroof!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasUsbChargingPort =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasUsbChargingPort!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/USB-2.png',
                                                        height: 24,
                                                        width: 24,
                                                        color:
                                                            Color(0xff686868)),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'USB charging port',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .interior!
                                                          .hasUsbChargingPort!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasVentilatedSeats =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .interior!
                                                      .hasVentilatedSeats!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Ventilated_seats.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Ventilated seats',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .interior!
                                                          .hasVentilatedSeats!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Exterior
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
                                          'Exterior features',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Color(0xFFF2F2F2),
                                          padding: EdgeInsets.all(16.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),),
                                          onPressed: () {
                                            carFeaturesDataSnapshot
                                                    .data!
                                                    .car!
                                                    .features!
                                                    .exterior!
                                                    .hasAllWheelDrive =
                                                !carFeaturesDataSnapshot
                                                    .data!
                                                    .car!
                                                    .features!
                                                    .exterior!
                                                    .hasAllWheelDrive!;
                                            carFeaturesBloc
                                                .changedCarFeaturesData
                                                .call(carFeaturesDataSnapshot
                                                    .data!);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Row(children: [
                                                  Image.asset('icons/AWD.png'),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'All-wheel drive',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(0xFF371D32),
                                                    ),
                                                  ),
                                                ]),
                                              ),
                                              Icon(
                                                Icons.check,
                                                size: 20,
                                                color: carFeaturesDataSnapshot
                                                        .data!
                                                        .car!
                                                        .features!
                                                        .exterior!
                                                        .hasAllWheelDrive!
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
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .exterior!
                                                      .hasBikeRack =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .exterior!
                                                      .hasBikeRack!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Bike.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Bike rack',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .exterior!
                                                          .hasBikeRack!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .exterior!
                                                      .hasSkiRack =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .exterior!
                                                      .hasSkiRack!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Image.asset(
                                                          'icons/Ski.png'),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        'Ski rack',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 16,
                                                          color:
                                                              Color(0xFF371D32),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .exterior!
                                                          .hasSkiRack!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .exterior!
                                                      .hasSnowTires =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .exterior!
                                                      .hasSnowTires!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Snow-tires.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Snow tires',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .exterior!
                                                          .hasSnowTires!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Comfort
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
                                          'Comfort features',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .comfort!
                                                      .freeWifi =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .comfort!
                                                      .freeWifi!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Wifi.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Free Wi-Fi',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .comfort!
                                                          .freeWifi!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .comfort!
                                                      .remoteStart =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .comfort!
                                                      .remoteStart!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Remote-start.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Remote start',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .comfort!
                                                          .remoteStart!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            // Safety and privacy
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
                                          'Safety and privacy features',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
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
                            //child seats//
                            // Row(
                            //   children: <Widget>[
                            //     Expanded(
                            //       child: Column(
                            //         children: [
                            //           SizedBox(
                            //             width: double.maxFinite,
                            //             child: ElevatedButton(
                            //                             style:ElevatedButton.styleFrom(
                            //                 elevation: 0.0,
                            //                 color: Color(0xFFF2F2F2),
                            //                 padding: EdgeInsets.all(16.0),
                            //                 shape: RoundedRectangleBorder(
                            //                     borderRadius: BorderRadius.circular(
                            //                         8.0)),
                            //                 onPressed: () {
                            //                   carFeaturesDataSnapshot.data!.car!
                            //                       .features!.safetyAndPrivacy!
                            //                       .hasChildSeat =
                            //                   !carFeaturesDataSnapshot.data!.car!
                            //                       .features!.safetyAndPrivacy!
                            //                       .hasChildSeat;
                            //                   carFeaturesBloc.changedCarFeaturesData
                            //                       .call(carFeaturesDataSnapshot.data!);
                            //                 },
                            //                 child: Row(
                            //                   mainAxisAlignment: MainAxisAlignment
                            //                       .spaceBetween,
                            //                   children: <Widget>[
                            //                     Container(
                            //                       child: Row(
                            //                           children: [
                            //                             Image.asset(
                            //                                 'icons/Child-seat.png'),
                            //                             SizedBox(width: 10),
                            //                             Text('Child seat',
                            //                               style: TextStyle(
                            //                                 fontFamily: 'Urbanist',
                            //                                 fontSize: 16,
                            //                                 color: Color(0xFF371D32),
                            //                               ),
                            //                             ),
                            //                           ]
                            //                       ),
                            //                     ),
                            //                     Icon(
                            //                       Icons.check,
                            //                       size: 20,
                            //                       color: carFeaturesDataSnapshot.data!
                            //                           .car!.features!.safetyAndPrivacy!
                            //                           .hasChildSeat ? Color(
                            //                           0xFFFF8F68) : Colors
                            //                           .transparent,
                            //                     ),
                            //                   ],
                            //                 )
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            // SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .safetyAndPrivacy!
                                                      .hasDashCamera =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .safetyAndPrivacy!
                                                      .hasDashCamera!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Camera.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Dash camera',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .safetyAndPrivacy!
                                                          .hasDashCamera!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .safetyAndPrivacy!
                                                      .hasGPSTrackingDevice =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .safetyAndPrivacy!
                                                      .hasGPSTrackingDevice!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Location.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'GPS tracking',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .safetyAndPrivacy!
                                                          .hasGPSTrackingDevice!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
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
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: () {
                                              carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .safetyAndPrivacy!
                                                      .hasSpareTire =
                                                  !carFeaturesDataSnapshot
                                                      .data!
                                                      .car!
                                                      .features!
                                                      .safetyAndPrivacy!
                                                      .hasSpareTire!;
                                              carFeaturesBloc
                                                  .changedCarFeaturesData
                                                  .call(carFeaturesDataSnapshot
                                                      .data!);
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: [
                                                    Image.asset(
                                                        'icons/Tire.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Spare tire',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(
                                                  Icons.check,
                                                  size: 20,
                                                  color: carFeaturesDataSnapshot
                                                          .data!
                                                          .car!
                                                          .features!
                                                          .safetyAndPrivacy!
                                                          .hasSpareTire!
                                                      ? Color(0xFFFF8F68)
                                                      : Colors.transparent,
                                                ),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // SizedBox(height: 10),
                            // // Text
                            // Row(
                            //   children: <Widget>[
                            //     Expanded(
                            //       child: Column(
                            //         children: <Widget>[
                            //           Text(
                            //             '24/7 roadside assistance will be included for your guests free of charge.',
                            //             style: TextStyle(
                            //               fontFamily: 'Urbanist',
                            //               fontSize: 14,
                            //               color: Color(0xFF353B50),
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ),
                            //   ],
                            // ),
                            SizedBox(height: 30),
                            // Custom features
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
                                          'Custom features',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
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
                            carFeaturesDataSnapshot
                                        .data!.car!.features!.customFeatures !=
                                    null
                                ? Column(
                                    children: <Widget>[
                                      for (CustomFeatures item
                                          in carFeaturesDataSnapshot
                                              .data!.car!.features!.customFeatures!)
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        backgroundColor:
                                                            Color(0xFFF2F2F2),
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),),
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/edit_a_feature_ui',
                                                            arguments: item,
                                                          ).then((value) {
                                                            if (value != null) {
                                                              if ((value as Map)[
                                                                      "Status"] ==
                                                                  "REMOVE") {
                                                                carFeaturesDataSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .features!
                                                                    .customFeatures!
                                                                    .remove(
                                                                        item);
                                                                carFeaturesBloc
                                                                    .changedCarFeaturesData
                                                                    .call(carFeaturesDataSnapshot
                                                                        .data!);
                                                              }
                                                              if ((value as Map)[
                                                                      "Status"] ==
                                                                  "EDIT") {
                                                                item = (value
                                                                        as Map)[
                                                                    "Data"];
                                                                carFeaturesBloc
                                                                    .changedCarFeaturesData
                                                                    .call(carFeaturesDataSnapshot
                                                                        .data!);
                                                              }
                                                            }
                                                          });
                                                        },
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: <Widget>[
                                                            Container(
                                                              child: Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Image.asset(
                                                                        'icons/Star.png'),
                                                                    SizedBox(
                                                                        width:
                                                                            10),
                                                                    SizedText(
                                                                      deviceWidth:
                                                                          deviceWidth,
                                                                      textWidthPercentage:
                                                                          0.65,
                                                                      text: item
                                                                          .name!,
                                                                      textOverflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      fontFamily:
                                                                          'Roboto',
                                                                      fontSize:
                                                                          16,
                                                                      textColor:
                                                                          Color(
                                                                              0xFF371D32),
                                                                    ),
                                                                  ]),
                                                            ),
                                                            Icon(
                                                                Icons
                                                                    .keyboard_arrow_right,
                                                                color: Color(
                                                                    0xFF353B50)),
                                                          ],
                                                        )),
                                                  ),
                                                  SizedBox(height: 10.0),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  )
                                : SizedBox(height: 10),
                            // Add new feature
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0)),),
                                            onPressed: carFeaturesDataSnapshot
                                                        .data!
                                                        .car!
                                                        .features!
                                                        .customFeatures!
                                                        .length <
                                                    5
                                                ? () {
                                                    Navigator.pushNamed(
                                                      context,
                                                      '/add_a_feature_ui',
                                                      arguments:
                                                          carFeaturesDataSnapshot
                                                              .data!,
                                                    ).then((value) {
                                                      if (value != null) {
                                                        carFeaturesBloc
                                                            .changedCarFeaturesData
                                                            .call(value as CreateCarResponse);
                                                      }
                                                    });
                                                  }
                                                : null,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(children: <Widget>[
                                                    Image.asset(
                                                        'icons/Star.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Add a feature',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ]),
                                                ),
                                                Icon(Icons.keyboard_arrow_right,
                                                    color: Color(0xFF353B50)),
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            carFeaturesDataSnapshot.data!.car!.features!
                                        .customFeatures!.length >=
                                    5
                                ? Text(
                                    'You can add up to 5 additional features.',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xFFF55A51),
                                    ),
                                  )
                                : Container(),
                            SizedBox(height: 30),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: StreamBuilder<int>(
                                            stream: carFeaturesBloc
                                                .progressIndicator,
                                            builder: (context,
                                                progressIndicatorSnapshot) {
                                              return ElevatedButton(
                                                        style:ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                backgroundColor: Color(0xffFF8F68),
                                                padding: EdgeInsets.all(16.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),),
                                                onPressed:
                                                    progressIndicatorSnapshot
                                                                .data! ==
                                                            1
                                                        ? null
                                                        : () async {
                                                            carFeaturesBloc
                                                                .changedProgressIndicator
                                                                .call(1);
                                                            var response = await carFeaturesBloc
                                                                .setCarFeatures(
                                                                    carFeaturesDataSnapshot
                                                                        .data!);
                                                            if (response !=
                                                                null) {
                                                              if (pushNeeded) {
                                                                Navigator.pushNamed(
                                                                    context,
                                                                    pushRouteName!,
                                                                    arguments: {
                                                                      'carResponse':
                                                                          response,
                                                                      'purpose':
                                                                          purpose
                                                                    });
                                                              } else {
                                                                Navigator.pop(
                                                                    context,
                                                                    response);
                                                              }
                                                            }
                                                          },
                                                child: progressIndicatorSnapshot
                                                            .data! ==
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
                                              );
                                            }),
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
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new CircularProgressIndicator(strokeWidth: 2.5)
                      ],
                    ),
                  );
          }),
    );
  }
}
