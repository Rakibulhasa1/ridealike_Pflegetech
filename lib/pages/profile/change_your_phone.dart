import 'dart:async';
import 'dart:convert';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:shimmer/shimmer.dart';


Future<RestApi.Resp> updatePhoneNumber(data) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(sendOTPUrl,
    json.encode(
        {"ProfileID": data['ProfileID'], "PhoneNumber": data['PhoneNumber']}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
Future<RestApi.Resp> sendPhoneOTP(data) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(sendOTPUrl,
    json.encode(
        {"ProfileID": data['ProfileID'], "PhoneNumber": data['PhoneNumber']}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

//Future<RestApi.Resp> sendPhoneVerificationCode(profileID) async {
//  final completer = Completer<RestApi.Resp>();
//  RestApi.callAPI(
//    '$SERVER_IP/v1/profile.ProfileService/SendPhoneVerificationCode',
//    json.encode({
//      "ProfileID": profileID,
//    }),
//  ).then((resp) {
//    completer.complete(resp);
//  });
//  return completer.future;
//}

Future<RestApi.Resp> verifyPhone(String profileID, String phoneNumber, String code) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    verifyPhoneUrl,
    json.encode({
      "ProfileID": profileID,
      "PhoneNumber": phoneNumber,
      "VerificationCode": code,
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

class ChangePhoneNumber extends StatefulWidget {
  @override
  _ChangePhoneNumberState createState() => _ChangePhoneNumberState();
}

class _ChangePhoneNumberState extends State<ChangePhoneNumber> {
  Map? passData;


  bool? _isButtonDisabled;
  bool _isButtonPressed = false;
  bool _showCodeInput = false;
  bool _isLoading = false;

  var _digitCount;
  var otpCode;
  bool _hasError = false;
  bool _hasMessage = false;

  String _error = '';
  String _message = '';
  String newPhoneNumber ='';
  String _dropdownInitialSelection = '+1';

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _resendCodeController = TextEditingController();

  String dropdownValue = '';
  int endTime =0;

  @override
  void initState() {
    super.initState();
    _isButtonDisabled = true;

    Future.delayed(Duration.zero, (){
      passData = ModalRoute.of(context)!.settings.arguments as Map;
    });
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
  void dispose() {
    super.dispose();

    _phoneController.clear();
    _resendCodeController.clear();
  }

//  _phoneNbValidation(String value) {
//    setState(() {
//      _digitCount = value.length;
//    });
//
//    if (_digitCount == 14) {
//      setState(() {
//        _isButtonDisabled = false;
//      });
//    } else {
//      setState(() {
//        _isButtonDisabled = true;
//      });
//    }
//  }

  void _countCodeLength(String value) async {
    setState(() {
      _error = '';
      _hasError = false;
    });
    if (value.length == 5) {
      var code = _resendCodeController.text;

      var res = await verifyPhone(passData!['Profile']['ProfileID'],
         newPhoneNumber , code);

      if (json.decode(res.body!)['Status']['success']==true) {
        _hasError=false;
        passData!['Profile']['PhoneNumber'] = newPhoneNumber;
        Navigator.pushNamed(context, '/profile_edit_tab',);
      } else {
        setState(() {
          _hasMessage = false;
          _error = 'Code not valid.';
          _hasError = true;
        });
      }
    }
  }

  void onEnd() {
    print('onEnd');
    if(!mounted) return;
    setState(() {
      endTime =0;
    });
  }

  void sendCode() async {
    //loading starts
    setState(() {
      _isLoading = true;
    });

    newPhoneNumber = dropdownValue + _phoneController.text;
    var data = {'ProfileID': passData!['Profile']['ProfileID'],
      'PhoneNumber':newPhoneNumber};

    var res = await sendPhoneOTP(data);
    var resData = json.decode(res.body!);

    if (res!=null && res.statusCode == 200){
      if(resData['Status']['success']==true){
        endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;
        _isButtonDisabled = true;
        _showCodeInput = true;
        _message = 'Code sent successfully';
        _hasMessage = true;
      }
      else{
        if(int.parse(resData['Status']['error']) < 181){
          endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;
          _isButtonDisabled = true;
          _showCodeInput = true;
          _message = 'Code sent successfully';
          _hasMessage = true;
        }
        else{
          _error = 'Too many attempts! Please try again later.';
          _hasError = true;
          _hasMessage = false;
        }
    }
    }
    else {
      _hasError = true;
      _error = json.decode(res.body!)['details'][0]['Message'];
    }

    //loading ends
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          // 'Change your phone',
          'Change your mobile number',
          style: TextStyle(
              color: Color(0xff371D32),
              fontSize: 16,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.pop(context,passData!['']),
        ),
        elevation: 0.0,
      ),
      body: _isLoading ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 220,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, right: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: MediaQuery.of(context).size.width / 3,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 14,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 14,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ) : PageView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                // Phone number input
                Column(
                  children: [

                    //old number text filed//
//                    Row(
//                      children: <Widget>[
//                        Expanded(
//                          child: Column(
//                            children: [
//                              SizedBox(
//                                width: double.maxFinite,
//                                child: Container(
//                                  decoration: BoxDecoration(
//                                      color: Color(0xFFF2F2F2),
//                                      borderRadius: BorderRadius.circular(8)),
//                                  child: TextFormField(
//                                    controller: _phoneController,
//                                    onChanged: _phoneNbValidation,
//                                    maxLength: 14,
//                                    inputFormatters: [
//                                      FilteringTextInputFormatter.allow(
//                                          RegExp(r'[0-9+]'),replacementString: '')
//                                    ],
//                                    keyboardType: TextInputType.number,
//                                    textInputAction: TextInputAction.done,
//                                    decoration: InputDecoration(
//                                        contentPadding: EdgeInsets.all(18.0),
//                                        border: InputBorder.none,
//                                        labelText: 'Phone',
//                                        labelStyle: TextStyle(
//                                          fontFamily: 'Urbanist',
//                                          fontSize: 12,
//                                          color: Color(0xFF353B50),
//                                        ),
//                                        hintText: 'Enter phone number',
//                                        counterText: ""),
//                                  ),
//                                ),
//                              ),
//                            ],
//                          ),
//                        ),
//                      ],
//                    ),
//country code//
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
                                  child:  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: CountryCodePicker(flagWidth: 20,
                                      alignLeft: true,
                                      comparator: (a, b) {
                                        return a.name!.compareTo(b.name!);
                                      },
                                      initialSelection: _dropdownInitialSelection,
                                      onChanged: ( newValue) {
                                      _dropdownInitialSelection = newValue.toString();
                                        setState(() {
                                          dropdownValue=newValue.toString();
                                        });

                                      },),
                                  ),

                                  // DropdownButtonFormField<String>(
                                  //   isDense: true,
                                  //   decoration: InputDecoration(
                                  //     contentPadding: EdgeInsets.all(16.0),
                                  //     border: InputBorder.none,
                                  //     labelText: 'Country',
                                  //     labelStyle: TextStyle(
                                  //       fontFamily: 'Urbanist',
                                  //       fontSize: 12,
                                  //       color: Color(0xFF353B50),
                                  //     ),
                                  //   ),
                                  //   value: dropdownValue,
                                  //   icon: Icon(
                                  //       Icons.keyboard_arrow_down,
                                  //       color: Color(0xFF353B50)
                                  //   ),
                                  //   onChanged: (String newValue) {
                                  //     setState(() => dropdownValue = newValue);
                                  //   },
                                  // ),
                                  // DropdownButtonFormField<String>(
                                  //   isDense: true,
                                  //   decoration: InputDecoration(
                                  //     contentPadding: EdgeInsets.all(16.0),
                                  //     border: InputBorder.none,
                                  //     labelText: 'Country',
                                  //     labelStyle: TextStyle(
                                  //       fontFamily: 'Urbanist',
                                  //       fontSize: 12,
                                  //       color: Color(0xFF353B50),
                                  //     ),
                                  //   ),
                                  //   value: dropdownValue,
                                  //   icon: Icon(
                                  //       Icons.keyboard_arrow_down,
                                  //       color: Color(0xFF353B50)
                                  //   ),
                                  //   onChanged:
                                  //       (String newValue) {
                                  //     setState(() => dropdownValue = newValue);
                                  //   },
                                  //   items: <String>['+1', '+91', '+880']
                                  //       .map<DropdownMenuItem<String>>((String item) {
                                  //     return DropdownMenuItem<String>(
                                  //       value: item,
                                  //       child: Text(item),
                                  //     );
                                  //   }
                                  //   ).toList(),
                                  // ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        //phone number field//
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
                                        return 'Mobile number is required';
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
                                        labelText: 'Mobile number',
                                        labelStyle: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 12,
                                          color: Color(0xFF353B50),
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
                    SizedBox(height: 10),
                    // Text
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'A verification code will be sent to this number.',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Color(0xff371D32)),
                      ),
                    ),
                    SizedBox(height: 10),
                    // Code input
                    _showCodeInput
                        ? Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: TextFormField(
                                          controller: _resendCodeController,
                                          onChanged: _countCodeLength,
                                          maxLength: 5,
                                          textInputAction: TextInputAction.done,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          keyboardType: TextInputType.number,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Secure code is required';
                                            }
                                            return null;
                                          },
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(22.0),
                                              border: InputBorder.none,
                                              labelText: 'Secure code',
                                              labelStyle: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 12,
                                                color: Color(0xFF353B50),
                                              ),
                                              counterText: '',
                                              hintText:
                                                  'Please enter secure code'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : new Container(),
                    SizedBox(height: 10),

                     //Resend code
                    _showCodeInput ?
                    endTime == null || endTime == 0 ?
                    Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              GestureDetector(
                                onTap: sendCode,
                                child: Text(
                                  'Resend code',
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xFF371D32)),
                                ),
                              ),
                            ],
                          ):Container() : new Container(),
                    endTime != null &&  endTime != 0  ?
                    CountdownTimer(
                      endTime: endTime,
                      onEnd: onEnd,
                      widgetBuilder: (_, CurrentRemainingTime? time) {
                        if (time == null) {
                          return Container();
                        }
                        String min = time.min != null ? time.min.toString().padLeft(2,'0'): '00';
                        String sec = time.sec != null ? time.sec.toString().padLeft(2, '0'): '00';
                        return Align(alignment: Alignment.centerLeft,
                            child: Text('$min:$sec',style:TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xFF371D32)) ,));
                      },
                    ): Container(),
                    SizedBox(height: 5,),
                    _hasError || _hasMessage ? SizedBox(height: 20) : new Container(),
                    _hasError ?
                    Row(
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
                          ) : new Container(),
                    _hasMessage ?
                    Row(children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _message,
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


                // Submit button
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child:
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Color(0xffFF8F68),
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),

                              ),
                               onPressed: _isButtonDisabled!
                                  ? null
                                  : sendCode,
                              child: _isButtonPressed
                                  ? SizedBox(
                                      height: 18.0,
                                      width: 18.0,
                                      child: new CircularProgressIndicator(
                                          strokeWidth: 2.5),
                                    )
                                  : Text(
                                      'Change phone',
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
        ],
      ),
    );
  }
}
