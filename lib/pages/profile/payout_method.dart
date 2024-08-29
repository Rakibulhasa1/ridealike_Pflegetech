import 'dart:async';
import 'dart:convert' show json;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/widgets/shimmer.dart';

import '../../utils/app_events/app_events_utils.dart';

Future<RestApi.Resp> getPayoutMethod(_userID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getPayoutMethodUrl,
    json.encode({"UserID": _userID}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

class PayoutMethod extends StatefulWidget {
  @override
  _PayoutMethodState createState() => _PayoutMethodState();
}

class _PayoutMethodState extends State<PayoutMethod> {
  Map _payoutData = {};
  int _groupValue = 2;

  final storage = new FlutterSecureStorage();

  final TextEditingController _paypalEmailController = TextEditingController();

  bool dataFetched= false;
  bool _hasPaypalEmailError = false;
  String _paypalEmailError = '';

  final TextEditingController _addreesController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _provinceController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _iBANController = TextEditingController();

  bool _hasAddressError = false;
  String _addressError = '';
  bool _hasCityError = false;
  String _cityError = '';
  bool _hasProvinceError = false;
  String _provinceError = '';
  bool _hasPostalCodeError = false;
  String _postalCodeError = '';
  bool _hasCountryError = false;
  String _countryError = '';
  bool _hasNameError = false;
  String _nameError = '';
  bool _hasIBANError = false;
  String _iBANError = '';
String? emailValidator;
  final TextEditingController _interacEmailController = TextEditingController();

  bool _hasInteracEmailError = false;
  String _interacEmailError = '';

  @override
  void initState() {
    super.initState();
    callFetchPayoutMethod();
  }

  callFetchPayoutMethod() async {
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var res = await getPayoutMethod(userID);


      setState(() {
        dataFetched = true;
        _payoutData = json.decode(res.body!)['PayoutMethod'];
        _paypalEmailController.text = _payoutData['PaypalData']['email'].toString().toLowerCase();
        _addreesController.text = _payoutData['DirectDepositData']['Address'];
        _cityController.text = _payoutData['DirectDepositData']['City'];
        _provinceController.text = _payoutData['DirectDepositData']['Province'];
        _postalCodeController.text = _payoutData['DirectDepositData']['PostalCode'];
        _countryController.text = _payoutData['DirectDepositData']['Country'];
        _nameController.text = _payoutData['DirectDepositData']['Name'];
        _iBANController.text = _payoutData['DirectDepositData']['IBAN'];
        _interacEmailController.text = _payoutData['InteracETransferData']['email'].toString().toLowerCase();
      });

      switch (json.decode(res.body!)['PayoutMethod']['PayoutMethodType']) {
        case 'payout_undefined':
          {
            setState(() {
              _groupValue = 2;
            });
          }
          break;
        case 'paypal':
          {
            setState(() {
              _groupValue = 0;
            });
          }
          break;
        case 'direct_deposit':
          {
            setState(() {
              _groupValue = 1;
            });
          }
          break;
        case 'interac_e_transfer':
          {
            setState(() {
              _groupValue = 2;
            });
          }
          break;
        default:
          {
            setState(() {
              _groupValue = 2;
            });
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: new AppBar(
        centerTitle: true,
        title: Text(
          'Payout method',
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
      body:dataFetched?
      SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Default payout method',
                style: TextStyle(
                  color: Color(0xff371D32),
                  fontSize: 18,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffF2F2F2),
                      borderRadius: BorderRadius.circular(8),
                      shape: BoxShape.rectangle),
                  height: 50,
                  child: _myRadioButton(
                    title: 'Interac e-Transfer',
                    value: 2,
                    onChanged: (newValue) {
                      setState(() {
                        _groupValue = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10),

              //direct deposite//
//              SizedBox(
//                width: double.infinity,
//                child: Container(
//                  decoration: BoxDecoration(
//                      color: Color(0xffF2F2F2),
//                      borderRadius: BorderRadius.circular(8),
//                      shape: BoxShape.rectangle),
//                  height: 50,
//                  child: _myRadioButton(
//                    title: 'Direct deposit',
//                    value: 1,
//                    onChanged: (newValue) {
//                      setState(() {
//                        _groupValue = newValue;
//                      });
//                    },
//                  ),
//                ),
//              ),
//              SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(0xffF2F2F2),
                      borderRadius: BorderRadius.circular(8),
                      shape: BoxShape.rectangle),
                  height: 50,
                  child: _myRadioButton(
                    title: 'PayPal',
                    value: 0,
                    onChanged: (newValue) {
                      setState(() {
                        _groupValue = newValue!;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 30),
              // paypal
              _groupValue == 0
                  ? Container(
                      child: Column(
                        children: <Widget>[
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
                                          onChanged: (email){
                                            checkForError(email);
                                          },
                                          keyboardType: TextInputType.emailAddress,
                                          inputFormatters:
                                          [FilteringTextInputFormatter.allow((RegExp(r'[a-zA-Z0-9@._-]+$')))],
                                          controller: _paypalEmailController,
                                          decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(22.0),
                                              border: InputBorder.none,
                                              labelText: 'Email',
                                              labelStyle: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 12,
                                                color: Color(0xFF353B50),
                                              ),
                                              hintText: 'Please enter email'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          _hasPaypalEmailError ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 5),
                                    Text(
                                      _paypalEmailError,
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFFF55A51),
                                      ),
                                    ),
                                  ],
                                ) : new Container(),
                          _hasPaypalEmailError ? SizedBox(height: 10,):Container(),
                          Container(height: 50,
                            width: MediaQuery.of(context).size.width*.95,
                            child: AutoSizeText('Please ensure your email is accurate as payments sent to an incorrect address cannot be returned.',
                              style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xFF353B50),
                            ),maxLines: 2,),
                          ),
                          SizedBox(height: 30),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Color(0xffFF8F68),
                                          padding: EdgeInsets.all(16.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8.0)),

                                        ),
                                        onPressed: () async {

                                          if (validateEmail(_paypalEmailController.text,'PayPal ')==null ) {
                                            var payload = {
                                              "UserID": _payoutData['UserID'],
                                              "PayoutMethodType": _groupValue == 0 ? 'paypal' : _groupValue == 1 ? 'direct_deposit'
                                                      : _groupValue == 2 ? 'interac_e_transfer' : 'payout_undefined',
                                              "PayPalEmail": _paypalEmailController.text.toLowerCase(),
                                              "InteracEmail": _interacEmailController.text.toLowerCase(),
                                              "BankAddress": _addreesController.text,
                                              "BankCity": _cityController.text,
                                              "BankProvince": _provinceController.text,
                                              "BankPostalCode": _postalCodeController.text,
                                              "BankCountry": _countryController.text,
                                              "BankName": _nameController.text,
                                              "BankIBAN": _iBANController.text,
                                            };

                                            await setPayoutMethod(payload);
                                            AppEventsUtils.logEvent("payout_method_updated", params: {
                                              "payout_method_selected": payload["PayoutMethodType"]
                                            });
                                            // Navigator.pushNamed(context, '/profile');
                                            Navigator.pop(context);
                                          } else {

                                              setState(() {
                                                _hasPaypalEmailError = true;
                                                _paypalEmailError = validateEmail(_paypalEmailController.text, 'PayPal ')!;
                                              });

                                          }
                                        },
                                        child: Text('Save',
                                          style: TextStyle(fontFamily: 'Urbanist',
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
                    )
                  : new Container(),
              // bank transfer
//              _groupValue == 1
//                  ? Container(
//                      child: Column(
//                        children: <Widget>[
//                          // Section header
//                          Row(
//                            children: <Widget>[
//                              Expanded(
//                                child: Column(
//                                  crossAxisAlignment: CrossAxisAlignment.start,
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: Text(
//                                        'Enter the account address',
//                                        style: TextStyle(
//                                          fontFamily: 'Urbanist',
//                                          fontSize: 18,
//                                          color: Color(0xFF371D32),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                          SizedBox(height: 15),
//                          // Address
//                          Row(
//                            children: [
//                              Expanded(
//                                child: Column(
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: Container(
//                                        decoration: BoxDecoration(
//                                            color: Color(0xFFF2F2F2),
//                                            borderRadius:
//                                                BorderRadius.circular(8.0)),
//                                        child: TextFormField(
//                                          inputFormatters: [
//                                            FilteringTextInputFormatter.allow(
//                                                RegExp(r'^[a-zA-Z0-9.,&\- ]+$'))
//                                          ],
//                                          controller: _addreesController,
//                                          validator: (value) {
//                                            if (value.isEmpty) {
//                                              return 'Your address is required';
//                                            }
//                                            return null;
//                                          },
//                                          decoration: InputDecoration(
//                                              contentPadding:
//                                                  EdgeInsets.all(22.0),
//                                              border: InputBorder.none,
//                                              labelText: 'Address',
//                                              labelStyle: TextStyle(
//                                                fontFamily: 'Urbanist',
//                                                fontSize: 12,
//                                                color: Color(0xFF353B50),
//                                              ),
//                                              hintText:
//                                                  'Please enter your address'),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                          _hasAddressError
//                              ? Row(
//                                  mainAxisAlignment: MainAxisAlignment.start,
//                                  children: <Widget>[
//                                    SizedBox(height: 5),
//                                    Text(
//                                      _addressError,
//                                      style: TextStyle(
//                                        fontFamily: 'Urbanist',
//                                        fontSize: 12,
//                                        color: Color(0xFFF55A51),
//                                      ),
//                                    ),
//                                  ],
//                                )
//                              : new Container(),
//                          SizedBox(height: 10),
//                          // City
//                          Row(
//                            children: [
//                              Expanded(
//                                child: Column(
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: Container(
//                                        decoration: BoxDecoration(
//                                            color: Color(0xFFF2F2F2),
//                                            borderRadius:
//                                                BorderRadius.circular(8.0)),
//                                        child: TextFormField(
//                                          controller: _cityController,
//                                          inputFormatters: [
//                                            FilteringTextInputFormatter.allow(
//                                                RegExp(r'^[a-zA-Z0-9.,&\- ]+$'))
//                                          ],
//                                          validator: (value) {
//                                            if (value.isEmpty) {
//                                              return 'City is required';
//                                            }
//                                            return null;
//                                          },
//                                          decoration: InputDecoration(
//                                              contentPadding:
//                                                  EdgeInsets.all(22.0),
//                                              border: InputBorder.none,
//                                              labelText: 'City',
//                                              labelStyle: TextStyle(
//                                                fontFamily: 'Urbanist',
//                                                fontSize: 12,
//                                                color: Color(0xFF353B50),
//                                              ),
//                                              hintText: 'Please enter city'),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                          _hasCityError
//                              ? Row(
//                                  mainAxisAlignment: MainAxisAlignment.start,
//                                  children: <Widget>[
//                                    SizedBox(height: 5),
//                                    Text(
//                                      _cityError,
//                                      style: TextStyle(
//                                        fontFamily: 'Urbanist',
//                                        fontSize: 12,
//                                        color: Color(0xFFF55A51),
//                                      ),
//                                    ),
//                                  ],
//                                )
//                              : new Container(),
//                          SizedBox(height: 10),
//                          // Province & Postal code
//                          Row(
//                            children: [
//                              Expanded(
//                                child: Column(
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: Container(
//                                        decoration: BoxDecoration(
//                                            color: Color(0xFFF2F2F2),
//                                            borderRadius:
//                                                BorderRadius.circular(8.0)),
//                                        child: TextFormField(
//                                          inputFormatters: [
//                                            FilteringTextInputFormatter.allow(
//                                                RegExp(r'^[a-zA-Z0-9]+$'))
//                                          ],
//                                          controller: _provinceController,
//                                          validator: (value) {
//                                            if (value.isEmpty) {
//                                              return 'Province is required';
//                                            }
//                                            return null;
//                                          },
//                                          decoration: InputDecoration(
//                                              contentPadding:
//                                                  EdgeInsets.all(22.0),
//                                              border: InputBorder.none,
//                                              labelText: 'Province',
//                                              labelStyle: TextStyle(
//                                                fontFamily: 'Urbanist',
//                                                fontSize: 12,
//                                                color: Color(0xFF353B50),
//                                              ),
//                                              hintText:
//                                                  'Please enter province'),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                              SizedBox(width: 10),
//                              Expanded(
//                                child: Column(
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: Container(
//                                        decoration: BoxDecoration(
//                                            color: Color(0xFFF2F2F2),
//                                            borderRadius:
//                                                BorderRadius.circular(8.0)),
//                                        child: TextFormField(
//                                          controller: _postalCodeController,
//                                          validator: (value) {
//                                            if (value.isEmpty) {
//                                              return 'Postal Code is required';
//                                            }
//                                            return null;
//                                          },
//                                          decoration: InputDecoration(
//                                              contentPadding:
//                                                  EdgeInsets.all(22.0),
//                                              border: InputBorder.none,
//                                              labelText: 'Postal Code',
//                                              labelStyle: TextStyle(
//                                                fontFamily: 'Urbanist',
//                                                fontSize: 12,
//                                                color: Color(0xFF353B50),
//                                              ),
//                                              hintText:
//                                                  'Please enter postal Code'),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                          _hasProvinceError
//                              ? Row(
//                                  mainAxisAlignment: MainAxisAlignment.start,
//                                  children: <Widget>[
//                                    SizedBox(height: 5),
//                                    Text(
//                                      _provinceError,
//                                      style: TextStyle(
//                                        fontFamily: 'Urbanist',
//                                        fontSize: 12,
//                                        color: Color(0xFFF55A51),
//                                      ),
//                                    ),
//                                  ],
//                                )
//                              : new Container(),
//                          SizedBox(height: 10),
//                          _hasPostalCodeError
//                              ? Row(
//                                  mainAxisAlignment: MainAxisAlignment.start,
//                                  children: <Widget>[
//                                    SizedBox(height: 5),
//                                    Text(
//                                      _postalCodeError,
//                                      style: TextStyle(
//                                        fontFamily: 'Urbanist',
//                                        fontSize: 12,
//                                        color: Color(0xFFF55A51),
//                                      ),
//                                    ),
//                                  ],
//                                )
//                              : new Container(),
//                          SizedBox(height: 10),
//                          // Country
//                          Row(
//                            children: [
//                              Expanded(
//                                child: Column(
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: Container(
//                                        decoration: BoxDecoration(
//                                            color: Color(0xFFF2F2F2),
//                                            borderRadius:
//                                                BorderRadius.circular(8.0)),
//                                        child: TextFormField(
//                                          inputFormatters: [
//                                            FilteringTextInputFormatter.allow(
//                                                RegExp(r'^[a-zA-Z0-9.,&\- ]+$'))
//                                          ],
//                                          controller: _countryController,
//                                          validator: (value) {
//                                            if (value.isEmpty) {
//                                              return 'Country is required';
//                                            }
//                                            return null;
//                                          },
//                                          decoration: InputDecoration(
//                                              contentPadding:
//                                                  EdgeInsets.all(22.0),
//                                              border: InputBorder.none,
//                                              labelText: 'Country',
//                                              labelStyle: TextStyle(
//                                                fontFamily: 'Urbanist',
//                                                fontSize: 12,
//                                                color: Color(0xFF353B50),
//                                              ),
//                                              hintText: 'Please enter country'),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                          _hasCountryError
//                              ? Row(
//                                  mainAxisAlignment: MainAxisAlignment.start,
//                                  children: <Widget>[
//                                    SizedBox(height: 5),
//                                    Text(
//                                      _countryError,
//                                      style: TextStyle(
//                                        fontFamily: 'Urbanist',
//                                        fontSize: 12,
//                                        color: Color(0xFFF55A51),
//                                      ),
//                                    ),
//                                  ],
//                                )
//                              : new Container(),
//                          SizedBox(height: 30),
//                          // Section header
//                          Row(
//                            children: <Widget>[
//                              Expanded(
//                                child: Column(
//                                  crossAxisAlignment: CrossAxisAlignment.start,
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: Text(
//                                        'Enter bank transfer information',
//                                        style: TextStyle(
//                                          fontFamily: 'Urbanist',
//                                          fontSize: 18,
//                                          color: Color(0xFF371D32),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                          SizedBox(height: 15),
//                          // Name
//                          Row(
//                            children: [
//                              Expanded(
//                                child: Column(
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: Container(
//                                        decoration: BoxDecoration(
//                                            color: Color(0xFFF2F2F2),
//                                            borderRadius:
//                                                BorderRadius.circular(8.0)),
//                                        child: TextFormField(
//                                          inputFormatters: [
//                                            FilteringTextInputFormatter.allow(
//                                                RegExp(r'^[a-zA-Z0-9\- ]+$'))
//                                          ],
//                                          controller: _nameController,
//                                          validator: (value) {
//                                            if (value.isEmpty) {
//                                              return 'Name is required';
//                                            }
//                                            return null;
//                                          },
//                                          decoration: InputDecoration(
//                                              contentPadding:
//                                                  EdgeInsets.all(22.0),
//                                              border: InputBorder.none,
//                                              labelText: 'Name',
//                                              labelStyle: TextStyle(
//                                                fontFamily: 'Urbanist',
//                                                fontSize: 12,
//                                                color: Color(0xFF353B50),
//                                              ),
//                                              hintText: 'Please enter name'),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                          _hasNameError
//                              ? Row(
//                                  mainAxisAlignment: MainAxisAlignment.start,
//                                  children: <Widget>[
//                                    SizedBox(height: 5),
//                                    Text(
//                                      _nameError,
//                                      style: TextStyle(
//                                        fontFamily: 'Urbanist',
//                                        fontSize: 12,
//                                        color: Color(0xFFF55A51),
//                                      ),
//                                    ),
//                                  ],
//                                )
//                              : new Container(),
//                          SizedBox(height: 10),
//                          // IBAN
//                          Row(
//                            children: [
//                              Expanded(
//                                child: Column(
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: Container(
//                                        decoration: BoxDecoration(
//                                            color: Color(0xFFF2F2F2),
//                                            borderRadius:
//                                                BorderRadius.circular(8.0)),
//                                        child: TextFormField(
//                                          inputFormatters: [
//                                            FilteringTextInputFormatter.allow(
//                                                RegExp(r'^[a-zA-Z0-9\- ]+$'))
//                                          ],
//                                          controller: _iBANController,
//                                          validator: (value) {
//                                            if (value.isEmpty) {
//                                              return 'IBAN is required';
//                                            }
//                                            return null;
//                                          },
//                                          decoration: InputDecoration(
//                                              contentPadding:
//                                                  EdgeInsets.all(22.0),
//                                              border: InputBorder.none,
//                                              labelText: 'IBAN',
//                                              labelStyle: TextStyle(
//                                                fontFamily: 'Urbanist',
//                                                fontSize: 12,
//                                                color: Color(0xFF353B50),
//                                              ),
//                                              hintText: 'Please enter IBAN'),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                          _hasIBANError
//                              ? Row(
//                                  mainAxisAlignment: MainAxisAlignment.start,
//                                  children: <Widget>[
//                                    SizedBox(height: 5),
//                                    Text(
//                                      _iBANError,
//                                      style: TextStyle(
//                                        fontFamily: 'Urbanist',
//                                        fontSize: 12,
//                                        color: Color(0xFFF55A51),
//                                      ),
//                                    ),
//                                  ],
//                                )
//                              : new Container(),
//                          SizedBox(height: 40),
//                          // Next button
//                          Row(
//                            children: [
//                              Expanded(
//                                child: Column(
//                                  children: [
//                                    SizedBox(
//                                      width: double.maxFinite,
//                                      child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                        elevation: 0.0,
//                                        color: Color(0xffFF8F68),
//                                        padding: EdgeInsets.all(16.0),
//                                        shape: RoundedRectangleBorder(
//                                            borderRadius:
//                                                BorderRadius.circular(8.0)),
//                                        onPressed: () async {
//                                          if (_addreesController.text.length > 0 &&
//                                              _cityController.text.length > 0 &&
//                                              _provinceController.text.length >
//                                                  0 &&
//                                              _postalCodeController
//                                                      .text.length >
//                                                  0 &&
//                                              _countryController.text.length >
//                                                  0 &&
//                                              _nameController.text.length > 0 &&
//                                              _iBANController.text.length > 0) {
//                                            var payload = {
//                                              "UserID": _payoutData['UserID'],
//                                              "PayoutMethodType": _groupValue ==
//                                                      0
//                                                  ? 'paypal'
//                                                  : _groupValue == 1
//                                                      ? 'direct_deposit'
//                                                      : _groupValue == 2
//                                                          ? 'interac_e_transfer'
//                                                          : 'payout_undefined',
//                                              "PayPalEmail":
//                                                  _paypalEmailController.text,
//                                              "InteracEmail":
//                                                  _interacEmailController.text,
//                                              "BankAddress":
//                                                  _addreesController.text,
//                                              "BankCity": _cityController.text,
//                                              "BankProvince":
//                                                  _provinceController.text,
//                                              "BankPostalCode":
//                                                  _postalCodeController.text,
//                                              "BankCountry":
//                                                  _countryController.text,
//                                              "BankName": _nameController.text,
//                                              "BankIBAN": _iBANController.text,
//                                            };
//
//                                            await setPayoutMethod(payload);
//
//                                            Navigator.pushNamed(
//                                                context, '/profile');
//                                          } else {
//                                            if (_addreesController.text.length >
//                                                0) {
//                                              setState(() {
//                                                _hasAddressError = false;
//                                              });
//                                            } else {
//                                              setState(() {
//                                                _hasAddressError = true;
//                                                _addressError =
//                                                    'Address is required.';
//                                              });
//                                            }
//
//                                            if (_cityController.text.length >
//                                                0) {
//                                              setState(() {
//                                                _hasCityError = false;
//                                              });
//                                            } else {
//                                              setState(() {
//                                                _hasCityError = true;
//                                                _cityError =
//                                                    'City is required.';
//                                              });
//                                            }
//
//                                            if (_provinceController
//                                                    .text.length >
//                                                0) {
//                                              setState(() {
//                                                _hasProvinceError = false;
//                                              });
//                                            } else {
//                                              setState(() {
//                                                _hasProvinceError = true;
//                                                _provinceError =
//                                                    'Province is required.';
//                                              });
//                                            }
//
//                                            if (_postalCodeController
//                                                    .text.length >
//                                                0) {
//                                              setState(() {
//                                                _hasPostalCodeError = false;
//                                              });
//                                            } else {
//                                              setState(() {
//                                                _hasPostalCodeError = true;
//                                                _postalCodeError =
//                                                    'Postal Code is required.';
//                                              });
//                                            }
//
//                                            if (_countryController.text.length >
//                                                0) {
//                                              setState(() {
//                                                _hasCountryError = false;
//                                              });
//                                            } else {
//                                              setState(() {
//                                                _hasCountryError = true;
//                                                _countryError =
//                                                    'Country is required.';
//                                              });
//                                            }
//
//                                            if (_nameController.text.length >
//                                                0) {
//                                              setState(() {
//                                                _hasNameError = false;
//                                              });
//                                            } else {
//                                              setState(() {
//                                                _hasNameError = true;
//                                                _nameError =
//                                                    'Name is required.';
//                                              });
//                                            }
//
//                                            if (_iBANController.text.length >
//                                                0) {
//                                              setState(() {
//                                                _hasIBANError = false;
//                                              });
//                                            } else {
//                                              setState(() {
//                                                _hasIBANError = true;
//                                                _iBANError =
//                                                    'IBAN is required.';
//                                              });
//                                            }
//                                          }
//                                        },
//                                        child: Text(
//                                          'Save',
//                                          style: TextStyle(
//                                              fontFamily:
//                                                  'Urbanist',
//                                              fontSize: 18,
//                                              color: Colors.white),
//                                        ),
//                                      ),
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ],
//                          ),
//                        ],
//                      ),
//                    )
//                  : new Container(),
              // interac e-transfer
              _groupValue == 2
                  ? Container(
                      child: Column(
                        children: <Widget>[
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
                                          keyboardType:
                                              TextInputType.emailAddress,
                                            onChanged: (email){
                                              checkForError(email);
                                            },

                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(
                                                RegExp('[a-zA-Z0-9@._-]'),
                                                replacementString: '')
                                          ],
                                          controller: _interacEmailController,
                                          decoration: InputDecoration(
                                              contentPadding:
                                                  EdgeInsets.all(22.0),
                                              border: InputBorder.none,
                                              labelText: 'Email',
                                              labelStyle: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 12,
                                                color: Color(0xFF353B50),
                                              ),
                                              hintText: 'Please enter email'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10,),
                          _hasInteracEmailError
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 5),
                                    Text(
                                      _interacEmailError,
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFFF55A51),
                                      ),
                                    ),
                                  ],
                                ) : new Container(),
                          _hasInteracEmailError?SizedBox(height: 10,):Container(),
                          Container(height: 50,
                            width: MediaQuery.of(context).size.width*.95,
                            child: AutoSizeText('Please ensure your email is accurate as payments sent to an incorrect address cannot be returned.',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xFF353B50),
                              ),maxLines: 2,),
                          ),
                          SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Color(0xffFF8F68),
                                          padding: EdgeInsets.all(16.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8.0)),

                                        ),
                                        onPressed: () async {
                                          if (validateEmail(_interacEmailController.text, 'Interac e-Transfer')==null) {
                                            var payload = {
                                              "UserID": _payoutData['UserID'],
                                              "PayoutMethodType": _groupValue == 0
                                                  ? 'paypal'
                                                  : _groupValue == 1 ? 'direct_deposit'
                                                      : _groupValue == 2
                                                          ? 'interac_e_transfer'
                                                          : 'payout_undefined',
                                              "PayPalEmail":
                                                  _paypalEmailController.text,
                                              "InteracEmail":
                                                  _interacEmailController.text,
                                              "BankAddress":
                                                  _addreesController.text,
                                              "BankCity": _cityController.text,
                                              "BankProvince":
                                                  _provinceController.text,
                                              "BankPostalCode":
                                                  _postalCodeController.text,
                                              "BankCountry":
                                                  _countryController.text,
                                              "BankName": _nameController.text,
                                              "BankIBAN": _iBANController.text
                                            };

                                            await setPayoutMethod(payload);

                                            Navigator.pushNamed(context, '/profile');
                                          } else {
                                              setState(() {
                                                _hasInteracEmailError = true;
                                                _interacEmailError =validateEmail(_interacEmailController.text, 'Interac e-Transfer ')!
                                                ;
                                              });

                                          }
                                        },
                                        child: Text(
                                          'Save',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                              fontFamily:
                                                  'Urbanist',
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
                    )
                  : new Container(),
            ],
          ),
        ),
      ):Center(
        child: ShimmerEffect()
      ),
    );
  }
  String? validateEmail(String email, String s) {

    if ( email == null || email.length == 0){
      return  "Email is required.";
    }
    // Pattern pattern=r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+$";
    bool emailValid =RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z]+(\.[a-zA-Z]+)*\.[a-zA-Z]+[a-zA-Z]+$").hasMatch(email);
    // RegExp regex = new RegExp(pattern);
    // if (!regex.hasMatch(email)|| email == null){
    //   return 'Enter a valid email address';
    // } else{
    //   return null;
    // }
    if(emailValid==false){
      return'Please provide valid email.';

    }else{
      return  null;
    }



  }
  Widget _myRadioButton({required String title,  int? value, void Function(int?)? onChanged}) {
    return RadioListTile(
      value: value!,
      groupValue: _groupValue,
      onChanged: onChanged,
      title: Text(title),
    );
  }

  void checkForError(String email) {
    if (validateEmail(email, '')== null){
      setState(() {
        _hasPaypalEmailError = false;
        _paypalEmailError = '';
        _hasInteracEmailError = false;
        _interacEmailError = '';
      });
    }
  }
}

Future<RestApi.Resp> setPayoutMethod(payload) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    setPayoutMethodUrl,
    json.encode({
      "PayoutMethod": {
        "UserID": payload['UserID'],
        "PayoutMethodType": payload['PayoutMethodType'],
        "PaypalData": {"email": payload['PayPalEmail']},
        "InteracETransferData": {"email": payload['InteracEmail']},
        "DirectDepositData": {
          "Address": payload['BankAddress'],
          "City": payload['BankCity'],
          "Province": payload['BankProvince'],
          "PostalCode": payload['BankPostalCode'],
          "Country": payload['BankCountry'],
          "Name": payload['BankName'],
          "IBAN": payload['BankIBAN']
        }
      }
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
