import 'dart:async';
import 'dart:convert' show Utf8Decoder, json;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_by_user_ids_response.dart';
import 'package:ridealike/pages/trips/response_model/rent_agree_carinfo_response.dart';
import 'package:ridealike/pages/trips/response_model/swap_agree_carinfo_response.dart';

import 'host_interface.dart';
import 'host_presenter.dart';

class HostView extends StatefulWidget {
  final Trips tripData;

  const HostView({Key? key,required this.tripData}) : super(key: key);

  @override
  State<HostView> createState() => _HostViewState();
}

class _HostViewState extends State<HostView> implements HostInterface {
  bool _loading = true;
  var response;
  bool _isAccepted =false;
  bool _isRejected = false;
  HostPresenter? _presenter;
  final _messengerKey = GlobalKey<ScaffoldState>();

  final storage = new FlutterSecureStorage();
 Trips? tripResponse;
  Trips? swapTripResponse;


  Future<RestApi.Resp> getTripByID(String tripID) async {
    var getTripByIDCompleter = Completer<RestApi.Resp>();
    RestApi.callAPI(getTripByIDUrl, json.encode({"TripID": tripID})).then((resp) {
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


  Future<Resp>getRentAgreementId(rentAgreementID,userId) async {

    var rentAgreementIdCompleter=Completer<Resp>();
    callAPI(getRentAgreementUrl,
        json.encode(
            {
              "RentAgreementID": rentAgreementID,
              "UserID":userId
            }
        )).then((resp){
      rentAgreementIdCompleter.complete(resp);
    });
    return rentAgreementIdCompleter.future;
  }
  Future<Resp>getSwapAgreementId(swapAgreementID,userId) async {

    var rentAgreementIdCompleter=Completer<Resp>();
    callAPI(getSwapArgeementTermsUrl,
        json.encode(
            {
              "SwapAgreementID":swapAgreementID,
              "UserID":userId
            }
        )).then((resp){
      rentAgreementIdCompleter.complete(resp);
    });
    return rentAgreementIdCompleter.future;
  }




  Future<void>getTripCarProfileInfo(String tripID) async {
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
      Navigator.pushNamed(context, '/trips_rent_out_details_ui', arguments: {
        'tripType': tripStatusPeriod,
        'trip': tripResponse,
        'backPressPop': true
      });
    print("after route************");

  }







  @override
  initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      _presenter = HostPresenter(this);
      _presenter!.getChangeRequest(widget.tripData.tripID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:AppBar(title: Text("Change Request Review",style: TextStyle(
        fontFamily:
        'Urbanist',
        fontSize:
        18,
      )),centerTitle: true,elevation:0.0,leading:
          IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Color(0xffFF8F68),
            ),
            onPressed: () => Navigator.pop(context),
          ),

      ),
      body: _loading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [


                Text("Your guest requested the following changes",style: TextStyle(
                  fontFamily:
                  'Urbanist',
                  fontSize:
                  18,
                )),
                SizedBox(
                  height: 6,
                ),
                Text("Current Info",style: TextStyle(
                  fontFamily:
                  'Urbanist',
                  fontSize:
                  16,
                )),
                SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: EdgeInsets.all(12.0),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.tripData.startDateTime !=
                          DateTime.parse(response["StartDateTime"])
                          ? Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 16),
                          Text(
                            "Pick Up Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(widget.tripData.startDateTime!.toLocal())}",style: TextStyle(
                          fontFamily:
                          'Urbanist',
                            fontSize:
                            15,
                          ),
                            overflow: TextOverflow.visible,
                            softWrap: false,
                          ),
                        ],
                      )
                          : Container(),
                      SizedBox(
                        height:widget.tripData.startDateTime !=
                            DateTime.parse(response["StartDateTime"])? 8:0,
                      ),
                      widget.tripData.endDateTime != DateTime.parse(response["EndDateTime"])
                          ? Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 16),
                          Text(
                              "Return Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(widget.tripData.endDateTime!.toLocal())}",style: TextStyle(
                          fontFamily:
                          'Urbanist',
                            fontSize:
                            15,
                          ),
                              overflow: TextOverflow.visible,
                              softWrap: false),
                        ],
                      )
                          : Container(),
                      SizedBox(
                        height:widget.tripData.endDateTime != DateTime.parse(response["EndDateTime"])? 8:0,
                      ),

                      widget.tripData.location!.address!=response['Location']["FormattedAddress"]?
                      Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 16),
                          Flexible(
                            child: Text(
                                "Location: ${widget.tripData.returnLocation==null?widget.tripData.location!.address:widget.tripData.returnLocation!.formattedAddress}",
                                ),
                          ),
                        ],
                      )
                          : Container()
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text("Requested Info",style: TextStyle(
                  fontFamily:
                  'Urbanist',
                  fontSize:
                  16,
                )),
                SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: EdgeInsets.all(12.0),
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      widget.tripData.startDateTime !=
                          DateTime.parse(response["StartDateTime"])
                          ? Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 16),
                          Text(  "Pick Up Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(widget.tripData.startDateTime!.toLocal())}",style: TextStyle(

                            // "Pick Up Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(DateTime.tryParse(response["StartDateTime"])!.toLocal())}",style: TextStyle(
                          fontFamily:
                          'Urbanist',
                            fontSize:
                            15,
                          ),
                            overflow: TextOverflow.visible,
                            softWrap: false,
                          ),
                        ],
                      )
                          : Container(),
                      SizedBox(
                        height: widget.tripData.startDateTime !=
                            DateTime.parse(response["StartDateTime"])?8:0,
                      ),
                      widget.tripData.endDateTime != DateTime.parse(response["EndDateTime"])
                          ? Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 16),
                          Text(
                              "Return Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(DateTime.tryParse(response["EndDateTime"])!.toLocal())}",style: TextStyle(
                            fontFamily:
                            'Urbanist',
                            fontSize:
                            16,
                          ),
                              overflow: TextOverflow.visible,
                              softWrap: false),
                        ],
                      )
                          : Container(),
                      SizedBox(
                        height:widget.tripData.endDateTime != DateTime.parse(response["EndDateTime"])? 8:0,
                      ),

                      widget.tripData.location!.formattedAddress!=response['Location']["FormattedAddress"]?
                      Row(
                        children: [
                          Icon(Icons.location_on),
                          SizedBox(width: 16),
                          Flexible(
                            child: Text(
                                "Location: ${response['Location']["FormattedAddress"]}",style: TextStyle(
                            fontFamily:
                            'Urbanist',
                              fontSize:
                              16,
                            ),
                            textAlign: TextAlign.left,),
                          ),
                        ],
                      )
                          : Container()
                    ],
                  ),
                ),

                // Table(
                //   // Allows to add a border decoration around your table
                //     border: TableBorder(verticalInside: BorderSide(width: 1, color:Color(0xffFF8F68) , style: BorderStyle.solid)),
                //     children: [
                //       TableRow(children :[
                //         Padding(
                //           padding: const EdgeInsets.only(top:8.0,right: 8.0),
                //           child: Text('Current Info'),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top:8.0,right: 8.0),
                //           child: Text('Requested Info'),
                //         ),
                //       ]),
                //       widget.tripData.startDateTime!=response["StartDateTime"]?
                //       TableRow(children :[
                //         Padding(
                //           padding:  const EdgeInsets.only(top:8.0,right: 8.0),
                //           child: Text('Start Date & Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(widget.tripData.startDateTime.toLocal())} ',style: TextStyle(fontWeight: FontWeight.bold)),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top:8.0),
                //           child: Text('Start Date & Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(DateTime.tryParse(response["StartDateTime"]).toLocal())}',style: TextStyle(fontWeight: FontWeight.bold)),
                //         ),
                //       ]):TableRow(children: [Container(),Container()]),
                //       widget.tripData.endDateTime!=response["EndDateTime"]?
                //       TableRow(children :[
                //         Padding(
                //           padding: const EdgeInsets.only(top:8.0,right: 8.0),
                //           child: Text('End Date & Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(widget.tripData.endDateTime.toLocal())}',style: TextStyle(fontWeight: FontWeight.bold),),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top:8.0,right: 8.0),
                //           child: Text('End Date & Time: ${DateFormat("EEE MMM dd, yyyy hh:00 a ").format(DateTime.tryParse(response["EndDateTime"]).toLocal())} ',style: TextStyle(fontWeight: FontWeight.bold)),
                //         ),
                //       ]):TableRow(children: [Container(),Container()]),
                //       widget.tripData.location.formattedAddress!=response['Location']["FormattedAddress"]?
                //       TableRow(children :[
                //         Padding(
                //           padding: const EdgeInsets.only(top:8.0,right: 8.0),
                //           child: Text('Location: ${widget.tripData.location.formattedAddress}',style: TextStyle(fontWeight: FontWeight.bold)),
                //         ),
                //         Padding(
                //           padding: const EdgeInsets.only(top:8.0,right: 8.0),
                //           child: Text('Location: ${response['Location']["FormattedAddress"]}',style: TextStyle(fontWeight: FontWeight.bold)),
                //         ),
                //       ]):TableRow(children: [Container(),Container()]),
                //     ]
                // ),

                SizedBox(
                  height: 20,
                ),
                Text(
                    "Accepting this Change will result in : \$ ${double.parse(response["HostPrice"].toString()).toInt()}",style: TextStyle(
                  fontFamily:
                  'Urbanist',
                  fontSize:
                  16,
                )),
                SizedBox(
                  height: 50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context)
                          .size
                          .width /2.5,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Color(0xffFF8F68))),
                        onPressed: () async {
                          await _presenter
                              !.getChangeRequestAccepted(widget.tripData.tripID);
                          if (_isAccepted) {
                            await  getTripCarProfileInfo(widget.tripData.tripID!);
                          }
                        },
                        child:!_isAccepted? Text("Accept", style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                          fontSize: 15,
                        ),):SizedBox(height:15,width: 15,child: CircularProgressIndicator(backgroundColor: Colors.white,)),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context)
                          .size
                          .width /2.5,
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                            MaterialStateProperty.all(Color(0xffFF8F68))),
                        onPressed: () async {
                          await _presenter
                              !.getChangeRequestRejected(widget.tripData.tripID);
                          if (_isRejected) {
                            await  getTripCarProfileInfo(widget.tripData.tripID!);
                          }
                        },
                        child: Text(!_isRejected?"Decline":"wait", style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Urbanist',
                          fontSize: 15,
                        ),),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }

  @override
  void onDataLoadError() {
    // TODO: implement onDataLoadError
  }

  @override
  void onDataLoadSuccess(res) {
    // TODO: implement onDataLoadSuccess
    response = res;
  }

  @override
  void onGetChangeRequest() {
    // TODO: implement onGetChangeRequest
  }

  @override
  void onDataLoading(bool load) {
    // TODO: implement onDataLoading
    setState(() {
      _loading = load;
    });
  }

  @override
  void onAcceptRequest(bool isAccepted) {
    // TODO: implement onAcceptRequest
    setState(() {
      _isAccepted = isAccepted;
    });
  }

  @override
  void onCancelRequest(bool isRejected) {
    // TODO: implement onCancelRequest
   setState(() {
     _isRejected = isRejected;
   });
  }
}
