import 'package:flutter/material.dart';
import 'package:ridealike/pages/list_a_car/bloc/car_pricing_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/car_suggested_data_response.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/list_a_car/response_model/payout_method_response.dart';
import 'package:ridealike/utils/empty_cheker.dart';
import 'package:ridealike/widgets/sized_text.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/app_events/app_events_utils.dart';

class PriceYourCarUi extends StatefulWidget {
  @override
  State createState() => PriceYourCarUiState();
}

class PriceYourCarUiState extends State<PriceYourCarUi> {
  var carPricingBloc = CarPricingBloc();
  String _oneTimeDiscountString = '';
  Map _payoutData = {};

//  Map _carSuggestedPriceData = {};
  bool exitPressed = false;

  //double? _sliderValue;
  ValueNotifier<double> _sliderValue = ValueNotifier(0);
  double _sliderMax = 0;
  double _sliderMin = 0;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Price Your Car"});
  }

  @override
  Widget build(BuildContext context) {
    Map routeData = ModalRoute.of(context)!.settings.arguments as Map;
    CreateCarResponse createCarResponse = CreateCarResponse.fromJson(
        (routeData['carResponse'] as CreateCarResponse).toJson());

    double deviceWidth = MediaQuery.of(context).size.width;

    var purpose = routeData['purpose'];
    bool pushNeeded = routeData['PUSH'] == null ? false : routeData['PUSH'];
    String? pushRouteName = routeData['ROUTE_NAME'];
    // final CreateCarResponse createCarResponse = ModalRoute.of(context).settings.arguments;
    carPricingBloc.changedProgressIndicator.call(0);
    carPricingBloc.getCarSuggestedPriceData(createCarResponse).then((value) {
      if (value != null && value.status!.success!) {
      } else {
        value = FetchCarSuggestedDataResponse();
        value.hourlyRate = 0;
        value.dailyRate = 0;
        value.everyExtraKMOver200KM = 0.75;
        value.perKMDeliveryFee = 2.00;
        value.weeklyDiscountPercentage = 0.0;
        value.monthlyDiscountPercentage = 0.0;
      }

      if (createCarResponse.car!.pricing!.completed == false) {
        if (isEmptyDouble(
            createCarResponse.car!.pricing!.rentalPricing!.perHour!)) {
          createCarResponse.car!.pricing!.rentalPricing!.perHour =
              value.hourlyRate == 0 ? 13 : value.hourlyRate;
        }
        if (isEmptyDouble(
            createCarResponse.car!.pricing!.rentalPricing!.perDay!)) {
          createCarResponse.car!.pricing!.rentalPricing!.perDay =
              value.dailyRate == 0 ? 100 : value.dailyRate;
        }
        if (isEmptyDouble(createCarResponse
            .car!.pricing!.rentalPricing!.perKMRentalDeliveryFee!)) {
          createCarResponse.car!.pricing!.rentalPricing!
              .perKMRentalDeliveryFee = value.perKMDeliveryFee;
        }
        if (isEmptyDouble(createCarResponse
            .car!.pricing!.rentalPricing!.bookForWeekDiscountPercentage!)) {
          createCarResponse
              .car!.pricing!.rentalPricing!.bookForWeekDiscountPercentage = 0.0;
        }
        if (isEmptyDouble(createCarResponse
            .car!.pricing!.rentalPricing!.bookForMonthDiscountPercentage!)) {
          createCarResponse.car!.pricing!.rentalPricing!
              .bookForMonthDiscountPercentage = 0.0;
        }
        if (createCarResponse
                .car!.pricing!.rentalPricing!.oneTime20DiscountForFirst3Users !=
            null) {
          createCarResponse.car!.pricing!.rentalPricing!
              .oneTime20DiscountForFirst3Users = false;
          _oneTimeDiscountString = '0';
        }
        if (createCarResponse.car!.preference!.dailyMileageAllowance ==
            'Limited') {
          if (isEmptyDouble(createCarResponse
              .car!.pricing!.rentalPricing!.perExtraKMOverLimit!)) {
            createCarResponse.car!.pricing!.rentalPricing!.perExtraKMOverLimit =
                0.75;
            // value.everyExtraKMOver200KM;
          }
        }
      } else {
        createCarResponse
                .car!.pricing!.rentalPricing!.oneTime20DiscountForFirst3Users!
            ? _oneTimeDiscountString = '1'
            : _oneTimeDiscountString = '0';
      }
      checkWithinLimit(createCarResponse, value);
      carPricingBloc.changedCarSuggestedPrice.call(value);
      carPricingBloc.changedCarPricingData.call(createCarResponse);
    });

    bool _isButtonPressed = false;

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
          },
        ),
        centerTitle: true,
        title: Text(
          '6/6',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: Color(0xff371D32),
          ),
        ),
        actions: <Widget>[
          StreamBuilder<CreateCarResponse>(
              stream: carPricingBloc.carPricingData,
              builder: (context, carPricingDataSnapshot) {
                if (_sliderValue.value == 0 && carPricingDataSnapshot
                    .data != null) {
                  _sliderValue.value = double.parse(carPricingDataSnapshot
                      .data!.car!.pricing!.rentalPricing!.perDay!
                      .floor()
                      .toString());
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        if (!exitPressed) {
                          exitPressed = true;
                          var response = await carPricingBloc.setCarPricing(
                              carPricingDataSnapshot.data!,
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
                          child: createCarResponse.car!.pricing!.completed!
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
      body: Container(
        child: new SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: StreamBuilder<CreateCarResponse>(
                  stream: carPricingBloc.carPricingData,
                  builder: (context, carPricingDataSnapshot) {
                    return carPricingDataSnapshot.hasData &&
                            carPricingDataSnapshot.data != null
                        ? StreamBuilder<FetchCarSuggestedDataResponse>(
                            stream: carPricingBloc.carSuggestedPrice,
                            builder: (context, suggestedPriceSnapshot) {
                              // TODO
                              debugPrint("carPricingDataSnapshot");
                              if(suggestedPriceSnapshot.data != null){
                                _sliderMin =
                                suggestedPriceSnapshot.data!.dailyRate == 0
                                    ? 50
                                    : double.parse((suggestedPriceSnapshot
                                    .data!.dailyRate! *
                                    0.0)
                                    .floor()
                                    .toString());
                                _sliderMax =
                                suggestedPriceSnapshot.data!.dailyRate == 0
                                    ? 700
                                    : double.parse((suggestedPriceSnapshot
                                    .data!.dailyRate! *
                                    3)
                                    .ceil()
                                    .toString());
                              }
                              return suggestedPriceSnapshot.hasData &&
                                      suggestedPriceSnapshot.data != null
                                  ? Column(
                                      children: <Widget>[
                                        // Header
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: Container(
                                                      child: Text(
                                                        'Set your pricing',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 36,
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
                                            Image.asset(
                                                'icons/Price-Tag_Pricing.png'),
                                          ],
                                        ),
                                        SizedBox(height: 20),
                                        // Text
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
                                                      'To help you set your rates, we make it easy with the suggested pricing below, based on analyzing your vehicle with our market data. You can change the rates to your preferred amounts.',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF353B50),
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
                                                      'Vehicle rates',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        // Per hour
                                        carPricingDataSnapshot
                                                        .data!
                                                        .car!
                                                        .availability!
                                                        .rentalAvailability!
                                                        .shortestTrip ==
                                                    1 ||
                                                carPricingDataSnapshot
                                                        .data!
                                                        .car!
                                                        .availability!
                                                        .rentalAvailability!
                                                        .shortestTrip ==
                                                    2 ||
                                                carPricingDataSnapshot
                                                        .data!
                                                        .car!
                                                        .availability!
                                                        .rentalAvailability!
                                                        .shortestTrip ==
                                                    3
                                            ? Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: Color(
                                                                    0xFFF2F2F2),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0)),
                                                            child: Container(
                                                              child: Column(
                                                                children: <Widget>[
                                                                  Padding(
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            16.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: <Widget>[
                                                                        Text(
                                                                          'Per hour',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Urbanist',
                                                                            fontSize:
                                                                                16,
                                                                            color:
                                                                                Color(0xFF371D32),
                                                                          ),
                                                                        ),
                                                                        // suggestedPriceSnapshot.data.hourlyRate==0?
                                                                        // Text('\$ 10',
                                                                        //   style: TextStyle(
                                                                        //     fontFamily: 'Urbanist',
                                                                        //     fontSize: 14,
                                                                        //     color: Color(0xFF353B50),
                                                                        //   ),
                                                                        // ) :
                                                                        Text(
                                                                          '\$' +
                                                                              '${double.parse(carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perHour.toString()).floor().toString()
                                                                              // carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perHour.toStringAsFixed(2)
                                                                              }',
                                                                          style:
                                                                              TextStyle(
                                                                            fontFamily:
                                                                                'Urbanist',
                                                                            fontSize:
                                                                                14,
                                                                            color:
                                                                                Color(0xFF353B50),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        right:
                                                                            16.0,
                                                                        bottom:
                                                                            0.0,
                                                                        left:
                                                                            16.0,
                                                                        top:
                                                                            0.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .start,
                                                                      children: <Widget>[
                                                                        suggestedPriceSnapshot.hasData &&
                                                                                suggestedPriceSnapshot.data != null
                                                                            ? suggestedPriceSnapshot.data!.hourlyRate == 0
                                                                                ? Text('Suggested: N/A')
                                                                                : Text(
                                                                                    'Suggested: \$${double.parse(suggestedPriceSnapshot.data!.hourlyRate.toString()).floor().toString()
                                                                                    // suggestedPriceSnapshot.data.hourlyRate.toStringAsFixed(2)
                                                                                    }',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Urbanist',
                                                                                      fontSize: 14,
                                                                                      color: Color(0xFF353B50),
                                                                                    ),
                                                                                  )
                                                                            : Container(),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: EdgeInsets.only(
                                                                        bottom:
                                                                            8.0),
                                                                    child: Row(
                                                                      children: <Widget>[
                                                                        Expanded(
                                                                          child:
                                                                              SliderTheme(
                                                                            data:
                                                                                SliderThemeData(
                                                                              thumbColor: Color(0xffFFFFFF),
                                                                              trackShape: RoundedRectSliderTrackShape(),
                                                                              trackHeight: 4.0,
                                                                              activeTrackColor: Color(0xffFF8F62),
                                                                              inactiveTrackColor: Color(0xFFE0E0E0),
                                                                              tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                                                              activeTickMarkColor: Color(0xffFF8F62),
                                                                              inactiveTickMarkColor: Color(0xFFE0E0E0),
                                                                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                                                            ),
                                                                            child:
                                                                                Slider(
                                                                              min: suggestedPriceSnapshot.data!.hourlyRate == 0 ? 10 : double.parse((suggestedPriceSnapshot.data!.hourlyRate! * 0.0).floor().toString()),
                                                                              max: suggestedPriceSnapshot.data!.hourlyRate == 0 ? 88 : double.parse((suggestedPriceSnapshot.data!.hourlyRate! * 3).ceil().toString()),
                                                                              onChanged: (values) {
                                                                                carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perHour = double.parse(values.floor().toString());
                                                                                carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                                              },
                                                                              value: double.parse(carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perHour!.floor().toString()),
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
                                            : Container(),
                                        carPricingDataSnapshot
                                                        .data!
                                                        .car!
                                                        .availability!
                                                        .rentalAvailability!
                                                        .shortestTrip ==
                                                    1 ||
                                                carPricingDataSnapshot
                                                        .data!
                                                        .car!
                                                        .availability!
                                                        .rentalAvailability!
                                                        .shortestTrip ==
                                                    2 ||
                                                carPricingDataSnapshot
                                                        .data!
                                                        .car!
                                                        .availability!
                                                        .rentalAvailability!
                                                        .shortestTrip ==
                                                    3
                                            ? SizedBox(height: 10)
                                            : Container(),
                                        // Per day
                                        // TODO
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFF2F2F2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0)),
                                                      child: Container(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <Widget>[
                                                                  SizedText(
                                                                    deviceWidth:
                                                                        deviceWidth,
                                                                    textWidthPercentage:
                                                                        0.7,
                                                                    text:
                                                                        'Per day (24 consecutive hours)',
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        16,
                                                                    textColor:
                                                                        Color(
                                                                            0xFF371D32),
                                                                  ),
                                                                  // suggestedPriceSnapshot.data.dailyRate==0?    Text('\$ 100',
                                                                  //   style: TextStyle(
                                                                  //     fontFamily: 'Urbanist',
                                                                  //     fontSize: 14,
                                                                  //     color: Color(0xFF353B50),
                                                                  //   ),
                                                                  // ):
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          16.0,
                                                                      bottom:
                                                                          8.0,
                                                                      left:
                                                                          16.0,
                                                                      top: 0.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <Widget>[
                                                                  suggestedPriceSnapshot
                                                                              .hasData &&
                                                                          suggestedPriceSnapshot.data !=
                                                                              null
                                                                      ? suggestedPriceSnapshot.data!.dailyRate ==
                                                                              0
                                                                          ? Text(
                                                                              'Suggested: N/A')
                                                                          : Text(
                                                                              'Suggested: \$${double.parse(suggestedPriceSnapshot.data!.dailyRate.toString()).floor().toString()
                                                                              // suggestedPriceSnapshot.data.dailyRate.toStringAsFixed(2)
                                                                              }',
                                                                              style: TextStyle(
                                                                                fontFamily: 'Urbanist',
                                                                                fontSize: 14,
                                                                                color: Color(0xFF353B50),
                                                                              ),
                                                                            )
                                                                      : Container(),
                                                                  Row(
                                                                    children: [
                                                                      IconButton(
                                                                        icon:
                                                                            Icon(
                                                                          Icons
                                                                              .remove,
                                                                          color:
                                                                              Color(0xffFF8F62),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          if (_sliderValue.value >
                                                                              _sliderMin) {
                                                                            debugPrint("NO");
                                                                            _sliderValue.value =
                                                                                _sliderValue.value - 1;
                                                                            carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perDay = _sliderValue.value;
                                                                            carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                                          }
                                                                          /*setState(() {
                                                            double currentValue = double.parse(carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perDay!.floor().toString());
                                                            double newValue = currentValue - 1;
                                                            if (newValue >= suggestedPriceSnapshot.data!.dailyRate! * 0.0) {
                                                              carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perDay = newValue;
                                                              carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                            }
                                                          });*/
                                                                        },
                                                                      ),
                                                                      OutlinedButton(
                                                                        onPressed:
                                                                            null,
                                                                        style: OutlinedButton
                                                                            .styleFrom(
                                                                          side:
                                                                              BorderSide(
                                                                            color:
                                                                                Color(0xffFF8F62),
                                                                            width:
                                                                                1, // Border width
                                                                          ),
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          ),
                                                                          padding:
                                                                              EdgeInsets.all(10),
                                                                        ),
                                                                        child:
                                                                        ValueListenableBuilder<
                                                                            double>(
                                                                            valueListenable:
                                                                            _sliderValue,
                                                                            builder: (context,
                                                                                value,
                                                                                child) {
                                                                              return Text(
                                                                                '\$' +
                                                                                    '${value}',
                                                                                style:
                                                                                TextStyle(
                                                                                  fontFamily:
                                                                                  'Urbanist',
                                                                                  fontSize:
                                                                                  16,
                                                                                  color:
                                                                                  Color(0xFF353B50),
                                                                                ),
                                                                              );
                                                                            }),

                                                                      ),
                                                                      IconButton(
                                                                        icon: Icon(
                                                                            Icons
                                                                                .add,
                                                                            color:
                                                                                Color(0xffFF8F62)),
                                                                        onPressed:
                                                                            () {
                                                                          if (_sliderValue.value <
                                                                              _sliderMax) {
                                                                            debugPrint("YES");
                                                                            _sliderValue.value =
                                                                                _sliderValue.value + 1;
                                                                            carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perDay = _sliderValue.value;
                                                                            carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                                          }
                                                                          /*setState(() {
                                                            double currentValue = double.parse(carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perDay!.floor().toString());
                                                            double newValue = currentValue + 1;
                                                            if (newValue <= suggestedPriceSnapshot.data!.dailyRate! * 3) {
                                                              carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perDay = newValue;
                                                              carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                            }
                                                          });*/
                                                                        },
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          8.0),
                                                              child: Row(
                                                                children: <Widget>[
                                                                  Expanded(
                                                                    child:
                                                                        SliderTheme(
                                                                      data:
                                                                          SliderThemeData(
                                                                        thumbColor:
                                                                            Color(0xffFFFFFF),
                                                                        trackShape:
                                                                            RoundedRectSliderTrackShape(),
                                                                        trackHeight:
                                                                            4.0,
                                                                        activeTrackColor:
                                                                            Color(0xffFF8F62),
                                                                        inactiveTrackColor:
                                                                            Color(0xFFE0E0E0),
                                                                        tickMarkShape:
                                                                            RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                                                        activeTickMarkColor:
                                                                            Color(0xffFF8F62),
                                                                        inactiveTickMarkColor:
                                                                            Color(0xFFE0E0E0),
                                                                        thumbShape:
                                                                            RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                                                      ),
                                                                      child: ValueListenableBuilder<
                                                                              double>(
                                                                          valueListenable:
                                                                              _sliderValue,
                                                                          builder: (context,
                                                                              value,
                                                                              child) {
                                                                            debugPrint("slider ${_sliderValue.value}");
                                                                            return Slider(
                                                                                min: _sliderMin,
                                                                                max: _sliderMax,
                                                                                onChanged: (values) {
                                                                                  debugPrint(values.floor().toString());
                                                                                  _sliderValue.value = double.parse(values.floor().toString());
                                                                                  carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perDay = _sliderValue.value;
                                                                                  carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                                                },
                                                                                value: value);
                                                                          }),
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

                                        // Section header
                                        carPricingDataSnapshot
                                                    .data!
                                                    .car!
                                                    .preference!
                                                    .dailyMileageAllowance ==
                                                'Limited'
                                            ? Column(
                                                children: <Widget>[
                                                  SizedBox(height: 20),
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            SizedBox(
                                                              width: double
                                                                  .maxFinite,
                                                              child: Text(
                                                                'Extras',
                                                                style:
                                                                    TextStyle(
                                                                  fontFamily:
                                                                      'Urbanist',
                                                                  fontSize: 18,
                                                                  color: Color(
                                                                      0xFF371D32),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 10),

                                                  ///Per km over the mileage allowance
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              width: double
                                                                  .maxFinite,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xFFF2F2F2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0)),
                                                                child:
                                                                    Container(
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.all(16.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: <Widget>[
                                                                            Expanded(
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: <Widget>[
                                                                                  Text(
                                                                                    'Per km over the mileage allowance',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Urbanist',
                                                                                      fontSize: 16,
                                                                                      color: Color(0xFF371D32),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              '\$' + '${carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perExtraKMOverLimit!.toStringAsFixed(2)}',
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
                                                                        padding: EdgeInsets.only(
                                                                            right:
                                                                                16.0,
                                                                            bottom:
                                                                                8.0,
                                                                            left:
                                                                                16.0,
                                                                            top:
                                                                                0.0),
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: <Widget>[
                                                                            suggestedPriceSnapshot.hasData && suggestedPriceSnapshot.data != null
                                                                                ? Text(
                                                                                    'Suggested: \$0.75',
                                                                                    // 'Suggested: \$${suggestedPriceSnapshot.data.everyExtraKMOver200KM.toStringAsFixed(2)}',
                                                                                    style: TextStyle(
                                                                                      fontFamily: 'Urbanist',
                                                                                      fontSize: 14,
                                                                                      color: Color(0xFF353B50),
                                                                                    ),
                                                                                  )
                                                                                : Container(),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding:
                                                                            EdgeInsets.only(bottom: 8.0),
                                                                        child:
                                                                            Row(
                                                                          children: <Widget>[
                                                                            Expanded(
                                                                              child: SliderTheme(
                                                                                data: SliderThemeData(
                                                                                  thumbColor: Color(0xffFFFFFF),
                                                                                  trackShape: RoundedRectSliderTrackShape(),
                                                                                  trackHeight: 4.0,
                                                                                  activeTrackColor: Color(0xffFF8F62),
                                                                                  inactiveTrackColor: Color(0xFFE0E0E0),
                                                                                  tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                                                                  activeTickMarkColor: Color(0xffFF8F62),
                                                                                  inactiveTickMarkColor: Color(0xFFE0E0E0),
                                                                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                                                                ),
                                                                                child: Slider(
                                                                                  min: 0.00,
                                                                                  max: 2.00,
                                                                                  divisions: 8,
                                                                                  onChanged: (values) {
                                                                                    carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perExtraKMOverLimit = double.parse(values.toStringAsFixed(2));
                                                                                    carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                                                  },
                                                                                  value: double.parse(carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perExtraKMOverLimit.toString()),
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
                                                ],
                                              )
                                            : Container(),

                                        SizedBox(height: 10),

                                        /// Custom delivery
                                        carPricingDataSnapshot
                                                    .data!
                                                    .car!
                                                    .preference!
                                                    .listingType!
                                                    .rentalEnabled ==
                                                true
                                            ? Column(
                                                children: [
                                                  //Custom delivery
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        child: Column(
                                                          children: [
                                                            SizedBox(
                                                              width: double
                                                                  .maxFinite,
                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: Color(
                                                                        0xFFF2F2F2),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0)),
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              16.0),
                                                                  child: Column(
                                                                    children: <Widget>[
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: <Widget>[
                                                                          SizedText(
                                                                            deviceWidth:
                                                                                deviceWidth,
                                                                            textWidthPercentage:
                                                                                0.8,
                                                                            text:
                                                                                'Enable custom delivery?',
                                                                            fontFamily:
                                                                                'Urbanist',
                                                                            fontSize:
                                                                                16,
                                                                            textColor:
                                                                                Color(0xFF371D32),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      Row(
                                                                        children: <Widget>[
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              children: <Widget>[
                                                                                Text(
                                                                                  'You can offer car delivery to popular locations such as airports, train stations, and lodgings or to a location that your Guest selects, subject to a minimum of \$25.',
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
                                                                      SizedBox(
                                                                          height:
                                                                              10),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: <Widget>[
                                                                          Expanded(
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                elevation: 0.0,
                                                                                padding: EdgeInsets.all(16.0),
                                                                                backgroundColor: carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery! ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                                                              ),
                                                                              onPressed: () {
                                                                                carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery = true;
                                                                                carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                                              },
                                                                              child: Column(
                                                                                children: <Widget>[
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: <Widget>[
                                                                                      Text(
                                                                                        'YES',
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Urbanist',
                                                                                          fontSize: 12,
                                                                                          color: carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery! ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                              width: 10),
                                                                          Expanded(
                                                                            child:
                                                                                ElevatedButton(
                                                                              style: ElevatedButton.styleFrom(
                                                                                elevation: 0.0,
                                                                                padding: EdgeInsets.all(16.0),
                                                                                backgroundColor: carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery! ? Color(0xFFE0E0E0).withOpacity(0.5) : Color(0xFFFF8F62),
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                                                              ),
                                                                              onPressed: () {
                                                                                carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery = false;
                                                                                carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                                              },
                                                                              child: Column(
                                                                                children: <Widget>[
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: <Widget>[
                                                                                      Text(
                                                                                        'NO',
                                                                                        style: TextStyle(
                                                                                          fontFamily: 'Urbanist',
                                                                                          fontSize: 12,
                                                                                          color: carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery! ? Color(0xFF353B50).withOpacity(0.5) : Color(0xFFFFFFFF),
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
                                                                      SizedBox(
                                                                          height:
                                                                              10),

                                                                      ///Per Kilometer Delivery
                                                                      carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery ==
                                                                              true
                                                                          ? Container(
                                                                              child: Column(
                                                                                children: <Widget>[
                                                                                  Padding(
                                                                                    padding: EdgeInsets.all(16.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                      children: <Widget>[
                                                                                        SizedText(
                                                                                          deviceWidth: deviceWidth,
                                                                                          textWidthPercentage: 0.6,
                                                                                          text: 'Per km delivery fee (rental only)',
                                                                                          fontFamily: 'Urbanist',
                                                                                          fontSize: 16,
                                                                                          textColor: Color(0xFF371D32),
                                                                                        ),
                                                                                        Text(
                                                                                          '\$' + '${carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery != true ? 2 : carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perKMRentalDeliveryFee!.toStringAsFixed(2)}',
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
                                                                                    padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 0.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                      children: <Widget>[
                                                                                        suggestedPriceSnapshot.hasData && suggestedPriceSnapshot.data != null
                                                                                            ?
                                                                                            // Text('Suggested: \$${suggestedPriceSnapshot.data.perKMDeliveryFee.toStringAsFixed(2)}'
                                                                                            Text(
                                                                                                'Suggested: \$2',
                                                                                                style: TextStyle(
                                                                                                  fontFamily: 'Urbanist',
                                                                                                  fontSize: 14,
                                                                                                  color: Color(0xFF353B50),
                                                                                                ),
                                                                                              )
                                                                                            : Container(),
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
                                                                                              activeTrackColor: Color(0xffFF8F62),
                                                                                              inactiveTrackColor: Color(0xFFE0E0E0),
                                                                                              tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                                                                              activeTickMarkColor: Color(0xffFF8F62),
                                                                                              inactiveTickMarkColor: Color(0xFFE0E0E0),
                                                                                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                                                                            ),
                                                                                            child: Slider(
                                                                                              min: 1,
                                                                                              max: 5,
                                                                                              divisions: 4,
                                                                                              onChanged: carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery == true
                                                                                                  ? (values) {
                                                                                                      carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perKMRentalDeliveryFee = values;
                                                                                                      carPricingBloc.changedCarPricingData.call(carPricingDataSnapshot.data!);
                                                                                                    }
                                                                                                  : null,

                                                                                              //     (values) {
                                                                                              //   carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perKMRentalDeliveryFee  = values;
                                                                                              //   carPricingBloc.changedCarPricingData.call( carPricingDataSnapshot.data);
                                                                                              // },
                                                                                              value: carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.enableCustomDelivery != true ? 2 : double.parse(carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perKMRentalDeliveryFee.toString()),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          : Container()
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
                                                ],
                                              )
                                            : Container(),

                                        // // Per km delivery fee
                                        // Row(
                                        //   children: <Widget>[
                                        //     Expanded(
                                        //       child: Column(
                                        //         children: [
                                        //           SizedBox(
                                        //             width: double.maxFinite,
                                        //             child: Container(
                                        //               decoration: BoxDecoration(
                                        //                 color: Color(0xFFF2F2F2),
                                        //                 borderRadius: BorderRadius.circular(8.0)
                                        //               ),
                                        //               child: Container(
                                        //                 child: Column(
                                        //                   children: <Widget>[
                                        //                     Padding(
                                        //                       padding: EdgeInsets.all(16.0),
                                        //                       child: Row(
                                        //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        //                         children: <Widget>[
                                        //                           Text('Per km delivery fee (rental only)',
                                        //                             style: TextStyle(
                                        //                               fontFamily: 'Urbanist',
                                        //                               fontSize: 16,
                                        //                               color: Color(0xFF371D32),
                                        //                             ),
                                        //                           ),
                                        //                           Text('\$' + '${carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perKMRentalDeliveryFee.toStringAsFixed(2)}',
                                        //                             style: TextStyle(
                                        //                               fontFamily: 'Urbanist',
                                        //                               fontSize: 14,
                                        //                               color: Color(0xFF353B50),
                                        //                             ),
                                        //                           ),
                                        //                         ],
                                        //                       ),
                                        //                     ),
                                        //                     Padding(
                                        //                       padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 0.0),
                                        //                       child: Row(
                                        //                         mainAxisAlignment: MainAxisAlignment.start,
                                        //                         children: <Widget>[
                                        //                           suggestedPriceSnapshot.hasData && suggestedPriceSnapshot.data!=null?
                                        //                           Text('Suggested: \$${suggestedPriceSnapshot.data.perKMDeliveryFee.toStringAsFixed(2)}',
                                        //                             style: TextStyle(
                                        //                               fontFamily: 'Urbanist',
                                        //                               fontSize: 14,
                                        //                               color: Color(0xFF353B50),
                                        //                             ),
                                        //                           ):Container(),
                                        //                         ],
                                        //                       ),
                                        //                     ),
                                        //                     Padding(
                                        //                       padding: EdgeInsets.only(bottom: 8.0),
                                        //                       child: Row(
                                        //                         children: <Widget>[
                                        //                           Expanded(
                                        //                             child: SliderTheme(
                                        //                               data: SliderThemeData(
                                        //                                 thumbColor: Color(0xffFFFFFF),
                                        //                                 trackShape: RoundedRectSliderTrackShape(),
                                        //                                 trackHeight: 4.0,
                                        //                                 activeTrackColor: Color(0xffFF8F62),
                                        //                                 inactiveTrackColor: Color(0xFFE0E0E0),
                                        //                                 tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                        //                                 activeTickMarkColor: Color(0xffFF8F62),
                                        //                                 inactiveTickMarkColor: Color(0xFFE0E0E0),
                                        //                                 thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                        //                               ),
                                        //                               child: Slider(
                                        //                                 min: 0.5,
                                        //                                 max: 1.5,
                                        //                                 onChanged: (values) {
                                        //
                                        //                                     carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perKMRentalDeliveryFee  = values;
                                        //                                     carPricingBloc.changedCarPricingData.call( carPricingDataSnapshot.data);
                                        //                                 },
                                        //                                 value: double.parse(carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perKMRentalDeliveryFee.toString()),
                                        //                               ),
                                        //                             ),
                                        //                           ),
                                        //                         ],
                                        //                       ),
                                        //                     ),
                                        //                   ],
                                        //                 ),
                                        //               ),
                                        //             ),
                                        //           ),
                                        //         ],
                                        //       ),
                                        //     ),
                                        //   ],
                                        // ),
                                        carPricingDataSnapshot
                                                    .data!
                                                    .car!
                                                    .preference!
                                                    .listingType!
                                                    .rentalEnabled ==
                                                true
                                            ? SizedBox(height: 20)
                                            : Container(),
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
                                                      'Discounts',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        // 1 week discount
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFF2F2F2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0)),
                                                      child: Container(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <Widget>[
                                                                  Text(
                                                                    'Weekly discount',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      fontSize:
                                                                          16,
                                                                      color: Color(
                                                                          0xFF371D32),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.bookForWeekDiscountPercentage!.round()}' +
                                                                        '% off',
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
                                                                ],
                                                              ),
                                                            ),
                                                            // Padding(
                                                            //   padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 0.0),
                                                            //   child: Row(
                                                            //     mainAxisAlignment: MainAxisAlignment.start,
                                                            //     children: <Widget>[
                                                            //       suggestedPriceSnapshot.hasData && suggestedPriceSnapshot.data!=null?
                                                            //       Text('Suggested: ${suggestedPriceSnapshot.data.weeklyDiscountPercentage}% off (\$${getDiscountedPrice(carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perDay, 7,suggestedPriceSnapshot.data.weeklyDiscountPercentage)})',
                                                            //         style: TextStyle(
                                                            //           fontFamily: 'Urbanist',
                                                            //           fontSize: 14,
                                                            //           color: Color(0xFF353B50),
                                                            //         ),
                                                            //       )
                                                            //           :Container(),
                                                            //     ],
                                                            //   ),
                                                            // ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          8.0),
                                                              child: Row(
                                                                children: <Widget>[
                                                                  Expanded(
                                                                    child:
                                                                        SliderTheme(
                                                                      data:
                                                                          SliderThemeData(
                                                                        thumbColor:
                                                                            Color(0xffFFFFFF),
                                                                        trackShape:
                                                                            RoundedRectSliderTrackShape(),
                                                                        trackHeight:
                                                                            4.0,
                                                                        activeTrackColor:
                                                                            Color(0xffFF8F62),
                                                                        inactiveTrackColor:
                                                                            Color(0xFFE0E0E0),
                                                                        tickMarkShape:
                                                                            RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                                                        activeTickMarkColor:
                                                                            Color(0xffFF8F62),
                                                                        inactiveTickMarkColor:
                                                                            Color(0xFFE0E0E0),
                                                                        thumbShape:
                                                                            RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                                                      ),
                                                                      child:
                                                                          Slider(
                                                                        min:
                                                                            0.0,
                                                                        max:
                                                                            30.0,
                                                                        divisions:
                                                                            6,
                                                                        onChanged:
                                                                            (values) {
                                                                          carPricingDataSnapshot
                                                                              .data!
                                                                              .car!
                                                                              .pricing!
                                                                              .rentalPricing!
                                                                              .bookForWeekDiscountPercentage = double.parse(values.round().toString());
                                                                          carPricingBloc
                                                                              .changedCarPricingData
                                                                              .call(carPricingDataSnapshot.data!);
                                                                        },
                                                                        value: double.parse(carPricingDataSnapshot
                                                                            .data!
                                                                            .car!
                                                                            .pricing!
                                                                            .rentalPricing!
                                                                            .bookForWeekDiscountPercentage
                                                                            .toString()),
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
                                        // 1 month discount
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFF2F2F2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0)),
                                                      child: Container(
                                                        child: Column(
                                                          children: <Widget>[
                                                            Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <Widget>[
                                                                  Text(
                                                                    'Monthly discount',
                                                                    style:
                                                                        TextStyle(
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      fontSize:
                                                                          16,
                                                                      color: Color(
                                                                          0xFF371D32),
                                                                    ),
                                                                  ),
                                                                  Text(
                                                                    '${carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.bookForMonthDiscountPercentage!.round()}' +
                                                                        '% off',
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
                                                                ],
                                                              ),
                                                            ),
                                                            // Padding(
                                                            //   padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 0.0),
                                                            //   child: Row(
                                                            //     mainAxisAlignment: MainAxisAlignment.start,
                                                            //     children: <Widget>[
                                                            //       suggestedPriceSnapshot.hasData && suggestedPriceSnapshot.data!=null?
                                                            //       Text('Suggested: ${suggestedPriceSnapshot.data.monthlyDiscountPercentage}% off (\$${getDiscountedPrice(carPricingDataSnapshot.data!.car!.pricing!.rentalPricing!.perDay, 30,suggestedPriceSnapshot.data.monthlyDiscountPercentage)})',
                                                            //         style: TextStyle(
                                                            //           fontFamily: 'Urbanist',
                                                            //           fontSize: 14,
                                                            //           color: Color(0xFF353B50),
                                                            //         ),
                                                            //       ):Container(),
                                                            //     ],
                                                            //   ),
                                                            // ),
                                                            Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      bottom:
                                                                          8.0),
                                                              child: Row(
                                                                children: <Widget>[
                                                                  Expanded(
                                                                    child:
                                                                        SliderTheme(
                                                                      data:
                                                                          SliderThemeData(
                                                                        thumbColor:
                                                                            Color(0xffFFFFFF),
                                                                        trackShape:
                                                                            RoundedRectSliderTrackShape(),
                                                                        trackHeight:
                                                                            4.0,
                                                                        activeTrackColor:
                                                                            Color(0xffFF8F62),
                                                                        inactiveTrackColor:
                                                                            Color(0xFFE0E0E0),
                                                                        tickMarkShape:
                                                                            RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                                                        activeTickMarkColor:
                                                                            Color(0xffFF8F62),
                                                                        inactiveTickMarkColor:
                                                                            Color(0xFFE0E0E0),
                                                                        thumbShape:
                                                                            RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                                                      ),
                                                                      child:
                                                                          Slider(
                                                                        min:
                                                                            0.0,
                                                                        max:
                                                                            30.0,
                                                                        divisions:
                                                                            6,
                                                                        onChanged:
                                                                            (values) {
                                                                          carPricingDataSnapshot
                                                                              .data!
                                                                              .car!
                                                                              .pricing!
                                                                              .rentalPricing!
                                                                              .bookForMonthDiscountPercentage = double.parse(values.round().toString());
                                                                          carPricingBloc
                                                                              .changedCarPricingData
                                                                              .call(carPricingDataSnapshot.data!);
                                                                        },
                                                                        value: double.parse(carPricingDataSnapshot
                                                                            .data!
                                                                            .car!
                                                                            .pricing!
                                                                            .rentalPricing!
                                                                            .bookForMonthDiscountPercentage
                                                                            .toString()),
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
                                        // A one-time discount
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFF2F2F2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0)),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        child: Column(
                                                          children: <Widget>[
                                                            Row(
                                                              children: <Widget>[
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <Widget>[
                                                                      Text(
                                                                        'A one-time discount to your first 3 Guests',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Urbanist',
                                                                          fontSize:
                                                                              16,
                                                                          color:
                                                                              Color(0xFF371D32),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            Row(
                                                              children: <Widget>[
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <Widget>[
                                                                      Text(
                                                                        'You can offer 20% discount. RideAlike will automatically apply this discount to only first 3 Guests who rent your vehicle. This will help you get initial ratings and reviews.',
                                                                        style:
                                                                            TextStyle(
                                                                          fontFamily:
                                                                              'Urbanist',
                                                                          fontSize:
                                                                              14,
                                                                          color:
                                                                              Color(0xFF353B50),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 10),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: <Widget>[
                                                                Expanded(
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      _oneTimeDiscountString =
                                                                          '1';
                                                                      carPricingDataSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .pricing!
                                                                          .rentalPricing!
                                                                          .oneTime20DiscountForFirst3Users = true;
                                                                      carPricingBloc
                                                                          .changedCarPricingData
                                                                          .call(
                                                                              carPricingDataSnapshot.data!);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          56.0,
                                                                      decoration:
                                                                          new BoxDecoration(
                                                                        color: _oneTimeDiscountString ==
                                                                                '1'
                                                                            ? Color(0xFFFF8F62)
                                                                            : Color(0xFFE0E0E0).withOpacity(0.5),
                                                                        borderRadius: new BorderRadius
                                                                            .circular(
                                                                            8.0),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Expanded(
                                                                                child: Text(
                                                                                  'OFFER 20% OFF',
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Urbanist',
                                                                                    fontSize: 12,
                                                                                    color: _oneTimeDiscountString == '1' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
                                                                SizedBox(
                                                                    width: 10),
                                                                Expanded(
                                                                  child:
                                                                      GestureDetector(
                                                                    onTap: () {
                                                                      _oneTimeDiscountString =
                                                                          '0';
                                                                      carPricingDataSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .pricing!
                                                                          .rentalPricing!
                                                                          .oneTime20DiscountForFirst3Users = false;
                                                                      carPricingBloc
                                                                          .changedCarPricingData
                                                                          .call(
                                                                              carPricingDataSnapshot.data!);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          56.0,
                                                                      decoration:
                                                                          new BoxDecoration(
                                                                        color: _oneTimeDiscountString ==
                                                                                '0'
                                                                            ? Color(0xFFFF8F62)
                                                                            : Color(0xFFE0E0E0).withOpacity(0.5),
                                                                        borderRadius: new BorderRadius
                                                                            .circular(
                                                                            8.0),
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: <Widget>[
                                                                          Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Expanded(
                                                                                child: Text(
                                                                                  "DON'T OFFER",
                                                                                  textAlign: TextAlign.center,
                                                                                  style: TextStyle(
                                                                                    fontFamily: 'Urbanist',
                                                                                    fontSize: 12,
                                                                                    color: _oneTimeDiscountString == '0' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
                                        // Next button
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: StreamBuilder<int>(
                                                        stream: carPricingBloc
                                                            .progressIndicator,
                                                        builder: (context,
                                                            progressIndicatorSnapshot) {
                                                          return ElevatedButton(
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              elevation: 0.0,
                                                              backgroundColor:
                                                                  Color(
                                                                      0xFFFF8F62),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                          16.0),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0)),
                                                            ),
                                                            onPressed:
                                                                progressIndicatorSnapshot
                                                                            .data ==
                                                                        1
                                                                    ? null
                                                                    : () async {
                                                                        carPricingBloc
                                                                            .changedProgressIndicator
                                                                            .call(1);
                                                                        var response =
                                                                            await carPricingBloc.setCarPricing(createCarResponse);

                                                                        FetchPayoutMethodResponse
                                                                            payoutDataResp =
                                                                            await carPricingBloc.callFetchPayoutMethod();
                                                                        if (payoutDataResp !=
                                                                                null &&
                                                                            payoutDataResp.payoutMethod!.payoutMethodType ==
                                                                                'payout_undefined') {
                                                                          Navigator.pushNamed(context, '/how_would_you_like_to_be_paid_out_ui', arguments: payoutDataResp)
                                                                              .then((value) {
                                                                            /*if(value!=null){

                                                }*/
                                                                            if (response !=
                                                                                null) {
                                                                              if (pushNeeded) {
                                                                                Navigator.pushNamed(context, pushRouteName!, arguments: {
                                                                                  'carResponse': response,
                                                                                  'purpose': purpose
                                                                                });
                                                                              } else {
                                                                                Navigator.pop(context, response);
                                                                              }
                                                                            } else {}
                                                                          });
                                                                        } else {
                                                                          if (response !=
                                                                              null) {
                                                                            if (pushNeeded) {
                                                                              Navigator.pushNamed(context, pushRouteName!, arguments: {
                                                                                'carResponse': response,
                                                                                'purpose': purpose
                                                                              });
                                                                            } else {
                                                                              Navigator.pop(context, response);
                                                                            }
                                                                          } else {}
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
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .white),
                                                                  )
                                                                : SizedBox(
                                                                    height:
                                                                        18.0,
                                                                    width: 18.0,
                                                                    child: new CircularProgressIndicator(
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
                                    )
                                  : SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 220,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 12.0,
                                                          right: 12),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
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
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3,
                                                child: Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 250,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0,
                                                          right: 16),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                  ),
                                                )),
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                height: 14,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                            ],
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            height: 250,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Shimmer.fromColors(
                                                baseColor: Colors.grey.shade300,
                                                highlightColor:
                                                    Colors.grey.shade100,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 16.0,
                                                          right: 16),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.grey[300],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                  ),
                                                )),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              SizedBox(
                                                height: 14,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    2,
                                                child: Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey.shade300,
                                                    highlightColor:
                                                        Colors.grey.shade100,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
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
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                            })
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                new CircularProgressIndicator(strokeWidth: 2.5)
                              ],
                            ),
                          );
                  })),
        ),
      ),
    );
  }

  void checkWithinLimit(CreateCarResponse createCarResponse,
      FetchCarSuggestedDataResponse value) {
    var pricing = createCarResponse.car!.pricing;
    if (!isInLimitInt(pricing!.rentalPricing!.perHour!.floor(),
        (value.hourlyRate! * .85).floor(), (value.hourlyRate! * 1.15).ceil())) {
      pricing!.rentalPricing!.perHour = value.hourlyRate;
    }
    if (!isInLimitInt(pricing.rentalPricing!.perDay!.floor(),
        (value.dailyRate! * .85).floor(), (value.dailyRate! * 1.15).ceil())) {
      pricing.rentalPricing!.perDay = value.dailyRate;
    }
    if (!isInLimit(pricing.rentalPricing!.perExtraKMOverLimit!, 0.00, 2.00)) {
      pricing.rentalPricing!.perExtraKMOverLimit = 0.75;
    }
    if (!isInLimit(pricing.rentalPricing!.perKMRentalDeliveryFee!, 0, 5)) {
      pricing.rentalPricing!.perKMRentalDeliveryFee = 2.0;
    }
    if (!isInLimit(
        pricing.rentalPricing!.bookForWeekDiscountPercentage!, 0, 30.0)) {
      pricing.rentalPricing!.bookForWeekDiscountPercentage = 0.0;
    }
    if (!isInLimit(
        pricing.rentalPricing!.bookForMonthDiscountPercentage!, 0, 30.0)) {
      pricing.rentalPricing!.bookForWeekDiscountPercentage = 0.0;
    }
  }

  bool isInLimit(double value, double lowerLimit, double upperLimit) {
    if (value < lowerLimit) {
      return false;
    }
    if (value > upperLimit) {
      return false;
    }

    return true;
  }

  bool isInLimitInt(int value, int lowerLimit, int upperLimit) {
    if (lowerLimit == 0 && upperLimit == 0) {
      return true;
    }
    if (value < lowerLimit) {
      return false;
    }
    if (value > upperLimit) {
      return false;
    }

    return true;
  }

  getDiscountedPrice(rate, int i, percentage) {
    // return (rate*i)*(100-percentage)/100.0;
    return ((rate * i).round());
  }
}
//
//Future<http.Response> setPricing(_carID) async {
//  var res;
//
//  try {
//    res = await http.post(
//      '$SERVER_IP/v1/car.CarService/SetPricing',
//      body: json.encode(
//        {
//          "CarID": _carID,
//          "Pricing": {
//            "RentalPricing": {
//              "PerHour": double.parse(_perOneHour.toString()).round(),
//              "PerDay": double.parse(_perOneDay.toString()).round(),
//              "PerExtraKMOverLimit": double.parse(_perExtraKm.toString()).round(),
//              "EnableCustomDelivery": _hasCustomDelivery,
//              "PerKMRentalDeliveryFee": double.parse(_perKmDeliveryFee.toString()).round(),
//              "BookForWeekDiscountPercentage": double.parse(_oneWeekDiscount.toString()).round(),
//              "BookForMonthDiscountPercentage": double.parse(_oneMonthDiscount.toString()).round(),
//              "OneTime20DiscountForFirst3Users": _oneTimeDiscount
//            },
//            "SwapPricing": {},
//            "Completed": true
//          }
//        }
//      ),
//    );
//  } catch (error) {
//
//  }
//
//  return res;
//}
