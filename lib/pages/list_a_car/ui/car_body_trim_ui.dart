import 'dart:convert' show json, base64, ascii;

import 'package:flutter/material.dart';
import 'package:ridealike/pages/list_a_car/request_service/car_body_trim_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

import '../../../utils/app_events/app_events_utils.dart';


class CarBodyTrimUi extends StatefulWidget {
  @override
  State createState() => CarBodyTrimUiState();
}

class CarBodyTrimUiState extends State<CarBodyTrimUi> {
  List? _carBodyTrimData;

  var arguments = {
    '_bodyTrimID': '',
    '_carData' : {}
  };

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Car Body Trip"});
    Future.delayed(Duration.zero,() async {
      final Map _data = ModalRoute.of(context)!.settings.arguments as Map;
      
//      var res = await fetchCarMake();
//      var res = await fetchCarBodyTrim();
      var res = await fetchCarBodyTrimForListCar(_data['_modelID'] );

      setState(() {

        _carBodyTrimData = json.decode(res.body!)['CarBodyTrims'].toList();
        if (_carBodyTrimData == null || _carBodyTrimData!.length ==0){
          _carBodyTrimData!.add({
            "Name":'N/A',
            "BodyTrimID":'N/A'
          });
        }
        _carBodyTrimData!.sort((a, b) => a['Name'].toString().toLowerCase().compareTo(b['Name'].toString().toLowerCase()));
      });
    });
  }

  @override
  Widget build (BuildContext context) { 

    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    
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
                          child: Text('Body trim',
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
                              Text((receivedData['_carData'] as CreateCarResponse).car!.about!.make!,
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 12,
                                  color: Color(0xFF371D32).withOpacity(0.5)
                                ),
                              ),
                              Text(' / ' + (receivedData['_carData'] as CreateCarResponse).car!.about!.model!,
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
              child: _carBodyTrimData != null ? new ListView.separated (
              separatorBuilder: (context, index) => Divider(
                color: Color(0xff371D32),
                thickness: 0.1,
              ),
              itemCount: _carBodyTrimData!.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return InkWell(
                  onTap: () {
                    (receivedData['_carData'] as CreateCarResponse ).car!.about!.carBodyTrim = _carBodyTrimData![index]['Name'];
                    (receivedData['_carData'] as CreateCarResponse ).car!.about!.style = '';

                    arguments['_bodyTrimID'] = _carBodyTrimData![index]['BodyTrimID'];
                    arguments['_carData'] = receivedData['_carData'];

                    Navigator.pushNamed(
                      context,
                      '/car_style_ui',
                      arguments: arguments,
                    ).then((value) {
                      if(value!=null){
                        Navigator.pop(context,value);
                      }
                    });
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
                                  Text(_carBodyTrimData![index]['Name'],
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