import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';

class TermsAndCondition extends StatefulWidget {
  @override
  State createState() => TermsAndConditionState();
}

class TermsAndConditionState extends State<TermsAndCondition> {
  bool _isButtonDisabled = false;

  bool _termsAndCondition = true;
  bool _promotionalMaterials = false;

  void _checkInputValue() {
    if (_termsAndCondition) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map rcvdData = ModalRoute.of(context)!.settings.arguments as Map;


    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new Container(),
        elevation: 0.0,
      ),

      body: new SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Terms & Conditions
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: new BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: new BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        height: 26,
                                        width: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.0),
                                          border: Border.all(
                                            color: Color(0xFF353B50),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 22,
                                          color: _termsAndCondition ? Color(0xFFFF8F68) : Colors.transparent,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: RichText(
                                                text: TextSpan(
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 14,
                                                      color: Color(0xFF353B50),
                                                    ),
                                                    children: <TextSpan>[
                                                      TextSpan(text: 'I agree to RideAlike '),
                                                      TextSpan(text: 'Terms & Conditions ',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                      TextSpan(text: 'and'),
                                                      TextSpan(text: ' Privacy Policy',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold
                                                        ),
                                                      ),
                                                    ]
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _termsAndCondition = !_termsAndCondition;
                                    });
                                    _checkInputValue();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Promotional Materials
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            decoration: new BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: new BorderRadius.circular(8.0),
                            ),
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        height: 26,
                                        width: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.rectangle,
                                          color: Colors.transparent,
                                          borderRadius: BorderRadius.circular(6.0),
                                          border: Border.all(
                                            color: Color(0xFF353B50),
                                            width: 2,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.check,
                                          size: 22,
                                          color: _promotionalMaterials ? Color(0xFFFF8F68) : Colors.transparent,
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              'I agree to receive promotional materials and product updates.',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Color(0xFF353B50),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _promotionalMaterials = !_promotionalMaterials;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
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

                            ),
                            onPressed: _isButtonDisabled ? null : () async {
                              print(rcvdData['User']['ProfileID']);
                              var res = await acceptTermsPolicy(rcvdData['User']['ProfileID']);


                              // if (_promotionalMaterials) {
                              //   await acceptPromotion(rcvdData['User']['ProfileID']);
                              // }


                              Map arguments = {
                                "User": {
                                  "ProfileID": rcvdData['User']['ProfileID']
                                }
                              };


                              Navigator.pushNamed(
                                  context, '/verify_phone_number',
                                  arguments: arguments
                              );
                              Navigator.pushNamed(
                                  context, '/verify_phone_number_ui',
                                  arguments: arguments
                              );
                            },
                            child: Text('Next',
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
            ],
          ),
        ),
      ),
    );
  }
}

Future<http.Response> acceptTermsPolicy(String profileID) async {
  var res = await http.post(
    Uri.parse(acceptTermsAndConditionsUrl_userServer),
    // acceptTermsAndConditionsUrl_userServer as Uri,
    body: json.encode({
      "ProfileID": profileID,
    }),
  );

  return res;
}

Future<http.Response> acceptPromotion(String profileID) async {
  var res = await http.post(
    Uri.parse(acceptPromotionalUpdatesUrl_userServer),
    // acceptPromotionalUpdatesUrl_userServer as Uri,
    body: json.encode({
      "ProfileID": profileID,
    }),
  );

  return res;
}
