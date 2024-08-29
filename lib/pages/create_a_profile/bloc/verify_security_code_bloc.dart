import 'dart:convert';

import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/create_a_profile/request_service/phone_number_verification.dart';
import 'package:ridealike/pages/create_a_profile/request_service/security_code_verification.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/pages/create_a_profile/response_model/verify_phone_response.dart';
import 'package:rxdart/rxdart.dart';

class VerifySecurityCodeBloc extends Object with Validators implements BaseBloc {


  //controller//
  final _codeTextController = BehaviorSubject<String>();
  final _messageController=BehaviorSubject<String>();

  //set data//
  Function(String) get changedTextCode => _codeTextController.sink.add;
  Function(String) get changedMessageTextCode => _messageController.sink.add;

  //get data//
  Stream<String> textCode() {
    Stream<String> value = _codeTextController.stream;
    print(value);
    return value;
  }

Stream<String>get  message=>_messageController.stream.transform(messageValidator);


  Future<dynamic> addCode(CreateProfileResponse argument) async {
    _messageController.sink.add('');
    String code = _codeTextController.stream.value;
    print("codeStream $code");
    var res = await verifyPhone(
        argument.user!.profileID!, argument.user!.phoneNumber!, code);
    Map mapRes = json.decode(res.body!);
    print('verifiyPhone $mapRes');
    var verifyPhoneArgument=VerifyPhoneResponse.fromJson(json.decode(res.body!));
    if(verifyPhoneArgument != null && verifyPhoneArgument.status!.success==true){

      return verifyPhoneArgument;
    }else{
      _messageController.sink.addError(verifyPhoneArgument.status!.error!);
      return null;
    }

  }
  resendVerificationCode(CreateProfileResponse argument) async{
    _messageController.sink.add('') ;
    var res= await sendPhoneVerificationCode(argument.user!.profileID!);
    Map mapRes=json.decode(res.body!);
    print('resendCode $mapRes');
    if(mapRes['Status'] == null){
      _messageController.sink.addError(mapRes['message']);
    }
    else if(mapRes != null && mapRes['Status']['success']==true){
      _messageController.sink.add('Code sent successfully');
    } else{
      _messageController.sink.addError(mapRes['Status']['error']);
    }
    return mapRes;
  }


  @override
  void dispose() {
    _codeTextController.close();
    _messageController.close();

  }
}
