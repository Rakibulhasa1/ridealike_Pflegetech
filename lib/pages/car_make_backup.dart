import 'package:flutter/material.dart';

class CarMake extends StatefulWidget {
  @override
  State createState() => CarMakeState();
}

class CarMakeState extends State<CarMake> {
  
  @override
  Widget build (BuildContext context) {
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {

            },
            child: Center(
              child: Container(
                margin: EdgeInsets.only(right: 16),
                child: Text('Cancel',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xffFF8F68),
                  ),
                ),
              ),
            ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            child: Text('Make',
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
                ],
              ),
              SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: <Widget>[
                            Text('A',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFF371D32).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Color(0xFFABABAB)),
                        SizedBox(
                          width: double.maxFinite,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications_active, color: Color(0xFF3C2235)),
                                      SizedBox(width: 10),
                                      Text('Acura',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  child: Icon(
                                    Icons.keyboard_arrow_right, 
                                    color: Color(0xFF353B50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Color(0xFFABABAB)),
                        SizedBox(
                          width: double.maxFinite,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications_active, color: Color(0xFF3C2235)),
                                      SizedBox(width: 10),
                                      Text('Alfa Romeo',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  child: Icon(
                                    Icons.keyboard_arrow_right, 
                                    color: Color(0xFF353B50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Color(0xFFABABAB)),
                        Row(
                          children: <Widget>[
                            Text('B',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFF371D32).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Color(0xFFABABAB)),
                        SizedBox(
                          width: double.maxFinite,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications_active, color: Color(0xFF3C2235)),
                                      SizedBox(width: 10),
                                      Text('BMW',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  child: Icon(
                                    Icons.keyboard_arrow_right, 
                                    color: Color(0xFF353B50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Color(0xFFABABAB)),
                        SizedBox(
                          width: double.maxFinite,
                          child: Padding(
                            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Icon(Icons.notifications_active, color: Color(0xFF3C2235)),
                                      SizedBox(width: 10),
                                      Text('Buick',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]
                                  ),
                                ),
                                Container(
                                  width: 16,
                                  child: Icon(
                                    Icons.keyboard_arrow_right, 
                                    color: Color(0xFF353B50),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(color: Color(0xFFABABAB)),
                        Row(
                          children: <Widget>[
                            Text('M',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFF371D32).withOpacity(0.5),
                              ),
                            ),
                          ],
                        ),
                        Divider(color: Color(0xFFABABAB)),
                        GestureDetector(
                          onTap: () {
                            receivedData['_make'] = 'Mercedes-Benz';

                            Navigator.pushNamed(
                              context,
                              '/car_model',
                              arguments: receivedData,
                            );
                          },
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Padding(
                              padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: [
                                        Icon(Icons.notifications_active, color: Color(0xFF3C2235)),
                                        SizedBox(width: 10),
                                        Text('Mercedes-Benz',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ]
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    child: Icon(
                                      Icons.keyboard_arrow_right, 
                                      color: Color(0xFF353B50),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Divider(color: Color(0xFFABABAB)),
                      ],
                    ),
                  ),
                ],
              ),
            ]
          ),
        ),
      ),
    );
  }
}