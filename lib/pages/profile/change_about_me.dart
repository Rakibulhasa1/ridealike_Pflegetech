import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/verify_email_view.dart';

class ChangeIntroduceYourselfView extends StatefulWidget {
  @override
  State createState() => ChangeIntroduceYourselfViewState();
}
class ChangeIntroduceYourselfViewState
    extends State<ChangeIntroduceYourselfView> {
   int? _aboutMeCharCount;
  bool _isButtonPressed = false;
  final TextEditingController _aboutMeController = TextEditingController();

  _countAboutMeCharacter(String value) {
    setState(() {
      _aboutMeCharCount = value.length;
    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      receivedData = ModalRoute.of(this.context)!.settings.arguments as Map;

      setState(() {
        _aboutMeController.text = receivedData!['Profile']['AboutMe'];
        _aboutMeCharCount = _aboutMeController.text.length;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xFFEA9A62)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: new Text(
          'Introduce yourself',
          style: TextStyle(
              fontFamily: 'Urbanist', fontSize: 16, color: Color(0xFF371D32)),
        ),
        elevation: 0.0,
      ),

      //Content of tabs
      body: new PageView(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: [
                    // Text field
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      children: <Widget>[

                                        Column(
                                          children: <Widget>[
                                            TextFormField(
                                              textInputAction: TextInputAction.done,
                                              controller: _aboutMeController,
                                              onChanged: _countAboutMeCharacter,
                                              minLines: 1,
                                              maxLines: 5,
                                              maxLength: 500,
                                              // maxLengthEnforced: true,
                                              keyboardType: TextInputType.visiblePassword,
                                              decoration: InputDecoration(
                                                border: InputBorder.none,
                                                labelText: 'About me',
                                                labelStyle: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32),
                                                ),
                                                hintText:
                                                    'Please introduce yourself (This will be visible to all RideAlike users)',
                                                hintStyle: TextStyle(
                                                    fontFamily:
                                                        'Urbanist',
                                                    fontSize: 14,
                                                    fontStyle:
                                                        FontStyle.italic),
                                                // counterText: '',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
                // Save button
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
                              // textColor: Colors.white,
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),),
                              onPressed: _isButtonPressed||_aboutMeController.text==''
                                  ? null
                                  : () async {
                                      setState(() {
                                        _isButtonPressed = true;
                                      });

                                      await addAboutMe(receivedData!['ProfileID'], _aboutMeController.text);

                                      Navigator.pushNamed(context, '/profile_edit_tab');
                                    },
                              child: _isButtonPressed
                                  ? SizedBox(
                                      height: 18.0,
                                      width: 18.0,
                                      child: new CircularProgressIndicator(
                                          strokeWidth: 2.5),
                                    )
                                  : Text(
                                      'Save',
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
        ],
      ),
    );
  }
}

Future<RestApi.Resp> addAboutMe(_profileID, _aboutMe) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    addAboutMeUrl,
    json.encode({"ProfileID": _profileID, "AboutMe": _aboutMe}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
