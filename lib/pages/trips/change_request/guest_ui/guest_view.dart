import 'dart:async';
import 'dart:convert' show Utf8Decoder, json;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/change_request/guest_ui/guest_presenter.dart';
import 'package:ridealike/pages/trips/change_request/guest_ui/widgets/change_request_current_duration.dart';
import 'package:ridealike/pages/trips/change_request/guest_ui/widgets/change_request_current_trip.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_by_user_ids_response.dart';
import 'package:ridealike/pages/trips/response_model/rent_agree_carinfo_response.dart';
import 'package:ridealike/pages/trips/response_model/swap_agree_carinfo_response.dart';

import 'guest_interface.dart';
import 'widgets/change_request_trip_location.dart';
import 'widgets/change_request_upcoming_duration.dart';

class GuestView extends StatefulWidget {
  final DateTime currentEndDateTime;
  final DateTime currentStartDateTime;
  final currentLocation;
  final String carId;
  final bool delivery;
  final bool customDelivery;
  final String tripId;
  final String tripType;

  const GuestView(
      {Key? key,
      required this.currentEndDateTime,
      this.currentLocation,
      required this.carId,
      required this.tripId,
      required this.delivery,
      required this.customDelivery,
      required this.currentStartDateTime,
      required this.tripType})
      : super(key: key);

  @override
  State<GuestView> createState() => _GuestViewState();
}

class _GuestViewState extends State<GuestView> implements GuestInterface {
  final _messengerKey = GlobalKey<ScaffoldState>();
 GuestPresenter? _presenter;
 DateTime? updatedStartDateTime;
  DateTime? updatedEndDateTime;
  bool _loadingData = false;
  double? _guestPrice;
  var _errorMessage;
  var _errorTitle;
  bool _isSubmitStarted = false;
  bool _isSubmitSuccess = false;
  StateSetter? _setState;
  double? distanceInkm;
  final storage = new FlutterSecureStorage();
  Trips? tripResponse;
  Trips? swapTripResponse;

  Future<RestApi.Resp> getTripByID(String tripID) async {
    var getTripByIDCompleter = Completer<RestApi.Resp>();
    RestApi.callAPI(getTripByIDUrl, json.encode({"TripID": tripID}))
        .then((resp) {
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

  Future<Resp> getRentAgreementId(rentAgreementID, userId) async {
    var rentAgreementIdCompleter = Completer<Resp>();
    callAPI(getRentAgreementUrl,
            json.encode({"RentAgreementID": rentAgreementID, "UserID": userId}))
        .then((resp) {
      rentAgreementIdCompleter.complete(resp);
    });
    return rentAgreementIdCompleter.future;
  }

  Future<Resp> getSwapAgreementId(swapAgreementID, userId) async {
    var rentAgreementIdCompleter = Completer<Resp>();
    callAPI(getSwapArgeementTermsUrl,
            json.encode({"SwapAgreementID": swapAgreementID, "UserID": userId}))
        .then((resp) {
      rentAgreementIdCompleter.complete(resp);
    });
    return rentAgreementIdCompleter.future;
  }

  Future<void> getTripCarProfileInfo(String tripID) async {
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
      print("*************************88-================");
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
    }
    print("before route************");
    Navigator.pushNamed(context, '/trips_rental_details_ui', arguments: {
      'tripType': tripStatusPeriod,
      'trip': tripResponse,
      'backPressPop': true
    });
    print("after route************");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _presenter = GuestPresenter(this);
    });
  }

  void updatedTime(Map<String, DateTime> val) {
    setState(() {
      if(widget.tripType == "Current"){
        updatedEndDateTime = val["endDate"]!;
      } else{
        updatedStartDateTime = val['startDate']!;
        updatedEndDateTime = val["endDate"]!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isSubmitSuccess
        ? Center(
            child: SizedBox(
            child: CircularProgressIndicator(),
            height: 40,
            width: 40,
          ))
        : Scaffold(
            key: _messengerKey,
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                "Change Request For ${widget.tripType} Trip",
                overflow: TextOverflow.visible,
                style: TextStyle(fontSize: 14,fontFamily: 'Urbanist'),
              ),
              elevation: 0.0,
              leading: IconButton(
                  icon: new Icon(Icons.arrow_back, color: Color(0xFFFF8F62)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              actions: [
                IconButton(
                  icon: new Icon(Icons.info_outline, color: Color(0xFFFF8F62)),
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor: Colors.white,
                          content: Text(
                            "Your Host must approve the requested changes before the"
                            "y are valid. We recommend that you contact your Hos"
                            "t via phone/SMS/in-app messaging first to discuss y"
                            "our requested change before submitting it, to minim"
                            "ize back and forth requests and make approvals quic"
                            "ker. Only requests approved by the Host by the Requ"
                            "est Change process are valid",
                            softWrap: true, style: TextStyle(fontSize: 14,fontFamily: 'Urbanist'),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Color(0xffFF8F68))),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Got it" ,style:
                              TextStyle(fontSize: 14,fontFamily: 'Urbanist',
                                  color:Colors.white),),
                            )
                          ],
                        );
                      }),
                )
              ],
            ),
            body: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [


                    Text(
                      "Current Pickup Location",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xFF353B50)),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: EdgeInsets.all(12.0),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "${widget.currentLocation.formattedAddress}",
                              style: TextStyle(fontSize: 16,fontFamily: 'Urbanist'),
                            ),
                          ),
                        ],
                      ),
                    ), SizedBox(
                      height: 20,
                    ),
                    widget.customDelivery
                        ? Text(
                      "Requested Pickup Location",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xFF353B50)),
                    )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: EdgeInsets.all(12.0),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "${widget.currentLocation.formattedAddress}",
                              style: TextStyle(fontSize: 16,fontFamily: 'Urbanist'),
                            ),

                          ),
                          // Icon(Icons.arrow_forward_ios)
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Delivery available within 50 km. (fees applicable)',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      "Current Return Location",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xFF353B50)),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: EdgeInsets.all(12.0),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "${widget.currentLocation.formattedAddress}",
                              style: TextStyle(fontSize: 16,fontFamily: 'Urbanist'),
                            ),
                          ),
                        ],
                      ),
                    ), SizedBox(
                      height: 20,
                    ),
                    widget.customDelivery
                        ? Text(
                      "Requested Return Location",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xFF353B50)),
                    )
                        : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    // Container(
                    //   decoration: BoxDecoration(
                    //       color: Color(0xFFF2F2F2),
                    //       borderRadius: BorderRadius.circular(8.0)),
                    //   padding: EdgeInsets.all(12.0),
                    //   width: MediaQuery.of(context).size.width,
                    //   child: Row(
                    //     children: [
                    //       Icon(Icons.location_on),
                    //       SizedBox(width: 16),
                    //       Expanded(
                    //         child: Text(
                    //           "${widget.currentLocation.formattedAddress}",
                    //           style: TextStyle(fontSize: 16,fontFamily: 'Urbanist',fontWeight: FontWeight.bold),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  widget.customDelivery && widget.tripType == "Current"
                      ? GestureDetector(
                    onTap: () {
                      showLocationModal();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.all(12.0),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              bookingInfo == null
                                  ? "${widget.currentLocation.formattedAddress}"
                                  : bookingInfo['locAddress'],
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      : GestureDetector(
                    onDoubleTap: () {},
                    onTap: () {
                      showLocationModal();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0xFFF2F2F2),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.all(12.0),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              bookingInfo == null
                                  ? "${widget.currentLocation.formattedAddress}"
                                  : bookingInfo['locAddress'],
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Urbanist',

                              ),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios)
                        ],
                      ),
                    ),
                  ),

                  // : Container(),
                    SizedBox(
                      height: 8,
                    ),
                    Text(
                      'Delivery available within 50 km. (fees applicable)',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ), SizedBox(
                      height: 20,
                    ),
                    widget.tripType == "Upcoming"
                        ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            "Current Start Date & Time",
                            style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFF353B50)),
                          ),
                          SizedBox(
                            height: 8.0,
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(8.0)),
                            padding: EdgeInsets.all(12.0),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 16),
                                Text(
                                  "${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(widget.currentStartDateTime.toLocal())}",
                                  style: TextStyle(fontSize: 16, fontFamily: 'Urbanist',),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    )
                        : SizedBox(),

                    Text(
                      "Current End Date & Time",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xFF353B50)),
                    ),
                    SizedBox(
                      height: 8.0,
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8.0)),
                      padding: EdgeInsets.all(12.0),
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 16),
                          Text(
                            "${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(widget.currentEndDateTime.toLocal())}",
                            style: TextStyle(fontSize: 16, fontFamily: 'Urbanist',),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(

                      children: [
                        Text(
                          "Requested End Date & Time",
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              color: Color(0xFF353B50)),
                        ),

                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    GestureDetector(
                      onTap: () {
                        showTripDurationModal();
                      },
                      child: updatedStartDateTime == null && updatedEndDateTime == null
                          ?
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: EdgeInsets.all(12.0),
                            width: MediaQuery.of(context).size.width,
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    "Pick Date & Time",
                                    style: TextStyle(fontSize: 16, fontFamily: 'Urbanist',),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Spacer(),
                                Icon(Icons.arrow_forward_ios)
                              ],
                            ),
                          )

                          : Container(
                        decoration: BoxDecoration(
                          color: Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: EdgeInsets.all(12.0),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: [
                            if (widget.tripType == "Upcoming")
                              Row(
                                children: [
                                  Icon(Icons.calendar_today),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      "Pick Up Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(widget.currentStartDateTime!.toLocal() ?? widget.currentStartDateTime.toLocal())}",
                                      style: TextStyle(fontSize: 16,fontFamily: 'Urbanist',),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,

                                    ),
                                  ),
                                ],
                              ),
                            if (widget.tripType == "Upcoming") SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Return Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(updatedEndDateTime!.toLocal() ?? widget.currentEndDateTime.toLocal())}",
                                        style: TextStyle(fontSize: 16,fontFamily: 'Urbanist',),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Icon(Icons.arrow_forward_ios)
                                    ],
                                  ),
                                ),
                              ],
                            )

                          ],
                        ),
                      ),
                    ),


                    SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      height: 20,
                    ),

                    // SizedBox(
                    //   height: 100,
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ButtonTheme(
                          height: 45,
                          minWidth: MediaQuery.of(context).size.width / 2.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: ElevatedButton(
                              onPressed: _isSubmitSuccess
                                  ? null
                                  : updatedEndDateTime == null &&
                                  bookingInfo == null
                                  ? null
                                  : () async {
                                if (bookingInfo != null) {
                                  distanceInkm =
                                      _presenter!.calculateDistance(
                                          bookingInfo['defaultLat'],
                                          bookingInfo['defaultLon'],
                                          bookingInfo['locLat'],
                                          bookingInfo['locLong']);
                                }
                                await _presenter
                                !.getChangeRequestCalculation({
                                  "EndDateTime":
                                  updatedEndDateTime != null
                                      ? updatedEndDateTime
                                  !.toIso8601String()
                                      : widget.currentEndDateTime
                                      .toIso8601String(),
                                  "ReturnLocation": {
                                    // "Address" :
                                    "FormattedAddress":
                                    "${bookingInfo != null ? bookingInfo['locAddress'] : widget.currentLocation.address}"
                                  },
                                  "StartDateTime":
                                  updatedStartDateTime != null
                                      ? updatedStartDateTime
                                  !.toIso8601String()
                                      : widget.currentStartDateTime
                                      .toIso8601String(),
                                  "TripID": "${widget.tripId}",
                                  "force": false
                                });

                                _errorMessage == null
                                    ? calculateTripPrice()
                                    : tripDurationValidation();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isSubmitSuccess
                                    ? Colors.grey
                                    : updatedEndDateTime != null ||
                                    // updatedStartDateTime != null ||
                                    bookingInfo != null
                                    ? Color(0xffFF8F68)
                                    : Colors.grey,
                              ),

                              child:
                              // _loadingData
                              //     ? Center(
                              //         child: CircularProgressIndicator(
                              //           backgroundColor: Colors.grey,
                              //         ),
                              //       )
                              //     :
                              _loadingData
                                  ? CircularProgressIndicator(
                                backgroundColor: Colors.white,
                              )
                                  : Text(
                                "Calculate",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Urbanist',
                                  fontSize: 15,
                                ),
                              ),
                            ),

                          ),
                        ),
                        ButtonTheme(
                          height: 45,
                          minWidth: MediaQuery.of(context).size.width / 2.5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: SizedBox(
                            height: 50,
                            width: MediaQuery.of(context).size.width / 2.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xffFF8F68),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },

                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Urbanist',
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void calculateTripPrice(){
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder:
                (context, newState) {
              _setState = newState;

              return AlertDialog(
                backgroundColor: Colors.white,
                content: Container(
                  height: MediaQuery.of(
                      context)
                      .size
                      .height *
                      .25,
                  child: Column(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Text(
                          "This change request will result in a new charge of \$${_guestPrice!.toStringAsFixed(2)}",style:TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize:
                  16,)),
                      SizedBox(),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment
                            .spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all(Color(0xffFF8F68))),
                            onPressed:
                                () async {
                              await _presenter
                                  !.getChangeRequestSubmit({
                                "EndDateTime": updatedEndDateTime !=
                                    null
                                    ? updatedEndDateTime!.toIso8601String()
                                    : widget.currentEndDateTime.toIso8601String(),
                                "ReturnLocation":
                                {
                                  "Address":
                                  "${bookingInfo != null ? bookingInfo['locAddress'] : widget.currentLocation.address}",
                                  "FormattedAddress":
                                  "${bookingInfo != null ? bookingInfo['locAddress'] : widget.currentLocation.address}",
                                  "LatLng":
                                  {
                                    "Latitude": bookingInfo != null
                                        ? bookingInfo['locLat']
                                        : widget.currentLocation.latLng.latitude,
                                    "Longitude": bookingInfo != null
                                        ? bookingInfo["locLong"]
                                        : widget.currentLocation.latLng.longitude
                                  }
                                },
                                "PickUpLocation":
                                {
                                  "Address":
                                  "${bookingInfo != null ? bookingInfo['locAddress'] : widget.currentLocation.address}",
                                  "FormattedAddress":
                                  "${bookingInfo != null ? bookingInfo['locAddress'] : widget.currentLocation.address}",
                                  "LatLng":
                                  {
                                    "Latitude": bookingInfo != null
                                        ? bookingInfo['locLat']
                                        : widget.currentLocation.latLng.latitude,
                                    "Longitude": bookingInfo != null
                                        ? bookingInfo["locLong"]
                                        : widget.currentLocation.latLng.longitude
                                  }
                                },
                                "StartDateTime": updatedStartDateTime !=
                                    null
                                    ? updatedStartDateTime!.toIso8601String()
                                    : widget.currentStartDateTime.toIso8601String(),
                                "TripID":
                                "${widget.tripId}",
                                "force":
                                true
                              });

                              // _messengerKey
                              //     .currentState!
                              //     .showSnackBar(
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    behavior:
                                    SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(
                                        bottom:
                                        100.0,
                                        right:
                                        8,
                                        left:
                                        8),
                                    duration:
                                    const Duration(seconds: 5),
                                    content:
                                    Text(
                                      _isSubmitSuccess
                                          ? 'Request Sent Successfully !! '
                                          : "Failed Request",
                                      style:
                                      TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor:
                                    Color(0xffFF8F68),
                                  )
                              );

                              Navigator.pop(
                                  context);
                              // Scaffold.of(context).showSnackBar(snackBar);

                              getTripCarProfileInfo(
                                  widget
                                      .tripId);
                            },
                            child: _isSubmitStarted
                                ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.grey,
                                ))
                                : Text("Submit",style:TextStyle(
                              fontFamily: 'Urbanist',color: Colors.white,
                              fontSize:
                              18,fontWeight: FontWeight.w600)),
                          ),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all(Color(0xffFF8F68))),
                            onPressed:
                                () {
                              Navigator.pop(
                                  context);
                            },
                            child: Text(
                                "Cancel",style:TextStyle(color: Colors.white,
                                fontFamily: 'Urbanist',
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        });
  }
  void tripDurationValidation(){
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: Container(
              height:
              MediaQuery.of(context)
                  .size
                  .height *
                  .25,
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                children: [
                  Text(
                    "Warning !!!",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Urbanist',
                        fontSize: 18,
                        fontWeight:
                        FontWeight
                            .bold),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(_errorMessage, style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      ),),
                  Spacer(),
                  ElevatedButton(
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty
                            .all(Color(
                            0xffFF8F68))),
                    onPressed: () {
                      Navigator.pop(
                          context);
                    },
                    child: Text("OK", style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Urbanist',
                        fontSize: 18,
                        fontWeight:
                        FontWeight
                            .bold),),
                  )
                ],
              ),
            ),

            // Text(_errorMessage),
            // actions: [
            //   ElevatedButton(
            //     style: ButtonStyle(
            //         backgroundColor: MaterialStateProperty.all(
            //             Color(0xffFF8F68))),
            //     onPressed: () {
            //       Navigator.pop(context);
            //     },
            //     child: Text("OK"),
            //   )
            // ],
          );
        });
  }
  void showLocationModal(){
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
        return ChangeLocation(
          bookingInfo: {
            'locAddress': widget
                .currentLocation.formattedAddress,
            "defaultAddress": widget
                .currentLocation.formattedAddress,
            "defaultLat": widget
                .currentLocation.latLng.latitude,
            "locLat": widget
                .currentLocation.latLng.latitude,
            "defaultLon": widget
                .currentLocation.latLng.longitude,
            "locLong": widget
                .currentLocation.latLng.longitude,
            'deliveryNeeded': widget.delivery,
            'customDeliveryEnable':
            widget.customDelivery
          },
        );
      },
    ).then((value) => getCustomLoc(value));
  }
  void showTripDurationModal(){
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        print("duration:::${widget.currentEndDateTime}");
        //     bookingInfo['startDate'].toString() +
        //     ":::" +
        //     bookingInfo['endDate'].toString());

        return widget.tripType == "Current"
            ? ChangeRequestCurrentTripDuration(
          bookingInfo: {
             'startDate': widget.currentEndDateTime,
            'endDate': widget.currentEndDateTime,
            'carID': widget.carId
          },
        )
            : ChangeRequestUpcomingTripDuration(
          bookingInfo: {
            'startDate': widget.currentStartDateTime,
            'endDate': widget.currentEndDateTime,
            'carID': widget.carId
          },
        );
      },
    ).then((value) {
      if(value != null){
        updatedTime(value as dynamic);
      }
    });
  }

  var bookingInfo;

  void getCustomLoc(booking) {
    print("bookingInfo$booking");
    setState(() {
      bookingInfo = booking;
    });
  }

  @override
  void onDataLoadFail(error) {
    // TODO: implement onDataLoadFail

    setState(() {
      if (error != null) {
        _errorMessage = error['details'][0]['Error'];
        _errorTitle = error['error'];
      } else {
        _errorMessage = null;
      }
    });
  }

  @override
  void onDataLoadSuccess(double guestPrice) {
    // TODO: implement onDataLoadSuccess
    _guestPrice = guestPrice;
  }

  @override
  void onDataLoadStarted(bool isStarted) {
    // TODO: implement onDataLoadStarted
    setState(() {
      _loadingData = isStarted;
    });
  }

  @override
  void onSubmitStart(bool isStarted) {
    // TODO: implement onSubmit
    _setState!(() {
      _isSubmitStarted = isStarted;
    });
  }

  @override
  void onSubmitSuccess(bool isSuccess) {
    // TODO: implement onSubmitSuccess
    setState(() {
      _isSubmitSuccess = isSuccess;
    });
  }
}
