import 'dart:async';
import 'dart:convert' show Utf8Decoder, json;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:ridealike/sharedPreference.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';

import '../utils/app_events/app_events_utils.dart';


// final _formKey = GlobalKey<FormState>();

class ForgotPassword extends StatefulWidget {
  @override
  State createState() => ForgotPasswordState();
}

class ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();


  bool _isButtonPressed = false;
  bool _hasError = false;

  String _error = '';

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Forgot Password"});


  }

  // void _checkInputValue() {
  //   var email = _emailController.text;
  //
  //   if (email != '') {
  //     setState(() {
  //       _isButtonDisabled = false;
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) => new Scaffold(
    backgroundColor: Colors.white,

    //App Bar
    appBar: new AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/create_profile_or_sign_in'
          );
        },
      ),
      elevation: 0.0,
    ),

    body: new SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: <Widget>[
                    Image.asset('images/Logo.png',
                      height: 80.0,
                    ),
                  ],
                ),
              ],
            ),
            // RideAlike
            Row(
              children: <Widget>[
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 10.0),
                            Text('RideAlike',
                              style: Theme.of(context).textTheme.headline1!.copyWith(
                                fontFamily: 'Urbanist',
                                fontSize: 44,
                                color: Color(0xffFF8F68)
                              ),
                            ),
                            SizedBox(height: 5.0),
                            // Text('Go farther.',
                            //   style: Theme.of(context).textTheme.title.copyWith(
                            //     fontFamily: 'Urbanist',
                            //     fontSize: 14,
                            //     fontWeight: FontWeight.w500
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 70),

            SizedBox(
              child: Center(
                child: Text('A password reset link will be sent to you email address.',
                    style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF371D32)
                ),),
              ),
            ),
            SizedBox(height: 10),
            // Email
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
                            borderRadius: BorderRadius.circular(8.0)
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Email address is required';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              setState(() {
                                _hasError=false;
                                _error='';
                              });
                            },
                            keyboardType: TextInputType.emailAddress,
                            inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'^[a-zA-Z0-9@._-]+$')))],
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(22.0),
                              border: InputBorder.none,
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFF353B50),
                              ),
                              hintText: 'Please enter email'

                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // SizedBox(height: 10),
            _hasError ? SizedBox(height: 10) : new Container(),
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
          SizedBox(height: 15) ,
            // Sign In button
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xffFF8F68),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),),
                          onPressed: _isButtonPressed ? null : () async {
                            var email = _emailController.text;
                            if (!RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z]+(\.[a-zA-Z]+)*\.[a-zA-Z]+[a-zA-Z]+$")
                                .hasMatch(email)) {
                              setState(() {
                                _error = 'Email formation invalid';
                                _hasError = true;
                              });
                              return;
                            }
                            // setState(() {
                            //   _isButtonDisabled = true;
                            //   _isButtonPressed = true;
                            //   // _hasError = false;
                            // });

                            setState(() {
                              _isButtonPressed = true;

                            });
                            var res = await _forgotPassword(email);

                            if (json.decode(res.body!)['Status']['success']) {
                              Navigator.of(context).pushNamed('/signin_ui');

                            } else {
                              setState(() {
                                _error = json.decode(res.body!)['Status']['error'];

                                // _isButtonDisabled = false;
                                _isButtonPressed = false;
                                _hasError = true;
                              });
                            }
                          },
                          child: _isButtonPressed ?
                          SizedBox(
                            height: 18.0,
                            width: 18.0,
                            child: new CircularProgressIndicator(strokeWidth: 2.5),
                          ) : Text('Send Email',
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

Future<Resp> _forgotPassword(String email) async {
  var completer = Completer<Resp>();

  callAPI(
    forgotPasswordUrl,
    json.encode({
      "Email": email
    }),
    ).then((resp) {
      completer.complete(resp);
    }
  );

  return completer.future;
}

class Resp {
  int? statusCode;
  String? body;

  Resp({
    this.statusCode,
    this.body,
  });
}

Future<Resp> callAPI(String url, String payload) async {
  var completer = Completer<Resp>();
  var apiUrl = Uri.parse(url);
  var client = HttpClient(); // `new` keyword optional

  // Create request
  HttpClientRequest request;
  request = await client.postUrl(apiUrl);

  // Write data
  request.write(payload);

  // Send the request
  HttpClientResponse response;
  response = await request.close();

  // Handle the response
  var resStream = response.transform(Utf8Decoder());
  await for (var data in resStream) {
    completer.complete(Resp(body: data, statusCode: response.statusCode));
    break;
  }

  return completer.future;
}

void displayDialog(BuildContext context, String title, String text) => showDialog(
  context: context,
  builder: (context) => AlertDialog(title: Text(title), content: Text(text)),
);
