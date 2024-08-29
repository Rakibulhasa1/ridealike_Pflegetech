import 'dart:convert';

import 'package:async_builder/async_builder.dart';
import 'package:conditioned/conditioned.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/messages/models/swap.dart';
import 'package:ridealike/pages/trips/bloc/trips_bloc.dart';
import 'package:ridealike/pages/trips/request_service/request_reimbursement.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_by_user_ids_response.dart';
import 'package:ridealike/pages/trips/response_model/trips_get_car_by_ids_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

import '../loadingview.dart';
import 'swapController.dart';

class SwapView extends StatefulWidget {
  final Swap swap;
  final VoidCallback onClicked;

  const SwapView({Key? key, required this.swap, required this.onClicked})
      : super(key: key);

  @override
  _SwapViewState createState() => _SwapViewState(this.swap, this.onClicked);
}

class _SwapViewState extends StateMVC<SwapView> {
 SwapController? _con;
  final storage = new FlutterSecureStorage();
  var tripsBloc = TripsBloc();
  bool _mapClick = false;
  bool _hasCard = false;


  _SwapViewState(Swap swap, VoidCallback onClicked) : super(SwapController()) {
    _con = controller as SwapController;
    _con!.swap = swap;
    _con!.onClicked = onClicked;
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Swap"});
  }

  @override
  Widget build(BuildContext context) {
    return _swapBuilder();
  }

  Widget _swapBuilder() {
    return AsyncBuilder<Swap>(
      future: _con!.getCardData() as Future<Swap>?,
      waiting: (context) => _swapLoading(),
      builder: (context, value) => _swapView(value!),
      error: (context, error, stackTrace) => _swapError(),
    );
  }

  Widget _swapError() {
    return Container(
      margin: EdgeInsets.all(10),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(20),
          child: Text(
            "Error Loading Swap Info",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _swapLoading() {
    return Container(
      margin: EdgeInsets.all(
        10,
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          margin: EdgeInsets.all(20),
          child: LoadingView(),
        ),
      ),
    );
  }

  Widget _swapView(Swap swap) {
    return Conditioned(
      cases: [
        Case(
          swap.status == "Agreed",
          builder: () => _swapViewAgreed(swap),
        ),
        Case(
          swap.status == "Suggested" && swap.suggestedByUserID == _con!.userId,
          builder: () => _swapViewRearrange(swap),
        ),
        Case(
          swap.status == "Suggested" && swap.suggestedByUserID != _con!.userId,
          builder: () => _swapViewReview(swap),
        ),
        Case(
          swap.status == "SwapAgreementStatusUndefined" ||
              swap.status == "SwapAgreementStatusNone",
          builder: () => _swapViewArrange(swap),
        ),
      ],
      defaultBuilder: () => Container(),
    );
  }

  Widget _swapViewAgreed(Swap swap) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: 10,
      ),
      child: GestureDetector(
        onTap: () async {
          print('SwapTripId${swap.tripId}');
          String? userID = await storage.read(key: 'user_id');
          if (!_mapClick) {
            _mapClick = true;
            var response = await getTripByID(swap.tripId!);
            Trips trips;
            if (response != null && response.statusCode == 200) {
              trips = Trips.fromJson(json.decode(response.body!)['Trip']);

            } else {
              return null;
            }

            var carIds = Map<String, Car>();
            var userIds = Map<String, Profiles>();
            for (int i = 0; i < 1; i++) {
              //car id Info//

              carIds[trips.carID!] = Car();
              userIds[trips.hostUserID!] = Profiles();
              userIds[trips.guestUserID!] = Profiles();
              trips.userID = userID;
              if (trips.tripType == 'Swap') {
                carIds[trips.swapData!.myCarID!] = Car();
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

            for (int i = 0; i < 1; i++) {
              //car id Info//
              Car? cars = carIds[trips.carID];
              if (cars != null) {
                trips.car = cars;
                trips.carName = cars.name;
                trips.carImageId = cars.imagesAndDocuments!.images!.mainImageID;
                trips.carLicense = cars.imagesAndDocuments!.license!.plateNumber;
                trips.carYear = cars.about!.year;
                trips.car!.about!.make = cars.about!.make;
                trips.car!.about!.model = cars.about!.model;
              }

              if (trips.tripType == 'Swap') {
                trips.myCarForSwap = carIds[trips.swapData!.myCarID];
              }

              Profiles? hostUserProfile = userIds[trips.hostUserID];
              if (hostUserProfile != null) {
                trips.hostProfile = hostUserProfile;
              }

              Profiles? guestUserProfile = userIds[trips.guestUserID];
              if (guestUserProfile != null) {
                trips.guestProfile = guestUserProfile;
              }
            }

            var tripType = trips.tripStatus == 'Booked'
                ? 'Upcoming'
                : trips.tripStatus == 'Started'
                    ? 'Current'
                    : (trips.tripStatus == 'Ended' ||
                            trips.tripStatus == 'Completed')
                        ? 'Past'
                        : trips.tripStatus == 'Cancelled'
                            ? 'Past'
                            : '';

            if (trips.tripStatus == 'Cancelled') {
              Navigator.pushNamed(context, '/trips_cancelled_details',
                  arguments: trips);
            } else if (trips.tripStatus == 'Cancelled' &&
                trips.tripType == 'Swap') {
              Navigator.pushNamed(context, '/trips_cancelled_details',
                  arguments: trips);
            } else if (trips.tripType == 'Swap') {
              Navigator.pushNamed(
                context,
                '/trips_rental_details_ui',
                arguments: {'tripType': tripType, 'trip': trips},
              );
            } else if (trips.guestUserID == trips.userID) {
              Navigator.pushNamed(
                context,
                '/trips_rental_details_ui',
                arguments: {'tripType': tripType, 'trip': trips},
              );
            } else if (trips.hostUserID == trips.userID) {
              Navigator.pushNamed(context, '/trips_rent_out_details_ui',
                  arguments: {'tripType': tripType, 'trip': trips});
            }
          }
        },
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            margin: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  swap.header.toString(),
                  style: TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                Container(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Text(
                        swap.title.toString(),
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          Icons.navigate_next,
                          size: 35,
                        ),
                      ),
                    )
                  ],
                ),
                Container(
                  height: 10,
                ),
                Row(
                  children: [
                    Icon(Icons.event),
                    Container(
                      width: 5,
                    ),
                    Expanded(
                      child:
                      Text(
                        DateFormat('EEE MMM dd, yyyy hh:00 a').format(swap.startDate as DateTime) +
                            " - " +
                            DateFormat('EEE MMM dd, yyyy hh:00 a').format(swap.endDate as DateTime),
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),

                      // Text(
                      //   DateUtils.instance.formatSwapDate(swap.startDate) +
                      //       " - " +
                      //       DateUtils.instance.formatSwapDate(swap.endDate),
                      //   style: TextStyle(
                      //     color: Colors.black54,
                      //   ),
                      // ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _swapViewArrange(Swap swap) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: 10,
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SWAP OPPORTUNITY',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Text(
                      swap.title.toString(),
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                swap.message.toString(),
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Container(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xffFF8F68),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),),
                  onPressed:swap.userVerificationStatus== "Undefined"?null : () async {
                    _hasCard = await _con!.fetchCardInfo(context);
                    if (_hasCard) {
                      AppEventsUtils.logEvent("swap_arrange_terms");
                      var arguments = {
                        "SwapAgreementID": swap.agreementId,
                        "UserID": await storage.read(key: 'user_id'),
                        "InsuranceType": swap.insurance,
                        "Address": swap.myAddress,
                        "Latitude": swap.myLat,
                        "Longitude": swap.myLon
                      };
                      Navigator.pushNamed(context, '/swap_arrange_terms',
                          arguments: arguments);
                    } else {
                      _hasCard = await _con!.handleShowAddCardModal(context);
                      if (_hasCard) {
                        AppEventsUtils.logEvent("swap_arrange_terms");
                        var arguments = {
                          "SwapAgreementID": swap.agreementId,
                          "UserID": await storage.read(key: 'user_id'),
                          "InsuranceType": swap.insurance,
                          "Address": swap.myAddress,
                          "Latitude": swap.myLat,
                          "Longitude": swap.myLon
                        };
                        Navigator.pushNamed(context, '/swap_arrange_terms',
                            arguments: arguments);
                      }
                    }
                  },

                  child: Container(
                    margin: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Text(
                      swap.userVerificationStatus== "Undefined"?"CAR NO LONGER AVAILABLE":
                      "Arrange Terms",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swapViewRearrange(Swap swap) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: 10,
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SWAP OPPORTUNITY',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: Text(
                      swap.title!,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                swap.message!,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'icons/Calendar_Manage-Calendar.png',
                          color: Color(
                            0xff371D32,
                          ),
                          height: 20,
                          width: 18,
                        ),
                        Container(
                          width: 5,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM d, hh:00 a').format(
                                    DateTime.parse(swap.startDate!).toLocal()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                DateFormat('MMM d, hh:00 a').format(
                                    DateTime.parse(swap.endDate!).toLocal()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        Container(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            swap.address!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                height: 5,
              ),
              Row(
                children: [
                  Image.asset('icons/Payout-Method.png'),
                  Container(
                    width: 5,
                  ),
                  swap.total! < 0
                      ? Text(
                          'Net trip cost: ' +
                              NumberFormat.simpleCurrency()
                                  .format(swap.total)
                                  .toString()
                                  .replaceAll("-", ""),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        )
                      : Text(
                          "Net Trip Income: " +
                              NumberFormat.simpleCurrency()
                                  .format(swap.total)
                                  .toString()
                                  .replaceAll("-", ""),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                ],
              ),
              Container(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),),
                  onPressed: swap.userVerificationStatus== "Undefined"?null: () async {
                    _hasCard = await _con!.fetchCardInfo(context);
                    if (_hasCard) {
                      AppEventsUtils.logEvent("swap_rearrange_terms");
                      var arguments = {
                        "_swapAgreementID": swap.agreementId,
                        "_userID": await storage.read(key: 'user_id'),
                        "_startDateTime": swap.startDate,
                        "_endDateTime": swap.endDate,
                        "_locationAddress": swap.address,
                        "_insuranceType": swap.insurance,
                        "_locationLat": swap.lat,
                        "_locationLon": swap.lon
                      };

                      Navigator.pushNamed(context, '/swap_arrange_terms',
                          arguments: arguments);
                    } else {
                      _hasCard = await _con!.handleShowAddCardModal(context);
                      if (_hasCard) {
                        AppEventsUtils.logEvent("swap_rearrange_terms");
                        var arguments = {
                          "_swapAgreementID": swap.agreementId,
                          "_userID": await storage.read(key: 'user_id'),
                          "_startDateTime": swap.startDate,
                          "_endDateTime": swap.endDate,
                          "_locationAddress": swap.address,
                          "_insuranceType": swap.insurance,
                          "_locationLat": swap.lat,
                          "_locationLon": swap.lon
                        };
                        Navigator.pushNamed(context, '/swap_arrange_terms',
                            arguments: arguments);
                      }
                    }
                  },

                  child: Container(
                    margin: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          swap.userVerificationStatus== "Undefined"?"CAR NO LONGER AVAILABLE":
                          "Rearrange",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        // Spacer(),
                        // Icon(
                        //   Icons.calendar_today,
                        //   color: Colors.white,
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _swapViewReview(Swap swap) {
    return Container(
      margin: EdgeInsets.only(
        left: 10,
        right: 10,
        top: 10,
        bottom: 10,
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SWAP OPPORTUNITY',
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      swap.title!,
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Text(
                swap.message!,
                style: TextStyle(
                  color: Colors.black54,
                ),
              ),
              Container(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'icons/Calendar_Manage-Calendar.png',
                          color: Color(
                            0xff371D32,
                          ),
                          height: 20,
                          width: 18,
                        ),
                        Container(
                          width: 5,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DateFormat('MMM d, hh:00 a').format(
                                    DateTime.parse(swap.startDate!).toLocal()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                              Text(
                                DateFormat('MMM d, hh:00 a').format(
                                    DateTime.parse(swap.endDate!).toLocal()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        Icon(Icons.location_on),
                        Container(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            swap.address!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                height: 5,
              ),
              Row(
                children: [
                  Icon(Icons.credit_card),
                  Container(
                    width: 5,
                  ),
                  swap.total! < 0
                      ? Text(
                          'Net trip cost: ' +
                              NumberFormat.simpleCurrency()
                                  .format(swap.total)
                                  .toString()
                                  .replaceAll("-", ""),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        )
                      : Text(
                          "Net Trip Income: " +
                              NumberFormat.simpleCurrency()
                                  .format(swap.total)
                                  .toString()
                                  .replaceAll("-", ""),
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                ],
              ),
              Container(
                height: 10,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),),
                  onPressed:swap.userVerificationStatus== "Undefined"?null: () async {
                    _hasCard = await _con!.fetchCardInfo(context);
                    if (_hasCard) {
                      AppEventsUtils.logEvent("swap_review_terms");
                      var arguments = {
                        "SwapAgreementID": swap.agreementId,
                        "UserID": await storage.read(key: 'user_id')
                      };
                      Navigator.pushNamed(context, '/agree_with_swap_terms',
                          arguments: arguments);
                    } else {
                      _hasCard = await _con!.handleShowAddCardModal(context);
                      if (_hasCard) {
                        AppEventsUtils.logEvent("swap_review_terms");
                        var arguments = {
                          "SwapAgreementID": swap.agreementId,
                          "UserID": await storage.read(key: 'user_id')
                        };
                        Navigator.pushNamed(context, '/agree_with_swap_terms',
                            arguments: arguments);
                      }
                    }
                  },

                  child: Container(
                    margin: EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          swap.userVerificationStatus== "Undefined"?"CAR NO LONGER AVAILABLE":
                          "Review terms",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        // Spacer(),
                        // Icon(
                        //   Icons.calendar_today,
                        //   color: Colors.white,
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
