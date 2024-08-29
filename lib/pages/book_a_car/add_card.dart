import 'dart:async';
import 'dart:convert' show json;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:masked_text/masked_text.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/utils/app_events/app_events_utils.dart';

import 'booking_info.dart';
import 'cvv_modal.dart';

class AddCard extends StatefulWidget {
  final bookingInfo;

  AddCard({this.bookingInfo});

  @override
  State createState() => AddCardState(bookingInfo);
}

class AddCardState extends State<AddCard> {
  bool _hasCardNumberError = false;
  bool _hasNameError = false;
  bool _hasExpDateError = false;
  bool _hasCvvError = false;
  bool _hasPostalCodeError = false;

  String _cardNumberError = '';
  String _nameError = '';
  String _expDateError = '';
  String _cvvError = '';
  String _postalCodeError = '';


  String errorCard ='';
  String errorExp='' ;

  _countCardNumber(String value) {
    if (value.length == 16) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    setState(() {
      _hasCardNumberError = false;
      _cardNumberError = '';
    });
  }

  _countExpireDate(String value) {
    if (value.length > 2 && int.parse(value.substring(0, 2)) > 12) {
      _expDate.text = '';
      _expDate.selection = TextSelection.fromPosition(
          TextPosition(offset: _expDate.text.length));
      return;
    }
    if (value.length > 3 && int.parse(value[3]) >= 4) {
      _expDate.text = value.substring(0, 3);
      _expDate.selection = TextSelection.fromPosition(
          TextPosition(offset: _expDate.text.length));
    }
    if (value.length == 5) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    setState(() {
      _hasExpDateError = false;
      _expDateError = '';
    });
  }
  _countCVVNumber(String value) {
    if (value.length == 4) {
      FocusScope.of(context).requestFocus(FocusNode());
    }
    setState(() {
      _hasCvvError = false;
      _cvvError = '';
    });

  }

  _countPostalCode(String value) {

    setState(() {
      _hasPostalCodeError = false;
      _postalCodeError = '';
    });

  }
  nameText(String value){
    if (value.length == 1) {

    }
    setState(() {
      _hasNameError = false;
      _nameError = '';
    });
  }
  var bookingInfo;

  AddCardState(this.bookingInfo);

  String _error = '';
  bool _hasError = false;

  bool _hideCardNumberInput = true;
  bool _hideNameOnCardInput = true;
  bool _hideExpireDateInput = true;
  bool _hideCvvInput = true;
  bool _hidePostalCodeInput = true;

  final storage = new FlutterSecureStorage();

 FocusNode? cardFocusNode;
  FocusNode? nameFocusNode;
  FocusNode? expireFocusNode;
  FocusNode? cvvFocusNode;
  FocusNode? codeFocusNode;

  void handleShowCVVModal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return CvvModal();
      },
    );
  }

  void handleShowBookingInfodModal(context) {
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      context: context,
      builder: (context) {
        return BookingInfo(
          bookingInfo: bookingInfo,
        );
      },
    );
  }

  final TextEditingController _cardNumber = TextEditingController();
  final TextEditingController _nameOnCard = TextEditingController();
  final TextEditingController _expDate = TextEditingController();
  final TextEditingController _cvv = TextEditingController();
  final TextEditingController _postalCode = TextEditingController();

  bool _hideCardNumber = true;
  bool _hideCVV = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      color: Color.fromRGBO(64, 64, 64, 1),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height / 2,
          maxHeight: MediaQuery.of(context).size.height - 24,
        ),
        child: Container(
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          // height: MediaQuery.of(context).size.height / 2,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: ListView(

            shrinkWrap: true,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: Text(
                        "Add card",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF371D32),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16,left: 16,right: 16,bottom: 10),
                child: Column(children: [
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Image.asset('icons/Security.png'),
                      SizedBox(width: 10),
                      AutoSizeText(
                        // 'Add your payment method using our secure payment system.',
                        'Secure credit card processing by Stripe.',
                        maxLines: 2,
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          color: Color(0xFF353B50),
                        ),
                      ),
                    ],
                  ),
                ],),
              ),
              SizedBox(height: 10),
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
                          margin: EdgeInsets.only(right: 16.0, left: 16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: new BoxDecoration(
                            color: Color(0xFFF2F2F2),
                            borderRadius: new BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      '',
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
                                  margin:
                                      EdgeInsets.only(right: 16.0, left: 16.0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)),
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
                                      suffixIcon: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _hideCardNumber = !_hideCardNumber;
                                          });
                                        },
                                        child: Image.asset(
                                            'icons/Show_Password.png'),
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
              _hasCardNumberError
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 20,
                        ),
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


              _hasError && errorCard!=''? Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(errorCard,
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
              ) : new Container(),
              _hasError  && errorCard!=''?SizedBox(height: 10):Container(),
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
                          margin: EdgeInsets.only(right: 16.0, left: 16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: new BoxDecoration(
                            color: Color(0xFFF2F2F2),
                            borderRadius: new BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      '',
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
                                  margin:
                                      EdgeInsets.only(right: 16.0, left: 16.0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: TextFormField(
                                    focusNode: nameFocusNode,
                                    controller: _nameOnCard,
                                    onChanged: nameText,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          (RegExp(r'^[A-Za-z ]+$')))
                                    ],
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(16.0),
                                      border: InputBorder.none,
                                      hintText: 'Enter name on card',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14, // Adjust the font size as needed
                                        color: Colors.grey, // You can customize the color as well
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
              _hasNameError
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 20,
                        ),
                        SizedBox(height: 5),
                        Text(
                          _nameError,
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
                          margin: EdgeInsets.only(right: 16.0, left: 16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: new BoxDecoration(
                            color: Color(0xFFF2F2F2),
                            borderRadius: new BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      '',
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
                                  margin:
                                      EdgeInsets.only(right: 16.0, left: 16.0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: new MaskedTextField(
                                    focusNode: expireFocusNode,
                                    controller: _expDate,
                                    // escapeCharacter: '#',
                                    mask: "##/##",
                                    onChanged: _countExpireDate,
                                    maxLength: 5,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(16.0),
                                        border: InputBorder.none,
                                        hintText: 'Enter exp. date (MM/YY)',
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
              _hasExpDateError
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          width: 20,
                        ),
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
              _hasError ?
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(errorExp,
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
              ):Container(),
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
                          margin: EdgeInsets.only(right: 16.0, left: 16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: new BoxDecoration(
                            color: Color(0xFFF2F2F2),
                            borderRadius: new BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
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
                                          SizedBox(width: 5),
                                          GestureDetector(
                                            onTap: () =>
                                                handleShowCVVModal(context),
                                            child: Icon(Icons.info,
                                                color: Color(0xffE0E0E0),
                                                size: 18),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                child: Row(
                                  children: <Widget>[
                                    Text(
                                      '',
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
                                  margin:
                                      EdgeInsets.only(right: 16.0, left: 16.0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)),
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
                                      suffixIcon:   IconButton(
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
                        SizedBox(
                          width: 20,
                        ),
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
                          margin: EdgeInsets.only(right: 16.0, left: 16.0),
                          padding: EdgeInsets.all(16.0),
                          decoration: new BoxDecoration(
                            color: Color(0xFFF2F2F2),
                            borderRadius: new BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      '',
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
                                  margin:
                                      EdgeInsets.only(right: 16.0, left: 16.0),
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: TextFormField(
                                    focusNode: codeFocusNode,
                                    controller: _postalCode,
                                    onChanged: _countPostalCode,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]'),replacementString: ''),
                                    ],
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(16.0),
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
                        SizedBox(
                          width: 20,
                        ),
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
              SizedBox(height: 10),

              Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
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
                                if (_cardNumber.text.length == 16 &&
                                    _nameOnCard.text.length > 0 &&
                                    _expDate.text.length == 5 &&
                                    _cvv.text.length == 3 ||  _cvv.text.length == 4 && _postalCode.text!='') {
                                  String? userID = await storage.read(key: 'user_id');

                                  var data = {
                                    "UserID": userID,
                                    "Number": _cardNumber.text,
                                    "Name": _nameOnCard.text,
                                    "ExpMonth":
                                        int.parse(_expDate.text.split('/')[0]),
                                    "ExpYear":
                                        int.parse(_expDate.text.split('/')[1]),
                                    "CVV": _cvv.text,
                                    "PostalCode": _postalCode.text
                                  };
                                  setState(() {
                                    _hasError = false;
                                  });


                                  var res = await addCard(data);

                                  if (res.statusCode == 200) {
                                    AppEventsUtils.logEvent("card_add_success");
                                    handleShowBookingInfodModal(context);
                                  } else {
                                    AppEventsUtils.logEvent("card_add_failure");
                                    setState(() {
                                      _error = json.decode(json.decode(res.body!)['message'].split(': ')[1].toString())['message'];
                                      if(json.decode(json.decode(res.body!)['message'].split(': ')[1].toString())['message']=='Your card number is incorrect.'){
                                        errorCard='Your card number is incorrect.';

                                      }
                                      if(_error=='Your card\'s expiration year is invalid.'){
                                        errorExp='Your card\'s expiration year is invalid.';
                                        print('yearerror$errorExp');

                                      }
                                      _hasError = true;
                                    });
                                  }
                                } else {
                                  if (_cardNumber.text.length != 16) {
                                    setState(() {
                                      _hasCardNumberError = true;
                                      _cardNumberError =
                                          'Card length should be 16.';
                                    });
                                  } else {
                                    setState(() {
                                      _hasCardNumberError = false;
                                    });
                                  }
                                  if (_nameOnCard.text.length == 0) {
                                    setState(() {
                                      _hasNameError = true;
                                      _nameError = 'Special characters and numbers are not allowed.';
                                    });
                                  } else {
                                    setState(() {
                                      _hasNameError = false;
                                    });
                                  }
                                  print(_expDate.text.length);
                                  if (_expDate.text.length != 5) {
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
                                  if (_cvv.text.length != 3||_cvv.text.length != 4) {
                                    setState(() {
                                      _hasCvvError = true;
                                      _cvvError = 'CVV should be valid number format.';
                                    });
                                  } else {
                                    setState(() {
                                      _hasCvvError = false;
                                    });
                                  }
                                  if (_postalCode.text=='') {
                                    setState(() {
                                      _hasPostalCodeError = true;
                                      _postalCodeError =
                                          'Postal code is required.';
                                    });
                                  } else {
                                    setState(() {
                                      _hasPostalCodeError = false;
                                    });
                                  }
                                }
                              },
                              child: Text(
                                'Add card',
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
              ),
              // Won't be charged
              Padding(
                padding: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'You won’t be charged yet',
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
    );
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Card Add"});
    cardFocusNode = FocusNode();
    nameFocusNode = FocusNode();
    expireFocusNode = FocusNode();
    cvvFocusNode = FocusNode();
    codeFocusNode = FocusNode();
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
