import 'package:flutter/material.dart';

import '../utils/app_events/app_events_utils.dart';


var _carData = {};

class ReviewListing extends StatefulWidget {
  @override
  State createState() => ReviewListingState();
}

class ReviewListingState extends  State<ReviewListing> {

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Review Your Listing"});
  }

  @override
  Widget build (BuildContext context) {
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

    _carData = receivedData;
    
    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new Container(),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {

                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text('Save & Exit',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xFFFF8F62),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        elevation: 0.0,
      ),

      //Content of tabs
      body: new SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            child: Text('Review your listing',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 36,
                                color: Color(0xFF371D32),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('icons/List-a-Car_Whats-Next.png'),
                ],
              ),
              SizedBox(height: 15),
              // Text
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text('You can review and make changes to any of the steps below, or proceed to publish.',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xFF353B50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Tell us about your car
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Color(0xFFF2F2F2),
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                            ),
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/edit_about_your_vehicle',
                                arguments: receivedData,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Text('Tell us about your vehicle',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                // Image.asset('icons/Checkbox.png'),
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xffFF8F68),
                                ),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              // Add photos to your listing
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xFFF2F2F2),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/edit_photos_and_documents',
                                arguments: receivedData,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Text('Upload photos and documents',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xffFF8F68),
                                ),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              // What features do you have
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xFFF2F2F2),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),  onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/edit_vehicle_features',
                                arguments: receivedData,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Text('Select your vehicle’s features',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xffFF8F68),
                                ),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              // Set your car rules
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xFFF2F2F2),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/edit_vehicle_preferences',
                                arguments: receivedData,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Text('Set preferences for your vehicle',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xffFF8F68),
                                ),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              // Set your car availability
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xFFF2F2F2),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),  onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/edit_vehicle_availability',
                                arguments: receivedData,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Text('Set your vehicle’s availability',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xffFF8F68),
                                ),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              // Price your car
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xFFF2F2F2),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/edit_vehicle_pricing',
                                arguments: receivedData,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Text('Set your pricing',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Icon(
                                  Icons.check_circle,
                                  color: Color(0xffFF8F68),
                                ),
                              ],
                            )
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Next button
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
                            ),onPressed: () {
                              Navigator.pushNamed(context,
                                '/listing_completed',
                                // arguments: arguments,
                              );
                            },
                            child: Text('Save',
                              // 'Submit your vehicle for review',
                              textAlign: TextAlign.center,
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
            ],
          ),
        ),
      ),
    );
  }
}
