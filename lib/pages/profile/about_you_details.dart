import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/models/existing_verification_images.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/profile/response_service/payment_card_info.dart';
import 'package:ridealike/pages/profile/update_your_identity_page.dart';
import 'package:ridealike/widgets/profile_page_block.dart';
import 'package:shimmer/shimmer.dart';

class AboutYouDetails extends StatefulWidget {
  @override
  _AboutYouDetailsState createState() => _AboutYouDetailsState();
}

class _AboutYouDetailsState extends State<AboutYouDetails> {
  Map? _profileData;
  Map? _profileVerificationData;
  Map? _ratingReviews;
   PaymentCardInfo? cardInfo;
  var userIDForReview = null;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      reloadDataFromServer();
    });
  }

  Future<RestApi.Resp> fetchProfileData(_profileID) async {
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

  Future<RestApi.Resp> fetchProfileVerificationData(_profileID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getVerificationStatusByProfileIDUrl,
      json.encode({
        "ProfileID": _profileID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  Future<RestApi.Resp> fetchRatingReviews(profileID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getNumberOfRatingsByProfileIDUrl,
      json.encode({"ProfileID": profileID}),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  Future<void> reloadDataFromServer() async {
    setState(() {
      userIDForReview = null;
    });
    String? profileID = await storage.read(key: 'profile_id');
    String? userID = await storage.read(key: 'user_id');
    var res;
    if (profileID != null) {
      res = await fetchProfileData(profileID);
      var res2 = await fetchProfileVerificationData(profileID);
      var res3 = await fetchRatingReviews(profileID);

      if (json.decode(res.body!).isNotEmpty) {
        setState(() {
          _profileData = json.decode(res.body!)['Profile'];
          _profileVerificationData = json.decode(res2.body!)['Verification'];
          _ratingReviews = json.decode(res3.body!);
        });
      }
    }
    if (userID != null) {
      var cardInfoRes = await fetchCardData(userID);
      setState(() {
        cardInfo = PaymentCardInfo.fromJson(json.decode(cardInfoRes.body!));
      });
    }
    setState(() {
      userIDForReview = json.decode(res.body!)['Profile']['UserID'];
    });
  }

  Future<RestApi.Resp> fetchCardData(_userID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getCardsByUserIDUrl,
      json.encode({
        "UserID": _userID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pushNamed(context, '/profile');
          },
        ),
        centerTitle: true,
        title: Text(
          'About You ',
          style: TextStyle(
              color: Color(0xff371D32), fontSize: 20, fontFamily: 'Urbanist'),
        ),
      ),
      body: userIDForReview == null
          ? SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 220,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, right: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: MediaQuery.of(context).size.width / 3,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 14,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 14,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ///update your identity
                    if (_profileData!['VerificationStatus'] == 'Rejected') ...[
                      ProfilePageBlock(
                        text: 'Update your identity info',
                        image: 'icons/Introduce-Yourself.png',
                        border: true,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateYourIdentityPage(
                                existingVerificationImages:
                                    ExistingVerificationImages(
                                  profileID:
                                      _profileVerificationData!['ProfileID'],
                                  faceImage: _profileVerificationData![
                                      'IdentityVerification']['ImageID'],
                                  licenceFrontImage:
                                      _profileVerificationData!['DLVerification']
                                              ['DLFrontVerification']
                                          ['DLFrontImageID'],
                                  licenceBackImage:
                                      _profileVerificationData!['DLVerification']
                                              ['DLBackVerification']
                                          ['DLBackImageID'],
                                ),
                              ),
                            ),
                          );
                          //     .then((value) {
                          //   if(value != null){
                          //     setState(() {
                          //
                          //       _profileData!['VerificationStatus']= value;
                          //     });
                          //   }
                          // });
                        },
                      ),
                      SizedBox(height: 10),
                    ],

                    /// Email verfication//
                    _profileVerificationData!['EmailVerification']
                                ['VerificationStatus'] ==
                            'Verified'
                        ? new Container()
                        : Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xfff44336)),
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        child: ElevatedButton(
                                          style:ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFF2F2F2),
                                            padding: EdgeInsets.all(12.0),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(8.0)),

                                          ),
                                          onPressed: () {
                                            Navigator.pushNamed(
                                                context, '/verify_email',
                                                arguments: _profileData);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(Icons.mail,
                                                        color:
                                                            Color(0xFF3C2235)),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Verify your email',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(Icons.error_outline,
                                                  color: Color(0xfff44336)),
                                              // Center(
                                              //   child: Container(
                                              //     width: 8,
                                              //     height: 8,
                                              //     // decoration: new BoxDecoration(
                                              //     //   color: Color(0xfff44336),
                                              //     //   shape: BoxShape.circle,
                                              //     // ),
                                              //     child: Icon(Icons.error_outline,color: Color(0xfff44336),),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    _profileVerificationData!['EmailVerification']
                                ['VerificationStatus'] ==
                            'Verified'
                        ? Container()
                        : SizedBox(height: 10),

                    /// Introduce yourself//
                    (_profileData!['AboutMe'] != null &&
                            _profileData!['AboutMe'] != '' &&
                            _profileData!['ImageID'] != null &&
                            _profileData!['ImageID'] != '')
                        ? new Container()
                        : Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xfff44336)),
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                        child: ElevatedButton(
                                          style:ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Color(0xFFF2F2F2),
                                          padding: EdgeInsets.all(12.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                           ),onPressed: () {
                                            Navigator.pushNamed(context,
                                                    '/introduce_yourself',
                                                    arguments: json
                                                        .encode(_profileData))
                                                .then((value) {
                                              if (value != null) {
                                                setState(() {
                                                  _profileData = value as Map;
                                                });
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    Image.asset(
                                                        'icons/Introduce-Yourself.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Introduce yourself',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(Icons.error_outline,
                                                  color: Color(0xfff44336)),
                                              // Container(
                                              //   width: 8,
                                              //   height: 8,
                                              //   decoration: new BoxDecoration(
                                              //     color: Color(0xFFFF8F62),
                                              //     shape: BoxShape.circle,
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    (_profileData!['AboutMe'] != null &&
                            _profileData!['AboutMe'] != '' &&
                            _profileData!['ImageID'] != null &&
                            _profileData!['ImageID'] != '')
                        ? Container()
                        : SizedBox(height: 10),
                    //Payment method
                    cardInfo != null && cardInfo!.cardInfo!.length != 0
                        ? Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: ElevatedButton(
                                        style:ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xFFF2F2F2),
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),),
                                        onPressed: () {
                                          Navigator.pushNamed(context,
                                                  '/profile_payment_method_tab')
                                              .then((value) {
                                            if (value != null) {
                                              setState(() {
                                                cardInfo = value as PaymentCardInfo;
                                              });
                                            }
                                          });
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(
                                                children: <Widget>[
                                                  SizedBox(width: 4),
                                                  Image.asset(
                                                      'icons/Payment-Method.png'),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Payment method',
                                                    style: TextStyle(
                                                      fontFamily: 'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(0xFF371D32),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 16,
                                              child: Icon(
                                                  Icons.keyboard_arrow_right,
                                                  color: Color(0xFF353B50)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color(0xfff44336)),
                                            shape: BoxShape.rectangle,
                                            borderRadius:
                                                BorderRadius.circular(10.0)),
                                        child: ElevatedButton(
                                          style:ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Color(0xFFF2F2F2),
                                          padding: EdgeInsets.all(12.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),),
                                          onPressed: () {
                                            Navigator.pushNamed(context,
                                                    '/profile_payment_method_tab')
                                                .then((value) {
                                              if (value != null) {
                                                setState(() {
                                                  cardInfo = value as PaymentCardInfo;
                                                });
                                              }
                                            });
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Container(
                                                child: Row(
                                                  children: <Widget>[
                                                    SizedBox(width: 4),
                                                    Image.asset(
                                                        'icons/Payment-Method.png'),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      'Payment method',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(Icons.error_outline,
                                                  color: Color(0xfff44336)),
                                            ],
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
                    // Payout
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  style:ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Color(0xFFF2F2F2),
                                  padding: EdgeInsets.all(12.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/profile_payout_method_tab');
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Image.asset(
                                                'icons/Payout-Method.png'),
                                            SizedBox(width: 10),
                                            Text(
                                              'Get paid',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 16,
                                        child: Icon(Icons.keyboard_arrow_right,
                                            color: Color(0xFF353B50)),
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
                    SizedBox(height: 10),
                    // Notification
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  style:ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Color(0xFFF2F2F2),
                                    padding: EdgeInsets.all(12.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        '/profile_notifications_settings_tab',
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Image.asset(
                                                  'icons/Notifications-Button.png'),
                                              SizedBox(width: 10),
                                              Text(
                                                'Notification settings',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: 16,
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

                    SizedBox(height: 10),

                    /// Reviews
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                child: ElevatedButton(
                                  style:ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Color(0xFFF2F2F2),
                                  padding: EdgeInsets.all(12.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/user_reviews',
                                        arguments: userIDForReview);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.stars,
                                        color: Color(0xFF371D32),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        _ratingReviews!['Count'] + ' Reviews',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        width: 16,
                                        child: Icon(Icons.keyboard_arrow_right,
                                            color: Color(0xFF353B50)),
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
                  ],
                ),
              ),
            ),
    );
  }
}
