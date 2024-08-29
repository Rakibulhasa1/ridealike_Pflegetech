import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;


//
 Map? receivedData;

final TextEditingController _emailController = TextEditingController();

class VerifyEmailView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    _emailController.text = receivedData['Email'];

    print(receivedData['UserID']);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xFFEA9A62)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: new Text(
          'Verify your email',
          style: TextStyle(
              fontFamily: 'Urbanist', fontSize: 16, color: Color(0xFF371D32)),
        ),
        elevation: 0.0,
      ),

      //Content of tabs
      body: SingleChildScrollView(scrollDirection: Axis.vertical,
        child:   Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                        width: 100,
                      ),
                      Align(alignment: Alignment.center,
                        child: AutoSizeText(
                          'Please check ${_emailController.text} inbox for your email verification request.  If you cannot find it, please check your Spam/Junk folder or click below to resend the verification request.  If you need to update your email, select the back button, click on your name and select email.',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            color: Color(0xFF353B50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
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
                                return 'Email address is required.';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                                enabled: false,
                                contentPadding: EdgeInsets.all(22.0),
                                border: InputBorder.none,
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ), hintStyle: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14, // Adjust the font size as needed
                              color: Colors.grey, // You can customize the color as well
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
            SizedBox(height: MediaQuery.of(context).size.height*.32,),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child:
                        ElevatedButton(style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xffFF8F68),
                          // textColor: Colors.white,
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),

                        ),
                          onPressed: () async {
                            await sendEmailVerificationLink(receivedData['UserID']);

                            // Navigator.pushNamed(context, '/about_you_tab');
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Resend verification link',
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
