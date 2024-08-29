import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';

import '../../../utils/app_events/app_events_utils.dart';

Future<http.Response> fetchCarMake() async {
  final response = await http.post( Uri.parse(getAllCarMakeUrl),
    body: json.encode(
      {}
    ),
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return response;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data');
  }
}



class EditDashboardCarMake extends StatefulWidget {
  @override
  State createState() => EditDashboardCarMakeState();
}

class EditDashboardCarMakeState extends State<EditDashboardCarMake> {
  List? _carMakeData;

  var arguments = {
    '_makeID': '',
    '_carData' : {}
  };

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Edit Dashboard Car Make"});
    callFetchCarMake();
  }

  callFetchCarMake() async {
    var res = await fetchCarMake();

    setState(() {
     _carMakeData = json.decode(res.body!)['CarMakes'];
    });
  }
  
  @override
  Widget build (BuildContext context) {
    
     final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    // final Map<dynamic, dynamic>? receivedData =
    // ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {

            },
            child: Center(
              child: Container(
                margin: EdgeInsets.only(right: 16),
                child: Text('Deselect all',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xffFF8F68),
                  ),
                ),
              ),
            ),
          ),
        ],
        elevation: 0.0,
      ),

      //Content of tabs
      body: Column(
        children: <Widget>[
          // Header 
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          child: Text('Make',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 36,
                              color: Color(0xFF371D32),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(
              child: _carMakeData != null ? new ListView.separated (
              separatorBuilder: (context, index) => Divider(
                color: Color(0xff371D32),
                thickness: 0.1,
              ),
              itemCount: _carMakeData!.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return GestureDetector(
                  onTap: () {
                    receivedData['About']['Make'] = _carMakeData![index]['Name'];

                    arguments['_makeID'] = _carMakeData![index]['MakeID'];
                    arguments['_carData'] = receivedData;

                    Navigator.pushNamed(
                      context,
                      '/edit_dashboard_car_model',
                      arguments: arguments,
                    );
                  },
                  child: SizedBox(
                    width: double.maxFinite,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8.0, left: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_carMakeData![index]['Name'],
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
                            width: 16,
                            child: Icon(
                              Icons.keyboard_arrow_right, 
                              color: Color(0xFF353B50),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            ) : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(strokeWidth: 2.5)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}