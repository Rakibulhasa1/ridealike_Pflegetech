import 'dart:async';
import 'dart:convert' show json;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/profile/response_service/payment_card_info.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/shimmer.dart';
import 'package:ridealike/widgets/sized_text.dart';



Future<RestApi.Resp> fetchCardData(_userID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getCardsByUserIDUrl,
    json.encode({
      "UserID": _userID,
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

//Custom InputFormatter
class NumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = new StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (text[i] != ' ') {
        buffer.write(text[i]);
      }
      var nonZeroIndex = i + 1;
      print(text.length);
      if (nonZeroIndex <= 3) {
        if (nonZeroIndex % 3 == 0 && nonZeroIndex != text.length) {
          buffer.write(' '); // Add double spaces.
        }
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        // selection: new TextSelection.collapsed(offset: string.length)
    );
  }
}

class PaymentMethod extends StatefulWidget {
  @override
  _PaymentMethodState createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  bool _hasCardNumberError = false;
  bool _hasNameError = false;
  bool _hasExpDateError = false;
  bool _hasCvvError = false;
  bool _hasPostalCodeError = false;
  bool _paymentClicked = false;
  bool minimize = false;

  String _cardNumberError = '';
  String _nameError = '';
  String _expDateError = '';
  String _cvvError = '';
  String _postalCodeError = '';
  String oldValue = "";

  _countCardNumber(String value) {
    if (value.length == 16) {
      cardFocusNode!.unfocus();
//      FocusScope.of(context).requestFocus(FocusNode());
    }
    setState(() {
      _hasCardNumberError = false;
      _cardNumberError = '';
    });
  }

  _countExpireDate(String value) {
    // print(value);
    // if (value.length > 2 && int.parse(value.substring(0, 2)) > 12) {
    //   _expDate.text = '';
    //   _expDate.selection = TextSelection.fromPosition(
    //       TextPosition(offset: _expDate.text.length));
    //   return;
    // }
    // if (value.length > 3 && int.parse(value[3]) >= 4) {
    //   _expDate.text = value.substring(0, 3);
    //   _expDate.selection = TextSelection.fromPosition(
    //       TextPosition(offset: _expDate.text.length));
    // }
    if (value.length == 5 && minimize) {
      FocusScope.of(context).requestFocus(FocusNode());
      minimize = false;
    } 
    
    if(value.length < 5) {
      minimize = true;
    }

    if (value.length > 0) {
      setState(() {
        _hasExpDateError = false;
        _expDateError = '';
      });
    }
    if (value.length == 2 && !_expDate.text.endsWith('/')) {
      _expDate.value = _expDate.value.copyWith(
        text: '${_expDate.text}/',
        selection: TextSelection.collapsed(offset: _expDate.text.length + 1),
      );
    }
  }

  _countCVVNumber(String value) {
//    if(value.length == 3){
//      Future.delayed(Duration(seconds: 2), (){
//        cvvFocusNode.unfocus();
//      });
//    }
    if (value.length == 4) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    setState(() {
      _hasCvvError = false;
      _cvvError = '';
    });
  }

  _countPostalCode(String value) {
    if (value.length == 10) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    setState(() {
      _hasPostalCodeError = false;
      _postalCodeError = '';
    });
  }

  nameText(String value) {
    if (value.length == 1 && value.length > 100) {
      value = value.substring(0, 100);
    }
    setState(() {
      _nameOnCard.selection = TextSelection.fromPosition(
          TextPosition(offset: _nameOnCard.text.length));
      _hasNameError = false;
      _nameError = '';
    });
  }

  String _error = '';
  bool _hasError = false;

  String errorCard = '';
  String errorExp = '';

  String _userID = '';

  bool _isCardDataAvailable = false;
  Map _cardData = {};

  bool _hideCardNumberInput = true;
  bool _hideNameOnCardInput = true;
  bool _hideExpireDateInput = true;
  bool _hideCvvInput = true;
  bool _hidePostalCodeInput = true;

  FocusNode? cardFocusNode;
  FocusNode? nameFocusNode;
  FocusNode? expireFocusNode;
  FocusNode? cvvFocusNode;
  FocusNode? codeFocusNode;

  final TextEditingController _cardNumber = TextEditingController();
  final TextEditingController _nameOnCard = TextEditingController();
  final TextEditingController _expDate = TextEditingController();
  final TextEditingController _cvv = TextEditingController();
  final TextEditingController _postalCode = TextEditingController();

  bool _hideCardNumber = true;
  bool _hideCVV = true;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Payment Method"});
    cardFocusNode = FocusNode();
    nameFocusNode = FocusNode();
    expireFocusNode = FocusNode();
    cvvFocusNode = FocusNode();
    codeFocusNode = FocusNode();
    _expDate.addListener(() {
      _countExpireDate(_expDate.text);
    });
    getCardData();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    cardFocusNode!.dispose();
    nameFocusNode!.dispose();
    expireFocusNode!.dispose();
    cvvFocusNode!.dispose();
    codeFocusNode!.dispose();
    super.dispose();
  }

  getCardData() async {
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var res = await fetchCardData(userID);

      setState(() {
        _userID = userID;

        if (json.decode(res.body!)['CardInfo'].length > 0) {
          _isCardDataAvailable = true;
          _cardData = json.decode(res.body!)['CardInfo'][0];
        } else {
          _isCardDataAvailable = false;
          _cardData = {
            "CardID": "",
            "LastFourDigits": "",
            "UserID": "",
            "CreatedAt": "",
            "UpdatedAt": ""
          };
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      // App bar
      appBar: new AppBar(
        centerTitle: true,
        title: Text(
          'Payment method',
          style: TextStyle(
              color: Color(0xff371D32), fontSize: 16, fontFamily: 'Urbanist'),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
      ),

      body: _cardData.isNotEmpty
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: <Widget>[
                  Text(
                    'We require a payment method to be kept on file so that you can book a vehicle whenever you wish.\n',
                    style: TextStyle(
                        color: Color(0xff371D32),
                        fontSize: 16,
                        fontFamily: 'Urbanist'),
                  ),
                  Text(
                    'If you are updating your payment method, you will need to re-enter all fields.\n',
                    style: TextStyle(
                        color: Color(0xff371D32),
                        fontSize: 16,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  /// Security message
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Image.asset('icons/Security.png'),
                      SizedBox(width: 10),
                      SizedBox(
                        width: 300,
                        height: 50,
                        child: AutoSizeText(
                          // 'Add your payment method using our secure payment system.',
                          'Secure credit card processing by Stripe.',
                          maxLines: 2,
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            color: Color(0xFF353B50),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Card number
                  _hideCardNumberInput
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _hideCardNumberInput = false;
                            });
                            cardFocusNode!.requestFocus();
                          },
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Card number',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          _isCardDataAvailable
                                              ? '**** **** **** ${_cardData['LastFourDigits']}'
                                              : '',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Row(
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
                                        focusNode: cardFocusNode,
                                        onChanged: _countCardNumber,
                                        obscureText: _hideCardNumber,
                                        controller: _cardNumber,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        maxLength: 16,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(16.0),
                                          border: InputBorder.none,
                                          hintText: 'Enter card number',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14, // Adjust the font size as needed
                                            color: Colors.grey, // You can customize the color as well
                                          ),
                                          counterText: "",
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _hideCardNumber
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Color(0xff353B50),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _hideCardNumber =
                                                    !_hideCardNumber;
                                              });
                                            },
                                          ),

                                          // GestureDetector(
                                          //   onTap: () {
                                          //     setState(() {
                                          //       _hideCardNumber = !_hideCardNumber;
                                          //     });
                                          //   },
                                          //   child: Image.asset(
                                          //       'icons/Show_Password.png'),
                                          // ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  _hasCardNumberError
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5),
                            Text(
                              _cardNumberError,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFFF55A51),
                              ),
                            ),
                          ],
                        )
                      : new Container(),
                  SizedBox(height: 10),
                  // _hasError && errorCard!=''? Row(
                  //   children: <Widget>[
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: <Widget>[
                  //           Text(errorCard,
                  //             style: TextStyle(
                  //               fontFamily: 'Urbanist',
                  //               fontSize: 14,
                  //               color: Color(0xFFF55A51),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ) : new Container(),
                  // _hasError  && errorCard!=''?SizedBox(height: 10):Container(),
                  // Name on card
                  _hideNameOnCardInput
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _hideNameOnCardInput = false;
                            });
                            nameFocusNode!.requestFocus();
                          },
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Name on card',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          _isCardDataAvailable
                                              ? '**********'
                                              : '',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Row(
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
                                        focusNode: nameFocusNode,
                                        onChanged: nameText,
                                        controller: _nameOnCard,
                                        maxLength: 100,
                                        maxLines: 2,
                                        minLines: 1,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              (RegExp('[a-zA-Z ]')),
                                              replacementString: '')
                                        ],
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(16.0),
                                            border: InputBorder.none,
                                            hintText: 'Enter name on card',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14, // Adjust the font size as needed
                                              color: Colors.grey, // You can customize the color as well
                                            ),
                                            counterText: ''),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  _hasNameError
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5),
                            SizedText(
                              deviceWidth: deviceWidth,
                              textWidthPercentage: 0.9,
                              text: _nameError,
                              fontFamily: 'Urbanist',
                              fontSize: 12,
                              textColor: Color(0xFFF55A51),
                            ),
                          ],
                        )
                      : new Container(),
                  SizedBox(height: 10),
                  // Expire date
                  _hideExpireDateInput
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _hideExpireDateInput = false;
                            });
                            expireFocusNode!.requestFocus();
                          },
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Exp. Date (MM/YY)',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          '##/##',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Row(
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
                                      child: new TextFormField(
                                        focusNode: expireFocusNode,
                                        controller: _expDate,
                                        onChanged: _countExpireDate,
                                        maxLength: 5,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9/]+$')),
                                          // ExpiryDateInputFormatter(),
                                        ],
                                        decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14, // Adjust the font size as needed
                                                  color: Colors.grey, // You can customize the color as well
                                                ),
                                            contentPadding:
                                                EdgeInsets.all(16.0),
                                            border: InputBorder.none,
                                            hintText: 'Enter exp. date (MM/YY)',
                                            counterText: ""),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  _hasExpDateError
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5),
                            Text(
                              _expDateError,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFFF55A51),
                              ),
                            ),
                          ],
                        )
                      : new Container(),
                  SizedBox(height: 10),
                  // _hasError ?
                  // Row(
                  //   children: <Widget>[
                  //     Expanded(
                  //       child: Column(
                  //         crossAxisAlignment: CrossAxisAlignment.start,
                  //         children: <Widget>[
                  //           Text(errorExp,
                  //             style: TextStyle(
                  //               fontFamily: 'Urbanist',
                  //               fontSize: 14,
                  //               color: Color(0xFFF55A51),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ],
                  // ):Container() ,
                  // CVV
                  _hideCvvInput
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _hideCvvInput = false;
                            });
                            cvvFocusNode!.requestFocus();
                          },
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          'CVV',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          _isCardDataAvailable ? '***' : '',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Row(
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
                                        focusNode: cvvFocusNode,
                                        maxLength: 4,
                                        controller: _cvv,
                                        obscureText: _hideCVV,
                                        onChanged: _countCVVNumber,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              (RegExp(r'^[0-9]+$')))
                                        ],
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(16.0),
                                          border: InputBorder.none,
                                          hintText: 'Enter CVV',
                                          hintStyle: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14, // Adjust the font size as needed
                                            color: Colors.grey, // You can customize the color as well
                                          ),
                                          counterText: "",
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _hideCVV
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Color(0xff353B50),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _hideCVV = !_hideCVV;
                                              });
                                            },
                                          ),
                                          // GestureDetector(
                                          //   onTap: () {
                                          //     setState(() {
                                          //       _hideCVV = !_hideCVV;
                                          //     });
                                          //   },
                                          //   child: Image.asset(
                                          //       'icons/Show_Password.png'),
                                          // ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  _hasCvvError
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5),
                            Text(
                              _cvvError,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFFF55A51),
                              ),
                            ),
                          ],
                        )
                      : new Container(),
                  SizedBox(height: 10),
                  // Postal code
                  _hidePostalCodeInput
                      ? GestureDetector(
                          onTap: () {
                            setState(() {
                              _hidePostalCodeInput = false;
                            });
                            codeFocusNode!.requestFocus();
                          },
                          child: SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              padding: EdgeInsets.all(16.0),
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: new BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: [
                                        Text(
                                          'Postal code',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          _isCardDataAvailable ? '*******' : '',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Row(
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
                                        focusNode: codeFocusNode,
                                        controller: _postalCode,
                                        onChanged: _countPostalCode,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(
                                              RegExp(r'^\w[a-zA-Z0-9 ]*'),
                                              replacementString: ''),
                                        ],
                                        textCapitalization:
                                            TextCapitalization.characters,
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(16.0),
                                            border: InputBorder.none,
                                            hintText: 'Enter postal code',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14, // Adjust the font size as needed
                                              color: Colors.grey, // You can customize the color as well
                                            ),
                                            counterText: ""),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  _hasPostalCodeError
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(height: 5),
                            Text(
                              _postalCodeError,
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFFF55A51),
                              ),
                            ),
                          ],
                        )
                      : new Container(),
                  // SizedBox(height: 10),
                  // Security message

                  SizedBox(height: 30),
                  _hasError ? SizedBox(height: 10) : new Container(),
                  _hasError
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    _error,
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
                  SizedBox(
                    height: 10,
                  ),
                  // Save button
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
                                      borderRadius: BorderRadius.circular(8.0)),

                                ),
                                onPressed: () async {
                                  if ((_cardNumber.text.length >= 14 &&
                                          _cardNumber.text.length <= 16) &&
                                      _nameOnCard.text.length > 0 &&
                                      _expDate.text.length == 5 &&
                                      (_cvv.text.length == 3 ||
                                          _cvv.text.length == 4) &&
                                      (_postalCode.text.length > 0 &&
                                          _postalCode.text.length <= 10)) {
                                    var data = {
                                      "UserID": _userID,
                                      "Number": _cardNumber.text,
                                      "Name": _nameOnCard.text,
                                      "ExpMonth": int.parse(
                                          _expDate.text.split('/')[0]),
                                      "ExpYear": int.parse(
                                          _expDate.text.split('/')[1]),
                                      "CVV": _cvv.text,
                                      "PostalCode": _postalCode.text
                                    };
                                    setState(() {
                                      _hasError = false;
                                      errorCard = '';
                                      errorExp = '';
                                    });

                                    var res = await addCard(data);
                                    if (!_paymentClicked) {
                                      _paymentClicked = true;
                                      if (res.statusCode == 200) {
                                        var cardInfoRes = await fetchCardData(_userID);

                                        // Navigator.pushNamed(context, '/profile').then((value) => _paymentClicked = false);
                                        var data = PaymentCardInfo.fromJson(json.decode(cardInfoRes.body!));
                                        AppEventsUtils.logEvent("payment_method_updated", params: {
                                          "payment_method_available": data.cardInfo != null && data.cardInfo!.length > 0
                                        });
                                        Navigator.pop(context, data);
                                        // Navigator.pushNamed(context,'/about_you_tab');

                                      } else {
                                        setState(() {
                                          _error = json.decode(json
                                              .decode(res.body!)['message']
                                              .split(': ')[1]
                                              .toString())['message'];
                                          _hasError = true;
                                          _paymentClicked = false;
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        _error = json.decode(json
                                            .decode(res.body!)['message']
                                            .split(': ')[1]
                                            .toString())['message'];
                                        //
                                        // if(json.decode(json.decode(res.body!)['message'].split(': ')[1].toString())['message']=='Your card number is incorrect.'){
                                        //   errorCard='Your card number is incorrect.';
                                        //
                                        // }
                                        // if(_error=='Your card\'s expiration year is invalid.'){
                                        //   errorExp='Your card\'s expiration year is invalid.';
                                        //   print('yearerror$errorExp');
                                        //
                                        // }
                                        _hasError = true;
                                        _paymentClicked = false;
                                      });
                                    }
                                  } else {
                                    if (_cardNumber.text.length < 14 ||
                                        _cardNumber.text.length > 16) {
                                      setState(() {
                                        _hasCardNumberError = true;
                                        _cardNumberError =
                                            'Card length should be at least 14.';
                                      });
                                    } else {
                                      setState(() {
                                        _hasCardNumberError = false;
                                      });
                                    }
                                    if (_nameOnCard.text.length == 0) {
                                      setState(() {
                                        _hasNameError = true;
                                        _nameError =
                                            'Special characters and numbers are not allowed.';
                                      });
                                    } else {
                                      setState(() {
                                        _hasNameError = false;
                                      });
                                    }
                                    print('expireValu${_expDate.text.length}');
                                    if (_expDate.text.length == 0) {
                                      print(_expDate.text.length);
                                      setState(() {
                                        _hasExpDateError = true;
                                        _expDateError =
                                            'Expiry date is required.';
                                      });
                                    } else {
                                      setState(() {
                                        _hasExpDateError = false;
                                      });
                                    }
                                    if (_cvv.text.length != 3 &&
                                        _cvv.text.length != 4) {
                                      setState(() {
                                        _hasCvvError = true;
                                        _cvvError =
                                            'CVV should be valid number format.';
                                      });
                                    } else {
                                      setState(() {
                                        _hasCvvError = false;
                                      });
                                    }
                                    if (_postalCode.text == '') {
                                      setState(() {
                                        _hasPostalCodeError = true;
                                        _postalCodeError =
                                            'Postal code should be at least 10.';
                                      });
                                    } else {
                                      setState(() {
                                        _hasPostalCodeError = false;
                                      });
                                    }
                                  }
                                },
                                child: Text(
                                  'Save',
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
            )
          : Center(
              child: ShimmerEffect()
            ),
    );
  }
}

Future<RestApi.Resp> addCard(_cardDate) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    addCardUrl,
    json.encode({
      "UserID": _cardDate['UserID'],
      "Number": _cardDate['Number'].toString(),
      "Name": _cardDate['Name'].toString(),
      "ExpMonth": _cardDate['ExpMonth'].toString(),
      "ExpYear": _cardDate['ExpYear'].toString(),
      "CVV": _cardDate['CVV'].toString(),
      "PostalCode": _cardDate['PostalCode'].toString()
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
