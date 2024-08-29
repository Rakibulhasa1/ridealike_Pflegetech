import 'dart:async';
import 'dart:convert' show json;
import 'dart:core';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ridealike/main.dart' as Main;
import 'package:ridealike/models/existing_verification_images.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/profile/policy_page.dart';
import 'package:ridealike/pages/profile/response_service/payment_card_info.dart';
import 'package:ridealike/pages/profile/response_service/unread_notification_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/profile_page_block.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'available_coupons_view.dart';
import 'update_your_identity_page.dart';

class ProfileView extends StatefulWidget {
  @override
  State createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  var _ratingReviews;
  Map? _profileData;
  Map? _profileVerificationData;
  bool isDataLoaded = false;
  PaymentCardInfo? cardInfo;
  final storage = new FlutterSecureStorage();
  bool deleteSuccess = false;

  var userIDForReview;
  UnreadNotificationResponse? unreadNotification;

  void launchUrl(String url) async {
    if (await canLaunch(url) != null) {
      launch(url);
    } else {
      throw "Could not launch $url";
    }
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

  Future<RestApi.Resp> fetchUnreadNotifications(userID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getUnreadNotificationByUserIDUrl,
      json.encode({
        "UserID": userID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  Future<RestApi.Resp> checkUnreadNotificationStatus(userID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      changeUnreadNotificationStatusUrl,
      json.encode({
        "UserID": userID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  Future<RestApi.Resp> fetchUserCars(userID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getCarsByUserIDUrl,
      json.encode({
        "UserID": userID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name": "Profile"});
    callFetchProfileData();
    getCardData();
    getUnreadNotification();
  }

  callFetchProfileData() async {
    String? profileID = await storage.read(key: 'profile_id');

    if (profileID != null) {
      var res = await fetchProfileData(profileID);
      var res2 = await fetchProfileVerificationData(profileID);
      var res3 = await fetchRatingReviews(profileID);
      userIDForReview = json.decode(res.body!)['Profile']['UserID'];

      if (json.decode(res.body!).isNotEmpty) {
        setState(() {
          _profileData = json.decode(res.body!)['Profile'];
          _profileVerificationData = json.decode(res2.body!)['Verification'];
          _ratingReviews = json.decode(res3.body!);
          isDataLoaded = true;
        });
      }
    }
  }

  void _showLogoutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Logout',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 18,
              )),
          content: Text('Are you sure you want to logout?',
              style: TextStyle(
                fontFamily: 'Urbanist',
              )),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  color: Color(0xffFF8F68),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 16,
                  color: Color(0xffFF8F68),
                ),
              ),
              onPressed: () async {
                Main.notificationCount.value = 0;
                FlutterAppBadger.removeBadge();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove("count");
                await storage.delete(key: 'profile_id');
                await storage.delete(key: 'user_id');
                await storage.delete(key: 'jwt');
                AppEventsUtils.logEvent("logged_out");
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/create_profile_or_sign_in',
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  getCardData() async {
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var cardInfoRes = await fetchCardData(userID);
      setState(() {
        cardInfo = PaymentCardInfo.fromJson(json.decode(cardInfoRes.body!));
      });
    }
  }

  getUnreadNotification() async {
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var unreadResponse = await fetchUnreadNotifications(userID);

      unreadNotification = UnreadNotificationResponse.fromJson(
          json.decode(unreadResponse.body!));
      if (unreadNotification != null &&
          unreadNotification!.totalCount != null &&
          unreadNotification!.totalCount != '0') {
        int? notificationCount = int.tryParse(unreadNotification!.totalCount!);
        Main.notificationCount.value = notificationCount!;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("count", Main.notificationCount.value.toString());
        /*await storage.write(
              key: "count",
              value: Main.notificationCount.value.toString()
                  .toString());*/
        FlutterAppBadger.updateBadgeCount(Main.notificationCount.value);
      }
      print('unread${unreadNotification!.totalCount}');
    }
  }

  bool aboutYouVerificationCheck() {
    if (_profileData!['VerificationStatus'] != 'Rejected' &&
        _profileVerificationData!['EmailVerification']['VerificationStatus'] ==
            'Verified' &&
        (_profileData!['AboutMe'] != null &&
            _profileData!['AboutMe'] != '' &&
            _profileData!['ImageID'] != null &&
            _profileData!['ImageID'] != '') &&
        cardInfo != null &&
        cardInfo!.cardInfo!.length != 0) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,

        //Content of tabs
        body:
            // isDataLoaded
            //     ?
            SafeArea(
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16, top: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // SizedBox(height: 35),
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: Container(
                                  child: Text(
                                    'Profile',
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
                    SizedBox(height: 10),
                    // Image & name
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
                                    padding: EdgeInsets.all(12.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, '/profile_edit_tab');
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: [
                                          Column(
                                            children: <Widget>[
                                              Center(
                                                child: (_profileData
                                                                ?.containsKey(
                                                                    'ImageID') ==
                                                            true &&
                                                        _profileData![
                                                                'ImageID'] !=
                                                            null &&
                                                        _profileData![
                                                                'ImageID'] !=
                                                            '')
                                                    ? CircleAvatar(
                                                        radius: 28,
                                                        backgroundColor:
                                                            Color(0xFFF2F2F2),
                                                        backgroundImage:
                                                            NetworkImage(
                                                                '$storageServerUrl/${_profileData!['ImageID']}'),
                                                      )
                                                    : Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey.shade300,
                                                        highlightColor: Colors
                                                            .grey.shade100,
                                                        child: Container(
                                                          width: 50,
                                                          height: 50,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(width: 15),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              _profileData != null
                                                  ? Text(
                                                      _profileData![
                                                              'FirstName'] +
                                                          ' ' +
                                                          _profileData![
                                                              'LastName'],
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 12,
                                                      width: 100,
                                                      child: Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey.shade300,
                                                        highlightColor: Colors
                                                            .grey.shade100,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .grey[300],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                      ),
                                                    ), SizedBox(height: 8,),
                                              _profileData != null
                                                  ? Text(
                                                      (_profileData!['VerificationStatus'] ==
                                                                  'InProgress' ||
                                                              _profileData![
                                                                      'VerificationStatus'] ==
                                                                  'Submitted'
                                                          ? 'Verification in progress'
                                                          : _profileData![
                                                                      'VerificationStatus'] ==
                                                                  'Rejected'
                                                              ? 'Verification Rejected'
                                                              : _profileData![
                                                                          'VerificationStatus'] ==
                                                                      'Blocked'
                                                                  ? 'Temporarily blocked'
                                                                  : _profileData![
                                                                              'VerificationStatus'] ==
                                                                          'Bucket'
                                                                      ? 'Verification Submitted'
                                                                      : '${_profileData!['Email']} '),
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF371D32),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 9,
                                                      width:MediaQuery.of(context).size.width /3,
                                                      child: Shimmer.fromColors(
                                                        baseColor: Colors
                                                            .grey.shade300,
                                                        highlightColor: Colors
                                                            .grey.shade100,
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                              color: Colors
                                                                  .grey[300],
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10)),
                                                        ),
                                                      ),
                                                    ),
                                              _profileData != null &&
                                                      _profileData![
                                                              'VerificationStatus'] ==
                                                          'Verified' &&
                                                      _profileVerificationData !=
                                                          null &&
                                                      _profileVerificationData![
                                                                  'EmailVerification']
                                                              [
                                                              'VerificationStatus'] ==
                                                          'Pending'
                                                  ? Text(
                                                      'Unverified',
                                                      style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xfff44336),
                                                      ),
                                                    )
                                                  : _profileData != null
                                                      ? Container()
                                                      : SizedBox(height: 10),

                                              // Text(
                                              //   _profileData!['VerificationStatus'] ==
                                              //               'InProgress' ||
                                              //           _profileData![
                                              //                   'VerificationStatus'] ==
                                              //               'Submitted'
                                              //       ? 'Verification in progress'
                                              //       : _profileData![
                                              //                   'VerificationStatus'] ==
                                              //               'Rejected'
                                              //           ? 'Verification Rejected'
                                              //           : _profileData![
                                              //                       'VerificationStatus'] ==
                                              //                   'Blocked'
                                              //               ? 'Temporarily blocked'
                                              //               : _profileData![
                                              //                           'VerificationStatus'] ==
                                              //                       'Bucket'
                                              //                   ? 'Verification Submitted'
                                              //                   : '${_profileData!['Email']} ',
                                              //   style: TextStyle(
                                              //     fontFamily: 'Urbanist',
                                              //     fontSize: 14,
                                              //     color: Color(0xFF353B50),
                                              //   ),
                                              // ),
                                              // _profileData!['VerificationStatus'] ==
                                              //             'Verified' &&
                                              //         _profileVerificationData![
                                              //                     'EmailVerification']
                                              //                 [
                                              //                 'VerificationStatus'] ==
                                              //             'Pending'
                                              //     ? Text(
                                              //         'Unverified',
                                              //         style: TextStyle(
                                              //           fontFamily:
                                              //               'Urbanist',
                                              //           fontSize: 14,
                                              //           color:
                                              //               Color(0xfff44336),
                                              //         ),
                                              //       )
                                              //     : Container(),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            width: 16,
                                            child: Icon(
                                                Icons.keyboard_arrow_right,
                                                color: Color(0xFF353B50)),
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
                    // SizedBox(height: 15),

                    ///about you//
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'ABOUT YOU',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Colors.grey),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Column(
                      children: [
                        ///update your identity
                        _profileData != null
                            ? _profileData!['VerificationStatus'] == 'Rejected'
                                ? Row(
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
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0.0,
                                                    backgroundColor:
                                                        Color(0xFFF2F2F2),
                                                    padding:
                                                        EdgeInsets.all(12.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdateYourIdentityPage(
                                                          existingVerificationImages:
                                                              ExistingVerificationImages(
                                                            profileID:
                                                                _profileVerificationData![
                                                                    'ProfileID'],
                                                            faceImage:
                                                                _profileVerificationData![
                                                                        'IdentityVerification']
                                                                    ['ImageID'],
                                                            licenceFrontImage:
                                                                _profileVerificationData![
                                                                            'DLVerification']
                                                                        [
                                                                        'DLFrontVerification']
                                                                    [
                                                                    'DLFrontImageID'],
                                                            licenceBackImage:
                                                                _profileVerificationData![
                                                                            'DLVerification']
                                                                        [
                                                                        'DLBackVerification']
                                                                    [
                                                                    'DLBackImageID'],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(
                                                                Icons
                                                                    .perm_identity_outlined,
                                                                color: Color(
                                                                    0xFF3C2235)),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Update your identity info',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xFF371D32),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(Icons.error_outline,
                                                          color: Color(
                                                              0xfff44336)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Container()
                            : SizedBox(height: 0),
                        SizedBox(height: 10),
                        // if (_profileData!['VerificationStatus'] ==
                        //     'Rejected') ...[
                        //   ProfilePageBlock(
                        //     text: 'Update your identity info',
                        //     image: 'icons/Introduce-Yourself.png',
                        //     border: true,
                        //     onPressed: () {
                        //       Navigator.push(
                        //         context,
                        //         MaterialPageRoute(
                        //           builder: (context) =>
                        //               UpdateYourIdentityPage(
                        //             existingVerificationImages:
                        //                 ExistingVerificationImages(
                        //               profileID: _profileVerificationData![
                        //                   'ProfileID'],
                        //               faceImage: _profileVerificationData![
                        //                   'IdentityVerification']['ImageID'],
                        //               licenceFrontImage:
                        //                   _profileVerificationData![
                        //                               'DLVerification']
                        //                           ['DLFrontVerification']
                        //                       ['DLFrontImageID'],
                        //               licenceBackImage:
                        //                   _profileVerificationData![
                        //                               'DLVerification']
                        //                           ['DLBackVerification']
                        //                       ['DLBackImageID'],
                        //             ),
                        //           ),
                        //         ),
                        //       );
                        //     },
                        //   ),
                        //   SizedBox(height: 10),
                        // ],

                        /// Email verfication//
                        _profileVerificationData != null
                            ? _profileVerificationData!['EmailVerification']
                                        ['VerificationStatus'] ==
                                    'Verified'
                                ? Container()
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
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0.0,
                                                    backgroundColor:
                                                        Color(0xFFF2F2F2),
                                                    padding:
                                                        EdgeInsets.all(12.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pushNamed(context,
                                                        '/verify_email',
                                                        arguments:
                                                            _profileData);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Container(
                                                        child: Row(
                                                          children: <Widget>[
                                                            Icon(Icons.mail,
                                                                color: Color(
                                                                    0xFF3C2235)),
                                                            SizedBox(width: 10),
                                                            Text(
                                                              'Verify your email',
                                                              style: TextStyle(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 16,
                                                                color: Color(
                                                                    0xFF371D32),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Icon(Icons.error_outline,
                                                          color: Color(
                                                              0xfff44336)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                            : SizedBox(height: 0),
                        _profileVerificationData != null &&
                                _profileVerificationData!['EmailVerification']
                                        ['VerificationStatus'] ==
                                    'Verified'
                            ? Container()
                            : SizedBox(height: 10),
                          ///Available coupons
                        // _profileVerificationData != null &&
                        //     _profileVerificationData!['EmailVerification']
                        //     ['VerificationStatus'] ==
                        //         'Verified'
                        //     ?
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius:
                                        BorderRadius.circular(
                                            8.0),
                                      ),
                                      child: ElevatedButton(
                                        style:
                                        ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor:
                                          Color(0xFFF2F2F2),
                                          padding:
                                          EdgeInsets.all(12.0),
                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(
                                                8.0),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context)=>AvailableCouponView()));
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment
                                              .spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .center,
                                          children: <Widget>[
                                            Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Image.asset('images/couponIcon.png',width: 30,height: 30,),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Available coupons',
                                                    style: TextStyle(
                                                      fontFamily:
                                                      'Urbanist',
                                                      fontSize: 16,
                                                      color: Color(
                                                          0xFF371D32),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            Row(
                                              children: [
                                                SvgPicture.asset('svg/Frame 3.svg'),
                                                SizedBox(width: 15,),
                                                Container(
                                                  width: 16,
                                                  child: Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
                                                      color: Color(0xFF353B50)),
                                                ),
                                              ],
                                            ),
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
                            // : SizedBox(height: 0),
                        _profileVerificationData != null &&
                            _profileVerificationData!['EmailVerification']
                            ['VerificationStatus'] ==
                                'Verified'
                            ? SizedBox(height: 10)
                            : SizedBox(height: 10),
                        // _profileVerificationData!['EmailVerification']
                        //             ['VerificationStatus'] ==
                        //         'Verified'
                        //     ? new Container()
                        //     : Row(
                        //         children: <Widget>[
                        //           Expanded(
                        //             child: Column(
                        //               children: [
                        //                 SizedBox(
                        //                   width: double.maxFinite,
                        //                   child: Container(
                        //                     decoration: BoxDecoration(
                        //                         border: Border.all(
                        //                             color: Color(0xfff44336)),
                        //                         shape: BoxShape.rectangle,
                        //                         borderRadius:
                        //                             BorderRadius.circular(
                        //                                 8.0)),
                        //                     child: ElevatedButton(style: ElevatedButton.styleFrom(
                        //                       elevation: 0.0,
                        //                       color: Color(0xFFF2F2F2),
                        //                       padding: EdgeInsets.all(12.0),
                        //                       shape: RoundedRectangleBorder(
                        //                           borderRadius:
                        //                               BorderRadius.circular(
                        //                                   8.0)),
                        //                       onPressed: () {
                        //                         Navigator.pushNamed(
                        //                             context, '/verify_email',
                        //                             arguments: _profileData);
                        //                       },
                        //                       child: Row(
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment
                        //                                 .spaceBetween,
                        //                         crossAxisAlignment:
                        //                             CrossAxisAlignment.center,
                        //                         children: <Widget>[
                        //                           Container(
                        //                             child: Row(
                        //                               children: <Widget>[
                        //                                 Icon(Icons.mail,
                        //                                     color: Color(
                        //                                         0xFF3C2235)),
                        //                                 SizedBox(width: 10),
                        //                                 Text(
                        //                                   'Verify your email',
                        //                                   style: TextStyle(
                        //                                     fontFamily:
                        //                                         'Urbanist',
                        //                                     fontSize: 16,
                        //                                     color: Color(
                        //                                         0xFF371D32),
                        //                                   ),
                        //                                 ),
                        //                               ],
                        //                             ),
                        //                           ),
                        //                           Icon(Icons.error_outline,
                        //                               color:
                        //                                   Color(0xfff44336)),
                        //                           // Center(
                        //                           //   child: Container(
                        //                           //     width: 8,
                        //                           //     height: 8,
                        //                           //     // decoration: new BoxDecoration(
                        //                           //     //   color: Color(0xfff44336),
                        //                           //     //   shape: BoxShape.circle,
                        //                           //     // ),
                        //                           //     child: Icon(Icons.error_outline,color: Color(0xfff44336),),
                        //                           //   ),
                        //                           // ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        // _profileVerificationData!['EmailVerification']
                        //             ['VerificationStatus'] ==
                        //         'Verified'
                        //     ? Container()
                        //     : SizedBox(height: 10),

                        /// Introduce yourself//
                        // (_profileData!['AboutMe'] != null &&
                        //         _profileData!['AboutMe'] != '' &&
                        //         _profileData!['ImageID'] != null &&
                        //         _profileData!['ImageID'] != '')
                        //     ? new Container()
                        //     : Row(
                        //         children: <Widget>[
                        //           Expanded(
                        //             child: Column(
                        //               children: [
                        //                 SizedBox(
                        //                   width: double.maxFinite,
                        //                   child: Container(
                        //                     decoration: BoxDecoration(
                        //                         border: Border.all(
                        //                             color: Colors.white),
                        //                         shape: BoxShape.rectangle,
                        //                         borderRadius:
                        //                             BorderRadius.circular(
                        //                                 8.0)),
                        //                     child: ElevatedButton(style: ElevatedButton.styleFrom(
                        //                       elevation: 0.0,
                        //                       color: Color(0xFFF2F2F2),
                        //                       padding: EdgeInsets.all(12.0),
                        //                       shape: RoundedRectangleBorder(
                        //                           borderRadius:
                        //                               BorderRadius.circular(
                        //                                   8.0)),
                        //                       onPressed: () {
                        //                         Navigator.pushNamed(context,
                        //                                 '/introduce_yourself',
                        //                                 arguments:
                        //                                     json.encode(
                        //                                         _profileData))
                        //                             .then((value) {
                        //                           if (value != null) {
                        //                             setState(() {
                        //                               _profileData = value;
                        //                             });
                        //                           }
                        //                         });
                        //                       },
                        //                       child: Row(
                        //                         mainAxisAlignment:
                        //                             MainAxisAlignment
                        //                                 .spaceBetween,
                        //                         crossAxisAlignment:
                        //                             CrossAxisAlignment.center,
                        //                         children: <Widget>[
                        //                           Container(
                        //                             child: Row(
                        //                               children: <Widget>[
                        //                                 Image.asset(
                        //                                     'icons/Introduce-Yourself.png'),
                        //                                 SizedBox(width: 10),
                        //                                 Text(
                        //                                   'Introduce yourself',
                        //                                   style: TextStyle(
                        //                                     fontFamily:
                        //                                         'Urbanist',
                        //                                     fontSize: 16,
                        //                                     color: Color(
                        //                                         0xFF371D32),
                        //                                   ),
                        //                                 ),
                        //                               ],
                        //                             ),
                        //                           ),
                        //                           Container(
                        //                             width: 16,
                        //                             child: Icon(
                        //                                 Icons
                        //                                     .keyboard_arrow_right,
                        //                                 color: Color(
                        //                                     0xFF353B50)),
                        //                           ),
                        //                           // Icon(Icons.error_outline,
                        //                           //     color:
                        //                           //         Color(0xfff44336)),
                        //                           // Container(
                        //                           //   width: 8,
                        //                           //   height: 8,
                        //                           //   decoration: new BoxDecoration(
                        //                           //     color: Color(0xFFFF8F62),
                        //                           //     shape: BoxShape.circle,
                        //                           //   ),
                        //                           // ),
                        //                         ],
                        //                       ),
                        //                     ),
                        //                   ),
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        // (_profileData!['AboutMe'] != null &&
                        //         _profileData!['AboutMe'] != '' &&
                        //         _profileData!['ImageID'] != null &&
                        //         _profileData!['ImageID'] != '')
                        //     ? Container()
                        //     : SizedBox(height: 10),
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
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor:
                                                  Color(0xFFF2F2F2),
                                              padding: EdgeInsets.all(12.0),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0)),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                      '/profile_payment_method_tab')
                                                  .then((value) {
                                                if (value != null) {
                                                  setState(() {
                                                    cardInfo = value
                                                        as PaymentCardInfo;
                                                  });
                                                }
                                              });
                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Container(
                                                  child: Row(
                                                    children: <Widget>[
                                                      Image.asset(
                                                          'icons/payment.png',
                                                          width: 25,
                                                          height: 30),
                                                      SizedBox(width: 10),
                                                      Text(
                                                        'Payment method',
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 16,
                                                          color:
                                                              Color(0xFF371D32),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  width: 16,
                                                  child: Icon(
                                                      Icons
                                                          .keyboard_arrow_right,
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
                                                    color: Colors.white),
                                                shape: BoxShape.rectangle,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        10.0)),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                backgroundColor:
                                                    Color(0xFFF2F2F2),
                                                padding: EdgeInsets.all(12.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0)),
                                              ),
                                              onPressed: () {
                                                Navigator.pushNamed(context,
                                                        '/profile_payment_method_tab')
                                                    .then((value) {
                                                  if (value != null) {
                                                    setState(() {
                                                      cardInfo = value
                                                          as PaymentCardInfo;
                                                    });
                                                  }
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: <Widget>[
                                                  Container(
                                                    child: Row(
                                                      children: <Widget>[
                                                        Image.asset(
                                                            'icons/payment.png',
                                                            width: 25,
                                                            height: 30),
                                                        SizedBox(width: 10),
                                                        Text(
                                                          'Payment method',
                                                          style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 16,
                                                            color: Color(
                                                                0xFF371D32),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    width: 16,
                                                    child: Icon(
                                                        Icons
                                                            .keyboard_arrow_right,
                                                        color:
                                                            Color(0xFF353B50)),
                                                  ),
                                                  // Icon(Icons.error_outline,
                                                  //     color:
                                                  //         Color(0xfff44336)),
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
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xFFF2F2F2),
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(context,
                                            '/profile_payout_method_tab');
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            child: Row(
                                              children: <Widget>[
                                                Image.asset('icons/Wallet.png',
                                                    width: 25, height: 30),
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
                                        style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Color(0xFFF2F2F2),
                                          padding: EdgeInsets.all(12.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                        ),
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
                                                      'icons/Notification.png',
                                                      width: 25,
                                                      height: 30),
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
                                      style: ElevatedButton.styleFrom(
                                        elevation: 0.0,
                                        backgroundColor: Color(0xFFF2F2F2),
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/user_reviews',
                                            arguments: userIDForReview);
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Image.asset('icons/Satisfaction.png',
                                              width: 25, height: 30),
                                          SizedBox(width: 10),
                                          Text(
                                            _ratingReviews != null
                                                ? _ratingReviews['Count'] +
                                                    ' Reviews'
                                                : 'All Reviews',
                                            style: _ratingReviews != null
                                                ? TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  )
                                                : TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  ),
                                          ),
                                          //
                                          // Text(
                                          //     _ratingReviews['Count'] +
                                          //       'All Reviews',
                                          //   style: TextStyle(
                                          //     fontFamily: 'Urbanist',
                                          //     fontSize: 16,
                                          //     color: Color(0xFF371D32),
                                          //   ),
                                          // ),

                                          Spacer(),
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
                        ),
                      ],
                    ),
                    SizedBox(height: 15),

                    Text('ABOUT RIDEALIKE',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            color: Colors.grey)),
                    SizedBox(height: 20),
                    Column(
                      children: [
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
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                      ),
                                      onPressed: () {
                                        // Navigator.pushNamed(context, '/profile_faqs_tab',);
                                        launchUrl(faqUrl);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            child: Row(children: [
                                              Image.asset('icons/Faq.png',
                                                  width: 25, height: 30),
                                              SizedBox(width: 10),
                                              Text(
                                                'FAQs',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32),
                                                ),
                                              ),
                                            ]),
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
                        ),
                        SizedBox(height: 10),
                        // Refer a Friend
                        ProfilePageBlock(
                          text: 'Refer-a-Friend',
                          image: 'icons/Network.png',
                          onPressed: () {
                            launchUrl(referAFriend);
                          },
                        ),
                        SizedBox(height: 10),

                        // Blog
                        ProfilePageBlock(
                          text: 'Blog',
                          image: 'icons/Blog.png',
                          onPressed: () {
                            launchUrl(blogUrl);
                          },
                        ),
                        SizedBox(height: 10),

                        // Policies
                        ProfilePageBlock(
                            text: 'Policies & Insurance',
                            image: 'icons/Health.png',
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PolicyPage(),
                                  ));
                            }),
                        SizedBox(height: 10),
                      ],
                    ),
                    SizedBox(height: 15),

                    Text('SUPPORT',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            color: Colors.grey)),
                    SizedBox(height: 20),

                    Column(
                      children: [
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
                                          padding: EdgeInsets.all(12.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                        ),
                                        onPressed: () {
                                          launchUrl(contactUsUrl);
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Image.asset(
                                                      'icons/Help desk.png',
                                                      width: 25,
                                                      height: 30),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Contact Us',
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
                        SizedBox(
                          height: 10,
                        ),

                        ///Feedback
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
                                        padding: EdgeInsets.all(12.0),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0)),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                            context, '/profile_feedback_tab',
                                            arguments: _profileData);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Container(
                                            child: Row(
                                              children: <Widget>[
                                                Image.asset(
                                                    'icons/Feedback.png',
                                                    width: 25,
                                                    height: 30),
                                                SizedBox(width: 10),
                                                Text(
                                                  'Give us feedback',
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
                        ),
                        SizedBox(
                          height: 10,
                        ),
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
                                          padding: EdgeInsets.all(12.0),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0)),
                                        ),
                                        onPressed: () {
                                          Navigator.pushNamed(
                                              context, '/submit_claim');
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Container(
                                              child: Row(
                                                children: <Widget>[
                                                  Image.asset(
                                                      'icons/image 2.png',
                                                      width: 25,
                                                      height: 30),
                                                  SizedBox(width: 10),
                                                  Text(
                                                    'Submit A Claim',
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
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    //schedule vehicle disinfection service//
                    // Row(
                    //   children: <Widget>[
                    //     Expanded(
                    //       child: Column(
                    //         children: [
                    //           SizedBox(
                    //             width: double.maxFinite,
                    //             child: ElevatedButton(style: ElevatedButton.styleFrom(
                    //                 elevation: 0.0,
                    //                 color: Color(0xFFF2F2F2),
                    //                 padding: EdgeInsets.all(12.0),
                    //                 shape: RoundedRectangleBorder(
                    //                     borderRadius:
                    //                         BorderRadius.circular(8.0)),
                    //                 onPressed: () {
                    //                   launchUrl(covidSanitizationdUrl);
                    //                 },
                    //                 child: Row(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.spaceBetween,
                    //                   children: <Widget>[
                    //                     Container(
                    //                       child: Row(
                    //                         children: <Widget>[
                    //                           Image.asset('icons/Service.png',width: 25,height:30),
                    //
                    //                           SizedBox(width: 10),
                    //                           Text(
                    //                             'Schedule Vehicle Disinfection Service',
                    //                             style: TextStyle(
                    //                               fontFamily: 'Urbanist',
                    //                               fontSize: 16,
                    //                               color: Color(0xFF371D32),
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                     Container(
                    //                       width: 16,
                    //                       child: Icon(
                    //                           Icons.keyboard_arrow_right,
                    //                           color: Color(0xFF353B50)),
                    //                     ),
                    //                   ],
                    //                 )),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 10,
                    // ),
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
                                    padding: EdgeInsets.all(12.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                  ),
                                  onPressed: () {
                                    _showLogoutDialog(context);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        child: Row(
                                          children: <Widget>[
                                            Image.asset('icons/Exit.png',
                                                width: 25, height: 30),
                                            SizedBox(width: 10),
                                            Text(
                                              'Log Out',
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

                    ///about you previous ui design///
                    // Row(
                    //   children: <Widget>[
                    //     Expanded(
                    //       child: Column(
                    //         children: [
                    //           SizedBox(
                    //             width: double.maxFinite,
                    //             child: Container(
                    //               decoration: aboutYouVerificationCheck()
                    //                   ? BoxDecoration(
                    //                       border:
                    //                           Border.all(color: Colors.white),
                    //                       shape: BoxShape.rectangle,
                    //                       borderRadius:
                    //                           BorderRadius.circular(10.0))
                    //                   : BoxDecoration(
                    //                       border: Border.all(
                    //                           color: Color(0xfff44336)),
                    //                       shape: BoxShape.rectangle,
                    //                       borderRadius:
                    //                           BorderRadius.circular(10.0)),
                    //               child: ElevatedButton(style: ElevatedButton.styleFrom(
                    //                   elevation: 0.0,
                    //                   color: Color(0xFFF2F2F2),
                    //                   padding: EdgeInsets.all(12.0),
                    //                   shape: RoundedRectangleBorder(
                    //                       borderRadius:
                    //                           BorderRadius.circular(8.0)),
                    //                   onPressed: () {
                    //                     Navigator.pushNamed(
                    //                         context, '/about_you_tab',
                    //                         arguments: {
                    //                           'profileData': _profileData,
                    //                           'profileVerificationData':
                    //                               _profileVerificationData,
                    //                           'ratingReviews': _ratingReviews,
                    //                           'cardInfo': cardInfo
                    //                         }).then((value) {
                    //                       callFetchProfileData();
                    //                       getCardData();
                    //                     });
                    //                   },
                    //                   child: Row(
                    //                     mainAxisAlignment:
                    //                         MainAxisAlignment.spaceBetween,
                    //                     children: <Widget>[
                    //                       Container(
                    //                         child: Row(
                    //                           children: <Widget>[
                    //                             Icon(Icons
                    //                                 .accessibility_new_outlined),
                    //                             SizedBox(width: 10),
                    //                             Text(
                    //                               'About You',
                    //                               style: TextStyle(
                    //                                 fontFamily: 'Urbanist',
                    //                                 fontSize: 16,
                    //                                 color: Color(0xFF371D32),
                    //                               ),
                    //                             ),
                    //                           ],
                    //                         ),
                    //                       ),
                    //                       aboutYouVerificationCheck()
                    //                           ? Container(
                    //                               width: 16,
                    //                               child: Icon(
                    //                                   Icons
                    //                                       .keyboard_arrow_right,
                    //                                   color:
                    //                                       Color(0xFF353B50)),
                    //                             )
                    //                           : Icon(Icons.error_outline,
                    //                               color: Color(0xfff44336)),
                    //                     ],
                    //                   )),
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 12),

                    // ///about rideAlike
                    // Row(
                    //   children: <Widget>[
                    //     Expanded(
                    //       child: Column(
                    //         children: [
                    //           SizedBox(
                    //             width: double.maxFinite,
                    //             child: ElevatedButton(style: ElevatedButton.styleFrom(
                    //                 elevation: 0.0,
                    //                 color: Color(0xFFF2F2F2),
                    //                 padding: EdgeInsets.all(12.0),
                    //                 shape: RoundedRectangleBorder(
                    //                     borderRadius:
                    //                         BorderRadius.circular(8.0)),
                    //                 onPressed: () {
                    //                   Navigator.pushNamed(
                    //                     context,
                    //                     '/about_rideAlike_tab',
                    //                   );
                    //                 },
                    //                 child: Row(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.spaceBetween,
                    //                   children: <Widget>[
                    //                     Container(
                    //                       child: Row(
                    //                         children: <Widget>[
                    //                           Image.asset('images/logo_r.png',
                    //                               width: 18,
                    //                               height: 18,
                    //                               color: Color(0xFF371D32)),
                    //                           SizedBox(width: 10),
                    //                           Text(
                    //                             'About RideAlike',
                    //                             style: TextStyle(
                    //                               fontFamily: 'Urbanist',
                    //                               fontSize: 16,
                    //                               color: Color(0xFF371D32),
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                     Container(
                    //                       width: 16,
                    //                       child: Icon(
                    //                           Icons.keyboard_arrow_right,
                    //                           color: Color(0xFF353B50)),
                    //                     ),
                    //                   ],
                    //                 )),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(height: 12),

                    ///suport
                    // Row(
                    //   children: <Widget>[
                    //     Expanded(
                    //       child: Column(
                    //         children: [
                    //           SizedBox(
                    //             width: double.maxFinite,
                    //             child: ElevatedButton(style: ElevatedButton.styleFrom(
                    //                 elevation: 0.0,
                    //                 color: Color(0xFFF2F2F2),
                    //                 padding: EdgeInsets.all(12.0),
                    //                 shape: RoundedRectangleBorder(
                    //                     borderRadius:
                    //                         BorderRadius.circular(8.0)),
                    //                 onPressed: () {
                    //                   Navigator.pushNamed(
                    //                       context, '/support_tab',
                    //                       arguments: _profileData);
                    //                 },
                    //                 child: Row(
                    //                   mainAxisAlignment:
                    //                       MainAxisAlignment.spaceBetween,
                    //                   children: <Widget>[
                    //                     Container(
                    //                       child: Row(
                    //                         children: <Widget>[
                    //                           Icon(
                    //                             Icons.help_outline,
                    //                             color: Color(0xFF371D32),
                    //                           ),
                    //                           SizedBox(width: 10),
                    //                           Text(
                    //                             'Support',
                    //                             style: TextStyle(
                    //                               fontFamily: 'Urbanist',
                    //                               fontSize: 16,
                    //                               color: Color(0xFF371D32),
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //                     ),
                    //                     Container(
                    //                       width: 16,
                    //                       child: Icon(
                    //                           Icons.keyboard_arrow_right,
                    //                           color: Color(0xFF353B50)),
                    //                     ),
                    //                   ],
                    //                 )),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    SizedBox(
                      height: 20,
                    ),

                    ///new logOut button//
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                // InkWell(
                                //   child: Text(
                                //     'Log Out',
                                //     style: TextStyle(
                                //       fontFamily: 'Urbanist',
                                //       fontSize: 16,
                                //       color: Color(0xFF371D32),
                                //       decoration: TextDecoration.underline,
                                //     ),
                                //   ),
                                //   onTap: () async {
                                //     // await storage.deleteAll();
                                //     Main.notificationCount.value = 0;
                                //     FlutterAppBadger.removeBadge();
                                //     //await storage.delete(key: 'count');
                                //     final prefs =
                                //         await SharedPreferences.getInstance();
                                //     await prefs.remove("count");
                                //     await storage.delete(key: 'profile_id');
                                //     await storage.delete(key: 'user_id');
                                //     await storage.delete(key: 'jwt');
                                //     //MixpanelUtil.resetMixpanel();
                                //     Navigator.pushNamed(
                                //         context, '/signin_ui');
                                //   },
                                // ),
                                Spacer(),
                                // InkWell(
                                //   child: Text(
                                //     'Delete RideAlike Account',
                                //     style: TextStyle(
                                //       fontFamily: 'Urbanist',
                                //       fontSize: 16,
                                //       color: Color(0xFF371D32),
                                //       decoration: TextDecoration.underline,
                                //     ),
                                //   ),
                                //   onTap: () {
                                //     showRemoveAccountDialog();
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        )
        // :  Container()
        // Column(
        //           mainAxisAlignment: MainAxisAlignment.center,
        //           children: [  SizedBox(
        //             height: 50,
        //           ),
        //             SizedBox(
        //               height: 120,
        //               width: MediaQuery.of(context).size.width,
        //               child: Shimmer.fromColors(
        //                   baseColor: Colors.grey.shade300,
        //                   highlightColor: Colors.grey.shade100,
        //                   child: Padding(
        //                     padding: const EdgeInsets.only(left: 12.0, right: 12),
        //                     child: Container(
        //                       decoration: BoxDecoration(
        //                           color: Colors.grey[300],
        //                           borderRadius: BorderRadius.circular(10)),
        //                     ),
        //                   )),
        //             ),
        //             SizedBox(
        //               height: 15,
        //             ),
        //
        //             SizedBox(
        //               height: 5,
        //             ),
        //             Row(
        //               children: [
        //                 SizedBox(
        //                   height: 20,
        //                   width: MediaQuery.of(context).size.width / 3,
        //                   child: Shimmer.fromColors(
        //                       baseColor: Colors.grey.shade300,
        //                       highlightColor: Colors.grey.shade100,
        //                       child: Padding(
        //                         padding: const EdgeInsets.only(left: 16.0, right: 16),
        //                         child: Container(
        //                           decoration: BoxDecoration(
        //                               color: Colors.grey[300],
        //                               borderRadius: BorderRadius.circular(10)),
        //                         ),
        //                       )),
        //                 ),
        //               ],
        //             ),
        //             SizedBox(
        //               height: 10,
        //             ),
        //             SizedBox(
        //               height: 250,
        //               width: MediaQuery.of(context).size.width,
        //               child: Shimmer.fromColors(
        //                   baseColor: Colors.grey.shade300,
        //                   highlightColor: Colors.grey.shade100,
        //                   child: Padding(
        //                     padding: const EdgeInsets.only(left: 16.0, right: 16),
        //                     child: Container(
        //                       decoration: BoxDecoration(
        //                           color: Colors.grey[300],
        //                           borderRadius: BorderRadius.circular(10)),
        //                     ),
        //                   )),
        //             ),
        //             SizedBox(
        //               height: 8,
        //             ),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 SizedBox(
        //                   height: 14,
        //                   width: MediaQuery.of(context).size.width / 2,
        //                   child: Shimmer.fromColors(
        //                       baseColor: Colors.grey.shade300,
        //                       highlightColor: Colors.grey.shade100,
        //                       child: Padding(
        //                         padding: const EdgeInsets.only(left: 16.0, right: 16),
        //                         child: Container(
        //                           decoration: BoxDecoration(
        //                               color: Colors.grey[300],
        //                               borderRadius: BorderRadius.circular(10)),
        //                         ),
        //                       )),
        //                 ),
        //                 // SizedBox(
        //                 //   height: 15,
        //                 //   width: MediaQuery.of(context).size.width / 4,
        //                 //   child: Shimmer.fromColors(
        //                 //       baseColor: Colors.grey.shade300,
        //                 //       highlightColor: Colors.grey.shade100,
        //                 //       child: Padding(
        //                 //         padding: const EdgeInsets.only(left: 16.0, right: 16),
        //                 //         child: Container(
        //                 //           decoration: BoxDecoration(
        //                 //               color: Colors.grey[300],
        //                 //               borderRadius: BorderRadius.circular(10)),
        //                 //         ),
        //                 //       )),
        //                 // ),
        //               ],
        //             ),
        //             SizedBox(
        //               height: 10,
        //             ),
        //             SizedBox(
        //               height: 250,
        //               width: MediaQuery.of(context).size.width,
        //               child: Shimmer.fromColors(
        //                   baseColor: Colors.grey.shade300,
        //                   highlightColor: Colors.grey.shade100,
        //                   child: Padding(
        //                     padding: const EdgeInsets.only(left: 16.0, right: 16),
        //                     child: Container(
        //                       decoration: BoxDecoration(
        //                           color: Colors.grey[300],
        //                           borderRadius: BorderRadius.circular(10)),
        //                     ),
        //                   )),
        //             ),
        //             SizedBox(
        //               height: 10,
        //             ),
        //             Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 SizedBox(
        //                   height: 14,
        //                   width: MediaQuery.of(context).size.width / 2,
        //                   child: Shimmer.fromColors(
        //                       baseColor: Colors.grey.shade300,
        //                       highlightColor: Colors.grey.shade100,
        //                       child: Padding(
        //                         padding: const EdgeInsets.only(left: 16.0, right: 16),
        //                         child: Container(
        //                           decoration: BoxDecoration(
        //                               color: Colors.grey[300],
        //                               borderRadius: BorderRadius.circular(10)),
        //                         ),
        //                       )),
        //                 ),
        //                 // SizedBox(
        //                 //   height: 15,
        //                 //   width: MediaQuery.of(context).size.width / 4,
        //                 //   child: Shimmer.fromColors(
        //                 //       baseColor: Colors.grey.shade300,
        //                 //       highlightColor: Colors.grey.shade100,
        //                 //       child: Padding(
        //                 //         padding: const EdgeInsets.only(left: 16.0, right: 16),
        //                 //         child: Container(
        //                 //           decoration: BoxDecoration(
        //                 //               color: Colors.grey[300],
        //                 //               borderRadius: BorderRadius.circular(10)),
        //                 //         ),
        //                 //       )),
        //                 // ),
        //               ],
        //             )
        //             ,],
        //         ),

        );
  }
}
