import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';

import '../../utils/app_events/app_events_utils.dart';

// final _formKey = GlobalKey<FormState>();

final TextEditingController _addreesController = TextEditingController();
final TextEditingController _cityController = TextEditingController();
final TextEditingController _provinceController = TextEditingController();
final TextEditingController _postalCodeController = TextEditingController();
final TextEditingController _countryController = TextEditingController();
final TextEditingController _nameController = TextEditingController();
final TextEditingController _iBANController = TextEditingController();



class BankTransfer extends StatefulWidget {
  @override
  State createState() => BankTransferState();
}

class BankTransferState extends State<BankTransfer> {

  bool? _isButtonDisabled;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Profile Setup Bank Transfer"});
    _isButtonDisabled = true;

    _addreesController.addListener(_checkInputValue);
    _cityController.addListener(_checkInputValue);
    _provinceController.addListener(_checkInputValue);
    _postalCodeController.addListener(_checkInputValue);
    _countryController.addListener(_checkInputValue);
    _nameController.addListener(_checkInputValue);
    _iBANController.addListener(_checkInputValue);
  }

  void _checkInputValue() {
    // var name = _nameController.text;
    // var email = _emailController.text;
    // var password = _passwordController.text;

    // if (name != '' && email != '' && password != '') {
    //   setState(() {
    //     _isButtonDisabled = false;
    //   });
    // }
  }

  @override
  Widget build (BuildContext context) { 

    final  dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    
    return Scaffold(
      backgroundColor: Colors.white,
      
      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        // actions: <Widget>[
        //   Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     children: <Widget>[
        //       GestureDetector(
        //         onTap: () {

        //         },
        //         child: Center(
        //           child: Container(
        //             margin: EdgeInsets.only(right: 16),
        //             child: Text('Save & Exit',
        //               style: TextStyle(
        //                 fontFamily: 'Urbanist',
        //                 fontSize: 16,
        //                 color: Color(0xFFFF8F62),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ],
        elevation: 0.0,
      ),

      body: new SingleChildScrollView(
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
                            child: Text('Set up bank transfer',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 36,
                                color:Color(0xFF371D32),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('icons/Payout-Payout.png'),
                ],
              ),
              SizedBox(height: 30),
              // Section header
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text('Enter the account address',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 18,
                              color: Color(0xFF371D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              // Address
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
                              controller: _addreesController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Your address is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(22.0),
                                border: InputBorder.none,
                                labelText: 'Address',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ),
                                hintText: 'Please enter your address'
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
              // City
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
                              controller: _cityController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'City is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(22.0),
                                border: InputBorder.none,
                                labelText: 'City',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ),
                                hintText: 'Please enter city'
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
              // Province & Postal code
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
                              controller: _provinceController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Province is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(22.0),
                                border: InputBorder.none,
                                labelText: 'Province',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ),
                                hintText: 'Please enter province'
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10),
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
                              controller: _postalCodeController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Postal Code is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(22.0),
                                border: InputBorder.none,
                                labelText: 'Postal Code',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ),
                                hintText: 'Please enter postal Code'
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
              // Country
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
                              controller: _countryController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Country is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(22.0),
                                border: InputBorder.none,
                                labelText: 'Country',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ),
                                hintText: 'Please enter country'
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
              // Section header
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text('Enter bank transfer information',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 18,
                              color: Color(0xFF371D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              // Name
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
                              controller: _nameController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Name is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(22.0),
                                border: InputBorder.none,
                                labelText: 'Name',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ),
                                hintText: 'Please enter name'
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
              // IBAN
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
                              controller: _iBANController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'IBAN is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(22.0),
                                border: InputBorder.none,
                                labelText: 'IBAN',
                                labelStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF353B50),
                                ),
                                hintText: 'Please enter IBAN'
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),
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
                            onPressed: () => Navigator.of(context).pop(),
                              // Navigator.pushNamed(
                              //   context,
                              //   '/review_your_listing',
                              //   arguments: receivedData,
                              // );
                            // },
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

Future<http.Response> attemptSignUp(String name, String email, String password) async {
  var res = await http.post(
    Uri.parse(registerUrl),
    // registerUrl as Uri,
    body: json.encode(
      {
        "Email": email,
        "Password": password,
        "Name": name
      }
    ),
  );
  
  return res;
}

void displayDialog(
BuildContext context, String title, String text) => showDialog(
  context: context,
  builder: (context) =>
    AlertDialog(
      title: Text(title),
      content: Text(text)
    ),
);