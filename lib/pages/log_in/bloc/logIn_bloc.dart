import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/pages/log_in/request_service/logIn.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:rxdart/rxdart.dart';

class LogInBloc extends Object with Validators implements BaseBloc {
  //controller//
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _errorController = BehaviorSubject<String>();
  final _progressIndicatorController = BehaviorSubject<bool>();
  final _buttonController = BehaviorSubject<bool>();

  final storage = new FlutterSecureStorage();

  //sink data//
  Stream<bool> get button => _buttonController.stream;

  Function(bool) get changedButton => _buttonController.sink.add;

  Function(String) get changedEmail => _emailController.sink.add;

  Function(String) get changedError => _errorController.sink.add;

  Function(String) get changedPassword => _passwordController.sink.add;

  //get data//

  Function(bool) get changedProgressIndicator =>
      _progressIndicatorController.sink.add;

  Stream<String> get email =>
      _emailController.stream.transform(logInEmailValidator);

  Stream<String> get error => _errorController.stream.transform(errorValidator);

  Stream<String> get password =>
      _passwordController.stream.transform(logInPasswordValidator);

  Stream<bool> get progressIndicator =>
      _progressIndicatorController.stream.transform(progressIndicatorValidator);

  Stream<bool> get singInButton =>
      Rx.combineLatest([email, password], (values) {
        if (values[0] == null ||
            values[0] == '' ||
            values[1] == null ||
            values[1] == '') {
          return false;
        } else {
          return true;
        }
      });

  @override
  void dispose() {
    _emailController.close();
    _passwordController.close();
    _errorController.close();
    _progressIndicatorController.close();
    _buttonController.close();
  }

  signInButton() async {
    String emailValue = _emailController.stream.value.toLowerCase();
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z]+(\.[a-zA-Z]+)*\.[a-zA-Z]+[a-zA-Z]+$")
        .hasMatch(emailValue);
//    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailValue);
    if (emailValid == false) {
      _emailController.sink.addError('Email formation is not correct');
      return null;
    }
    String passValue = _passwordController.stream.value;

    _buttonController.sink.add(false);
    _progressIndicatorController.sink.add(true);
    var response = await attemptSignIn(emailValue.toLowerCase(), passValue);
    _progressIndicatorController.sink.add(false);

    print('logInRes${response.body}');
    var signInResponse =
        CreateProfileResponse.fromJson(json.decode(response.body!));

    if (signInResponse != null && signInResponse.user != null) {
      AppEventsUtils.logEvent("user_login", params: {
        "email": emailValue.toLowerCase(),
        "login_device_type": "Smartphone"
      });
      await storage.delete(key: 'profile_id');
      await storage.delete(key: 'user_id');
      // await storage.delete(key: 'user_emailId');
      await storage.write(key: 'jwt', value: signInResponse.jWT);

      return signInResponse;
    } else {
      _buttonController.sink.add(true);
      var _error;
      if (json.decode(response.body!)['message'] ==
          'Could not fetch user data: mongo: no documents in result') {
        _error = 'User not found.';
      } else if (json.decode(response.body!)['message'] ==
          'Payload is not valid') {
        _error = 'Incorrect password format';
      } else if (json.decode(response.body!)['message'] ==
          'Email and password does not match') {
        _error = 'Email and password do not match';
      } else {
        _error = json.decode(response.body!)['message'];
        print("logInError$_error");
      }
      print("logInError$_error");

      _errorController.sink.add(_error);

      return null;
    }
  }

  bool signInButtonValidation() {
    String emailValue = _emailController.stream.value.toLowerCase();
    String passValue = _passwordController.stream.value;
    if (emailValue == null ||
        emailValue.trim() == '' ||
        passValue == null ||
        passValue.trim() != '') {
      return false;
    } else {
      return true;
    }
  }
}
