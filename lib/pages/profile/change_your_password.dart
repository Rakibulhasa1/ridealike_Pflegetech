import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/create_a_profile/bloc/create_profile_bloc.dart';


Future<RestApi.Resp> updatePassword(data) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    updatePasswordUrl,
    json.encode({
      "Email": data['Email'],
      "Password": data['Password'],
      "NewPassword": data['NewPassword'],
      "UserID": data['UserID']
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

class ChangePassword extends StatefulWidget {
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
 Map? passData;
  var createProfileBloc = CreateProfileBloc();
  bool currentPasswordVisible = true;
  bool newPasswordVisible = true;
  // bool verifyPasswordVisible;

  bool _hasError = false;
  bool _error1 = false;
  var _error11 ;
  bool _error2 = false;
  bool _error3 = false;
  bool _error4= false;
  bool _isSamePasswordError = false;
  String _samePasswordError = '';
  String _serverError = '';
  String characterError = '';
  String lowerUpperError = '';
  String numberError = '';
  String whiteSpaceError = '';
  bool?   noSpace;
  _passWordChange(String value) {
  bool  noSpace = !value.contains(' ');
    if (value.length < 8 ||
        !validateCharCase(value) ||
        !validateSpecChar(value)) {
      setState(() {
        _hasError = true;
      });
      if (value.length < 8) {
        setState(() {
          _error1 = true;
          characterError='• Be at least 8 characters long.';

        });
      } else {
        setState(() {
          _error1 = false;
          characterError='• Be at least 8 characters long.';
        });
      }
      if (!validateCharCase(value)) {
        setState(() {
          _error2 = true;
          lowerUpperError='• Include both lower and upper case.';
        });
      } else {
        setState(() {
          _error2 = false;
          lowerUpperError='• Include both lower and upper case.';
        });
      }
      if (!validateSpecChar(value)) {
        setState(() {
          _error3 = true;
          numberError='• Include at least 1 number or symbol.';

        });
      }
      else {
        setState(() {
          _error3 = false;
          numberError='• Include at least 1 number or symbol.';
        });
      }
      if (!noSpace) {
        setState(() {
          _error4 = true;
          whiteSpaceError='• Exclude white spaces.';

        });
      }
      else {
        setState(() {
          _error4 = false;
          whiteSpaceError='• Exclude white spaces.';
        });
      }
    } else {
      setState(() {
        _hasError = false;
      });
    }
  }
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    passData = ModalRoute.of(context)!.settings.arguments as Map;
    bool _isButtonPressed = false;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Change your password',
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
      body: Center(
        child: SingleChildScrollView(
          child:   Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    // Current password
                    Row(
                      children: [
                        Expanded(
                          child:
                          Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius:
                                      BorderRadius.circular(8.0)),
                                  child: TextFormField(
                                    controller: _currentPasswordController,
                                    textInputAction: TextInputAction.done,
                                    // onChanged: _passWordChange,
                                    obscureText: currentPasswordVisible,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'Current password',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Enter password',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          currentPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Color(0xff353B50),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            currentPasswordVisible =
                                            !currentPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                  // New password
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
                                      borderRadius:
                                      BorderRadius.circular(8.0)),
                                  child: TextFormField(
                                    controller: _newPasswordController,
                                    textInputAction: TextInputAction.done,
                                      onChanged: _passWordChange,
                                    obscureText: newPasswordVisible,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'New password',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Enter password',
                                      suffixIcon:
                                      IconButton(
                                        icon: Icon(
                                          newPasswordVisible
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: Color(0xff353B50),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            newPasswordVisible =
                                            !newPasswordVisible;
                                          });
                                        },
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
                    SizedBox(height: 15),
                    _hasError
                        ? Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Your new password needs to:',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  color: Color(0xFFF55A51),
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                characterError,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  color: _error1
                                      ? Color(0xFFF55A51)
                                      : Color(0xFF5CAEAC),
                                ),
                              ),
                              Text(_error2?'• Include both lower and upper case.':
                                lowerUpperError,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  color: _error2
                                      ? Color(0xFFF55A51)
                                      : Color(0xFF5CAEAC),
                                ),
                              ),
                              Text(
                                numberError,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  color: _error3
                                      ? Color(0xFFF55A51)
                                      : Color(0xFF5CAEAC),
                                ),
                              ),
                              Text(
                               whiteSpaceError,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  color: _error4
                                      ? Color(0xFFF55A51)
                                      : Color(0xFF5CAEAC),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                        : new Container(),
                    SizedBox(height: 15),
                   _isSamePasswordError
                        ? Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                _samePasswordError,
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
                  ],
                ),
                // Submit button
                Row(
                  children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _serverError != ''
                              ? Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      _serverError,
                                      style: TextStyle(
                                        fontFamily:
                                        'Urbanist',
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
                          SizedBox(height: MediaQuery.of(context).size.height*.35,),
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
                                var currentPass =
                                    _currentPasswordController.text;
                                var newPass = _newPasswordController.text;
                              noSpace = !newPass.contains(' ');
                                // bool validateLengthCase = newPass.length >= 8;
                                // bool validateCharCase = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z]).{2,}$').hasMatch(newPass);
                                // bool validateSpecChar = RegExp(r'^(?=.*?[!@#\$&*~0-9]).{1,}$').hasMatch(newPass);
                                //
                                //
                                // List<PasswordError> errors = List(4);
                                // if (!validateLengthCase || !validateCharCase || !validateSpecChar || !noSpace) {
                                //   errors[0] =
                                //       PasswordError(validateLengthCase, '• Be at least 8 characters long.');
                                //   errors[1] = PasswordError(
                                //       validateCharCase, '• Include both lower and upper case.');
                                //   errors[2] = PasswordError(
                                //       validateSpecChar, '• Include at least 1 number or symbol.');
                                //   errors[3] = PasswordError(
                                //       noSpace, '• Exclude white spaces.');
                                //
                                //   setState(() {
                                //     _hasError = true;
                                //   });
                                //   return;
                                // }else{
                                // setState(() {
                                //   _hasError=false;
                                // });
                                // }
                                if (_newPasswordController.text!=''&& currentPass == newPass) {
                                  setState(() {
                                    _isSamePasswordError = true;
                                    _samePasswordError =
                                    'New password should not be the same as current password.';
                                  });
                                } else {
                                  setState(() {
                                    _isSamePasswordError = false;
                                  });
                                }
                                //
                                // if (newPass.length < 8 ||
                                //     !validateCharCase(newPass) ||
                                //     !validateSpecChar(newPass) ||!noSpace) {
                                //   setState(() {
                                //     _hasError = true;
                                //   });
                                //   if (newPass.length < 8) {
                                //     setState(() {
                                //       _error1 = true;
                                //     });
                                //   } else {
                                //     setState(() {
                                //       _error1 = false;
                                //     });
                                //   }
                                //
                                //   if (!validateCharCase(newPass)) {
                                //     setState(() {
                                //       _error2 = true;
                                //     });
                                //   } else {
                                //     setState(() {
                                //       _error2 = false;
                                //     });
                                //   }
                                //
                                //   if (!validateSpecChar(newPass)) {
                                //     setState(() {
                                //       _error3 = true;
                                //     });
                                //   }
                                //   else {
                                //     setState(() {
                                //       _error3 = false;
                                //     });
                                //   }
                                //   if (!noSpace) {
                                //     setState(() {
                                //       _error4 = true;
                                //     });
                                //   }
                                //   else {
                                //     setState(() {
                                //       _error4 = false;
                                //     });
                                //   }
                                // } else {
                                //   setState(() {
                                //     _hasError = false;
                                //   });
                                // }

                                if (!_hasError &&
                                    !_isSamePasswordError) {
                                  setState(() {
                                    _isButtonPressed = true;
                                  });

                                  var data = {
                                    'Email': passData!['Profile']
                                    ['Email'],
                                    'Password': currentPass,
                                    'NewPassword': newPass,
                                    'UserID': passData!['Profile']
                                    ['UserID']
                                  };

                                  var res = await updatePassword(data);

                                  if (res.statusCode == 200) {
                                    Navigator.pushNamed(
                                        context, '/profile_edit_tab');
                                  } else {
                                    setState(() {
                                      if(json.decode(res.body!)['details'][0]['Message']=='Invalid request'){
                                        _serverError='Current password is incorrect.';
                                      }else{
                                        _serverError = json.decode(res.body!)['details'][0]['Message'];

                                      }

                                    });
                                  }
                                } else {
                                  setState(() {
                                    _isButtonPressed = false;
                                    _serverError = '';
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
                                'Change password',
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
      ),
    );
  }
}

validateCharCase(String value) {
  String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z]).{2,}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(value);
}

validateSpecChar(String value) {
  String pattern = r'^(?=.*?[!@#\$&*~0-9]).{1,}$';
  RegExp regExp = new RegExp(pattern);
  return regExp.hasMatch(value);
}
