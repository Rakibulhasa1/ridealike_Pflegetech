import 'dart:convert' show json;
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
// import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:ridealike/pages/trips/bloc/trips_rental_bloc.dart';
import 'package:ridealike/pages/trips/request_service/insurance_roadside_assist_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_car_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_guest_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_host_request.dart';
import 'package:ridealike/pages/trips/request_service/request_reimbursement.dart';
//import 'package:ridealike/pages/trips/trips_response_model.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/insurance_roadside_assistnumber_response.dart';
import 'package:ridealike/widgets/cancel_modal.dart';
import 'package:ridealike/widgets/pdfview.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
// import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_events/app_events_utils.dart';
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
        return CancelModal(tripData: tripDetails
          // onCahngeNote: handleChangeNote,
          // onPressCancel: handleCancel,
        );
      });
}

InsuranceRoadSideNumbers? insuranceRoadSideNumbers;
TripAllUserStatusGroupResponse? tripAllUserStatusGroupResponse;



class DashboardTripsRentalDetails extends StatefulWidget {
  @override
  _DashboardTripsRentalDetailsState createState() => _DashboardTripsRentalDetailsState();
}

class _DashboardTripsRentalDetailsState extends State<DashboardTripsRentalDetails> {
  final endTripRentalBloc = EndTripRentalBloc();

  final tripsRentalBloc = TripsRentalBloc();
  Trips? tripDetails;

  TripAllUserStatusGroupResponse? ownerShipId;

  String insuranceDocumentID = "";
  String infoCardDocumentID = "";

  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Dashboard Past Trips"});
    insuranceRoadAssistNumber();
    getVehicleDocs();
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
      var response = await HttpClient.post(
          getInsuranceAndInfoCardUrl,
          {});
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
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    tripsRentalBloc.changePaddingHeight.call(0.0);
    tripsRentalBloc.changedCancellationNote.call('');

    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    Trips tripDetails = receivedData['trip'];
    String tripType = receivedData['tripType'];
    tripsRentalBloc.changedTripsData.call(tripDetails);
    tripsRentalBloc.changedTripsTypeData.call(tripType);
    tripsRentalBloc.getTripByIdMethod(tripDetails);
    RateTripCarRequest rateTripCarRequest = RateTripCarRequest(
        inspectionByUserID: tripDetails.userID,
        tripID: tripDetails.tripID,
        rateCar: '0',
        reviewCarDescription: '');

    RateTripHostRequest rateTripHostRequest = RateTripHostRequest(
        tripID: tripDetails.tripID,
        inspectionByUserID: tripDetails.userID,
        rateHost: '0',
        reviewHostDescription: '');

    endTripRentalBloc.changedTripRateCar.call(rateTripCarRequest);
    endTripRentalBloc.changedTripRateHost.call(rateTripHostRequest);

//    print(tripDetails.carYear);
    return Scaffold(
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
                                (tripsDataSnapshot.data!.carImageId ==
                                    null ||
                                    tripsDataSnapshot
                                        .data!.carImageId ==
                                        '')
                                    ? AssetImage(
                                  'images/car-placeholder.png',
                                ) as Widget
                                    : Image.network(
                                  '$storageServerUrl/${tripsDataSnapshot.data!.carImageId}',
                                  fit: BoxFit.fill,
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
                                            "Index": tripType == 'Upcoming' ? 0 : tripType == 'Current' ? 1 : 2
                                          };

                                      Navigator.pop(context);

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
                                              tripDetails.tripType ==
                                                  'Swap'
                                                  ? '${tripsTypeSnapshot.data} swap'
                                                  : '${tripsTypeSnapshot.data} rental',
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
                                          .data!.startDateTime!
                                          .toLocal()),
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
                                          .data!.endDateTime!
                                          .toLocal()),
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
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),

                                //location//

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    SizedBox(
                                      width: MediaQuery.of(context)
                                          .size
                                          .width *
                                          0.85,
                                      child: AutoSizeText(
                                        tripsDataSnapshot
                                            .data!.location!.address!,
                                        overflow:
                                        TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 12,
                                            color: Color(0xFF353B50)),
                                        maxLines: 3,
                                      ),
//                                                width: 345,
                                    ),
                                    // Padding(
                                    //   padding: const EdgeInsets.only(
                                    //       right: 10),
                                    //   child: Icon(
                                    //     Icons.arrow_forward_ios,
                                    //     size: 15,
                                    //   ),
                                    // )
                                  ],
                                ),

                                // Location note//
                                tripDetails.car!.about!.location
                                    !.notes !=
                                    null &&
                                    tripDetails.car!.about!.location
                                        !.notes !=
                                        ''
                                    ? Divider()
                                    : Container(),
                                tripDetails.car!.about!.location
                                    !.notes !=
                                    null &&
                                    tripDetails.car!.about!.location
                                        !.notes !=
                                        ''
                                    ? Row(
                                  children: [
                                    Icon(Icons.note),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Container(
                                      height:
                                      MediaQuery.of(context)
                                          .size
                                          .height *
                                          .12,
                                      width:
                                      MediaQuery.of(context)
                                          .size
                                          .width *
                                          .77,
                                      child: Align(
                                        alignment: Alignment
                                            .centerLeft,
                                        child: AutoSizeText(
                                          '${tripDetails.car!.about!.location!.notes}',
                                          maxLines: 4,
                                          overflow: TextOverflow
                                              .ellipsis,
                                          style: TextStyle(
                                              color: Color(
                                                  0xff353B50),
                                              fontFamily:
                                              'Open Sans Regular',
                                              fontWeight:
                                              FontWeight
                                                  .normal,
                                              fontSize: 12),
                                        ),
                                      ),
                                    ),
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
                                tripDetails.tripType == 'Swap'
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
                                tripDetails.tripType == 'Swap'
                                    ? InkWell(
                                  onTap: () {
                                    //todo
                                    Navigator.pushNamed(context,
                                        '/car_details_non_search',
                                        arguments: {
                                          'carID':
                                          tripsDataSnapshot
                                              .data!.carID,
                                          'bookingButton': false
                                        });
                                  },
                                  child: Container(
                                    height: deviceHeight * 0.08,
                                    width: deviceWidth,
                                    padding: EdgeInsets.only(
                                        top: 10),
                                    child: Stack(
                                      children: <Widget>[
                                        ClipOval(
                                          child: Image(
                                            height: 30,
                                            width: 30,
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                '$storageServerUrl/${tripDetails.myCarForSwap!.imagesAndDocuments!.images!.mainImageID}'),
                                          ),
                                        ),
                                        Positioned(
                                          left: 0.0,
                                          bottom: 6,
                                          child: ClipOval(
                                            child: Image(
                                              height: 30,
                                              width: 30,
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                  '$storageServerUrl/${tripDetails.car!.imagesAndDocuments!.images!.mainImageID}'),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 40,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
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
                                                    width: deviceWidth * 0.8,
                                                    child:
                                                    AutoSizeText(
                                                      tripsRentalBloc
                                                          .getTextForSwappedCar(tripDetails),
                                                      maxLines:
                                                      1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color: Color(0xff353B50),
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Icon(
                                                Icons
                                                    .arrow_forward_ios,
                                                size: 15,
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
                                    Navigator.pushNamed(context,
                                        '/car_details_non_search',
                                        arguments: {
                                          'carID':
                                          tripsDataSnapshot
                                              .data!.carID,
                                          'bookingButton': false
                                        });
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
                                                  .data
                                                  !.carImageId !=
                                                  null ||
                                                  tripsDataSnapshot
                                                      .data
                                                      !.carImageId !=
                                                      '')
                                                  ? CircleAvatar(
                                                backgroundImage:
                                                NetworkImage(
                                                    '$storageServerUrl/${tripsDataSnapshot.data!.carImageId}'),
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
                                                  fontSize: 16,
                                                  color: Color(
                                                      0xFF371D32)),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              tripsDataSnapshot
                                                  .data!
                                                  .carYear ==
                                                  null
                                                  ? ''
                                                  : tripsDataSnapshot
                                                  .data!
                                                  .carYear! +
                                                  ' ' +
                                                  tripsDataSnapshot
                                                      .data!
                                                      .car!
                                                      .about!
                                                      .make! +
                                                  ' ' +
                                                  tripsDataSnapshot
                                                      .data!
                                                      .car!
                                                      .about!
                                                      .model!,
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
                                // SizedBox(
                                //   height: 5,
                                // ),
                                tripsTypeSnapshot.data == 'Past' &&
                                    tripDetails.tripType == 'Swap'
                                    ? Container()
                                    : Divider(),
                                tripsTypeSnapshot.data == 'Past' &&
                                    tripDetails.tripType == 'Swap'
                                    ? Container()
                                    : SizedBox(
                                  height: 5,
                                ),
                                //licence pnumber//
                                tripsTypeSnapshot.data == 'Past' &&
                                    tripDetails.tripType == 'Swap'
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
                                      tripsDataSnapshot.data!
                                          .carLicense !=
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
                                SizedBox(
                                  height: 5,
                                ),
                                Divider(),
                                //host name//
                                InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(
                                        context, '/user_profile',
                                        arguments: tripDetails
                                            .hostProfile!
                                            .toJson());
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
                                                    '$storageServerUrl/${tripsDataSnapshot.data!.hostProfile!.imageID}'),
                                                radius: 17.5,
                                              )
                                                  : CircleAvatar(
                                                backgroundImage:
                                                AssetImage(
                                                  'images/user.png',
                                                ),
                                                radius: 17.5,
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
                                              '${tripsDataSnapshot.data!.hostProfile!.firstName} ${tripsDataSnapshot.data!.hostProfile!.lastName}',
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
                                ),
                                Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                tripsTypeSnapshot.data == 'Past'
                                    ? InkWell(
                                  onTap: () {
                                    // TODO receipt
                                    if (tripDetails.tripType ==
                                        'Swap') {
                                      Navigator.pushNamed(
                                          context,
                                          '/receipt_swap',
                                          arguments: tripDetails
                                              .bookingID);
                                    } else {
                                      Navigator.pushNamed(
                                          context, '/receipt',
                                          arguments: tripDetails
                                              .bookingID);
                                    }
                                  },
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          tripDetails.tripType == 'Swap'
                                              ? 'Trip earnings'
                                              :
                                          "Trip cost",
                                          style: TextStyle(
                                              fontFamily:
                                              'Urbanist',
                                              fontSize: 16,
                                              color: Color(
                                                  0xFF371D32)),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "\$${tripsDataSnapshot.data!.guestTotal!.toStringAsFixed(2).replaceAll("-", "")}",
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
                                )
                                    : Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "Trip cost",
                                      style: TextStyle(
                                          fontFamily:
                                          'Urbanist',
                                          fontSize: 16,
                                          color: Color(
                                              0xFF371D32)),
                                    ),
                                    Text(
                                      "\$${tripsDataSnapshot.data!.guestTotal!.toStringAsFixed(2)}",
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
                                  height: 10,
                                ),
                                Divider(),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    //message host//
                                    GestureDetector(
                                      onTap: () {
                                        Thread threadData = new Thread(
                                            id: "1123571113",
                                            userId: tripsDataSnapshot
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
                                          width:
                                          MediaQuery.of(context)
                                              .size
                                              .width /
                                              2.3,
                                          decoration: BoxDecoration(
                                            color: Color(0xfff2f2f2),
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 10,
                                                vertical: 15),
                                            child: Center(
                                                child: Text(
                                                  "Message host",
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(
                                                          0xFF371D32)),
                                                )),
                                          )),
                                    ),
                                    // Call host//
                                    GestureDetector(
                                      onTap: () {
                                        launchUrl(
                                            ('tel://${tripsDataSnapshot.data!.hostProfile!.phoneNumber}'));
                                      },
                                      child: Container(
                                          width:
                                          MediaQuery.of(context)
                                              .size
                                              .width /
                                              2.3,
                                          decoration: BoxDecoration(
                                            color: Color(0xfff2f2f2),
                                            borderRadius:
                                            BorderRadius.all(
                                                Radius.circular(
                                                    8)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 10,
                                                vertical: 15),
                                            child: Center(
                                                child: Text(
                                                  "Call host",
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(
                                                          0xFF371D32)),
                                                )),
                                          )),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                // Current trip contents//
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
                                      var resp =
                                      await getTripByID(
                                          tripDetails.tripID!);
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
                                      Navigator.pushNamed(context,
                                          '/trip_vehicle_ownership',
                                          arguments: ownerShipId);
                                    },
                                    child: _vehicleDocs(
                                        "Vehicle Ownership", 0))
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 5,
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
                                    ? _vehicleDocs(
                                    "Insurance (Pink Slip)", 1)
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
                                  height: 5,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? _vehicleDocs(
                                    "Incident Info Card", 2)
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 5.0,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? Divider()
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? SizedBox(
                                  height: 15.0,
                                )
                                    : new Container(),
                                tripsTypeSnapshot.data == 'Current'
                                    ? Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                                  children: <Widget>[
                                    // call insurance//
                                    GestureDetector(
                                      onTap: () {
                                        launchUrl(
                                            ('tel://${insuranceRoadSideNumbers!.insuranceAndRoadSideAssistNumbers!.insuranceCallNumber}'));
                                      },
                                      child: Container(
                                          width: MediaQuery.of(
                                              context)
                                              .size
                                              .width /
                                              2.3,
                                          decoration:
                                          BoxDecoration(
                                            color: Color(
                                                0xfff2f2f2),
                                            borderRadius:
                                            BorderRadius
                                                .all(Radius
                                                .circular(
                                                8)),
                                          ),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                5,
                                                vertical:
                                                15),
                                            child: Center(
                                                child: Text(
                                                  "Call insurance",
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(
                                                          0xFF371D32)),
                                                )),
                                          )),
                                    ),

                                    //call roadSide Assist//
                                    GestureDetector(
                                      onTap: () {
                                        launchUrl(
                                            ('tel://${insuranceRoadSideNumbers!.insuranceAndRoadSideAssistNumbers!.roadSideAssistNumber}'));
                                        ;
                                      },
                                      child: Container(
                                          width: MediaQuery.of(
                                              context)
                                              .size
                                              .width /
                                              2.3,
                                          decoration:
                                          BoxDecoration(
                                            color: Color(
                                                0xfff2f2f2),
                                            borderRadius:
                                            BorderRadius
                                                .all(Radius
                                                .circular(
                                                8)),
                                          ),
                                          child: Padding(
                                            padding:
                                            const EdgeInsets
                                                .symmetric(
                                                horizontal:
                                                5,
                                                vertical:
                                                15),
                                            child: Center(
                                                child: Text(
                                                  "Call roadside assist",
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize:
                                                      deviceWidth *
                                                          0.035,
                                                      color: Color(
                                                          0xFF371D32)),
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
                                            .data!
                                            .car!
                                            .preference!
                                            .isSuitableForPets !=
                                            null &&
                                            tripsDataSnapshot
                                                .data!
                                                .car!
                                                .preference!
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
                                            .data!
                                            .car!
                                            .preference!
                                            .isSmokingAllowed !=
                                            null &&
                                            tripsDataSnapshot
                                                .data!
                                                .car!
                                                .preference!
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
                                                      .data!
                                                      .car!
                                                      .preference!
                                                      .dailyMileageAllowance ==
                                                      'Limited'
                                                      ? AutoSizeText(
                                                    '${tripsDataSnapshot.data!.car!.preference!.limit} km allowed daily, extra mileage is ${tripsDataSnapshot.data!.car!.pricing!.rentalPricing!.perExtraKMOverLimit!.toStringAsFixed(2)}/km',
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color: Color(0xFF353B50)),
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
                                              // tripsDataSnapshot.data!.car!.features.fuelType != null

                                              tripsDataSnapshot
                                                  .data!
                                                  .car!
                                                  .features!
                                                  .fuelType !=
                                                  null
                                                  ? 'Refuel with ${tripsDataSnapshot.data!.car!.features!.fuelType == '91-94_PREMIUM' ? 'Premium' : 
                                              tripsDataSnapshot.data!.car!.features!.fuelType == '91-94 premium' ? 'Premium' : 
                                              tripsDataSnapshot.data!.car!.features!.fuelType == '87_REGULAR' ? 'Regular' :
                                              tripsDataSnapshot.data!.car!.features!.fuelType == '87 regular' ? 'Regular' : 
                                              tripsDataSnapshot.data!.car!.features!.fuelType == 'electric' ? 'Electric' :
                                              tripsDataSnapshot.data!.car!.features!.fuelType == 'ELECTRIC' ? 'Electric' : 
                                              tripsDataSnapshot.data!.car!.features!.fuelType == 'diesel' ? 'Diesel' : 
                                              tripsDataSnapshot.data!.car!.features!.fuelType == 'DIESEL' ? 'Diesel' : 
                                              tripsDataSnapshot.data!.car!.features!.fuelType} only'
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
                                          children: <Widget>[
                                            Image.asset(
                                                'icons/Cleanliness-2.png'),
                                            SizedBox(
                                              width: 6.0,
                                            ),
                                            Text(
                                              'Return in the same state of cleanliness',
                                              style: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(
                                                      0xFF353B50)),
                                            ),
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
                                            'Cancel your trip for FREE until ${DateFormat("EEE MMM dd, yyyy hh:00 a").format(tripsDataSnapshot.data!.freeCancelBeforeDateTime!)}',
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
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
                                SizedBox(
                                  height: 30,
                                ),
                                tripsTypeSnapshot.data == 'Upcoming'  && tripsRentalBloc.checkCancelButtonVisibility(tripsDataSnapshot.data!)
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
                                                        8.0)),

                                              ),
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
                                    'Upcoming' &&
                                    tripsDataSnapshot
                                        .data!.hostUserID !=
                                        tripsDataSnapshot
                                            .data!.userID
                                    ? tripsRentalBloc
                                    .checkButtonVisibility(
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
                                                  '/start_trip_ui',
                                                  arguments:
                                                  tripsDataSnapshot
                                                      .data,
                                                );
                                              },
                                              child: Text(
                                                'Inspect the vehicle and start the trip',
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
                                    : Container()
                                    : new Container(),
                                // End trip button
                                tripsTypeSnapshot.data == 'Current'
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
                                                  0xffFF8F68),
                                              padding:
                                              EdgeInsets
                                                  .all(
                                                  16.0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      8.0)),),
                                              onPressed:
                                                  () async {
                                                Navigator
                                                    .pushNamed(
                                                  context,
                                                  '/end_trip_ui',
//                                              '/end_trip',
                                                  arguments:{
                                                    'TRIP_DATA':tripsDataSnapshot
                                                        .data,
                                                  }

                                                );
                                              },
                                              child: Text(
                                                tripDetails.tripType ==
                                                    'Swap'
                                                    ? 'End trip'
                                                    : 'End trip now',
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

                                tripsTypeSnapshot.data == 'Past' &&  tripDetails.tripType != 'Swap'
                                    ? Padding(
                                  padding: const EdgeInsets.all(
                                      8.0),
                                  child: Row(
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
                                                elevation: 0.0,
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
                                                  String?
                                                  profileID =
                                                  await storage
                                                      .read(
                                                      key: 'profile_id');

                                                  if (profileID !=
                                                      null) {
                                                    // Card null check
                                                    _bookingInfo[
                                                    "route"] =
                                                    '/trips_rental_details_ui';
                                                    _bookingInfo[
                                                    'calendarID'] =
                                                        tripsDataSnapshot
                                                            .data!
                                                            .car!
                                                            .calendarID!;
                                                    _bookingInfo[
                                                    'carID'] =
                                                        tripsDataSnapshot
                                                            .data!
                                                            .carID!;
                                                    _bookingInfo[
                                                    'userID'] =
                                                        tripsDataSnapshot
                                                            .data!
                                                            .userID!;
                                                    _bookingInfo[
                                                    'location'] =
                                                        tripsDataSnapshot
                                                            .data!
                                                            .car!
                                                            .about!
                                                            .location!
                                                            .address!;
                                                    _bookingInfo[
                                                    'locAddress'] =
                                                        tripsDataSnapshot
                                                            .data!
                                                            .car!
                                                            .about!
                                                            .location!
                                                            .address!;
                                                    _bookingInfo['locLat'] = tripsDataSnapshot
                                                        .data!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .latLng!
                                                        .latitude!;
                                                    _bookingInfo['locLong'] = tripsDataSnapshot
                                                        .data!
                                                        .car!
                                                        .about!
                                                        .location!
                                                        .latLng!
                                                        .longitude!;
                                                    _bookingInfo['customDeliveryEnable'] = tripsDataSnapshot
                                                        .data!
                                                        .car!
                                                        .pricing!
                                                        .rentalPricing!
                                                        .enableCustomDelivery!;

                                                    handleShowAddCardModal();
                                                  }
                                                },
                                                child: Text(
                                                  'Book again',
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
                                  ),
                                )
                                    : Container(),
                                // Reviw button
                                tripsTypeSnapshot.data == 'Past' && tripDetails.tripType != 'Swap'
                                    ? tripsDataSnapshot.data!.carRatingReviewAdded == false || tripsDataSnapshot.data!.hostRatingReviewAdded == false
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
                                                      8.0)),),
                                              onPressed: () =>
                                                  openReviewModal(
                                                      context,
                                                      tripsDataSnapshot),
                                              child: Text(
                                                'Leave a review',
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
                                    : new Container():Container(),
                                // //Swap rating //
                                //     tripsTypeSnapshot.data == 'Past' && tripDetails.tripType == 'Swap'
                                //     ? Column(
                                //   children: [
                                //     SizedBox(height: 16),
                                //     Divider(),
                                //     Row(
                                //       children: <Widget>[
                                //         Expanded(
                                //           child: Column(
                                //             children: <
                                //                 Widget>[
                                //               SizedBox(
                                //                   width: double
                                //                       .maxFinite,
                                //                   child:
                                //                   Container(
                                //                     margin:
                                //                     EdgeInsets.all(8.0),
                                //                     child:
                                //                     ElevatedButton(
                                //                         style: ElevatedButton.styleFrom(
                                //                       elevation:
                                //                       0.0,
                                //                       color:
                                //                       Color(0xFFFF8F62),
                                //                       padding:
                                //                       EdgeInsets.all(16.0),
                                //                       shape:
                                //                       RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                //                       onPressed:
                                //                           () {
                                //                         // handleShowReimbursementModal(tripDetails.tripID);
                                //                             Navigator.pushNamed(context,'/reimbursement',arguments: tripDetails.swapData.otherTripID);
                                //
                                //                           },
                                //                       child:
                                //                       Text(
                                //                         'Request reimbursement',
                                //                         style: TextStyle(
                                //                             fontFamily: 'Urbanist',
                                //                             fontSize: 18,
                                //                             color: Colors.white),
                                //                       ),
                                //                     ),
                                //                   )),
                                //             ],
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //   ],
                                // ) : Container(),
                       ///swap reimbursement///
                                StreamBuilder<Trips>(
                                    stream:
                                    tripsRentalBloc.swapTripsData,
                                    builder: (context,
                                        swapTripDataSnapshot) {
                                      return swapTripDataSnapshot.hasData
                                          ? Column(
                                        children: [
                                          tripsTypeSnapshot.data == 'Past' &&
                                              tripDetails.tripType == 'Swap' &&
                                              swapTripDataSnapshot.data!.tripStatus == "Ended"
                                              ? Column(
                                            children: [SizedBox(height: 16),
                                              Divider(),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child:
                                                    Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                            width: double.maxFinite,
                                                            child: Container(
                                                              margin: EdgeInsets.all(8.0),
                                                              child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                                elevation: 0.0,
                                                                backgroundColor: Color(0xFFFF8F62),
                                                                padding: EdgeInsets.all(16.0),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),),
                                                                onPressed: () {
                                                                  Navigator.pushNamed(
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
                                                                  style: TextStyle(fontFamily: 'Urbanist', fontSize: 18, color: Colors.white),
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
                                          tripsTypeSnapshot.data == 'Past' && tripDetails.tripType == 'Swap' &&
                                              swapTripDataSnapshot.data!.tripStatus == "Completed"
                                              ? Column(
                                            children: [
                                              SizedBox(height: 16),
                                              Divider(),
                                              tripsTypeSnapshot.data == 'Past' && tripDetails.tripType == 'Swap' &&
                                                  (tripsDataSnapshot.data!.carRatingReviewAdded == false ||
                                                      tripsDataSnapshot.data!.hostRatingReviewAdded == false ||
                                                      swapTripDataSnapshot.data!.guestRatingReviewAdded == false)
                                                  ? Row(
                                                children: [
                                                  Expanded(
                                                    child: Column(
                                                      children: [
                                                        SizedBox(
                                                          width: double.maxFinite,
                                                          child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                            elevation: 0.0,
                                                            backgroundColor: Color(0xffF2F2F2),
                                                            padding: EdgeInsets.all(16.0),
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),),
                                                            onPressed: () => openSwapReviewModal(context, tripsDataSnapshot, swapTripDataSnapshot),
                                                            child: Text(
                                                              'Leave a review',
                                                              style: TextStyle(fontFamily: 'Urbanist', fontSize: 16, color: Color(0xFF371D32)),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                                  : new Container(),
                                              swapTripDataSnapshot.data!.reimbursementStatus=='Unapproved'?
                                              Row(
                                                children: <
                                                    Widget>[
                                                  Expanded(
                                                    child:
                                                    Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                            width: double.maxFinite,
                                                            child: Container(
                                                              margin: EdgeInsets.all(8.0),
                                                              child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                                elevation: 0.0,
                                                                backgroundColor: Color(0xFFFF8F62),
                                                                padding: EdgeInsets.all(16.0),
                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),),
                                                                onPressed: () {
                                                                  // handleShowReimbursementModal(tripDetails.tripID);
                                                                  Navigator.pushNamed(context,'/reimbursement',arguments: tripDetails.swapData!.otherTripID);
                                                                },
                                                                child: Text(
                                                                  'Request reimbursement',
                                                                  style: TextStyle(fontFamily: 'Urbanist', fontSize: 18, color: Colors.white),
                                                                ),
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ):Container(),
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
            height: MediaQuery.of(context).size.height,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 345,
                  maxHeight: MediaQuery.of(context).size.height - 10),
              child: Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
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
                                          allowHalfRating: true,
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
                                      borderRadius: BorderRadius.circular(8.0)),),
                                  onPressed: () async {
                                    await endTripRentalBloc.rateThisTripAndHost(tripsDataSnapshot.data!);

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
//                    child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                       // To make the card compact
//                      children: <Widget>[
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.start,
//                          children: <Widget>[
//                            GestureDetector(
//                              onTap: () {
//                                Navigator.pop(context);
//                              },
//                              child: Icon(
//                                Icons.keyboard_backspace,
//                                color: Colors.orange,
//                              ),
//                            ),
//                            SizedBox(width: 80.0),
//                            Text(
//                              "Leave a review",
//                              textAlign: TextAlign.center,
//                              style: TextStyle(
//                                  fontFamily: 'Urbanist',
//                                  fontSize: 16,
//                                  color: Color(0xFF371D32)),
//                            ),
//                          ],
//                        ),
//                        SizedBox(height: 15.0),
//                        //Rating car//
//                        tripsDataSnapshot.data!.carRatingReviewAdded == false
//                            ? StreamBuilder<RateTripCarRequest>(
//                                stream: endTripRentalBloc.tripRateCar,
//                                builder: (context, tripRateCarSnapshot) {
//                                  return tripRateCarSnapshot.hasData &&
//                                          tripRateCarSnapshot.data != null
//                                      ? Container(
//                                          height: 100.0,
//                                          decoration: BoxDecoration(
//                                            color: Colors.grey[200],
//                                            borderRadius: BorderRadius.circular(5),
//                                          ),
//                                          child: Column(
//                                            crossAxisAlignment:
//                                                CrossAxisAlignment.start,
//                                            children: <Widget>[
//                                              Row(
//                                                mainAxisAlignment:
//                                                    MainAxisAlignment.spaceBetween,
//                                                children: <Widget>[
//                                                  Padding(
//                                                    padding: const EdgeInsets.only(
//                                                        left: 16.0,
//                                                        right: 16.0,
//                                                        top: 16),
//                                                    child: Text(
//                                                      "Rate the car",
//                                                      textAlign: TextAlign.center,
//                                                      style: TextStyle(
//                                                          fontFamily: 'Urbanist',
//                                                          fontSize: 16,
//                                                          color: Color(0xFF371D32)),
//                                                    ),
//                                                  ),
//                                                  Padding(
//                                                    padding: const EdgeInsets.only(
//                                                        left: 8.0,
//                                                        right: 8.0,
//                                                        top: 10),
//                                                    child: SmoothStarRating(
//                                                        allowHalfRating: false,
//                                                        onRated: (v) {
//                                                          tripRateCarSnapshot.data
//                                                              .rateCar = v.toString();
//                                                          endTripRentalBloc
//                                                              .changedTripRateCar
//                                                              .call(
//                                                                  tripRateCarSnapshot
//                                                                      .data);
//                                                        },
//                                                        starCount: 5,
//                                                        rating: double.parse(
//                                                            tripRateCarSnapshot
//                                                                .data!.rateCar),
//                                                        size: 20.0,
//                                                        isReadOnly: false,
//                                                        // fullRatedIconData: Icons.blur_off,
//                                                        // halfRatedIconData: Icons.blur_on,
//                                                        color: Color(0xffFF8F68),
//                                                        borderColor:
//                                                            Color(0xffFF8F68),
//                                                        spacing: 0.0),
//                                                  ),
//                                                ],
//                                              ),
//                                              Padding(
//                                                padding: const EdgeInsets.only(
//                                                    left: 16.0, right: 16.0),
//                                                child: TextField(
//                                                  onChanged: (review) {
//                                                    tripRateCarSnapshot.data
//                                                            .reviewCarDescription =
//                                                        review;
//                                                    endTripRentalBloc
//                                                        .changedTripRateCar
//                                                        .call(
//                                                            tripRateCarSnapshot.data);
//                                                  },
//                                                  decoration: InputDecoration(
//                                                      hintText:
//                                                          'Write a car review[optional]',
//                                                      hintStyle: TextStyle(
//                                                          fontFamily:
//                                                              'Urbanist',
//                                                          fontSize: 14,
//                                                          color: Color(0xFF686868),
//                                                          fontStyle:
//                                                              FontStyle.italic),
//                                                      border: InputBorder.none),
//                                                ),
//                                              ),
//                                            ],
//                                          ),
//                                        )
//                                      : Container();
//                                })
//                            : Container(),
//                        SizedBox(height: 15.0),
//
//                        //Rate host//
//                        tripsDataSnapshot.data!.hostRatingReviewAdded == false
//                            ? StreamBuilder<RateTripHostRequest>(
//                                stream: endTripRentalBloc.tripRateHost,
//                                builder: (context, tripRateHostSnapshot) {
//                                  return tripRateHostSnapshot.hasData &&
//                                          tripRateHostSnapshot.data != null
//                                      ? Container(
//                                          height: 100.0,
//                                          decoration: BoxDecoration(
//                                            color: Colors.grey[200],
//                                            borderRadius: BorderRadius.circular(5),
//                                          ),
//                                          child: Column(
//                                            crossAxisAlignment:
//                                                CrossAxisAlignment.start,
//                                            children: <Widget>[
//                                              Row(
//                                                mainAxisAlignment:
//                                                    MainAxisAlignment.spaceBetween,
//                                                children: <Widget>[
//                                                  Padding(
//                                                    padding: const EdgeInsets.only(
//                                                        left: 16.0,
//                                                        right: 16.0,
//                                                        top: 16),
//                                                    child: Text(
//                                                      "Rate the host",
//                                                      textAlign: TextAlign.center,
//                                                      style: TextStyle(
//                                                          fontFamily: 'Urbanist',
//                                                          fontSize: 16,
//                                                          color: Color(0xFF371D32)),
//                                                    ),
//                                                  ),
//                                                  Padding(
//                                                    padding: const EdgeInsets.only(
//                                                        left: 8.0,
//                                                        right: 8.0,
//                                                        top: 10),
//                                                    child: SmoothStarRating(
//                                                        allowHalfRating: false,
//                                                        onRated: (v) {
//                                                          tripRateHostSnapshot
//                                                                  .data!.rateHost =
//                                                              v.toString();
//                                                          endTripRentalBloc
//                                                              .changedTripRateHost
//                                                              .call(
//                                                                  tripRateHostSnapshot
//                                                                      .data);
//                                                        },
//                                                        starCount: 5,
//                                                        rating: double.parse(
//                                                            tripRateHostSnapshot
//                                                                .data!.rateHost),
//                                                        size: 20.0,
//                                                        isReadOnly: false,
//                                                        // fullRatedIconData: Icons.blur_off,
//                                                        // halfRatedIconData: Icons.blur_on,
//                                                        color: Color(0xffFF8F68),
//                                                        borderColor:
//                                                            Color(0xffFF8F68),
//                                                        spacing: 0.0),
//                                                  ),
//                                                ],
//                                              ),
//                                              Padding(
//                                                padding: const EdgeInsets.only(
//                                                    left: 16.0, right: 16.0),
//                                                child: TextField(
//                                                  onChanged: (hostReviews) {
//                                                    tripRateHostSnapshot.data
//                                                            .reviewHostDescription =
//                                                        hostReviews;
//                                                    endTripRentalBloc
//                                                        .changedTripRateHost
//                                                        .call(tripRateHostSnapshot
//                                                            .data);
//                                                  },
//                                                  decoration: InputDecoration(
//                                                      hintText:
//                                                          'Write a host review[optional]',
//                                                      hintStyle: TextStyle(
//                                                          fontFamily:
//                                                              'Urbanist',
//                                                          fontSize: 14,
//                                                          color: Color(0xFF686868),
//                                                          fontStyle:
//                                                              FontStyle.italic),
//                                                      border: InputBorder.none),
//                                                ),
//                                              ),
//                                            ],
//                                          ),
//                                        )
//                                      : Container();
//                                })
//                            : Container(),
//                        SizedBox(height: 20.0),
//                        Row(
//                          children: [
//                            Expanded(
//                              child: Column(
//                                children: [
//                                  SizedBox(
//                                    width: double.maxFinite,
//                                    child: ElevatedButton(
//                                                         style: ElevatedButton.styleFrom(
//                                      elevation: 0.0,
//                                      color: Color(0xffFF8F68),
//                                      padding: EdgeInsets.all(16.0),
//                                      shape: RoundedRectangleBorder(
//                                          borderRadius: BorderRadius.circular(8.0)),
//                                      onPressed: () async {
//                                        await endTripRentalBloc.rateThisTripAndHost(
//                                            tripsDataSnapshot.data);
//                                        Navigator.pop(context);
//                                      },
//                                      child: Text(
//                                        'Done',
//                                        style: TextStyle(
//                                            fontFamily: 'Urbanist',
//                                            fontSize: 18,
//                                            color: Colors.white),
//                                      ),
//                                    ),
//                                  ),
//                                ],
//                              ),
//                            ),
//                          ],
//                        ),
//                      ],
//                    ),
                ),
              ),
            ),
          );
        });
  }
  void openSwapReviewModal(context, AsyncSnapshot<Trips> tripsDataSnapshot, AsyncSnapshot<Trips> swapTripDataSnapshot,) {
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
            height: MediaQuery.of(context).size.height,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: 345,
                  maxHeight: MediaQuery.of(context).size.height - 10),
              child: Container(
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
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
                                                            .rateCar = v.toString();
                                                        endTripRentalBloc
                                                            .changedTripRateCar
                                                            .call(
                                                            tripRateCarSnapshot.data!);
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
                                                onChanged: (review) {
                                                  tripRateCarSnapshot
                                                      .data!
                                                      .reviewCarDescription =
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
                                                      true,
                                                      onRatingChanged:
                                                          (v) {
                                                        tripRateHostSnapshot
                                                            .data!
                                                            .rateHost = v.toString();
                                                        print(v
                                                            .toString());
                                                        endTripRentalBloc
                                                            .changedTripRateHost
                                                            .call(
                                                            tripRateHostSnapshot.data!);
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
                                                            .rateGuest = v.toString();
                                                        endTripRentalBloc
                                                            .changedRateTripGuest
                                                            .call(
                                                            rateTripGuestSnapshot.data!);
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
                                                        style: ElevatedButton.styleFrom(
                                                    elevation: 0.0,
                                                    backgroundColor: Color(0xffFF8F68),
                                                    padding:
                                                    EdgeInsets.all(16.0),
                                                    shape:
                                                    RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius
                                                            .circular(
                                                            8.0)),),
                                                    onPressed: tripRateCarSnapshot.hasData &&
                                                        tripRateHostSnapshot
                                                            .hasData &&
                                                        rateTripGuestSnapshot
                                                            .hasData &&
                                                        ((double.tryParse(
                                                            tripRateCarSnapshot
                                                                .data!.rateCar!) !=
                                                            0 &&
                                                            tripsDataSnapshot
                                                                .data!
                                                                .carRatingReviewAdded ==
                                                                false) ||
                                                            (double.tryParse(tripRateHostSnapshot
                                                                .data!
                                                                .rateHost!) !=
                                                                0 &&
                                                                tripsDataSnapshot
                                                                    .data!
                                                                    .hostRatingReviewAdded ==
                                                                    false) ||
                                                            (double.tryParse(rateTripGuestSnapshot
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
    return Row(
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
        InkWell(
          onTap: () {
            if (type == 0) {
            } else if (type == 1) {
              print(insuranceDocumentID);
              NavigationService().push(
                MaterialPageRoute(
                  builder: (context) => PdfView(
                    title: "Insurance",
                    id: insuranceDocumentID,
                  ),
                ),
              );
            } else if (type == 2) {
              print(infoCardDocumentID);
              NavigationService().push(
                MaterialPageRoute(
                  builder: (context) => PdfView(
                    title: "Info Card",
                    id: infoCardDocumentID,
                  ),
                ),
              );
            } else {}
          },
          child: Row(
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
        ),
      ],
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
