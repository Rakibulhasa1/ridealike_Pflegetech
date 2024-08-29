import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;

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

class LicenseProvicne extends StatefulWidget {
  @override
  State createState() => LicenseProvicneState();
}

class LicenseProvicneState extends State<LicenseProvicne> {
  List? _licenseProvinceData;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

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
            return GestureDetector(
              onTap: () {
                receivedData['_licenseProvince'] = _licenseProvinceData![index]['Name'];

                Navigator.pushNamed(
                  context,
                  '/add_photos_to_your_listing',
                  arguments: receivedData
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