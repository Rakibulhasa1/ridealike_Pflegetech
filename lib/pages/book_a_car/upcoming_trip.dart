import 'package:flutter/material.dart';



class UpcomingTrip extends StatefulWidget {
  @override
  State createState() => UpcomingTripState();
}

class UpcomingTripState extends  State<UpcomingTrip> {

  @override
  Widget build(BuildContext context) {
    return Container(
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
                                Navigator.pushNamed(context, '/trips',
                                  // arguments: arguments,
                                );
                              },
                              child: Text('View upcoming trip',
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
    );
  }
}
