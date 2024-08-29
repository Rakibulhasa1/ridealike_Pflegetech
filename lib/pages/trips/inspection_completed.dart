import 'package:flutter/material.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';

import '../../utils/app_events/app_events_utils.dart';


class InspectionCompleted extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Inspection Completed"});
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    Trips tripDetails = receivedData['trip'];
    String tripType = receivedData['tripType'];
    bool damage=false;
    if(receivedData['damage']!=null){
      damage=receivedData['damage'];
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.black38,
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(top: 32.0),
            width: 300,
            height: MediaQuery.of(context).size.height*.65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  spreadRadius: 0.5,
                  blurRadius: 17,
                  offset: Offset(0.0, 17.0)
                )
              ]
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Image(
                    image: damage==true?AssetImage('icons/Experience_Bad.png'):AssetImage('icons/Experience-Good.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0,left: 10,right:10),
                  child: Center(
                    child: Text(damage==true?'We are sorry to hear you a bad experience':"Thanks for hosting with RideAlike",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 24,
                      color: Color(0xFF371D32)
                    ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0,left: 10,right:10),
                  child: Center(
                    child: Text(damage==true?'Our team is working on your case and we\'ll get back to you shortly.':"Expect a payout for this trip within 5 business days.",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 14,
                      color: Color(0xFF353B50)
                    ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 25.0,right: 10,left: 10,bottom: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Color(0xffFF8F68),
                      padding: EdgeInsets.all(16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                    ),
                    onPressed: () {
                      if (tripDetails.tripType=='Swap'){
                        Navigator.pushNamed(
                          context,
//                      '/trips_rental_details',
                          '/trips_rental_details_ui',
                          arguments: {'tripType': tripType,  'trip': tripDetails},
                        );
                      } else {
                        Navigator.pushNamed(
                          context,
//                        '/trips_rent_out_details',
                          '/trips_rent_out_details_ui',
                          arguments: {
                            'tripType': tripType,
                            'trip': tripDetails
                          },
                        );
                      }
                    },
                    child: Text('Ok',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 18,
                        color: Colors.white
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
