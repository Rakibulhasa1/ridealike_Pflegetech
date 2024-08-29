import 'dart:async';
import 'dart:convert' show Utf8Decoder, json;
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/pages/profile/response_service/profile_notifications_response.dart';
import 'package:ridealike/pages/trips/request_service/request_reimbursement.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_by_user_ids_response.dart';
import 'package:ridealike/pages/trips/response_model/rent_agree_carinfo_response.dart';
import 'package:ridealike/pages/trips/response_model/swap_agree_carinfo_response.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/app_events/app_events_utils.dart';

Future<RestApi.Resp> fetchProfileByUserID(userId) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getProfileByUserIDUrl,
    json.encode({
      "UserID": userId,
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
Future<RestApi.Resp> fetchNotifications(_userID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getNotificationByUserIDUrl,
    json.encode({
      "UserID": _userID,
      "Limit":"1000"
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> getTripByID(String tripID) async {
  var getTripByIDCompleter = Completer<RestApi.Resp>();
  RestApi.callAPI(getTripByIDUrl, json.encode({"TripID": tripID})).then((resp) {
    getTripByIDCompleter.complete(resp);
  });

  return getTripByIDCompleter.future;
}

Future<RestApi.Resp> getCarByID(String carID) async {
  var getTripByIDCompleter = Completer<RestApi.Resp>();
  RestApi.callAPI(getCarUrl, json.encode({"CarID": carID})).then((resp) {
    getTripByIDCompleter.complete(resp);
  });

  return getTripByIDCompleter.future;
}

Future<RestApi.Resp> getProfileByID(String userID) async {
  var getTripByIDCompleter = Completer<RestApi.Resp>();
  RestApi.callAPI(getProfileByUserIDUrl, json.encode({"UserID": userID}))
      .then((resp) {
    getTripByIDCompleter.complete(resp);
  });

  return getTripByIDCompleter.future;
}

class Notification extends StatefulWidget {
  @override
  _NotificationState createState() => _NotificationState();
}

class _NotificationState extends State<Notification> {
  ProfileNotification? _notifications;

  String? notificationTripID;

  final storage = new FlutterSecureStorage();
  Trips? tripResponse;
  DateTime? dateTime;
  bool notificationClick = false;
  var arguments = {
    'title': '',
    'body': '',
    'TripID': '',
    'NotificationType': ''
  };

  Trips? swapTripResponse;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Notification"});
    getNotifications();
  }

  getNotifications() async {
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var res = await fetchNotifications(userID);

      setState(() {
        _notifications = ProfileNotification.fromJson(json.decode(res.body!));
      });
    }
  }

  getTripCarProfileInfo(String tripID) async {
    String? userID = await storage.read(key: 'user_id');
    var tripResp = await getTripByID(tripID);
    if (tripResp != null) {
      tripResponse = Trips.fromJson(json.decode(tripResp.body!)['Trip']);
      tripResponse!.userID = userID;
    }

    var profileResponse = await getProfileByID(tripResponse!.guestUserID!);
    if (profileResponse != null) {
      tripResponse!.guestProfile =
          Profiles.fromJson(json.decode(profileResponse.body!)['Profile']);
    }

    var hostProfileResponse = await getProfileByID(tripResponse!.hostUserID!);
    if (hostProfileResponse != null) {
      tripResponse!.hostProfile =
          Profiles.fromJson(json.decode(hostProfileResponse.body!)['Profile']);
    }
    if (tripResponse!.tripType != 'Swap') {
      var rentAgreement =
      await getRentAgreementId(tripResponse!.rentAgreementID, userID);
      RentAgreementCarInfoResponse rentAgreementCarInfoResponse;
      if (rentAgreement != null && rentAgreement.statusCode == 200) {
        rentAgreementCarInfoResponse = RentAgreementCarInfoResponse.fromJson(
            json.decode(rentAgreement.body!));
        tripResponse!.car = rentAgreementCarInfoResponse.rentAgreement!.car;
        tripResponse!.carName =
            rentAgreementCarInfoResponse.rentAgreement!.car!.name;
        tripResponse!.carImageId = rentAgreementCarInfoResponse
            .rentAgreement!.car!.imagesAndDocuments!.images!.mainImageID;
        tripResponse!.carLicense = rentAgreementCarInfoResponse
            .rentAgreement!.car!.imagesAndDocuments!.license!.plateNumber;
        tripResponse!.carYear =
            rentAgreementCarInfoResponse.rentAgreement!.car!.about!.year;
      }
    } else {
      var swapTripResp = await getTripByID(tripResponse!.swapData!.otherTripID!);
      swapTripResponse = Trips.fromJson(json.decode(swapTripResp.body!)['Trip']);
      var swapTripAgreement =
      await getSwapAgreementId(swapTripResponse!.swapAgreementID, userID);
      SwapAgreementCarInfoResponse swapAgreementCarInfoResponse;
      if (swapTripAgreement != null && swapTripAgreement.statusCode == 200) {
        swapAgreementCarInfoResponse = SwapAgreementCarInfoResponse.fromJson(
            json.decode(swapTripAgreement.body!));
        tripResponse!.car =
            swapAgreementCarInfoResponse.swapAgreementTerms!.theirCar;
        tripResponse!.myCarForSwap =
            swapAgreementCarInfoResponse.swapAgreementTerms!.myCar;
        swapTripResponse!.car =
            swapAgreementCarInfoResponse.swapAgreementTerms!.myCar;
        swapTripResponse!.myCarForSwap =
            swapAgreementCarInfoResponse.swapAgreementTerms!.theirCar;
      }
    }
    String tripStatusPeriod = '';
    //TripUndefined, Booked, Cancelled, Started, Ended, Completed
    if (tripResponse!.tripStatus == 'Booked') {
      tripStatusPeriod = 'Upcoming';
    } else if (tripResponse!.tripStatus == 'Started') {
      tripStatusPeriod = 'Current';
    } else {
      tripStatusPeriod = 'Past';
    }
    if (tripResponse!.tripStatus == 'Cancelled') {
      Navigator.pushNamed(context, '/trips_cancelled_details_notification',
          arguments: {'trip': tripResponse, 'backPressPop': true})
          .then((value) {
        notificationClick = false;
      });
    } else if (tripResponse!.tripStatus == 'Cancelled' &&
        tripResponse!.tripType == 'Swap') {
      Navigator.pushNamed(context, '/trips_cancelled_details_notification',
          arguments: {'trip': tripResponse, 'backPressPop': true})
          .then((value) {
        notificationClick = false;
      });
    } else if (tripResponse!.tripType == 'Swap') {
      Navigator.pushNamed(
        context,
        '/trips_rental_details_ui',
        arguments: {
          'tripType': tripStatusPeriod,
          'trip': tripResponse,
          'backPressPop': true
        },
      ).then((value) {
        notificationClick = false;
      });
    } else if (tripResponse!.guestUserID == tripResponse!.userID) {
      Navigator.pushNamed(
        context,
        '/trips_rental_details_ui',
        arguments: {
          'tripType': tripStatusPeriod,
          'trip': tripResponse,
          'backPressPop': true
        },
      ).then((value) {
        notificationClick = false;
      });
    } else if (tripResponse!.hostUserID == tripResponse!.userID) {
      Navigator.pushNamed(context, '/trips_rent_out_details_ui', arguments: {
        'tripType': tripStatusPeriod,
        'trip': tripResponse,
        'backPressPop': true
      }).then((value) {
        notificationClick = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: new AppBar(
        title: Text('Notifications',style: TextStyle(
          fontSize: 30,fontFamily: 'Urbanist',fontWeight: FontWeight.w600
        ),),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
      ),
      body: _notifications != null?
      Column(
        children: <Widget>[
          // Header

          SizedBox(height: 10),
          Expanded(
              child: _notifications!.notification!.length != 0 ?
              ListView.builder (
                  itemCount:  _notifications!.notification!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: <Widget>[

                          InkWell( onTap:(){
                            if(!notificationClick){
                              notificationClick=true;
                              if(_notifications!.notification![index].notificationType=='TripReminder'){
                                getTripCarProfileInfo(_notifications!.notification![index].tripID!);

                              }else if(_notifications!.notification![index].notificationType=='InAppMessage'){
                                if(_notifications!.notification![index].rUserID==null
                                    ||_notifications!.notification![index].rUserID==''){

                                }else{
                                  fetchProfileByUserID(_notifications!.notification![index].rUserID).then((response) {
                                    Map profileResponse=json.decode(response.body!);
                                    String name= profileResponse['Profile']['FirstName'] +" "+ profileResponse['Profile']['LastName'];

                                    Thread threadData = new Thread(id: "1123571113",
                                        userId: _notifications!.notification![index].rUserID!,
                                        image: "",
                                        name:name,
                                        message: '',
                                        time: '',
                                        messages: []);

                                    Navigator.push(context,
                                      MaterialPageRoute( settings: RouteSettings(name: "/messages"),
                                        builder: (context) => MessageListView(thread: threadData,),),
                                    );
                                  },);
                                }


                              }
                              else{
                                arguments['title']=_notifications!.notification![index].title!;
                                arguments['body']=_notifications!.notification![index].body!;
                                Navigator.pushNamed(context, '/notifications_details', arguments: arguments).then((value){
                                  notificationClick = false;
                                });
                              }
                            }

                          },
                            child: SizedBox(
                              width: double.maxFinite,
                              child: ConstrainedBox(
                                  constraints: BoxConstraints(),
                                  child: Padding(
                                    padding: const EdgeInsets.all(0.0),
                                    child: Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xffF2F2F2),
                                            borderRadius: BorderRadius.circular(8.0),
                                            shape: BoxShape.rectangle
                                        ),

                                        child:   Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Icon(Icons.link,color: Color(0xff24d2b5),),
                                               SizedBox(width: 6,),
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(_notifications!.notification![index].title!,
                                                      style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          color: Color(0xff371D32),
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold

                                                      ),
                                                    ),
                                                     SizedBox(height: 8,),
                                                         SizedBox(
                                                           width: MediaQuery.of(context).size.width*.72,
                                                        child: Text(_notifications!.notification![index].body!,
                                                          style: TextStyle(
                                                              fontFamily: 'Urbanist',
                                                              color: Color(0xff371D32),
                                                              fontSize: 16
                                                          ),
                                                        ),
                                                      ),
                                                       SizedBox(height: 6,),
                                                     Text(
                                                        DateFormat('MMM dd, yyyy, h:mm a').format(_notifications!.notification![index].dateTime!.toLocal()),
                                                        style: TextStyle(
                                                            fontFamily: 'Urbanist',
                                                            color: Colors.black54,
                                                            fontSize: 16
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                Icon(
                                                  Icons.keyboard_arrow_right,
                                                  color: Color(0xffABABAB),
                                                  size: 18,
                                                ),
                                              ],
                                            ),
                                        ),
                                    ),
                                  ),
                              ),
                            ),

                          ),
                        ],
                      ),
                    );

                  }
              ) :Center(child: Text('Sorry! No notification found'))

          ),
        ],
      ): Center(
        child:
        SingleChildScrollView(
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
                    padding:
                    const EdgeInsets.only(left: 12.0, right: 12),
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
              height: 220,
              width: MediaQuery.of(context).size.width,
              child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Padding(
                    padding:
                    const EdgeInsets.only(left: 16.0, right: 16),
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
              height: 220,
              width: MediaQuery.of(context).size.width,
              child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Padding(
                    padding:
                    const EdgeInsets.only(left: 16.0, right: 16),
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
      )


      ),

    );
































    // Column(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: <Widget>[
    //     Text(
    //       'Notifications',
    //       style: TextStyle(
    //         color: Color(0xff371D32),
    //         fontFamily: 'Urbanist',
    //         fontWeight: FontWeight.bold,
    //         fontSize: 36,
    //       ),
    //     ),
    //     SizedBox(height: 15),
    //       ListView.builder(
    //         shrinkWrap: true,
    //         scrollDirection: Axis.vertical,
    //         itemCount: _notifications!.notification.length,
    //         itemBuilder: (context, index){
    //         return  Container(
    //           height: 50,
    //           padding: EdgeInsets.all(16),
    //
    //           decoration: BoxDecoration(
    //               color: Color(0xffF2F2F2),
    //               borderRadius: BorderRadius.circular(8),
    //               shape: BoxShape.rectangle),
    //           child: Row(
    //             crossAxisAlignment: CrossAxisAlignment.center,
    //
    //             children: <Widget>[
    //               Column(
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: <Widget>[
    //                   Text(
    //                     _notifications!.notification[index].title,
    //                     style: TextStyle(
    //                         fontSize: 16,
    //                         fontFamily: 'Urbanist',
    //                         color: Color(0xff371D32)),
    //                   ),
    //                   SizedBox(height: 5),
    //                   Text(
    //                     _notifications!.notification[index].body,
    //                     style: TextStyle(
    //                       color: Color(0xff353B50),
    //                       fontFamily: 'Urbanist',
    //                       fontSize: 14,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //               Container(
    //                 width: 16,
    //                 child: Icon(
    //                   Icons.keyboard_arrow_right,
    //                   color: Color(0xff353B50),
    //                 ),
    //               )
    //             ],
    //           ),
    //         );
    //       },
    //
    //       ),
    //   ],
    // )
  }
}