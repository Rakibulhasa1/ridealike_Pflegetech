import 'package:flutter/material.dart';
import 'package:ridealike/pages/list_a_car/response_model/payout_method_response.dart';

import '../../../utils/app_events/app_events_utils.dart';

class PaymentMethodUi extends StatefulWidget {
  @override
  State createState() => PaymentMethodUiState();
}

class PaymentMethodUiState extends State<PaymentMethodUi> {

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "How Would You Like To Be Paid Out"});
  }

  @override
  Widget build(BuildContext context) {
    final FetchPayoutMethodResponse payoutMethodResponse =
        ModalRoute.of(context)!.settings.arguments as FetchPayoutMethodResponse;

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

                    Navigator.pushNamed(context, '/dashboard_tab');
                  },
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.only(right: 16),
                      child: Text(
                        'Save & Exit',
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

        //Content of tabs
        body: new SingleChildScrollView(
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
                              child: Text(
                                'How would you like to receive your earnings?',
                                style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 36,
                                    color: Color(0xFF371D32),
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset('icons/Payout-Payout.png'),
                  ],
                ),
                SizedBox(height: 20),
                // Text
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: Text(
                              'Select the way you would like to receive your earnings. You will be paid out within 5 business days after each trip.',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xFF353B50),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                //interc
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Color(0xFFF2F2F2),
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),

                              ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/set_up_interac_ui',
                                    arguments: payoutMethodResponse,
                                  ).then((value) {
                                    if (value != null) {
                                      Navigator.pop(context, value);
                                    }
                                  });
                                },
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Row(children: [
                                        Image.asset(
//                                          'icons/interac.png',
                                        'icons/Logo-interac-black.png',
                                          height: 25,
                                          width: 25,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'Set up Interac e-Transfer',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Container(
                                      width: 16,
                                      child: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Color(0xFF353B50),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // PayPal
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Color(0xFFF2F2F2),
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),

                              ),
                                onPressed: () {
                                  Navigator.pushNamed(
                                          context, '/set_up_paypal_ui',
                                          arguments: payoutMethodResponse)
                                      .then((value) {
                                    if (value != null) {
                                      Navigator.pop(context, value);
                                    }
                                  });
                                  //then//
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      child: Row(children: [
                                        Image.asset('icons/PayPal_copy.png'),
                                        SizedBox(width: 10),
                                        Text(
                                          'Set up PayPal',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Container(
                                      width: 16,
                                      child: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Color(0xFF353B50),
                                      ),
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // Bank transfer
//                Row(
//                  children: <Widget>[
//                    Expanded(
//                      child: Column(
//                        children: <Widget>[
//                          SizedBox(
//                            width: double.maxFinite,
//                            child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                elevation: 0.0,
//                                color: Color(0xFFF2F2F2),
//                                padding: EdgeInsets.all(16.0),
//                                shape: RoundedRectangleBorder(
//                                    borderRadius: BorderRadius.circular(8.0)),
//                                onPressed: () {
//                                  Navigator.pushNamed(
//                                          context, '/set_up_bank_transfer_ui',
//                                          arguments: payoutMethodResponse)
//                                      .then((value) {
//                                    if (value != null) {
//                                      Navigator.pop(context, value);
//                                    }
//                                  });
//                                },
//                                child: Row(
//                                  mainAxisAlignment:
//                                      MainAxisAlignment.spaceBetween,
//                                  children: <Widget>[
//                                    Container(
//                                      child: Row(children: [
//                                        Image.asset('icons/Payout-Method.png'),
//                                        SizedBox(width: 15),
//                                        Text(
//                                          'Direct Deposit',
//                                          style: TextStyle(
//                                            fontFamily: 'Urbanist',
//                                            fontSize: 16,
//                                            color: Color(0xFF371D32),
//                                          ),
//                                        ),
//                                      ]),
//                                    ),
//                                    Container(
//                                      width: 16,
//                                      child: Icon(
//                                        Icons.keyboard_arrow_right,
//                                        color: Color(0xFF353B50),
//                                      ),
//                                    ),
//                                  ],
//                                )),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ],
//                ),
                // Interac



              ],
            ),
          ),
        ));
  }
}
