

import 'package:flutter/material.dart';
import 'package:ridealike/pages/trips/bloc/end_trip_bloc.dart';
import 'package:ridealike/pages/trips/bloc/trips_rental_bloc.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_car_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_host_request.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
class ReviewModal extends StatelessWidget {
  final Trips? tripData;
  ReviewModal({this.tripData});
 final  tripsRentalBloc=TripsRentalBloc();
  final endTripRentalBloc = EndTripRentalBloc();

  @override
  Widget build(BuildContext context) {


    RateTripCarRequest rateTripCarRequest = RateTripCarRequest(
        inspectionByUserID: tripData!.userID,
        tripID: tripData!.tripID,
        rateCar: '0',
        reviewCarDescription: '');

    RateTripHostRequest rateTripHostRequest = RateTripHostRequest(
        tripID: tripData!.tripID,
        inspectionByUserID: tripData!.userID,
        rateHost: '0',
        reviewHostDescription: '');

    endTripRentalBloc.changedTripRateCar.call(rateTripCarRequest);
    endTripRentalBloc.changedTripRateHost.call(rateTripHostRequest);
    return  Container(
      alignment: Alignment.bottomLeft,
      color: Color.fromRGBO(64, 64, 64, 1),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:250,
          maxHeight: MediaQuery.of(context).size.height-20
        ),
        child: Container(
          margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          // height: MediaQuery.of(context).size.height / 2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
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

                      Align(alignment: Alignment.topCenter,
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
              tripData!.carRatingReviewAdded == false
                  ? StreamBuilder<RateTripCarRequest>(
                  stream: endTripRentalBloc.tripRateCar,
                  builder: (context, tripRateCarSnapshot) {
                    return tripRateCarSnapshot.hasData &&
                        tripRateCarSnapshot.data != null
                        ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
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
                                    "Rate the car",
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
                                        tripRateCarSnapshot.data
                                            !.rateCar = v.toString();
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
                                onChanged: (review) {
                                  tripRateCarSnapshot.data
                                      !.reviewCarDescription =
                                      review;
                                  endTripRentalBloc
                                      .changedTripRateCar
                                      .call(
                                      tripRateCarSnapshot.data!);
                                },
                                decoration: InputDecoration(
                                    hintText:
                                    'Write a car review[optional]',
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
                    ),
                        )
                        : Container();
                  })
                  : Container(),
              //Rate host//
              tripData!.hostRatingReviewAdded == false
                  ? StreamBuilder<RateTripHostRequest>(
                  stream: endTripRentalBloc.tripRateHost,
                  builder: (context, tripRateHostSnapshot) {
                    return tripRateHostSnapshot.hasData &&
                        tripRateHostSnapshot.data != null
                        ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: Container(
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
                                onChanged: (hostReviews) {
                                  tripRateHostSnapshot.data!.reviewHostDescription = hostReviews;
                                  endTripRentalBloc.changedTripRateHost.call(tripRateHostSnapshot.data!);
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
                    ),
                        )
                        : Container();
                  })
                  : Container(),

              SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            child: SizedBox(
                              width: double.maxFinite,
                              child: ElevatedButton(style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Color(0xffFF8F68),
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),),
                                onPressed: () async {
                                  await endTripRentalBloc.rateThisTripAndHost(tripData!);
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
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
      Container(
        alignment: Alignment.bottomLeft,
        color: Color.fromRGBO(64, 64, 64, 1),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height / 2,
            maxHeight: MediaQuery.of(context).size.height - 24,
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            // height: MediaQuery.of(context).size.height / 2,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              shrinkWrap: true,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.keyboard_backspace,
                        color: Colors.orange,
                      ),
                    ),
                    SizedBox(width: 80.0),
                    Text(
                      "Leave a review",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF371D32)),
                    ),
                  ],
                ),
                SizedBox(height: 15.0),
                //Rating car//
                tripData?.carRatingReviewAdded == false
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
                                    "Rate the car",
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
                                        tripRateCarSnapshot.data
                                            !.rateCar = v.toString();
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
                                onChanged: (review) {
                                  tripRateCarSnapshot.data
                                      !.reviewCarDescription =
                                      review;
                                  endTripRentalBloc
                                      .changedTripRateCar
                                      .call(
                                      tripRateCarSnapshot.data!);
                                },
                                decoration: InputDecoration(
                                    hintText:
                                    'Write a car review[optional]',
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
                tripData?.hostRatingReviewAdded == false
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
                                onChanged: (hostReviews) {
                                  tripRateHostSnapshot.data
                                      !.reviewHostDescription =
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
                            child: ElevatedButton(style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Color(0xffFF8F68),
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),),
                              onPressed: () async {
                                await endTripRentalBloc.rateThisTripAndHost(tripData!);
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
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
  }
}

//Future<http.Response> cancelTrip(Trips tripData) async {
//  var res;
//
//  try {
//    res = await http.post('https://api.trip.ridealike.anexa.dev/v1/trip.TripService/CancelTrip',
//      body: json.encode(
//        {
//          "TripID": tripData.tripID
//        }
//      ),
//    );
//  } catch (error) {}
//
//  return res;
//}
