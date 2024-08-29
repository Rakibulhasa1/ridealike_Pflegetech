import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;


Map? passData;

Future<RestApi.Resp> updateEmail(data) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    updateEmailUrl,
    json.encode({
      "Email": data['Email'],
      "NewEmail": data['NewEmail'],
      "UserID": data['UserID']
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
Future<RestApi.Resp> sendEmailVerificationLink(_userID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    sendEmailVerificationLinkUrl,
    json.encode({
      "UserID": _userID,
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

class ChangeEmail extends StatefulWidget {
  @override
  _ChangeEmailState createState() => _ChangeEmailState();
}

class _ChangeEmailState extends State<ChangeEmail> {
  TextEditingController _emailTextController = new TextEditingController();
  bool _isButtonPressed = false;
  var text;
  Map? editedEamil;
  String _error = '';
  bool _hasError = false;
  bool _emailError = false;
  String _profileEmailError = '';
  var res;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      passData = ModalRoute.of(context)!.settings.arguments as Map;
      _emailTextController.text = passData!['Profile']['Email'];
    });
  }

  @override
  void dispose() {
    _emailTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Change your email',
          style: TextStyle(
              color: Color(0xff371D32),
              fontSize: 16,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
      ),
      body: PageView(children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            // onPressed: () {},
                            child: TextFormField(
                              controller: _emailTextController,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[a-zA-Z0-9@._-]'),
                                    replacementString: '')
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _hasError=false;
                                  _error='';
                                });
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(8.0),
                                border: InputBorder.none,
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ),
                                hintText: 'Enter email',
                              ),
                            ),
                          ),
                        ),
                        _hasError ? SizedBox(height: 10) : new Container(),
                        _hasError
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
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
                              )
                            : new Container(),
                      ],
                    ),
                  ),
                ],
              ),
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),

                            ),
                            onPressed: _isButtonPressed
                                ? null
                                : () async {
                                    var emailUpdated = _emailTextController.text.toLowerCase();
                                    if (!RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z]+(\.[a-zA-Z]+)*\.[a-zA-Z]+[a-zA-Z]+$")
                                        .hasMatch(emailUpdated)) {
                                      setState(() {
                                        _error = 'Please provide valid email.';
                                        _hasError = true;
                                      });
                                      return;
                                    }

                                    setState(() {
                                      _isButtonPressed = true;
                                    });

                                    var data = {
                                      'Email': (passData!['Profile']['Email']),
                                      'NewEmail': emailUpdated.toLowerCase(),
                                      'UserID': passData!['Profile']['UserID']
                                    };

                                    var res = await updateEmail(data);
                                    await sendEmailVerificationLink(data['UserID']);

                                    if (res.statusCode == 200) {
                                      Navigator.pushNamed(context, '/profile_edit_tab', arguments:  {'EMAIL_VERIFICATION':'Pending'});
                                    } else {
                                      setState(() {
                                        _error = json.decode(res.body!)['details'][0]['Message'];
                                        if(_error=='Email already exists'){
                                          _error='Failed to update email, email already exists.';
                                        }else{
                                          _error = json.decode(res.body!)['details'][0]['Message'];
                                        }
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
                                    'Change email',
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
              )

            ],
          ),
        ),
      ]),
    );
  }
}
