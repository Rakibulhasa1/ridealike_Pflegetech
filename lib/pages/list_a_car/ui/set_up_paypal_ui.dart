import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridealike/pages/list_a_car/bloc/payment_method_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/payout_method_response.dart';

import '../../../utils/app_events/app_events_utils.dart';

class PayPalSetupUi extends StatefulWidget {
  @override
  State createState() => PayPalSetupUiState();
}

class PayPalSetupUiState extends State<PayPalSetupUi> {
  final paymentMethodBloc=PaymentMethodBloc();


  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Setup Paypal"});
  }



  @override
  Widget build (BuildContext context) {
    final FetchPayoutMethodResponse payoutMethodResponse = ModalRoute.of(context)!.settings.arguments as FetchPayoutMethodResponse;
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
        // elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
        elevation: 0.0,
      ),

      body: StreamBuilder<FetchPayoutMethodResponse>(
        stream: paymentMethodBloc.paymentMethodData,
        builder: (context, paymentMethodDataSnapshot) {
          return paymentMethodDataSnapshot.hasData && paymentMethodDataSnapshot.data!=null?
            Container(
            child: new SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                  child: Column(
                  children: <Widget>[
                    SizedBox(height: 160),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                child: Column(
                                  children: <Widget>[
                                    Image.asset('icons/PayPal.png'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 40),
                    //email//
                    Column(
                      children: [
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
                                        keyboardType: TextInputType.emailAddress,
                                        inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'^[a-zA-Z0-9@._-]+$')))],
                                        initialValue: paymentMethodDataSnapshot.data!.payoutMethod!.paypalData!.email,
                                        onChanged: (email){
                                          paymentMethodDataSnapshot.data!.payoutMethod!.payoutMethodType ='paypal';
                                          paymentMethodDataSnapshot.data!.payoutMethod!.paypalData!.email = paymentMethodBloc.validateEmail(email);
                                          paymentMethodBloc.changedPaymentMethod.call(paymentMethodDataSnapshot.data!);
                                        },
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(22.0),
                                          border: InputBorder.none,
                                          labelText: 'Email',
                                          labelStyle: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 12,
                                            color: Color(0xFF353B50),
                                          ),
                                          hintText: 'Please enter email'
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8,),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: StreamBuilder<String>(
                                  stream: paymentMethodBloc.error,
                                  builder: (context, snapshot) {
                                    return
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          snapshot.hasError?
                                          Text(snapshot.hasError?snapshot.error.toString():'',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xFFF55A51),
                                            ),
                                          ):Container(),
                                          snapshot.hasError? SizedBox(height: 15) : new Container(),
                                        ],
                                      );
                                  }
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                   SizedBox(
                     height: 10,
                   ),
                    Container(height: 50,
                      width: MediaQuery.of(context).size.width*.95,
                      child: AutoSizeText('Please ensure your email is accurate as payments sent to an incorrect address cannot be returned.',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF353B50),
                        ),maxLines: 2,),
                    ),
//button//
                    SizedBox(height: 30),
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
                                        backgroundColor:  progressIndicatorSnapshot.data ==1 || paymentMethodDataSnapshot.data!.payoutMethod!.paypalData!.email==''? Colors.grey:Color(0xffFF8F68),
                                        padding: EdgeInsets.all(16.0),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                      ),
                                       onPressed: progressIndicatorSnapshot.data ==1 || paymentMethodDataSnapshot.data!.payoutMethod!.paypalData!.email==''?
                                      null:() async {
                                        paymentMethodBloc.changedProgressIndicator.call(1);
                                        var resp=  await  paymentMethodBloc.payPalPaymentMethod( paymentMethodDataSnapshot.data!);
//                                        paymentMethodBloc.changedProgressIndicator.call(0);
                                        if(resp!=null){
                                          Navigator.pop(context,true);
                                        }else{
                                          Navigator.pop(context,false);
                                        }
                                      },
                                      child: progressIndicatorSnapshot.data ==1? SizedBox(
                                        height: 18.0,
                                        width: 18.0,
                                        child: new CircularProgressIndicator(strokeWidth: 2.5),
                                      ) : Text('Next',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          color: Colors.white
                                        ),
                                      ),
                                    ): Container();
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
