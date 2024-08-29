import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';

import '../utils/app_events/app_events_utils.dart';

Future<http.Response> fetchReviewersProfiles(param, jwt) async {
  final response = await http.post(
    Uri.parse(getProfilesByUserIDsUrl),
    // getProfilesByUserIDsUrl as Uri,
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({"UserIDs": param}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}



class CarReviews extends StatefulWidget {
  @override
  State createState() => CarReviewsState();
}

class CarReviewsState extends State<CarReviews> {
  List _reviews = [];
  List _reviewerUserIDs = [];
  List _reviewerProfiles = [];

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Car Reviews"});
      List _receivedData = ModalRoute.of(context)!.settings.arguments as List;

      for (int i = 0; i < _receivedData.length; i++) {
        _reviewerUserIDs.add(_receivedData[i]['ReviewerUserID']);
      }

      if (_reviewerUserIDs.length > 0) {
        String? jwt = await storage.read(key: 'jwt');

        var res = await fetchReviewersProfiles(_reviewerUserIDs, jwt);

        for (int j = 0; j < _reviewerUserIDs.length; j++) {
          for (int k = 0; k < json.decode(res.body!)['Profiles'].length; k++) {
            if (_reviewerUserIDs[j] ==
                json.decode(res.body!)['Profiles'][k]['UserID']) {
              var _tempProfile = {
                "ImageID": json.decode(res.body!)['Profiles'][k]['ImageID'],
                "FirstName": json.decode(res.body!)['Profiles'][k]['FirstName'],
                "LastName": json.decode(res.body!)['Profiles'][k]['LastName']
              };

              _reviewerProfiles.add(_tempProfile);
            }
          }
        }

        setState(() {
          _reviewerProfiles = _reviewerProfiles;
        });
      }

      setState(() {
        _reviews = _receivedData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Reviews',
          style: TextStyle(
              color: Color(0xff371D32),
              fontSize: 16,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
      ),
      body: _reviews != null
          ? Column(
              children: <Widget>[
                 _reviews.length != 0
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: _reviews.length,
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  margin: EdgeInsets.only(
                                      top: 16.0,
                                      right: 16.0,
                                      left: 16.0,
                                      bottom: 0),
                                  decoration: BoxDecoration(
                                      color: Color(0xffF2F2F2),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          // Date
                                          Row(
                                            children: [
                                              Row(
                                                children: [
                                                  Column(
                                                    children: <Widget>[
                                                      Center(
                                                        child: (_reviewerProfiles[
                                                                            index]
                                                                        [
                                                                        'ImageID'] !=
                                                                    null &&
                                                                _reviewerProfiles[
                                                                            index]
                                                                        [
                                                                        'ImageID'] !=
                                                                    '')
                                                            ? CircleAvatar(
                                                                backgroundImage:
                                                                    NetworkImage(
                                                                        '$storageServerUrl/${_reviewerProfiles[index]['ImageID']}'),
                                                                radius: 17.5,
                                                              )
                                                            : CircleAvatar(
                                                                backgroundImage:
                                                                    AssetImage(
                                                                        'images/user.png'),
                                                                radius: 17.5,
                                                                backgroundColor:
                                                                    Color(
                                                                        0xFFF2F2F2),
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
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        _reviewerProfiles[index]
                                                                ['FirstName'] +
                                                            ' ' +
                                                            '${_reviewerProfiles[index]['LastName'][0]}' +
                                                            '.',
                                                        style: TextStyle(
                                                            color: Color(
                                                                0xff371D32),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14,
                                                            fontFamily:
                                                                'Urbanist'),
                                                      ),
                                                      Text(
                                                        DateFormat("d MMM yyyy")
                                                            .format(DateTime
                                                                .parse(_reviews[
                                                                        index][
                                                                    'DateTime'])),
                                                        style: TextStyle(
                                                          color:
                                                              Color(0xff353B50),
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          fontFamily:
                                                              'Urbanist',
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
                                                children: List.generate(
                                                    _reviews[index]['Rating'],
                                                    (index) {
                                                  return Icon(
                                                    Icons.star,
                                                    size: 20,
                                                    color: Color(0xff5BC0EB),
                                                  );
                                                }),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: List.generate(
                                                  (5 - _reviews[index]['Rating']).toInt(),  // Explicitly cast to int
                                                      (index) {
                                                    return Icon(
                                                      Icons.star,
                                                      size: 20,
                                                      color: Color(0xffABABAB),
                                                    );
                                                  },
                                                ),
                                              )

                                              // Row(
                                              //   mainAxisSize: MainAxisSize.min,
                                              //   children: List.generate(
                                              //       5 -
                                              //           _reviews[index]
                                              //               ['Rating'],
                                              //       (index) {
                                              //     return Icon(
                                              //       Icons.star,
                                              //       size: 20,
                                              //       color: Color(0xffABABAB),
                                              //     );
                                              //   }),
                                              // ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        _reviews[index]['Review'],
                                        style: TextStyle(
                                            letterSpacing: -0.4,
                                            color: Color(0xff371D32),
                                            fontWeight: FontWeight.normal,
                                            fontSize: 16,
                                            fontFamily: 'Urbanist'),
                                      ),
                                    ],
                                  ),
                                ));
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Center(
                          child: Text(
                            'There are no reviews.',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ),
                      ),
              ],
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new CircularProgressIndicator(strokeWidth: 2.5),

                ],
              ),
            ),
    );
  }
}
