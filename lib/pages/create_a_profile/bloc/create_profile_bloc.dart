import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/password_error_class.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/create_a_profile/request_service/create_profile.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:rxdart/rxdart.dart';

class CreateProfileBloc extends Object with Validators implements BaseBloc {
  //controller//
  final _firstNameController = BehaviorSubject<String>();
  final _lastNameController = BehaviorSubject<String>();
  final _emailController = BehaviorSubject<String>();
  final _passwordController = BehaviorSubject<String>();
  final _nextButtonController = BehaviorSubject<bool>();
  final _termsController = BehaviorSubject<bool>();
  final _promotionalMaterialsController = BehaviorSubject<bool>();
  final _errorController = BehaviorSubject<String>();
  final _progressIndicatorController = BehaviorSubject<int>();

  //set data//
  Function(String) get changedFirstName => _firstNameController.sink.add;

  Function(String) get changedLastName => _lastNameController.sink.add;

  Function(String) get changedEmail => _emailController.sink.add;

  Function(String) get changedPassword => _passwordController.sink.add;

  void changedPasswordWithValidation(String password, bool hasError, ) {
    _passwordController.sink.add(password);

    bool validateLengthCase = password.length >= 8;
    bool validateCharCase = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z]).{2,}$').hasMatch(password);
    bool validateSpecChar = RegExp(r'^(?=.*?[!@#\$&*~0-9]).{1,}$').hasMatch(password);
    List<PasswordError> errors = List<PasswordError>.filled(4, PasswordError(false, ''));
    bool noSpace = !password.contains(' ');

    errors[0] = PasswordError(validateLengthCase, '  Be at least 8 characters long.');
    errors[1] = PasswordError(validateCharCase, '  Include both lower and upper case.');
    errors[2] = PasswordError(validateSpecChar, '  Include at least 1 number or symbol.');
    errors[3] = PasswordError(noSpace, '  Exclude white spaces.');

    if (!validateLengthCase || !validateCharCase || !validateSpecChar || !noSpace ) {
      _passwordController.sink.addError(errors);
      return;
    }

    if (!hasError) {
      _passwordController.sink.add(password);
    }
  }


  Function(bool) get changedTerms => _termsController.sink.add;

  Function(int) get changedProgressIndicator =>
      _progressIndicatorController.sink.add;

  Function(bool) get changedPromotionalMaterials => _promotionalMaterialsController.sink.add;

  Function(String) get changedError => _errorController.sink.add;

  Function(bool) get changedNextButton => _nextButtonController.sink.add;

//get data//

  Stream<String> get firstName => _firstNameController.stream;

  Stream<String> get lastName => _lastNameController.stream;

  Stream<String> get email => _emailController.stream;

  Stream<String> get password =>
      _passwordController.stream.transform(passwordValidator);

  Stream<bool> get terms => _termsController.stream;

  Stream<bool> get button => _nextButtonController.stream;

  Stream<bool> get promotionalMaterials => _promotionalMaterialsController.stream.transform(promotionalMaterialsValidator);

  Stream<String> get error => _errorController.stream.transform(errorValidator);

  Stream<int> get progressIndicator => _progressIndicatorController.stream;

  checkEmailValidity() {
    String email = _emailController.stream.value;
    if
    (
    RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$")
        .hasMatch(email)) {
    } else {
      _emailController.sink.addError("Please provide valid email");
    }
  }

  Stream<bool> get nextButton =>
      Rx.combineLatest([firstName, lastName, email, password, terms], (values) {
        print('values $values');
        if (values[0] == '' ||
            values[1] == '' ||
            values[2] == '' ||
            values[3] == '' ||
            values[4] == false) {
          return false;
        } else {
          if (_emailController.stream.value == null){
            return false;
          }
          if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z]+(\.[a-zA-Z]+)*\.[a-zA-Z]+[a-zA-Z]+$").hasMatch(values[2] as String)) {
            _emailController.sink.addError("Please provide valid email");
            return false;
          }
          if (_passwordController.stream.value == null){
            return false;
          }
          return true;
        }
      });

  submitButton() async {
    String name = _firstNameController.stream.value;
    String last = _lastNameController.stream.value;
    String email = _emailController.stream.value.toLowerCase();
    String pass = _passwordController.stream.value;
    bool promotional = _promotionalMaterialsController.stream.value;
    print('pm:$promotional');
    bool emailValid =
    RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
        .hasMatch(email);

    if (!emailValid) {
      return;
    }

    bool validateLengthCase = pass.length >= 8;
    bool validateCharCase = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z]).{2,}$').hasMatch(pass);
    bool validateSpecChar = RegExp(r'^(?=.*?[!@#\$&*~0-9]).{1,}$').hasMatch(pass);

    bool noSpace = !pass.contains(' ');
    List<PasswordError> errors = List<PasswordError>.filled(4, PasswordError(true, ''));

    if (!validateLengthCase || !validateCharCase || !validateSpecChar || !noSpace) {
      errors[0] = PasswordError(
          validateLengthCase, '  Be at least 8 characters long.');
      errors[1] = PasswordError(
          validateCharCase, '  Include both lower and upper case.');
      errors[2] = PasswordError(
          validateSpecChar, '  Include at least 1 number or symbol.');
      errors[3] = PasswordError(
          noSpace, '  Exclude white spaces.');
      _passwordController.sink.addError(errors);
      return;
    }


    _nextButtonController.sink.add(false);
    _progressIndicatorController.sink.add(1);

    print('name$name');
    var res = await attemptSignUp(name, last, email.toLowerCase(), pass,promotional);

    print('response${res.body}');
    if (res.statusCode == 200) {
      CreateProfileResponse arguments = CreateProfileResponse.fromJson(json.decode(res.body!));

      print('arguments$arguments');

      var returnObject = json.decode(res.body!);
      print('object$returnObject');


       await acceptTermsPolicy(arguments.user!.profileID!);
///accept promotional materials//
      // bool promotional = _promotionalMaterialsController.stream.value;
      // print('pm:$promotional');
      // if (promotional) {
      //
      //   var promotionRes = await acceptPromotion(arguments.user.profileID);
      //   print("promotion${promotionRes.body}");
      // }
//      _nextButtonController.sink.add(true);
      _progressIndicatorController.sink.add(0);
      return arguments;
    } else {
      var errorMessage = json.decode(res.body!)['details'][0]['Message'];
      print("error$errorMessage");

//      _nextButtonController.sink.add(true);
      _emailController.sink.addError(errorMessage);
      _progressIndicatorController.sink.add(0);
      return null;
    }
  }

  @override
  void dispose() {
    _firstNameController?.close();
    _lastNameController?.close();
    _emailController?.close();
    _passwordController?.close();
    _termsController.close();
    _nextButtonController.close();
    _promotionalMaterialsController.close();
    _errorController.close();
    _progressIndicatorController.close();
  }
}
