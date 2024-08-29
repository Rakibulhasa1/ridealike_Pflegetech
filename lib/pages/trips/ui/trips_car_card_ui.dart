import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/trips/bloc/trips_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_by_user_ids_response.dart';
import 'package:ridealike/pages/trips/response_model/trips_get_car_by_ids_response.dart';
import 'package:ridealike/widgets/sized_text.dart';
import 'package:shimmer/shimmer.dart';

class TripsCarCardUi extends StatefulWidget {
  final String? tripType;
  String? dataToRemove;
  final String? tripId;

  TripsCarCardUi({this.tripType, this.tripId, this.dataToRemove});

  @override
  _TripsCarCardUiState createState() => _TripsCarCardUiState();
}

class _TripsCarCardUiState extends State<TripsCarCardUi> {
  var tripsBloc = TripsBloc();
  String? _userID;
  var dataToRemove;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    setState(() {
      dataToRemove = widget.dataToRemove;
    });
    tripsBloc.allTripsGroupStatus(250, 0, widget.tripType).then((value) async {
      _userID = await storage.read(key: 'user_id');
      var carIds = Map<String, Car?>();
      var userIds = Map<String, Profiles>();
      for (int i = 0; i < value!.trips!.length; i++) {
        //car id Info//

        carIds[value.trips![i].carID!] = null;
        userIds[value.trips![i].hostUserID!] = Profiles();
        userIds[value.trips![i].guestUserID!] = Profiles();
        value.trips![i].userID = value.userID;
        if (value.trips![i].tripType == 'Swap') {
          carIds[value.trips![i].swapData!.myCarID!] = null;
        }
      }

      GetCarsByCarIDsResponse? carIdsResponse =
          await tripsBloc.tripGetCarData(carIds.keys.toList());
      ProfileByUserIdsResponse userIdsResponse =
          await tripsBloc.tripsGetProfileData(userIds.keys.toList());

      // carIds.clear();
      userIds.clear();

      if (carIdsResponse != null) {
        for (int i = 0; i < carIdsResponse.cars!.length; i++) {
          carIds[carIdsResponse.cars![i].iD!] = carIdsResponse.cars![i];
        }
      }
      for (int i = 0; i < userIdsResponse.profiles!.length; i++) {
        userIds[userIdsResponse.profiles![i].userID!] =
            userIdsResponse.profiles![i];
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
          value.trips![i].myCarForSwap = carIds[value.trips![i].swapData!.myCarID];
        }

        Profiles? hostUserProfile = userIds[value.trips![i].hostUserID];
        if (hostUserProfile != null) {
          value.trips![i].hostProfile = hostUserProfile;
        }

        Profiles? guestUserProfile = userIds[value.trips?[i].guestUserID];
        if (guestUserProfile != null) {
          value.trips![i].guestProfile = guestUserProfile;
        }
      }
      print("trips count befor remove :::::::${value.trips!.length}");

      value.trips!.removeWhere((element) =>
          (element.hostUserID == _userID && element.tripType == 'Swap'));
      print("trips count after remove :::::::${value.trips!.length}");
      if (widget.dataToRemove == 'C') {
        value.trips!.removeWhere((element) => element.tripStatus == "Cancelled");
      } else if (widget.dataToRemove == 'A') {
        value.trips!.removeWhere((element) => element.tripStatus != "Cancelled");
      }

      tripsBloc.changedTripGroupStatus.call(value);

      print("**********************************************");
      if (widget.tripId != null) {
        print(widget.tripId);
        goToDetails(value);
      } else {
        print("tripid null");
      }
      print("**********************************************");
    });
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return StreamBuilder<TripAllUserStatusGroupResponse>(
        stream: tripsBloc.tripGroupStatus,
        builder: (context, tripGroupStatusSnapshot) {
          /*if(tripGroupStatusSnapshot.hasData &&
              tripGroupStatusSnapshot.data != null && widget.tripId != null){
            goToDetails(tripGroupStatusSnapshot);
          }*/
          return tripGroupStatusSnapshot.hasData &&
                  tripGroupStatusSnapshot.data != null
              ? Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height,
                  child: tripGroupStatusSnapshot.data!.trips!.length != 0
                      ? ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: false,
                          itemCount: tripGroupStatusSnapshot.data!.trips!.length,
                          itemBuilder: (context, index) {
//              Trips trip = widget.tripsToShow[index];
                            return GestureDetector(
                              onTap: () {
                                //route with car model
                                if (tripGroupStatusSnapshot
                                        .data!.trips![index].tripStatus ==
                                    'Cancelled') {
                                  Navigator.pushNamed(
                                      context, '/trips_cancelled_details',
                                      arguments: tripGroupStatusSnapshot
                                          .data!.trips![index]);
                                } else if (tripGroupStatusSnapshot
                                            .data!.trips![index].tripStatus ==
                                        'Cancelled' &&
                                    tripGroupStatusSnapshot
                                            .data!.trips![index].tripType ==
                                        'Swap') {
                                  Navigator.pushNamed(
                                      context, '/trips_cancelled_details',
                                      arguments: tripGroupStatusSnapshot
                                          .data!.trips![index]);
                                } else if (tripGroupStatusSnapshot
                                        .data!.trips![index].tripType ==
                                    'Swap') {
                                  Navigator.pushNamed(
                                    context,
                                    '/trips_rental_details_ui',
                                    arguments: {
                                      'tripType': widget.tripType,
                                      'trip': tripGroupStatusSnapshot
                                          .data!.trips![index]
                                    },
                                  );
                                } else if (tripGroupStatusSnapshot
                                        .data!.trips![index].guestUserID ==
                                    tripGroupStatusSnapshot.data!.userID) {
                                  Navigator.pushNamed(
                                    context,
//                                 '/trips_rental_details',
                                    '/trips_rental_details_ui',
                                    arguments: {
                                      'tripType': widget.tripType,
                                      'trip': tripGroupStatusSnapshot
                                          .data!.trips![index]
                                    },
                                  );
                                } else if (tripGroupStatusSnapshot
                                        .data!.trips![index].hostUserID ==
                                    tripGroupStatusSnapshot.data!.userID) {
                                  Navigator.pushNamed(
                                      context, '/trips_rent_out_details_ui',
                                      arguments: {
                                        'tripType': widget.tripType,
                                        'trip': tripGroupStatusSnapshot
                                            .data!.trips![index]
                                      });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 10, bottom: 8),
                                child: Card(
                                  elevation: 0.0,
                                  shape: RoundedRectangleBorder(
                                    side: new BorderSide(
                                        color: Colors.grey, width: .5),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  child: ConstrainedBox(
                                    constraints: tripGroupStatusSnapshot
                                                .data!.trips![index].car ==
                                            null
                                        ? BoxConstraints(
                                            minHeight: 80,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3.45,
                                            maxHeight: 130)
                                        : BoxConstraints(
                                            minHeight: 290,
                                            maxWidth: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                3.45,
                                            maxHeight: 300),
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
                                                height: tripGroupStatusSnapshot
                                                            .data!
                                                            .trips![index]
                                                            .car ==
                                                        null
                                                    ? 50
                                                    : 210,
                                                width: double.infinity,
                                                child: (tripGroupStatusSnapshot
                                                                .data!
                                                                .trips![index]
                                                                .carImageId ==
                                                            null ||
                                                        tripGroupStatusSnapshot
                                                                .data!
                                                                .trips![index]
                                                                .carImageId ==
                                                            '')
                                                    ? Container()
                                                    : Image.network(
                                                        '$storageServerUrl/${tripGroupStatusSnapshot.data!.trips![index].carImageId}',
                                                        fit: BoxFit.cover,
                                                      ),
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 10,
                                              left: 15,
                                              child: Container(
                                                height: 25,
                                                width: deviceWidth * 0.25,
                                                decoration: BoxDecoration(
                                                    color:
                                                        tripGroupStatusSnapshot
                                                                    .data!
                                                                    .trips![
                                                                        index]
                                                                    .car ==
                                                                null
                                                            ? Colors.black12
                                                            : Color(0xffFFFFFF),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                    shape: BoxShape.rectangle),
                                                child: Center(
                                                  child: SizedText(
                                                      deviceWidth: deviceWidth,
                                                      textWidthPercentage: 0.3,
                                                      text: tripGroupStatusSnapshot
                                                                  .data!
                                                                  .trips![index]
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
                                                      fontSize: 12,
                                                      textColor:
                                                          Color(0xff353B50),
                                                      fontFamily:
                                                          'Urbanist'),
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: tripGroupStatusSnapshot
                                                          .data!
                                                          .trips![index]
                                                          .tripStatus ==
                                                      'Cancelled'
                                                  ? true
                                                  : false,
                                              child: Positioned(
                                                bottom: 10,
                                                left: 120,
                                                child: Container(
                                                  height: 25,
                                                  width: deviceWidth * 0.3,
                                                  decoration: BoxDecoration(
                                                      color: Color(0xffF55A51),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      shape:
                                                          BoxShape.rectangle),
                                                  child: Center(
                                                    child: SizedText(
                                                        deviceWidth:
                                                            deviceWidth,
                                                        textWidthPercentage:
                                                            0.35,
                                                        text: 'CANCELLED',
                                                        fontSize: 12,
                                                        textColor:
                                                            Color(0xffFFFFFF),
                                                        fontFamily:
                                                            'Urbanist'),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        tripGroupStatusSnapshot
                                                    .data!.trips![index].car ==
                                                null
                                            ? SizedBox()
                                            : SizedBox(height: 5),
                                        // vehicle content
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              // car name //
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15, top: 8),
                                                  child: Text(
                                                    (tripGroupStatusSnapshot
                                                                        .data!
                                                                        .trips![
                                                                            index]
                                                                        .car ==
                                                                    null &&
                                                                tripGroupStatusSnapshot
                                                                        .data!
                                                                        .trips![
                                                                            index]
                                                                        .car ==
                                                                    null &&
                                                                tripGroupStatusSnapshot
                                                                        .data!
                                                                        .trips![
                                                                            index]
                                                                        .car ==
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
                                                        ? 'Deleted Car'
                                                        : tripGroupStatusSnapshot
                                                                .data!
                                                                .trips![index]
                                                                .car!
                                                                .about!
                                                                .year! +
                                                            ' ' +
                                                            tripGroupStatusSnapshot
                                                                .data!
                                                                .trips![index]
                                                                .car!
                                                                .about!
                                                                .make! +
                                                            ' ' +
                                                            tripGroupStatusSnapshot
                                                                .data!
                                                                .trips![index]
                                                                .car!
                                                                .about!
                                                                .model!,
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: Color(0xff371D32),
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15, right: 4),
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
                                                          SizedBox(width: 8),
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
                                                      SizedBox(width: 18),
                                                      //guest user//
                                                      tripGroupStatusSnapshot
                                                                  .data!
                                                                  .trips![index]
                                                                  .guestUserID ==
                                                              tripGroupStatusSnapshot
                                                                  .data!.userID
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
                                                                  children: <
                                                                      Widget>[
                                                                    Icon(
                                                                        Icons
                                                                            .payment,
                                                                        color: Color(
                                                                            0xFF3C2235)),
                                                                    SizedBox(
                                                                        width:
                                                                            5),
                                                                    SizedText(
                                                                      deviceWidth:
                                                                          deviceWidth,
                                                                      textWidthPercentage:
                                                                          0.18,
                                                                      text: tripGroupStatusSnapshot.data!.trips![index].tripStatus == 'Cancelled' &&
                                                                              (tripGroupStatusSnapshot.data!.trips![index].cancellationFee != null && tripGroupStatusSnapshot.data!.trips![index].cancellationFee!.refund != null)
                                                                          ? '\$${tripGroupStatusSnapshot.data!.trips![index].cancellationFee!.refund!.toStringAsFixed(2).replaceAll("-", "")}'
                                                                          : '\$0.00',
                                                                      fontSize:
                                                                          14,
                                                                      fontFamily:
                                                                          'Urbanist',
                                                                      textColor:
                                                                          Color(
                                                                              0xff353B50),
                                                                    ),
                                                                  ],
                                                                )
                                                              : tripGroupStatusSnapshot
                                                                          .data!
                                                                          .tripStatusGroup ==
                                                                      'Past'
                                                                  ? Row(
                                                                      children: <
                                                                          Widget>[
                                                                        Icon(
                                                                            Icons
                                                                                .payment,
                                                                            color:
                                                                                Color(0xFF3C2235)),
                                                                        SizedBox(
                                                                            width:
                                                                                5),
                                                                        SizedText(
                                                                          deviceWidth:
                                                                              deviceWidth,
                                                                          textWidthPercentage:
                                                                              0.17,
                                                                          text:
                                                                              '\$${tripGroupStatusSnapshot.data!.trips![index].guestTotal!.toStringAsFixed(2).replaceAll("-", "")}',
                                                                          fontSize:
                                                                              14,
                                                                          fontFamily:
                                                                              'Urbanist',
                                                                          textColor:
                                                                              Color(0xff353B50),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : tripGroupStatusSnapshot
                                                                              .data!
                                                                              .trips![
                                                                                  index]
                                                                              .tripType ==
                                                                          'Swap'
                                                                      ? Row(
                                                                          children: <
                                                                              Widget>[
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
                                                                            Container(
                                                                              constraints: BoxConstraints(
                                                                                maxWidth: MediaQuery.of(context).size.width * 0.25,
                                                                              ),
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
                                                                          ],
                                                                        )
                                                                      : Expanded(
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.center,
                                                                            children: <Widget>[
                                                                              Icon(Icons.location_on, color: Color(0xff353B50), size: 20),
                                                                              SizedBox(width: 8),
                                                                              SizedText(
                                                                                deviceWidth: deviceWidth,
                                                                                textWidthPercentage: 0.17,
                                                                                maxLines: 3,
                                                                                textOverflow: TextOverflow.ellipsis,
                                                                                text: '${tripGroupStatusSnapshot.data!.trips![index].returnLocation!=null?tripGroupStatusSnapshot.data!.trips![index].returnLocation!.formattedAddress:tripGroupStatusSnapshot.data!.trips![index].location!.address}',
                                                                                fontSize: 14,
                                                                                textColor: Color(0xff353B50),
                                                                                fontFamily: 'Urbanist',
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        )
                                                          //host user//
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
                                                                      children: <
                                                                          Widget>[
                                                                        Image.asset(
                                                                            'icons/Payout-Method.png'),
                                                                        SizedBox(
                                                                            width:
                                                                                8),
                                                                        Container(
                                                                          constraints:
                                                                              BoxConstraints(
                                                                            maxWidth:
                                                                                MediaQuery.of(context).size.width * 0.25,
                                                                          ),
                                                                          child: SizedText(
                                                                              deviceWidth: deviceWidth,
                                                                              textWidthPercentage: 0.15,
                                                                              text: tripGroupStatusSnapshot.data!.trips![index].tripStatus == 'Cancelled' && tripGroupStatusSnapshot.data!.trips![index].hostTotal! > 0.0 ? '\$${tripGroupStatusSnapshot.data!.trips![index].hostTotal!.toStringAsFixed(2).replaceAll("-", "")}' : 'No trip earnings',
                                                                              // :
                                                                              //
                                                                              // tripGroupStatusSnapshot.data!.trips![index].cancellationFee!=null &&
                                                                              //     tripGroupStatusSnapshot.data!.trips![index].cancellationFee.whoCancelled=='Guest'?
                                                                              //
                                                                              //   tripGroupStatusSnapshot.data!.trips![index].cancellationFee.cancellationProfit!=null &&
                                                                              //     tripGroupStatusSnapshot.data!.trips![index].cancellationFee.cancellationProfit.whoGained=='Guest'?
                                                                              //   'No trip earnings':'\$${tripGroupStatusSnapshot.data!.trips![index].cancellationFee.cancellationProfit.ammount.toStringAsFixed(2).replaceAll("-", "")}'
                                                                              //
                                                                              //   : tripGroupStatusSnapshot.data!.trips![index].tripStatus == 'Cancelled'&& tripGroupStatusSnapshot.data!.trips![index].cancellationFee!=null &&
                                                                              //     tripGroupStatusSnapshot.data!.trips![index].cancellationFee.whoCancelled=='Host'
                                                                              //     && tripGroupStatusSnapshot.data!.trips![index].cancellationFee.cancellationFee!=null ?
                                                                              // '\$${tripGroupStatusSnapshot.data!.trips![index].cancellationFee.cancellationFee.toStringAsFixed(2).replaceAll("-", "")}':'No trip earnings':
                                                                              //     tripGroupStatusSnapshot.data!.trips![index].tripType == 'Swap'
                                                                              //         ? '\$${tripGroupStatusSnapshot.data!.trips![index].hostTotal.toStringAsFixed(2)}'
                                                                              //         : '',
                                                                              fontSize: 14,
                                                                              fontFamily: 'Open Sans Regular',
                                                                              textColor: Color(0xff353B50)),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : tripGroupStatusSnapshot
                                                                              .data!
                                                                              .tripStatusGroup ==
                                                                          'Past'
                                                                      ? Row(
                                                                          children: <
                                                                              Widget>[
                                                                            Image.asset('icons/Payout-Method.png'),
                                                                            SizedBox(width: 8),
                                                                            SizedText(
                                                                              deviceWidth: deviceWidth,
                                                                              textWidthPercentage: 0.17,
                                                                              text: '\$${tripGroupStatusSnapshot.data!.trips![index].hostTotal!.toStringAsFixed(2).replaceAll("-", "")}',
                                                                              fontSize: 14,
                                                                              fontFamily: 'Open Sans Regular',
                                                                              textColor: Color(0xff353B50),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      : Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: <
                                                                              Widget>[
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.circular(12),
                                                                              child: Image(
                                                                                height: 20,
                                                                                width: 20,
                                                                                fit: BoxFit.cover,
                                                                                image: tripGroupStatusSnapshot.data?.trips?[index].guestProfile!.imageID == null ||
                                                                                    tripGroupStatusSnapshot.data!.trips![index].guestProfile!.imageID == ''
                                                                                    ? AssetImage('images/user.png') as ImageProvider<Object>
                                                                                    : NetworkImage('$storageServerUrl/${tripGroupStatusSnapshot.data!.trips![index].guestProfile!.imageID}'),
                                                                                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                                  return Image.asset('images/user.png',width: 20,height: 20,fit: BoxFit.cover,);
                                                                                },
                                                                              )
                                                                              // Image(
                                                                              // height: 20,
                                                                              // width: 20,
                                                                              // fit: BoxFit.cover,
                                                                              // image: (tripGroupStatusSnapshot.data!.trips![index].guestProfile.imageID == null || tripGroupStatusSnapshot.data!.trips![index].guestProfile.imageID == '') ? AssetImage('images/user.png') : NetworkImage('$storageServerUrl/${tripGroupStatusSnapshot.data!.trips![index].guestProfile.imageID}'),

                                                                            ),
                                                                            SizedBox(width: 8),
                                                                            SizedText(
                                                                              deviceWidth: deviceWidth,
                                                                              textWidthPercentage: 0.18,
                                                                              text: '${tripGroupStatusSnapshot.data!.trips![index].guestProfile!.firstName} ${tripGroupStatusSnapshot.data!.trips![index].guestProfile!.lastName}',
                                                                              fontSize: 12,
                                                                              fontFamily: 'Urbanist',
                                                                              textColor: Color(0xff353B50),
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
                          child:
                              widget.tripType == 'Past' && dataToRemove == 'C'
                                  ? Text('There are no past trips')
                                  : Text(widget.tripType == 'Upcoming'
                                      ? 'There are no upcoming trips booked.'
                                      : widget.tripType == 'Current'
                                          ? 'There are no current trips.'
                                          : 'There are no cancelled trips.')),
                )
              : Center(
                  child: ListView(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [  SizedBox(
                          height: 15,
                        ),
                          SizedBox(
                            height: 220,
                            width: MediaQuery.of(context).size.width,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey[300] ?? Colors.grey, // Provide a default color if null
                                highlightColor: Colors.grey[100] ?? Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 16),
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
                                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 14,
                                width: MediaQuery.of(context).size.width / 4,
                                child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 220,
                            width: MediaQuery.of(context).size.width,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 16),
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
                                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 14,
                                width: MediaQuery.of(context).size.width / 4,
                                child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 220,
                            width: MediaQuery.of(context).size.width,
                            child: Shimmer.fromColors(
                                  baseColor: Colors.grey[300] ?? Colors.grey,
  highlightColor: Colors.grey[100] ?? Colors.grey,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 16),
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
                                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )),
                              ),
                              SizedBox(
                                height: 14,
                                width: MediaQuery.of(context).size.width / 4,
                                child: Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )),
                              ),
                            ],
                          ),

                          SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            height: 220,
                            width: MediaQuery.of(context).size.width,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 16.0, right: 16),
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
                                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )),
                              ),
                              // SizedBox(
                              //   height: 15,
                              //   width: MediaQuery.of(context).size.width / 4,
                              //   child: Shimmer.fromColors(
                              //       baseColor: Colors.grey.shade300,
                              //       highlightColor: Colors.grey.shade100,
                              //       child: Padding(
                              //         padding: const EdgeInsets.only(left: 16.0, right: 16),
                              //         child: Container(
                              //           decoration: BoxDecoration(
                              //               color: Colors.grey[300],
                              //               borderRadius: BorderRadius.circular(10)),
                              //         ),
                              //       )),
                              // ),
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
                                  padding: const EdgeInsets.only(left: 16.0, right: 16),
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
                                      padding: const EdgeInsets.only(left: 16.0, right: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(10)),
                                      ),
                                    )),
                              ),
                              // SizedBox(
                              //   height: 15,
                              //   width: MediaQuery.of(context).size.width / 4,
                              //   child: Shimmer.fromColors(
                              //       baseColor: Colors.grey.shade300,
                              //       highlightColor: Colors.grey.shade100,
                              //       child: Padding(
                              //         padding: const EdgeInsets.only(left: 16.0, right: 16),
                              //         child: Container(
                              //           decoration: BoxDecoration(
                              //               color: Colors.grey[300],
                              //               borderRadius: BorderRadius.circular(10)),
                              //         ),
                              //       )),
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: 8,
                          ),

                        ],
                      ),
                    ],
                  ),
                );
        });
  }

  void showMessages(TripAllUserStatusGroupResponse tripGroupStatusSnapshot) {
    var value;
    int index = tripGroupStatusSnapshot.trips!
        .indexWhere((element) => element.tripID == widget.tripId);
    if (tripGroupStatusSnapshot.trips![index].tripStatus == 'Cancelled') {
      if (tripGroupStatusSnapshot.trips![index].cancellationFee != null &&
          tripGroupStatusSnapshot.trips![index].cancellationFee!.whoCancelled ==
              'Guest') {
        if (tripGroupStatusSnapshot
                    .trips![index].cancellationFee!.cancellationProfit !=
                null &&
            tripGroupStatusSnapshot.trips![index].cancellationFee!
                    .cancellationProfit!.whoGained ==
                'Guest') {
          value = 'No trip earnings';
          return value;
        } else {
          if (tripGroupStatusSnapshot.trips![index].cancellationFee!
                      .cancellationProfit!.whoGained ==
                  'Host' &&
              tripGroupStatusSnapshot.trips![index].cancellationFee!
                      .cancellationProfit!.ammount !=
                  null) {
            value =
                '\$${tripGroupStatusSnapshot.trips![index].cancellationFee!.cancellationProfit!.ammount!.toStringAsFixed(2).replaceAll("-", "")}';
          }
        }
      } else {
        if (tripGroupStatusSnapshot.trips![index].cancellationFee!.whoCancelled ==
                'Host' &&
            tripGroupStatusSnapshot
                    .trips![index].cancellationFee!.cancellationFee !=
                null &&
            tripGroupStatusSnapshot
                    .trips![index].cancellationFee!.cancellationFee !=
                '') {
          value =
              '\$${tripGroupStatusSnapshot.trips![index].cancellationFee!.cancellationFee!.toStringAsFixed(2).replaceAll("-", "")}';
        }
        return value;
      }
    }
  }

  void goToDetails(TripAllUserStatusGroupResponse tripGroupStatusSnapshot) {
    print("**********************************************");
    int index = tripGroupStatusSnapshot.trips!
        .indexWhere((element) => element.tripID == widget.tripId);
    print(index);
    print("**********************************************");
    if (tripGroupStatusSnapshot.trips![index].tripStatus == 'Cancelled') {
      Navigator.pushNamed(context, '/trips_cancelled_details',
          arguments: tripGroupStatusSnapshot.trips![index]);
    } else if (tripGroupStatusSnapshot.trips![index].tripStatus == 'Cancelled' &&
        tripGroupStatusSnapshot.trips![index].tripType == 'Swap') {
      Navigator.pushNamed(context, '/trips_cancelled_details',
          arguments: tripGroupStatusSnapshot.trips![index]);
    } else if (tripGroupStatusSnapshot.trips![index].tripType == 'Swap') {
      Navigator.pushNamed(
        context,
        '/trips_rental_details_ui',
        arguments: {
          'tripType': widget.tripType,
          'trip': tripGroupStatusSnapshot.trips![index]
        },
      );
    } else if (tripGroupStatusSnapshot.trips![index].guestUserID ==
        tripGroupStatusSnapshot.userID) {
      Navigator.pushNamed(
        context,
//                                 '/trips_rental_details',
        '/trips_rental_details_ui',
        arguments: {
          'tripType': widget.tripType,
          'trip': tripGroupStatusSnapshot.trips![index]
        },
      );
    } else if (tripGroupStatusSnapshot.trips![index].hostUserID ==
        tripGroupStatusSnapshot.userID) {
      Navigator.pushNamed(context, '/trips_rent_out_details_ui', arguments: {
        'tripType': widget.tripType,
        'trip': tripGroupStatusSnapshot.trips![index]
      });
    }
  }
}
