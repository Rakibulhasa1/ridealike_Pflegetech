import 'dart:convert' show json;
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/trips/bloc/trips_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_by_user_ids_response.dart';
import 'package:ridealike/pages/trips/response_model/trips_get_car_by_ids_response.dart';

import '../../utils/app_events/app_events_utils.dart';

Future<http.Response> fetchCarsData(_carIDs, jwt) async {
  final response = await http.post(
    Uri.parse(getCarsByCarIDsUrl),
    // getCarsByCarIDsUrl as Uri,
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({
      "carIDs": _carIDs,
    }),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

const textStyle = TextStyle(
    color: Color(0xff371D32),
    fontSize: 36,
    fontFamily: 'Urbanist',
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2);

class DashboardPastTrips extends StatefulWidget {
  @override
  State createState() => DashboardPastTripsState();
}

class DashboardPastTripsState extends State<DashboardPastTrips> {
  var tripsBloc = TripsBloc();
  String? _userID;
  final storage = new FlutterSecureStorage();

  var _receivedData;

  String? userID;
  String? hostUserId;
  var dataToRemove;
  String? pastTrip;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name": "Past Trips"});
    Future.delayed(Duration.zero, () {
      _receivedData = ModalRoute.of(context)!.settings.arguments;
      var carId = _receivedData['CarID'];
      setState(() {
        dataToRemove = _receivedData['DataToRemove'];
      });

      if (carId != null && carId != '') {
        tripsBloc.allTripsGroupStatus(200, 0, 'Past').then((value) async {
          _userID = (await storage.read(key: 'user_id'))!;
          var carIds = Map<String, Car>();
          var userIds = Map<String, Profiles>();
          for (int i = 0; i < value!.trips!.length; i++) {
            //car id Info//

            carIds[value.trips![i].carID!] = Car();
            userIds[value.trips![i].hostUserID!] = Profiles();
            userIds[value.trips![i].guestUserID!] = Profiles();
            value.trips![i].userID = value.userID;
            if (value.trips![i].tripType == 'Swap') {
              carIds[value.trips![i].swapData!.myCarID!] = Car();
            }
          }

          GetCarsByCarIDsResponse? carIdsResponse =
              await tripsBloc.tripGetCarData(carIds.keys.toList());
          ProfileByUserIdsResponse? userIdsResponse =
              await tripsBloc.tripsGetProfileData(userIds.keys.toList());

          carIds.clear();
          userIds.clear();

          if (carIdsResponse != null) {
            for (int i = 0; i < carIdsResponse.cars!.length; i++) {
              carIds[carIdsResponse.cars![i].iD!] = carIdsResponse.cars![i];
            }
          }
          if (userIdsResponse != null) {
            for (int i = 0; i < userIdsResponse.profiles!.length; i++) {
              userIds[userIdsResponse.profiles![i].userID!] =
                  userIdsResponse.profiles![i];
            }
          }

          for (int i = 0; i < value.trips!.length; i++) {
            //car id Info//
            Car? cars = carIds[value.trips![i].carID];
            if (cars != null) {
              value.trips![i].car = cars;
              value.trips![i].carName = cars.name;
              value.trips![i].carImageId =
                  cars.imagesAndDocuments!.images!.mainImageID;
              value.trips![i].carLicense =
                  cars.imagesAndDocuments!.license!.plateNumber;
              value.trips![i].carYear = cars.about!.year;
              value.trips![i].car!.about!.make = cars.about!.make;
              value.trips![i].car!.about!.model = cars.about!.model;
            }

            if (value.trips![i].tripType == 'Swap') {
              value.trips![i].myCarForSwap =
                  carIds[value.trips![i].swapData!.myCarID];
            }

            Profiles? hostUserProfile = userIds[value.trips![i].hostUserID];
            if (hostUserProfile != null) {
              value.trips![i].hostProfile = hostUserProfile;
            }

            Profiles? guestUserProfile = userIds[value.trips![i].guestUserID];
            if (guestUserProfile != null) {
              value.trips![i].guestProfile = guestUserProfile;
            }
          }

          value.trips!.removeWhere((element) =>
              element.car == null ||
              (element.hostUserID == _userID && element.tripType == 'Swap'));

          value.trips!.removeWhere((element) => (element.tripType != 'Swap'
              ? element.carID != carId
              : (element.swapData != null &&
                  element.swapData!.myCarID != carId)));

          //
          // if(dataToRemove == 'C') {
          //   value.trips!.removeWhere((element) => element.tripStatus == "Cancelled");
          // } else if ( dataToRemove == 'A'){
          //   value.trips!.removeWhere((element) => element.tripStatus != "Cancelled"&& element.tripType!='Swap');
          // }
          if (dataToRemove == 'C') {
            value.trips!
                .removeWhere((element) => element.tripStatus == "Cancelled");
          } else if (dataToRemove == 'A') {
            value.trips!
                .removeWhere((element) => element.tripStatus != "Cancelled");
          }

          value.trips!.removeWhere((element) =>
              element.tripType == "Rent" && element.guestUserID == _userID);

          tripsBloc.changedTripGroupStatus.call(value);
        });
      } else {
        tripsBloc.allTripsGroupStatus(200, 0, 'Past').then((value) async {
          _userID = (await storage.read(key: 'user_id'))!;
          var carIds = Map<String, Car>();
          var userIds = Map<String, Profiles>();
          for (int i = 0; i < value!.trips!.length; i++) {
            //car id Info//

            carIds[value.trips![i].carID!] = Car();
            userIds[value.trips![i].hostUserID!] = Profiles();
            userIds[value.trips![i].guestUserID!] = Profiles();
            value.trips![i].userID = value.userID;
            if (value.trips![i].tripType == 'Swap') {
              carIds[value.trips![i].swapData!.myCarID!] = Car();
            }
          }

          GetCarsByCarIDsResponse? carIdsResponse =
              await tripsBloc.tripGetCarData(carIds.keys.toList());
          ProfileByUserIdsResponse userIdsResponse =
              await tripsBloc.tripsGetProfileData(userIds.keys.toList());

          carIds.clear();
          userIds.clear();

          if (carIdsResponse != null) {
            for (int i = 0; i < carIdsResponse.cars!.length; i++) {
              carIds[carIdsResponse.cars![i].iD!] = carIdsResponse.cars![i];
            }
          }
          if (userIdsResponse != null) {
            for (int i = 0; i < userIdsResponse.profiles!.length; i++) {
              userIds[userIdsResponse.profiles![i].userID!] =
                  userIdsResponse.profiles![i];
            }
          }

          for (int i = 0; i < value.trips!.length; i++) {
            //car id Info//
            Car? cars = carIds[value.trips![i].carID];
            if (cars != null) {
              value.trips![i].car = cars;
              value.trips![i].carName = cars.name;
              value.trips![i].carImageId =
                  cars.imagesAndDocuments!.images!.mainImageID;
              value.trips![i].carLicense =
                  cars.imagesAndDocuments!.license!.plateNumber;
              value.trips![i].carYear = cars.about!.year;
              value.trips![i].car!.about!.make = cars.about!.make;
              value.trips![i].car!.about!.model = cars.about!.model;
            }

            if (value.trips![i].tripType == 'Swap') {
              value.trips![i].myCarForSwap =
                  carIds[value.trips![i].swapData!.myCarID];
            }

            Profiles? hostUserProfile = userIds[value.trips![i].hostUserID];
            if (hostUserProfile != null) {
              value.trips![i].hostProfile = hostUserProfile;
            }

            Profiles? guestUserProfile = userIds[value.trips![i].guestUserID];
            if (guestUserProfile != null) {
              value.trips![i].guestProfile = guestUserProfile;
            }
          }

          value.trips!.removeWhere((element) =>
              element.car == null ||
              (element.hostUserID == _userID && element.tripType == 'Swap'));

          // if(dataToRemove == 'C') {
          //   value.trips!.removeWhere((element) => element.tripStatus == "Cancelled");
          // } else if ( dataToRemove == 'A'){
          //   value.trips!.removeWhere((element) => element.tripStatus != "Cancelled" && element.tripType!='Swap');
          // }
          if (dataToRemove == 'C') {
            value.trips!
                .removeWhere((element) => element.tripStatus == "Cancelled");
          } else if (dataToRemove == 'A') {
            value.trips!
                .removeWhere((element) => element.tripStatus != "Cancelled");
          }

          value.trips!.removeWhere((element) =>
              element.tripType == "Rent" && element.guestUserID == _userID);

          tripsBloc.changedTripGroupStatus.call(value);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('removeData$dataToRemove');
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            dataToRemove != null && dataToRemove == 'C'
                ? 'Past Trips'
                : 'Cancelled Trips',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: Color(0xff371D32),
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: StreamBuilder<TripAllUserStatusGroupResponse>(
            stream: tripsBloc.tripGroupStatus,
            builder: (context, tripGroupStatusSnapshot) {
              return tripGroupStatusSnapshot.hasData &&
                      tripGroupStatusSnapshot.data != null
                  ? Container(
                      color: Colors.white,
                      height: MediaQuery.of(context).size.height,
                      child: tripGroupStatusSnapshot.data!.trips!.length != 0
                          ? ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: false,
                              itemCount:
                                  tripGroupStatusSnapshot.data!.trips!.length,
                              itemBuilder: (context, index) {
//              Trips trip = widget.tripsToShow[index];
                                return GestureDetector(
                                  onTap: () {
                                    //route with car model
                                    if (tripGroupStatusSnapshot
                                            .data!.trips![index].tripStatus ==
                                        'Cancelled') {
                                      Navigator.pushNamed(context,
                                          '/dashboard_trips_cancelled_details',
                                          arguments: tripGroupStatusSnapshot
                                              .data!.trips![index]);
                                    } else if (tripGroupStatusSnapshot.data!
                                                .trips![index].tripStatus ==
                                            'Cancelled' &&
                                        tripGroupStatusSnapshot
                                                .data!.trips![index].tripType ==
                                            'Swap') {
                                      Navigator.pushNamed(context,
                                          '/dashboard_trips_cancelled_details',
                                          arguments: tripGroupStatusSnapshot
                                              .data!.trips![index]);
                                    } else if (tripGroupStatusSnapshot
                                            .data!.trips![index].tripType ==
                                        'Swap') {
                                      Navigator.pushNamed(
                                        context,
                                        '/dashboard_past_trips_details',
                                        arguments: {
                                          'tripType': 'Past',
                                          'trip': tripGroupStatusSnapshot
                                              .data!.trips![index]
                                        },
                                      );
                                    } else if (tripGroupStatusSnapshot
                                            .data!.trips![index].guestUserID ==
                                        tripGroupStatusSnapshot.data!.userID) {
                                      Navigator.pushNamed(
                                        context,
                                        '/dashboard_past_trips_details',
                                        arguments: {
                                          'tripType': 'Past',
                                          'trip': tripGroupStatusSnapshot
                                              .data!.trips![index],
                                        },
                                      );
                                    } else if (tripGroupStatusSnapshot
                                            .data!.trips![index].hostUserID ==
                                        tripGroupStatusSnapshot.data!.userID) {
                                      Navigator.pushNamed(context,
                                          '/dashboard_past_trips_rent_out_details',
                                          arguments: {
                                            'tripType': 'Past',
                                            'trip': tripGroupStatusSnapshot
                                                .data!.trips![index],
                                            'dashboard': '1'
                                          });
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 15,
                                        right: 15,
                                        top: 15,
                                        bottom: 8),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                            minHeight: 335,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3.45,
                                            maxHeight: 380),
                                        child: Column(
                                          children: <Widget>[
                                            // Image of the vehicle
                                            Stack(
                                              children: <Widget>[
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              12.0)),
//
                                                  child: Container(
                                                    height: 250,
                                                    width: double.infinity,
                                                    child: (tripGroupStatusSnapshot
                                                                    .data!
                                                                    .trips![
                                                                        index]
                                                                    .carImageId ==
                                                                null ||
                                                            tripGroupStatusSnapshot
                                                                    .data!
                                                                    .trips![
                                                                        index]
                                                                    .carImageId ==
                                                                '')
                                                        ? AssetImage(
                                                                'images/car-placeholder.png')
                                                            as Widget
                                                        : Image.network(
                                                            '$storageServerUrl/${tripGroupStatusSnapshot.data!.trips![index].carImageId}',
                                                            fit: BoxFit.fill,
                                                          ),
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 10,
                                                  left: 15,
                                                  child: Container(
                                                    height: 25,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                        color:
                                                            Color(0xffFFFFFF),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
                                                        shape:
                                                            BoxShape.rectangle),
                                                    child: Center(
                                                      child: Text(
                                                        tripGroupStatusSnapshot
                                                                    .data!
                                                                    .trips![
                                                                        index]
                                                                    .tripType ==
                                                                'Swap'
                                                            ? 'SWAP'
                                                            : tripGroupStatusSnapshot
                                                                        .data!
                                                                        .trips![
                                                                            index]
                                                                        .guestUserID ==
                                                                    tripGroupStatusSnapshot
                                                                        .data!
                                                                        .userID
                                                                ? 'RENTAL'
                                                                : tripGroupStatusSnapshot
                                                                            .data!
                                                                            .trips![
                                                                                index]
                                                                            .hostUserID ==
                                                                        tripGroupStatusSnapshot
                                                                            .data!
                                                                            .userID
                                                                    ? 'RENT OUT'
                                                                    : 'TripTypeUndefined',
                                                        style: TextStyle(
                                                            fontSize: 12,
                                                            color: Color(
                                                                0xff353B50),
                                                            fontFamily:
                                                                'Urbanist'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Visibility(
                                                  visible:
                                                      tripGroupStatusSnapshot
                                                                  .data!
                                                                  .trips![index]
                                                                  .tripStatus ==
                                                              'Cancelled'
                                                          ? true
                                                          : false,
                                                  child: Positioned(
                                                    bottom: 10,
                                                    left: 110,
                                                    child: Container(
                                                      height: 25,
                                                      width: 90,
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xffF55A51),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          shape: BoxShape
                                                              .rectangle),
                                                      child: Center(
                                                        child: Text(
                                                          'CANCELLED',
                                                          style: TextStyle(
                                                              fontSize: 12,
                                                              color: Color(
                                                                  0xffFFFFFF),
                                                              fontFamily:
                                                                  'Urbanist'),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 15),
                                            // vehicle content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  // car name //
                                                  Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15, top: 8),
                                                      child: Text(
                                                        (tripGroupStatusSnapshot.data!.trips![index].car!.about!.year == null &&
                                                                    tripGroupStatusSnapshot
                                                                            .data!
                                                                            .trips![
                                                                                index]
                                                                            .car!
                                                                            .about!
                                                                            .make ==
                                                                        null &&
                                                                    tripGroupStatusSnapshot
                                                                            .data!
                                                                            .trips![
                                                                                index]
                                                                            .car!
                                                                            .about!
                                                                            .model ==
                                                                        null ||
                                                                tripGroupStatusSnapshot.data!.trips![index].car!.about!.year == '' &&
                                                                    tripGroupStatusSnapshot
                                                                            .data!
                                                                            .trips![
                                                                                index]
                                                                            .car!
                                                                            .about!
                                                                            .make ==
                                                                        '' &&
                                                                    tripGroupStatusSnapshot
                                                                            .data!
                                                                            .trips![
                                                                                index]
                                                                            .car!
                                                                            .about!
                                                                            .model ==
                                                                        '')
                                                            ? 'No name found'
                                                            : tripGroupStatusSnapshot.data!.trips![index].car!.about!.year! +
                                                                ' ' +
                                                                tripGroupStatusSnapshot
                                                                    .data!
                                                                    .trips![
                                                                        index]
                                                                    .car!
                                                                    .about!
                                                                    .make! +
                                                                ' ' +
                                                                tripGroupStatusSnapshot
                                                                    .data!
                                                                    .trips![
                                                                        index]
                                                                    .car!
                                                                    .about!
                                                                    .model!,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Color(0xff371D32),
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 15,
                                                              right: 4),
                                                      child: Row(
                                                        children: <Widget>[
                                                          // calendar//
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
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
                                                                  width: 8),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <Widget>[
                                                                  //start date//
                                                                  Text(
                                                                    '${DateFormat('MMM dd, hh:00 a').format(tripGroupStatusSnapshot.data!.trips![index].startDateTime!.toLocal())} to',
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xff353B50),
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        letterSpacing:
                                                                            -0.2,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                  //End date//
                                                                  Text(
                                                                    '${DateFormat('MMM dd, hh:00 a').format(tripGroupStatusSnapshot.data!.trips![index].endDateTime!.toLocal())}',
                                                                    style: TextStyle(
                                                                        color: Color(
                                                                            0xff353B50),
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .normal,
                                                                        letterSpacing:
                                                                            -0.2,
                                                                        fontSize:
                                                                            14),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(width: 10),
                                                          tripGroupStatusSnapshot
                                                                      .data!
                                                                      .trips![
                                                                          index]
                                                                      .guestUserID ==
                                                                  tripGroupStatusSnapshot
                                                                      .data!
                                                                      .userID
                                                              ? tripGroupStatusSnapshot
                                                                          .data!
                                                                          .trips![
                                                                              index]
                                                                          .tripStatus ==
                                                                      'Cancelled'

                                                                  //Cancelled for free//
                                                                  ? Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: <Widget>[
                                                                        Icon(
                                                                            Icons
                                                                                .payment,
                                                                            color:
                                                                                Color(0xFF3C2235)),
                                                                        SizedBox(
                                                                            width:
                                                                                5),
                                                                        Container(
                                                                          height:
                                                                              60,
                                                                          width:
                                                                              100,
                                                                          child:
                                                                              Align(
                                                                            alignment:
                                                                                Alignment.center,
                                                                            child:
                                                                                Text(
                                                                              tripGroupStatusSnapshot.data!.trips![index].tripStatus == 'Cancelled' && tripGroupStatusSnapshot.data!.trips![index].guestTotal == 0 ? 'Cancelled for free' : '\$${tripGroupStatusSnapshot.data!.trips![index].guestTotal!.toStringAsFixed(2).replaceAll("-", "")}',
                                                                              style: TextStyle(
                                                                                fontSize: 14,
                                                                                fontFamily: 'Urbanist',
                                                                                color: Color(0xff353B50),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : tripGroupStatusSnapshot
                                                                              .data!
                                                                              .tripStatusGroup ==
                                                                          'Past'
                                                                      ? Row(
                                                                          children: <Widget>[
                                                                            Icon(Icons.payment,
                                                                                color: Color(0xFF3C2235)),
                                                                            SizedBox(width: 5),
                                                                            Text(
                                                                              '\$${tripGroupStatusSnapshot.data!.trips![index].guestTotal!.toStringAsFixed(2).replaceAll("-", "")}',
                                                                              style: TextStyle(
                                                                                fontSize: 14,
                                                                                fontFamily: 'Urbanist',
                                                                                color: Color(0xff353B50),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : tripGroupStatusSnapshot.data!.trips![index].tripType ==
                                                                              'Swap'
                                                                          ? Row(
                                                                              children: <Widget>[
                                                                                ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  child: Image(
                                                                                    height: 20,
                                                                                    width: 20,
                                                                                    fit: BoxFit.cover,
                                                                                    image: NetworkImage('$storageServerUrl/${tripGroupStatusSnapshot.data!.trips![index].myCarForSwap!.imagesAndDocuments!.images!.mainImageID}'),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 10),
                                                                                SizedBox(
                                                                                  width: 100,
                                                                                  height: 80,
                                                                                  child: Center(
                                                                                    child: AutoSizeText(
                                                                                      'Swapping with ${tripGroupStatusSnapshot.data!.trips![index].myCarForSwap!.about!.year! + ' ' + tripGroupStatusSnapshot.data!.trips![index].myCarForSwap!.about!.make! + ' ' + tripGroupStatusSnapshot.data!.trips![index].myCarForSwap!.about!.model!}',
                                                                                      maxLines: 2,
                                                                                      style: TextStyle(
                                                                                        fontSize: 14,
                                                                                        letterSpacing: -0.2,
                                                                                        color: Color(0xff353B50),
                                                                                        fontWeight: FontWeight.normal,
                                                                                        fontFamily: 'Urbanist',
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Expanded(
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: <Widget>[
                                                                                  Icon(Icons.location_on, color: Color(0xff353B50), size: 20),
                                                                                  SizedBox(width: 8),
                                                                                  Container(
                                                                                    height: 200,
                                                                                    width: 100,
                                                                                    child: Align(
                                                                                      alignment: Alignment.center,
                                                                                      child: AutoSizeText(
                                                                                        '${tripGroupStatusSnapshot.data!.trips![index].location!.address}',
                                                                                        maxLines: 2,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: TextStyle(
                                                                                          fontSize: 14,
                                                                                          letterSpacing: -0.2,
                                                                                          color: Color(0xff353B50),
                                                                                          fontWeight: FontWeight.normal,
                                                                                          fontFamily: 'Urbanist',
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            )
                                                              : tripGroupStatusSnapshot
                                                                          .data!
                                                                          .trips![
                                                                              index]
                                                                          .hostUserID ==
                                                                      tripGroupStatusSnapshot
                                                                          .data!
                                                                          .userID
                                                                  ? tripGroupStatusSnapshot
                                                                              .data!
                                                                              .trips![
                                                                                  index]
                                                                              .tripStatus ==
                                                                          'Cancelled'
                                                                      ? Row(
                                                                          children: <Widget>[
                                                                            Image.asset('icons/Payout-Method.png'),
                                                                            SizedBox(width: 8),
                                                                            Text(
                                                                              tripGroupStatusSnapshot.data!.trips![index].tripStatus == 'Cancelled' && tripGroupStatusSnapshot.data!.trips![index].hostTotal! > 0.0 ? '\$${tripGroupStatusSnapshot.data!.trips![index].hostTotal!.toStringAsFixed(2).replaceAll("-", "")}' : 'No trip earnings'

                                                                              // tripGroupStatusSnapshot.data!.trips![index].tripStatus == 'Cancelled'  &&
                                                                              //     tripGroupStatusSnapshot.data!.trips![index].hostTotal!=0?'\$${tripGroupStatusSnapshot.data!.trips![index].hostTotal.toStringAsFixed(2)}':
                                                                              // tripGroupStatusSnapshot.data!.trips![index].tripType == 'Swap'
                                                                              //     ? '\$${tripGroupStatusSnapshot.data!.trips![index].hostTotal.toStringAsFixed(2).replaceAll("-", "")}'
                                                                              //     : 'No trip payout',
                                                                              ,
                                                                              style: TextStyle(fontSize: 14, fontFamily: 'Open Sans Regular', color: Color(0xff353B50), letterSpacing: -0.2, fontWeight: FontWeight.normal),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : tripGroupStatusSnapshot.data!.tripStatusGroup ==
                                                                              'Past'
                                                                          ? Row(
                                                                              children: <Widget>[
                                                                                Image.asset('icons/Payout-Method.png'),
                                                                                SizedBox(width: 8),
                                                                                Text(
                                                                                  '\$${tripGroupStatusSnapshot.data!.trips![index].hostTotal!.toStringAsFixed(2).replaceAll("-", "")}',
                                                                                  style: TextStyle(fontSize: 14, fontFamily: 'Urbanist', color: Color(0xff353B50), letterSpacing: -0.2, fontWeight: FontWeight.normal),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          : Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: <Widget>[
                                                                                ClipRRect(
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                  child: Image(
                                                                                    height: 20,
                                                                                    width: 20,
                                                                                    fit: BoxFit.cover,
                                                                                    image: (tripGroupStatusSnapshot.data!.trips![index].guestProfile!.imageID == null || tripGroupStatusSnapshot.data!.trips![index].guestProfile!.imageID == '') ? AssetImage('images/user.png') : NetworkImage('$storageServerUrl/${tripGroupStatusSnapshot.data!.trips![index].guestProfile!.imageID}') as ImageProvider,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 8),
                                                                                Container(
                                                                                  height: 100,
                                                                                  width: 100,
                                                                                  child: Align(
                                                                                    alignment: Alignment.center,
                                                                                    child: AutoSizeText(
                                                                                      '${tripGroupStatusSnapshot.data!.trips![index].guestProfile!.firstName} ${tripGroupStatusSnapshot.data!.trips![index].guestProfile!.lastName}',
                                                                                      style: TextStyle(fontSize: 12, fontFamily: 'Urbanist', fontWeight: FontWeight.normal, color: Color(0xff353B50), letterSpacing: -0.2),
                                                                                      maxLines: 1,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            )
                                                                  : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                          : Center(
                              child: Text(
                                  dataToRemove != null && dataToRemove == 'C'
                                      ? 'There are no past trips.'
                                      : 'There are no cancelled trips.')),
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new CircularProgressIndicator(strokeWidth: 2.5)
                        ],
                      ),
                    );
            }));

//     return Scaffold(
//         backgroundColor: Colors.white,
//
//         appBar: new AppBar(
//           leading: new IconButton(
//             icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           title: Text('Past trips',
//             style: TextStyle(
//               fontFamily: 'Urbanist',
//               fontSize: 16,
//               color: Color(0xff371D32),
//             ),
//           ),
//           centerTitle: true,
//           elevation: 0.0,
//         ),
//
//         body: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Container(
//               color: Colors.white,
//               height: MediaQuery.of(context).size.height * .85,
//               child: _pastTripsData.length >= 0 ? ListView.builder(
//                 scrollDirection: Axis.vertical,
//                 shrinkWrap: false,
//                 itemCount: _pastTripsData.length,
//                 itemBuilder: (context, index) {
//                   return GestureDetector(
//                     onTap: () {
//                       if (_pastTripsData[index]['TripStatus'] == 'Cancelled') {
//                         Navigator.pushNamed(context, '/trips_cancelled_details',
//                             arguments: _pastTripsData[index]);
//                       } else if (_pastTripsData[index]['TripStatus'] == 'Cancelled' &&
//                           _pastTripsData[index]['TripStatus']['tripType'] == 'Swap')
//                       {
//                         Navigator.pushNamed(context, '/trips_cancelled_details',
//                             arguments: _pastTripsData[index]
//                           );
//                       } else if ( _pastTripsData[index]['TripStatus']['TripType'] == 'Swap') {
//                         Navigator.pushNamed(context, '/trips_rental_details_ui',
//                           arguments: {
//                             'tripType':  _pastTripsData[index]['TripStatus']['TripType'],
//                             'trip':  _pastTripsData[index]
//                           },
//                         );
//                       } else if ( _pastTripsData[index]['GuestUserId'] == userID) {
//                         Navigator.pushNamed(context,
// //                                 '/trips_rental_details',
//                           '/trips_rental_details_ui',
//                           arguments: {
//                             'tripType':  _pastTripsData[index]['TripStatus']['TripType'],
//                             'trip': _pastTripsData[index]
//                           },
//                         );
//                       } else if ( _pastTripsData[index]['HostUserId'] == userID) {
//                         Navigator.pushNamed(
//                             context, '/trips_rent_out_details_ui',
//                             arguments: {
//                               'tripType': _pastTripsData[index]['TripStatus']['TripType'],
//                               'trip': _pastTripsData[index]
//                             });
//                       }
//                     },
//                     child: Container(
//                       width: 345,
//                       height: 320,
//                       margin: EdgeInsets.only(bottom: 10.0),
//                       decoration: BoxDecoration(
//                         color: Color(0xffFFFFFF),
//                         shape: BoxShape.rectangle,
//                         border: Border.all(width: 1, color: Color(0xffE0E0E0)),
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//
//                       child: Column(
//                         children: <Widget>[
//                           Stack(
//                             children: <Widget>[
//                               ClipRRect(
//                                 borderRadius: BorderRadius.only(
//                                     topLeft: Radius.circular(12),
//                                     topRight: Radius.circular(12)
//                                 ),
//                                 child:
//                                 // Image(
//                                 //   height: 225,
//                                 //   width: double.infinity,
//                                 //   image: NetworkImage(carID[index]),
//                                 //   fit: BoxFit.fill,
//                                 // ),
//                                 Image(
//                                   fit: BoxFit.fill,
//                                   height: 225,
//                                   width: double.infinity,
//                                   image: (_pastTripsData[index]['CarImageID'] == null || _pastTripsData[index]['CarImageID'] == '')
//                                       ? AssetImage('images/car-placeholder.png')
//                                       : NetworkImage('$storageServerUrl/${_pastTripsData[index]['CarImageID']}'
//                                   ),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 10,
//                                 left: 15,
//                                 child: Container(
//                                   height: 25,
//                                   width: 80,
//                                   decoration: BoxDecoration(
//                                       color: Color(0xffFFFFFF),
//                                       borderRadius: BorderRadius.circular(8),
//                                       shape: BoxShape.rectangle
//                                   ),
//                                   child: Center(
//                                     child: Text(_pastTripsData[index]['TripType'],
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           color:Color(0xff353B50),
//                                           fontFamily: 'SFProDisplay',
//                                           fontWeight: FontWeight.bold
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//
//                               _pastTripsData[index]['TripStatus']=='Cancelled'?Positioned(
//                                 bottom: 10,
//                                 left: 100,
//                                 child: Container(
//                                   height: 25,
//                                   width: 100,
//                                   decoration: BoxDecoration(
//                                       color: _pastTripsData[index]['TripStatus']=='Cancelled'?Color(0xffF55A51):Color(0xffFFFFFF),
//                                       borderRadius: BorderRadius.circular(8),
//                                       shape: BoxShape.rectangle
//                                   ),
//                                   child: Center(
//                                     child: Text(_pastTripsData[index]['TripStatus'].toUpperCase(),
//                                       style: TextStyle(
//                                           fontSize: 12,
//                                           color: _pastTripsData[index]['TripStatus']=='Cancelled'? Color(0xffFFFFFF):Color(0xff353B50),
//                                           fontFamily: 'SFProDisplay',
//                                           fontWeight: FontWeight.bold
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ):Container(),
//
//                               // Positioned(
//                               //     bottom: 10,
//                               //     left: 15,
//                               //     child: Container(
//                               //       height: 25,
//                               //       width: 80,
//                               //       decoration: BoxDecoration(
//                               //           color: Color(0xffFFFFFF),
//                               //           borderRadius: BorderRadius.circular(8),
//                               //           shape: BoxShape.rectangle),
//                               //       child: Center(
//                               //         child: Text(
//                               //           _pastTripsData[index] == 'Rental'
//                               //               ? 'RENTAL'
//                               //               : _pastTripsData[index] == 'Rental out'
//                               //                   ? 'RENT OUT'
//                               //                   : 'Swap',
//                               //           style: TextStyle(
//                               //               fontSize: 12,
//                               //               color: Color(0xff353B50),
//                               //               fontFamily: 'SF Pro Display Bold',
//                               //               fontWeight: FontWeight.bold),
//                               //         ),
//                               //       ),
//                               //     ),
//                               //   ),
//                               // Visibility(
//                               //   visible:
//                               //       !_pastTripsData[index]['TripStatus'] == true ? false : true,
//                               //   child: Positioned(
//                               //       bottom: 10,
//                               //       left: 110,
//                               //       child: Container(
//                               //         height: 25,
//                               //         width: 90,
//                               //         decoration: BoxDecoration(
//                               //             color: Color(0xffF55A51),
//                               //             borderRadius: BorderRadius.circular(8),
//                               //             shape: BoxShape.rectangle),
//                               //         child: Center(
//                               //           child: Text(
//                               //             'CANCELLED',
//                               //             style: TextStyle(
//                               //                 fontSize: 12,
//                               //                 color: Color(0xffFFFFFF),
//                               //                 fontFamily: 'SF Pro Display Bold',
//                               //                 fontWeight: FontWeight.bold),
//                               //           ),
//                               //         ),
//                               //       )),
//                               // ),
//                             ],
//                           ),
//                           SizedBox(height: 10),
//                           Expanded(
//                             child: Column(
//                               // crossAxisAlignment: CrossAxisAlignment.start,
//                               children: <Widget>[
//                                 Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Padding(
//                                     padding: const EdgeInsets.only(left: 15),
//                                     child: Text(_pastTripsData[index]['CarName'],
//                                       style: TextStyle(
//                                         fontFamily: 'Urbanist',
//                                         fontWeight: FontWeight.w500,
//                                         color: Color(0xff371D32),
//                                         fontSize: 16,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 15),
//                                 Container(
//                                   margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                                   child: Row(
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Row(
//                                         // crossAxisAlignment: CrossAxisAlignment.center,
//                                         children: <Widget>[
//                                           Icon(
//                                             Icons.calendar_today,
//                                             color: Color(0xff353B50),
//                                             size: 20,
//                                           ),
//                                           SizedBox(width: 8),
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: <Widget>[
//                                               Text('${_pastTripsData[index]['StartDate']} to',
//                                                 style: TextStyle(
//                                                     color: Color(0xff353B50),
//                                                     fontFamily: 'Urbanist',
//                                                     fontSize: 14
//                                                 ),
//                                               ),
//                                               Text(_pastTripsData[index]['EndDate'],
//                                                 style: TextStyle(
//                                                     color: Color(0xff353B50),
//                                                     fontFamily: 'Urbanist',
//                                                     fontSize: 14
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                       Row(
//                                         // mainAxisAlignment: MainAxisAlignment.center,
//                                         children: <Widget>[
//                                           Image.asset('icons/Payout-Method.png'),
//                                           SizedBox(width: 8),
//                                           _pastTripsData[index]['TripStatus']=='Cancelled'?Text('No trip payout',
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontFamily: 'Urbanist',
//                                               color: Color(0xff353B50),
//                                             ),
//                                           ):Text('\$' + _pastTripsData[index]['Amount'].toStringAsFixed(2),
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                               fontFamily: 'Urbanist',
//                                               color: Color(0xff353B50),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//
//                                 // Row ends
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ) : Center(child: Text('No trips found')),
//             ),
//           ),
//         )
//     );
  }
}
