import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/book_a_car/booking_info.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/bloc/trips_rental_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/utils/size_config.dart';

import '../../../utils/app_events/app_events_utils.dart';

const headingText = TextStyle(
    fontWeight: FontWeight.w500,
    fontFamily: 'Urbanist',
    letterSpacing: 0.2,
    fontSize: 12);
const valueTextStyle = TextStyle(
  fontFamily: 'Urbanist',
  fontWeight: FontWeight.normal,
  letterSpacing: -0.2,
  color: Color(0xff353B50),
  fontSize: 14,
);
final tripsRentalBloc = TripsRentalBloc();



class TripsCancelledDetails extends StatefulWidget {
  Trips trips;
   bool? backPressPop = false;

  @override
  _TripsCancelledDetailsState createState() =>
      _TripsCancelledDetailsState(this.trips);

  TripsCancelledDetails(this.trips, {this.backPressPop});
}

class _TripsCancelledDetailsState extends State<TripsCancelledDetails> {
  var tripType;
  var bookingDetailsType;
  var profileImageId;
  var userType;
  var userName;
  var amountType;
  var paymentAmount;
  bool? swap;
  var carType;
  double? deviceHeight;
  double? deviceWidth;
  Trips trips;
  bool isDataUpToDate = false;
  final storage = new FlutterSecureStorage();
var userID;
  var cancellationFeeCredit;
  var cancellationFeeCreditValue;
  bool? backPressPop= false;
  String? verificationStatus;
  _TripsCancelledDetailsState(this.trips, {this.backPressPop});
  // bool _cardAdded;
  var _bookingInfo = {
    "carID": '',
    "userID": '',
    "location": '',
    "locAddress": '',
    "FormattedAddress": '',
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
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Trip Cancelled"});
    updateTripsData(trips.tripID!).then((value) {
      Trips tripsUpdated = Trips.fromJson(json.decode(value.body!)['Trip']);
      userID = storage.read(key: 'user_id');
      tripsUpdated.car = trips.car;
      tripsUpdated.myCarForSwap = trips.myCarForSwap;
      tripsUpdated.carName = trips.carName;

      tripsUpdated.carImageId = trips.carImageId;
      tripsUpdated.carLicense = trips.carLicense;
      tripsUpdated.carYear = trips.carYear;
      tripsUpdated.hostProfile = trips.hostProfile;
      tripsUpdated.guestProfile = trips.guestProfile;
      tripsUpdated.userID = trips.userID;
      tripsUpdated.guestProfile!.verificationStatus =
          trips.guestProfile!.verificationStatus;

      setState(() {
        trips = tripsUpdated;
        isDataUpToDate = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    deviceHeight = MediaQuery.of(context).size.height;
    deviceWidth = MediaQuery.of(context).size.width;
    if (trips.guestUserID == trips.userID && trips.tripType != 'Swap') {
      setState(() {
        tripType = 'rental';
        bookingDetailsType = 'BOOKING';
        profileImageId = trips.hostProfile!.imageID;
        userType = 'Host';
        userName =
            '${trips.hostProfile!.firstName}  ${trips.hostProfile!.lastName}';
        trips.guestTotal != null && trips.guestTotal! < 0
            ? amountType = 'cost'
            : amountType = 'refund';

        paymentAmount =
            trips.guestTotal!.toStringAsFixed(2).replaceAll("-", "");
        swap = false;
        carType = 'Car';
      });
    } else if (trips.hostUserID == trips.userID) {
      setState(() {
        tripType = 'rent out';
        bookingDetailsType = 'BOOKING';
        profileImageId = trips.guestProfile!.imageID;
        userType = 'Guest';
        userName =
            '${trips.guestProfile!.firstName} ${trips.guestProfile!.lastName}';
        trips.hostTotal != null && trips.hostTotal! < 0
            ? amountType = 'cost'
            : amountType = 'earnings';
        paymentAmount = trips.hostTotal!.toStringAsFixed(2).replaceAll("-", "");
        swap = false;
        carType = 'Booked car';
      });
    } else if (trips.guestUserID == trips.userID && trips.tripType == 'Swap') {
      setState(() {
        tripType = 'Swap';
        bookingDetailsType = 'SWAP';
        profileImageId = trips.hostProfile!.imageID;
        userType = 'Host';
        userName =
            '${trips.hostProfile!.firstName}  ${trips.hostProfile!.lastName}';
        if (trips.cancellationFee != null &&
            trips.cancellationFee!.cancellationProfit != null &&
            (trips.cancellationFee!.cancellationProfit!.whoPaidUserID ==
                    userID ||
                trips.cancellationFee!.cancellationProfit!.whoPaidUserID ==
                    '')) {
          cancellationFeeCredit = 'Cancellation Fee';
          cancellationFeeCreditValue = trips.cancellationFee!.cancellationFee;
          print('creditvalue$cancellationFeeCreditValue');
        } else {
          cancellationFeeCredit = 'Cancellation Credit';
          cancellationFeeCreditValue =
              trips.cancellationFee!.cancellationProfit!.ammount;
          print('creditvalue$cancellationFeeCreditValue');
        }

        trips.guestTotal != null && trips.guestTotal! < 0
            ? amountType = 'cost'
            : trips.guestTotal! > 0 &&
                    cancellationFeeCreditValue == trips.guestTotal
                ? amountType = 'earnings'
                : amountType = 'refund';
        paymentAmount =
            trips.guestTotal!.toStringAsFixed(2).replaceAll("-", "");
        swap = true;
        carType = 'Swapped car';
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: isDataUpToDate
          ? SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      trips.car == null
                          ? Container(
                              height: 250,
                              width: double.infinity,
                              color: Colors.black12,
                            )
                          : Image(
                              height: 250,
                              width: double.infinity,
                              image: (trips.carImageId == null ||
                                      trips.carImageId == '')
                                  ? AssetImage('images/car-placeholder.png')
                                  : NetworkImage(
                                          '$storageServerUrl/${trips.carImageId}')
                                      as ImageProvider,
                              fit: BoxFit.fill,
                            ),
                      Positioned(
                        left: 15,
                        top: 40,
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: trips.car == null
                                ? Colors.black12
                                : Colors.white,
                          ),
                          child: IconButton(
                            icon: Image.asset('icons/Back.png'),
                            onPressed: () {
                              Map argument = {"Index": 3};
                              Navigator.pop(context);
                              // if(backPressPop){
                              //   Navigator.pop(context);
                              // } else {
                              //   Map argument = {"Index": 3};
                              //   Navigator.pushNamed(context, '/trips', arguments: argument
                              //     // arguments: arguments,
                              //   );
                              // }
                            },
                          ),
                        ),
                      ),
                      Positioned(
                        left: 70,
                        top: 30,
                        child: Container(
                          height: 40,
                          width: 260,
                          decoration: BoxDecoration(
                              color: Color(0xffFFFFFF),
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(12)),
                          child: Center(
                            child: Text(trips.tripType == 'Swap'
                                ? 'Cancelled ${trips.tripType}'
                                : 'Cancelled $tripType'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      'TRIP ID: ' +
                          (trips.tripType == 'Swap'
                              ? 'SBN${trips.swapData!.SBN}'
                              : 'RBN${trips.rBN}'),
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        color: Color(0xff371D32).withOpacity(0.5),
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Divider(color: Color(0xFFE7EAEB)),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: trips.cancellationFee != null &&
                            trips.cancellationFee!.whoCancelled != null
                        ? trips.cancellationFee!.whoCancelled == 'RideAlike'
                            ? Text(
                                'TRIP DURATION - CANCELLED BY ADMIN.',
                                style: headingText.copyWith(
                                  color: Color(0xff371D32).withOpacity(0.5),
                                ),
                              )
                            : trips.cancellationFee!.whoCancelled == 'Guest'
                                ? Text(
                                    trips.guestProfile!.verificationStatus ==
                                            "Undefined"
                                        ? "TRIP DURATION - CANCELLED BY DELETED USER"
                                        : 'TRIP DURATION - CANCELLED BY ${trips.guestProfile!.firstName!.toUpperCase()} ${trips.guestProfile!.lastName![0].toUpperCase()}.',
                                    style: headingText.copyWith(
                                      color: Color(0xff371D32).withOpacity(0.5),
                                    ),
                                  )
                                : Text(
                                    trips.car == null
                                        ? "TRIP DURATION - CANCELLED BY DELETED USER"
                                        : 'TRIP DURATION - CANCELLED BY ${trips.hostProfile!.firstName!.toUpperCase()} ${trips.hostProfile!.lastName![0].toUpperCase()}.',
                                    style: headingText.copyWith(
                                      color: Color(0xff371D32).withOpacity(0.5),
                                    ),
                                  )
                        : Container(),
                  ),
                  trips.car == null
                      ? Container()
                      : Column(
                          children: [
                            Divider(),
                            SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Text(
                                trips.tripType == 'Swap'
                                    ? 'SWAP DETAILS'
                                    : '$bookingDetailsType DETAILS',
                                style: headingText.copyWith(
                                  color: Color(0xff371D32).withOpacity(0.5),
                                ),
                              ),
                            ),
                            Divider(),
                            SizedBox(height: 10),
                            trips.tripType == 'Swap'
                                ? Container(
                                    height: SizeConfig.deviceHeight! *
                                        0.09 *
                                        SizeConfig.deviceFontSize!,
                                    width: deviceWidth,
                                    padding: EdgeInsets.only(top: 10, left: 15),
                                    child: Stack(
                                      children: <Widget>[
                                        ClipOval(
                                          child: Image(
                                            height: 30,
                                            width: 30,
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                                '$storageServerUrl/${trips.myCarForSwap!.imagesAndDocuments!.images!.mainImageID}'),
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
                                                  '$storageServerUrl/${trips.car!.imagesAndDocuments!.images!.mainImageID}'),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          left: 40,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Text(
                                                    'Swapped car',
                                                    style: TextStyle(
                                                        color:
                                                            Color(0xff371D32),
                                                        fontSize: 16),
                                                  ),
                                                  SizedBox(
                                                    width: deviceWidth! * 0.78,
                                                    child: AutoSizeText(
                                                      tripsRentalBloc
                                                          .getTextForSwappedCar(
                                                              trips),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xff353B50),
                                                          fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: 10),
                                              // Row(
                                              //   crossAxisAlignment: CrossAxisAlignment.end,
                                              //   mainAxisAlignment: MainAxisAlignment.center,
                                              //   children: <Widget>[
                                              //     Icon(
                                              //       Icons.arrow_forward_ios,
                                              //       size: 15,
                                              //     ),
                                              //   ],
                                              // )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                : tripType == 'rent out'
                                    ? Container(
                                        child: SizedBox(
                                          width: double.maxFinite,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 15),
                                                child: Row(
                                                  children: <Widget>[
                                                    ClipOval(
                                                      child: Image(
                                                        height: 30,
                                                        width: 30,
                                                        fit: BoxFit.cover,
                                                        image: (trips.carImageId ==
                                                                    null ||
                                                                trips.carImageId ==
                                                                    '')
                                                            ? AssetImage(
                                                                'images/car-placeholder.png')
                                                            : NetworkImage(
                                                                    '$storageServerUrl/${trips.carImageId}')
                                                                as ImageProvider,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    Text(
                                                      '$carType',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color:
                                                              Color(0xff371D32),
                                                          letterSpacing: -0.4,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontFamily:
                                                              'Urbanist'),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 15),
                                                child: Row(
                                                  children: <Widget>[
                                                    Text(
                                                        trips.carYear == null
                                                            ? ''
                                                            : trips.car!.about!
                                                                    .year! +
                                                                ' ' +
                                                                trips
                                                                    .car!
                                                                    .about!
                                                                    .make! +
                                                                ' ' +
                                                                trips
                                                                    .car!
                                                                    .about!
                                                                    .model!,
                                                        style: valueTextStyle),
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
                                              arguments: trips.carID);
                                        },
                                        child: Container(
                                          child: SizedBox(
                                            width: double.maxFinite,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 15),
                                                  child: Row(
                                                    children: <Widget>[
                                                      ClipOval(
                                                        child: Image(
                                                          height: 30,
                                                          width: 30,
                                                          fit: BoxFit.cover,
                                                          image: (trips.carImageId ==
                                                                      null ||
                                                                  trips.carImageId ==
                                                                      '')
                                                              ? AssetImage(
                                                                  'images/car-placeholder.png')
                                                              : NetworkImage(
                                                                      '$storageServerUrl/${trips.carImageId}')
                                                                  as ImageProvider,
                                                        ),
                                                      ),
                                                      SizedBox(width: 8),
                                                      Text(
                                                        '$carType',
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Color(
                                                                0xff371D32),
                                                            letterSpacing: -0.4,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal,
                                                            fontFamily:
                                                                'Urbanist'),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 15),
                                                  child: Row(
                                                    children: <Widget>[
                                                      Text(
                                                          trips.carYear == null
                                                              ? ''
                                                              : trips
                                                                      .car!
                                                                      .about!
                                                                      .year! +
                                                                  ' ' +
                                                                  trips
                                                                      .car!
                                                                      .about!
                                                                      .make! +
                                                                  ' ' +
                                                                  trips
                                                                      .car!
                                                                      .about!
                                                                      .model!,
                                                          style:
                                                              valueTextStyle),
                                                      SizedBox(width: 8),
                                                      Icon(
                                                        Icons.arrow_forward_ios,
                                                        color:
                                                            Color(0xff353B50),
                                                        size: 12,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                            Divider(),
                            trips.guestProfile!.verificationStatus ==
                                        "Undefined" ||
                                    trips.hostProfile!.verificationStatus ==
                                        "Undefined"
                                ? Container()
                                : InkWell(
                                    onTap: () {
                                      if (userType == 'Host' ||
                                          trips.tripType == 'Swap') {
                                        Navigator.pushNamed(
                                            context, '/user_profile',
                                            arguments:
                                                trips.hostProfile!.toJson());
                                      } else {
                                        print(
                                            "guest####${trips.guestProfile!.profileID}");
                                        Navigator.pushNamed(
                                            context, '/trips_guest_profile_ui',
                                            arguments: {
                                              'guestUserID': trips.guestUserID,
                                              'guestProfileID':
                                                  trips.guestProfile!.profileID
                                            });
                                      }
                                    },
                                    child: Container(
                                      child: SizedBox(
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 15),
                                              child: Row(
                                                children: <Widget>[
                                                  ClipOval(
                                                    child: Image(
                                                      height: 30,
                                                      width: 30,
                                                      fit: BoxFit.cover,
                                                      image: (profileImageId ==
                                                                  null ||
                                                              profileImageId ==
                                                                  '')
                                                          ? AssetImage(
                                                              'images/user.png')
                                                          : NetworkImage(
                                                                  '$storageServerUrl/$profileImageId')
                                                              as ImageProvider,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 8,
                                                  ),
                                                  Text(
                                                    trips.tripType == 'Swap'
                                                        ? 'Host'
                                                        : '$userType',
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xff371D32),
                                                        letterSpacing: -0.4,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontFamily: 'Urbanist'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15),
                                              child: Row(
                                                children: <Widget>[
                                                  Text(
                                                      trips.tripType == 'Swap'
                                                          ? '${trips.hostProfile!.firstName} ${trips.hostProfile!.lastName}'
                                                          : '$userName',
                                                      style: valueTextStyle),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.arrow_forward_ios,
                                                    color: Color(0xff353B50),
                                                    size: 12,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                  trips.guestProfile!.verificationStatus == "Undefined" ||
                          trips.hostProfile!.verificationStatus == "Undefined"
                      ? Container()
                      : Divider(),
                  InkWell(
                    onTap: () {
                      //Navigator.pushNamed(context, '/receipt', arguments: trips.bookingID);
                      if (trips.tripType == 'Swap') {
                        Navigator.pushNamed(context, '/receipt_swap',
                            arguments: trips);
                      } else {
                        Navigator.pushNamed(context, '/receipt',
                            arguments: trips);
                      }
                    },
                    child: Container(
                      child: SizedBox(
                        width: double.maxFinite,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'Trip $amountType',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff371D32),
                                        letterSpacing: -0.4,
                                        fontWeight: FontWeight.normal,
                                        fontFamily: 'Urbanist'),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: Row(
                                children: <Widget>[
                                  Text('\$$paymentAmount',
                                      style: valueTextStyle),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Color(0xff353B50),
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Divider(),
                  (tripType == 'rent out' || trips.tripType == 'Swap') &&
                          trips.tripStatus == 'Cancelled'
                      ? Container()
                      : Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: trips.car == null
                                          ? Container()
                                          : ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                backgroundColor:
                                                    trips.car == null
                                                        ? null
                                                        : Color(0xffFF8F68),
                                                padding: EdgeInsets.all(16.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                              ),
                                              onPressed: trips.car == null
                                                  ? null
                                                  : () async {
                                                      String? profileID =
                                                          await storage.read(
                                                              key:
                                                                  'profile_id');

                                                      if (profileID != null) {
                                                        // Card null check

                                                        String postalCode = trips
                                                                        .car!
                                                                        .about!
                                                                        .location!
                                                                        .postalCode !=
                                                                    null &&
                                                                trips
                                                                        .car!
                                                                        .about!
                                                                        .location!
                                                                        .postalCode !=
                                                                    ''
                                                            ? trips
                                                                .car!
                                                                .about!
                                                                .location!
                                                                .postalCode!
                                                            : '';
                                                        String region = trips
                                                                        .car!
                                                                        .about!
                                                                        .location!
                                                                        .region !=
                                                                    null &&
                                                                trips
                                                                        .car!
                                                                        .about!
                                                                        .location!
                                                                        .region !=
                                                                    ''
                                                            ? trips
                                                                .car!
                                                                .about!
                                                                .location!
                                                                .region!
                                                            : '';
                                                        String locality = trips
                                                                        .car!
                                                                        .about!
                                                                        .location!
                                                                        .locality !=
                                                                    null &&
                                                                trips
                                                                        .car!
                                                                        .about!
                                                                        .location!
                                                                        .locality !=
                                                                    ''
                                                            ? trips
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
                                                            trips.car!
                                                                .calendarID!;
                                                        _bookingInfo['carID'] =
                                                            trips.carID!;
                                                        _bookingInfo['userID'] =
                                                            trips.userID!;
                                                        _bookingInfo[
                                                                'location'] =
                                                            trips
                                                                .car!
                                                                .about!
                                                                .location!
                                                                .address!;
                                                        _bookingInfo[
                                                                'FormattedAddress'] =
                                                            trips
                                                                .car!
                                                                .about!
                                                                .location!
                                                                .formattedAddress!;
                                                        _bookingInfo[
                                                                'locAddress'] =
                                                            address;
                                                        _bookingInfo['locLat'] =
                                                            trips
                                                                .car!
                                                                .about!
                                                                .location!
                                                                .latLng!
                                                                .latitude!;
                                                        _bookingInfo[
                                                                'locLong'] =
                                                            trips
                                                                .car!
                                                                .about!
                                                                .location!
                                                                .latLng!
                                                                .longitude!;
                                                        _bookingInfo[
                                                                'customDeliveryEnable'] =
                                                            trips
                                                                .car!
                                                                .pricing!
                                                                .rentalPricing!
                                                                .enableCustomDelivery!;

                                                        var res =
                                                            await fetchCarData(
                                                                trips.carID);
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
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[new CircularProgressIndicator()],
              ),
            ),
    );
  }

  Future<Resp> updateTripsData(String tripID) async {
    var getTripByIDCompleter = Completer<Resp>();
    callAPI(getTripByIDUrl, json.encode({"TripID": tripID})).then((resp) {
      getTripByIDCompleter.complete(resp);
    });

    return getTripByIDCompleter.future;
  }
}
