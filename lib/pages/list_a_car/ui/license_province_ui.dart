import 'dart:async';
import 'dart:convert' show json, base64, ascii;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

import '../../../utils/app_events/app_events_utils.dart';


Future<RestApi.Resp> fetchProvince() async {
  final completer=Completer<RestApi.Resp>();
  RestApi.callAPI(getAllProvinceUrl, json.encode(
    {}
  ),
  ).then((resp){
    completer.complete(resp);
  });
  return completer.future;

}

class LicenseProvinceUi extends StatefulWidget {
  @override
  State createState() => LicenseProvinceUiState();
}

class LicenseProvinceUiState extends State<LicenseProvinceUi> {
  List? _licenseProvinceData;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "License Province"});
    callFetchProvince();
  }

  callFetchProvince() async {
    var res = await fetchProvince();

    setState(() {
     _licenseProvinceData = json.decode(res.body!)['Province'];
    });
  }

  @override
  Widget build (BuildContext context) { 

    final CreateCarResponse createCarResponse = ModalRoute.of(context)!.settings.arguments as CreateCarResponse;
    
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
      body: _licenseProvinceData != null ? new ListView.separated
        (
          separatorBuilder: (context, index) => Divider(
            color: Color(0xff371D32),
            thickness: 0.1,
          ),
          itemCount: _licenseProvinceData!.length,
          itemBuilder: (BuildContext ctxt, int index) {
            return InkWell(
              onTap: () {
                createCarResponse.car!.imagesAndDocuments!.license!.province = _licenseProvinceData![index]['Name'];

                Navigator.pop(
                  context,
                  createCarResponse
                );
              },
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
                            SizedBox(width: 10),
                            Text(_licenseProvinceData![index]['Name'],
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
    );
  }
}