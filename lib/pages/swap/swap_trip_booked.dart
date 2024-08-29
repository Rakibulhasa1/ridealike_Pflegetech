import 'package:flutter/material.dart';

import '../../utils/app_events/app_events_utils.dart';

class SwapTripBooked extends StatefulWidget {
  @override
  State createState() => SwapTripBookedState();
}

class SwapTripBookedState extends  State<SwapTripBooked> {

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Swap Trip Booked"});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomLeft,
        color: Color.fromRGBO(64, 64, 64, 1),
        child: ConstrainedBox(
          constraints: BoxConstraints(
          ),
          child: Container(
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: ListView(
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
                    fontFamily: 'Urbanist',
                    fontSize: 36,
                    color: Color(0xff371D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Congratulations on booking a trip with RideAlike.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xff353B50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('We trust it will be to your satisfaction and you can always reach support by email at hello@ridealike.com or chat if needed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xff353B50),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Please ensure you meet your Host on time. Enjoy your RideAlike trip!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xff353B50),
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
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context, 
                                    '/trips'
                                  );
                                },
                                 child: Text('Ok',
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
