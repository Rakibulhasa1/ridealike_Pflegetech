import 'dart:async';
import 'dart:io';

import 'package:ridealike/pages/create_a_profile/bloc/password_error_class.dart';
import 'package:ridealike/pages/discover/response_model/fetchNewCarResponse.dart';


mixin Validators {

  var emailValidator = StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {
    bool emailValid = RegExp(r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$").hasMatch(email);
    if (emailValid) {
      sink.add(email);
    } else {
      sink.addError('Email formation is not correct');
    }
  });
  var passwordValidator = StreamTransformer<String, String>.fromHandlers(handleData: (password, sink) {

    if (password!=null && password.length>0) {
      sink.add(password);
    } else{
      sink.addError(<PasswordError>[]);
    }
  });

var termsValidator=StreamTransformer<bool,bool>.fromHandlers(handleData: (terms,sink){
  if(terms==true){
    sink.add(terms);
  }else{
    sink.addError("");
  }
});
var buttonValidator=StreamTransformer<bool,bool>.fromHandlers(handleData: (button,sink){
  if(button==true){
    sink.add(button);
  }
});
var loggedInValidator=StreamTransformer<bool,bool>.fromHandlers(handleData: (loggedIn,sink){
  if(loggedIn==true){
    sink.add(loggedIn);
  }else{
    sink.addError("");
  }
});
var showSearchHereValidator=StreamTransformer<bool,bool>.fromHandlers(handleData: (showSearchHere,sink){
  if(showSearchHere==true){
    sink.add(showSearchHere);
  }else{
    sink.addError("");
  }
});
  var progressIndicatorValidator=StreamTransformer<bool,bool>.fromHandlers(handleData: (indicator,sink){
    if(indicator==true){
      sink.add(indicator);
    }else{
      sink.addError("");
    }
  });
  var progressIndicatorValidatorCar=StreamTransformer<bool,bool>.fromHandlers(handleData: (indicator,sink){
    sink.add(indicator);
  });

var promotionalMaterialsValidator=StreamTransformer<bool,bool>.fromHandlers(handleData: (promotional,sink){
  if(promotional==true){
    sink.add(promotional);
  }else{
    sink.addError("");
  }
});
var errorValidator=StreamTransformer<String,String>.fromHandlers(handleData: (error,sink){
  if(error==null || error==''){
    sink.add('');
  }else{
    sink.addError(error);
  }
});
var messageValidator=StreamTransformer<String,String>.fromHandlers(handleData: (message,sink){
  if(message!=null){
    sink.add(message);
  }else{

  }
});
var phoneNumberValidator = StreamTransformer<String,String>.fromHandlers(handleData: (phoneNumber,sink){
  if(phoneNumber.length==10){
    sink.add(phoneNumber);
  }else{
    sink.addError('error');
  }
});
var codeValueValidator = StreamTransformer<String,String>.fromHandlers(handleData: (code,sink){
  if(code.length==5){
    sink.add(code);
  }else{
    sink.addError(' code error');
  }
});
var fileValidator = StreamTransformer<File,File>.fromHandlers(handleData: (imageFile,sink){
  if(imageFile!=null){
    sink.add(imageFile);
  }else{
    sink.addError(' code error');
  }
});
  var logInEmailValidator = StreamTransformer<String, String>.fromHandlers(handleData: (email, sink) {

    if (email!=null && email.trim()!='') {
      sink.add(email);
    }else{
       sink.add(null as String);
      sink.addError('');
    }
  });
  var logInPasswordValidator = StreamTransformer<String, String>.fromHandlers(handleData: (password, sink) {
    if (password.isNotEmpty) {
      sink.add(password);
    } else {
      sink.addError("Password needs to be 8 characters long");
    }
  });

  // var logInPasswordValidator = StreamTransformer<String, String>.fromHandlers(handleData: (password, sink) {
  //   if (password != '') {
  //     sink.add(password);
  //   } else {
  //     sink.add(null);
  //     sink.addError("Password needs to be 8 characters long");
  //   }
  // }

  var numValidator = StreamTransformer<num, num>.fromHandlers(handleData: (value, sink) {
    if (value != null) {
      sink.add(value);
    } else {
    }
  });
  var fetchNewCarValidator = StreamTransformer<FetchNewCarResponse, FetchNewCarResponse>.fromHandlers(handleData: (value, sink) {
    if (value != null) {
      sink.add(value);
    } else {
    }
  });

}
