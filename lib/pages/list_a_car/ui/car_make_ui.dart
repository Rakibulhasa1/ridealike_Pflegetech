import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:ridealike/pages/list_a_car/request_service/car_make_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

import '../../../utils/app_events/app_events_utils.dart';

class CarMakeUi extends StatefulWidget {
  @override
  State createState() => CarMakeUiState();
}

class CarMakeUiState extends State<CarMakeUi> {
  List? _carMakeData;

  var arguments = {
    '_makeID': '',
    '_carData' : {}
  };

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Car Make"});
    callFetchCarMake();
  }

  callFetchCarMake() async {
    var res = await fetchCarMake();

    setState(() {
     _carMakeData = json.decode(res.body!)['CarMakes'];
     _carMakeData!.sort((a, b) => a['Name'].toString().toLowerCase().compareTo(b['Name'].toString().toLowerCase()));
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
      body:
      Column(
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
                  return InkWell(
                    onTap: () {
                      receivedData.car!.about!.make = _carMakeData![index]['Name'];
                      receivedData.car!.about!.model = '';
                      receivedData.car!.about!.carBodyTrim = '';
                      receivedData.car!.about!.style = '';
                      arguments['_makeID'] = _carMakeData![index]['MakeID'];
                      arguments['_carData'] = receivedData;

                      Navigator.pushNamed(
                        context,
                        '/car_model_ui',
                        arguments: arguments,
                      ).then((value){
                        if(value!=null){
                          Navigator.pop(context, value);
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