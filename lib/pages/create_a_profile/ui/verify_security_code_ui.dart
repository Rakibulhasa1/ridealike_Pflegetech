import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/create_a_profile/bloc/verify_security_code_bloc.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/pages/create_a_profile/response_model/verify_phone_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:shimmer/shimmer.dart';





class VerifySecurityCodeUi extends StatefulWidget {
  State createState() => new VerifySecurityCodeUiState();
}

class VerifySecurityCodeUiState extends State<VerifySecurityCodeUi> {
  final securityCodeBloc = VerifySecurityCodeBloc();
  final storage = FlutterSecureStorage();
  bool _hasError = false;
  bool _hasMessage = false;
  bool _isLoading = false;
  // bool _isInit = true;
  int endTime = 0;
 CreateProfileResponse? createProfileResponse;
  final TextEditingController textCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Verify Security Code"});
    Future.delayed(Duration.zero, (){
      createProfileResponse = ModalRoute.of(context)!.settings.arguments as CreateProfileResponse;
      print('addphoneResponse ${createProfileResponse!.user!.phoneNumber}');
      sendCode();
    });


  } //
  // = DateTime.now().millisecondsSinceEpoch + 1000 * 30;

  void onEnd() {
    print('onEnd');
    if(!mounted) return;
    setState(() {
      endTime = 0;
    });
  }

  submit() {
    FocusScope.of(context).requestFocus(FocusNode());
    securityCodeBloc.addCode(createProfileResponse!).then((value) {
      AppEventsUtils.logEvent("registration_otp_add",
          params: {"otp": "true",}
      );
      securityCodeBloc.changedTextCode.call('');
      VerifyPhoneResponse response = value;
      if (response != null && response.status!.success == true) {

        Navigator.pushNamed(context, '/verify_identity_ui',
            arguments: json.encode(createProfileResponse!.toJson()) )
            .then((value) {
          storage.delete(key: 'photo');
        });
      }
    });
  }

  void sendCode() async{
    setState(() {
      _isLoading = true;
    });

    var sendCodeResponse = await securityCodeBloc.resendVerificationCode(createProfileResponse!);

    if(sendCodeResponse['Status'] != null){
      endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 180;
    }else if(int.parse(sendCodeResponse['message']) < 181){
      endTime = DateTime.now().millisecondsSinceEpoch + 1000 * int.parse(sendCodeResponse['message']);
    }else{
      endTime = 0;
      _hasError = true;
    }

    setState(() {
      _isLoading = false;
    });
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

      //Content of tabs
      body: _isLoading ?
      SingleChildScrollView(
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
                ) :
      SingleChildScrollView(
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
                            child: Text(
                              'Enter your verification code',
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
                                borderRadius: BorderRadius.circular(8)),
                            child: StreamBuilder<String>(
                                stream: securityCodeBloc.textCode(),
                                builder: (context, snapshot) {
                                  return TextField(
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.number,
                                    onChanged:(value) {
                                      securityCodeBloc.changedTextCode.call(value);
                                      securityCodeBloc.changedMessageTextCode.call("");
                                      if(value.length ==5) {
                                        submit();
                                      }
                                    } ,
                                    controller: textCodeController,
                                    /*onSubmitted: snapshot.hasData ? (value) {
                                      securityCodeBloc.changedMessageTextCode.call("");
                                      if(snapshot.data.length ==5) {
                                        submit();
                                      }
                                    } : null,*/
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
                                        hintText: 'Please enter verification code.'),
                                  );
                                }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Resend code
              endTime == null || endTime == 0 ?
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        // setState(() {
                        //   endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 5;
                        // });
                        sendCode();
                      },
                      child: Text(
                        'Resend code',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: Color(0xFF371D32)),
                      ),
                    ),
                  ),
                ],
              ):Container(),
//              _hasError || _hasMessage ? SizedBox(height: 25) : new Container(),
             endTime != null &&  endTime != 0  ?
             CountdownTimer(
                endTime: endTime,
                onEnd: onEnd,
               widgetBuilder: (_, CurrentRemainingTime? time) {
                 if (time == null) {
                   return null!;
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
              SizedBox(height: 8,),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        StreamBuilder<String>(
                            stream: securityCodeBloc.message,
                            builder: (context, messageSnapshot) {
                              return Column(crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                              messageSnapshot.hasData && messageSnapshot.data != null?
                                      Text('${messageSnapshot.data}.',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF5CAEAC),
                                          ),
                                        ):Container(),
                                      SizedBox(height: 8,),
                                      textCodeController.text.length!=0 && messageSnapshot.hasError && messageSnapshot.data == null?
                              Text('${ messageSnapshot.error.toString()}.',
                              style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xFFF55A51),),) : Container(),
                                    ],
                                  );
                                   // messageSnapshot.hasError && messageSnapshot.data == null
                                   //    ? Text('${ messageSnapshot.error.toString()}.',
                                   //        style: TextStyle(
                                   //          fontFamily: 'Urbanist',
                                   //          fontSize: 14,
                                   //          color: Color(0xFFF55A51),
                                   //        ),
                                   //      )
                                   //    : Container();
                            }),
                      ],
                    ),
                  ),
                ],
              ),
              //error//

//               Row(children: <Widget>[
//                        Expanded(
//                          child: Column(
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: <Widget>[
//                              StreamBuilder<String>(
//                                stream:securityCodeBloc.error,
//                                builder: (context, snapshot) {
//                                  return Text(snapshot.hasError?snapshot.error.toString() :'',
//                                    style: TextStyle(
//                                      fontFamily: 'Urbanist',
//                                      fontSize: 14,
//                                      color: Color(0xFFF55A51),
//                                    ),
//                                  );
//                                }
//                              ),
//                            ],
//                          ),
//                        ),
//                      ],
//                    )
//           ,
              // Error message //
//               Row(children: <Widget>[
//                        Expanded(
//                          child: Column(
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            children: <Widget>[
//                              StreamBuilder<String>(
//                                stream: securityCodeBloc.message,
//                                builder: (context, snapshot) {
//                                  return Text(snapshot.hasData?snapshot.data.toString():'',
//                                    style: TextStyle(
//                                      fontFamily: 'Urbanist',
//                                      fontSize: 14,
//                                      color: Color(0xFF5CAEAC),
//                                    ),
//                                  );
//                                }
//                              ),
//                            ],
//                          ),
//                        ),
//                      ],
//                    )
              if(_hasError) Text('Too many attempts! Please try again later.',
                style: TextStyle(color: Colors.red),),
            ],
          ),
        ),
      ),
    );
  }
}
