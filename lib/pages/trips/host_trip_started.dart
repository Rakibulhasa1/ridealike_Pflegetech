import 'package:flutter/material.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/utils/size_config.dart';

import '../../utils/app_events/app_events_utils.dart';




class HostTripStarted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Host Trip Started"});
    final receivedData = ModalRoute.of(context)!.settings.arguments;
    Trips tripDetails = receivedData as Trips;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.black38,
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(top: 32.0),
            width: 300,
            height: SizeConfig.deviceHeight! * 0.72,
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
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Image(
                    image: AssetImage('icons/Drive-Safe.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Center(
                    child: Text(
                      "Congratulations,\n Your Pre-Pick Up Process has been successfully completed.\nDrive safe.",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 19,
                          color: Color(0xFF371D32)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Center(
                    child: Text(
                      // "During your trip, you can always refer to your current trip to see any booking information as well as vehicle documents.",
                      "Your Guest will review your selections and pictures upon their arrival. Ensure you verify their photo ID to their name and picture displayed in your Upcoming Trip before providing your keys.",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: Color(0xFF353B50)),
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

                      Navigator.pushNamed(
                        context,
                        '/trips_rent_out_details_ui',
                        arguments: {'tripType': 'Upcoming', 'trip': tripDetails},
                      );
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