import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:intl/intl.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
//class TripsCarCard extends StatefulWidget {
//  final List<Trips> tripsToShow;
//  final String tripType;
//  final String userId;
//
//  TripsCarCard(this.tripsToShow, this.tripType, this.userId);
//
//  @override
//  _TripsCarCardState createState() => _TripsCarCardState();
//}
//
//class _TripsCarCardState extends State<TripsCarCard> {
//  @override
//  Widget build(BuildContext context) {
//    return Container(
//      color: Colors.white,
//      height: 330,
//      child: widget.tripsToShow.length != 0 ? ListView.builder(
//        scrollDirection: Axis.vertical,
//        shrinkWrap: false,
//        itemCount: widget.tripsToShow.length,
//        itemBuilder: (context, index) {
//          Trips trip = widget.tripsToShow[index];
//          return GestureDetector(
//            onTap: () {
//              //route with car model
//              if (trip.tripStatus == 'Cancelled') {
//                Navigator.pushNamed(
//                  context,
//                  '/trips_cancelled_details',
//                  arguments: trip
//                );
//              } else if (trip.guestUserID == widget.userId) {
//                Navigator.pushNamed(
//                  context,
//                  '/trips_rental_details',
//                  arguments: {'tripType': widget.tripType,  'trip': trip},
//                );
//              }
//              else if (trip.hostUserID == widget.userId) {
//                Navigator.pushNamed(
//                  context,
//                  '/trips_rent_out_details',
//                  arguments: {'tripType': widget.tripType,  'trip': trip}
//                );
//              }
//            },
//            child: Container(
//              margin: EdgeInsets.all(15),
//              width: 345,
//              height: 320,
//              decoration: BoxDecoration(
//                color: Color(0xffFFFFFF),
//                shape: BoxShape.rectangle,
//                border: Border.all(width: 1, color: Color(0xffE0E0E0)),
//                borderRadius: BorderRadius.circular(10),
//              ),
//              child: Column(
//                children: <Widget>[
//                  // Image of the vehicle
//                  Stack(
//                    children: <Widget>[
//                      ClipRRect(
//                        borderRadius: BorderRadius.only(
//                          topLeft: Radius.circular(12),
//                          topRight: Radius.circular(12)
//                        ),
//                        child: Image(
//                          height: 225,
//                          width: double.infinity,
//                          image: (trip.carImageId == null || trip.carImageId == '')
//                            ? AssetImage('images/car-placeholder.png')
//                            : NetworkImage('https://api.storage.ridealike.com/${trip.carImageId}'
//                          ),
//                          fit: BoxFit.fill,
//                        ),
//                      ),
//                      Positioned(
//                        bottom: 10,
//                        left: 15,
//                        child: Container(
//                          height: 25,
//                          width: 80,
//                          decoration: BoxDecoration(
//                            color: Color(0xffFFFFFF),
//                            borderRadius: BorderRadius.circular(8),
//                            shape: BoxShape.rectangle
//                          ),
//                          child: Center(
//                            child: Text(trip.guestUserID == widget.userId ? 'RENTAL'
//                              : trip.hostUserID == widget.userId
//                              ? 'RENT OUT'
//                              : 'Swap',
//                              style: TextStyle(
//                                fontSize: 12,
//                                color: Color(0xff353B50),
//                                fontFamily: 'Urbanist'
//                              ),
//                            ),
//                          ),
//                        ),
//                      ),
//                      Visibility(
//                        visible: trip.tripStatus == 'Cancelled' ? true : false,
//                        child: Positioned(
//                          bottom: 10,
//                          left: 110,
//                          child: Container(
//                            height: 25,
//                            width: 90,
//                            decoration: BoxDecoration(
//                              color: Color(0xffF55A51),
//                              borderRadius: BorderRadius.circular(8),
//                              shape: BoxShape.rectangle
//                            ),
//                            child: Center(
//                              child: Text('CANCELLED',
//                                style: TextStyle(
//                                  fontSize: 12,
//                                  color: Color(0xffFFFFFF),
//                                  fontFamily: 'Urbanist'
//                                ),
//                              ),
//                            ),
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                  SizedBox(height: 10),
//                  // vehicle content
//                  Expanded(
//                    child: Column(
//                      crossAxisAlignment: CrossAxisAlignment.start,
//                      children: <Widget>[
//                        Align(
//                          alignment: Alignment.centerLeft,
//                          child: Padding(
//                            padding: const EdgeInsets.only(left: 15),
//                            child: Text((trip.carName == null || trip.carName == '') ? 'No name found' : trip.carYear + ' ' + trip.carName,
//                              style: TextStyle(
//                                fontFamily: 'Urbanist',
//                                fontWeight: FontWeight.w500,
//                                color: Color(0xff371D32),
//                                fontSize: 16,
//                              ),
//                            ),
//                          ),
//                        ),
//                        SizedBox(height: 15),
//                        Row(
//                          crossAxisAlignment: CrossAxisAlignment.center,
//                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                          children: <Widget>[
//                            Padding(
//                              padding: const EdgeInsets.only(left: 15),
//                              child: Row(
//                                crossAxisAlignment: CrossAxisAlignment.center,
//                                children: <Widget>[
//                                  Icon(
//                                    Icons.calendar_today,
//                                    color: Color(0xff353B50),
//                                    size: 20,
//                                  ),
//                                  SizedBox(width: 8),
//                                  Column(
//                                    crossAxisAlignment: CrossAxisAlignment.start,
//                                    children: <Widget>[
//                                      Text('${DateFormat('MMM dd, hh:mm a').format(trip.startDateTime)} to',
//                                        style: TextStyle(
//                                          color: Color(0xff353B50),
//                                          fontFamily: 'Urbanist',
//                                          fontWeight: FontWeight.normal,
//                                          letterSpacing: -0.2,
//                                          fontSize: 14
//                                        ),
//                                      ),
//                                      Text('${DateFormat('MMM dd, hh:mm a').format(trip.endDateTime)}',
//                                        style: TextStyle(
//                                          color: Color(0xff353B50),
//                                          fontFamily: 'Urbanist',
//                                          fontWeight: FontWeight.normal,
//                                          letterSpacing: -0.2,
//                                          fontSize: 14
//                                        ),
//                                      ),
//                                    ],
//                                  ),
//                                ],
//                              ),
//                            ),
//                            // SizedBox(width: 50),
//                            trip.guestUserID == widget.userId ? trip.tripStatus == 'Cancelled'
//                            ? Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: <Widget>[
//                                Icon(Icons.payment, color: Color(0xFF3C2235)),
//                                SizedBox(width: 5),
//                                Text(trip.tripStatus == 'Cancelled' ? 'Cancelled for free' : '\$${trip.tripPayout}',
//                                  style: TextStyle(
//                                    fontSize: 14,
//                                    fontFamily: 'Urbanist',
//                                    color: Color(0xff353B50),
//                                  ),
//                                ),
//                              ],
//                            )
//                            : Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: <Widget>[
//                                Icon(
//                                  Icons.location_on,
//                                  color: Color(0xff353B50),
//                                  size: 20
//                                ),
//                                SizedBox(width: 8),
//                                SizedBox(
//                                  width: 80,
//                                  height: 40,
//                                  child: Center(
//                                    child: AutoSizeText('${trip.Other}',
//                                      maxLines: 2,
//                                      style: TextStyle(
//                                        fontSize: 14,
//                                        letterSpacing: -0.2,
//                                        color: Color(0xff353B50),
//                                        fontWeight: FontWeight.normal,
//                                        fontFamily: 'Urbanist',
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                              ],
//                            )
//                            : trip.hostUserID == widget.userId ? trip.tripStatus == 'Cancelled'
//                            ? Row(
//                              mainAxisAlignment: MainAxisAlignment.center,
//                              children: <Widget>[
//                                Image.asset('icons/Payout-Method.png'),
//                                SizedBox(width: 8),
//                                Text(trip.tripStatus == 'Cancelled' ? 'No trip payout' : '\$${trip.tripPayout}',
//                                  style: TextStyle(
//                                    fontSize: 14,
//                                    fontFamily: 'Open Sans Regular',
//                                    color: Color(0xff353B50),
//                                    letterSpacing: -0.2,
//                                    fontWeight: FontWeight.normal
//                                  ),
//                                ),
//                              ],
//                            )
//                            : Row(
//                              crossAxisAlignment: CrossAxisAlignment.center,
//                              children: <Widget>[
//                                ClipRRect(
//                                  borderRadius: BorderRadius.circular(12),
//                                  child: Image(
//                                    height: 20,
//                                    width: 20,
//                                    fit: BoxFit.cover,
//                                    image: (trip.guestProfile.imageID == null || trip.guestProfile.imageID == '')
//                                      ? AssetImage('images/user.png')
//                                      : NetworkImage('https://api.storage.ridealike.com/${trip.guestProfile.imageID}'
//                                    ),
//                                  ),
//                                ),
//                                SizedBox(width: 10),
//                                Text('${trip.guestProfile.firstName} ${trip.guestProfile.lastName} ',
//                                  style: TextStyle(
//                                    fontSize: 12,
//                                    fontFamily: 'Urbanist',
//                                    fontWeight:FontWeight.normal,
//                                    color: Color(0xff353B50),
//                                    letterSpacing: -0.2
//                                  ),
//                                ),
//                              ],
//                            )
//                            : Row(
//                              crossAxisAlignment: CrossAxisAlignment.center,
//                              children: <Widget>[
//                                ClipRRect(
//                                  borderRadius: BorderRadius.circular(12),
//                                  child: Image(
//                                    height: 20,
//                                    width: 20,
//                                    fit: BoxFit.cover,
//                                    image: NetworkImage('https://source.unsplash.com/YApiWyp0lqo/1600x900'),
//                                  ),
//                                ),
//                                SizedBox(width: 10),
//                                SizedBox(
//                                  width: 80,
//                                  height: 40,
//                                  child: Center(
//                                    child: AutoSizeText('Swapping with 2019 Audi Q8',
//                                      maxLines: 2,
//                                      style: TextStyle(
//                                        fontSize: 14,
//                                        letterSpacing: -0.2,
//                                        color: Color(0xff353B50),
//                                        fontWeight: FontWeight.normal,
//                                        fontFamily: 'Urbanist',
//                                      ),
//                                    ),
//                                  ),
//                                ),
//                              ],
//                            ),
//                          ],
//                        )
//                      ],
//                    ),
//                  ),
//                ],
//              ),
//            ),
//          );
//        },
//      ) : Center(child: Text('No trips found')),
//    );
//  }
//}
