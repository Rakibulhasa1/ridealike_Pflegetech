import 'dart:async';
import 'dart:convert';

import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/create_a_profile/request_service/phone_number_verification.dart';
import 'package:ridealike/pages/create_a_profile/response_model/add_phone_number_response.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:rxdart/rxdart.dart';

class VerifyPhoneNumberBloc extends Object with Validators implements BaseBloc {

  final _phoneNumberController = BehaviorSubject<String>();
  final _dropDownValueController = BehaviorSubject<String>();
  final _progressIndicatorController = BehaviorSubject<int>();
  final _nextButtonController = BehaviorSubject<bool>();

  //set data//
  Function(String) get changedPhoneNumber => _phoneNumberController.sink.add;
  Function(bool) get changedNextButton => _nextButtonController.sink.add;

  Function(String) get changedDropdownValue =>
      _dropDownValueController.sink.add;
  Function(int) get changedProgressIndicator => _progressIndicatorController.sink.add;

  //get data//
  Stream<String> get phoneNumber =>
      _phoneNumberController.stream.transform(phoneNumberValidator);
  Stream<int> get progressIndicator =>_progressIndicatorController.stream;

  Stream<String> get dropDown => _dropDownValueController.stream;
  Stream<bool> get button => _nextButtonController.stream;

  Stream<bool> get nextAddPhoneButton => Rx.combineLatest([phoneNumber], (values) {
        print('In value $values');
        return true;
      });

  addPhone(CreateProfileResponse  arg) async {
    _nextButtonController.sink.add(false);

    String phone = _phoneNumberController.stream.value;
    String drop = _dropDownValueController.stream.value;

    print(drop);
   var v = drop + phone;


    print(v);
    print(arg.user!.profileID);

    var res = await addPhoneNumber(arg.user!.profileID!, v);
    print('numberRes ${res.body}');

    if(res!=null&& res.statusCode==200){

      var  phoneArguments= AddPhoneNumberResponse.fromJson(json.decode(res.body!));
      print('arguments$phoneArguments');
//      Map resMap=json.decode(res.body!);
//      print('resMap$resMap');

      // var sendPhoneVerification= await sendPhoneVerificationCode(arg.user.profileID);
      // var verificationPhnRes=json.decode(sendPhoneVerification.body!);
      // print('phoneVerification: $verificationPhnRes');

      return phoneArguments;

    }else{
      return null;
    }
  }

  @override
  void dispose() {
    _phoneNumberController.close();
    _dropDownValueController.close();
    _progressIndicatorController.close();
    _nextButtonController.close();
  }
}
