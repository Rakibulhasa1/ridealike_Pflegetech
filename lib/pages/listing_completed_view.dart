import 'package:flutter/material.dart';

class ListingCompletedView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return new Scaffold(
        backgroundColor: Colors.white,
//        body: Container(
//          margin: EdgeInsets.all(16),
//          child: Column(
//            crossAxisAlignment: CrossAxisAlignment.end,
////            mainAxisSize: MainAxisSize.max,
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              SizedBox(height: 100,),
//              Column(
////                crossAxisAlignment: CrossAxisAlignment.stretch,
//                mainAxisAlignment: MainAxisAlignment.end,
//                crossAxisAlignment: CrossAxisAlignment.end,
//                children: [
//                  Row(
//                    crossAxisAlignment: CrossAxisAlignment.end,
//                    children: [
//                      Image.asset(
//                        'icons/Well_Done.png',
//                      ),
//                    ],
//                    mainAxisAlignment: MainAxisAlignment.center,
//                  ),
//                ],
//              ),
//              Expanded(
//                flex: 1,
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.end,
//                  children: <Widget>[
//                    Text(
//                      'Congratulations!',
//                      style: TextStyle(
//                        fontFamily: 'Urbanist',
//                        fontSize: 36,
//                        color: Color(0xFF371D32),
//                        fontWeight: FontWeight.bold,
//                      ),
//                    ),
//                    SizedBox(height: 15),
//                    Text(
//                      'We will quickly review your listing for quality control, and then we’ll publish it for our Guests to enjoy, and to help you earn extra income.',
//                      textAlign: TextAlign.center,
//                      style: TextStyle(
//                        fontFamily: 'Urbanist',
//                        fontSize: 16,
//                        color: Color(0xFF353B50),
//                      ),
//                    ),
//                    SizedBox(height: 20),
//                    SizedBox(
//                      width: double.maxFinite,
//                      child: ElevatedButton(style: ElevatedButton.styleFrom(
//                        elevation: 0.0,
//                        color: Color(0xffFF8F68),
//                        padding: EdgeInsets.all(16.0),
//                        shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(8.0)),
//                        onPressed: () {
//                          Navigator.pushNamed(
//                            context,
//                            '/dashboard_tab',
//                            // arguments: arguments,
//                          );
//                        },
//                        child: Text(
//                          'Continue to Dashboard',
//                          style: TextStyle(
//                              fontFamily: 'Urbanist',
//                              fontSize: 16,
//                              color: Colors.white),
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ),
//              //Spacer(),
//              // Header
//              /* Expanded(
//                child: Column(
//                  mainAxisAlignment: MainAxisAlignment.end,
//                  children: <Widget>[
//                    Text(
//                      'Congratulations!',
//                      style: TextStyle(
//                        fontFamily: 'Urbanist',
//                        fontSize: 36,
//                        color: Color(0xFF371D32),
//                        fontWeight: FontWeight.bold,
//                      ),
//                    ),
//                    SizedBox(height: 15),
//                    Text(
//                      'We will quickly review your listing for quality control, and then we’ll publish it for our Guests to enjoy, and to help you earn extra income.',
//                      textAlign: TextAlign.center,
//                      style: TextStyle(
//                        fontFamily: 'Urbanist',
//                        fontSize: 16,
//                        color: Color(0xFF353B50),
//                      ),
//                    ),
//                    SizedBox(height: 20),
//                    SizedBox(
//                      width: double.maxFinite,
//                      child: ElevatedButton(style: ElevatedButton.styleFrom(
//                        elevation: 0.0,
//                        color: Color(0xffFF8F68),
//                        padding: EdgeInsets.all(16.0),
//                        shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(8.0)),
//                        onPressed: () {
//                          Navigator.pushNamed(
//                            context,
//                            '/dashboard_tab',
//                            // arguments: arguments,
//                          );
//                        },
//                        child: Text(
//                          'Continue to Dashboard',
//                          style: TextStyle(
//                              fontFamily: 'Urbanist',
//                              fontSize: 16,
//                              color: Colors.white),
//                        ),
//                      ),
//                    ),
//                  ],
//                ),
//              ),*/
//            ],
//          ),
//        ),
        body: PageView(
          children:<Widget>[Padding(
            padding: EdgeInsets.all(16.0),
            child: ListView(
              children: <Widget>[
                // Header
                Image.asset('icons/Well_Done.png'),
                SizedBox(height: 40),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                        Text('Congratulations!',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: deviceHeight*0.04,
                    color: Color(0xFF371D32),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Subtext
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('We will review your listing and then publish it for our Guests to enjoy so that you can earn extra income.',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xFF353B50),
                              ),textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25),
                Row(
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
                                // var arguments = {"User": {"Name": "Test User"}};

                                // Navigator.of(context).pushNamed('/profile');
                                Navigator.pushNamed(
                                  context,
                                  '/dashboard_tab'
                                  // arguments: arguments,
                                );
                              },
                              child: Text('Continue to Dashboard',
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
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
                SizedBox(height: 15),
              ],
            ),
          ),] ,

        ),
      );
  }
}
