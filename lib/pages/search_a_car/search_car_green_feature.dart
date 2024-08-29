import 'package:flutter/material.dart';
import 'package:ridealike/pages/search_a_car/response_model/search_data.dart';

import '../../utils/app_events/app_events_utils.dart';

class SearchCarGreenFeature extends StatefulWidget {
  @override
  State createState() => SearchCarGreenFeatureState();
}

class SearchCarGreenFeatureState extends State<SearchCarGreenFeature> {
  List<String> greenFeature = [];

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Search Car Green Feature"});
  }

  @override
  Widget build(BuildContext context) {
    final SearchData? receivedData = ModalRoute.of(context)?.settings.arguments as SearchData?;
    greenFeature= receivedData!.greenFeature!;
    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
            icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  setState(() {
                    greenFeature.length!=0?greenFeature.clear():greenFeature.addAll(['All',"electric","hybrid"]);
                  });
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text(
                      greenFeature.length==0?'Select all':
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
                        child: Text(
                          'Green Feature',
                          style: TextStyle(
                              fontFamily: 'Urbanist',
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        greenFeature.contains('electric')
                            ? greenFeature.remove('electric')
                            : greenFeature.add('electric');
                      });
                    },
                    child: Row(
                      children: [
                        Text('Electric',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Color(0xFF371D32),
                            )),
                        Spacer(),
                        Icon(
                          Icons.check,
                          color: greenFeature.contains("electric")
                              ? Color(0xffFF8F68)
                              : Colors.transparent,
                        )
                      ],
                    ),
                  ),
                  Divider(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        greenFeature.contains('hybrid')
                            ? greenFeature.remove('hybrid')
                            : greenFeature.add('hybrid');
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Hybrid',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 16,
                              color: Color(0xFF371D32),
                            )),
                        Spacer(),
                        Icon(
                          Icons.check,
                          color: greenFeature.contains('hybrid')
                              ? Color(0xffFF8F68)
                              : Colors.transparent,
                        )
                      ],
                    ),
                  ),
                ]),
              ),),

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
                        child: ElevatedButton(style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xffFF8F68),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),),
                          onPressed: () {
                            receivedData!.greenFeature = greenFeature;
                            Navigator.pop(context, receivedData);
                          },
                          child: Text(
                            'Save',
                            style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Colors.white),
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
