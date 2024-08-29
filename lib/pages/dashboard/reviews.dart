import 'dart:convert' show json;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
Future<http.Response> fetchReviewersProfiles(param) async {
  print('User ids : $param');
  final response = await http.post(
    Uri.parse(getProfilesByUserIDsUrl),
    // getProfilesByUserIDsUrl as Uri,
    body: json.encode(
      {
        "UserIDs": param
      }
    ),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

class Reviews extends StatefulWidget {
  @override
  State createState() => ReviewsState();
}

class ReviewsState extends State<Reviews> {
  List _reviews = [];
  List _reviewerUserIDs = [];
//  List _reviewerProfiles = [];
  Map _reviewerProfilesMap = {};

  @override
  void initState() {
    super.initState();
    
    Future.delayed(Duration.zero,() async {
      List _receivedData = ModalRoute.of(context)!.settings.arguments as List;

      for (int i = 0; i < _receivedData.length; i++) {
        _reviewerUserIDs.add(_receivedData[i]['ReviewerUserID']);
      }

      if (_reviewerUserIDs.length > 0) {
        var res = await fetchReviewersProfiles(_reviewerUserIDs);

        List _reviewerProfiles = json.decode(res.body!)['Profiles'];

        setState(() {
          for (var i in _reviewerProfiles){
            _reviewerProfilesMap[i['UserID']]= i;
          }
        });

        print(_reviewerProfiles);
      }

      setState(() {
        _reviews = _receivedData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final List _reviews = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      
      appBar: AppBar(
        centerTitle: true,
        title: Text('Reviews',
          style: TextStyle(
            color: Color(0xff371D32),
            fontSize: 16,
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w500
          ),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
      ),

      body: _reviews != null ? Column(
        children: <Widget>[
          _reviews.length!=0?  Expanded(
            child: ListView.builder(
              itemCount: _reviews.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return SizedBox(
                  width: double.maxFinite,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    margin: EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0, bottom: 0),
                    decoration: BoxDecoration(
                      color: Color(0xffF2F2F2),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Date
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      children: <Widget>[
                                        Center(
                                          child: (_reviewerProfilesMap[_reviewerUserIDs[index]]['ImageID'] != null && _reviewerProfilesMap[_reviewerUserIDs[index]]['ImageID'] != '') ? CircleAvatar(
                                            backgroundImage: NetworkImage('$storageServerUrl/${_reviewerProfilesMap[_reviewerUserIDs[index]]['ImageID']}'),
                                            radius: 17.5,
                                          )
                                          : CircleAvatar(
                                            backgroundImage: AssetImage('images/user.png'),
                                            radius: 17.5,
                                            backgroundColor: Color(0xFFF2F2F2),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(width: 10.0),
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          child: AutoSizeText(_reviewerProfilesMap[_reviewerUserIDs[index]]['FirstName'] + ' ' + '${_reviewerProfilesMap[_reviewerUserIDs[index]]['LastName']}' + '.',
                                            style: TextStyle(
                                              color: Color(0xff371D32),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              fontFamily: 'Urbanist'
                                            ),maxLines: 3,

                                          ),
                                          width: MediaQuery.of(context).size.width*0.25,

                                        ),
                                        Text(DateFormat("d MMM yyyy").format(DateTime.parse(_reviews[index]['DateTime'])),
                                          style: TextStyle(
                                            color: Color(0xff353B50),
                                            fontWeight: FontWeight.normal,
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Rating
                            Row(
                              children: <Widget>[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(_reviews[index]['Rating'], (index) {
                                    return Icon(
                                      Icons.star,
                                      size: 20,
                                      color: Color(0xffFF8F68),
                                    );
                                  }),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate((5 - _reviews[index]['Rating']).toInt(), (index) {
                                    return Icon(
                                      Icons.star,
                                      size: 20,
                                      color: Color(0xffABABAB),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        Text(_reviews[index]['Review'],
                          style: TextStyle(
                            color: Color(0xff371D32),
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            fontFamily: 'Urbanist'
                          ),
                        ),
                      ],
                    ),
                  )
                );
              },
            ),
          ):Center(child: Text('There are no reviews.')),
        ],
      )
      : Center(
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
