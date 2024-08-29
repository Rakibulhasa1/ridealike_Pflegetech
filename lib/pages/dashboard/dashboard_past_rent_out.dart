import 'dart:core';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/book_a_car/booking_info.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/pages/trips/bloc/trips_rental_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/widgets/buton.dart';
import 'package:ridealike/widgets/cancel_modal.dart';
import 'package:ridealike/widgets/experience_modal.dart';
import 'package:ridealike/widgets/list_head.dart';
import 'package:ridealike/widgets/list_row.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/app_events/app_events_utils.dart';



class DashboardTripsRentOutDetails extends StatefulWidget {
  @override
  _DashboardTripsRentOutDetailsState createState() => _DashboardTripsRentOutDetailsState();
}

class _DashboardTripsRentOutDetailsState extends State<DashboardTripsRentOutDetails> {
  final tripsRentedOutBloc = TripsRentalBloc();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Dashboard Past Rent Out"});
  }

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
            title: "We are sorry to hear you had a bad experience",
            subtitle:
            "Our team is working o your case and we'll get back to you shortly");
      },
    );
  }

  void handleCancelConfirm() {
    Navigator.of(context).pop();
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
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    Trips tripDetails = receivedData['trip'];
    String tripType = receivedData['tripType'];
    String dash = receivedData['dashboard'];
    tripsRentedOutBloc.changedTripsData.call(tripDetails);
    tripsRentedOutBloc.changedTripsTypeData.call(tripType);
    tripsRentedOutBloc.getTripByIdMethod(tripDetails);
    tripsRentedOutBloc.rentAgreeIdCarInfo(tripDetails);
    tripsRentedOutBloc.changedProgressIndicator.call(0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: StreamBuilder<String>(
          stream: tripsRentedOutBloc.tripsType,
          builder: (context, tripsTypeSnapshot) {
            return tripsTypeSnapshot.hasData && tripsTypeSnapshot.data != null
                ? StreamBuilder<Trips>(
                stream: tripsRentedOutBloc.tripsData,
                builder: (context, tripsDataSnapshot) {
                  return tripsDataSnapshot.hasData && tripsDataSnapshot.data != null
                      ? Container(
                    child: Padding(
                      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                      child: SingleChildScrollView(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
//                                        margin: EdgeInsets.only(top: 25.0),
                              child: Stack(
                                children: <Widget>[
                                  (tripsDataSnapshot.data!.carImageId != null &&
                                      tripsDataSnapshot.data!.carImageId != '')
                                      ?
                                  Image.network(
                                    '$storageServerUrl/${tripsDataSnapshot.data!.carImageId}',
                                    fit: BoxFit.fill,
                                    width: double.infinity,
                                    height: 250,
                                  ) : Image.asset('images/car-placeholder.png'),
                                  Container(
                                    height: 60.0,
                                    margin: EdgeInsets.only(top: 5.0, right: 10.0, left: 10.0),
                                    child: Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            Map argument = {"Index": tripType == 'Upcoming' ? 0 :
                                            tripType == 'Current' ? 1 : 2
                                            };
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white,),
                                            child: Padding(padding: const EdgeInsets.all(8.0),
                                              child: Icon(Icons.arrow_back),),
                                          ),
                                        ),
                                        SizedBox(width: 10.0,),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12.0),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Text(" ${tripsTypeSnapshot.data} rent out",
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF353B50)),textAlign: TextAlign.center,
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
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Column(
                                children: [
                                  Padding(padding: EdgeInsets.only(top: 24,),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: Text(
                                            'TRIP ID: ' + (tripDetails.tripType == 'Swap' ? 'SBN${tripDetails.swapData!.SBN}' : 'RBN${tripDetails.rBN}'),
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 12,
                                              color: Color(0xff371D32).withOpacity(0.5),
                                            ),
                                            // textAlign: TextAlign.start,
                                          ),
                                        ),
                                        Divider(color: Color(0xFFE7EAEB)),
                                        SizedBox(height: 20),
                                        ListHead(title: 'TRIP DETAILS',
                                        ),
                                        ListRow(
                                          leading: Image.asset(
                                            'icons/Calendar_Manage-Calendar.png',
                                            width: 16, color: Color.fromRGBO(55, 29, 50, 1),
                                          ),
                                          title: Text("Pickup",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
                                          ),
                                          trailing: Text(DateFormat('EEE, MMM dd, hh:00 a')
                                              .format(tripsDataSnapshot.data!.startDateTime!.toLocal()),
                                            style: TextStyle(fontFamily: 'Urbanist', fontSize: 12,
                                                color: Color(0xFF353B50)),
                                          ),
                                        ),
                                        ListRow(
                                          leading: Image.asset(
                                            'icons/Calendar_Manage-Calendar.png',
                                            width: 16,
                                            color: Color.fromRGBO(55, 29, 50, 1),
                                          ),
                                          title: Text("Return",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
                                          ),
                                          trailing: Text(DateFormat('EEE, MMM dd, hh:00 a')
                                              .format(tripsDataSnapshot.data!.endDateTime!.toLocal()),
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 12,
                                                color: Color(0xFF353B50)),
                                          ),
                                        ),
                                        // ListRow(
                                        //   leading: Image.asset(
                                        //     'icons/Location_Car-Location.png',
                                        //     width: 16,
                                        //     color: Color.fromRGBO(55, 29, 50, 1),
                                        //   ),
                                        //   title: Text("Location",
                                        //     style: TextStyle(
                                        //         fontFamily: 'Urbanist',
                                        //         fontSize: 16,
                                        //         color: Color(0xFF371D32)),
                                        //   ),
                                        //   trailing: SizedBox(width: MediaQuery.of(context).size.width*.5,
                                        //     child: AutoSizeText(
                                        //       tripsDataSnapshot.data!.location.address,
                                        //       style: TextStyle(
                                        //           fontFamily: 'Urbanist',
                                        //           fontSize: 12,
                                        //           color: Color(0xFF353B50)),textAlign: TextAlign.right,
                                        //       maxLines: 3, overflow: TextOverflow.ellipsis,
                                        //
                                        //     ),
                                        //   ),
                                        // ),

                                        //location//
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Image.asset(
                                                    'icons/Location_Car-Location.png',
                                                    width: 16,
                                                    color: Color.fromRGBO(55, 29, 50, 1),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
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
                                        ),
                                        SizedBox(height: 8,),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              SizedBox(
                                                width: MediaQuery.of(context).size.width * 0.85,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10),
                                                  child: AutoSizeText(
                                                    tripsDataSnapshot.data!.location!.address!,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 12,
                                                        color: Color(0xFF353B50)),
                                                    maxLines: 3,
                                                  ),
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
                                        ),
                                        Divider()
                                      ],
                                    ),
                                  ),

                                  Padding(padding: EdgeInsets.symmetric(vertical: 16,),
                                    child: Column(
                                      children: [
                                        // ListHead(title: 'BOOKING DETAILS',),
                                        ListRow(
                                          leading: Center(
                                            child: (tripsDataSnapshot.data!.carImageId != null &&
                                                tripsDataSnapshot.data!.carImageId != '')
                                                ? CircleAvatar(
                                              backgroundImage: NetworkImage('$storageServerUrl/${tripsDataSnapshot.data!.carImageId}'),
                                              radius: 17.5,
                                            )
                                                : CircleAvatar(backgroundImage:
                                            AssetImage('images/car-placeholder.png'),
                                              radius: 17.5,
                                            ),
                                          ),
                                          title: Text(
                                            "Booked Car",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
                                          ),
                                          trailing: Text(tripsDataSnapshot.data!.car!.about!.year! +
                                              ' ' + tripsDataSnapshot.data!.car!.about!.make! +
                                              ' ' + tripsDataSnapshot.data!.car!.about!.model!,
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 12,
                                                color: Color(0xFF353B50)),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                              context,
                                              '/trips_guest_profile_ui',
                                              arguments: {
                                                'guestUserID': tripDetails.guestUserID
                                              },
                                            );
                                          },
                                          child: ListRow(
                                            leading: Center(
                                              child: (tripsDataSnapshot.data!.guestProfile!.imageID != null &&
                                                  tripsDataSnapshot.data!.guestProfile!.imageID != '')
                                                  ? CircleAvatar(
                                                backgroundImage:
                                                NetworkImage(
                                                    '$storageServerUrl/${tripsDataSnapshot.data!.guestProfile!.imageID}'),
                                                radius: 17.5,
                                              )
                                                  : CircleAvatar(
                                                backgroundImage: AssetImage('images/user.png'),
                                                radius: 17.5,
                                              ),
                                            ),
                                            title: Text("Guest",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32)),),
                                            trailing: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '${tripsDataSnapshot.data!.guestProfile!.firstName} ${tripsDataSnapshot.data!.guestProfile!.lastName}',
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 12,
                                                      color: Color(0xFF353B50)),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                                Icon(Icons.chevron_right),
                                              ],
                                            ),
                                          ),
                                        ),
                                        tripsTypeSnapshot.data == 'Past'
                                            ? InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(context, '/receipt',
                                                arguments: tripDetails.bookingID);
                                          },
                                          child: ListRow(
                                            title: Text(
                                              // "Trip Payout",
                                              "Trip earnings",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32)),
                                            ),
                                            trailing: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "\$${tripsDataSnapshot.data!.hostTotal!.toStringAsFixed(2)}",
                                                  style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 12,
                                                      color: Color(0xFF353B50)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                Icon(Icons.chevron_right),
                                              ],
                                            ),
                                          ),
                                        )
                                            : ListRow(
                                          title: Text("Trip earnings",
                                            style: TextStyle(
                                                fontFamily:
                                                'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
                                          ),
                                          trailing: Text(
                                            "\$${tripsDataSnapshot.data!.hostTotal!.toStringAsFixed(2)}",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 12,
                                                color: Color(0xFF353B50)),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  //messages & call guest//
                                  Row(  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: (){
                                          Thread threadData = new Thread(
                                              id: "1123571113",
                                              userId: tripsDataSnapshot.data!.guestProfile!.userID!,
                                              image: tripsDataSnapshot.data!.guestProfile!.imageID != "" ?
                                              tripsDataSnapshot.data!.guestProfile!.imageID! : "",
                                              name: tripsDataSnapshot.data!.guestProfile!.firstName! +
                                                  '\t' + tripsDataSnapshot.data!.guestProfile!.lastName!,
                                              message: '',
                                              time: '',
                                              messages: []);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute( settings: RouteSettings(name: "/messages"),builder: (context) =>
                                                MessageListView(thread: threadData,
                                                ),
                                            ),
                                          );
                                        },
                                        child: Container(width: MediaQuery.of(context).size.width /
                                            2.3,
                                            decoration: BoxDecoration(
                                              color: Color(0xfff2f2f2),
                                              borderRadius:
                                              BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                  horizontal: 10,
                                                  vertical: 15),
                                              child: Center(
                                                  child: Text(
                                                    "Message guest",
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color: Color(
                                                            0xFF371D32)),
                                                  )),
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          launchUrl(
                                              ('tel://${tripsDataSnapshot.data!.guestProfile!.phoneNumber}'));
                                        },
                                        child: Container(
                                            width: MediaQuery.of(context).size.width / 2.3,
                                            decoration: BoxDecoration(
                                              color: Color(0xfff2f2f2),
                                              borderRadius: BorderRadius.all(Radius.circular(8)),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                              child: Center(
                                                  child: Text(
                                                    "Call guest",
                                                    style: TextStyle(fontFamily: 'Urbanist',
                                                        fontSize: 16, color: Color(0xFF371D32)),
                                                  )),
                                            )),
                                      ),
//                                                Button(
//                                                  title: "Message guest",
//                                                  textStyle: TextStyle(
//                                                      fontFamily: 'Urbanist',
//                                                      fontSize: 16,
//                                                      color: Color(0xff371D32)),
//                                                  onPress: () {
//                                                    Thread threadData = new Thread(
//                                                        id: "1123571113",
//                                                        userId: tripsDataSnapshot.data!.guestProfile!.userID,
//                                                        image: tripsDataSnapshot.data!.guestProfile!.imageID != "" ?
//                                                        tripsDataSnapshot.data!.guestProfile!.imageID : "",
//                                                        name: tripsDataSnapshot.data!.guestProfile!.firstName +
//                                                            '\t' + tripsDataSnapshot.data!.guestProfile!.lastName,
//                                                        message: '',
//                                                        time: '',
//                                                        messages: []);
//                                                    Navigator.push(
//                                                      context,
//                                                      MaterialPageRoute(builder: (context) =>
//                                                          MessageListView(thread: threadData,
//                                                        ),
//                                                      ),
//                                                    );
//                                                  },
//                                                ),
//                                                SizedBox(width: 16),
//                                                Expanded(
//                                                  child: Button(
//                                                    title: "Call guest",
//                                                    textStyle: TextStyle(
//                                                        fontFamily:
//                                                            'Urbanist',
//                                                        fontSize: 16,
//                                                        color: Color(
//                                                            0xff371D32)),
//                                                    onPress: () {
//                                                      launchUrl(
//                                                          ('tel://${tripsDataSnapshot.data!.guestProfile!.phoneNumber}'));
//                                                    },
//                                                  ),
//                                                ),
                                    ],
                                  ),
                                  SizedBox(height: 8,),
                                  tripsTypeSnapshot.data == 'Upcoming' ?
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Container(
                                      margin: EdgeInsets.all(2),
                                      child: Button(title: "Cancel trip",
                                        textStyle: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xff371D32)),
                                        onPress: () => handleShowCancelModal(tripDetails),
                                      ),
                                    ),
                                  ) : new Container(),



                                  SizedBox(height: 4,),
                                  tripsDataSnapshot.data!.tripStatus == 'Ended'

                                      ? Column(
                                    children: [
                                      SizedBox(height: 16),
                                      Divider(),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
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
                                                              shape:
                                                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                                            ),
                                                            onPressed:
                                                                () {
                                                              Navigator.pushNamed(
                                                                context,
                                                                '/inspection_ui',
                                                                arguments: {
                                                                  'tripType': tripsTypeSnapshot.data,
                                                                  'trip': tripsDataSnapshot.data
                                                                },
                                                              );
                                                            },
                                                            child:
                                                            Text('Inspect your vehicle',
                                                              style: TextStyle(fontFamily: 'Urbanist',
                                                                  fontSize: 18, color: Colors.white),
                                                            ),
                                                          ))),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                      : tripsDataSnapshot.data!.tripStatus == 'Completed' ?
                                  //Reimbursement//
                                  tripsDataSnapshot.data!.reimbursementStatus=='Unapproved'?
                                  Column(children: [
                                    SizedBox(height: 16),
                                    Divider(),
                                    Padding(padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              children: <Widget>[
                                                SizedBox(width: double.maxFinite,
                                                    child: Container(margin: EdgeInsets.all(8.0),
                                                      child: ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                        elevation: 0.0,
                                                        backgroundColor: Color(0xFFFF8F62),
                                                        padding: EdgeInsets.all(16.0),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),),
                                                        onPressed: () {
                                                          // handleShowReimbursementModal(tripDetails.tripID);
                                                          Navigator.pushNamed(context,'/reimbursement',arguments: tripDetails.tripID);

                                                        },
                                                        child: Text('Request reimbursement',
                                                          style: TextStyle(fontFamily: 'Urbanist',
                                                              fontSize: 18, color: Colors.white),
                                                        ),
                                                      ),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  ):Container()
                                      : Container(),
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
}

void launchUrl(String url) async {
  if (await canLaunch(url)) {
    launch(url);
  } else {
    throw "Could not launch $url";
  }
}