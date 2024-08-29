import 'dart:async';
import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/book_a_car/booking_info.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/pages/trips/bloc/end_trip_bloc.dart';
import 'package:ridealike/pages/trips/bloc/host_inspection_info_bloc.dart';
import 'package:ridealike/pages/trips/bloc/inspection_info_bloc.dart';
import 'package:ridealike/pages/trips/bloc/trips_rental_bloc.dart';
import 'package:ridealike/pages/trips/change_request/host_ui/host_view.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/inspection_info_response.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:ridealike/widgets/buton.dart';
import 'package:ridealike/widgets/cancel_modal.dart';
import 'package:ridealike/widgets/experience_modal.dart';
import 'package:ridealike/widgets/list_row.dart';
import 'package:ridealike/widgets/sized_text.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/app_events/app_events_utils.dart';
class TripsRentOutDetails extends StatefulWidget {
  @override
  _TripsRentOutDetailsState createState() => _TripsRentOutDetailsState();
}

class _TripsRentOutDetailsState extends State<TripsRentOutDetails> {
  final tripsRentedOutBloc = TripsRentalBloc();
  final endTripRentalBloc = EndTripRentalBloc();
  String? insuranceType;
  String changeRequestCount = "0";
  Trips? swapTripResponse;
  final storage = new FlutterSecureStorage();
  final inspectionInfoBloc = InspectionInfoBloc();
  final hostinspectionInfoBloc = HostButtonInspectionInfoBloc();
bool startprepickupbutton = true;

  void handleShowCancelModal(tripData) {
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
        return CancelModal(tripData: tripData
          // onCahngeNote: handleChangeNote,
          // onPressCancel: handleCancel,
        );
      },
    );
  }

  void handleCancel() {
    Navigator.of(context).pop();
    showModalBottomSheet(
      isScrollControlled: true,
      enableDrag: false,
      isDismissible: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return ExperienceModal(
            onPress: handleCancelConfirm,
            experienceImageSrc: "icons/Experience_Bad.png",
            title: "We are sorry to hear you had a bad experience.",
            subtitle:
            "Our team is working o your case and we'll get back to you shortly.");
      },
    );
  }

  void handleCancelConfirm() {
    Navigator.of(context).pop();
  }

  // void handleShowReimbursementModal(tripID) {
  //   showModalBottomSheet(
  //     isScrollControlled: true,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(10),
  //         topRight: Radius.circular(10),
  //       ),
  //     ),
  //     context: context,
  //     builder: (context) {
  //       return Wrap(children: [ReimbursementModalUi(tripID: tripID)]);
  //     },
  //   );
  // }

  var _bookingInfo = {
    "carID": '',
    "userID": '',
    "location": '',
    "locAddress": '',
    "locLat": '',
    "locLong": '',
    "startDate": DateTime.now().toUtc().toIso8601String(),
    "endDate": DateTime.now().add(Duration(days: 4)).toUtc().toIso8601String(),
    "insuranceType": 'Minimum',
    "deliveryNeeded": false,
    "calendarID": ''
  };

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
        return BookingInfo(bookingInfo: _bookingInfo);
      },
    );
  }

  // Future<RestApi.Resp> getTripByID(String tripID) async {
  //   var getTripByIDCompleter = Completer<RestApi.Resp>();
  //   RestApi.callAPI(getTripByIDUrl, json.encode({"TripID": tripID})).then((resp) {
  //     getTripByIDCompleter.complete(resp);
  //   });
  //
  //   return getTripByIDCompleter.future;
  // }
  //
  // Future<RestApi.Resp> getProfileByID(String userID) async {
  //   var getTripByIDCompleter = Completer<RestApi.Resp>();
  //   RestApi.callAPI(getProfileByUserIDUrl, json.encode({"UserID": userID}))
  //       .then((resp) {
  //     getTripByIDCompleter.complete(resp);
  //   });
  //
  //   return getTripByIDCompleter.future;
  // }
  //
  //
  // Future<Resp>getRentAgreementId(rentAgreementID,userId) async {
  //
  //   var rentAgreementIdCompleter=Completer<Resp>();
  //   callAPI(getRentAgreementUrl,
  //       json.encode(
  //           {
  //             "RentAgreementID": rentAgreementID,
  //             "UserID":userId
  //           }
  //       )).then((resp){
  //     rentAgreementIdCompleter.complete(resp);
  //   });
  //   return rentAgreementIdCompleter.future;
  // }
  // Future<Resp>getSwapAgreementId(swapAgreementID,userId) async {
  //
  //   var rentAgreementIdCompleter=Completer<Resp>();
  //   callAPI(getSwapArgeementTermsUrl,
  //       json.encode(
  //           {
  //             "SwapAgreementID":swapAgreementID,
  //             "UserID":userId
  //           }
  //       )).then((resp){
  //     rentAgreementIdCompleter.complete(resp);
  //   });
  //   return rentAgreementIdCompleter.future;
  // }
  getInsuranceAndChangeRequestInfo(bookID) async {
    try {
      var response = await HttpClient.post(
          getBookingByIDUrl, {"BookingID": "$bookID"},
          token: await storage.read(key: 'jwt') ?? '') ;
      insuranceType = response['Booking']["Params"]["InsuranceType"];
      changeRequestCount = response['Booking']["NoOfTripRequests"];
      print("$insuranceType ==========");
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  // void loadNewData(value,changeRequest)async{
  //   // String userID = await storage.read(key: 'user_id');
  //   // var tripResp = await getTripByID(tripID);
  //   // if (tripResp != null) {
  //   //   tripDetails = Trips.fromJson(json.decode(tripResp.body!)['Trip']);
  //   //   tripDetails.userID = userID;
  //   // }
  //   //
  //   // var profileResponse = await getProfileByID(tripDetails.guestUserID);
  //   // if (profileResponse != null) {
  //   //   tripDetails.guestProfile =
  //   //       Profiles.fromJson(json.decode(profileResponse.body!)['Profile']);
  //   // }
  //   //
  //   // var hostProfileResponse = await getProfileByID(tripDetails.hostUserID);
  //   // if (hostProfileResponse != null) {
  //   //   tripDetails.hostProfile =
  //   //       Profiles.fromJson(json.decode(hostProfileResponse.body!)['Profile']);
  //   // }
  //   // if (tripDetails.tripType != 'Swap') {
  //   //   var rentAgreement =
  //   //   await getRentAgreementId(tripDetails.rentAgreementID, userID);
  //   //   RentAgreementCarInfoResponse rentAgreementCarInfoResponse;
  //   //   if (rentAgreement != null && rentAgreement.statusCode == 200) {
  //   //     rentAgreementCarInfoResponse = RentAgreementCarInfoResponse.fromJson(
  //   //         json.decode(rentAgreement.body!));
  //   //     tripDetails.car = rentAgreementCarInfoResponse.rentAgreement.car;
  //   //     tripDetails.carName =
  //   //         rentAgreementCarInfoResponse.rentAgreement.car!.name;
  //   //     tripDetails.carImageId = rentAgreementCarInfoResponse
  //   //         .rentAgreement.car!.imagesAndDocuments!.images!.mainImageID;
  //   //     tripDetails.carLicense = rentAgreementCarInfoResponse
  //   //         .rentAgreement.car!.imagesAndDocuments.license.plateNumber;
  //   //     tripDetails.carYear =
  //   //         rentAgreementCarInfoResponse.rentAgreement.car!.about.year;
  //   //   }
  //   // } else {
  //   //   var swapTripResp = await getTripByID(tripDetails.swapData!.otherTripID);
  //   //   swapTripResponse = Trips.fromJson(json.decode(swapTripResp.body!)['Trip']);
  //   //   var swapTripAgreement =
  //   //   await getSwapAgreementId(swapTripResponse.swapAgreementID, userID);
  //   //   SwapAgreementCarInfoResponse swapAgreementCarInfoResponse;
  //   //   if (swapTripAgreement != null && swapTripAgreement.statusCode == 200) {
  //   //     swapAgreementCarInfoResponse = SwapAgreementCarInfoResponse.fromJson(
  //   //         json.decode(swapTripAgreement.body!));
  //   //     tripDetails.car =
  //   //         swapAgreementCarInfoResponse.swapAgreementTerms.theirCar;
  //   //     tripDetails.myCarForSwap =
  //   //         swapAgreementCarInfoResponse.swapAgreementTerms.myCar;
  //   //     swapTripResponse.car =
  //   //         swapAgreementCarInfoResponse.swapAgreementTerms.myCar;
  //   //     swapTripResponse.myCarForSwap =
  //   //         swapAgreementCarInfoResponse.swapAgreementTerms.theirCar;
  //   //   }
  //   // }
  //   //
  //   // setState(() {
  //   //
  //   // });
  //
  //
  //
  //
  //   if(value==true){
  //     changeRequest= false;
  //   }
  //   setState(() {
  //
  //   });
  // }
  bool _isShow = true;
  dynamic receivedData;
  Trips? tripDetails;
  String? tripType;
  String? dash;
  InspectionInfo? inspectioninfo;
bool buttonclickabe = true;

  @override
  initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Trips Rented Out Details"});
    Timer(
        const Duration(seconds: 5),
            () => setState(() {
          _isShow = true;
        }));
    Future.delayed(Duration.zero, () {

      receivedData = ModalRoute.of(context)!.settings.arguments;
      tripDetails = receivedData!['trip'];
      tripType = receivedData!['tripType'];
      InspectionInfo? inspectionInfo = receivedData!['inspectionData'];
      getInsuranceAndChangeRequestInfo(tripDetails!.bookingID);
      dash = receivedData!['dashboard'];
      tripsRentedOutBloc.changedTripsData.call(tripDetails!);
      tripsRentedOutBloc.changedTripsTypeData.call(tripType!);
      tripsRentedOutBloc.getTripByIdMethod(tripDetails!);
      tripsRentedOutBloc.changedProgressIndicator.call(0);
      inspectioninfo = receivedData!['inspectionData'];
      inspectionInfoBloc.getInspectionInfoByTripID(tripDetails!.tripID!);
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<String>(
          stream: tripsRentedOutBloc.tripsType,
          builder: (context, tripsTypeSnapshot) {
            return tripsTypeSnapshot.hasData && tripsTypeSnapshot.data != null
                ? StreamBuilder<Trips>(
                stream: tripsRentedOutBloc.tripsData,
                builder: (context, tripsDataSnapshot) {
                  return tripsDataSnapshot.hasData &&
                      tripsDataSnapshot.data != null
                      ? Container(
                    child: Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
//                                        margin: EdgeInsets.only(top: 25.0),
                              child: Stack(
                                children: <Widget>[
                                  (tripsDataSnapshot
                                      .data!.carImageId !=
                                      null &&
                                      tripsDataSnapshot
                                          .data!.carImageId !=
                                          '')
                                      ? Image.network(
                                    '$storageServerUrl/${tripsDataSnapshot.data!.carImageId}',
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: 250,
                                  )
                                      : Image.asset(
                                      'images/car-placeholder.png'),
                                  Container(
                                    height: 60.0,
                                    margin: EdgeInsets.only(
                                        top: 5.0,
                                        right: 10.0,
                                        left: 10.0),
                                    child: Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            Map argument = {
                                              "Index": tripType ==
                                                  'Upcoming'
                                                  ? 0
                                                  : tripType ==
                                                  'Current'
                                                  ? 1
                                                  : 2
                                            };
                                            // Navigator.pop(context);
                                            if(receivedData!['backPressPop']!= null &&receivedData!['backPressPop'] ){
                                              Navigator.pop(context);
                                            } else {
                                              Map argument = {
                                                "Index": tripType ==
                                                    'Upcoming'
                                                    ? 0
                                                    : tripType ==
                                                    'Current'
                                                    ? 1
                                                    : 2
                                              };
                                              Navigator.pushNamed(
                                                  context, '/trips',
                                                  arguments: argument
                                                // arguments: arguments,
                                              );
                                            }
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white,
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(8.0),
                                              child: Icon(
                                                  Icons.arrow_back),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10.0,
                                        ),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                              BorderRadius
                                                  .circular(12.0),
                                            ),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets
                                                  .all(12.0),
                                              child: Text(
                                                " ${tripsTypeSnapshot.data} rent out",
                                                style: TextStyle(
                                                    fontFamily:
                                                    'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(
                                                        0xFF353B50)),
                                                textAlign:
                                                TextAlign.center,
                                              ),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 24,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'TRIP ID: ' +
                                              (tripDetails!.tripType ==
                                                  'Swap'
                                                  ? 'SBN${tripDetails!.swapData!.SBN}'
                                                  : 'RBN${tripDetails!.rBN}'),
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 12,
                                            color: Color(0xff371D32)
                                                .withOpacity(0.5),
                                          ),
                                          // textAlign: TextAlign.start,
                                        ),
                                        Divider(
                                            color: Color(0xFFE7EAEB)),



                                      //  SizedBox(height: 20),

                                        Text(
                                          "TRIP DETAILS",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 12,
                                              color: Color(0xFF371D32)
                                                  .withOpacity(0.5)),
                                        ),
                                        SizedBox(height:15),
                                        // ListHead(
                                        //   title: 'TRIP DETAILS',
                                        // ),
                                        ListRow(
                                          leading: Image.asset(
                                            'icons/Calendar_Manage-Calendar.png',
                                            width: 16,
                                            color: Color.fromRGBO(
                                                55, 29, 50, 1),
                                          ),
                                          title: Text(
                                            "Pickup",
                                            style: TextStyle(
                                                fontFamily:
                                                'Urbanist',
                                                fontSize: 16,
                                                color: Color(
                                                    0xFF371D32)),
                                          ),
                                          trailing: Text(
                                            DateFormat(
                                                'EEE, MMM dd, hh:00 a')
                                                .format(
                                                tripsDataSnapshot
                                                    .data!
                                                    .startDateTime!
                                                    .toLocal()),
                                            style: TextStyle(
                                                fontFamily:
                                                'Urbanist',
                                                fontSize: 12,
                                                color: Color(
                                                    0xFF353B50)),
                                          ),
                                        ),
                                        ListRow(
                                          leading: Image.asset(
                                            'icons/Calendar_Manage-Calendar.png',
                                            width: 16,
                                            color: Color.fromRGBO(
                                                55, 29, 50, 1),
                                          ),
                                          title: Text(
                                            "Return",
                                            style: TextStyle(
                                                fontFamily:
                                                'Urbanist',
                                                fontSize: 16,
                                                color: Color(
                                                    0xFF371D32)),
                                          ),
                                          trailing: Text(
                                            DateFormat(
                                                'EEE, MMM dd, hh:00 a')
                                                .format(
                                                tripsDataSnapshot
                                                    .data!
                                                    .endDateTime!
                                                    .toLocal()),
                                            style: TextStyle(
                                                fontFamily:
                                                'Urbanist',
                                                fontSize: 12,
                                                color: Color(
                                                    0xFF353B50)),
                                          ),
                                        ),

                                        ///location//
//                                                   Padding(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             left: 16),
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: <Widget>[
//                                                         Row(
//                                                           children: <Widget>[
//                                                             Image.asset(
//                                                               'icons/Location_Car-Location.png',
//                                                               width: 16,
//                                                               color: Color
//                                                                   .fromRGBO(
//                                                                       55,
//                                                                       29,
//                                                                       50,
//                                                                       1),
//                                                             ),
//                                                             SizedBox(
//                                                               width: 8,
//                                                             ),
//                                                             Text(
//                                                               "Location",
//                                                               style: TextStyle(
//                                                                   fontFamily:
//                                                                       'Urbanist',
//                                                                   fontSize: 16,
//                                                                   color: Color(
//                                                                       0xFF371D32)),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                       ],
//                                                     ),
//                                                   ),
//                                                   SizedBox(
//                                                     height: 8,
//                                                   ),
//                                                   Padding(
//                                                     padding:
//                                                         const EdgeInsets.only(
//                                                             left: 16),
//                                                     child: Row(
//                                                       mainAxisAlignment:
//                                                           MainAxisAlignment
//                                                               .spaceBetween,
//                                                       children: <Widget>[
//                                                         SizedBox(
//                                                           width: MediaQuery.of(
//                                                                       context)
//                                                                   .size
//                                                                   .width *
//                                                               0.85,
//                                                           child: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                         .only(
//                                                                     left: 10),
//                                                             child: AutoSizeText(
//                                                               tripsDataSnapshot.data!.location.formattedAddress,
//                                                               overflow:
//                                                                   TextOverflow
//                                                                       .ellipsis,
//                                                               style: TextStyle(
//                                                                   fontFamily:
//                                                                       'Urbanist',
//                                                                   fontSize: 12,
//                                                                   color: Color(
//                                                                       0xFF353B50)),
//                                                               maxLines: 3,
//                                                             ),
//                                                           ),
// //                                                width: 345,
//                                                         ),
//                                                         // Padding(
//                                                         //   padding: const EdgeInsets.only(
//                                                         //       right: 10),
//                                                         //   child: Icon(
//                                                         //     Icons.arrow_forward_ios,
//                                                         //     size: 15,
//                                                         //   ),
//                                                         // )
//                                                       ],
//                                                     ),
//                                                   ),

                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: <Widget>[
                                            Row(

                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                ),
                                                SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  "Location",
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(
                                                          0xFF371D32)),
                                                ),
                                                SizedBox(width: 20)
                                              ],
                                            ),
                                            Flexible(
                                              child:
                                              AutoSizeText(
                                                tripsDataSnapshot.data?.returnLocation?.formattedAddress ??
                                                    tripsDataSnapshot.data?.location?.address ??
                                                    '',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 12,
                                                  color: Color(0xFF353B50),
                                                ),
                                                maxLines: 3,
                                              ),

                                              // AutoSizeText(
                                              //   tripsDataSnapshot.data!
                                              //       .returnLocation !=
                                              //       null
                                              //       ? tripsDataSnapshot
                                              //       .data!
                                              //       .returnLocation!
                                              //       .formattedAddress
                                              //       : tripsDataSnapshot
                                              //       .data!
                                              //       .location
                                              //       .address,
                                              //
                                              //   overflow: TextOverflow
                                              //       .ellipsis,
                                              //   style: TextStyle(
                                              //       fontFamily:
                                              //       'Urbanist',
                                              //       fontSize: 12,
                                              //       color: Color(
                                              //           0xFF353B50)),
                                              //   maxLines: 3,
                                              // ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8),
                                        Divider(),
                                        Row(children: [
                                          Image.asset(
                                            'icons/car-insurance.png',
                                            color: Color(
                                              0xff371D32,
                                            ),
                                            height: 20,
                                            width: 18,
                                          ),
                                          SizedBox(width: 10),
                                          Text("Insurance",
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 16,
                                                  color:
                                                  Color(0xFF371D32))),
                                          Spacer(),
                                          Text(
                                              insuranceType == "Minimum"
                                                  ? "Standard"
                                                  : "Premium",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF353B50)))
                                        ]),
Divider(),
                                        Row(children: [
                                          Image.asset(
                                            'icons/fast-delivery.png',
                                            color: Color(
                                              0xff371D32,
                                            ),
                                            height: 20,
                                            width: 18,
                                          ),
                                          SizedBox(width: 10),
                                          Text("Delivery Needed",
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 16,
                                                  color:
                                                  Color(0xFF371D32))),
                                          Spacer(),
                                          Text(
                                              tripDetails!.deliveryNeeded!
                                                  ? "Yes"
                                                  : "No",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF353B50)))
                                        ]),

                                        //location//

                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          child: Column(
                                            children: [
                                              // ListHead(title: 'BOOKING DETAILS',),
                                              ListRow(
                                                leading: Center(
                                                  child: (tripsDataSnapshot
                                                      .data!
                                                      .carImageId !=
                                                      null &&
                                                      tripsDataSnapshot
                                                          .data!
                                                          .carImageId !=
                                                          '')
                                                      ? CircleAvatar(
                                                    backgroundImage:
                                                    NetworkImage(
                                                        '$storageServerUrl/${tripsDataSnapshot.data!.carImageId}'),
                                                    radius: 17.5,
                                                  )
                                                      : CircleAvatar(
                                                    backgroundImage:
                                                    AssetImage(
                                                        'images/car-placeholder.png'),
                                                    radius: 17.5,
                                                  ),
                                                ),
                                                title: Text(
                                                  "Booked Car",
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(
                                                          0xFF371D32)),
                                                ),
                                                trailing: Text(
                                                  tripsDataSnapshot
                                                      .data!.car!.about!.year! +
                                                      ' ' +
                                                      tripsDataSnapshot.data
                                                          !.car!.about!.make! +
                                                      ' ' +
                                                      tripsDataSnapshot.data
                                                          !.car!.about!.model!,
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Urbanist',
                                                      fontSize: 12,
                                                      color: Color(
                                                          0xFF353B50)),
                                                ),
                                              ),
                                              tripDetails!.guestProfile!
                                                  .verificationStatus ==
                                                  "Undefined"
                                                  ? Container()
                                                  : InkWell(
                                                onTap: () {
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/trips_guest_profile_ui',
                                                    arguments: {
                                                      'guestUserID':
                                                      tripDetails
                                                          !.guestUserID,
                                                      'guestProfileID':
                                                      tripDetails
                                                          !.guestProfile!
                                                          .profileID
                                                    },
                                                  );
                                                },
                                                child: ListRow(
                                                  leading: Center(
                                                    child: (tripsDataSnapshot
                                                        .data!
                                                        .guestProfile!
                                                        .imageID !=
                                                        null &&
                                                        tripsDataSnapshot
                                                            .data!
                                                            .guestProfile!
                                                            .imageID !=
                                                            '')
                                                        ? CircleAvatar(
                                                      backgroundImage:
                                                      NetworkImage(
                                                          '$storageServerUrl/${tripsDataSnapshot.data!.guestProfile!.imageID}'),
                                                      radius:
                                                      17.5,
                                                    )
                                                        : CircleAvatar(
                                                      backgroundImage:
                                                      AssetImage(
                                                          'images/user.png'),
                                                      radius:
                                                      17.5,
                                                    ),
                                                  ),
                                                  title: Text(
                                                    "Guest",
                                                    style: TextStyle(
                                                        fontFamily:
                                                        'Urbanist',
                                                        fontSize: 16,
                                                        color: Color(
                                                            0xFF371D32)),
                                                  ),
                                                  trailing: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .end,
                                                    children: [
                                                      Text(
                                                        '${tripsDataSnapshot.data!.guestProfile!.firstName} ${tripsDataSnapshot.data!.guestProfile!.lastName}',
                                                        style: TextStyle(
                                                            fontFamily:
                                                            'Urbanist',
                                                            fontSize:
                                                            12,
                                                            color: Color(
                                                                0xFF353B50)),
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Icon(Icons
                                                          .chevron_right),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              //trips earnings//
                                              // tripsTypeSnapshot.data == 'Past' ?
                                              InkWell(
                                                onTap: () {
                                                  tripDetails
                                                      !.noOfTripRequest =
                                                      changeRequestCount;
                                                  if (changeRequestCount !=
                                                      "0") {
                                                    Navigator.pushNamed(
                                                        context,
                                                        '/receipt_list',
                                                        arguments:
                                                        tripDetails);
                                                  } else {
                                                    Navigator.pushNamed(
                                                        context, '/receipt',
                                                        arguments:
                                                        tripDetails);
                                                  }
                                                },
                                                child: ListRow(
                                                  title: Text(
                                                    tripsDataSnapshot.data!
                                                        .hostTotal! >
                                                        0.0
                                                        ? "Trip earnings"
                                                        : "Total Receivable",
                                                    style: TextStyle(
                                                        fontFamily:
                                                        'Urbanist',
                                                        fontSize: 16,
                                                        color: Color(
                                                            0xFF371D32)),
                                                  ),
                                                  trailing: Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .end,
                                                    children: [
                                                      Text(
                                                        "\$${tripsDataSnapshot.data!.newHostTotal![int.parse(changeRequestCount)].toStringAsFixed(2).replaceAll("-", "")}",
                                                        style: TextStyle(
                                                            fontFamily:
                                                            'Urbanist',
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xFF353B50)),
                                                        overflow:
                                                        TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      Icon(Icons
                                                          .chevron_right),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),

                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Thread threadData = new Thread(
                                                    id: "1123571113",
                                                    userId: tripsDataSnapshot
                                                        .data!
                                                        .guestProfile
                                                        !.userID!,
                                                    image: tripsDataSnapshot
                                                        .data!
                                                        .guestProfile!
                                                        .imageID !=
                                                        ""
                                                        ? tripsDataSnapshot
                                                        .data!
                                                        .guestProfile!
                                                        .imageID!
                                                        : "",
                                                    name: tripsDataSnapshot
                                                        .data!
                                                        .guestProfile!
                                                        .firstName! +
                                                        '\t' +
                                                        tripsDataSnapshot
                                                            .data!
                                                            .guestProfile!
                                                            .lastName!,
                                                    message: '',
                                                    time: '',
                                                    messages: []);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    settings: RouteSettings(
                                                        name: "/messages"),
                                                    builder: (context) =>
                                                        MessageListView(
                                                          thread: threadData,
                                                        ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                  width: SizeConfig
                                                      .deviceWidth! *
                                                      0.48,
                                                  decoration: BoxDecoration(
                                                    color:
                                                    Color(0xffFF8F68),
                                                    borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(
                                                            8)),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 15),
                                                    child: Center(
                                                        child: SizedText(
                                                            deviceWidth:
                                                            SizeConfig
                                                                .deviceWidth!,
                                                            textWidthPercentage:
                                                            0.7,
                                                            text:
                                                            "Message Guest",
                                                            fontFamily:
                                                            'Urbanist',
                                                            fontSize: 15,
                                                            textColor: Colors
                                                                .white)),
                                                  )),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // launchUrl(
                                                //     ('tel://${tripsDataSnapshot.data!.guestProfile.phoneNumber}'));
                                                UrlLauncher.launch('tel://${tripsDataSnapshot.data!.guestProfile!.phoneNumber}');
                                              },
                                              child: Container(
                                                  width:
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width /
                                                      2.3,
                                                  decoration: BoxDecoration(
                                                    color:
                                                    Color(0xffFF8F68),
                                                    borderRadius:
                                                    BorderRadius.all(
                                                        Radius.circular(
                                                            8)),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 15),
                                                    child: Center(
                                                        child: Text(
                                                          "Call Guest",
                                                          style: TextStyle(
                                                              fontFamily:
                                                              'Urbanist',
                                                              fontSize: 15,
                                                              color:
                                                              Colors.white),
                                                        )),
                                                  )),
                                            ),
                                          ],
                                        ),

Divider(),


                                        tripsTypeSnapshot.data=="Current"?
                                        StreamBuilder<InspectionInfo>(
                                            stream: inspectionInfoBloc
                                                .inspectionInfoStream,
                                            builder: (context, inspectionInfoSnapshot){
                                              return
                                                Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator
                                                            .pushNamed(
                                                          context,
                                                          '/rentout_guest_start_trip_details',
                                                          arguments:

                                                          {"tripsData":tripsDataSnapshot
                                                              .data,
                                                            "inspectionData":inspectionInfoSnapshot.data,
                                                            "tripID": inspectionInfoSnapshot.data,
                                                            'tripType':
                                                            tripsTypeSnapshot
                                                                .data,
                                                            'trip':
                                                            tripsDataSnapshot
                                                                .data

                                                          },
                                                        );
                                                      },
                                                      child: Container(
                                                          width: MediaQuery
                                                              .of(
                                                              context)
                                                              .size
                                                              .width ,
                                                          decoration:
                                                          BoxDecoration(
                                                            color: Color(
                                                                0xffFF8F68),
                                                            borderRadius:
                                                            BorderRadius
                                                                .all(Radius
                                                                .circular(
                                                                8)),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                10,
                                                                vertical: 15),
                                                            child: Center(
                                                                child: Text(
                                                                  "Guest Start Trip Details",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                      'Urbanist',
                                                                      fontSize:
                                                                      15,
                                                                      color: Colors
                                                                          .white),
                                                                )),
                                                          )),
                                                    ), SizedBox(
                                                      height: 8,
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        Navigator
                                                            .pushNamed(
                                                          context,
                                                          '/rentout_host_start_trip_details',
                                                          arguments:
                                                          {"tripsData":tripsDataSnapshot
                                                              .data,
                                                            "inspectionData":inspectionInfoSnapshot.data,
                                                            "tripID": inspectionInfoSnapshot.data
                                                          },
                                                          // {"tripsData":tripsDataSnapshot
                                                          //     .data,"inspectionData":inspectionInfoSnapshot.data},
                                                        );
                                                      },
                                                      child: Container(
                                                          width: MediaQuery
                                                              .of(
                                                              context)
                                                              .size
                                                              .width ,
                                                          decoration:
                                                          BoxDecoration(
                                                            color: Color(
                                                                0xffFF8F68),
                                                            borderRadius:
                                                            BorderRadius
                                                                .all(Radius
                                                                .circular(
                                                                8)),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                10,
                                                                vertical: 15),
                                                            child: Center(
                                                                child: Text(
                                                                  "Host Start Trip Details",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                      'Urbanist',
                                                                      fontSize:
                                                                      15,
                                                                      color: Colors
                                                                          .white),
                                                                )),
                                                          )),
                                                    ),
                                                  ],
                                                ); }) :Container(),




                                        tripsTypeSnapshot.data=="Past"?
                                        StreamBuilder<InspectionInfo>(
                                            stream: inspectionInfoBloc
                                                .inspectionInfoStream,
                                            builder: (context, inspectionInfoSnapshot){
                                              return
                                                Column(
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator
                                                                .pushNamed(
                                                              context,
                                                              '/rentout_guest_start_trip_details',
                                                              arguments:
                                                              {"tripsData":tripsDataSnapshot
                                                                  .data,
                                                                "inspectionData":inspectionInfoSnapshot.data,
                                                                "tripID": inspectionInfoSnapshot.data
                                                              },
                                                            );
                                                          },
                                                          child: Container(
                                                              width: MediaQuery
                                                                  .of(
                                                                  context)
                                                                  .size
                                                                  .width ,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: Color(
                                                                    0xffFF8F68),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                    .circular(
                                                                    8)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                    10,
                                                                    vertical: 15),
                                                                child: Center(
                                                                    child: Text(
                                                                      "Guest Start Trip Details",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                          'Urbanist',
                                                                          fontSize:
                                                                          15,
                                                                          color: Colors
                                                                              .white),
                                                                    )),
                                                              )),
                                                        ),SizedBox(height: 8),

                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator
                                                                .pushNamed(
                                                              context,
                                                              '/rentout_host_start_trip_details',
                                                              arguments:
                                                              {
                                                                "tripsData":tripsDataSnapshot.data,
                                                                "tripID": inspectionInfoSnapshot.data,
                                                                "inspectionData":inspectionInfoSnapshot.data},
                                                              // {"tripsData":tripsDataSnapshot
                                                              //     .data,"inspectionData":inspectionInfoSnapshot.data},
                                                            );
                                                          },
                                                          child: Container(
                                                              width: MediaQuery
                                                                  .of(
                                                                  context)
                                                                  .size
                                                                  .width ,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: Color(
                                                                    0xffFF8F68),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                    .circular(
                                                                    8)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                    10,
                                                                    vertical: 15),
                                                                child: Center(
                                                                    child: Text(
                                                                      "Host Start Trip Details",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                          'Urbanist',
                                                                          fontSize:
                                                                          15,
                                                                          color: Colors
                                                                              .white),
                                                                    )),
                                                              )),
                                                        ),
                                                      ],
                                                    ),

                                                    SizedBox(height: 8,),
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator
                                                                .pushNamed(
                                                              context,
                                                              '/rentout_guest_end_trip_details',
                                                              arguments:
                                                              {
                                                                "tripsData":tripsDataSnapshot
                                                                  .data,
                                                                "inspectionData":inspectionInfoSnapshot.data,
                                                                 "tripID": inspectionInfoSnapshot.data
                                                              },
                                                            );
                                                          },
                                                          child: Container(
                                                              width: MediaQuery
                                                                  .of(
                                                                  context)
                                                                  .size
                                                                  .width ,
                                                              decoration:
                                                              BoxDecoration(
                                                                color: Color(
                                                                    0xffFF8F68),
                                                                borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                    .circular(
                                                                    8)),
                                                              ),
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                    10,
                                                                    vertical: 15),
                                                                child: Center(
                                                                    child: Text(
                                                                      "Guest End Trip Details",
                                                                      style: TextStyle(
                                                                          fontFamily:
                                                                          'Urbanist',
                                                                          fontSize:
                                                                          15,
                                                                          color: Colors
                                                                              .white),
                                                                    )),
                                                              )),
                                                        ),
                                                        SizedBox(height: 8,),





                                                        tripsDataSnapshot.data!.tripStatus ==
                                                            'Ended'
                                                            ?
                                                        Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                          children: [

                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                elevation: 0.0,
                                                                backgroundColor:
                                                                tripsDataSnapshot.data!.tripStatus== 'Completed'
                                                                    ? Color(0xffFF8F68)
                                                                    : Colors.grey,
                                                                padding: EdgeInsets.all(
                                                                    16.0),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        8.0)),

                                                              ),
                                                              onPressed: () {

                                                              },
                                                              child: Text(
                                                                'Host End Trip Details',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                    'Urbanist',
                                                                    fontSize: 18,
                                                                    color:
                                                                    Colors.white),
                                                              ),
                                                            ),
                                                          ],
                                                        )

                                                            :
                                                        tripsDataSnapshot
                                                            .data!.tripStatus ==
                                                            'Completed'
                                                            ?
                                                        tripsDataSnapshot.data!
                                                            .reimbursementStatus ==
                                                            'Unapproved'
                                                            ? Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                          children: [

                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                elevation: 0.0,
                                                                backgroundColor: Color(
                                                                    0xFFFF8F62),
                                                                padding:
                                                                EdgeInsets
                                                                    .all(
                                                                    16.0),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        8.0)),),
                                                              onPressed: () {
                                                                if( tripsDataSnapshot.data!.tripStatus== 'Completed'){
                                                                  Navigator
                                                                      .pushNamed(
                                                                    context,
                                                                    '/host_end_trip_details',
                                                                    arguments:
                                                                    {
                                                                      "tripsData":tripsDataSnapshot.data,
                                                                      "tripID": inspectionInfoSnapshot.data,
                                                                      "inspectionData":inspectionInfoSnapshot.data},
                                                                    // {"tripsData":tripsDataSnapshot
                                                                    //     .data,"inspectionData":inspectionInfoSnapshot.data},
                                                                  );}
                                                                else{

                                                                }
                                                              },
                                                              child: Text(
                                                                'Host End Trip Details',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                    'Urbanist',
                                                                    fontSize:
                                                                    15,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                            : Container()
                                                            : Container(),




                                                        tripsDataSnapshot.data!.tripStatus ==
                                                            'Ended'
                                                            ?
                                                        Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                          children: [
                                                            SizedBox(height: 16),
                                                            Divider(),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                elevation: 0.0,
                                                                backgroundColor:
                                                                Color(0xFFFF8F62),
                                                                padding: EdgeInsets.all(
                                                                    16.0),
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                        8.0)),

                                                              ),
                                                               onPressed: () {
                                                                Navigator.pushNamed(
                                                                  context,
                                                                  '/inspection_ui',
                                                                  arguments: {
                                                                    'tripType':
                                                                    tripsTypeSnapshot
                                                                        .data,
                                                                    'trip':
                                                                    tripsDataSnapshot
                                                                        .data,
                                                                    "tripsData":tripsDataSnapshot.data,
                                                                    "tripID": inspectionInfoSnapshot.data,
                                                                    "inspectionData":inspectionInfoSnapshot.data
                                                                  },
                                                                );
                                                              },
                                                              child: Text(
                                                                'Inspect your vehicle',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                    'Urbanist',
                                                                    fontSize: 18,
                                                                    color:
                                                                    Colors.white),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                        // ;}
                                                        //                 )
                                                            :
                                                        tripsDataSnapshot
                                                            .data!.tripStatus ==
                                                            'Completed'
                                                            ?

                                                        ///Reimbursement//
                                                        tripsDataSnapshot.data!
                                                            .reimbursementStatus ==
                                                            'Unapproved'
                                                            ? Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .stretch,
                                                          children: [
                                                            SizedBox(
                                                                height: 16),
                                                            Divider(),
                                              ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                              elevation: 0.0,
                                                              backgroundColor: Color(
                                                                  0xFFFF8F62),
                                                              padding:
                                                              EdgeInsets
                                                                  .all(
                                                                  16.0),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius.circular(
                                                                      8.0)),),
                                                              onPressed: () {
                                                                // handleShowReimbursementModal(tripDetails.tripID);
                                                                // Navigator.pushNamed(
                                                                //     context,
                                                                //     '/reimbursement',
                                                                //     arguments:
                                                                //     tripDetails
                                                                //         .tripID);
                                                              },
                                                              child: Text(
                                                                'Request reimbursement',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                    'Urbanist',
                                                                    fontSize:
                                                                    18,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                            : Container()
                                                            : Container(),
                                                      ],
                                                    ),
                                                  ],
                                                );
                                            }) :Container(),

                                        SizedBox(height:10),

                                        Divider()
                                      ],
                                    ),
                                  ),




                                  /// pre pickup process button
                                  // SizedBox(
                                  //   height: 8,
                                  // ),





                                  // SizedBox(height:8),



                                  tripsTypeSnapshot.data ==
                                      'Upcoming' ? StreamBuilder<InspectionInfo>(
                                    stream: inspectionInfoBloc
                                        .inspectionInfoStream,
                                    builder: (context, inspectionInfoSnapshot) {
                                      return Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double
                                                      .maxFinite,
                                                  child:
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                    elevation:
                                                    0.0,
                                                    backgroundColor: inspectionInfoSnapshot
                                                        .data== null
                                                        // && DateTime.now().isBefore(
                                                        // tripsDataSnapshot
                                                        //     .data
                                                        //     .startDateTime
                                                        //     .subtract(Duration(
                                                        //     minutes:
                                                        //     90)))
                                                        ? Color(0xffFF8F68)
                                                        : Colors.grey,
                                                    // Color(0xffFF8F68),
                                                    padding:
                                                    EdgeInsets
                                                        .all(
                                                        16.0),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),),
                                                    onPressed:
                                                        () async {


if( inspectionInfoSnapshot.data
== null){
                                                          // && DateTime.now().isBefore(
                                                          // tripsDataSnapshot
                                                          //     .data
                                                          //     .startDateTime
                                                          //     .subtract(Duration(
                                                          //     minutes:
                                                          //     90)))


if( DateTime.now().isBefore(
    tripsDataSnapshot
        .data!
        .startDateTime!
        .subtract(Duration(
        minutes:
        90))))

                                                      showPrePickupProcessTimeStartWarning(
                                                          tripsDataSnapshot
                                                              .data!
                                                              .startDateTime!);
                                                     else if(
    DateTime.now().isBefore(
    tripsDataSnapshot
        .data!
        .startDateTime!
        .subtract(Duration(
        minutes:
        90)))
){

                                                      showData(
                                                          tripsDataSnapshot
                                                              .data!
                                                              .startDateTime!);}
                                                     else{



  Navigator
      .pushNamed(
    context,
    '/common_inspection_ui',
    arguments:
    tripsDataSnapshot
        .data,
    // {"tripsData":tripsDataSnapshot
    //     .data,"inspectionData":inspectionInfoSnapshot.data},
  );
}}


                                                    },
                                                    child: Text(
                                                      'Start Pre-Pick-Up Process',
                                                      textAlign:
                                                      TextAlign
                                                          .center,
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'Urbanist',
                                                          fontSize:
                                                          18,
                                                          color: Colors
                                                              .white),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ) : Container(),


                                  SizedBox(height:10),




                                  // tripType == "Upcoming"
                                  //     ? ButtonTheme(
                                  //   height: 45,
                                  //   minWidth:
                                  //   MediaQuery.of(context)
                                  //       .size
                                  //       .width,
                                  //   shape:
                                  //   RoundedRectangleBorder(
                                  //     borderRadius:
                                  //     BorderRadius.circular(
                                  //         8.0),
                                  //   ),
                                  //   child: Visibility(
                                  //     visible: _isShow,
                                  //     child: ElevatedButton(style: ElevatedButton.styleFrom(
                                  //       onPressed: () {
                                  //
                                  //
                                  //         // setState(
                                  //         //       () {
                                  //         //
                                  //         //     _isShow = !_isShow;
                                  //         //   },
                                  //         // );
                                  //         if (
                                  //         DateTime.now().isBefore(
                                  //         tripsDataSnapshot
                                  //             .data
                                  //             .startDateTime
                                  //             .subtract(Duration(
                                  //         minutes:
                                  //         90)))
                                  //
                                  //         ) {
                                  //           showPrePickupProcessTimeStartWarning(
                                  //               tripsDataSnapshot
                                  //                   .data
                                  //                   .startDateTime);
                                  //
                                  //         }
                                  //         else {
                                  //           Navigator.pushNamed(
                                  //             context,
                                  //             '/common_inspection_ui',
                                  //             arguments:
                                  //             tripsDataSnapshot
                                  //                 .data,
                                  //           );
                                  //         }
                                  //       },
                                  //       color: DateTime.now().isBefore(
                                  //           tripsDataSnapshot
                                  //               .data
                                  //               .startDateTime
                                  //               .subtract(Duration(
                                  //               minutes:
                                  //               90)))
                                  //           ? Colors.grey
                                  //           : Color(0xffFF8F68),
                                  //       child: Text(
                                  //         "Start Pre-Pick-up Process",
                                  //         style: TextStyle(
                                  //           color: Colors.white,
                                  //           fontFamily: 'Urbanist',
                                  //           fontSize: 15,
                                  //
                                  //         ),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // )
                                  //     : Container(),
                                  SizedBox(
                                    height: 8,
                                  ),


                                  SizedBox(
                                    height: 8,
                                  ),

                                  /// change request button
                                  (tripType == "Current" ||
                                      tripType ==
                                          "Upcoming") &&
                                      tripsDataSnapshot
                                          .data!.changeRequest!
                                      ? ButtonTheme(
                                    height: 45,
                                    minWidth:
                                    MediaQuery.of(context)
                                        .size
                                        .width,
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          8.0),
                                    ),
                                    child:  SizedBox(
                                      height: 50,
                                      width: MediaQuery.of(context)
                                          .size
                                          .width,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                4.0),
                                          ),
                                        backgroundColor: Color(0xffFF8F68),),

                                        onPressed: () {


                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                    HostView(
                                                      tripData:
                                                      tripsDataSnapshot.data!,
                                                    )),
                                          );
                                        },
                                        child: Text(
                                          "Review Guest Change Request",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Urbanist',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                      : Container(),
                                  SizedBox(
                                    height: 8,
                                  ),

                                  ///cancel trip button

                                  tripsTypeSnapshot.data ==
                                      'Upcoming' &&
                                      tripsRentedOutBloc
                                          .checkCancelButtonVisibility(
                                          tripsDataSnapshot
                                              .data!)
                                      ? Padding(
                                    padding:
                                    const EdgeInsets.all(
                                        4.0),
                                    child: Container(
                                      margin: EdgeInsets.all(2),
                                      child: Button(
                                        title: "Cancel trip",
                                        textStyle: TextStyle(
                                            fontFamily:
                                            'Urbanist',
                                            fontSize: 16,
                                            color: Color(
                                                0xff371D32)),
                                        onPress: () =>
                                            handleShowCancelModal(
                                                tripDetails),
                                      ),
                                    ),
                                  )
                                      : new Container(),

                                  SizedBox(
                                    height: 4,
                                  ),

                  //                 ///inspect vehicle
                  //                 tripsDataSnapshot.data!.tripStatus ==
                  //                     'Ended'
                  //                     ?
                  //                 Column(
                  //                   crossAxisAlignment:
                  //                   CrossAxisAlignment
                  //                       .stretch,
                  //                   children: [
                  //                     SizedBox(height: 16),
                  //                     Divider(),
                  //                     ElevatedButton(style: ElevatedButton.styleFrom(
                  //                       elevation: 0.0,
                  //                       color:
                  //                       Color(0xFFFF8F62),
                  //                       padding: EdgeInsets.all(
                  //                           16.0),
                  //                       shape: RoundedRectangleBorder(
                  //                           borderRadius:
                  //                           BorderRadius
                  //                               .circular(
                  //                               8.0)),
                  //                       onPressed: () {
                  //                         Navigator.pushNamed(
                  //                           context,
                  //                           '/inspection_ui',
                  //                           arguments: {
                  //                             'tripType':
                  //                             tripsTypeSnapshot
                  //                                 .data,
                  //                             'trip':
                  //                             tripsDataSnapshot
                  //                                 .data,
                  //                             "tripsData":tripsDataSnapshot.data,
                  //                             // "tripID": inspectionInfoSnapshot.data,
                  //                             // "inspectionData":inspectionInfoSnapshot.data
                  //                           },
                  //                         );
                  //                       },
                  //                       child: Text(
                  //                         'Inspect your vehicle',
                  //                         style: TextStyle(
                  //                             fontFamily:
                  //                             'Urbanist',
                  //                             fontSize: 18,
                  //                             color:
                  //                             Colors.white),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 )
                  // // ;}
                  // //                 )
                  //                     :
                  //                 tripsDataSnapshot
                  //                     .data!.tripStatus ==
                  //                     'Completed'
                  //                     ?
                  //
                  //                 ///Reimbursement//
                  //                 tripsDataSnapshot.data
                  //                     .reimbursementStatus ==
                  //                     'Unapproved'
                  //                     ? Column(
                  //                   crossAxisAlignment:
                  //                   CrossAxisAlignment
                  //                       .stretch,
                  //                   children: [
                  //                     SizedBox(
                  //                         height: 16),
                  //                     Divider(),
                  //                     ElevatedButton(style: ElevatedButton.styleFrom(
                  //                       elevation: 0.0,
                  //                       color: Color(
                  //                           0xFFFF8F62),
                  //                       padding:
                  //                       EdgeInsets
                  //                           .all(
                  //                           16.0),
                  //                       shape: RoundedRectangleBorder(
                  //                           borderRadius:
                  //                           BorderRadius.circular(
                  //                               8.0)),
                  //                       onPressed: () {
                  //                         // handleShowReimbursementModal(tripDetails.tripID);
                  //                         // Navigator.pushNamed(
                  //                         //     context,
                  //                         //     '/reimbursement',
                  //                         //     arguments:
                  //                         //     tripDetails
                  //                         //         .tripID);
                  //                       },
                  //                       child: Text(
                  //                         'Request reimbursement',
                  //                         style: TextStyle(
                  //                             fontFamily:
                  //                             'Urbanist',
                  //                             fontSize:
                  //                             18,
                  //                             color: Colors
                  //                                 .white),
                  //                       ),
                  //                     ),
                  //                   ],
                  //                 )
                  //                     : Container()
                  //                     : Container(),
                                  SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                      : Container();
                })
                : Container();
          }),
    );
  }
  checkButtonVisibility(Trips tripDetails) {
    DateTime startTime = tripDetails.startDateTime!;
    startTime = startTime.subtract(Duration(
        minutes: startTime.minute,
        seconds: startTime.second,
        milliseconds: startTime.millisecond,
        microseconds: startTime.microsecond));
    var currentTime = DateTime.now().toUtc();
    int minutesStart = currentTime.difference(startTime).inMinutes;
    int minutesEnd = currentTime.difference(tripDetails.endDateTime!).inMinutes;
    if (minutesStart > -60 && minutesEnd <= 0) {
      return true;
    } else {
      return false;
    }
  }
  showPrePickupProcessTimeStartWarning(DateTime startTime) {
    showDialog(
      context: context,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor:  Colors.white,
          content: Container(
            height: MediaQuery.of(context).size.height * .18,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Cannot Start Trip at the time",
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      fontWeight:
                      FontWeight
                          .bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                    "You can start Pre-Pickup-Process After ${DateFormat('EEE, MMM dd, hh:mm a').format(startTime.subtract(Duration(minutes: 90)).toLocal())}", style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 15,
                ),),
                SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Color(0xffFF8F68))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("OK", style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18,color: Colors.white,
                          fontWeight:
                          FontWeight
                              .bold),),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  showData(DateTime startTime) {
    showDialog(
      context: context,
      // false = user must tap button, true = tap outside dialog
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Container(
            height: MediaQuery.of(context).size.height * .18,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    "Host inspection is done successfully"),
                SizedBox(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                          MaterialStateProperty.all(Color(0xffFF8F68))),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("OK"),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

void launchUrl(String url) async {
  if (await canLaunch(url)) {
    launch(url);
  } else {
    throw "Could not launch $url";
  }
}



