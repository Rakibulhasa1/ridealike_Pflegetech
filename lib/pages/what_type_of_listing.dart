import 'dart:convert' show json, base64, ascii, utf8;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';

var _listingType =  {
  "_carID": ''
};

class ListingType extends StatefulWidget {
  @override
  State createState() => ListingTypeState();
}

class ListingTypeState extends  State<ListingType> {

  @override
  Widget build (BuildContext context) { 

    final  dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

    if (receivedData != null && receivedData['Car'] != null && receivedData['Car']['ID'] != null) {
      _listingType['_carID'] = receivedData['Car']['ID'];
    }
    
    return Scaffold(
    backgroundColor: Colors.white,

    //App Bar
    appBar: new AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
        onPressed: () => Navigator.of(context).pop(),
      ),
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
            SizedBox(height: 5),
            Center(
              child: Container(
                height: 2,
                width: 79,
                margin: EdgeInsets.only(right: 16),
                child: LinearProgressIndicator(
                  value: 0.24,
                  backgroundColor: Color(0xFFF2F2F2),
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
                            child: Text('What type of listing do you want?',
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
              SizedBox(height: 30),
              // Only rent
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
                            onPressed: () async {
                              var res = await setListingType(true, false);

                              var arguments = json.decode(res.body!);
                              
                              Navigator.pushNamed(
                                context,
                                '/pickup_and_return_location',
                                arguments: arguments,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Text('Rent outs only',
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
                                  child: Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
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
              SizedBox(height: 10),
              // Only swap
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
                            onPressed: () async {
                              var res = await setListingType(false, true);

                              var arguments = json.decode(res.body!);
                              
                              Navigator.pushNamed(
                                context,
                                '/pickup_and_return_location',
                                arguments: arguments,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Text('Swaps only',
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
                                  child: Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
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
              SizedBox(height: 10),
              // Both rent and swap
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
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),),
                            onPressed: () async {
                              var res = await setListingType(true, true);

                              var arguments = json.decode(res.body!);
                              
                              Navigator.pushNamed(
                                context,
                                '/pickup_and_return_location',
                                arguments: arguments,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: [
                                      Text('Both rent outs and swaps',
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
                                  child: Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
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
    )
    );
  }
}

Future<http.Response> setListingType(bool _rentOutEnabled, bool _swapEnabled) async {
  var res = await http.post(
    Uri.parse(setListingTypeUrl),
    // setListingTypeUrl as Uri,
    body: json.encode(
      {
        "CarID": _listingType['_carID'],
        "ListingType": {
          "RentOutEnabled": _rentOutEnabled,
          "SwapEnabled": _swapEnabled
        }
      }
    ),
  );
  
  return res;
}
