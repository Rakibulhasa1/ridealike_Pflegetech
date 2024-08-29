import 'dart:async';
import 'dart:convert' show json;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/bloc/create_car_bloc.dart';
import 'package:ridealike/pages/list_a_car/bloc/status_of_car_listing.dart';
import 'package:ridealike/pages/list_a_car/request_service/create_car_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/list_a_car/response_model/payout_method_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/sized_text.dart';
const listTextStyle = TextStyle(
  color: Color(0xff371D32),
  fontSize: 16,
  fontFamily: 'Urbanist',
  fontWeight: FontWeight.w500,
);
class WhatHappensNextUi extends StatefulWidget {
  @override
  State createState() => WhatHappensNextUiState();
}

class WhatHappensNextUiState extends State<WhatHappensNextUi> {
  final createCarBloc = CreateCarBloc();
  bool loading = false;
  int? purpose;
  CreateCarResponse? response;
bool click=false;

  @override
  void initState() {
    super.initState();
       AppEventsUtils.logEvent("view_registration_vehicle");
    var statusOfCarList = StatusOfCarList(
        StatusValue.turn,
        StatusValue.notAccessible,
        StatusValue.notAccessible,
        StatusValue.notAccessible,
        StatusValue.notAccessible,
        StatusValue.notAccessible,
        1, 0);
    createCarBloc.changedStatus.call(statusOfCarList);

    Future.delayed(Duration.zero, () async {
      dynamic data= ModalRoute.of(context)!.settings.arguments;
      if(data != null){
        response = data['carResponse'];
        response = await getCar(response!.car!.iD!);
        purpose = data['purpose'];
        createCarBloc.changedData.call(response!);
        createCarBloc.maintainStatus(response!, purpose!);
        print('verificationStatus${response!.car!.verification!.verificationStatus}');
      } else{

      }

      createCarBloc.changedProgressIndicator.call(0);

    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Colors.white,

        //App Bar
        appBar: new AppBar(
          leading: StreamBuilder<StatusOfCarList>(
            stream: createCarBloc.status,
            builder: (context, statusSnapshot) {
              return statusSnapshot.hasData && statusSnapshot.data!.purpose!=2?
                new IconButton(
                icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
                onPressed: () {

                  if(response!= null) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                  }
                },
              ):Container();
            }
          ),
          elevation: 0.0,
        ),

        //Content of tabs
        body: StreamBuilder<CreateCarResponse>(
            stream: createCarBloc.carData,
            builder: (context, carDataSnapshot) {
              return StreamBuilder<StatusOfCarList>(
                  stream: createCarBloc.status,
                  builder: (context, statusSnapshot) {
                    return statusSnapshot.hasData && statusSnapshot.data != null
                        ? Container(
                            child: new SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                children: <Widget>[
                                  // Header
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: Container(
                                                child: Text(
                                                 createCarBloc.headerText(statusSnapshot.data!.purpose),
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 36,
                                                      color: Color(0xFF371D32),
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Image.asset('icons/List-a-Car_Whats-Next.png'),
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
                                                createCarBloc.subHeaderText(statusSnapshot.data!.purpose),
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
                                  SizedBox(height: 30),
                                  // vehicle details
                                  Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: (statusSnapshot.data!.carAbout==StatusValue.turn ||statusSnapshot.data!.carAbout==StatusValue.completed)? Color(0xFFF2F2F2)
                                                      :Color(0xFFF2F2F2).withOpacity(.5),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                                ),
                                                   onPressed: () async {

                                                  if(click){

                                                    return;
                                                  }
                                                  click=true;
                                                    CreateCarResponse argument = carDataSnapshot.data!;
                                                    if(statusSnapshot.data!.carAbout==StatusValue.turn ||statusSnapshot.data!.carAbout==StatusValue.completed){
                                                      // createCarBloc.changedProgressIndicator.call(1);
                                                      if (carDataSnapshot.hasData == false || carDataSnapshot.data == null ) {
                                                        argument = await createCarBloc.createCarButton();

                                                        if (argument != null) {
                                                          createCarBloc.changedData.call(argument);
                                                          // createCarBloc.changedProgressIndicator.call(0);

                                                        } else {
                                                          // createCarBloc.changedProgressIndicator.call(0);
                                                          return;
                                                        }
                                                      } else {
                                                        argument = carDataSnapshot.data!;
                                                      }
                                                       Navigator.pushNamed(
                                                         context,
                                                         '/tell_us_about_your_car_ui',
                                                         arguments: {'carResponse': argument,'purpose':purpose},
                                                       ).then((value) {
                                                         if (value != null) {
                                                           createCarBloc.changedData.call(value as CreateCarResponse);
                                                           if(statusSnapshot.data!.carAbout==StatusValue.turn){
                                                             statusSnapshot.data!.carAbout = StatusValue.completed;
                                                             statusSnapshot.data!.imagesAndDocuments = StatusValue.turn;
                                                             statusSnapshot.data!.selection = 2;
                                                             createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                           }

                                                         }
                                                       });

                                                   }
                                                    click=false;
                                                  },
                                                  child: Row(crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          SizedText(
                                                            deviceWidth: deviceWidth,
                                                            textWidthPercentage: 0.75,
                                                            text: 'Tell us about your vehicle',
                                                            fontFamily:
                                                            'Urbanist',
                                                            fontSize: 16,
                                                            textColor: Color(
                                                                0xFF371D32),
                                                          ),
                                                        ]),
                                                      ),
                                                      statusSnapshot.data!.carAbout == StatusValue.turn
                                                          ? Padding(
                                                            padding: const EdgeInsets.only(right: 8),
                                                            child: Container(
                                                                width: 8,
                                                                height: 8,
                                                                decoration: new BoxDecoration(color: Color(0xffFF8F62), shape: BoxShape.circle,),),
                                                          )
                                                          : statusSnapshot.data!.carAbout == StatusValue.completed
                                                              ? Padding(
                                                                padding: const EdgeInsets.only(right: 4),
                                                                child: Icon(Icons.check_circle, color: Color(0xffF68E65),size: 22,),
                                                              )
                                                              : Container(),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // Photo & documents
                                  Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: (statusSnapshot.data!.imagesAndDocuments==StatusValue.turn ||statusSnapshot.data!.imagesAndDocuments==StatusValue.completed) ? Color(0xFFF2F2F2)
                                                      : Color(0xFFF2F2F2)
                                                          .withOpacity(0.5),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    if(statusSnapshot.data!.imagesAndDocuments==StatusValue.turn || statusSnapshot.data!.imagesAndDocuments==StatusValue.completed){
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/add_photos_to_your_listing_ui',
                                                          arguments: {'carResponse': carDataSnapshot.data,'purpose':purpose},
                                                      ).then((value) {
                                                        if (value != null) {
                                                          createCarBloc.changedData.call(value as CreateCarResponse);
                                                          if(statusSnapshot.data!.imagesAndDocuments==StatusValue.turn){
                                                            statusSnapshot.data!.imagesAndDocuments = StatusValue.completed;
                                                            statusSnapshot.data!.features = StatusValue.turn;
                                                            statusSnapshot.data!.selection = 3;
                                                            createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                          }
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          SizedText(
                                                            deviceWidth: deviceWidth,
                                                            textWidthPercentage: 0.75,
                                                            text: 'Upload photos and documents',
                                                            fontFamily:
                                                            'Urbanist',
                                                            fontSize: 16,
                                                            textColor: (statusSnapshot.data!.imagesAndDocuments==StatusValue.turn ||
                                                                statusSnapshot.data!.imagesAndDocuments==StatusValue.completed) ?
                                                            Color(0xFF371D32) : Color(0xFF371D32).withOpacity(0.5),
                                                          ),
                                                        ]),
                                                      ),
                                                      statusSnapshot.data!.imagesAndDocuments == StatusValue.turn
                                                          ? Padding(
                                                            padding: const EdgeInsets.only(right:8.0),
                                                            child: Container(
                                                                width: 8,
                                                                height: 8,
                                                                decoration: new BoxDecoration(color: Color(0xffFF8F62), shape: BoxShape.circle,
                                                                ),
                                                              ),
                                                          )
                                                          : statusSnapshot.data!.imagesAndDocuments == StatusValue.completed
                                                              ? Padding(
                                                                padding: const EdgeInsets.only(right: 4),
                                                                child: Icon(Icons.check_circle, color:  Color(0xffFF8F62),size: 22,),
                                                              )
                                                              : Container(),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // features
                                  Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor:(statusSnapshot.data!.features==StatusValue.turn ||statusSnapshot.data!.features==StatusValue.completed)?Color(0xFFF2F2F2):Color(0xFFF2F2F2)
                                                      .withOpacity(0.5),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    if(statusSnapshot.data!.features==StatusValue.turn ||statusSnapshot.data!.features==StatusValue.completed){
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/what_features_do_you_have_ui',
                                                        arguments: {'carResponse': carDataSnapshot.data,'purpose':purpose},
                                                      ).then((value) {
                                                        if (value != null) {
                                                          createCarBloc.changedData.call(value as  CreateCarResponse);
                                                          if(statusSnapshot.data!.features == StatusValue.turn){
                                                          statusSnapshot.data!.features = StatusValue.completed;
                                                          statusSnapshot.data!.preference = StatusValue.turn;
                                                          statusSnapshot.data!.selection = 4;
                                                          createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                          }
                                                        }
                                                      });

                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          SizedText(
                                                            deviceWidth: deviceWidth,
                                                            textWidthPercentage: 0.75,
                                                            text: 'Select your vehicle’s features',
                                                            fontFamily:
                                                            'Urbanist',
                                                            fontSize: 16,
                                                            textColor: (statusSnapshot.data!.features==StatusValue.turn ||
                                                                statusSnapshot.data!.features==StatusValue.completed) ?
                                                            Color(0xFF371D32):Color(
                                                                0xFF371D32)
                                                                .withOpacity(
                                                                0.5),
                                                          ),
                                                        ]),
                                                      ),
                                                      statusSnapshot.data!.features == StatusValue.turn ?
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 8),
                                                        child: Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration:
                                                          new BoxDecoration(color: Color(0xffFF8F62),
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                      )
                                                          : statusSnapshot.data!.features == StatusValue.completed
                                                          ? Padding(
                                                            padding: const EdgeInsets.only(right: 4),
                                                            child:
                                                            Icon(Icons.check_circle,
                                                                  color: Color(0xffFF8F62),size: 22,),
                                                          )
                                                          : Container(),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // Preferences
                                  Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: (statusSnapshot.data!.preference==StatusValue.turn ||statusSnapshot.data!.preference==StatusValue.completed)?Color(0xFFF2F2F2):Color(0xFFF2F2F2)
                                                      .withOpacity(0.5),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    if(statusSnapshot.data!.preference==StatusValue.turn ||statusSnapshot.data!.preference==StatusValue.completed){
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/set_your_car_rules_ui',
                                                        arguments:{'carResponse':  carDataSnapshot.data,'purpose':purpose},
                                                      ).then((value) {
                                                        if (value != null) {
                                                          createCarBloc.changedData.call(value as CreateCarResponse);
                                                          if(statusSnapshot.data!.preference == StatusValue.turn){
                                                          statusSnapshot.data!.preference = StatusValue.completed;
                                                          statusSnapshot.data!.availability = StatusValue.turn;
                                                          statusSnapshot.data!.selection = 5;
                                                          createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                          }
                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      SizedText(
                                                        deviceWidth: deviceWidth,
                                                        textWidthPercentage: 0.75,
                                                        text: 'Set preferences for your vehicle',
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        textColor: (statusSnapshot.data!.preference==StatusValue.turn ||
                                                            statusSnapshot.data!.preference==StatusValue.completed) ?
                                                        Color(0xFF371D32):Color(
                                                            0xFF371D32)
                                                            .withOpacity(
                                                            0.5),
                                                      ),
                                                      Container(
                                                        child: Row(children: [
                                                          Text(
                                                            '',
                                                            style: TextStyle(

                                                            ),
                                                          ),
                                                        ]),
                                                      ),
                                                      statusSnapshot.data!.preference == StatusValue.turn ?
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 8),
                                                        child: Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration:
                                                          new BoxDecoration(
                                                            color: Color(0xffFF8F62),
                                                            shape: BoxShape
                                                                .circle,
                                                          ),
                                                        ),
                                                      )
                                                          : statusSnapshot.data
                                                          !.preference ==
                                                          StatusValue
                                                              .completed
                                                          ? Padding(
                                                            padding: const EdgeInsets.only(right: 4),
                                                            child: Icon(
                                                                  Icons
                                                                      .check_circle,
                                                                  color: Color(0xffFF8F62),size: 22,
                                                            ),
                                                          )
                                                          : Container(),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // Availability
                                  Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor:(statusSnapshot.data!.availability==StatusValue.turn ||statusSnapshot.data!.availability==StatusValue.completed)?Color(0xFFF2F2F2): Color(0xFFF2F2F2)
                                                      .withOpacity(0.5),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    if(statusSnapshot.data!.availability==StatusValue.turn ||statusSnapshot.data!.availability==StatusValue.completed){
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/set_your_car_availability_ui',
                                                        arguments: {'carResponse': carDataSnapshot.data,'purpose':purpose},
                                                      ).then((value) {
                                                        if (value != null) {
                                                          createCarBloc.changedData.call(value as CreateCarResponse);
                                                          if(statusSnapshot.data!.availability==StatusValue.turn){
                                                            statusSnapshot.data!.availability = StatusValue.completed;
                                                            statusSnapshot.data!.pricing = StatusValue.turn;
                                                            statusSnapshot.data!.selection = 6;
                                                            createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                          }


                                                        }
                                                      });
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          SizedText(
                                                            deviceWidth: deviceWidth,
                                                            textWidthPercentage: 0.75,
                                                            text: 'Set your vehicle’s availability',
                                                            fontFamily:
                                                            'Urbanist',
                                                            fontSize: 16,
                                                            textColor: (statusSnapshot.data!.availability==StatusValue.turn ||
                                                                statusSnapshot.data!.availability==StatusValue.completed) ?
                                                            Color(0xFF371D32):Color(
                                                                0xFF371D32)
                                                                .withOpacity(
                                                                0.5),
                                                          ),
                                                        ]),
                                                      ),
                                                      statusSnapshot.data!.availability == StatusValue.turn ?
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 8),
                                                        child: Container(
                                                          width: 8,
                                                          height: 8,
                                                          decoration:
                                                          new BoxDecoration(
                                                            color: Color(0xffFF8F62),
                                                            shape: BoxShape
                                                                .circle,
                                                          ),
                                                        ),
                                                      )
                                                          : statusSnapshot.data!.availability == StatusValue.completed ?
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 4),
                                                        child: Icon(
                                                            Icons
                                                                .check_circle,
                                                            color: Color(0xffFF8F62),size: 22,),
                                                      )
                                                          : Container(),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // Pricing
                                  Row(mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: (statusSnapshot.data!.pricing==StatusValue.turn ||statusSnapshot.data!.pricing==StatusValue.completed)?Color(0xFFF2F2F2): Color(0xFFF2F2F2)
                                                      .withOpacity(0.5),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),),
                                                  onPressed: () {
                                                    if(statusSnapshot.data!.pricing==StatusValue.turn ||statusSnapshot.data!.pricing==StatusValue.completed){
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/price_your_car_ui',
                                                        arguments: {'carResponse': carDataSnapshot.data,'purpose':purpose},
                                                      ).then((value) async {
                                                        if (value != null) {
                                                          createCarBloc.changedData.call(value as CreateCarResponse);
                                                          if(statusSnapshot.data!.pricing==StatusValue.turn){
                                                            statusSnapshot.data!.pricing = StatusValue.completed;
                                                            FetchPayoutMethodResponse payoutDataResp= await createCarBloc.callFetchPayoutMethod();
                                                            if (payoutDataResp!=null && payoutDataResp.payoutMethod!.payoutMethodType =='payout_undefined') {
                                                              statusSnapshot.data!.selection = 7;
                                                            } else{
                                                              statusSnapshot.data!.purpose = 2;
                                                              statusSnapshot.data!.selection = 8;
                                                            }
                                                            createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                          }

                                                        }
                                                      });

                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(children: [
                                                          SizedText(
                                                            deviceWidth: deviceWidth,
                                                            textWidthPercentage: 0.75,
                                                            text: 'Set your pricing',
                                                            fontFamily:
                                                            'Urbanist',
                                                            fontSize: 16,
                                                            textColor: (statusSnapshot.data!.pricing==StatusValue.turn ||
                                                                statusSnapshot.data!.pricing==StatusValue.completed) ?
                                                            Color(0xFF371D32):Color(
                                                                0xFF371D32)
                                                                .withOpacity(
                                                                0.5),
                                                          ),
                                                        ]),
                                                      ),
                                                      statusSnapshot.data!.pricing == StatusValue.turn
                                                          ? Padding(
                                                            padding: const EdgeInsets.only(right: 8),
                                                            child: Container(
                                                        width: 8,
                                                        height: 8,
                                                        decoration:
                                                        new BoxDecoration(
                                                            color:  Color(0xffFF8F62),
                                                            shape: BoxShape
                                                                .circle,
                                                        ),
                                                      ),
                                                          )
                                                          : statusSnapshot.data!.pricing == StatusValue.completed ?
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 4),
                                                        child: Icon(
                                                            Icons
                                                                .check_circle,
                                                            color: Color(0xffFF8F62),size: 22,),
                                                      )
                                                          : Container(),
                                                    ],
                                                  )),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                statusSnapshot.data!.purpose==3? SizedBox(height: 10):Container(),
                                statusSnapshot.data!.purpose==3?
                                carDataSnapshot.data!=null &&carDataSnapshot.data!.car!=null && carDataSnapshot.data!.car!='' &&
                                    (carDataSnapshot.data!.car!.verification!.verificationStatus=='Submitted'
                                        ||carDataSnapshot.data!.car!.verification!.verificationStatus=='Verified')?
                                Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xFFF2F2F2),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),),
                                                  onPressed: () {
                                                    Navigator.pushNamed(context, '/deactivate_your_listing_tab');
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.spaceBetween,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Text(
                                                            'Deactivate your listing',
                                                            style: listTextStyle
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(right: 4),
                                                        child: Container(
                                                          width: 16,
                                                          child: Icon(Icons.keyboard_arrow_right,
                                                              color: Color(0xff353B50)),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ):Container():Container(),
                                  statusSnapshot.data!.purpose==3? SizedBox(height: 10):Container(),

                                  statusSnapshot.data!.purpose==3?
                                  carDataSnapshot.data!=null &&carDataSnapshot.data!.car!=null && carDataSnapshot.data!.car!='' &&
                                      (carDataSnapshot.data!.car!.verification!.verificationStatus=='Updated'
                                          ||carDataSnapshot.data!.car!.verification!.verificationStatus=='Verified')?
                                  Container() : Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xffFF8F68),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),),
                                                  onPressed: () async {
                                                    var response = await requestToVerifyListedCar(carDataSnapshot.data!.car!.iD);
                                                    var resRequest=json.decode(response.body!);
                                                    print('responseRequest${resRequest['Status']}');

                                                    Navigator.pushNamed(
                                                      context,
                                                      '/listing_completed',
                                                    ).then((value) {
                                                      createCarBloc.changedProgressIndicator.call(0);
                                                    });
                                                  },
                                                  child: Align(
                                                    child: Text(
                                                      'Save',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(fontFamily: 'Urbanist', fontSize: 18, color: Colors.white),
                                                    ),alignment: Alignment.center,
                                                  )
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ) :  Container(),
                                  SizedBox(height: 30),
                                statusSnapshot.data!.purpose!=3?
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: StreamBuilder<bool>(
                                                  stream:
                                                      createCarBloc.nextButton,
                                                  builder:
                                                      (context, snapshot1) {
                                                    return StreamBuilder<int>(
                                                        stream: createCarBloc.progressIndicator,
                                                        builder: (context, progressIndicatorSnapshot) {
                                                        return
                                                          ElevatedButton(style: ElevatedButton.styleFrom(
                                                          elevation: 0.0,
                                                          backgroundColor
                                                              : Color(0xffFF8F68),
                                                          padding: EdgeInsets.all(16.0),
                                                          shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(8.0)),),
                                                          onPressed: progressIndicatorSnapshot.data==1? null:() async {
                                                            createCarBloc.changedProgressIndicator.call(1);
                                                            CreateCarResponse argument;
                                                            if (carDataSnapshot.hasData == false || carDataSnapshot.data == null ) {
                                                              argument = await createCarBloc.createCarButton();

                                                              if (argument != null) {
                                                                createCarBloc.changedData.call(argument);
                                                              } else {
                                                                createCarBloc.changedProgressIndicator.call(0);
                                                                return;
                                                              }
                                                            } else {
                                                              argument = carDataSnapshot.data!;
                                                            }

                                                            print('argumentButton$argument');
                                                            if (argument != null) {


                                                              if (statusSnapshot.data!.selection == 1) {
                                                                Navigator.pushNamed(
                                                                  context,
                                                                  '/tell_us_about_your_car_ui',
                                                                  arguments: {'carResponse': CreateCarResponse.fromJson(argument.toJson()),'purpose':purpose},
                                                                ).then((value) {
                                                                  createCarBloc.changedProgressIndicator.call(0);
                                                                  if (value != null) {
                                                                    createCarBloc.changedData.call(value as CreateCarResponse);
                                                                    statusSnapshot.data!.carAbout = StatusValue.completed;
                                                                    statusSnapshot.data!.imagesAndDocuments = StatusValue.turn;
                                                                    statusSnapshot.data!.selection = 2;
                                                                    createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                                  }
                                                                });
                                                              } else if(statusSnapshot.data!.selection == 2){
                                                                Navigator.pushNamed(
                                                                  context,
                                                                  '/add_photos_to_your_listing_ui',
                                                                  arguments:  {'carResponse':  CreateCarResponse.fromJson(argument.toJson()),'purpose':purpose},
                                                                ).then((value) {
                                                                  createCarBloc.changedProgressIndicator.call(0);
                                                                  if (value != null) {
                                                                    createCarBloc.changedData.call(value as CreateCarResponse);
                                                                    statusSnapshot.data!.imagesAndDocuments = StatusValue.completed;
                                                                    statusSnapshot.data!.features = StatusValue.turn;
                                                                    statusSnapshot.data!.selection = 3;
                                                                    createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                                  }
                                                                });
                                                              } else if(statusSnapshot.data!.selection == 3){
                                                                Navigator.pushNamed(
                                                                  context,
                                                                  '/what_features_do_you_have_ui',
                                                                  arguments:  {'carResponse': CreateCarResponse.fromJson(argument.toJson()),'purpose':purpose},
                                                                ).then((value) {
                                                                  createCarBloc.changedProgressIndicator.call(0);
                                                                  if (value != null) {
                                                                    createCarBloc.changedData.call(value as CreateCarResponse);
                                                                    statusSnapshot.data!.features = StatusValue.completed;
                                                                    statusSnapshot.data!.preference = StatusValue.turn;
                                                                    statusSnapshot.data!.selection = 4;
                                                                    createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                                  }
                                                                });


                                                              } else if(statusSnapshot.data!.selection == 4){
                                                                Navigator.pushNamed(
                                                                  context,
                                                                  '/set_your_car_rules_ui',
                                                                  arguments: {'carResponse': CreateCarResponse.fromJson(argument.toJson()),'purpose':purpose},
                                                                ).then((value) {
                                                                  createCarBloc.changedProgressIndicator.call(0);
                                                                  if (value != null) {
                                                                    createCarBloc.changedData.call(value  as CreateCarResponse);
                                                                    statusSnapshot.data!.preference = StatusValue.completed;
                                                                    statusSnapshot.data!.availability = StatusValue.turn;
                                                                    statusSnapshot.data!.selection = 5;
                                                                    createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                                  }
                                                                });

                                                              } else if(statusSnapshot.data!.selection == 5){
                                                                Navigator.pushNamed(
                                                                  context,
                                                                  '/set_your_car_availability_ui',
                                                                  arguments: {'carResponse': CreateCarResponse.fromJson(argument.toJson()),'purpose':purpose},
                                                                ).then((value) {
                                                                  createCarBloc.changedProgressIndicator.call(0);
                                                                  if (value != null) {
                                                                    createCarBloc.changedData.call(value as CreateCarResponse);
                                                                    statusSnapshot.data!.availability = StatusValue.completed;
                                                                    statusSnapshot.data!.pricing = StatusValue.turn;
                                                                    statusSnapshot.data!.selection = 6;
                                                                    createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                                  }
                                                                });

                                                              } else if(statusSnapshot.data!.selection == 6){
                                                                Navigator.pushNamed(
                                                                  context,
                                                                  '/price_your_car_ui',
                                                                  arguments: {'carResponse':  CreateCarResponse.fromJson(argument.toJson()),'purpose':purpose},
                                                                ).then((value) async {
                                                                  if (value != null) {
                                                                    createCarBloc.changedData.call(value as CreateCarResponse);
                                                                    statusSnapshot.data!.pricing = StatusValue.completed;
                                                                    FetchPayoutMethodResponse payoutDataResp= await createCarBloc.callFetchPayoutMethod();
                                                                    if (payoutDataResp!=null && payoutDataResp.payoutMethod!.payoutMethodType =='payout_undefined') {
                                                                      statusSnapshot.data!.selection = 7;
                                                                    } else{
                                                                      statusSnapshot.data!.purpose = 2;
                                                                      statusSnapshot.data!.selection = 8;
                                                                    }
                                                                    createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                                  }
                                                                  createCarBloc.changedProgressIndicator.call(0);

                                                                });
                                                              }else if(statusSnapshot.data!.selection == 7){

                                                                FetchPayoutMethodResponse payoutDataResp= await createCarBloc.callFetchPayoutMethod();
                                                                if (payoutDataResp!=null && payoutDataResp.payoutMethod!.payoutMethodType =='payout_undefined') {
                                                                  Navigator.pushNamed(
                                                                    context,
                                                                    '/how_would_you_like_to_be_paid_out_ui',arguments: payoutDataResp).then((value){
                                                                    createCarBloc.changedProgressIndicator.call(0);
                                                                    if(value!=null){
                                                                      statusSnapshot.data!.purpose=2;
                                                                      statusSnapshot.data!.selection=8;
                                                                      createCarBloc.changedData.call( carDataSnapshot.data!);
                                                                      createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                                    }
                                                                  });
                                                                } else {
                                                                  createCarBloc.changedProgressIndicator.call(0);
                                                                  statusSnapshot.data!.purpose=2;
                                                                  statusSnapshot.data!.selection=8;
                                                                  createCarBloc.changedData.call( carDataSnapshot.data!);
                                                                  createCarBloc.changedStatus.call(statusSnapshot.data!);
                                                                }

                                                              }
                                                              else if(statusSnapshot.data!.selection == 8){
                                                                 if( statusSnapshot.data!.purpose==2){
                                                                     var response = await requestToVerifyListedCar(carDataSnapshot.data!.car!.iD);
                                                                     var resRequest=json.decode(response.body!);
                                                                     var status = resRequest['Status'];
                                                                     AppEventsUtils.logEvent("vehicle_listing_complete",
                                                                        params: 
                                                                           { "vehicleRegistration":"complete",
                                                                           "vehicleVerifyRequestStatus":status['success'],
                                                                         "is_host": true
                                        
                                                                           });
                                                                     print('responseRequest${resRequest['Status']}');
                                                                  }
                                                                     
                                                                  Navigator.pushNamed(
                                                                    context,
                                                                    '/listing_completed',
                                                                  ).then((value) {
                                                                    createCarBloc.changedProgressIndicator.call(0);
                                                                  });

                                                              } else{
                                                                createCarBloc.changedProgressIndicator.call(0);

                                                              }
                                                            }
                                                          },
                                                          child:
                                                                progressIndicatorSnapshot.hasData && progressIndicatorSnapshot.data==0
                                                                    ?  Text(createCarBloc.buttonText(statusSnapshot.data!.purpose),
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle(fontFamily: 'Urbanist', fontSize: 18, color: Colors.white),) :SizedBox(
                                                                  height: 18.0,
                                                                  width: 18.0,
                                                                  child: new CircularProgressIndicator(strokeWidth: 2.5),
                                                                ),

                                                        );
                                                      }
                                                    );
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ):Container(),
                                ],
                              ),
                            ),
                          ))
                        : Container();
                  });
            }));
  }

  void callFunction(var arguments) {
    print('argumentButton$arguments');
    if (arguments != null) {
      Navigator.pushNamed(
        context,
        '/tell_us_about_your_car_ui',
        arguments: arguments,
      );
    }
  }
}

Future<CreateCarResponse> getCar(String carId) async {
  var completer = Completer<CreateCarResponse>();

  callAPI(
    getCarUrl,
    json.encode({
      "CarID": carId
    }),
  ).then((resp) {
    var res = CreateCarResponse.fromJson(json.decode(resp.body!));
    completer.complete(res);
  });

  return completer.future;
}