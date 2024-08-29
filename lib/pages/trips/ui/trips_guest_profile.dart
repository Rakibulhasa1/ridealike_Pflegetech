import 'dart:async';
import 'dart:convert' show json;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/pages/profile/response_service/profile_verification_response.dart';
import 'package:ridealike/pages/trips/bloc/guest_user_profile_bloc.dart';
import 'package:ridealike/pages/trips/response_model/guest_profile_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_verification_response.dart';
import 'package:ridealike/pages/trips/response_model/trips_get_car_by_ids_response.dart';

import '../../../utils/app_events/app_events_utils.dart';
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
Future<RestApi.Resp> getProfileData(profileID) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    getProfileUrl,
    json.encode({
      "ProfileID": profileID,
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}


class GuestProfileUi extends StatefulWidget {

  @override
  _GuestProfileUiState createState() => _GuestProfileUiState();
}

class _GuestProfileUiState extends State<GuestProfileUi> {

final guestUserProfileBloc=GuestUserProfileBloc();
final storage = new FlutterSecureStorage();
var profileVerifiedDocument;
Map profileRespRepData={};
ProfileVerificationResponse? profileVerificationResponse;
 Map? receivedData;
String? guestUserID;
@override
void initState() {
  super.initState();
  AppEventsUtils.logEvent("page_viewed",
      params: {"page_name": "Trips Guest Profile"});
  Future.delayed(Duration.zero, () async {
    receivedData = ModalRoute.of(context)!.settings.arguments as Map;
    String? profileID = await storage.read(key: 'profile_id');
    String receivedProfileID = receivedData!['guestProfileID'];
       guestUserID= receivedData!['guestUserID'];
    guestUserProfileBloc.fetchAllData(guestUserID!);
    var profileRes;
  if(receivedData!.isNotEmpty){
  profileRes = await getProfileData(receivedProfileID);
  var response = await profileVerificationData(profileID);

  setState(() {
    profileVerificationResponse = ProfileVerificationResponse.fromJson(json.decode(response.body!));
    profileRespRepData = json.decode(profileRes.body!);
  });

}




  });
}


getReplyTimeString( Map profileRespRepData) {
  print('timeresponse${profileRespRepData['ResponseTime']}');
  print('${profileRespRepData['Profile']['ReplyRate']}');
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

    // String guestUserID= receivedData['guestUserID'];


    return Scaffold(
      backgroundColor: Colors.white,
      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xFFFF8F62)),
          onPressed: () => Navigator.of(context).pop(),
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
      body:
      StreamBuilder<ProfileResponse>(
        stream: guestUserProfileBloc.profileData,
        builder: (context, profileDataSnapshot) {
          return StreamBuilder<ProfileVerificationResponseGuest>(
            stream: guestUserProfileBloc.profileVerification,
            builder: (context, profileVerificationSnapshot) {
              return StreamBuilder<String>(
                stream: guestUserProfileBloc.ratingReview,
                builder: (context, ratingReviewSnapshot) {
                  return
                    profileDataSnapshot.hasData && profileVerificationSnapshot.hasData && ratingReviewSnapshot.hasData
                        && profileDataSnapshot.data!=null && profileVerificationSnapshot.data!=null
                        && ratingReviewSnapshot.data!=null ?
                    Container(
                      child: new SingleChildScrollView(
                        child: Padding(padding: EdgeInsets.all(16.0),
                          child: Column(children: <Widget>[
                            // Profile image and message
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Container(
                                          color: Colors.white,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Column(
                                                    children: <Widget>[
                                                      Center(
                                                        child: profileDataSnapshot.data!.profile!.imageID != "" ? CircleAvatar(
                                                          backgroundImage: NetworkImage('$storageServerUrl/${profileDataSnapshot.data!.profile!.imageID }'),
                                                          radius: 35,
                                                        ) : CircleAvatar(
                                                          backgroundImage: AssetImage('images/user.png'),
                                                          radius: 35,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(width: 10),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: <Widget>[
                                                      SizedBox(width: MediaQuery.of(context).size.width*.5,
                                                        child: AutoSizeText(profileDataSnapshot.data!.profile!.firstName! + '\t'+ '${profileDataSnapshot.data!.profile!.lastName![0]}.',
                                                          style: TextStyle(
                                                              fontFamily: 'Urbanist',
                                                              fontSize: 24,
                                                              color: Color(0xFF371D32)
                                                          ),maxLines: 3,
                                                        ),
                                                      ),
                                                      SizedBox(height: 4,),
                                                      Text(profileDataSnapshot.data!.profile!.createdAt!=null ?'Joined in ${DateFormat("yyyy").format(DateTime.tryParse(profileDataSnapshot.data!.profile!.createdAt!) as DateTime)}':
                                                      ' ',
                                                        style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 14,
                                                          color: Color(0xFF353B50),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Container(
                                                    height: 48,
                                                    width: 48,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xffFF8F68),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        Thread threadData = Thread(
                                                          id: "1123571113",
                                                          userId: profileDataSnapshot.data!.profile!.userID!,
                                                          image: profileDataSnapshot.data!.profile!.imageID != "" ? profileDataSnapshot.data!.profile!.imageID! : "",
                                                          name: profileDataSnapshot.data!.profile!.firstName! + '\t' + profileDataSnapshot.data!.profile!.lastName!,
                                                          message: '',
                                                          time: '',
                                                          messages: [],
                                                        );
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            settings: RouteSettings(name: "/messages"),
                                                            builder: (context) => MessageListView(
                                                              thread: threadData,
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      child: Center(
                                                        child: Image.asset(
                                                          'icons/Message-3.png',
                                                          width: 24,
                                                          height: 24,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  ),

                                                ],
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
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(getReplyTimeString(profileRespRepData),
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 16
                                                      ),
                                                    ),
                                                    Text('Reply time',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 14
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              VerticalDivider(),
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text('${double.parse(profileRespRepData['Profile']['ReplyRate'].toString()).floor()}%',
                                                      style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 18
                                                      ),
                                                    ),
                                                    Text('Reply rate',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 14
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              VerticalDivider(),
                                              Expanded(
                                                flex: 3,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(profileDataSnapshot.data!.profile!.numberOfTrips!=null?
                                                    (profileDataSnapshot.data!.profile!.numberOfTrips).toString()  :'0',
                                                      style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 18
                                                      ),
                                                    ),
                                                    Text('Trips',
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 14
                                                      ),
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
                                          child: Text('About me',
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 24,
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
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Text(profileDataSnapshot.data!.profile!.aboutMe!,
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
                                          child: Text('Information verified',
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 24,
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
                            // Documents verified
                            SizedBox(height: 10),
                            //DRiving license && driving record//
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                profileVerificationSnapshot.data!.verification!.dLVerification!.verificationStatus == 'Verified' ?
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Image.asset('icons/Drivers-licence-2.png'),
                                            SizedBox(width: 5.0),
                                            Container(
                                              child: Row(
                                                  children: [
                                                    Text('Driver\'s license',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color: Color(0xFF353B50),
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ) : new Container(),
                                //insurance history//

                                profileVerificationResponse!.verification!.drivingRecordVerification!=null &&
                                    profileVerificationResponse!.verification!.drivingRecordVerification!.verificationStatus == 'Verified'?
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Icon(Icons.portrait),
                                            SizedBox(width: 5.0),
                                            Container(
                                              child: Row(
                                                children: [
                                                  Text('Driving record',
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
                                ):Container(),
                              ],
                            ),
                            SizedBox(height: 10),
                            //Phone verify && email//
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[

                                profileVerificationResponse!.verification!.phoneVerification!.verificationStatus == 'Verified' ?
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Image.asset('icons/Phone-23.png'),
                                            SizedBox(width: 5.0),
                                            Container(
                                              child: Row(
                                                  children: [
                                                    Text('Mobile number',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color: Color(0xFF353B50),
                                                      ),
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ) : new Container(),
                                profileVerificationResponse!.verification!.emailVerification!.verificationStatus == 'Verified' ?
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: <Widget>[
                                            Image.asset('icons/Mail-2.png'),
                                            SizedBox(width: 5.0),
                                            Container(
                                              child: Row(
                                                children: [
                                                  Text('Email',
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
                                ) : new Container(),
                              ],
                            ),
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
                                          child: Text('Reviews',
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 24,
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
                            SizedBox(height: 10),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        width: double.maxFinite,
                                        child: ElevatedButton(style: ElevatedButton.styleFrom( 
                                          elevation: 0.0,
                                          backgroundColor: Color(0xFFF2F2F2),
                                          padding: EdgeInsets.all(16.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                                        ),
                                            onPressed: () {
                                              Navigator.pushNamed(
                                                  context, '/user_reviews',
                                                  arguments:guestUserID );
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: <Widget>[
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Image.asset('icons/Rating.png'),
                                                    SizedBox(width: 5),
                                                    Text(profileDataSnapshot.data!.profile!.profileRating!.toStringAsFixed(1),
                                                      style: TextStyle(
                                                          fontFamily: 'Urbanist',
                                                          fontSize: 24,
                                                          color: Color(0xFF371D32),
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Text('Based on ' + ratingReviewSnapshot.data! + ' reviews',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF353B50),
                                                  ),
                                                ),
                                                Container(
                                                  child: Icon(
                                                      Icons.keyboard_arrow_right,
                                                      color: Color(0xFF353B50)
                                                  ),
                                                ),
                                              ],
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            StreamBuilder<GetCarsByCarIDsResponse>(
                              stream: guestUserProfileBloc.allCarsStream,
                              builder: (context, allCarsSnapshot) {
                                return allCarsSnapshot.hasData  && allCarsSnapshot.data != null ?
                                Column(children: [
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
                                                profileDataSnapshot.data!.profile!.firstName! +
                                                    ' ' +
                                                    profileDataSnapshot.data!.profile!.lastName! +
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
                                            itemCount: allCarsSnapshot.data!.cars!.length,
                                            itemBuilder: (context, index) {
                                              return GestureDetector(onTap: (){
                                                //todo
                                                Navigator.pushNamed(context, '/car_details_non_search',
                                                    arguments: allCarsSnapshot.data!.cars![index].iD);
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
                                                          image: allCarsSnapshot.data!.cars![index].imagesAndDocuments!.images!.mainImageID == "" ? AssetImage(
                                                              'images/car-placeholder.png')
                                                              : NetworkImage(
                                                              '$storageServerUrl/${allCarsSnapshot.data!.cars![index].imagesAndDocuments!.images!.mainImageID}') as ImageProvider,
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
                                                              Text(allCarsSnapshot.data!.cars![index].about!.make!+ ' ' + allCarsSnapshot.data!.cars![index].about!.model!,
                                                                style:   TextStyle(
                                                                  fontFamily: 'Urbanist',
                                                                  fontSize: 16,

                                                                ),),
                                                              Row(
                                                                children: <Widget>[
                                                                  Text(allCarsSnapshot.data!.cars![index].about!.year!,
                                                                    style: TextStyle(
                                                                      fontSize: 12,
                                                                      fontWeight:
                                                                      FontWeight.normal,
                                                                      fontFamily: 'Urbanist',
                                                                      color: Color(0xff353B50),
                                                                    ),
                                                                  ),
                                                                  Text('.'),
                                                                  Text(allCarsSnapshot.data!.cars![index].numberOfTrips! + ' trip',
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
                                                                '\$${allCarsSnapshot.data!.cars![index].pricing!.rentalPricing!.perDay}/day',
                                                                style:   TextStyle(
                                                            fontFamily: 'Urbanist',
                                                            fontSize: 16,

                                                          ),
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
                                                                children: allCarsSnapshot.data!.cars![index].rating !=
                                                                    0
                                                                    ? List.generate(5,
                                                                        (indexIcon) {
                                                                      return Icon(
                                                                        Icons.star,
                                                                        size: 13,
                                                                        color: indexIcon <
                                                                            allCarsSnapshot.data!.cars![index].rating!
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
                                  ),],): Container();
                              }
                            ),


                          ],
                          ),
                        ),
                      )
                    ):    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new CircularProgressIndicator(strokeWidth: 2.5)
                        ],
                      ),
                    );
                }
              );
            }
          );
        }
      )


    );
  }
}




