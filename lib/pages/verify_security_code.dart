import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';

class VerifySecurityCode extends StatefulWidget {
  State createState() => new VerifySecurityCodeState();
}

class VerifySecurityCodeState extends State<VerifySecurityCode> {
  // bool _isButtonDisabled;
  // bool _isButtonPressed = false;

  final TextEditingController _codeController = TextEditingController();
  bool _hasError = false;
  bool _hasMessage = false;

  String _error = '';
  String _message = '';

  @override
  Widget build(BuildContext context) {
    final Map rcvdData = ModalRoute.of(context)!.settings.arguments as Map;

    void _countCodeLength(String value) async {
      if (value.length == 5) {
        var code = _codeController.text;

        FocusScope.of(context).requestFocus(FocusNode());

        var res = await verifyPhone(rcvdData['Profile']['ProfileID'], rcvdData['Profile']['PhoneNumber'], code);
        Map mapRes = json.decode(res.body!);

        if (!mapRes['Status']['success']) {
          setState(() {
             _hasMessage = false;
            _error = 'Error! Code not valid.';
            _hasError = true;
          });
        } else {
          Navigator.pushNamed(
            context,
            '/verify_identity',
            arguments: mapRes,
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),

      //Content of tabs
      body: SingleChildScrollView(
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
                            child: Text('Enter your verification code',
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
              SizedBox(height: 35),
              // Input field
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(8)
                            ),
                            child: TextFormField(
                              controller: _codeController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Secure code is required';
                                }
                                return null;
                              },
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.done,
                              onChanged: _countCodeLength,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(22.0),
                                border: InputBorder.none,
                                labelText: 'Verification code',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ), hintStyle: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14, // Adjust the font size as needed
                                color: Colors.grey, // You can customize the color as well
                              ),
                                hintText: 'Please enter verification code',
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
              // Resend code
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _hasError = false;

                          _message = 'Success! Code resent.';
                          _hasMessage = true;
                        });

                        sendPhoneVerificationCode(rcvdData['Profile']['ProfileID']);
                      },
                      child: Text('Resend code',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: Color(0xFF371D32)
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _hasError || _hasMessage ? SizedBox(height: 25) : new Container(),
              _hasError ? Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_error,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: Color(0xFFF55A51),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ) : new Container(),
              _hasMessage ? Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(_message,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: Color(0xFF5CAEAC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ) : new Container(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<http.Response> verifyPhone(String profileID, String phoneNumber, String code) async {
  var res;

  try {
    res = await http.post(
      Uri.parse(verifyPhoneUrl),
      // verifyPhoneUrl as Uri,
      body: json.encode(
          {
            "ProfileID": profileID,
            "PhoneNumber": phoneNumber,
            "VerificationCode": code,
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