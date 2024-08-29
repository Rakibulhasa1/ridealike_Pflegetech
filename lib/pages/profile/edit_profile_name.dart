import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

class EditProfileName extends StatefulWidget {
  final firstName;
  final lastName;

  const EditProfileName({Key? key, this.firstName, this.lastName})
      : super(key: key);

  @override
  State<EditProfileName> createState() => _EditProfileNameState();
}

class _EditProfileNameState extends State<EditProfileName> {
  TextEditingController? _firstController;
  TextEditingController? _lastController;
  final storage = new FlutterSecureStorage();
  var completer = Completer<bool>();
  bool loading = false;
  bool changedFirstName = false;
  bool changedLastName = false;
  String? _firstString;
  String? _lastString;

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController(text: widget.firstName);
    _lastController = TextEditingController(text: widget.lastName);

    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Edit Profile Name"});
  }

  void isLoading(bool isLoading) {
    setState(() {
      loading = isLoading;
    });
  }

  Future<bool> getFirstNameChanged() async {
    var userID = await storage.read(key: 'user_id');
    var data = {"UserID": "$userID", "FirstName": "${_firstController!.text}"};

    try {
      var response = await HttpClient.post(changeFirstName, data,
          token: await storage.read(key: 'jwt') as String);
      bool success = response['Status']['success'];
      completer.complete(success);
    } catch (e) {
      print(e);
    }

    return completer.future;
  }

  Future<bool> getLastNameChanged() async {
    var userID = await storage.read(key: 'user_id');
    var data = {"UserID": "$userID", "LastName": "${_lastController!.text}"};

    try {
      var response = await HttpClient.post(changeLastName, data,
          token: await storage.read(key: 'jwt')as String);
      bool success = response['Status']['success'];
      completer.complete(success);
    } catch (e) {
      print(e);
    }
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
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
        body: Container(
          child: new SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                child: Text(
                                  'Change Name',
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 36,
                                      color: Color(0xFF371D32),
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset('icons/Profile_Create-Profile.png'),
                    ],
                  ),

                  //Bloc UI started//
                  SizedBox(height: 25),

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
                                    controller: _firstController,
                                    maxLength: 100,
                                    onChanged: (value) {
                                      setState(() {
                                        _firstString = value;
                                      });
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          _firstString==""?RegExp(r'[a-zA-Z]'):RegExp(r'[a-zA-Z ]'),
                                          replacementString: ''),
                                      // FilteringTextInputFormatter.deny(RegExp(r"\s\b|\b\s"))
                                    ],
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                        counter: Offstage(),
                                        contentPadding: EdgeInsets.all(22.0),
                                        border: InputBorder.none,
                                        labelText: 'First name',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 12,
                                          color: Color(0xFF353B50),
                                        ),
                                        hintText: 'Enter first name'),
                                  )
                                  // }),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                      '*Please provide valid input, only alpha characters are allowed.',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.grey,
                      )),
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
                                  controller: _lastController,
                                  maxLength: 100,
                                  onChanged: (value) {
                                    if (value.length > 100) {
                                      value = value.substring(0, 100);
                                    }

                                    setState(() {
                                      _lastString = value;
                                    });
                                  },
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        _lastString==""?RegExp(r'[a-zA-Z]'):RegExp(r'[a-zA-Z ]'),
                                        replacementString: '')
                                  ],
                                  decoration: InputDecoration(
                                      counter: Offstage(),
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'Last name',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Enter last name'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                      '*Please provide valid input, only alpha characters are allowed.',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.grey,
                      )),
                  // Change button
                  SizedBox(height: 20),
                  SizedBox(
                    height: 55,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: _firstController!.text == "" ||
                                _lastController!.text == ''
                            ? null
                            : () async {
                                isLoading(true);
                                if (_firstController!.text != widget.firstName &&
                                    _lastController!.text != widget.lastName) {
                                  changedFirstName =
                                      await getFirstNameChanged();
                                  changedLastName = await getLastNameChanged();
                                } else if (_firstController!.text !=
                                    widget.firstName) {
                                  changedFirstName =
                                      await getFirstNameChanged();
                                } else {
                                  changedLastName = await getLastNameChanged();
                                  print("=====$changedLastName");
                                }
                                if (changedFirstName || changedLastName) {
                                  isLoading(false);
                                  Navigator.pushNamed(
                                      context, '/profile_edit_tab');
                                } else {
                                  final snackBar = SnackBar(
                                    content: const Text('Something Wrong!'),
                                    action: SnackBarAction(
                                      label: 'Retry',
                                      onPressed: () {
                                        // Some code to undo the change.
                                      },
                                    ),
                                  );

                                  // Find the ScaffoldMessenger in the widget tree
                                  // and use it to show a SnackBar.
                                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: _firstString == '' || _lastString == ''
                              ? Colors.grey
                              : Color(0xffFF8F68),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),

                        ),
                        child: loading
                            ? SizedBox(
                                height: 18.0,
                                width: 18.0,
                                child: new CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  backgroundColor: Colors.grey,
                                ),
                              )
                            : Text(
                                'Save',
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 18,
                                    color: Colors.white),
                              )),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
