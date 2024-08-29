import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';

int _digitCount = 0;

class VerifyPhoneNumber extends StatefulWidget {
  State createState() => new VerifyPhoneNumberState();
}

class VerifyPhoneNumberState extends State<VerifyPhoneNumber> {
  String dropdownValue = '+1';
  bool? _isButtonDisabled;
  bool _isButtonPressed = false;

  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _isButtonDisabled = true;
  }

  _countDigit(String value) {
    setState(() {
      _digitCount = value.length;
    });

    if (_digitCount == 10) {
      FocusScope.of(context).requestFocus(FocusNode());
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
  Widget build (BuildContext context) {
    final  Map rcvdData = ModalRoute.of(context)!.settings.arguments as Map;
    
    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      // appBar: new AppBar(
      //   leading: new IconButton(
      //     icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
      //     onPressed: () {
      //       Navigator.pushNamed(
      //         context,
      //         '/create_profile'
      //       );
      //     },
      //   ),
      //   elevation: 0.0,
      // ),
      appBar: new AppBar(
        leading: new Container(),
        elevation: 0.0,
      ),

      //Content of tabs
      body: SingleChildScrollView(
        child: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
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
                            child: Text('Verify your phone number',
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
                  Image.asset('icons/Phone_Verify-Number.png'),
                ],
              ),
              SizedBox(height: 20),
              // Text
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            child: Text('Phone number is required so we know how to contact you in case of emergency.',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xFF353B50),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Input fields
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          // height: 70.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: DropdownButtonFormField<String>(
                              isDense: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(16.0),
                                border: InputBorder.none,
                                labelText: 'Country',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ),
                              ),
                              value: dropdownValue,
                              icon: Icon(
                                Icons.keyboard_arrow_down, 
                                color: Color(0xFF353B50)
                              ),
                              onChanged: (String? newValue) {
                                setState(() => dropdownValue = newValue!);
                              },
                              items: <String>['+1', '+91', '+880']
                                .map<DropdownMenuItem<String>>((String item) {
                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Text(item),
                                  );
                                }
                              ).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child:
                          Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: TextFormField(
                              onChanged: _countDigit,
                              controller: _phoneController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Phone number is required';
                                }
                                return null;
                              },
                              maxLength: 10,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(18.0),
                                border: InputBorder.none,
                                labelText: 'Phone number',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ), hintStyle: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14, // Adjust the font size as needed
                                color: Colors.grey, // You can customize the color as well
                              ),
                                hintText: 'Enter phone number',
                                counterText: ""
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 120),
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
                            onPressed: _isButtonDisabled! ? null : () async {
                              setState(() {
                                _isButtonDisabled = true;
                                _isButtonPressed = true;
                              });

                              var phone = _phoneController.text;

                              var res = await addPhoneNumber(rcvdData['User']['ProfileID'], dropdownValue + phone);

                              if (res != null) {
                                Map mapRes = json.decode(res.body!);

                                await sendPhoneVerificationCode(rcvdData['User']['ProfileID']);

                                Navigator.pushNamed(
                                  context,
                                  '/verify_security_code',
                                  arguments: mapRes,
                                );
                              } else {
                                setState(() {
                                  _isButtonDisabled = false;
                                  _isButtonPressed = false;
                                });
                              }
                            },
                            child: _isButtonPressed ?
                            SizedBox(
                              height: 18.0,
                              width: 18.0,
                              child: new CircularProgressIndicator(strokeWidth: 2.5),
                            ) : Text('Next',
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
      ),
    );
  }
}

Future<http.Response> addPhoneNumber(String profileID, String phone) async {
  var res;

  try {
    res = await http.post(
      Uri.parse(addPhoneNumberUrl),
      // addPhoneNumberUrl as Uri,
    body: json.encode(
      {
        "ProfileID": profileID,
        "PhoneNumber": phone,
      }
    ),
  );
  } catch (error) {
    
  }
  
  return res; 
}

Future<http.Response> sendPhoneVerificationCode(String profileID) async {
  var res = await http.post(
    Uri.parse(sendPhoneVerificationCodeUrl),
    // sendPhoneVerificationCodeUrl as Uri,
    body: json.encode(
      {
        "ProfileID": profileID,
      }
    ),
  );
  return res; 
}