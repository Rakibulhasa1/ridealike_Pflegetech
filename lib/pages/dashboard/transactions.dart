import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';

import '../../utils/app_events/app_events_utils.dart';

Future<http.Response> fetchUsersData(_userIDs) async {
  final response = await http.post(
    Uri.parse(getProfilesByUserIDsUrl),
    // getProfilesByUserIDsUrl as Uri,
    body: json.encode({
      "UserIDs": _userIDs
    }),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

const textStyle = TextStyle(
  color: Color(0xff371D32),
  fontSize: 36,
  fontFamily: 'Urbanist',
  fontWeight: FontWeight.bold,
  letterSpacing: -0.2
);


class Transactions extends StatefulWidget {
  @override
  State createState() => TransactionsState();
}

class TransactionsState extends State<Transactions> {
  List _transactionData = [];
  Map _receivedData = {};

  List _userIDsList = [];
  List _profileData = [];

  final storage = new FlutterSecureStorage();

  // final children = <Widget>[];

  DateTime today = new DateTime.now();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Transactions"});
    Future.delayed(Duration.zero,() async {
      _receivedData = ModalRoute.of(context)!.settings.arguments as Map;

      String? userID = await storage.read(key: 'user_id');

      for (int i = 0; i < _receivedData['Transactions'].length; i++) {
        if (_receivedData['Transactions'][i]['PayerUserID'] == userID) {
          _userIDsList.add(_receivedData['Transactions'][i]['PayeeUserID']);
        } else if (_receivedData['Transactions'][i]['PayeeUserID'] == userID) {
          _userIDsList.add(_receivedData['Transactions'][i]['PayerUserID']);
        }
      }

      var res = await fetchUsersData(_userIDsList);

      if (json.decode(res.body!)['Profiles'] != null) {
        for (int j = 0; j < _receivedData['Transactions'].length; j++) {
          for (int k = 0; k < json.decode(res.body!)['Profiles'].length; k++) {
            if (_receivedData['Transactions'][j]['PayerUserID'] == userID
                && _receivedData['Transactions'][j]['PayeeUserID'] == json.decode(res.body!)['Profiles'][k]['UserID']) {
              var _tempUserdata = {
                "Name": json.decode(res.body!)['Profiles'][k]['FirstName'] + ' ' + json.decode(res.body!)['Profiles'][k]['LastName'],
                "Amount": '\$' + double.parse(_receivedData['Transactions'][j]['HostIncome'].toString()).toStringAsFixed(2),
                "Type": _receivedData['Transactions'][j]['TransactionType'] == "TransactionRental" ? 'Rental' : 'Swap',
                "Time": DateFormat('MMM dd').format(DateTime.parse(_receivedData['Transactions'][j]['CreatedAt'])),
                "BookingID": _receivedData['Transactions'][j]['BookingID']
              };

              _transactionData.add(_tempUserdata);
            } else if (_receivedData['Transactions'][j]['PayeeUserID'] == userID
                && _receivedData['Transactions'][j]['PayerUserID'] == json.decode(res.body!)['Profiles'][k]['UserID']) {
              var _tempUserdata = {
                "Name": json.decode(res.body!)['Profiles'][k]['FirstName'] + ' ' + json.decode(res.body!)['Profiles'][k]['LastName'],
                "Amount": '\$' + double.parse(_receivedData['Transactions'][j]['HostIncome'].toString()).toStringAsFixed(2),
                "Type": _receivedData['Transactions'][j]['TransactionType'] == "TransactionRental" ? 'Rent out' : 'Swap',
                "Time": DateFormat('MMM dd').format(DateTime.parse(_receivedData['Transactions'][j]['CreatedAt'])),
                "BookingID": _receivedData['Transactions'][j]['BookingID']
              };

              _transactionData.add(_tempUserdata);
            }
          }
        }
      }

      setState(() {

        _profileData = _transactionData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Transactions', 
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: Color(0xff371D32),
          ),
        ),
        centerTitle: true,
        elevation: 0.0,
      ),
      
      body:_profileData!=null?
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _profileData.length!=0?
          Column(
            children: <Widget>[
              // Month header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(DateFormat("MMMM").format(today).toUpperCase() + ' ' + DateFormat("y").format(today),
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xff371D32),
                    ),
                  ),
                  _receivedData['ThisMonthsIncome']!=null && _receivedData['ThisMonthsIncome']!=''?
                  Text('\$${double.parse( _receivedData['ThisMonthsIncome'].toString()).toStringAsFixed(2)}',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xff353B50),
                    ),
                  ):Text(''),
                ],
              ),
              SizedBox(height: 30),
              // Transaction row
              for(int a = 0; a < _profileData.length; a++)
                _profileData[a]['Type'] =='Rental'?
                Container():
                InkWell(onTap: (){
                  _profileData[a]['Type'] =='Swap'?  Navigator.pushNamed(
                      context,
                      '/receipt_swap',
                      arguments: _profileData[a]['BookingID']
                  ):
                  Navigator.pushNamed(
                      context,
                      '/receipt',
                      arguments: _profileData[a]['BookingID']
                  );
                },
                  child: Column(
                  children: <Widget>[
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(_profileData[a]['Name'],
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xff371D32),
                                  ),
                                ),
                                SizedBox(height: 5.0),
                                Text(_profileData[a]['Type'] + ' • ' + _profileData[a]['Time'],
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 12,
                                    color: Color(0xff353B50),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Row(
                            children: [
                              Text(_profileData[a]['Amount'],
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Color(0xff371D32),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    right: 4,left: 2),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15,
                                ),
                              )
                            ],
                          ),

                        ],
                      ),
                    ),
                    Divider(color: Color(0xFFE7EAEB)),
                  ],
              ),
                ),

            ],
          ):Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(child: Text('Sorry! no transaction found.')),
          ),
        ),
      ):Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new CircularProgressIndicator(strokeWidth: 2.5)
          ],
        ),
      )
    );
  }
}
