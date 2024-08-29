import 'package:flutter/material.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/utils/size_config.dart';

import '../../../utils/app_events/app_events_utils.dart';

class TripCancelled extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Trip Cancelled"});

    final receivedData = ModalRoute.of(context)!.settings.arguments;
    Trips tripDetails = receivedData as Trips;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.black38,
        child: Center(
          child: Container(
            height: SizeConfig.deviceHeight! * 0.6,
            padding: const EdgeInsets.only(top: 32.0),
            width: 300,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 0.5,
                      blurRadius: 17,
                      offset: Offset(0.0, 17.0))
                ]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image(
                    image: AssetImage('icons/Trip-Cancelled-2.png'),
                    height: 100.0,
                    width: 100.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 0.0),
                  child: Center(
                    child: Text(
                      "Your trip\n has been cancelled!",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 24,
                          color: Color(0xFF371D32)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(
                      top: 25.0, right: 10, left: 10, bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Color(0xffFF8F68),
                      padding: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, '/trips_cancelled_details',
                              arguments: tripDetails)
                          .then((value) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            '/discover_tab', (Route<dynamic> route) => false);
                      });
                    },
                    child: Text(
                      'Ok',
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
        ),
      ),
    );
  }
}
