import 'dart:async';
import 'dart:convert' show Utf8Decoder, json;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:ridealike/sharedPreference.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';

// final _formKey = GlobalKey<FormState>();

class Login extends StatefulWidget {
  @override
  State createState() => LoginState();
}

class LoginState extends State<Login> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool? _isButtonDisabled;
  bool _isButtonPressed = false;
  bool _hidePassword = true;
  bool _hasError = false;

  String _error = '';

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _isButtonDisabled = true;
    _emailController.addListener(_checkInputValue);
    _passwordController.addListener(_checkInputValue);
  }

  void _checkInputValue() {
    var email = _emailController.text;
    var password = _passwordController.text;

    if (email != '' && password != '') {
      setState(() {
        _isButtonDisabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => new Scaffold(
        backgroundColor: Colors.white,

        //App Bar
        appBar: new AppBar(
          leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
            onPressed: () {
              Navigator.pushNamed(context, '/create_profile_or_sign_in');
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
                        Image.asset(
                          'images/Logo.png',
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
                                Text(
                                  'RideAlike',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline1!
                                      .copyWith(
                                          fontFamily: 'Urbanist',
                                          fontSize: 44,
                                          color: Color(0xffFF8F68)),
                                ),
                                SizedBox(height: 5.0),
                                Text(
                                  'Go farther.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline6!
                                      .copyWith(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 80),
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
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: TextFormField(
                                controller: _emailController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Email address is required';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.emailAddress,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      (RegExp(r'^[a-zA-Z0-9@._-]+$')))
                                ],
                                decoration: InputDecoration(
                                    contentPadding: EdgeInsets.all(22.0),
                                    border: InputBorder.none,
                                    labelText: 'Email',
                                    labelStyle: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 12,
                                      color: Color(0xFF353B50),
                                    ),
                                    hintText: 'Please enter email'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                // Password
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
                                  borderRadius: BorderRadius.circular(8.0)),
                              child: TextFormField(
                                controller: _passwordController,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Password is required';
                                  }
                                  return null;
                                },
                                obscureText: _hidePassword,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(22.0),
                                  border: InputBorder.none,
                                  labelText: 'Password',
                                  labelStyle: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 12,
                                    color: Color(0xFF353B50),
                                  ),
                                  hintText: 'Please enter password',
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _hidePassword = !_hidePassword;
                                      });
                                    },
                                    child:
                                        Image.asset('icons/Show_Password.png'),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                _hasError
                    ? Row(
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  _error,
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
                      )
                    : new Container(),
                _hasError ? SizedBox(height: 15) : new Container(),
                // Sign In button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child:ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Color(0xffFF8F68),
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),

                              ),
                              onPressed: _isButtonDisabled!
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isButtonDisabled = true;
                                        _isButtonPressed = true;
                                        _hasError = false;
                                      });

                                      var email = _emailController.text;
                                      var password = _passwordController.text;

                                      var res =
                                          await attemptSignIn(email, password);

                                      if (res.statusCode == 200) {
                                        await storage.deleteAll();

                                        await storage.write(
                                            key: 'profile_id',
                                            value: json.decode(res.body!)['User']
                                                ['ProfileID']);
                                        await storage.write(
                                            key: 'user_id',
                                            value: json.decode(res.body!)['User']
                                                ['UserID']);
                                        await storage.write(
                                            key: 'jwt',
                                            value:
                                                json.decode(res.body!)['JWT']);

                                        if (!(json.decode(res.body!)['User']
                                                ['RegistrationStatus']
                                            ['PhoneVerified'])) {
                                          Map arguments = {
                                            "User": {
                                              "ProfileID":
                                                  json.decode(res.body!)['User']
                                                      ['ProfileID']
                                            }
                                          };

                                          Navigator.pushNamed(
                                              context, '/verify_phone_number',
                                              arguments: arguments);
                                        } else if (!(json
                                                    .decode(res.body!)['User']
                                                ['RegistrationStatus']
                                            ['TermsAndConditionAccepted'])) {
                                          Map arguments = {
                                            "User": {
                                              "ProfileID":
                                                  json.decode(res.body!)['User']
                                                      ['ProfileID']
                                            }
                                          };

                                          Navigator.pushNamed(
                                            context,
                                            '/terms_and_conditions',
                                            arguments: arguments,
                                          );
                                        } else if (!(json
                                                    .decode(res.body!)['User']
                                                ['RegistrationStatus']
                                            ['DLDocumentsSubmitted'])) {
                                          Map arguments = {
                                            "PhoneVerification": {
                                              "ProfileID":
                                                  json.decode(res.body!)['User']
                                                      ['ProfileID']
                                            }
                                          };

                                          Navigator.pushNamed(
                                            context,
                                            '/verify_identity',
                                            arguments: arguments,
                                          );
                                        } else {
                                          Navigator.pushNamed(
                                              context, '/profile');
                                        }
                                      } else {
                                        setState(() {
                                          if (json.decode(
                                                  res.body!)['message'] ==
                                              'Could not fetch user data: mongo: no documents in result') {
                                            _error = 'User not found.';
                                          } else {
                                            _error = json
                                                .decode(res.body!)['message'];
                                          }

                                          _isButtonDisabled = false;
                                          _isButtonPressed = false;
                                          _hasError = true;
                                        });
                                      }
                                    },
                              child: _isButtonPressed
                                  ? SizedBox(
                                      height: 18.0,
                                      width: 18.0,
                                      child: new CircularProgressIndicator(
                                          strokeWidth: 2.5),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          color: Colors.white),
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

Future<Resp> attemptSignIn(String email, String password) async {
  var completer = Completer<Resp>();

  callAPI(
    loginUrl,
    json.encode({"Email": email, "Password": password}),
  ).then((resp) {
    completer.complete(resp);
  });

  return completer.future;
}

class Resp {
  int statusCode;
  String body;

  Resp({
    required this.statusCode,
    required this.body,
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

void displayDialog(BuildContext context, String title, String text) =>
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: Text(title), content: Text(text)),
    );
