import 'dart:convert' show json, base64, ascii;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';

import '../../../utils/app_events/app_events_utils.dart';

Future<http.Response> fetchCarMake() async {
  final response = await http.post(
    Uri.parse(getAllCarStyleUrl),
    // getAllCarStyleUrl as Uri,
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


class EditDashboardCarStyle extends StatefulWidget {
  @override
  State createState() => EditDashboardCarStyleState();
}

class EditDashboardCarStyleState extends State<EditDashboardCarStyle> {
  List? _carStylesData;

  @override
  void initState() {
    super.initState();
    
    Future.delayed(Duration.zero,() async {
      AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Edit Dashboard Car Style"});
       final Map _data = ModalRoute.of(context)!.settings.arguments as Map;
      // final Map<dynamic, dynamic>? _data =
      // ModalRoute.of(context)?.settings.arguments as Map<dynamic, dynamic>?;

      var res = await fetchCarMake();

      setState(() {
        _carStylesData = json.decode(res.body!)['CarStyles'].where((i) => i['BodyTrimID'] == _data['_bodyTrimID']).toList();
      });
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
                child: Text('Cancel',
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
                        child: Text('Style',
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
          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
                        child: Row(
                          children: <Widget>[
                            Text(receivedData['_carData']['About']['Make'],
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFF371D32).withOpacity(0.5)
                              ),
                            ),
                            Text(' / ' + receivedData['_carData']['About']['Model'],
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFF371D32).withOpacity(0.5)
                              ),
                            ),
                            Text(' / ' + receivedData['_carData']['About']['CarBodyTrim'],
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                color: Color(0xFF371D32).withOpacity(0.5)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(
            color: Color(0xff371D32),
            thickness: 0.1,
          ),
          Expanded(
            child: _carStylesData != null ? new ListView.separated (
              separatorBuilder: (context, index) => Divider(
                color: Color(0xff371D32),
                thickness: 0.1,
              ),
              itemCount: _carStylesData!.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return GestureDetector(
                  onTap: () {
                    receivedData['_carData']['About']['Style'] = _carStylesData![index]['Name'];

                    Navigator.pushNamed(
                      context,
                      '/edit_dashboard_about_your_vehicle',
                      arguments: receivedData['_carData'],
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
                                Text(_carStylesData![index]['Name'],
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