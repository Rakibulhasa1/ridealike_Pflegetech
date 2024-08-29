import 'dart:convert' show json;
import 'dart:convert';
import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import 'package:ridealike/pages/book_a_car/booking_info.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/pages/trips/bloc/end_trip_bloc.dart';
import 'package:ridealike/pages/trips/bloc/inspection_info_bloc.dart';
import 'package:ridealike/pages/trips/bloc/trips_rental_bloc.dart';
import 'package:ridealike/pages/trips/change_request/guest_ui/guest_view.dart';
import 'package:ridealike/pages/trips/request_service/insurance_roadside_assist_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_car_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_guest_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_host_request.dart';
import 'package:ridealike/pages/trips/request_service/request_reimbursement.dart';

//import 'package:ridealike/pages/trips/trips_response_model.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/inspection_info_response.dart';
import 'package:ridealike/pages/trips/response_model/insurance_roadside_assistnumber_response.dart';
import 'package:ridealike/utils/address_utils.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/utils/size_config.dart';
import 'package:ridealike/widgets/cancel_modal.dart';
import 'package:ridealike/widgets/pdfview.dart';
import 'package:ridealike/widgets/sized_text.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

// import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:url_launcher/url_launcher.dart';

void openCancelModal(context, tripDetails, TripsRentalBloc tripsRentalBloc) {
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
      ),
      isDismissible: true,
      builder: (BuildContext bc) {
        return CancelModal(tripData: tripDetails);
      });
}

InsuranceRoadSideNumbers? insuranceRoadSideNumbers;
TripAllUserStatusGroupResponse? tripAllUserStatusGroupResponse;

class TripsRentalDetailsUi extends StatefulWidget {
  @override
  _TripsRentalDetailsUiState createState() => _TripsRentalDetailsUiState();
}

class _TripsRentalDetailsUiState extends State<TripsRentalDetailsUi> {
  final endTripRentalBloc = EndTripRentalBloc();
  final tripsRentalBloc = TripsRentalBloc();
  final inspectionInfoBloc = InspectionInfoBloc();
  Trips? tripDetails;

  TripAllUserStatusGroupResponse? ownerShipId;

  String insuranceDocumentID = "";
  String infoCardDocumentID = "";
  String address = '';

  String? tripType;
  double? deviceHeight;
  double? deviceWidth;
  bool isVehicleOwnershipClicked = false;
  String? insuranceType;
  String changeRequestCount = "0";
  var backPressPop;

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

  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Trips Rental Details"});
    insuranceRoadAssistNumber();
    getVehicleDocs();
    Future.delayed(Duration.zero, () {
      deviceHeight = MediaQuery
          .of(context)
          .size
          .height;
      deviceWidth = MediaQuery
          .of(context)
          .size
          .width;
      tripsRentalBloc.changePaddingHeight.call(0.0);
      tripsRentalBloc.changedCancellationNote.call('');

      final dynamic receivedData = ModalRoute
          .of(context)!
          .settings
          .arguments;
      //  Trips tripDetails = receivedData["tripID"];
      tripDetails = receivedData['trip'];

      getInsuranceAndChangeRequestInfo(tripDetails!.bookingID);
      backPressPop = receivedData['backPressPop'];
      tripType = receivedData['tripType'];
      tripsRentalBloc.changedTripsTypeData.call(tripType!);
      tripsRentalBloc.rentAgreeIdCarInfo(tripDetails!);
      // tripsRentalBloc.getTripByIdMethod(tripDetails);
      if (tripDetails!.tripType == 'Swap') {
        tripsRentalBloc.getTripByIdSwap(tripDetails!);
      }
      tripsRentalBloc.rentAgreeIdCarInfo(tripDetails!);
      inspectionInfoBloc.getInspectionInfoByTripID(tripDetails!.tripID!);


      RateTripCarRequest rateTripCarRequest = RateTripCarRequest(
          inspectionByUserID: tripDetails!.userID,
          tripID: tripDetails!.tripID!,
          rateCar: '0',
          reviewCarDescription: '');


      RateTripHostRequest rateTripHostRequest = RateTripHostRequest(
          tripID: tripDetails!.tripID!,
          inspectionByUserID: tripDetails!.userID,
          rateHost: '0',
          reviewHostDescription: '');

      if (tripDetails!.tripType == 'Swap') {
        RateTripGuestRequest rateTripGuestRequest = RateTripGuestRequest(
            tripID: tripDetails!.swapData!.otherTripID,
            inspectionByUserID: tripDetails!.userID,
            rateGuest: '0',
            reviewGuestDescription: '');
        endTripRentalBloc.changedRateTripGuest.call(rateTripGuestRequest);
      }

      endTripRentalBloc.changedTripRateCar.call(rateTripCarRequest);
      endTripRentalBloc.changedTripRateHost.call(rateTripHostRequest);

      AddressUtils.getAddress(tripDetails!.location!.latLng!.latitude!,
          tripDetails!.location!.latLng!.longitude!)
          .then((value) {
        setState(() {
          address = value;
        });
      });
    });
  }

  insuranceRoadAssistNumber() async {
    var response = await insuranceAndRoadSideAssistNumberRequest();
    if (response != null && response.statusCode == 200) {
      insuranceRoadSideNumbers =
          InsuranceRoadSideNumbers.fromJson(json.decode(response.body!));
    }
  }

  void getVehicleDocs() async {
    try {
      var response = await HttpClient.post(getInsuranceAndInfoCardUrl, {});
      print(response.toString());
      insuranceDocumentID =
      response["InsuranceAndInfoCard"]["InsuranceDocumentID"];
      infoCardDocumentID =
      response["InsuranceAndInfoCard"]["InfoCardDocumentID"];
      print(insuranceDocumentID);
      print(infoCardDocumentID);
    } catch (e) {
      print(e);
    }
  }

  void getInsuranceAndChangeRequestInfo(bookID) async {
    try {
      var response = await HttpClient.post(getBookingByIDUrl, {
        "BookingID": "$bookID"
      },
          token: await storage.read(key: 'jwt') as String);
      insuranceType = response['Booking']["Params"]["InsuranceType"];
      changeRequestCount = response['Booking']['NoOfTripRequests'];
      print("$insuranceType jlkjlkjsdlkfjk");
      print("$changeRequestCount ==========");
    } catch (e) {
      print(e);
    }
  }

  final storage = new FlutterSecureStorage();
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

  @override
  Widget build(BuildContext context) {
//    print(tripDetails!.carYear);
    print("$changeRequestCount ==========");
    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<String>(
          stream: tripsRentalBloc.tripsType,
          builder: (context, tripsTypeSnapshot) {
            return tripsTypeSnapshot.hasData && tripsTypeSnapshot.data != null
                ? StreamBuilder<Trips>(
                stream: tripsRentalBloc.tripsData,
                builder: (context, tripsDataSnapshot) {
                  return tripsDataSnapshot.hasData &&
                      tripsDataSnapshot.data != null
                      ? Container(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 25.0),
                            child: Stack(
                              children: <Widget>[
                                (tripsDataSnapshot
                                    .data
                                !.car
                                !.imagesAndDocuments
                                !.images
                                !.mainImageID ==
                                    null ||
                                    tripsDataSnapshot
                                        .data
                                    !.car
                                    !.imagesAndDocuments
                                    !.images
                                    !.mainImageID ==
                                        '')
                                    ? Image.asset(
                                  'images/car-placeholder.png',
                                )
                                    : tripDetails!.hostProfile
                                !.verificationStatus ==
                                    "Undefined" ||
                                    tripDetails!.guestProfile
                                    !.verificationStatus ==
                                        "Undefined"
                                    ? Container(
                                  height: 250,
                                  width: double.infinity,
                                  color: Colors.black12,
                                )
                                    : Image.network(
                                  '$storageServerUrl/${tripsDataSnapshot.data
                                  !.car!.imagesAndDocuments!.images
                                  !.mainImageID}',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 250,

                                ),
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
                                            "Index":
                                            tripType == 'Upcoming'
                                                ? 0
                                                : tripType ==
                                                'Current'
                                                ? 1
                                                : 2
                                          };

                                          // Navigator.pop(context);
                                          if (backPressPop != null &&
                                              backPressPop) {
                                            Navigator.pushNamed(
                                                context, '/trips',
                                                arguments: argument
                                              // arguments: arguments,
                                            );
                                            // Navigator.pop(context);
                                          } else {
                                            Map argument = {
                                              "Index": tripType ==
                                                  'Upcoming'
                                                  ? 0
                                                  : tripType ==
                                                  'Current' ? 1 : 2
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
                                            const EdgeInsets.all(
                                                8.0),
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
                                            BorderRadius.circular(
                                                12.0),
                                          ),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets.all(
                                                12.0),
                                            child: Text(
                                              tripDetails!.tripType ==
                                                  'Swap'
                                                  ? '${tripsTypeSnapshot
                                                  .data} swap'
                                                  : '${tripsTypeSnapshot
                                                  .data} rental',
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
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 30,
                                ),
                                Text(
                                  'TRIP ID: ' +
                                      (tripDetails!.tripType == 'Swap'
                                          ? 'SBN${tripDetails!.swapData!.SBN}'
                                          : 'RBN${tripDetails!.rBN}'),
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 12,
                                    color: Color(0xff371D32)
                                        .withOpacity(0.5),
                                  ),
                                  textAlign: TextAlign.start,
                                ),
                                Divider(color: Color(0xFFE7EAEB)),

                                SizedBox(height: 10),


                                Text(
                                  "TRIP DETAILS",
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      color: Color(0xFF371D32)
                                          .withOpacity(0.5)),
                                ),
                                Divider(),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Image.asset(
                                          'icons/Calendar_Manage-Calendar.png',
                                          color: Color(
                                            0xff371D32,
                                          ),
                                          height: 20,
                                          width: 18,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Pickup",
                                          style: TextStyle(
                                              fontFamily:
                                              'Urbanist',
                                              fontSize: 16,
                                              color:
                                              Color(0xFF371D32)),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      DateFormat(
                                          'EEE, MMM dd, hh:00 a')
                                          .format(tripsDataSnapshot
                                          .data!.startDateTime
                                      !.toLocal()),
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xFF353B50)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Image.asset(
                                          'icons/Calendar_Manage-Calendar.png',
                                          color: Color(
                                            0xff371D32,
                                          ),
                                          height: 20,
                                          width: 18,
                                        ),
//                                    Icon(
//                                      Icons.calendar_today,
//                                    ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Return",
                                          style: TextStyle(
                                              fontFamily:
                                              'Urbanist',
                                              fontSize: 16,
                                              color:
                                              Color(0xFF371D32)),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      DateFormat(
                                          'EEE, MMM dd, hh:00 a')
                                          .format(tripsDataSnapshot
                                          .data!.endDateTime
                                      !.toLocal()),
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xFF353B50)),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(),
                                SizedBox(
                                  height: 5,
                                ),
                                //location//
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
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
                                              color:
                                              Color(0xFF371D32)),
                                        ),
                                        SizedBox(width: 20)
                                      ],
                                    ),

                                    Flexible(
                                      child:
                                      AutoSizeText(
                                        tripsDataSnapshot.data?.returnLocation
                                            ?.formattedAddress ??
                                            tripsDataSnapshot.data?.location
                                                ?.address ??
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
                                      //   tripsDataSnapshot
                                      //       .data
                                      //       .returnLocation != null
                                      //       ?
                                      //   tripsDataSnapshot
                                      //       .data
                                      //       .returnLocation
                                      //       .formattedAddress
                                      //       : tripsDataSnapshot
                                      //       .data
                                      //       .location
                                      //       .address,
                                      //
                                      //    overflow:
                                      //   TextOverflow.ellipsis,
                                      //   style: TextStyle(
                                      //       fontFamily: 'Urbanist',
                                      //       fontSize: 12,
                                      //       color: Color(0xFF353B50)),
                                      //   maxLines: 3,
                                      // ),
                                    ),
                                  ],
                                ),
                                Divider(),

                                SizedBox(height: 8),
                                Row(
                                    children: [
                                      Image.asset(
                                        'icons/car-insurance.png',
                                        color: Color(
                                          0xff371D32,
                                        ),
                                        height: 20,
                                        width: 18,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Insurance", style: TextStyle(
                                          fontFamily:
                                          'Urbanist',
                                          fontSize: 16,
                                          color:
                                          Color(0xFF371D32))),
                                      Spacer(),
                                      Text(insuranceType == "Minimum"
                                          ? "Standard"
                                          : "Premium", style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xFF353B50)))
                                    ]
                                ),
                                Divider(),
                                Row(
                                    children: [
                                      Image.asset(
                                        'icons/fast-delivery.png',
                                        color: Color(
                                          0xff371D32,
                                        ),
                                        height: 20,
                                        width: 18,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Delivery Needed", style: TextStyle(
                                          fontFamily:
                                          'Urbanist',
                                          fontSize: 16,
                                          color:
                                          Color(0xFF371D32))),
                                      Spacer(),
                                      Text(tripDetails!.deliveryNeeded!
                                          ? "Yes"
                                          : "No", style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xFF353B50)))
                                    ]
                                ),

                                /// Location note//
                                tripDetails!.tripType == 'Swap' ||
                                    tripDetails
                                    !.location!.customLoc ==
                                        true
                                    ? Container()
                                    : tripDetails!.car!.about!
                                    .location !=
                                    null &&
                                    tripDetails!.car!.about!
                                        .location!.notes !=
                                        null &&
                                    tripDetails!.car!.about!
                                        .location!.notes !=
                                        ''
                                    ? Divider()
                                    : Container(),
                                tripDetails!.tripType == 'Swap' ||
                                    tripDetails
                                    !.location!.customLoc ==
                                        true
                                    ? Container()
                                    : tripDetails!.car!.about!
                                    .location !=
                                    null &&
                                    tripDetails!.car!.about!
                                        .location!.notes !=
                                        null &&
                                    tripDetails!.car!.about!
                                        .location!.notes !=
                                        ''
                                    ? Row(
                                  children: [
                                    //  Icon(Icons.note),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    // Container(
                                    //   height: MediaQuery
                                    //       .of(
                                    //       context)
                                    //       .size
                                    //       .height *
                                    //       .12,
                                    //   width: MediaQuery
                                    //       .of(
                                    //       context)
                                    //       .size
                                    //       .width *
                                    //       .77,
                                    //   child: Align(
                                    //     alignment: Alignment
                                    //         .centerLeft,
                                    //     child: AutoSizeText(
                                    //       '${tripDetails!.car!.about!.location
                                    //           .notes}',
                                    //       maxLines: 4,
                                    //       overflow:
                                    //       TextOverflow
                                    //           .ellipsis,
                                    //       style: TextStyle(
                                    //           color: Color(
                                    //               0xff353B50),
                                    //           fontFamily:
                                    //           'Open Sans Regular',
                                    //           fontWeight:
                                    //           FontWeight
                                    //               .normal,
                                    //           fontSize: 12),
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                )
                                    : Container(),
                                Divider(),
//                            SizedBox(
//                              height: 10,
//                            ),
//                            tripsTypeSnapshot.data == 'Upcoming' ? Container(
//                              width: MediaQuery.of(context).size.width,
//                              decoration: BoxDecoration(
//                                color: Color(0xfff2f2f2),
//                                borderRadius: BorderRadius.all(Radius.circular(8)),
//                              ),
//                              child: Padding(
//                                padding: const EdgeInsets.symmetric(
//                                    horizontal: 10, vertical: 15),
//                                child: Center(
//                                    child: Text(
//                                  "Change dates",
//                                  style: TextStyle(
//                                    fontFamily: 'Urbanist',
//                                    fontSize: 16,
//                                    color: Color(0xFF371D32)
//                                  ),
//                                )),
//                              ),
//                            ) : new Container(),
                                SizedBox(
                                  height: 0,
                                ),
                                tripDetails!.tripType == 'Swap'
                                    ? Text(
                                  "SWAP DETAILS",
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      color: Color(0xFF371D32)
                                          .withOpacity(0.5)),
                                )
                                    : Text(
                                  "BOOKING DETAILS",
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      color: Color(0xFF371D32)
                                          .withOpacity(0.5)),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(),
                                tripDetails!.hostProfile
                                !.verificationStatus ==
                                    "Undefined" ||
                                    tripDetails!.guestProfile
                                    !.verificationStatus ==
                                        "Undefined"
                                    ? Container()
                                    : tripDetails!.tripType == 'Swap'
                                    ? InkWell(
                                  onTap: () {
                                    //todo
                                    Navigator.pushNamed(
                                        context,
                                        '/car_details_non_search',
                                        arguments: {
                                          'carID':
                                          tripsDataSnapshot
                                              .data
                                          !.carID,
                                          'bookingButton':
                                          false
                                        });
                                  },
                                  child: Container(
                                    height: SizeConfig
                                        .deviceHeight! *
                                        0.09 *
                                        SizeConfig
                                            .deviceFontSize!,
                                    width: deviceWidth,
                                    padding:
                                    EdgeInsets.only(
                                        top: 10),
                                    child: Stack(
                                      children: <Widget>[
                                        ClipOval(
                                          child: Image(
                                            height: 30,
                                            width: 30,
                                            fit: BoxFit
                                                .cover,
                                            image: NetworkImage(
                                                '$storageServerUrl/${tripDetails
                                                !.myCarForSwap
                                                !.imagesAndDocuments!.images
                                                !.mainImageID}'),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0.0,
                                          bottom: 6,
                                          child: ClipOval(
                                            child: Image(
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit
                                                  .cover,
                                              image: NetworkImage(
                                                  '$storageServerUrl/${tripDetails
                                                  !.car!.imagesAndDocuments!
                                                      .images!.mainImageID}'),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 40,
                                          child: Row(
                                            mainAxisSize:
                                            MainAxisSize
                                                .max,
                                            mainAxisAlignment:
                                            MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .start,
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,
                                                children: <
                                                    Widget>[
                                                  Text(
                                                    'Swapped car',
                                                    style: TextStyle(
                                                        color:
                                                        Color(0xff371D32),
                                                        fontSize: 16),
                                                  ),
                                                  SizedBox(
                                                    width: deviceWidth! *
                                                        0.75,
                                                    child:
                                                    AutoSizeText(
                                                      tripsRentalBloc
                                                          .getTextForSwappedCar(
                                                          tripDetails!),
                                                      maxLines:
                                                      2,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Color(
                                                              0xff353B50),
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  width: 8),
                                              Row(
                                                crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .end,
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .arrow_forward_ios,
                                                    size:
                                                    15,
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                )
                                    : InkWell(
                                  onTap: () {
                                    //todo
                                    Navigator.pushNamed(
                                        context,
                                        '/car_details_non_search',
                                        arguments: {
                                          'carID':
                                          tripsDataSnapshot
                                              .data
                                          !.carID,
                                          'bookingButton':
                                          false
                                        });
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <
                                              Widget>[
                                            Center(
                                              child: (tripsDataSnapshot.data
                                              !.carImageId !=
                                                  null ||
                                                  tripsDataSnapshot.data
                                                  !.carImageId !=
                                                      '')
                                                  ? CircleAvatar(
                                                backgroundImage:
                                                NetworkImage(
                                                    '$storageServerUrl/${tripsDataSnapshot
                                                        .data!.carImageId}'),
                                                radius:
                                                17.5,
                                              )
                                                  : CircleAvatar(
                                                backgroundImage:
//                                                                AssetImage('images/car-placeholder.png'),
                                                AssetImage(
                                                    'images/Profile@3x.png'),
                                                radius:
                                                17.5,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Car",
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize:
                                                  16,
                                                  color: Color(
                                                      0xFF371D32)),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <
                                              Widget>[
                                            SizedText(
                                                deviceWidth:
                                                deviceWidth!,
                                                textWidthPercentage:
                                                0.67,
                                                textOverflow:
                                                TextOverflow
                                                    .ellipsis,
                                                text: tripsDataSnapshot.data
                                                !.carYear ==
                                                    null
                                                    ? ''
                                                    : tripsDataSnapshot.data
                                                !.carYear! +
                                                    ' ' +
                                                    tripsDataSnapshot
                                                        .data!.car!.about!
                                                        .make! +
                                                    ' ' +
                                                    tripsDataSnapshot
                                                        .data!.car!.about!
                                                        .model!,
                                                fontFamily:
                                                'Urbanist',
                                                fontSize:
                                                14,
                                                textColor:
                                                Color(
                                                    0xFF353B50)),
                                            Icon(
                                              Icons
                                                  .arrow_forward_ios,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   height: 5,
                                // ),
                                tripsTypeSnapshot.data == 'Past' &&
                                    tripDetails!.tripType ==
                                        'Swap' ||
                                    (tripDetails!.hostProfile
                                    !.verificationStatus ==
                                        "Undefined" ||
                                        tripDetails!.guestProfile
                                        !.verificationStatus ==
                                            "Undefined")
                                    ? Container()
                                    : Divider(),
                                tripsTypeSnapshot.data == 'Past' &&
                                    tripDetails!.tripType ==
                                        'Swap' ||
                                    (tripDetails!.hostProfile
                                    !.verificationStatus ==
                                        "Undefined" ||
                                        tripDetails!.guestProfile
                                        !.verificationStatus ==
                                            "Undefined")
                                    ? Container()
                                    : SizedBox(
                                  height: 5,
                                ),
                                //licence pnumber//
                                tripsTypeSnapshot.data == 'Past' &&
                                    tripDetails!.tripType ==
                                        'Swap' ||
                                    (tripDetails!.hostProfile
                                    !.verificationStatus ==
                                        "Undefined" ||
                                        tripDetails!.guestProfile
                                        !.verificationStatus ==
                                            "Undefined")
                                    ? Container()
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      'License plate',
                                      style: TextStyle(
                                          fontFamily:
                                          'Urbanist',
                                          fontSize: 16,
                                          color: Color(
                                              0xFF371D32)),
                                    ),
                                    Text(
                                      tripsDataSnapshot.data
                                      !.carLicense !=
                                          null
                                          ? tripsDataSnapshot
                                          .data!.carLicense!
                                          : "",
                                      style: TextStyle(
                                          fontFamily:
                                          'Urbanist',
                                          fontSize: 14,
                                          color: Color(
                                              0xFF353B50)),
                                    ),
                                  ],
                                ),
                                tripDetails!.hostProfile
                                !.verificationStatus ==
                                    "Undefined" ||
                                    tripDetails!.guestProfile
                                    !.verificationStatus ==
                                        "Undefined"
                                    ? Container()
                                    : SizedBox(
                                  height: 5,
                                ),
                                tripDetails!.hostProfile
                                !.verificationStatus ==
                                    "Undefined" ||
                                    tripDetails!.guestProfile
                                    !.verificationStatus ==
                                        "Undefined"
                                    ? Container()
                                    : Divider(),
                                //host name//
                                tripDetails!.hostProfile
                                !.verificationStatus ==
                                    "Undefined" ||
                                    tripDetails!.guestProfile
                                    !.verificationStatus ==
                                        "Undefined"
                                    ? Container()
                                    : InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context,
                                        '/user_profile',
                                        arguments: tripDetails
                                        !.hostProfile
                                        !.toJson());
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Center(
                                              child: (tripsDataSnapshot
                                                  .data!
                                                  .hostProfile!
                                                  .imageID !=
                                                  null &&
                                                  tripsDataSnapshot
                                                      .data!
                                                      .hostProfile!
                                                      .imageID !=
                                                      '')
                                                  ? CircleAvatar(
                                                backgroundImage:
                                                NetworkImage(
                                                    '$storageServerUrl/${tripsDataSnapshot
                                                        .data!.hostProfile
                                                    !.imageID}'),
                                                radius:
                                                17.5,
                                              )
                                                  : CircleAvatar(
                                                backgroundImage:
                                                AssetImage(
                                                  'images/user.png',
                                                ),
                                                radius:
                                                17.5,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "Host",
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(
                                                      0xFF371D32)),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              '${tripsDataSnapshot.data
                                              !.hostProfile
                                              !.firstName} ${tripsDataSnapshot
                                                  .data!.hostProfile!
                                                  .lastName}',
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(
                                                      0xFF353B50)),
                                            ),
                                            Icon(
                                              Icons
                                                  .arrow_forward_ios,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                tripDetails!.hostProfile
                                !.verificationStatus ==
                                    "Undefined" ||
                                    tripDetails!.guestProfile
                                    !.verificationStatus ==
                                        "Undefined"
                                    ? Container()
                                    : Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                // tripsTypeSnapshot.data == 'Past'?
                                InkWell(
                                  onTap: () {
                                    // TODO receipt
                                    print(tripDetails!.noOfTripRequest);
                                    if (tripDetails!.tripType ==
                                        'Swap') {
                                      Navigator.pushNamed(
                                          context, '/receipt_swap',
                                          arguments: tripDetails);
                                    } else if (changeRequestCount != "0") {
                                      tripDetails!.noOfTripRequest =
                                          changeRequestCount;
                                      Navigator.pushNamed(
                                          context, '/receipt_list',
                                          arguments: tripDetails);
                                    } else {
                                      Navigator.pushNamed(
                                          context, '/receipt',
                                          arguments: tripDetails);
                                    }
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          tripDetails!.tripType ==
                                              'Swap' &&
                                              tripsDataSnapshot
                                                  .data!
                                                  .guestTotal! >
                                                  0.0
                                              ? 'Trip Income'
                                              : "Total Payable",
                                          style: TextStyle(
                                              fontFamily:
                                              'Urbanist',
                                              fontSize: 16,
                                              color:
                                              Color(0xFF371D32)),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "\$${tripsDataSnapshot.data
                                              !.newGuestTotal![int.parse(
                                                  changeRequestCount)]
                                              !.toStringAsFixed(2)
                                                  .replaceAll("-", "")}",
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(
                                                      0xFF353B50)),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                // : Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment
                                //             .spaceBetween,
                                //     children: <Widget>[
                                //       Text(
                                //         "Trip cost",
                                //         style: TextStyle(
                                //             fontFamily:
                                //                 'Urbanist',
                                //             fontSize: 16,
                                //             color: Color(
                                //                 0xFF371D32)),
                                //       ),
                                //       Text(
                                //         "\$${tripsDataSnapshot.data!.guestTotal!.toStringAsFixed(2)}",
                                //         style: TextStyle(
                                //             fontFamily:
                                //                 'Urbanist',
                                //             fontSize: 14,
                                //             color: Color(
                                //                 0xFF353B50)),
                                //       ),
                                //     ],
                                //   ),
                                ,
                                SizedBox(
                                  height: 5,
                                ),
                                // Divider(),
                                // Current Vehicle Documents//
                                tripsTypeSnapshot.data == 'Current'
                                    ? Text(
                                  "VEHICLE DOCUMENTS",
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      color: Color(0xFF371D32)
                                          .withOpacity(0.5)),
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? Divider()
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 5,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? InkWell(
                                    onTap: () async {
                                      if (!isVehicleOwnershipClicked) {
                                        isVehicleOwnershipClicked =
                                        true;
                                        var resp =
                                        await getTripByID(
                                            tripDetails
                                            !.tripID!);
                                        if (resp != null &&
                                            resp.statusCode ==
                                                200) {
                                          ownerShipId =
                                              TripAllUserStatusGroupResponse
                                                  .fromJson(json
                                                  .decode(resp
                                                  .body!));
                                          print(ownerShipId
                                          !.vehicleOwnershipDocument
                                              .toString());
                                        }
                                        Navigator.pushNamed(
                                            context,
                                            '/trip_vehicle_ownership',
                                            arguments:
                                            ownerShipId)
                                            .then((value) =>
                                        isVehicleOwnershipClicked =
                                        false);
                                      }
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              'Vehicle ownership',
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(
                                                      0xFF371D32)),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              "View",
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(
                                                      0xFF353B50)),
                                            ),
                                            Icon(
                                              Icons
                                                  .arrow_forward_ios,
                                              size: 15,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ))
                                    : new Container(),
                                Divider(),

                                tripsTypeSnapshot.data == 'Current'
                                    ? _vehicleDocs(
                                    "Insurance (Pink Slip)", 1)
                                    : new Container(),
                                Divider(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? _vehicleDocs(
                                    "Incident Info Card", 2)
                                    : new Container(),
                                Divider(),
                                tripDetails!.hostProfile
                                !.verificationStatus ==
                                    "Undefined" ||
                                    tripDetails!.guestProfile
                                    !.verificationStatus ==
                                        "Undefined"
                                    ? Container()
                                    : Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                    children: <Widget>[
                                      //message host//
                                      GestureDetector(
                                        onTap: () {
                                          Thread threadData = new Thread(
                                              id: "1123571113",
                                              userId:
                                              tripsDataSnapshot
                                                  .data!
                                                  .hostProfile!
                                                  .userID!,
                                              image: tripsDataSnapshot
                                                  .data!
                                                  .hostProfile!
                                                  .imageID !=
                                                  ""
                                                  ? tripsDataSnapshot
                                                  .data!
                                                  .hostProfile!
                                                  .imageID!
                                                  : "",
                                              name: tripsDataSnapshot
                                                  .data!
                                                  .hostProfile!
                                                  .firstName! +
                                                  '\t' +
                                                  tripsDataSnapshot
                                                      .data!
                                                      .hostProfile!
                                                      .lastName!,
                                              message: '',
                                              time: '',
                                              messages: []);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              settings:
                                              RouteSettings(
                                                  name:
                                                  "/messages"),
                                              builder: (context) =>
                                                  MessageListView(
                                                    thread:
                                                    threadData,
                                                  ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                            width: SizeConfig
                                                .deviceWidth! *
                                                0.48,
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
                                                  child: SizedText(
                                                      deviceWidth:
                                                      SizeConfig
                                                          .deviceWidth!,
                                                      textWidthPercentage:
                                                      0.7,
                                                      text:
                                                      "Message Host",
                                                      fontFamily: 'Urbanist',
                                                      fontSize:
                                                      15,
                                                      textColor:
                                                      Colors
                                                          .white)),
                                            )),
                                      ),
                                      // Call host//
                                      GestureDetector(
                                        onTap: () {
                                          // launchUrl(
                                          //     ('tel://${tripsDataSnapshot.data
                                          //         .hostProfile.phoneNumber}'));

                                          UrlLauncher.launch(
                                              'tel://${tripsDataSnapshot.data
                                              !.hostProfile!.phoneNumber}');
                                        },
                                        child: Container(
                                            width: MediaQuery
                                                .of(
                                                context)
                                                .size
                                                .width /
                                                2.3,
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
                                                    "Call Host",
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize:
                                                        15,
                                                        color: Colors
                                                            .white),
                                                  )),
                                            )),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  SizedBox(height: 10),

                                  ///change request button
                                  (tripsTypeSnapshot.data == "Current" ||
                                      tripsTypeSnapshot.data == "Upcoming") ?
                                  ButtonTheme(
                                    height: 45,
                                    minWidth:
                                    MediaQuery
                                        .of(context)
                                        .size
                                        .width,
                                    shape:
                                    RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(
                                          0),
                                    ),
                                    child: SizedBox(
                                      height: 50,
                                      width: MediaQuery
                                          .of(context)
                                          .size
                                          .width,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xffFF8F68),
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                4),
                                          ),),
                                        onPressed: () {
                                          if (tripsDataSnapshot.data
                                          !.changeRequest!) {
                                            showDialog(
                                              context: context,
                                              // false = user must tap button, true = tap outside dialog
                                              builder: (
                                                  BuildContext dialogContext) {
                                                return
                                                  AlertDialog(
                                                    backgroundColor: Colors
                                                        .white,
                                                    content: Container(
                                                      height: MediaQuery
                                                          .of(context)
                                                          .size
                                                          .height *
                                                          .18,
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                        children: [
                                                          Text(
                                                              "You already have a pending request",
                                                              style: TextStyle(
                                                                fontFamily:
                                                                'Urbanist',
                                                                fontSize:
                                                                18,
                                                              )),
                                                          SizedBox(),
                                                          Row(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                            children: [
                                                              ElevatedButton(
                                                                style: ButtonStyle(
                                                                    backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                        Color(
                                                                            0xffFF8F68))),
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child: Text(
                                                                    "OK",
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                        'Urbanist',
                                                                        fontSize:
                                                                        18,
                                                                        color: Colors
                                                                            .white)),
                                                              )
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                              },
                                            );
                                          } else {
                                            print("${tripsTypeSnapshot
                                                .data}========");
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        GuestView(
                                                            currentEndDateTime: tripsDataSnapshot
                                                                .data!
                                                                .endDateTime!,
                                                            currentStartDateTime: tripsDataSnapshot
                                                                .data!
                                                                .startDateTime!,
                                                            carId: tripsDataSnapshot
                                                                .data!.carID!,
                                                            tripId: tripsDataSnapshot
                                                                .data!.tripID!,
                                                            currentLocation: tripsDataSnapshot
                                                                .data!
                                                                .returnLocation !=
                                                                null
                                                                ? tripsDataSnapshot
                                                                .data!
                                                                .returnLocation
                                                                : tripsDataSnapshot
                                                                .data!.location,
                                                            delivery: tripsDataSnapshot
                                                                .data!
                                                                .deliveryNeeded!,
                                                            customDelivery: tripDetails
                                                            !.car!.pricing
                                                            !.rentalPricing!
                                                                .enableCustomDelivery!,
                                                            tripType: tripsTypeSnapshot
                                                                .data!

                                                        )));
                                          }
                                        },

                                        child: Text(
                                          "Request Change",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Urbanist',
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ) : Container(),
                                  SizedBox(
                                    height: 10,
                                  ),
                                ]),
                                //  Current trip contents//

                                SizedBox(height: 10),

                                tripsTypeSnapshot.data == "Past" ?
                                StreamBuilder<InspectionInfo>(
                                    stream: inspectionInfoBloc
                                        .inspectionInfoStream,
                                    builder: (context, inspectionInfoSnapshot) {
                                      return
                                        Column(
                                          children: [
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator
                                                        .pushNamed(
                                                      context,
                                                      '/rentout_guest_start_trip_details',
                                                      arguments:
                                                      {
                                                        "tripsData": tripsDataSnapshot
                                                            .data,
                                                        "inspectionData": inspectionInfoSnapshot
                                                            .data,
                                                        "tripID": inspectionInfoSnapshot
                                                            .data
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                      width: MediaQuery
                                                          .of(
                                                          context)
                                                          .size
                                                          .width,
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
                                                ),
                                                SizedBox(height: 5),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator
                                                        .pushNamed(
                                                      context,
                                                      '/rentout_host_start_trip_details',
                                                      arguments:
                                                      {
                                                        "tripsData": tripsDataSnapshot
                                                            .data,
                                                        "tripID": inspectionInfoSnapshot
                                                            .data,
                                                        "inspectionData": inspectionInfoSnapshot
                                                            .data},
                                                      // {"tripsData":tripsDataSnapshot
                                                      //     .data,"inspectionData":inspectionInfoSnapshot.data},
                                                    );
                                                  },
                                                  child: Container(
                                                      width: MediaQuery
                                                          .of(
                                                          context)
                                                          .size
                                                          .width,
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

                                            SizedBox(height: 5,),
                                            Column(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator
                                                        .pushNamed(
                                                      context,
                                                      '/rentout_guest_end_trip_details',
                                                      arguments:
                                                      {
                                                        "tripsData": tripsDataSnapshot
                                                            .data,
                                                        "inspectionData": inspectionInfoSnapshot
                                                            .data,
                                                      },
                                                    );
                                                  },
                                                  child: Container(
                                                      width: MediaQuery
                                                          .of(
                                                          context)
                                                          .size
                                                          .width,
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
                                                SizedBox(height: 5),
                                                GestureDetector(
                                                  onTap: () {
                                                    Navigator
                                                        .pushNamed(
                                                      context,
                                                      '/host_end_trip_details',
                                                      arguments:
                                                      {
                                                        "tripsData":tripsDataSnapshot.data,
                                                        "tripID": inspectionInfoSnapshot.data,
                                                        "inspectionData":inspectionInfoSnapshot.data
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
                                                              "Host End Trip Details",
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
                                          ],
                                        );
                                    }) : Container(),
                                SizedBox(height: 5),


                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 5,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 0,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 0,
                                )
                                    : new Container(),

                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 10.0,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? Divider()
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 0,
                                )
                                    : new Container(),

                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 0.0,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? Divider()
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 0.0,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizeConfig.deviceFontSize! > 1
                                    ? Column(
                                  children: [
                                    // call insurance//
                                    GestureDetector(
                                      onTap: () {
                                        // launchUrl(
                                        //     ('tel://${insuranceRoadSideNumbers
                                        //         .insuranceAndRoadSideAssistNumbers
                                        //         .insuranceCallNumber}'));
                                        UrlLauncher.launch(
                                            'tel://${insuranceRoadSideNumbers!
                                                .insuranceAndRoadSideAssistNumbers!
                                                .insuranceCallNumber}');
                                      },
                                      child: Container(
                                          decoration:
                                          BoxDecoration(
                                            color: Color(
                                                0xffFF8F68),
                                            borderRadius: BorderRadius
                                                .all(Radius
                                                .circular(
                                                8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                5,
                                                vertical:
                                                15),
                                            child: Center(
                                                child: Text(
                                                  "Call Insurance",
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize:
                                                      16,
                                                      color: Colors
                                                          .white),
                                                )),
                                          )),
                                    ),
                                    SizedBox(height: 10),
                                    //call roadSide Assist//
                                    GestureDetector(
                                      onTap: () {
                                        // launchUrl(
                                        //     ('tel://${insuranceRoadSideNumbers
                                        //         .insuranceAndRoadSideAssistNumbers
                                        //         .roadSideAssistNumber}'));
                                        UrlLauncher.launch(
                                            'tel://${insuranceRoadSideNumbers!
                                                .insuranceAndRoadSideAssistNumbers!
                                                .roadSideAssistNumber}');
                                      },
                                      child: Container(
                                          decoration:
                                          BoxDecoration(
                                            color: Color(
                                                0xffFF8F68),
                                            borderRadius: BorderRadius
                                                .all(Radius
                                                .circular(
                                                8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                5,
                                                vertical:
                                                15),
                                            child: Center(
                                                child: Text(
                                                  "Call Roadside Assist",
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize:
                                                      16,
                                                      color: Colors
                                                          .white),
                                                  maxLines: 1,
                                                )),
                                          )),
                                    ),
                                  ],
                                )
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    // call insurance//
                                    GestureDetector(
                                      onTap: () {
                                        // launchUrl(
                                        //     ('tel://${insuranceRoadSideNumbers
                                        //         .insuranceAndRoadSideAssistNumbers
                                        //         .insuranceCallNumber}'));
                                        UrlLauncher.launch(
                                            'tel://${insuranceRoadSideNumbers!
                                                .insuranceAndRoadSideAssistNumbers!
                                                .insuranceCallNumber}');
                                      },
                                      child: Container(
                                          width: MediaQuery
                                              .of(
                                              context)
                                              .size
                                              .width /
                                              2.3,
                                          decoration:
                                          BoxDecoration(
                                            color: Color(
                                                0xffFF8F68),
                                            borderRadius: BorderRadius
                                                .all(Radius
                                                .circular(
                                                8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                5,
                                                vertical:
                                                15),
                                            child: Center(
                                                child: Text(
                                                  "Call Insurance",
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize:
                                                      16,
                                                      color: Colors
                                                          .white),
                                                )),
                                          )),
                                    ),

                                    //call roadSide Assist//
                                    GestureDetector(
                                      onTap: () {
                                        // launchUrl(
                                        //     ('tel://${insuranceRoadSideNumbers
                                        //         .insuranceAndRoadSideAssistNumbers
                                        //         .roadSideAssistNumber}'));
                                        UrlLauncher.launch(
                                            'tel://${insuranceRoadSideNumbers!
                                                .insuranceAndRoadSideAssistNumbers!
                                                .roadSideAssistNumber}');
                                        ;
                                      },
                                      child: Container(
                                          width: MediaQuery
                                              .of(
                                              context)
                                              .size
                                              .width /
                                              2.3,
                                          decoration:
                                          BoxDecoration(
                                            color: Color(
                                                0xffFF8F68),
                                            borderRadius: BorderRadius
                                                .all(Radius
                                                .circular(
                                                8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                5,
                                                vertical:
                                                15),
                                            child: Center(
                                                child: Text(
                                                  "Call Roadside Assist",
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize:
                                                      16,
                                                      color: Colors
                                                          .white),
                                                  maxLines: 1,
                                                )),
                                          )),
                                    ),
                                  ],
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 40,
                                )
                                    : new Container(),

                                // Trip rules//
                                tripsTypeSnapshot.data != 'Past'
                                    ? Text(
                                  "TRIP RULES",
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      color: Color(0xFF371D32)
                                          .withOpacity(0.5)),
                                )
                                    : Container(),
                                tripsTypeSnapshot.data != 'Past'
                                    ? SizedBox(
                                  height: 5,
                                )
                                    : Container(),

                                tripsTypeSnapshot.data != 'Past'
                                    ? Container(
                                  color: Color(0xfff2f2f2),
                                  child: Padding(
                                    padding:
                                    const EdgeInsets.all(
                                        8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .stretch,
                                      children: <Widget>[
                                        tripsDataSnapshot
                                            .data
                                        !.car
                                        !.preference!
                                            .isSuitableForPets !=
                                            null &&
                                            tripsDataSnapshot
                                                .data
                                            !.car
                                            !.preference!
                                                .isSuitableForPets ==
                                                true
                                            ? Container()
                                            : Column(
                                          children: <
                                              Widget>[
                                            Row(
                                              children: <
                                                  Widget>[
                                                Image.asset(
                                                    'icons/No-Pets.png'),
                                                SizedBox(
                                                    width:
                                                    6.0),
                                                Text(
                                                  'No pets',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Urbanist',
                                                      fontSize:
                                                      14,
                                                      color:
                                                      Color(0xFF353B50)),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                          ],
                                        ),
                                        tripsDataSnapshot
                                            .data
                                        !.car
                                        !.preference!
                                            .isSmokingAllowed !=
                                            null &&
                                            tripsDataSnapshot
                                                .data
                                            !.car
                                            !.preference!
                                                .isSmokingAllowed ==
                                                true
                                            ? Container()
                                            : Column(
                                          children: <
                                              Widget>[
                                            Row(
                                              children: <
                                                  Widget>[
                                                Image.asset(
                                                    'icons/No-smoking.png'),
                                                SizedBox(
                                                    width:
                                                    5.0),
                                                Text(
                                                  'No smoking',
                                                  style: TextStyle(
                                                      fontFamily:
                                                      'Urbanist',
                                                      fontSize:
                                                      14,
                                                      color:
                                                      Color(0xFF353B50)),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 6.0,
                                            ),
                                          ],
                                        ),
                                        // Mileage//
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .stretch,
                                          children: <Widget>[
                                            Row(
                                              children: <
                                                  Widget>[
                                                Image.asset(
                                                    'icons/Mileage.png'),
                                                SizedBox(
                                                  width: 5.0,
                                                ),
                                                Flexible(
                                                  flex: 2,
                                                  child: tripsDataSnapshot
                                                      .data
                                                  !.car
                                                  !.preference!
                                                      .dailyMileageAllowance ==
                                                      'Limited'
                                                      ? AutoSizeText(
                                                    '${tripsDataSnapshot.data
                                                    !.car!.preference!
                                                        .limit} km allowed daily, extra mileage is \$${tripsDataSnapshot
                                                        .data!.car!.pricing
                                                    !.rentalPricing!
                                                        .perExtraKMOverLimit
                                                    !.toStringAsFixed(
                                                        2)}/km',
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color: Color(
                                                            0xFF353B50)),
                                                    maxLines:
                                                    4,
                                                  )
                                                      : Text(
                                                    'Unlimited mileage allowance',
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
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                          ],
                                        ),

                                        Row(
                                          children: <Widget>[
                                            Image.asset(
                                                'icons/Fuel-2.png'),
                                            SizedBox(
                                              width: 6.0,
                                            ),
                                            Text(
                                              // tripsDataSnapshot.data!.car!.features!.fuelType != null

                                              tripsDataSnapshot
                                                  .data
                                              !.car
                                              !.features!
                                                  .fuelType !=
                                                  null
                                                  ? 'Refuel with ${tripsDataSnapshot
                                                  .data!.car!.features!
                                                  .fuelType ==
                                                  '91-94_PREMIUM'
                                                  ? 'Premium'
                                                  : tripsDataSnapshot.data!.car
                                              !.features!.fuelType ==
                                                  '91-94 premium'
                                                  ? 'Premium'
                                                  : tripsDataSnapshot.data!.car
                                              !.features!.fuelType ==
                                                  '87_REGULAR'
                                                  ? 'Regular'
                                                  : tripsDataSnapshot.data!.car
                                              !.features!.fuelType ==
                                                  '87 regular'
                                                  ? 'Regular'
                                                  : tripsDataSnapshot.data!.car
                                              !.features!.fuelType ==
                                                  'electric'
                                                  ? 'Electric'
                                                  : tripsDataSnapshot.data!.car
                                              !.features!.fuelType ==
                                                  'ELECTRIC'
                                                  ? 'Electric'
                                                  : tripsDataSnapshot.data!.car
                                              !.features!.fuelType == 'diesel'
                                                  ? 'Diesel'
                                                  : tripsDataSnapshot.data!.car
                                              !.features!.fuelType == 'DIESEL'
                                                  ? 'Diesel'
                                                  : tripsDataSnapshot.data!.car
                                              !.features!.fuelType} only'
                                                  : '',
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(
                                                      0xFF353B50)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Image.asset(
                                                'icons/Fuel-2.png'),
                                            SizedBox(
                                              width: 6.0,
                                            ),
                                            Text(
                                              'Return with the same fuel level',
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(
                                                      0xFF353B50)),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Image.asset(
                                                'icons/Cleanliness-2.png'),
                                            SizedBox(
                                              width: 6.0,
                                            ),
                                            SizedText(
                                                deviceWidth:
                                                deviceWidth!,
                                                textWidthPercentage:
                                                0.8,
                                                text:
                                                'Return in the same state of cleanliness',
                                                fontFamily:
                                                'Urbanist',
                                                fontSize: 14,
                                                textColor: Color(
                                                    0xFF353B50)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    : Container(),

                                tripsTypeSnapshot.data == 'Upcoming'
                                    ? SizedBox(
                                  height: 30,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data ==
                                    'Upcoming' &&
                                    tripsDataSnapshot.data!
                                        .freeCancelBeforeDateTime!
                                        .isAfter(DateTime.now())
                                    ? Text(
                                  "CANCELLATION POLICY",
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      color: Color(0xFF371D32)
                                          .withOpacity(0.5)),
                                )
                                    : new Container(),
                                SizedBox(
                                  height: 5,
                                ),
                                tripsTypeSnapshot.data ==
                                    'Upcoming' &&
                                    tripsTypeSnapshot.data !=
                                        'Past'
                                    ? tripsDataSnapshot.data!
                                    .freeCancelBeforeDateTime!
                                    .isAfter(DateTime.now())
                                    ? Padding(
                                  padding:
                                  const EdgeInsets.only(
                                      top: 8,
                                      bottom: 8),
                                  child: Container(
                                    color:
                                    Color(0xfff2f2f2),
                                    height: 60,
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                            'icons/Info-2.png'),
                                        SizedBox(
                                            width: 5.0),
                                        Flexible(
                                          flex: 2,
                                          child:
                                          AutoSizeText(
                                            'Cancel your trip for FREE until ${DateFormat(
                                                "EEE MMM dd, yyyy hh:00 a")
                                                .format(tripsDataSnapshot.data!
                                                .freeCancelBeforeDateTime!)}',
                                            style: TextStyle(
                                                fontFamily:
                                                'Urbanist',
                                                fontSize:
                                                14,
                                                color: Color(
                                                    0xFF353B50)),
                                            maxLines: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    : Padding(
                                  padding:
                                  const EdgeInsets.only(
                                      top: 8,
                                      bottom: 8),
                                  child: Container(
                                    color:
                                    Color(0xfff2f2f2),
                                    height: 60,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                      children: <Widget>[
                                        Padding(
                                          padding:
                                          const EdgeInsets
                                              .only(
                                              top: 2),
                                          child: Image.asset(
                                              'icons/Info-2.png'),
                                        ),
                                        SizedBox(
                                            width: 5.0),
                                        Flexible(
                                          flex: 2,
                                          child:
                                          AutoSizeText(
                                            'You are no longer within the free cancellation period.',
                                            style: TextStyle(
                                                fontFamily:
                                                'Urbanist',
                                                fontSize:
                                                14,
                                                color: Color(
                                                    0xFF353B50)),
                                            maxLines: 4,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    : Container(),
                                tripDetails!.hostProfile
                                !.verificationStatus ==
                                    "Undefined"
                                    ? Container()
                                    : SizedBox(
                                  height: 30,
                                ),
                                tripsTypeSnapshot.data ==
                                    'Upcoming' &&
                                    tripsRentalBloc
                                        .checkCancelButtonVisibility(
                                        tripsDataSnapshot
                                            .data!)
                                    ? Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: double
                                                .maxFinite,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                backgroundColor: Color(
                                                    0xffF2F2F2),
                                                padding:
                                                EdgeInsets
                                                    .all(
                                                    16.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        8.0)),),
                                              onPressed: () =>
                                                  openCancelModal(
                                                      context,
                                                      tripsDataSnapshot
                                                          .data,
                                                      tripsRentalBloc),
                                              child: Text(
                                                'Cancel trip',
                                                style: TextStyle(
                                                    fontFamily:
                                                    'Roboto',
                                                    fontSize:
                                                    16,
                                                    color: Color(
                                                        0xFF371D32)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                                    : new Container(),
                                Divider(),
                                // Start trip button
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
                                                  style: ElevatedButton
                                                      .styleFrom(
                                                    elevation:
                                                    0.0,
                                                    backgroundColor: inspectionInfoSnapshot
                                                        .data == null
                                                        ? Colors.grey
                                                        : Color(0xffFF8F68),
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
                                                    inspectionInfoSnapshot.data
                                                        == null
                                                        ? showDialog<void>(
                                                      context: context,
                                                      builder: (
                                                          BuildContext dialogContext) {
                                                        return
                                                          AlertDialog(
                                                            backgroundColor: Colors
                                                                .white,
                                                            content: Container(

                                                              height:
                                                              MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .height *
                                                                  .25,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                                crossAxisAlignment: CrossAxisAlignment
                                                                    .center,
                                                                children: [
                                                                  SizedBox(
                                                                    height: 10,
                                                                  ),
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
                                                                    "Please ask your host to finish their inspection and then start your trip",
                                                                    textAlign: TextAlign
                                                                        .center,
                                                                    style: TextStyle(
                                                                      fontFamily: 'Urbanist',
                                                                      fontSize: 14,

                                                                    ),),
                                                                  Spacer(),
                                                                  ElevatedButton(
                                                                    style: ButtonStyle(
                                                                        backgroundColor:
                                                                        MaterialStateProperty
                                                                            .all(
                                                                            Color(
                                                                                0xffFF8F68))),
                                                                    onPressed: () {
                                                                      Navigator
                                                                          .pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                      "OK",
                                                                      style: TextStyle(
                                                                          fontFamily: 'Urbanist',
                                                                          fontSize: 18,
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold),),
                                                                  )
                                                                ],
                                                              ),
                                                            ),

                                                          );
                                                      },
                                                    )
                                                        :
                                                    Navigator
                                                        .pushNamed(
                                                      context,
                                                      '/guest_start_inspection_ui',
                                                      arguments:
                                                      {
                                                        "tripsData": tripsDataSnapshot
                                                            .data,
                                                        "inspectionData": inspectionInfoSnapshot
                                                            .data
                                                      },
                                                    );
                                                  },
                                                  child: Text(
                                                    'Start Pick-Up Process',
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
                                Row(

                                    children: <Widget>[
                                      tripsTypeSnapshot.data == "Current" ?
                                      StreamBuilder<InspectionInfo>(
                                          stream: inspectionInfoBloc
                                              .inspectionInfoStream,
                                          builder: (context,
                                              inspectionInfoSnapshot) {
                                            return
                                              Expanded(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/rentout_guest_start_trip_details',
                                                            arguments: {
                                                              "tripsData": tripsDataSnapshot
                                                                  .data,
                                                              "inspectionData": inspectionInfoSnapshot
                                                                  .data,
                                                              "tripID": inspectionInfoSnapshot
                                                                  .data
                                                            },
                                                          );
                                                        },
                                                        style: ElevatedButton
                                                            .styleFrom(
                                                          primary: Color(
                                                              0xffFF8F68),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .circular(8),
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 10,
                                                              vertical: 15),
                                                          child: Text(
                                                            "Guest Start Trip Details",
                                                            style: TextStyle(
                                                              fontFamily: 'Urbanist',
                                                              fontSize: 15,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                     SizedBox(
                                                       width: MediaQuery
                                                           .of(context)
                                                           .size
                                                           .width,
                                                       child: ElevatedButton(
                                                          onPressed: () {
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/rentout_host_start_trip_details',
                                                              arguments: {
                                                                "tripsData": tripsDataSnapshot
                                                                    .data,
                                                                "tripID": inspectionInfoSnapshot
                                                                    .data,
                                                                "inspectionData": inspectionInfoSnapshot
                                                                    .data
                                                              },
                                                            );
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            primary: Color(
                                                                0xffFF8F68),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .circular(8),
                                                            ),
                                                          ),
                                                          child: Padding(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10,
                                                                vertical: 15),
                                                            child: Text(
                                                              "Host Start Trip Details",
                                                              style: TextStyle(
                                                                fontFamily: 'Urbanist',
                                                                fontSize: 15,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                     ),

                                                  ],
                                                ),
                                              );
                                          }) : Container(),
                                    ]),


                                Divider(),
                                // End trip button
                                tripsTypeSnapshot.data == 'Current'
                                    ? tripDetails!.tripType == 'Swap'
                                    ? StreamBuilder<Trips>(
                                    stream: tripsRentalBloc
                                        .swapTripsData,
                                    builder: (context,
                                        swapTripDataSnapshot) {
                                      return swapTripDataSnapshot
                                          .hasData &&
                                          swapTripDataSnapshot
                                              .data!
                                              .tripStatus !=
                                              'TripUndefined' &&
                                          swapTripDataSnapshot
                                              .data!
                                              .tripStatus !=
                                              'Booked' &&
                                          swapTripDataSnapshot
                                              .data!
                                              .tripStatus !=
                                              'Cancelled'
                                          ? Row(
                                        children: [
                                          Expanded(
                                            child:
                                            Column(
                                              children: [
                                                SizedBox(
                                                  width:
                                                  double.maxFinite,
                                                  child:
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation:
                                                      0.0,
                                                      backgroundColor:
                                                      Color(0xffFF8F68),
                                                      padding:
                                                      EdgeInsets.all(16.0),
                                                      shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius: BorderRadius
                                                              .circular(8.0)),),
                                                    onPressed:
                                                        () async {
                                                      Navigator.pushNamed(
                                                        context,
                                                        '/end_trip_ui',
//                                              '/end_trip',
                                                        arguments: {
                                                          'TRIP_DATA': tripsDataSnapshot
                                                              .data,
                                                          'SWAP_TRIP': swapTripDataSnapshot
                                                              .data
                                                        },
                                                      );
                                                    },
                                                    child:
                                                    Text(
                                                      'End trip',
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
                                      )
                                          : Container();
                                    })
                                    : Row(
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
                                                backgroundColor: Color(
                                                    0xffFF8F68),
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
                                                Navigator
                                                    .pushNamed(
                                                  context,
                                                  '/end_trip_ui',
//                                              '/end_trip',
                                                  arguments: {
                                                    'TRIP_DATA':
                                                    tripsDataSnapshot.data,
                                                  },
                                                );
                                              },
                                              child: Text(
                                                'End trip now',
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
                                )
                                    : new Container(),

                                tripsTypeSnapshot.data == 'Past' &&
                                    tripDetails!.tripType !=
                                        'Swap' &&
                                    (tripDetails!.hostProfile
                                    !.verificationStatus !=
                                        "Undefined" &&
                                        tripDetails!.guestProfile
                                        !.verificationStatus !=
                                            "Undefined")
                                    ? Padding(
                                  padding:
                                  const EdgeInsets.all(1.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            // SizedBox(
                                            //   width: double
                                            //       .maxFinite,
                                            //   child:
                                            //   ElevatedButton(
                                            //     style:ElevatedButton.styleFrom(
                                            //     elevation: 0.0,
                                            //     backgroundColor: Color(
                                            //         0xffFF8F68),
                                            //     padding:
                                            //     EdgeInsets
                                            //         .all(
                                            //         16.0),
                                            //     shape: RoundedRectangleBorder(
                                            //         borderRadius:
                                            //         BorderRadius.circular(
                                            //             8.0)),),
                                            //     onPressed:
                                            //         () async {
                                            //       String?
                                            //       profileID =
                                            //       await storage
                                            //           .read(
                                            //           key: 'profile_id');
                                            //
                                            //       if (profileID !=
                                            //           null) {
                                            //         String? postalCode = tripsDataSnapshot
                                            //             .data!.car!.about!.location!
                                            //             .postalCode !=
                                            //             null &&
                                            //             tripsDataSnapshot.data
                                            //                 !.car!.about!.location!
                                            //                 .postalCode !=
                                            //                 ''
                                            //             ? tripsDataSnapshot
                                            //             .data
                                            //             !.car!
                                            //             .about!
                                            //             .location!
                                            //             .postalCode
                                            //             : '';
                                            //         String? region = tripsDataSnapshot
                                            //             .data!.car!.about!.location!
                                            //             .region !=
                                            //             null &&
                                            //             tripsDataSnapshot.data
                                            //                 !.car!.about!.location!
                                            //                 .region !=
                                            //                 ''
                                            //             ? tripsDataSnapshot
                                            //             .data
                                            //             !.car!
                                            //             .about!
                                            //             .location!
                                            //             .region
                                            //             : '';
                                            //         String? locality = tripsDataSnapshot
                                            //             .data!.car!.about!.location!
                                            //             .locality !=
                                            //             null &&
                                            //             tripsDataSnapshot.data
                                            //                 !.car!.about!.location!
                                            //                 .locality !=
                                            //                 ''
                                            //             ? tripsDataSnapshot
                                            //             .data
                                            //             !.car!
                                            //             .about!
                                            //             .location!
                                            //             .locality
                                            //             : '';
                                            //
                                            //         if (postalCode!
                                            //             .length >
                                            //             3) {
                                            //           postalCode =
                                            //               postalCode.substring(
                                            //                   0,
                                            //                   3);
                                            //         }
                                            //         String address = postalCode +
                                            //             ', ' +
                                            //             region! +
                                            //             ', ' +
                                            //             locality!;
                                            //         address =
                                            //             address
                                            //                 .trim();
                                            //         address = address
                                            //             .replaceAll(
                                            //             ', ,',
                                            //             ', ');
                                            //         while (address
                                            //             .startsWith(
                                            //             ',')) {
                                            //           address =
                                            //               address
                                            //                   .substring(1);
                                            //           address =
                                            //               address
                                            //                   .trim();
                                            //         }
                                            //         while (address
                                            //             .endsWith(
                                            //             ',')) {
                                            //           address =
                                            //               address.substring(
                                            //                   0,
                                            //                   address.length -
                                            //                       1);
                                            //           address =
                                            //               address
                                            //                   .trim();
                                            //         }
                                            //         // Card null check
                                            //         _bookingInfo[
                                            //         "route"] =
                                            //         '/trips_rental_details_ui';
                                            //         _bookingInfo[
                                            //         'calendarID'] =
                                            //             tripsDataSnapshot
                                            //                 .data
                                            //                 !.car!
                                            //                 .calendarID!;
                                            //         _bookingInfo[
                                            //         'carID'] =
                                            //             tripsDataSnapshot
                                            //                 .data
                                            //                 !.carID!;
                                            //         _bookingInfo[
                                            //         'userID'] =
                                            //             tripsDataSnapshot
                                            //                 .data!
                                            //                 .userID!;
                                            //         _bookingInfo[
                                            //         'location'] =
                                            //             tripsDataSnapshot
                                            //                 .data
                                            //                 !.car!
                                            //                 .about!
                                            //                 .location!
                                            //                 .address!;
                                            //         _bookingInfo[
                                            //         'locAddress'] =
                                            //             address;
                                            //         _bookingInfo['locLat'] =
                                            //             tripsDataSnapshot
                                            //                 .data
                                            //                 !.car!
                                            //                 .about!
                                            //                 .location!
                                            //                 .latLng!
                                            //                 .latitude!;
                                            //         _bookingInfo['locLong'] =
                                            //             tripsDataSnapshot
                                            //                 .data
                                            //                 !.car!
                                            //                 .about!
                                            //                 .location!
                                            //                 .latLng!
                                            //                 .longitude!;
                                            //         _bookingInfo['customDeliveryEnable'] =
                                            //             tripsDataSnapshot
                                            //                 .data
                                            //                 !.car!
                                            //                 .pricing
                                            //                 !.rentalPricing!
                                            //                 .enableCustomDelivery!;
                                            //
                                            //         var res = await fetchCarData(
                                            //             tripsDataSnapshot
                                            //                 .data
                                            //                 !.carID);
                                            //         var _carDetails =
                                            //         json.decode(
                                            //             res.body!)['Car'];
                                            //         _bookingInfo[
                                            //         "window"] =
                                            //         _carDetails['Availability']
                                            //         [
                                            //         'RentalAvailability']
                                            //         [
                                            //         'BookingWindow'];
                                            //
                                            //         handleShowAddCardModal();
                                            //       }
                                            //     },
                                            //     child: Text(
                                            //       'Book again',
                                            //       style: TextStyle(
                                            //           fontFamily:
                                            //           'Urbanist',
                                            //           fontSize:
                                            //           18,
                                            //           color: Colors
                                            //               .white),
                                            //     ),
                                            //   ),
                                            // ),
                                            SizedBox(
                                              width: double
                                                  .maxFinite,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor:
                                                  tripDetails!.car == null
                                                      ? null
                                                      : Color(0xffFF8F68),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                                ),
                                                onPressed: tripDetails!.car ==
                                                    null
                                                    ? null
                                                    : () async {
                                                  String? profileID =
                                                  await storage.read(
                                                      key:
                                                      'profile_id');

                                                  if (profileID != null) {
                                                    // Card null check

                                                    String postalCode = tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .postalCode !=
                                                        null &&
                                                        tripDetails!
                                                            .car!
                                                            .about!
                                                            .location!
                                                            .postalCode !=
                                                            ''
                                                        ? tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .postalCode!
                                                        : '';
                                                    String region = tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .region !=
                                                        null &&
                                                        tripDetails!
                                                            .car!
                                                            .about!
                                                            .location!
                                                            .region !=
                                                            ''
                                                        ? tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .region!
                                                        : '';
                                                    String locality = tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .locality !=
                                                        null &&
                                                        tripDetails!
                                                            .car!
                                                            .about!
                                                            .location!
                                                            .locality !=
                                                            ''
                                                        ? tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .locality!
                                                        : '';

                                                    if (postalCode.length >
                                                        3) {
                                                      postalCode =
                                                          postalCode
                                                              .substring(
                                                              0, 3);
                                                    }
                                                    String address =
                                                        postalCode +
                                                            ', ' +
                                                            region +
                                                            ', ' +
                                                            locality;
                                                    address =
                                                        address.trim();
                                                    address =
                                                        address.replaceAll(
                                                            ', ,', ', ');
                                                    while (address
                                                        .startsWith(',')) {
                                                      address = address
                                                          .substring(1);
                                                      address =
                                                          address.trim();
                                                    }
                                                    while (address
                                                        .endsWith(',')) {
                                                      address =
                                                          address.substring(
                                                              0,
                                                              address.length -
                                                                  1);
                                                      address =
                                                          address.trim();
                                                    }
                                                    _bookingInfo["route"] =
                                                    '/trips_cancelled_details';
                                                    _bookingInfo[
                                                    'calendarID'] =
                                                    tripDetails!.car!
                                                        .calendarID!;
                                                    _bookingInfo['carID'] =
                                                    tripDetails!.carID!;
                                                    _bookingInfo['userID'] =
                                                    tripDetails!.userID!;
                                                    _bookingInfo[
                                                    'location'] =
                                                    tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .address!;
                                                    _bookingInfo[
                                                    'FormattedAddress'] =
                                                    tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .formattedAddress!;
                                                    _bookingInfo[
                                                    'locAddress'] =
                                                        address;
                                                    _bookingInfo['locLat'] =
                                                    tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .latLng!
                                                        .latitude!;
                                                    _bookingInfo[
                                                    'locLong'] =
                                                    tripDetails!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .latLng!
                                                        .longitude!;
                                                    _bookingInfo[
                                                    'customDeliveryEnable'] =
                                                    tripDetails!
                                                        .car!
                                                        .pricing!
                                                        .rentalPricing!
                                                        .enableCustomDelivery!;

                                                    var res =
                                                    await fetchCarData(
                                                        tripDetails!.carID);
                                                    var _carDetails =
                                                    json.decode(res
                                                        .body!)['Car'];
                                                    _bookingInfo[
                                                    "window"] = _carDetails[
                                                    'Availability']
                                                    [
                                                    'RentalAvailability']
                                                    ['BookingWindow'];
                                                    _bookingInfo[
                                                    'FormattedAddress'] =
                                                    _carDetails['About']
                                                    ['Location']
                                                    [
                                                    'FormattedAddress'];

                                                    handleShowAddCardModal();
                                                  }
                                                },
                                                child: Text(
                                                  'Book again',
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 18,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 10,)
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                    : Container(),
                                // Reviw button
                                tripsTypeSnapshot.data == 'Past' &&
                                    tripDetails!.tripType != 'Swap'
                                    ? tripsDataSnapshot.data
                                !.carRatingReviewAdded ==
                                    false ||
                                    tripsDataSnapshot.data!
                                        .hostRatingReviewAdded ==
                                        false
                                    ? Row(
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
                                                backgroundColor: Color(
                                                    0xffF2F2F2),
                                                padding:
                                                EdgeInsets
                                                    .all(
                                                    16.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0)),
                                              ),

                                              onPressed: () {}
                                              // openReviewModal(
                                              //     context,
                                              //     tripsDataSnapshot),
                                              ,
                                              child: Text(
                                                'Leave a review',
                                                style: TextStyle(
                                                    fontFamily:
                                                    'Urbanist',
                                                    fontSize:
                                                    16,
                                                    color: Color(
                                                        0xFF371D32)),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                                    : new Container()
                                    : Container(),
                                StreamBuilder<Trips>(
                                    stream:
                                    tripsRentalBloc.swapTripsData,
                                    builder: (context,
                                        swapTripDataSnapshot) {
                                      return swapTripDataSnapshot
                                          .hasData
                                          ? Column(
                                        children: [
                                          tripsTypeSnapshot
                                              .data ==
                                              'Past' &&
                                              tripDetails
                                              !.tripType ==
                                                  'Swap' &&
                                              swapTripDataSnapshot
                                                  .data!
                                                  .tripStatus ==
                                                  "Ended"
                                              ? Column(
                                            children: [
                                              SizedBox(
                                                  height:
                                                  16),
                                              Divider(),
                                              Row(
                                                children: <
                                                    Widget>[
                                                  Expanded(
                                                    child:
                                                    Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                            width: double
                                                                .maxFinite,
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .all(8.0),
                                                              child: ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  elevation: 0.0,
                                                                  backgroundColor: Color(
                                                                      0xFFFF8F62),
                                                                  padding: EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius
                                                                          .circular(
                                                                          8.0)),

                                                                ),
                                                                onPressed: () {
                                                                  Navigator
                                                                      .pushNamed(
                                                                    context,
                                                                    '/swap_inspection_ui',
                                                                    arguments: {
                                                                      'tripType': "Past",
                                                                      'trip': tripDetails,
                                                                    },
                                                                  );
                                                                },
                                                                child: Text(
                                                                  'Next: Inspect your vehicle',
                                                                  style: TextStyle(
                                                                      fontFamily: 'Urbanist',
                                                                      fontSize: 18,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                              : Container(),
                                          tripsTypeSnapshot
                                              .data ==
                                              'Past' &&
                                              tripDetails
                                              !.tripType ==
                                                  'Swap' &&
                                              swapTripDataSnapshot
                                                  .data!
                                                  .tripStatus ==
                                                  "Completed"
                                              ? Column(
                                            children: [
                                              SizedBox(
                                                  height:
                                                  16),
                                              Divider(),
                                              tripsTypeSnapshot.data ==
                                                  'Past' &&
                                                  tripDetails!.tripType ==
                                                      'Swap' &&
                                                  (tripsDataSnapshot.data
                                                  !.carRatingReviewAdded ==
                                                      false ||
                                                      tripsDataSnapshot.data!
                                                          .hostRatingReviewAdded ==
                                                          false ||
                                                      swapTripDataSnapshot.data!
                                                          .guestRatingReviewAdded ==
                                                          false)
                                                  ? Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          width: double
                                                              .maxFinite,
                                                          child: ElevatedButton(
                                                            style: ElevatedButton
                                                                .styleFrom(
                                                              elevation: 0.0,
                                                              backgroundColor: Color(
                                                                  0xffF2F2F2),
                                                              padding: EdgeInsets
                                                                  .all(16.0),
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius
                                                                      .circular(
                                                                      8.0)),),
                                                            onPressed: () {}
                                                            // openSwapReviewModal(
                                                            //     context,
                                                            //     tripsDataSnapshot,
                                                            //     swapTripDataSnapshot)
                                                            ,
                                                            child: Text(
                                                              'Leave a review',
                                                              style: TextStyle(
                                                                  fontFamily: 'Urbanist',
                                                                  fontSize: 16,
                                                                  color: Color(
                                                                      0xFF371D32)),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                                  : new Container(),
                                              swapTripDataSnapshot.data!
                                                  .reimbursementStatus ==
                                                  'Unapproved'
                                                  ? Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                            width: double
                                                                .maxFinite,
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .all(8.0),
                                                              child: ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  elevation: 0.0,
                                                                  backgroundColor: Color(
                                                                      0xFFFF8F62),
                                                                  padding: EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius
                                                                          .circular(
                                                                          8.0)),),
                                                                onPressed: () {
                                                                  // handleShowReimbursementModal(tripDetails!.tripID!);
                                                                  // Navigator
                                                                  //     .pushNamed(
                                                                  //     context,
                                                                  //     '/reimbursement',
                                                                  //     arguments: tripDetails
                                                                  //         .swapData
                                                                  //         .otherTripID);
                                                                },
                                                                child: Text(
                                                                  'Request reimbursement',
                                                                  style: TextStyle(
                                                                      fontFamily: 'Urbanist',
                                                                      fontSize: 18,
                                                                      color: Colors
                                                                          .white),
                                                                ),
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                                  : Container(),
                                            ],
                                          )
                                              : Container(),
                                        ],
                                      )
                                          : Container();
                                    }),

                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : Container();
                })
                : Container();
          }),
    );
  }

  void openReviewModal(context, AsyncSnapshot<Trips> tripsDataSnapshot) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        isDismissible: true,
        builder: (BuildContext buildContext) {
          return Container(
            margin: const EdgeInsets.all(16.0),
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 345,
                  maxHeight: MediaQuery
                      .of(context)
                      .size
                      .height - 10),
              child: Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom),
                // height: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 24),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.keyboard_backspace,
                                color: Colors.orange,
                              ),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                "Leave a review",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xFF371D32)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    SizedBox(height: 15.0),
                    //Rating car//
                    tripsDataSnapshot.data!.carRatingReviewAdded == false
                        ? StreamBuilder<RateTripCarRequest>(
                        stream: endTripRentalBloc.tripRateCar,
                        builder: (context, tripRateCarSnapshot) {
                          return tripRateCarSnapshot.hasData &&
                              tripRateCarSnapshot.data != null
                              ? Container(
                            height: 100.0,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                          top: 16),
                                      child: Text(
                                        "Rate the vehicle",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          top: 10),
                                      child: SmoothStarRating(
                                          allowHalfRating: false,
                                          onRatingChanged: (v) {
                                            tripRateCarSnapshot
                                                .data!.rateCar =
                                                v.toString();
                                            endTripRentalBloc
                                                .changedTripRateCar
                                                .call(
                                                tripRateCarSnapshot
                                                    .data!);
                                          },
                                          starCount: 5,
                                          rating: double.parse(
                                              tripRateCarSnapshot
                                                  .data!.rateCar!),
                                          size: 20.0,
                                          // isReadOnly: false,
                                          // fullRatedIconData: Icons.blur_off,
                                          // halfRatedIconData: Icons.blur_on,
                                          color: Color(0xffFF8F68),
                                          borderColor:
                                          Color(0xffFF8F68),
                                          spacing: 0.0),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16.0),
                                  child: TextField(
                                    textInputAction:
                                    TextInputAction.done,
                                    onChanged: (review) {
                                      tripRateCarSnapshot.data!
                                          .reviewCarDescription =
                                          review;
                                      endTripRentalBloc
                                          .changedTripRateCar
                                          .call(tripRateCarSnapshot
                                          .data!);
                                    },
                                    decoration: InputDecoration(
                                        hintText:
                                        'Write a vehicle review[optional]',
                                        hintStyle: TextStyle(
                                            fontFamily:
                                            'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF686868),
                                            fontStyle:
                                            FontStyle.italic),
                                        border: InputBorder.none),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Container();
                        })
                        : Container(),
                    SizedBox(height: 15.0),

                    //Rate host//
                    tripsDataSnapshot.data!.hostRatingReviewAdded == false
                        ? StreamBuilder<RateTripHostRequest>(
                        stream: endTripRentalBloc.tripRateHost,
                        builder: (context, tripRateHostSnapshot) {
                          return tripRateHostSnapshot.hasData &&
                              tripRateHostSnapshot.data != null
                              ? Container(
                            height: 100.0,
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 16.0,
                                          right: 16.0,
                                          top: 16),
                                      child: Text(
                                        "Rate the host",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32)),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8.0,
                                          right: 8.0,
                                          top: 10),
                                      child: SmoothStarRating(
                                          allowHalfRating: false,
                                          onRatingChanged: (v) {
                                            tripRateHostSnapshot
                                                .data!.rateHost =
                                                v.toString();
                                            endTripRentalBloc
                                                .changedTripRateHost
                                                .call(
                                                tripRateHostSnapshot
                                                    .data!);
                                          },
                                          starCount: 5,
                                          rating: double.parse(
                                              tripRateHostSnapshot
                                                  .data!.rateHost!),
                                          size: 20.0,
                                          // isReadOnly: false,
                                          // fullRatedIconData: Icons.blur_off,
                                          // halfRatedIconData: Icons.blur_on,
                                          color: Color(0xffFF8F68),
                                          borderColor:
                                          Color(0xffFF8F68),
                                          spacing: 0.0),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16.0),
                                  child: TextField(
                                    textInputAction:
                                    TextInputAction.done,
                                    onChanged: (hostReviews) {
                                      tripRateHostSnapshot.data!
                                          .reviewHostDescription =
                                          hostReviews;
                                      endTripRentalBloc
                                          .changedTripRateHost
                                          .call(tripRateHostSnapshot
                                          .data!);
                                    },
                                    decoration: InputDecoration(
                                        hintText:
                                        'Write a host review[optional]',
                                        hintStyle: TextStyle(
                                            fontFamily:
                                            'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF686868),
                                            fontStyle:
                                            FontStyle.italic),
                                        border: InputBorder.none),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Container();
                        })
                        : Container(),
                    SizedBox(height: 20.0),
                    Row(
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
                                        borderRadius: BorderRadius.circular(
                                            8.0)),),
                                  onPressed: () async {
                                    await endTripRentalBloc.rateThisTripAndHost(
                                        tripsDataSnapshot.data!);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Done',
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
                  ],
                ),
              ),
            ),
          );
        });
  }

  void openSwapReviewModal(context,
      AsyncSnapshot<Trips> tripsDataSnapshot,
      AsyncSnapshot<Trips> swapTripDataSnapshot,) {
    showModalBottomSheet(
        isScrollControlled: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        isDismissible: true,
        builder: (BuildContext buildContext) {
          return Container(
            margin: const EdgeInsets.all(16.0),
            height: MediaQuery
                .of(context)
                .size
                .height,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 345,
                  maxHeight: MediaQuery
                      .of(context)
                      .size
                      .height - 10),
              child: Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery
                        .of(context)
                        .viewInsets
                        .bottom),
                // height: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: StreamBuilder<RateTripCarRequest>(
                    stream: endTripRentalBloc.tripRateCar,
                    builder: (context, tripRateCarSnapshot) {
                      return StreamBuilder<RateTripHostRequest>(
                          stream: endTripRentalBloc.tripRateHost,
                          builder: (context, tripRateHostSnapshot) {
                            return StreamBuilder<RateTripGuestRequest>(
                                stream: endTripRentalBloc.rateTripGuest,
                                builder: (context, rateTripGuestSnapshot) {
                                  return ListView(
                                    scrollDirection: Axis.vertical,
                                    shrinkWrap: true,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 16, bottom: 24),
                                          child: Stack(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Icon(
                                                  Icons.keyboard_backspace,
                                                  color: Colors.orange,
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.topCenter,
                                                child: Text(
                                                  "Leave a review",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(0xFF371D32)),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15.0),
                                      //Rating car//
                                      tripsDataSnapshot
                                          .data!.carRatingReviewAdded ==
                                          false
                                          ? tripRateCarSnapshot.hasData &&
                                          tripRateCarSnapshot.data !=
                                              null
                                          ? Container(
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                          BorderRadius.circular(
                                              5),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      left: 16.0,
                                                      right: 16.0,
                                                      top: 16),
                                                  child: Text(
                                                    "Rate the vehicle",
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color: Color(
                                                            0xFF371D32)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      left: 8.0,
                                                      right: 8.0,
                                                      top: 10),
                                                  child:
                                                  SmoothStarRating(
                                                      allowHalfRating:
                                                      false,
                                                      onRatingChanged:
                                                          (v) {
                                                        tripRateCarSnapshot
                                                            .data!
                                                            .rateCar =
                                                            v.toString();
                                                        endTripRentalBloc
                                                            .changedTripRateCar
                                                            .call(
                                                            tripRateCarSnapshot
                                                                .data!);
                                                      },
                                                      starCount:
                                                      5,
                                                      rating: double.parse(
                                                          tripRateCarSnapshot
                                                              .data!
                                                              .rateCar!),
                                                      size: 20.0,
                                                      // isReadOnly:
                                                      // false,
                                                      // fullRatedIconData: Icons.blur_off,
                                                      // halfRatedIconData: Icons.blur_on,
                                                      color: Color(
                                                          0xffFF8F68),
                                                      borderColor:
                                                      Color(
                                                          0xffFF8F68),
                                                      spacing:
                                                      0.0),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 16.0,
                                                  right: 16.0),
                                              child: TextField(
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                onChanged: (review) {
                                                  tripRateCarSnapshot
                                                      .data
                                                  !.reviewCarDescription =
                                                      review;
                                                  endTripRentalBloc
                                                      .changedTripRateCar
                                                      .call(
                                                      tripRateCarSnapshot
                                                          .data!);
                                                },
                                                decoration: InputDecoration(
                                                    hintText:
                                                    'Write a vehicle review[optional]',
                                                    hintStyle: TextStyle(
                                                        fontFamily:
                                                        'Urbanist',
                                                        fontSize: 14,
                                                        color: Color(
                                                            0xFF686868),
                                                        fontStyle:
                                                        FontStyle
                                                            .italic),
                                                    border:
                                                    InputBorder
                                                        .none),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          : Container()
                                          : Container(),
                                      SizedBox(height: 15.0),

                                      //Rate host//
                                      tripsDataSnapshot
                                          .data!.hostRatingReviewAdded ==
                                          false
                                          ? tripRateHostSnapshot.hasData &&
                                          tripRateHostSnapshot.data !=
                                              null
                                          ? Container(
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                          BorderRadius.circular(
                                              5),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      left: 16.0,
                                                      right: 16.0,
                                                      top: 16),
                                                  child: Text(
                                                    "Rate the host",
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color: Color(
                                                            0xFF371D32)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      left: 8.0,
                                                      right: 8.0,
                                                      top: 10),
                                                  child:
                                                  SmoothStarRating(
                                                      allowHalfRating:
                                                      false,
                                                      onRatingChanged:
                                                          (v) {
                                                        tripRateHostSnapshot
                                                            .data!
                                                            .rateHost =
                                                            v.toString();
                                                        print(v
                                                            .toString());
                                                        endTripRentalBloc
                                                            .changedTripRateHost
                                                            .call(
                                                            tripRateHostSnapshot
                                                                .data!);
                                                      },
                                                      starCount:
                                                      5,
                                                      rating: double.parse(
                                                          tripRateHostSnapshot
                                                              .data!
                                                              .rateHost!),
                                                      size: 20.0,
                                                      // isReadOnly:
                                                      // false,
                                                      // // fullRatedIconData: Icons.blur_off,
                                                      // halfRatedIconData: Icons.blur_on,
                                                      color: Color(
                                                          0xffFF8F68),
                                                      borderColor:
                                                      Color(
                                                          0xffFF8F68),
                                                      spacing:
                                                      0.0),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 16.0,
                                                  right: 16.0),
                                              child: TextField(
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                onChanged:
                                                    (hostReviews) {
                                                  tripRateHostSnapshot
                                                      .data!
                                                      .reviewHostDescription =
                                                      hostReviews;
                                                  endTripRentalBloc
                                                      .changedTripRateHost
                                                      .call(
                                                      tripRateHostSnapshot
                                                          .data!);
                                                },
                                                decoration: InputDecoration(
                                                    hintText:
                                                    'Write a host review[optional]',
                                                    hintStyle: TextStyle(
                                                        fontFamily:
                                                        'Urbanist',
                                                        fontSize: 14,
                                                        color: Color(
                                                            0xFF686868),
                                                        fontStyle:
                                                        FontStyle
                                                            .italic),
                                                    border:
                                                    InputBorder
                                                        .none),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          : Container()
                                          : Container(),
                                      SizedBox(height: 15.0),

                                      ///guest rating//
                                      swapTripDataSnapshot.data!
                                          .guestRatingReviewAdded ==
                                          false
                                          ? rateTripGuestSnapshot.hasData &&
                                          rateTripGuestSnapshot.data !=
                                              null
                                          ? Container(
                                        height: 100.0,
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                          BorderRadius.circular(
                                              5),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      left: 16.0,
                                                      right: 16.0,
                                                      top: 16),
                                                  child: Text(
                                                    "Rate the guest",
                                                    textAlign:
                                                    TextAlign
                                                        .center,
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color: Color(
                                                            0xFF371D32)),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .only(
                                                      left: 8.0,
                                                      right: 8.0,
                                                      top: 10),
                                                  child:
                                                  SmoothStarRating(
                                                      allowHalfRating:
                                                      false,
                                                      onRatingChanged:
                                                          (v) {
                                                        print(v
                                                            .toString());
                                                        rateTripGuestSnapshot
                                                            .data!
                                                            .rateGuest =
                                                            v.toString();
                                                        endTripRentalBloc
                                                            .changedRateTripGuest
                                                            .call(
                                                            rateTripGuestSnapshot
                                                                .data!);
                                                      },
                                                      starCount:
                                                      5,
                                                      rating: double.parse(
                                                          rateTripGuestSnapshot
                                                              .data!
                                                              .rateGuest!),
                                                      size: 20.0,
                                                      // isReadOnly:
                                                      // false,
                                                      // // fullRatedIconData: Icons.blur_off,
                                                      // halfRatedIconData: Icons.blur_on,
                                                      color: Color(
                                                          0xffFF8F68),
                                                      borderColor:
                                                      Color(
                                                          0xffFF8F68),
                                                      spacing:
                                                      0.0),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding:
                                              const EdgeInsets
                                                  .only(
                                                  left: 16.0,
                                                  right: 16.0),
                                              child: TextField(
                                                textInputAction:
                                                TextInputAction
                                                    .done,
                                                onChanged:
                                                    (guestReviews) {
                                                  rateTripGuestSnapshot
                                                      .data!
                                                      .reviewGuestDescription =
                                                      guestReviews;
                                                  endTripRentalBloc
                                                      .changedRateTripGuest
                                                      .call(
                                                      rateTripGuestSnapshot
                                                          .data!);
                                                },
                                                decoration: InputDecoration(
                                                    hintText:
                                                    'Write a guest review[optional]',
                                                    hintStyle: TextStyle(
                                                        fontFamily:
                                                        'Urbanist',
                                                        fontSize: 14,
                                                        color: Color(
                                                            0xFF686868),
                                                        fontStyle:
                                                        FontStyle
                                                            .italic),
                                                    border:
                                                    InputBorder
                                                        .none),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                          : Container()
                                          : Container(),

                                      SizedBox(height: 20.0),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  width: double.maxFinite,
                                                  child: ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      elevation: 0.0,
                                                      backgroundColor: Color(
                                                          0xffFF8F68),
                                                      padding:
                                                      EdgeInsets.all(16.0),
                                                      shape:
                                                      RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius
                                                              .circular(
                                                              8.0)),),
                                                    onPressed: tripRateCarSnapshot
                                                        .hasData &&
                                                        tripRateHostSnapshot
                                                            .hasData &&
                                                        rateTripGuestSnapshot
                                                            .hasData &&
                                                        ((double.tryParse(
                                                            tripRateCarSnapshot
                                                                .data!
                                                                .rateCar!) !=
                                                            0 &&
                                                            tripsDataSnapshot
                                                                .data
                                                            !
                                                                .carRatingReviewAdded ==
                                                                false) ||
                                                            (double.tryParse(
                                                                tripRateHostSnapshot
                                                                    .data!
                                                                    .rateHost!) !=
                                                                0 &&
                                                                tripsDataSnapshot
                                                                    .data!
                                                                    .hostRatingReviewAdded ==
                                                                    false) ||
                                                            (double.tryParse(
                                                                rateTripGuestSnapshot
                                                                    .data!
                                                                    .rateGuest!) !=
                                                                0 &&
                                                                swapTripDataSnapshot
                                                                    .data!
                                                                    .guestRatingReviewAdded ==
                                                                    false))
                                                        ? () async {
                                                      await endTripRentalBloc
                                                          .rateThisTripAndHost(
                                                          tripsDataSnapshot
                                                              .data!);
                                                      await endTripRentalBloc
                                                          .rateGuest(
                                                          swapTripDataSnapshot
                                                              .data!);
                                                      Navigator.pop(
                                                          context);
                                                    }
                                                        : null,
                                                    child: Text(
                                                      'Done',
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
                                    ],
                                  );
                                });
                          });
                    }),
              ),
            ),
          );
        });
  }

  Widget _vehicleDocs(String title, int type) {
    return InkWell(
      onTap: () {
        if (type == 0) {} else if (type == 1) {
          print(insuranceDocumentID);
          NavigationService().push(
            MaterialPageRoute(
              builder: (context) =>
                  PdfView(
                    title: "Insurance",
                    id: insuranceDocumentID,
                  ),
            ),
          );
        } else if (type == 2) {
          print(infoCardDocumentID);
          NavigationService().push(
            MaterialPageRoute(
              builder: (context) =>
                  PdfView(
                    title: "Info Card",
                    id: infoCardDocumentID,
                  ),
            ),
          );
        } else {}
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF371D32)),
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Text(
                "View",
                style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    color: Color(0xFF353B50)),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 15,
              ),
            ],
          ),
        ],
      ),
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
