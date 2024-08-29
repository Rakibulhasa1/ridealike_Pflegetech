import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

import '../../../utils/app_events/app_events_utils.dart';

Future<http.Response> fetchCarType() async {
  final response = await http.post(
    Uri.parse(getAllCarTypeUrl),
    // getAllCarTypeUrl as Uri,
    body: json.encode(
      {}
    ),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

class CarTypeUi extends StatefulWidget {
  @override
  State createState() => CarTypeUiState();
}

class CarTypeUiState extends State<CarTypeUi> {
  List _carTypeData = [];

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Car Type"});
    callFetchCarType();
  }

  callFetchCarType() async {
    var res = await fetchCarType();

    setState(() {
     _carTypeData = json.decode(res.body!)['CarTypes'];
     _carTypeData.sort((a, b) => a['Name'].toString().toLowerCase().compareTo(b['Name'].toString().toLowerCase()));
    });
  }
  
  @override
  Widget build (BuildContext context) {
    
    CreateCarResponse receivedData = ModalRoute.of(context)!.settings.arguments as CreateCarResponse;

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
              Navigator.pop(context);
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
      body: _carTypeData.length > 0 ? Column(
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
                          child: Text('Type',
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
              child: new ListView.separated (
              separatorBuilder: (context, index) => Divider(
                color: Color(0xff371D32),
                thickness: 0.1,
              ),
              itemCount: _carTypeData.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return InkWell(
                  onTap: () {
                    receivedData.car!.about!.carType = _carTypeData[index]['Name'];
                    Navigator.pop(
                      context,receivedData,
                    );
                  },
                  child: Container(
                    child: SizedBox(
                      width: double.maxFinite,
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8.0, left: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Row(
                                children: [
                                  Text(_carTypeData[index]['Name'],
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Color(0xFF371D32),
                                    ),
                                  ),
                                ]
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
                  ),
                );
              }
            )
          ),
        ],
      ) : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new CircularProgressIndicator(strokeWidth: 2.5)
          ],
        ),
      ),
    );
  }
}