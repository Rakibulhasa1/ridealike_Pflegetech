import 'dart:collection';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/search_a_car/response_model/model_response.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';

import '../../utils/app_events/app_events_utils.dart';

//Future<http.Response> fetchCarModel() async {
//  final response = await http.post(
//    'https://api.car!.ridealike.anexa.dev/v1/car.CarService/GetAllCarModel',
//    body: json.encode({}),
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
Future<http.Response> fetchCarModel(carTypes,carMakes) async {
  final response = await http.post(
    Uri.parse(getAllEnlistedCarModelsUrl),
    // getAllEnlistedCarModelsUrl as Uri,
    body: json.encode({
      "CarTypes": carTypes,
      "CarMakes": carMakes
    }
    ),
  );

  print('Resp : ${response.body}');
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

class SearchCarModel extends StatefulWidget {
  @override
  _SearchCarModelState createState() => _SearchCarModelState();
}

class _SearchCarModelState extends State<SearchCarModel> {
  SearchCarModelResponse? _carModelData;
  bool dataFetched = false;
  Map <String, CarModels> _selectedCarModels = {};

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Search Car Model"});
  }

  Future  callFetchCarModel(SearchData receivedData) async {

    List<String> carMakeNameList = [];
    if(receivedData.carMake != null ){
      for ( var i in receivedData.carMake!){
        carMakeNameList.add(i.name!);
      }
    }

    var res = await fetchCarModel(receivedData.carType,carMakeNameList);
    _carModelData = SearchCarModelResponse.fromJson(json.decode(res.body!));
    // print('carModelResponse: ${_carModelData!.carModels.to}');
    _carModelData!.carModels!.sort((a, b) => a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase()));
    List<CarModels> carModelsNew = [];
    List carModelName = [];
    for (var i in _carModelData!.carModels!){
      if(carModelName.contains(i.name)){
      } else{
        carModelName.add(i.name);
        carModelsNew.add(i);
      }

    }
    setState(() {
      _carModelData!.carModels = carModelsNew;
    });
  }

  @override
  Widget build(BuildContext context) {
    final SearchData receivedData = ModalRoute.of(context)!.settings.arguments as SearchData;
    HashSet<String> uniqueDates = HashSet<String>();
    if(_carModelData==null){
      callFetchCarModel(receivedData).then((value) {
        if (receivedData != null && dataFetched ==false) {
          setState(() {
            dataFetched = true;
          });
          if (receivedData.carModel != null) {
            for (var i in receivedData.carModel!) {
              _selectedCarModels[i.name!] = i;
            }
          }
          for ( var i in _carModelData!.carModels!){
            if(_selectedCarModels[i.name] != null){
              i.selected= true;

            }
          }
          setState(() {
            _carModelData= _carModelData;
          });
        }
      });
    }


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
            onPressed: () {
              Navigator.of(context).pop();
            }
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    if(_selectedCarModels==null ||_selectedCarModels.length==0){
                      for(var i in  _carModelData!.carModels!){
                        i.selected = true;
                        _selectedCarModels[i.name!]= i;
                      }
                    }else{
                      _selectedCarModels.clear();
                      for(var i in  _carModelData!.carModels!){
                        i.selected = false;
                      }

                    }

                    // for(var i in  _carModelData){
                    //   _selectedCarModels.add(i['Name']);
                    // }
                  });
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text(_selectedCarModels==null ||_selectedCarModels.length==0?'Select all':
                    'Deselect all',
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
                        child: Text(
                          'Vehicle model',
                          style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 36,
                              color: Color(0xFF371D32),
                              fontWeight: FontWeight.bold),
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
            child: _carModelData != null
                ? new ListView.builder(
                itemCount: _carModelData!.carModels!.length,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Container(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (_carModelData!.carModels![index].selected) {
                                _carModelData!.carModels![index].selected = false;
                                _selectedCarModels.remove(_carModelData!.carModels![index].name);
                              } else {
                                _carModelData!.carModels![index].selected = true;
                                _selectedCarModels[_carModelData!.carModels![index].name!]= _carModelData!.carModels![index];
                              }
                            });
                          },
                          child: Container(
                            width: double.maxFinite,
                            padding: EdgeInsets.only(
                                right: 16.0,
                                bottom: 8.0,
                                left: 16.0,
                                top: 8.0),
                            // height: 50,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  _carModelData!.carModels![index].name!,
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: 16,
                                    color: Color(0xFF371D32),
                                  ),
                                ),
                                Icon(
                                  Icons.check,
                                  color: _carModelData!.carModels![index].selected
                                      ? Color(0xffFF8F62)
                                      : Colors.transparent,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Divider(),
                      ],
                    ),
                  );
                })
                : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(strokeWidth: 2.5)
                ],
              ),
            ),
          ),
          SizedBox(height: 10.0),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          right: 16.0, bottom: 16.0, left: 16.0),
                      child: SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xffFF8F68),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),

                          ),
                          onPressed: () {
                            receivedData.carModel = [];
                            _selectedCarModels.forEach((key, value) {
                              receivedData.carModel!.add(value);
                            });

                            /*if (_selectedCarModels.length == 0) {
                              receivedData['_carModelLength'] = 'Select model';
                            } else if (_selectedCarModels.length == 1) {
                              receivedData['_carModelLength'] =
                                  _selectedCarModels[0];
                            } else {
                              receivedData['_carModelLength'] = 'Multiple';
                            }*/

                            Navigator.pop(
                              context,receivedData,
                            );
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(
                                fontFamily: 'SFProDisplaySemibold',
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}