import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/widgets/shimmer.dart';

import '../utils/app_events/app_events_utils.dart';


Future<http.Response> fetchReviewersProfiles(param, jwt) async {
  final response = await http.post(
    Uri.parse(getProfilesByUserIDsUrl),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $jwt'},
    body: json.encode({"UserIDs": param}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<RestApi.Resp> fetchRatingReviews(userID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getAllReviewByUserIDUrl,
    json.encode({"UserID": userID, "Limit": "0", "Skip": "0"}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}


class UserReviews extends StatefulWidget {
  @override
  State createState() => UserReviewsState();
}

class UserReviewsState extends State<UserReviews>
    with SingleTickerProviderStateMixin {
  List _reviews = [];
  List _fromHostReviews = [];
  List _fromGuestReviews = [];
  List _reviewerUserIDs = [];
  Map _reviewerProfiles = {};
  TabController? _tabController;
  List? ratingReviewList;
  bool? loader;
  double _guestRating = 0, _hostRating = 0;

  List<Tab> tabs = <Tab>[
    Tab(
      text: 'From Guests',
    ),
    Tab(text: 'From Hosts'),
  ];

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "User Reviews"});
    _tabController = TabController(vsync: this, length: tabs.length);

    loader = true;
    Future.delayed(Duration(seconds: 15), () {
      setState(() {
        loader = false;
      });
    });
    Future.delayed(Duration.zero, () async {
      Object? userID = ModalRoute.of(context)?.settings.arguments;
      var res3 = await fetchRatingReviews(userID);
      ratingReviewList = json.decode(res3.body!)['RatingReviews'];

      if (ratingReviewList == null) {
        return;
      }

      for (int i = 0; i < ratingReviewList!.length; i++) {
        _reviewerUserIDs.add(ratingReviewList![i]['ReviewerUserID']);
        if (ratingReviewList![i]['WhoRatedYou'] == 'guest') {
          _fromGuestReviews.add(ratingReviewList![i]);
          _guestRating += double.parse(ratingReviewList![i]['Rating']);
        }
        if (ratingReviewList![i]['WhoRatedYou'] == 'host') {
          _fromHostReviews.add(ratingReviewList![i]);
          _hostRating += double.parse(ratingReviewList![i]['Rating']);
        }
      }

      String guestRatingAvg = _fromGuestReviews.length == 0 ? '0' :  (_guestRating/_fromGuestReviews.length).toString();
      String hostRatingAvg = _fromHostReviews.length == 0 ? '0' :  (_hostRating/_fromHostReviews.length).toString();
      var _ratingReviews;

      tabs = <Tab>[
        Tab(
          text: 'From Guests ('+ guestRatingAvg + ')',
        ),
        Tab(text: 'From Hosts (' + hostRatingAvg + ')',
        )
      ];
      if (_reviewerUserIDs.length > 0) {
        String? jwt = await storage.read(key: 'jwt');

        var res = await fetchReviewersProfiles(_reviewerUserIDs, jwt);

        for (int k = 0; k < json.decode(res.body)['Profiles'].length; k++) {
          var _tempProfile = {
            "ImageID": json.decode(res.body)['Profiles'][k]['ImageID'],
            "FirstName": json.decode(res.body)['Profiles'][k]['FirstName'],
            "LastName": json.decode(res.body)['Profiles'][k]['LastName']
          };

          _reviewerProfiles[json.decode(res.body)['Profiles'][k]['UserID']] =
              _tempProfile;
        }

        setState(() {
          _reviewerProfiles = _reviewerProfiles;
        });
      }

      setState(() {
        _reviews = ratingReviewList!;
        loader = false;
      });
    });
  }

  @override
  void dispose() {
    _tabController!.dispose();
    super.dispose();
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
        bottom: TabBar(
          indicatorColor: Color(0xffFF8F62),
          labelColor: Color(0xffFF8F62),
          unselectedLabelColor: Color(0xff371D32),
          tabs: tabs,
          controller: _tabController,
        ),
        elevation: 0.0,
      ),
      body: !loader!
          ? TabBarView(controller: _tabController, children: [
              _fromGuestReviews != null
                  ? Column(
                      children: <Widget>[
                        _fromGuestReviews.length != 0
                            ? Expanded(
                              child: ListView.builder(
                                  itemCount: _fromGuestReviews.length,
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
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  // Date
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Column(
                                                            children: <Widget>[
                                                              Center(
                                                                child: (_reviewerProfiles[_fromGuestReviews[index]['ReviewerUserID']]
                                                                                [
                                                                                'ImageID'] !=
                                                                            null &&
                                                                        _reviewerProfiles[_fromGuestReviews[index]['ReviewerUserID']]
                                                                                [
                                                                                'ImageID'] !=
                                                                            '')
                                                                    ? CircleAvatar(
                                                                        backgroundImage:
                                                                            NetworkImage(
                                                                                '$storageServerUrl/${_reviewerProfiles[_fromGuestReviews[index]['ReviewerUserID']]['ImageID']}'),
                                                                        radius:
                                                                            17.5,
                                                                      )
                                                                    : CircleAvatar(
                                                                        backgroundImage:
                                                                            AssetImage(
                                                                                'images/user.png'),
                                                                        radius:
                                                                            17.5,
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
                                                                _reviewerProfiles[
                                                                            _fromGuestReviews[index]
                                                                                [
                                                                                'ReviewerUserID']]
                                                                        [
                                                                        'FirstName'] +
                                                                    ' ' +
                                                                    '${_reviewerProfiles[_fromGuestReviews[index]['ReviewerUserID']]['LastName'][0]}' +
                                                                    '.',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xff371D32),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize: 14,
                                                                    fontFamily:
                                                                        'Urbanist'),
                                                              ),
                                                              Text(
                                                                DateFormat(
                                                                        "d MMM yyyy")
                                                                    .format(DateTime.parse(
                                                                        _fromGuestReviews[
                                                                                index]
                                                                            [
                                                                            'DateTime'])),
                                                                style: TextStyle(
                                                                  color: Color(
                                                                      0xff353B50),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
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
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: List.generate(
                                                            int.parse(
                                                                _fromGuestReviews[
                                                                        index]
                                                                    ['Rating']),
                                                            (index) {
                                                          return Icon(
                                                            Icons.star,
                                                            size: 20,
                                                            color:
                                                                Color(0xff5BC0EB),
                                                          );
                                                        }),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: List.generate(
                                                            5 -
                                                                int.parse(
                                                                    _fromGuestReviews[
                                                                            index]
                                                                        [
                                                                        'Rating']),
                                                            (index) {
                                                          return Icon(
                                                            Icons.star,
                                                            size: 20,
                                                            color:
                                                                Color(0xffABABAB),
                                                          );
                                                        }),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                _fromGuestReviews[index]
                                                    ['Review'],
                                                style: TextStyle(
                                                    letterSpacing: -0.4,
                                                    color: Color(0xff371D32),
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        'Urbanist'),
                                              ),
                                            ],
                                          ),
                                        ));
                                  },
                                ),
                            )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Text(
                                  //   'Sorry! no review found',
                                  //   style:
                                  //   TextStyle(color: Colors.grey, fontSize: 16),
                                  // ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Reviews will appear here once provided.',
                                      style: TextStyle(
                                          color: Colors.grey, fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
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
              _fromHostReviews != null
                  ? Column(
                      children: <Widget>[
                        _fromHostReviews.length != 0
                            ? Expanded(
                                child: ListView.builder(
                                  itemCount: _fromHostReviews.length,
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
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  // Date
                                                  Row(
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Column(
                                                            children: <Widget>[
                                                              Center(
                                                                child: (_reviewerProfiles[_fromHostReviews[index]['ReviewerUserID']]['ImageID'] !=
                                                                            null &&
                                                                        _reviewerProfiles[_fromHostReviews[index]['ReviewerUserID']]['ImageID'] !=
                                                                            '')
                                                                    ? CircleAvatar(
                                                                        backgroundImage:
                                                                            NetworkImage('$storageServerUrl/${_reviewerProfiles[_fromHostReviews[index]['ReviewerUserID']]['ImageID']}'),
                                                                        radius:
                                                                            17.5,
                                                                      )
                                                                    : CircleAvatar(
                                                                        backgroundImage:
                                                                            AssetImage('images/user.png'),
                                                                        radius:
                                                                            17.5,
                                                                        backgroundColor:
                                                                            Color(0xFFF2F2F2),
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
                                                                _reviewerProfiles[_fromHostReviews[index]
                                                                            [
                                                                            'ReviewerUserID']]
                                                                        [
                                                                        'FirstName'] +
                                                                    ' ' +
                                                                    '${_reviewerProfiles[_fromHostReviews[index]['ReviewerUserID']]['LastName'][0]}' +
                                                                    '.',
                                                                style: TextStyle(
                                                                    color: Color(
                                                                        0xff371D32),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14,
                                                                    fontFamily:
                                                                        'Urbanist'),
                                                              ),
                                                              Text(
                                                                DateFormat(
                                                                        "d MMM yyyy")
                                                                    .format(DateTime.parse(
                                                                        _fromHostReviews[index]
                                                                            [
                                                                            'DateTime'])),
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xff353B50),
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .normal,
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
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: List.generate(
                                                            int.parse(
                                                                _fromHostReviews[
                                                                        index]
                                                                    ['Rating']),
                                                            (index) {
                                                          return Icon(
                                                            Icons.star,
                                                            size: 20,
                                                            color: Color(
                                                                0xff5BC0EB),
                                                          );
                                                        }),
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: List.generate(
                                                            5 -
                                                                int.parse(
                                                                    _fromHostReviews[
                                                                            index]
                                                                        [
                                                                        'Rating']),
                                                            (index) {
                                                          return Icon(
                                                            Icons.star,
                                                            size: 20,
                                                            color: Color(
                                                                0xffABABAB),
                                                          );
                                                        }),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 10),
                                              Text(
                                                _fromHostReviews[index]
                                                    ['Review'],
                                                style: TextStyle(
                                                    letterSpacing: -0.4,
                                                    color: Color(0xff371D32),
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 16,
                                                    fontFamily:
                                                        'Urbanist'),
                                              ),
                                            ],
                                          ),
                                        ));
                                  },
                                ),
                              )
                            : Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Text(
                                      //   'Sorry! no review found',
                                      //   style:
                                      //       TextStyle(color: Colors.grey, fontSize: 16),
                                      // )
                                      // // Text(
                                      // //   'Review will be shown if anyone give review',
                                      // //   style:
                                      // //       TextStyle(color: Colors.grey, fontSize: 16),
                                      // // ),

                                      Text(
                                        'Reviews will appear here once provided.',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 16),
                                      ),
                                    ],
                                  ),
                                )),
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
            ])
          : Center(
              child: ShimmerEffect()
            ),
    );
  }
}
