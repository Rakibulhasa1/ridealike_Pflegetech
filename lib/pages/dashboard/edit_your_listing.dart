import 'package:flutter/material.dart';

const listTextStyle = TextStyle(
  color: Color(0xff371D32),
  fontSize: 16,
  fontFamily: 'Urbanist',
  fontWeight: FontWeight.w500,
);

class EditYourListing extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    final  dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/dashboard_tab'
            );
          },
        ),
        elevation: 0.0,
      ),
      body: new SingleChildScrollView(
        scrollDirection: Axis.vertical,
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
                            child: Text(
                              'Edit your listing',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 36,
                                  color: Color(0xFF371D32),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('icons/List-a-Car_Whats-Next.png'),
                ],
              ),
              //texting//
              SizedBox(height: 25),
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
                              backgroundColor: Color(0xffF2F2F2),
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                            ),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit_dashboard_about_your_vehicle',
                                  arguments: receivedData,
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        'Vehicle details',
                                        style: listTextStyle
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    child: Icon(Icons.keyboard_arrow_right,
                                        color: Color(0xff353B50)),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
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
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),
                                ),

                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit_dashboard_photos_and_documents',
                                  arguments: receivedData,
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        'Photos and documents',
                                        style: listTextStyle
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    child: Icon(Icons.keyboard_arrow_right,
                                        color: Color(0xff353B50)),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                            ),  onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit_dashboard_vehicle_features',
                                  arguments: receivedData,
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        'Features',
                                        style: listTextStyle
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    child: Icon(Icons.keyboard_arrow_right,
                                        color: Color(0xff353B50)),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                            ),   onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit_dashboard_vehicle_preferences',
                                  arguments: receivedData,
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        'Preferences',
                                        style: listTextStyle
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    child: Icon(Icons.keyboard_arrow_right,
                                        color: Color(0xff353B50)),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                            ),  onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/edit_dashboard_vehicle_availability',
                                  arguments: receivedData,
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        'Availability',
                                        style: listTextStyle
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    child: Icon(Icons.keyboard_arrow_right,
                                        color:Color(0xff353B50)),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
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
                                  '/edit_dashboard_vehicle_pricing',
                                  arguments: receivedData,
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        'Pricing',
                                        style: listTextStyle
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    child: Icon(Icons.keyboard_arrow_right,
                                        color: Color(0xff353B50)),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
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
                              Navigator.pushNamed(context, '/deactivate_your_listing_tab');
                            },
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                      'Deactive your listing',
                                      style: listTextStyle
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  child: Icon(Icons.keyboard_arrow_right,
                                      color: Color(0xff353B50)),
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
            ],
          ),
        ),
      ),
    );
  }
}
