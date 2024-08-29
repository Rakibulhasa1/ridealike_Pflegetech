import 'dart:async';
import 'dart:convert' show json, base64, ascii;

import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/widgets/sized_text.dart';

import '../../../utils/app_events/app_events_utils.dart';

Future<Resp> fetchCarMake() async {
  final completer=Completer<Resp>();
  callAPI(getAllCarStyleUrl, json.encode(
      {}
  ),).then((resp) {
    completer.complete(resp);
  });
  return completer.future;

}
Future<Resp> fetchCarMakeForListCar(String bodyTrimID) async {
  final completer=Completer<Resp>();
  callAPI(getAllStyleForListACarUrl, json.encode(
      {
        "BodyTrimID": bodyTrimID
      }
  ),).then((resp) {
    completer.complete(resp);
  });
  return completer.future;

}

class CarStyleUi extends StatefulWidget {
  @override
  State createState() => CarStyleUiState();
}

class CarStyleUiState extends State<CarStyleUi> {
  List? _carStylesData;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Car Style"});
    Future.delayed(Duration.zero,() async {
      final Map _data = ModalRoute.of(context)!.settings.arguments as Map;
      
//      var res = await fetchCarMake();
      var res = await fetchCarMakeForListCar(_data['_bodyTrimID']);

      setState(() {
        _carStylesData = json.decode(res.body!)['CarStyles'].toList();
        if (_carStylesData == null || _carStylesData!.length ==0){
          _carStylesData!.add({
            "Name":'N/A'
          });
        }
        _carStylesData!.sort((a, b) => a['Name'].toString().toLowerCase().compareTo(b['Name'].toString().toLowerCase()));
      });
    });
  }

  @override
  Widget build (BuildContext context) { 

    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    double deviceWidth = MediaQuery.of(context).size.width;
    
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
              Navigator.pop(context, {'DATA':null, 'BUTTON': 'CANCEL'});

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
                            SizedText(
                              deviceWidth: deviceWidth,
                              textWidthPercentage: 0.95,
                              text: (receivedData['_carData'] as CreateCarResponse).car!.about!.make! + ' / ' +(receivedData['_carData'] as CreateCarResponse).car!.about!.model! + ' / ' + (receivedData['_carData'] as CreateCarResponse).car!.about!.carBodyTrim!,
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                textColor: Color(0xFF371D32).withOpacity(0.5)

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
                return InkWell(
                  onTap: () {
                    (receivedData['_carData'] as CreateCarResponse ).car!.about!.style = _carStylesData![index]['Name'];

                    Navigator.pop(
                      context,
                       {'DATA':receivedData['_carData'], 'BUTTON': null},
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