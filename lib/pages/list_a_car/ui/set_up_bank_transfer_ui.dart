import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridealike/pages/list_a_car/bloc/payment_method_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/payout_method_response.dart';

import '../../../utils/app_events/app_events_utils.dart';

class BankTransferUi extends StatefulWidget {
  @override
  State createState() => BankTransferUiState();
}

class BankTransferUiState extends State<BankTransferUi> {


  final paymentMethodBloc=PaymentMethodBloc();
  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Set Up bank Transfer"});
  }



  @override
  Widget build (BuildContext context) {

    FetchPayoutMethodResponse payoutMethodResponse = ModalRoute.of(context)!.settings.arguments as FetchPayoutMethodResponse;
    payoutMethodResponse.payoutMethod!.payoutMethodType='direct_deposit';
    paymentMethodBloc.changedPaymentMethod.call(payoutMethodResponse);
    paymentMethodBloc.changedProgressIndicator.call(0);
    
    return Scaffold(
      backgroundColor: Colors.white,
      
      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
             Navigator.pop(context, false);
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text('Save & Exit',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xFFFF8F62),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        elevation: 0.0,
      ),

      body: StreamBuilder<FetchPayoutMethodResponse>(
        stream: paymentMethodBloc.paymentMethodData,
        builder: (context, paymentMethodDataSnapshot) {
          return paymentMethodDataSnapshot.hasData&& paymentMethodDataSnapshot.data!=null?
            Container(
            child: new SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  child: Text('Direct Deposit',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 36,
                                      color:Color(0xFF371D32),
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Image.asset('icons/Payout-Payout.png'),
                      ],
                    ),
                    SizedBox(height: 30),
                    // Section header
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Text('Enter the account address',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 18,
                                    color: Color(0xFF371D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    // Address
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
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: TextFormField(
                                    initialValue: paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.address,
                                   onChanged: (address){
                                     paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.address=address;
                                     paymentMethodBloc.changedPaymentMethod.call( paymentMethodDataSnapshot.data!);

                                   },
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9/ \#.,-]'),replacementString: '')],
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'Address',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Please enter your address'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // City
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
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: TextFormField(
                                    initialValue: paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.city,
                                   onChanged: (city){
                                     paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.city=city;
                                     paymentMethodBloc.changedPaymentMethod.call( paymentMethodDataSnapshot.data!);
                                   },
                                    textCapitalization: TextCapitalization.sentences,
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'),replacementString:'' )],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'City',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Please enter city'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Province & Postal code
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
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: TextFormField(
                                    initialValue: paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.province,
                                  onChanged: (province){
                                    paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.province=province;
                                    paymentMethodBloc.changedPaymentMethod.call( paymentMethodDataSnapshot.data!);
                                  },
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]'),replacementString: '')],
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'Province',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Please enter province'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: TextFormField(
                                    initialValue: paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.postalCode,
                                onChanged: (postalCode){
                                  paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.postalCode=postalCode;
                                  paymentMethodBloc.changedPaymentMethod.call( paymentMethodDataSnapshot.data!);
                                },
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9._-]'),replacementString: '')],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'Postal Code',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Please enter postal Code'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // Country
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
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: TextFormField(
                                    initialValue: paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.country,
                                 onChanged: (country){
                                   paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.country=country;
                                   paymentMethodBloc.changedPaymentMethod.call( paymentMethodDataSnapshot.data!);
                                 },
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'),replacementString:'')],
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'Country',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Please enter country'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    // Section header
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Text('Enter bank transfer information',
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 18,
                                    color: Color(0xFF371D32),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    // Name
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
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: TextFormField(
                                    initialValue: paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.name,
                                   onChanged: (name){
                                     paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.name=name;
                                     paymentMethodBloc.changedPaymentMethod.call( paymentMethodDataSnapshot.data!);
                                   },
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]'),replacementString:'')],
                                    textCapitalization: TextCapitalization.sentences,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'Name',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Please enter name'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    // IBAN
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
                                    borderRadius: BorderRadius.circular(8.0)
                                  ),
                                  child: TextFormField(
                                    initialValue: paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.iBAN,
                                   onChanged: (iBAN){
                                     paymentMethodDataSnapshot.data!.payoutMethod!.directDepositData!.iBAN=iBAN;
                                     paymentMethodBloc.changedPaymentMethod.call( paymentMethodDataSnapshot.data!);
                                   },
                                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 @._-]'),replacementString:'')],
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(22.0),
                                      border: InputBorder.none,
                                      labelText: 'IBAN',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Please enter IBAN'
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    // Next button
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: StreamBuilder<int>(
                                  stream: paymentMethodBloc.progressIndicator,
                                  builder: (context, progressIndicatorSnapshot) {
                                    return progressIndicatorSnapshot.hasData && progressIndicatorSnapshot.data!= null?
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xffFF8F68),
                                        padding: EdgeInsets.all(16.0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                      ),
                                      onPressed: progressIndicatorSnapshot.data ==1 || paymentMethodBloc.checkButtonDisability(paymentMethodDataSnapshot.data!)?null:() async {
                                        paymentMethodBloc.changedProgressIndicator.call(1);
                                        var resp=  await  paymentMethodBloc.payPalPaymentMethod(paymentMethodDataSnapshot.data!);
                                        if(resp!=null){
                                          Navigator.pop(context,true);
                                        }else{
                                          Navigator.pop(context,false);
                                        }
                                      },
                                      child:  progressIndicatorSnapshot.data ==1? SizedBox(
                                        height: 18.0,
                                        width: 18.0,
                                        child: new CircularProgressIndicator(strokeWidth: 2.5),
                                      ):Text('Next',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          color: Colors.white
                                        ),
                                      ),
                                    ):Container();
                                  }
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
          ):Container();
        }
      ),
    );
  }
}
