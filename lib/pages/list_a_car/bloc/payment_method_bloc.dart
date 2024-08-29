import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/request_service/payout_method_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/payout_method_response.dart';
import 'package:rxdart/rxdart.dart';

class PaymentMethodBloc extends Object with Validators implements BaseBloc {
  final _paymentMethodController = BehaviorSubject<FetchPayoutMethodResponse>();
  final _errorController = BehaviorSubject<String>();
  Function(FetchPayoutMethodResponse) get changedPaymentMethod => _paymentMethodController.sink.add;
  Stream<FetchPayoutMethodResponse> get paymentMethodData => _paymentMethodController.stream;

  Function(String) get changedError => _errorController.sink.add;


  final storage = new FlutterSecureStorage();

  //progressIndicator//
  final _progressIndicatorController =BehaviorSubject<int>();
  Function(int) get changedProgressIndicator => _progressIndicatorController.sink.add;
  Stream<int> get progressIndicator => _progressIndicatorController.stream;
  Stream<String> get error => _errorController.stream.transform(errorValidator);

  @override
  void dispose() {
    _paymentMethodController.close();
    _progressIndicatorController.close();
  }

  payPalPaymentMethod(FetchPayoutMethodResponse payoutMethodResponse) async {
    var completer = Completer<FetchPayoutMethodResponse>();

    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var resp = await setPayoutMethod(
          userID, payoutMethodResponse);
      if (resp != null && resp.statusCode == 200) {
        var payPalResp = FetchPayoutMethodResponse.fromJson(json.decode(resp.body!));
        completer.complete(payPalResp);
      }
    }
    return completer.future;
  }

  String validateEmail(String email) {

    if(email!=null && RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z]+(\.[a-zA-Z]+)*\.[a-zA-Z]+[a-zA-Z]+$").hasMatch(email)
        // RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$").hasMatch(email)
    ){
      _errorController.sink.add('');
      return email;
    }else{
      _errorController.sink.addError('Please provide valid email.');
      return '';
    }


  }

  checkButtonDisability( FetchPayoutMethodResponse payoutMethodData) {
    if (payoutMethodData.payoutMethod!.directDepositData!.name!= "" &&
        payoutMethodData.payoutMethod!.directDepositData!.country!= "" &&
        payoutMethodData.payoutMethod!.directDepositData!.city!="" &&
        payoutMethodData.payoutMethod!.directDepositData!.postalCode!="" &&
        payoutMethodData.payoutMethod!.directDepositData!.address!="" &&
        payoutMethodData.payoutMethod!.directDepositData!.iBAN!="") {

      return false;
    } else {
      return true;

    }

  }
}
