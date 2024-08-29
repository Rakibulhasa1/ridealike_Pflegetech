import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';

import '../../utils/app_events/app_events_utils.dart';

//Future<http.Response> fetchCarType() async {
//  final response = await http.post(getAllCarTypeUrl,
//    body: json.encode(
//      {}
//    ),
//  );
//
//  if (response.statusCode == 200) {
//    // If the server did return a 200 OK response,
//    // then parse the JSON.
//    return response;
//  } else {
//    // If the server did not return a 200 OK response,
//    // then throw an exception.
//    throw Exception('Failed to load data');
//  }
//}
Future<http.Response> fetchCarType() async {
  final response = await http.post(
    Uri.parse(getAllEnlistedCarTypesUrl),
    // getAllEnlistedCarTypesUrl as Uri,
    body: json.encode(
        {}
    ),

  );
  print('url: ${response.body}');

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

class SearchCarType extends StatefulWidget {
  @override
  State createState() => SearchCarTypeState();
}

class SearchCarTypeState extends State<SearchCarType> {
  List? _carTypeData;
  List<String> _selectedCarTypes = [];
  bool dataFetched = false;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Search Car Type"});
    callFetchCarType();
  }

  callFetchCarType() async {
    var res = await fetchCarType();

    setState(() {
      _carTypeData = json.decode(res.body!)['CarTypes'];
//     _carTypeData!.sort((a, b) => a['Name'].toString().toLowerCase().compareTo(b['Name'].toString().toLowerCase()));
      _carTypeData!.sort((a, b) => a.toString().toLowerCase().compareTo(b.toString().toLowerCase()));

    });
  }

  @override
  Widget build (BuildContext context) {
    final SearchData receivedData = ModalRoute.of(context)!.settings.arguments as SearchData;

    if (receivedData != null && dataFetched== false) {
      dataFetched=true;
      List temp  = receivedData.carType!;
      if(temp!= null) {
        for (var i in temp) {

          _selectedCarTypes.add(i);
        }
      }

    }

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
            onPressed: () {

              Navigator.of(context).pop();
            }
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              setState(() {
                if(_selectedCarTypes==null || _selectedCarTypes.length==0){
                  for(var i in _carTypeData!){
                    _selectedCarTypes.add(i);
                  }
                }else{
                  _selectedCarTypes.clear();

                }

              });
            },
            child: Center(
              child: Container(
                margin: EdgeInsets.only(right: 16),
                child: Text(_selectedCarTypes==null || _selectedCarTypes.length==0?'Select all':'Deselect all',
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
                        child: Text('Vehicle type',
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
          SizedBox(height: 15.0),
          Expanded(
            child: _carTypeData != null ? new ListView.builder (
                itemCount: _carTypeData!.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Container(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: (){
                            setState(() {
                              if (_selectedCarTypes.indexOf(_carTypeData![index]) >= 0) {
                                _selectedCarTypes.remove(_carTypeData![index]);
                              } else {
                                _selectedCarTypes.add(_carTypeData![index]);
                              }
                            });
                          },
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 8.0),
                            // height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(_carTypeData![index],
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xFF371D32),
                                  ),
                                ),
                                Icon(
                                  Icons.check,
                                  color: _selectedCarTypes.indexOf(_carTypeData![index]) >= 0 ? Color(0xffFF8F62) : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(),
                      ],
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
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xffFF8F68),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                          ),
                          onPressed: () {
                            receivedData.carType = _selectedCarTypes;
                            if(receivedData.carMake!=null  && receivedData.carModel!=null){
                              receivedData.carMake=[];
                              receivedData.carModel=[];
                            }

/*
                            if (_selectedCarTypes.length == 0) {
                              receivedData['_carTypeLength'] = 'Select type';
                            } else if (_selectedCarTypes.length == 1) {
                              receivedData['_carTypeLength'] = _selectedCarTypes[0];
                            } else {
                              receivedData['_carTypeLength'] = 'Multiple';
                            }*/

                            Navigator.pop(
                                context, receivedData
                            );
                          },
                          child: Text('Save',
                            style: TextStyle(
                                fontFamily: 'SFProDisplaySemibold',
                                fontSize: 16,
                                color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}