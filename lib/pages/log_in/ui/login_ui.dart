import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/pages/log_in/bloc/logIn_bloc.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
//profile Status utils
import 'package:ridealike/utils/profile_status.dart';


class LoginUi extends StatefulWidget {
  @override
  State createState() => LoginUiState();
}

class LoginUiState extends State<LoginUi> {
  final logInBloc = LogInBloc();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  dynamic receivedData;
  final storage = new FlutterSecureStorage();
  bool _hidePassword = true;
  bool _isPasswordChecked = false;
  String initialEmailData = '';

  @override
  Widget build(BuildContext context) {
    receivedData = ModalRoute.of(context)!.settings.arguments;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
          backgroundColor:Color(0xffFF8F68),
              elevation: 0,iconTheme: IconThemeData(
        color: Colors.white,
      ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height / 2.5,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("images/login_top.png"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 25,
                      ),
                      Text(
                        "Welcome \nBack",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontFamily: 'Urbanist'
                        ),
                      ),
                    ],
                  ),
                ) // Foreground widget here
            ),
            receivedData != null && receivedData['MESSAGE'] != null
                ? SizedBox(height: 40)
                : SizedBox(height: 60),
            receivedData != null &&
                receivedData['MESSAGE'] != null &&
                receivedData['MESSAGE'] == 'Email already exists'
                ? Text(
              'It seems like you already have an account with this email address. Please sign in instead.',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 14,
                color: Colors.black,
              ),
            )
                : Container(),

            receivedData != null && receivedData['MESSAGE'] != null
                ? SizedBox(
              height: 20,
            )
                : Container(),

            /// Email
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: StreamBuilder<String>(
                      stream: logInBloc.email,
                      builder: (context, emailSnapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: double.maxFinite,
                              child: TextFormField(
                                controller: _emailController,
                                onChanged: (email) {
                                  logInBloc.changedError.call('');
                                  logInBloc.changedEmail.call(email);
                                },
                                keyboardType: TextInputType.emailAddress,
                                maxLines: 1,
                                decoration: InputDecoration(

                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Color(0xffFF8F68)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide:
                                    BorderSide(color: Color(0xffFF8F68)),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                      left: 10, right: 10, top: 10),
                                  labelStyle: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                  ),
                                  labelText: 'Email', hintStyle: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14, // Adjust the font size as needed
                                  color: Colors.grey, // You can customize the color as well
                                ),

                                  prefixIcon: Icon(
                                    Icons.email_outlined,
                                    color: Color(0xffFF8F68),
                                  ),
                                ),
                              ),
                            ),
                            emailSnapshot.hasError && emailSnapshot.error != ''
                                ? SizedBox(
                              height: 10,
                            )
                                : Container(),
                            emailSnapshot.hasError && emailSnapshot.error != ''
                                ? Align(
                              child: Text(
                                'Please enter an email id',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  color: Color(0xFFF55A51),
                                ),
                              ),
                              alignment: Alignment.centerLeft,
                            )
                                : Container(),
                            emailSnapshot.hasError && emailSnapshot.error != ''
                                ? SizedBox(
                              height: 8,
                            )
                                : Container(),
                          ],
                        );
                      }),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            SizedBox(height: 15),
            // Password
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: StreamBuilder<String>(
                      stream: logInBloc.password,
                      builder: (context, snapshot) {
                        return TextField(
                          controller: _passwordController,
                          onChanged: (password) {
                            logInBloc.changedError.call('');
                            logInBloc.changedPassword.call(password);
                          },
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffFF8F68)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xffFF8F68)),
                            ),
                            contentPadding:
                            EdgeInsets.only(left: 10, right: 10, top: 15),
                            labelStyle: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                            ),
                            labelText: 'Password',hintStyle: TextStyle(
                            fontFamily: 'Urbanist'),
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Color(0xffFF8F68),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _hidePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Color(0xff353B50),
                              ),
                              onPressed: () {
                                setState(() {
                                  _hidePassword = !_hidePassword;
                                });
                              },
                            ),
                          ),
                        );
                      }),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              //mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 10,
                ),
                Checkbox(
                  checkColor: Colors.white,
                  value: _isPasswordChecked,
                  onChanged: (bool? value) {
                    setState(() {
                      _isPasswordChecked = value!;
                    } );
                  },
                ),
                Text(
                  'Save Password',
                  style: TextStyle(
                      color: Color(0xffFF8F68),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Urbanist'),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/forgot_password');
                  },
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                        color: Color(0xffFF8F68),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,

                        fontFamily: 'Urbanist'),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: StreamBuilder<String>(
                      stream: logInBloc.error,
                      builder: (context, snapshot) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            snapshot.hasError
                                ? Text(
                              snapshot.hasError
                                  ? snapshot.error.toString()
                                  : '',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 14,
                                color: Color(0xFFF55A51),
                              ),
                            )
                                : Container(),
                            snapshot.hasError
                                ? SizedBox(height: 15)
                                : Container(),
                          ],
                        );
                      }),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            SizedBox(height: 15),
            // Sign In button
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: SizedBox(
                    width: double.maxFinite,
                    child: StreamBuilder<bool>(
                        stream: logInBloc.singInButton,
                        builder: (context, snapshot) {
                          return StreamBuilder<bool>(
                              stream: logInBloc.button,
                              builder: (context, buttonSnapshot) {
                                return ElevatedButton(style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: snapshot.hasData &&
                                      snapshot.data! &&
                                      buttonSnapshot.data!
                                      ? Color(0xffFF8F68)
                                      : Colors.grey,
                                  padding: EdgeInsets.all(10.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),),
                                  onPressed: snapshot.hasData && snapshot.data!
                                      ? () async {
                                    CreateProfileResponse resp =
                                    await logInBloc.signInButton();
                                    print('resp$resp');
                                    AppEventsUtils.logEvent(
                                        "login_successful",
                                        params: {
                                          "email": resp.user!.email,
                                          "success": resp.status!.success,
                                          "login_device_type": "Smartphone"
                                        });
                                    if (resp == null) {
                                    } else if (!(resp
                                        .user!
                                        .registrationStatus!
                                        .termsAndConditionAccepted!)) {
                                      var arguments = resp;
                                      Navigator.pushNamed(
                                        context,
                                        '/terms_and_conditions_ui',
                                        arguments: arguments,
                                      );
                                    } else if (!(resp
                                        .user!
                                        .registrationStatus!
                                        .phoneVerified!)) {
                                      var arguments = resp;
                                      print('LogInprofileId$arguments');
                                      Navigator.pushNamed(context,
                                          '/verify_phone_number_ui',
                                          arguments: arguments);
                                    } else if (!(resp
                                        .user!
                                        .registrationStatus!
                                        .dLDocumentsSubmitted!)) {
                                      var arguments = resp;
                                      Navigator.pushNamed(
                                        context,
                                        '/verify_identity_ui',
                                        arguments: json
                                            .encode(arguments.toJson()),
                                      );
                                    } else {
                                      await storage.write(
                                          key: 'profile_id',
                                          value: resp.user!.profileID);
                                      await storage.write(
                                          key: 'user_id',
                                          value: resp.user!.userID);
                                      await storage.write(
                                          key: 'jwt', value: resp.jWT);
                                      await storage.write(
                                          key: 'user_emailId',
                                          value: resp.user!.email);
                                      if (_isPasswordChecked) {
                                        await storage.write(
                                            key: 'user_password',
                                            value:
                                            _passwordController.text);
                                      } else {
                                        await storage.delete(
                                            key: 'user_password');
                                      }
                                      if (receivedData != null &&
                                          receivedData['ROUTE'] != null) {
                                        Navigator.pushReplacementNamed(
                                            context,
                                            receivedData['ROUTE'],
                                            arguments: receivedData[
                                            'ARGUMENTS'])
                                            .then((value) => {
                                          logInBloc.changedButton
                                              .call(true)
                                        });

                                        return;
                                      } else {
                                        await ProfileStatus.init();
                                        Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                            '/discover_tab',
                                                (Route<dynamic> route) =>
                                            false);
                                      }
                                    }
                                  }
                                      : null,
                                  child: StreamBuilder<bool>(
                                      stream: logInBloc.progressIndicator,
                                      builder: (context, snapshot) {
                                        return snapshot.hasData
                                            ? SizedBox(
                                          height: 18.0,
                                          width: 18.0,
                                          child:
                                          CircularProgressIndicator(
                                              strokeWidth: 2.5),
                                        )
                                            : Text(
                                          'Log In',
                                          style: TextStyle(
                                              fontFamily:
                                              'Urbanist',
                                              fontSize: 18,
                                              color: Colors.white),
                                        );
                                      }),
                                );
                              });
                        }),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.only(left:22.0,right:22),
              child: Row(
                children: [
                  Expanded(child: Divider(
                    color: Color(0xffFF8F68),
                    thickness: 1,
                  )),
                  SizedBox(width: 10,),
                  Text("Or ",style: TextStyle(fontSize: 18, fontFamily: 'Urbanist')),
                  SizedBox(width: 10,),
                  Expanded(child: Divider(
                    thickness: 1,
                    color: Color(0xffFF8F68),
                  )),
                ],
              ),
            ),

            SizedBox(height: 10),
            // Sign Up button
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: SizedBox(
                    width: double.maxFinite,
                    child: ElevatedButton(style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: Colors.black,
                          width: 1,
                        ),
                      ),),
                      onPressed: () {
                        Navigator.pushNamed(context, '/create_profile');
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  void getEmailId() async {
    var emailID = await storage.read(key: 'user_emailId');
    if (emailID != null) {
      logInBloc.changedEmail.call(emailID);
      _emailController.text = emailID;
    } else {
      Text('please enter a email id');
      // Handle the case where emailID is null
      // For example, show an error message or provide a default value
    }
  }

  void getPassword() async {
    var password = await storage.read(key: 'user_password');
    if (password != null) {
      setState(() {
        _isPasswordChecked = true;
      });
      logInBloc.changedPassword.call(password);
      _passwordController.text = password;
    }
  }


  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Login"});
    logInBloc.changedButton.call(true);
    Future.delayed(Duration.zero, () {
      setState(() {
        receivedData = ModalRoute.of(context)!.settings.arguments;
      });
      if (receivedData != null && receivedData['EMAIL'] != null) {
        logInBloc.changedEmail.call(receivedData['EMAIL']);
        _emailController.text = receivedData['EMAIL'];
      } else {
        getEmailId();
        getPassword();
      }
    });
  }
}