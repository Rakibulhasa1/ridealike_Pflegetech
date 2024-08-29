import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/search_a_car/response_model/make_response_model.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';

import '../../utils/app_events/app_events_utils.dart';
//Future<http.Response> fetchCarMake() async {
//  final response = await http.post('https://api.car!.ridealike.anexa.dev/v1/car.CarService/GetAllCarMake',
//    body: json.encode(
//      {}
//    ),
//  );
//
//  if (response.statusCode == 200) {
//    return response;
//  } else {
//    throw Exception('Failed to load data');
//  }
//}
Future<http.Response> fetchCarMake(var carTypes) async {
  final response = await http.post(
    Uri.parse(getAllEnlistedCarMakesUrl),
    // getAllEnlistedCarMakesUrl as Uri,
    body: json.encode(
        {
          "CarTypes": carTypes
        }
    ),
  );
print('makeresponse${response.body}');
  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

class SearchCarMake extends StatefulWidget {
  @override
  _SearchCarMakeState createState() => _SearchCarMakeState();
}

class _SearchCarMakeState extends State<SearchCarMake> {
//  List _carMakeData;

  SearchCarMakeResponse? _carMakeResponse;
  bool dataFetched = false;
  List<CarMakes> _selectedCarMakes = [];

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Search Car Make"});
  }

  Future callFetchCarMake(SearchData receivedData) async {
    var res = await fetchCarMake(receivedData.carType);


    setState(() {
      _carMakeResponse = SearchCarMakeResponse.fromJson(json.decode(res.body!));
//      _carMakeData = json.decode(res.body!)['CarMakes'];
      _carMakeResponse!.carMakes!.sort((a, b) => a.name.toString().toLowerCase().compareTo(b.name.toString().toLowerCase()));
    });
  }

  @override
  Widget build(BuildContext context) {
    final SearchData? receivedData = ModalRoute.of(context)?.settings.arguments as SearchData?;
    if ( _carMakeResponse == null){

      callFetchCarMake(receivedData!).then((value) {

        if (receivedData != null && dataFetched == false) {

          setState(() {
            dataFetched = true;
          });

          if(receivedData.carMake!= null) {
            Set _seletedMakes =Set();
            for(var i in receivedData.carMake!){
              _seletedMakes.add(i.makeID);
              _selectedCarMakes.add(i);
            }

            for(var element in _carMakeResponse!.carMakes!){//todo

              if(_seletedMakes.contains(element.makeID)){
                element.selected = true;
              }
            }
            setState(() {
              _carMakeResponse!.carMakes = _carMakeResponse!.carMakes;
            });
          }
        }

      });
    }


    return Scaffold(
      backgroundColor: Colors.white,

      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
//
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
                  //select all//
                    if(  _selectedCarMakes==null ||_selectedCarMakes.length==0){
                      for(var i in _carMakeResponse!.carMakes!){
                        setState(() {
                          _selectedCarMakes.add(i);
                          i.selected = true;
                        });
                      }
                    }else{
                      _selectedCarMakes.clear();
                      for(var i in _carMakeResponse!.carMakes!){
                        setState(() {
                          i.selected= false;
                        });
                      }
                    }


                  });
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text(_selectedCarMakes==null ||_selectedCarMakes.length==0?'Select all':
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
                        child: Text('Vehicle make',
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
            child: _carMakeResponse != null && _carMakeResponse!.carMakes!= null ? new ListView.builder (
              itemCount: _carMakeResponse!.carMakes!.length,
              itemBuilder: (BuildContext ctxt, int index) {
                return Container(
                  child: Column(
                    children: [
                      InkWell(
                        onTap: (){
                          setState(() {
                            _carMakeResponse!.carMakes![index].selected = !_carMakeResponse!.carMakes![index].selected;
//                            if (_selectedCarMakes.contains(_carMakeResponse!.carMakes[index])  0) {
//                              _selectedCarMakes.remove(_carMakeData[index]['Name']);
//                              _selectedCarMakesID.remove(_carMakeData[index]['MakeID']);
//                            } else {
//                              _selectedCarMakes.add(_carMakeData[index]['Name']);
//                              _selectedCarMakesID.add(_carMakeData[index]['MakeID']);
//                              makeNameToIdMap[_carMakeData[index]['MakeID']] = _carMakeData[index]['Name'];
//                            }
                          });
                        },
                        child: Container(
                          width: double.maxFinite, 
                          padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 8.0),
                          // height: 50,
                          child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(_carMakeResponse!.carMakes![index].name!,
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 16,
                                    color: Color(0xFF371D32),
                                  ),
                                ),
                              Icon(
                                Icons.check, 
                                color: _carMakeResponse!.carMakes![index].selected ? Color(0xffFF8F62) : Colors.transparent,
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
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(right: 16.0, bottom: 16.0, left: 16.0),
                      child: SizedBox(
                      width: double.maxFinite,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xffFF8F68),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                        ),
                        onPressed: () {
                          List<CarMakes> _newSelectedCarMakes =[];
                          for(var element in _carMakeResponse!.carMakes!){
                            if(element.selected ){
                              _newSelectedCarMakes.add(element);
                            }
                          }
                          receivedData!.carMake = _newSelectedCarMakes;
                          if(receivedData.carModel != null){
                            (receivedData.carModel)!.clear();
                          }

                          Navigator.pop(
                            context, receivedData,
                          );
                        },
                        child: Text('Save',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            color: Colors.white
                          ),
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
