import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/pages/profile/response_service/profile_verification_response.dart';

import '../utils/app_events/app_events_utils.dart';


Future<RestApi.Resp> fetchRatingReviews(profileID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getNumberOfRatingsByProfileIDUrl,
    json.encode(
        {
          "ProfileID": profileID
        }
        ),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> fetchUserCars(param) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getCarsByUserIDUrl,
    json.encode({"UserID": param}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> getProfileData(_profileID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getProfileUrl,
    json.encode({
      "ProfileID": _profileID,
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
Future<RestApi.Resp> profileVerificationData(_profileID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(getVerificationStatusByProfileIDUrl,
    json.encode({
      "ProfileID": _profileID,
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}


class UserProfile extends StatefulWidget {
  @override
  State createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  var _ratingReviews;
  // List _ratingReviewsAll;
  var _userCars;
 Map profileRespRepData={};
  var _profileData = {};
  var _verification;
  var _userTrips;
  bool _loggedIn = false;
  String _userId = "";
  bool? _hasCarHost;
   var userID;

  String _loggedInUser = '';
  ProfileVerificationResponse? profileVerificationResponse;
  final storage = new FlutterSecureStorage();
    Map? _receivedData;

  @override
  void initState() {
    super.initState();
    _hasCarHost = false;
    Future.delayed(Duration.zero, () async {
      AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "User Profile"});
        _receivedData = ModalRoute.of(context)!.settings.arguments as Map;

      String? profileID = await storage.read(key: 'profile_id');
      String? userID = await storage.read(key: 'user_id');
      if (userID != null) {
        setState(() {
          _loggedIn = true;
          _loggedInUser = userID;
        });
      } else {
        setState(() {
          _loggedIn = false;
        });
      }

      if (_receivedData!.isNotEmpty) {
        var res = await fetchRatingReviews(_receivedData!['ProfileID']);
        var profileRes = await getProfileData(_receivedData!['ProfileID']);

        var res2 = await fetchUserCars(_receivedData!['UserID']);

        var response = await profileVerificationData(_receivedData!['ProfileID']);
        setState(() {
          _userId = _receivedData!['UserID'];
          _ratingReviews = json.decode(res.body!);
          profileRespRepData = json.decode(profileRes.body!);
          print('ProfileResponseData${profileRespRepData['Profile']['ResponseTime']}');

          _userCars = json.decode(res2.body!)['Cars'];
          if(_userCars.length > 0){
            setState(() {
              _hasCarHost=true;
            });

          }else{
            setState(() {
              _hasCarHost=false;
            });
          }

          profileVerificationResponse = ProfileVerificationResponse.fromJson(json.decode(response.body!));
          _profileData = _receivedData!;
        });
      }
    });
  }
  getReplyTimeString( Map profileRespRepData) {
print('timeresponse${profileRespRepData['ResponseTime']}');
print('${profileRespRepData['ReplyRate']}');
var time=double.parse(profileRespRepData['Profile']['ResponseTime'].toString()).floor();
    if(time>=0 && time<= 1) {
      return 'Within a minute';
    }
   if(time>1 && time<= 60){
      return 'Within an hour';
    }
   if( time> 60){
     return 'Within a day';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xFFFF8F62)),
          onPressed: () {
            Future.delayed(Duration(seconds: 1),(){
              Navigator.of(context).pop();
            });

          }
        ),
        actions: <Widget>[
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: <Widget>[
          //     GestureDetector(
          //       onTap: () {
          //         Navigator.pushNamed(
          //           context,
          //           '/discover_tab',
          //         );
          //       },
          //       child: Center(
          //         child: Container(
          //           margin: EdgeInsets.only(right: 16),
          //           child: Icon(Icons.more_horiz, color: Color(0xFFFF8F62)),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
        elevation: 0.0,
      ),

      //Content of tabs
      body: _profileData.isNotEmpty
          ? new SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    // Profile image and message
                    Row(
                      children: <Widget>[
                        Expanded(
                          flex: 8,
                          child: Row(
                            children: [
                              Row(
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Center(
                                        child: _profileData['ImageID'] != ""
                                            ?
                                        CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    '$storageServerUrl/${_profileData['ImageID']}'),
                                                radius: 35,
                                              )
                                            :
                                        CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'images/user.png'),
                                                radius: 35,
                                              ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(width: 10),
                                ],
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    // _loggedIn?
                                    // Text(
                                    //   _profileData['FirstName'] + ' ' +
                                    //       _profileData['LastName'],
                                    //   style: TextStyle(
                                    //       fontFamily:
                                    //       'Roboto',
                                    //       fontSize: 18),
                                    // ):
                                    Text(
                                      _profileData['FirstName'] + ' ' +
                                          '${  _profileData['LastName'][0]}.',
                                      style: TextStyle(
                                          fontFamily:
                                          'Roboto',
                                          fontSize: 18),
                                    ),
                                    // Text(
                                    //   _profileData['FirstName'] +
                                    //       ' ' +
                                    //       _profileData['LastName'],
                                    //   style: TextStyle(
                                    //       fontFamily: 'Urbanist',
                                    //       fontSize: 24,
                                    //       color: Color(0xFF371D32)),
                                    // ),
                                    Text(_profileData['CreatedAt']!=null && _profileData['CreatedAt']!=''?'Joined in ${DateFormat("yyyy").format(DateTime.parse(_profileData['CreatedAt']))}':
                                      ' ',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xFF353B50),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        _loggedIn &&
                            (_profileData['UserID'] !=
                                _loggedInUser)
                            ? Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: 48,
                                      width: 48,
                                      child: GestureDetector(
                                        onTap: () {
                                          Thread threadData = Thread(
                                            id: "1123571113",
                                            userId: _userId,
                                            image: _profileData['ImageID'] != "" ? _profileData['ImageID'] : "",
                                            name: "${_profileData['FirstName']} ${_profileData['LastName']}",
                                            message: '',
                                            time: '',
                                            messages: [],
                                          );

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              settings: RouteSettings(name: "/messages"),
                                              builder: (context) => MessageListView(thread: threadData),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(0xffFF8F68),
                                            borderRadius: BorderRadius.circular(30.0),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Image.asset('icons/Message-3.png', color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                              )
                            : new Container(),
                      ],
                    ),
                    // Profile info
                    SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(getReplyTimeString(profileRespRepData),

                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              'Reply time',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      VerticalDivider(),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text('${double.parse(profileRespRepData['Profile']['ReplyRate'].toString()).floor()}%',
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16),
                                            ),
                                            Text(
                                              'Reply rate',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                      VerticalDivider(),
                                      Expanded(
                                        flex: 3,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(
                                              '${_profileData['NumberOfTrips'] !=null &&  _profileData['NumberOfTrips'] !=''? _profileData['NumberOfTrips'] :0 }',
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              'Trips',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // About me
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'About me',
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 24,
                                        color: Color(0xFF371D32),
                                        fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Text(
                                  _profileData['AboutMe'],
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                    fontSize: 14,
                                    color: Color(0xFF353B50),
                                  ),

                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    // Documents header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Information verified',
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 24,
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
                    // Documents verified
                    SizedBox(height: 10),
                    //driver's licence//
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        profileVerificationResponse!.verification!.dLVerification!.verificationStatus == 'Verified'
                            ? Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset(
                                              'icons/Drivers-licence-2.png'),
                                          SizedBox(width: 5.0),
                                          Container(
                                            child: Row(children: [
                                              Text(
                                                'Driver\'s license',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF353B50),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : new Container(),
                          profileVerificationResponse!.verification!.drivingRecordVerification!=null &&
                            profileVerificationResponse!.verification!.drivingRecordVerification!.verificationStatus == 'Verified'?
                           Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Icon(Icons.portrait),
                                          // Image.asset('icons/Insurance-2.png'),
                                          SizedBox(width: 5.0),
                                          Container(
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Driving record',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF353B50),
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
                              ) :Container(),

                      ],
                    ),
                    SizedBox(height: 10),
                    //phone number//
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        profileVerificationResponse!.verification!.phoneVerification!.verificationStatus == 'Verified'
                            ? Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset('icons/Phone-23.png'),
                                          SizedBox(width: 5.0),
                                          Container(
                                            child: Row(children: [
                                              Text(
                                                'Mobile number',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF353B50),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : new Container(),
                        profileVerificationResponse!.verification!.emailVerification!.verificationStatus == 'Verified'
                            ? Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Image.asset('icons/Mail-2.png'),
                                          SizedBox(width: 5.0),
                                          Container(
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Email',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF353B50),
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
                              )
                            : new Container(),
                      ],
                    ),
                    _hasCarHost!? SizedBox(height: 10):Container(),
                    _hasCarHost!? Row(
                    children: [
                      Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: <Widget>[
                                    // Image.asset('icons/Phone-23.png'),
                                    Icon(Icons.contact_page),
                                    SizedBox(width: 2.0),
                                    Container(
                                      child: Row(children: [
                                        Text(
                                          'Vehicle ownership',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ) : new Container(),

                    // Reviews header

                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Reviews',
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 24,
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
                    SizedBox(height: 10),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Color(0xFFF2F2F2),
                                    padding: EdgeInsets.all(16.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(8.0)),

                                  ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, '/user_reviews',
                                          arguments: _receivedData!['UserID']);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Image.asset('icons/Rating.png'),
                                            SizedBox(width: 5),
                                            Text(
                                              _profileData['ProfileRating']
                                                  .toStringAsFixed(1),
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 24,
                                                  color: Color(0xFF371D32),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Based on ' +
                                              ( _ratingReviews['Count']!= null?_ratingReviews['Count']: '0' )+
                                              ' reviews',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                        Container(
                                          child: Icon(
                                              Icons.keyboard_arrow_right,
                                              color: Color(0xFF353B50)),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // User cars
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    _profileData['FirstName'] +
                                        ' ' +
                                        _profileData['LastName'] +
                                        '\'s vehicles',
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 24,
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
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            height: 276,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: false,
                              itemCount: _userCars.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(onTap: (){
                                  //todo
                                  Navigator.pushNamed(context, '/car_details_non_search',
                                      arguments: _userCars[index]['ID']);
                                },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 16),
                                    width:
                                        MediaQuery.of(context).size.width * .85,
                                    height: 276,
                                    child: Column(
                                      children: <Widget>[
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image(
                                            height: 200,
                                            width: MediaQuery.of(context).size.width * .85,
                                            image: _userCars[index]['ImagesAndDocuments']['Images']['MainImageID'] == "" ? AssetImage(
                                                    'images/car-placeholder.png')
                                                : NetworkImage(
                                                    '$storageServerUrl/${_userCars[index]['ImagesAndDocuments']['Images']['MainImageID']}') as ImageProvider<Object>,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(_userCars[index]['About']['Make'] + ' ' + _userCars[index]['About']['Model'],
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    fontFamily: 'Urbanist',
                                                    color: Color(0xff353B50),
                                                  ),),
                                                Row(
                                                  children: <Widget>[
                                                    Text(_userCars[index]['About']['Year'],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontFamily: 'Urbanist',
                                                        color: Color(0xff353B50),
                                                      ),
                                                    ),
                                                    Text('.'),
                                                    Text(_userCars[index]['NumberOfTrips'] + ' trip',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.normal,
                                                        fontFamily: 'Urbanist',
                                                        color: Color(0xff353B50),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: <Widget>[
                                                Text(
                                                  '\$${_userCars[index]['Pricing']['RentalPricing']['PerDay']}/day',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      fontFamily: 'Urbanist',
                                                      color: Color(0xff353B50),
                                                    )
                                                ),
                                                // Row(
                                                //   mainAxisSize: MainAxisSize.min,
                                                //   children: List.generate(_userCars[index]['Rating'].floor(), (index) {
                                                //     return Icon(
                                                //       Icons.star,
                                                //       size: 13,
                                                //       color: Color(0xff7CB7B6),
                                                //     );
                                                //   }),
                                                // ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: _userCars[index]
                                                              ['Rating'] !=
                                                          0
                                                      ? List.generate(5,
                                                          (indexIcon) {
                                                          return Icon(
                                                            Icons.star,
                                                            size: 13,
                                                            color: indexIcon <
                                                                    _userCars[index]
                                                                            [
                                                                            'Rating']
                                                                        .floor()
                                                                ? Color(
                                                                    0xff5BC0EB)
                                                                : Colors.grey,
                                                          );
                                                        })
                                                      : List.generate(5, (index) {
                                                          return Icon(
                                                            Icons.star,
                                                            size: 13,
                                                            color: Colors.grey,
                                                          );
                                                        }),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[new CircularProgressIndicator()],
              ),
            ),
    );
  }
}
