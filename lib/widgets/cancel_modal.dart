import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/trips/bloc/trips_rental_bloc.dart';
import 'package:ridealike/pages/trips/request_service/cancel_trip_request.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

class CancelModal extends StatefulWidget {
  final Trips tripData;

  CancelModal({required this.tripData});

  @override
  _CancelModalState createState() => _CancelModalState();
}

class _CancelModalState extends State<CancelModal> {
  bool _modalClick = false;

  final tripsRentalBloc = TripsRentalBloc();
  bool _isButtonPressed = false;
  final TextEditingController _cancelDescriptionController =
      TextEditingController();
  int? _aboutMeCharCount;

  _countAboutMeCharacter(String value) {
    setState(() {
      _aboutMeCharCount = value.length;
    });
  }

  void initState() {
    super.initState();
    // AppEventsUtils.logEvent("view_cancel_trip");
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Cancel Trip"});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      color: Color.fromRGBO(64, 64, 64, 1),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height / 2,
          maxHeight: MediaQuery.of(context).size.height - 24,
        ),
        child: Container(
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: Text(
                          "Cancel trip",
                          style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xff371D32)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Discard",
                          style: TextStyle(
                            color: Color(0xffF68E65),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 16, right: 16, bottom: 8),
                child: Text(
                  "CANCELLATION POLICY",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.info),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 50,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: widget.tripData.freeCancelBeforeDateTime!
                                .isAfter(DateTime.now())
                            ? AutoSizeText(
                                "Cancel your trip free until ${DateFormat('EEE MMM dd, yyyy hh:00 a').format(widget.tripData.freeCancelBeforeDateTime!)}",
                                maxLines: 3,
                                style: TextStyle(
                                    fontFamily: 'Open Sans Regular',
                                    fontSize: 14,
                                    color: Color(0xFF353B50)),
                              )
                            : AutoSizeText(
                                "You are no longer within the free cancellation period.",
                                maxLines: 2,
                                style: TextStyle(
                                    fontFamily: 'Open Sans Regular',
                                    fontSize: 14,
                                    color: Color(0xFF353B50)),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xfff2f2f2),
                  borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 16.0, top: 10),
                          child: Text(
                            "Cancellation reasons",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xFF371D32)),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 16.0),
                      child: TextField(
                        textInputAction: TextInputAction.done,
                        minLines: 1,
                        maxLines: 5,
                        controller: _cancelDescriptionController,
                        onChanged: _countAboutMeCharacter,
                        decoration: InputDecoration(
                            hintText: 'Add a note',
                            hintStyle: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xFF686868),
                                fontStyle: FontStyle.italic),
                            border: InputBorder.none),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              margin: EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Color(0xffF55A51),
                                  padding: EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),
                                ),
                                onPressed: _cancelDescriptionController.text ==
                                        ''
                                    ? null
                                    : () async {
                                        if (!_modalClick) {
                                          _modalClick = true;
                                          setState(() {
                                            _isButtonPressed = true;
                                          });

                                          var address = await cancelTrip(
                                              widget.tripData.tripID,
                                              _cancelDescriptionController
                                                  .text);

                                          AppEventsUtils.logEvent(
                                              "trip_cancel_successful",
                                              params: {
                                                "trip_id":
                                                    widget.tripData.tripID,
                                                "location":
                                                    widget.tripData.location,
                                                "start_date": widget
                                                    .tripData.startDateTime
                                                    ?.toIso8601String(),
                                                "end_date": widget
                                                    .tripData.endDateTime
                                                    ?.toIso8601String(),
                                                "car_id": widget.tripData.carID,
                                                "car_name":
                                                    widget.tripData.carName,
                                                "car_rating": widget
                                                    .tripData.car!.rating
                                                    ?.toStringAsFixed(1),
                                                "car_trips": widget.tripData
                                                    .car!.numberOfTrips,
                                                "host_rating": widget.tripData
                                                    .hostProfile!.profileRating
                                                    ?.toStringAsFixed(1),
                                                "host_trips": widget.tripData
                                                    .hostProfile!.numberOfTrips,
                                                "trip_cancellation_reason":
                                                    _cancelDescriptionController
                                                        .text,
                                              });
                                          Navigator.pushNamed(
                                              context,
//                                      '/trips_cancelled_details',
                                              '/trip_cancelled',
                                              arguments: widget.tripData);
                                        }
                                      },
                                child: Text(
                                  'Proceed with cancellation',
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 18,
                                      color: Colors.white),
                                ),
                              ),
                            )),
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
//    res = await http.post('https://api.trip.ridealike.com/v1/trip.TripService/CancelTrip',
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
