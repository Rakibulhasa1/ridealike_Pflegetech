import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';

class VerifyCarView extends StatefulWidget {
  @override
  State createState() => VerifyCarViewState();
}

class VerifyCarViewState extends  State<VerifyCarView> {
  @override
  Widget build (BuildContext context) { 
    final  dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

    bool _isButtonPressed = false;
    final storage = new FlutterSecureStorage();

    return Scaffold(
    backgroundColor: Colors.white,

    // App Bar
    appBar: new AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0.0,
    ),

    //Content of tabs
    body: new SingleChildScrollView(
      child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Image.asset('icons/Verification-in-Progress.png'),
                        SizedBox(height: 40),
                        Text('Thank you for choosing RideAlike',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 36,
                            color: Color(0xFF371D32),
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
                      children: <Widget>[
                        Text("You are one step closer to earning revenue from your car! Next, we will verify all of your information and if necessary contact you.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            color: Color(0xFF353B50),
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
                      children: <Widget>[
                        Text("Meanwhile, please continue to list your car and we will publish it once our verification process is complete.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            color: Color(0xFF353B50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 70),
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
                              backgroundColor: Color(0xFFF68E65),
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                            ),
                             onPressed: _isButtonPressed ? null : () async {
                              setState(() {
                                _isButtonPressed = true;
                              });

                              String? jwt = await storage.read(key: 'jwt');

                              if (jwt != null) {
                                setState(() async {
                                  var res = await requestToVerify(receivedData['Car']['ID'], jwt);

                                  if (res != null) {
                                    Navigator.pushNamed(
                                      context,
                                      '/what_features_do_you_have',
                                      arguments: receivedData,
                                    );
                                  } else {
                                    setState(() {
                                      _isButtonPressed = false;
                                    });
                                  }
                                });
                              }
                            },
                            child: Text('Verify and continue listing',
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

  Future<http.Response> requestToVerify(_carID, jwt) async {
    var res;

    try {
      res = await http.post(
        Uri.parse(requestToVerifyUrl),
        // requestToVerifyUrl as Uri,
        headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
        body: json.encode(
          {
            "CarID": _carID,
          }
        ),
      );
    } catch (error) {
      
    }
    
    return res;
  }
}