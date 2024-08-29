import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../utils/app_events/app_events_utils.dart';

class TripBooked extends StatefulWidget {
  @override
  State createState() => TripBookedState();
}

class TripBookedState extends  State<TripBooked> {

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Trip Booked"});
  }

  void handleShowUpcomingTripdModal(context) {
    Navigator.of(context).pushNamed("/trips", arguments: {"Index": 0});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomLeft,
        color: Color.fromRGBO(64, 64, 64, 1),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            // minHeight: MediaQuery.of(context).size.height / 2,
            // maxHeight: MediaQuery.of(context).size.height - 24,
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
                Container(
                  margin: EdgeInsets.only(top: 32, bottom: 32),
                  height: 100,
                  child: Image.asset('icons/Trip-Booked.png'),
                ),
                //
                Text('Your trip is booked!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Regular',
                    fontSize: 36,
                    color: Color(0xff371D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 20,left: 8,right: 8),
                  child: SizedBox(width: MediaQuery.of(context).size.width*.80,
                    child: AutoSizeText('You can always find details of your current trip, including proof of insurance, by selecting the Trips icon.',
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xff353B50),
                      ),
                    ),
                  ),
                ),
                Divider(),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.maxFinite,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Color(0xffFF8F68),
                                  padding: EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                ),
                                onPressed: () => handleShowUpcomingTripdModal(context),
                                child: Text('Done',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 18,
                                    color: Colors.white
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
