import 'dart:async';
import 'dart:convert' show json;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/profile/response_service/notification_settings_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/shimmer.dart';

Future<RestApi.Resp> fetchNotificationSettings(_userID) async {
  final completer=Completer<RestApi.Resp>();
  RestApi.callAPI(getNotificationSettingUrl,
    json.encode(
      {
        "UserID": _userID,
      }
  ),).then((resp){
    completer.complete(resp);
  });
  return completer.future;
}

class NotificationSettings extends StatefulWidget {
  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  String _userID = '';
  final storage = new FlutterSecureStorage();
  NotificationSettingsResponse? notificationSettingsResponse;


  var headingTextStyle= TextStyle(
      color: Color(0xff371D32),
      fontFamily: 'Urbanist',
      fontSize: 18
  );

  var textStyle = TextStyle(
    fontFamily: 'Urbanist',
    color: Color(0xff371D32),
    fontSize: 16,
  );

  var textDetailsStyle= TextStyle(
      color: Color(0xff371D32),
      fontFamily: 'Urbanist',
      fontSize: 16,
  );

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Notification Settings"});
    getNotiSettings();
  }

  getNotiSettings() async {
    String? userID = await storage.read(key: 'user_id');

    if (userID != null) {
      var res = await fetchNotificationSettings(userID);

      setState(() {
        _userID = userID;
        notificationSettingsResponse= NotificationSettingsResponse.fromJson(json.decode(res.body!));
      });
      print(notificationSettingsResponse!.notificationSetting);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: new AppBar(
        centerTitle: true,
        title: Text('Notification settings',
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

      body: notificationSettingsResponse!=null && notificationSettingsResponse!.notificationSetting != null ?

      Container(
          color: Color(0xffFFFFFF),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Messages (At least 1 required)',
                      style:
                      headingTextStyle,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'Receive notifications of messages from other users or RideAlike',
                      style: textDetailsStyle
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                                  Text('Push notifications', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value: notificationSettingsResponse!.notificationSetting!.messages!.push!,
                                onChanged: disableMessage()==1 &&  notificationSettingsResponse!.notificationSetting!.messages!.push! ? null: (value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.messages!.push= value;
                                    print('push$value');
                                  });
                                  setNotiSettings(notificationSettingsResponse! , _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Email (recommended)', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value:notificationSettingsResponse!.notificationSetting!.messages!.email!,
                                onChanged: disableMessage()==1 &&  notificationSettingsResponse!.notificationSetting!.messages!.email! ? null:(value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.messages!.email = value;
                                  });
                                  setNotiSettings( notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Text', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value:  notificationSettingsResponse!.notificationSetting!.messages!.text!,
                                onChanged: disableMessage()==1 &&  notificationSettingsResponse!.notificationSetting!.messages!.text! ? null:(value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.messages!.text = value;
                                  });
                                  setNotiSettings(notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32,),
                    Text('Reminders (At least 1 required)',
                        style: headingTextStyle),
                    SizedBox(height: 15,),
                    Text('Receive notification reminders about the start and end of your trips',style: textDetailsStyle,),
                    SizedBox(height: 15,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Push notifications', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value: notificationSettingsResponse!.notificationSetting!.reminders!.push!,
                                onChanged: disableReminder()==1 &&  notificationSettingsResponse!.notificationSetting!.reminders!.push! ? null: (value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.reminders!.push= value;
                                  });
                                  setNotiSettings(notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Email (recommended)', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value: notificationSettingsResponse!.notificationSetting!.reminders!.email!,
                                onChanged: disableReminder()==1 &&  notificationSettingsResponse!.notificationSetting!.reminders!.email! ? null: (value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.reminders!.email= value;
                                  });
                                  setNotiSettings(notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Text', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value: notificationSettingsResponse!.notificationSetting!.reminders!.text!,
                                onChanged:disableReminder()==1 &&  notificationSettingsResponse!.notificationSetting!.reminders!.text! ? null:  (value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.reminders!.text= value;
                                  });
                                  setNotiSettings(notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32,),
                    Text('Product updates, promotions and tips',style: headingTextStyle),
                    SizedBox(height: 15,),
                    Text('Receive notifications about promotions and tips from RideAlike',style: textDetailsStyle,),
                    SizedBox(height:15,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Push notifications', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value: notificationSettingsResponse!.notificationSetting!.productsPromotions!.push!,
                                onChanged: (value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.productsPromotions!.push= value;
                                  });
                                  setNotiSettings(notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Email', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value: notificationSettingsResponse!.notificationSetting!.productsPromotions!.email!,
                                onChanged: (value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.productsPromotions!.email= value;
                                  });
                                  setNotiSettings(notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Text', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value:  notificationSettingsResponse!.notificationSetting!.productsPromotions!.text!,
                                onChanged: (value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.productsPromotions!.text= value;
                                  });
                                  setNotiSettings(notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32,),
                    Text('Profile support',style: headingTextStyle),
                    SizedBox(height: 15,),
                    Text('Anything related to customer support, legal matters, etc.',style: textDetailsStyle,),
                    SizedBox(height:15,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Push notifications', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value: notificationSettingsResponse!.notificationSetting!.profileSupport!.push!,
                                onChanged: (value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.profileSupport!.push = value;
                                  });
                                  setNotiSettings(notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                           color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Email', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value:   notificationSettingsResponse!.notificationSetting!.profileSupport!.email!,
                                onChanged: (value) {
                            setState(() {
                              notificationSettingsResponse!.notificationSetting!.profileSupport!.email = value;
                            });
                            setNotiSettings(notificationSettingsResponse!, _userID);
                            },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    SizedBox(
                      width: double.maxFinite,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Color(0xffF2F2F2),
                            borderRadius: BorderRadius.circular(8),
                            shape: BoxShape.rectangle),
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child:
                              Text('Text', style: textStyle),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: CupertinoSwitch(
                                activeColor: Color(0xffFF8F62),
                                trackColor: Color(0xff353B50),
                                value: notificationSettingsResponse!.notificationSetting!.profileSupport!.text!,
                                onChanged: (value) {
                                  setState(() {
                                    notificationSettingsResponse!.notificationSetting!.profileSupport!.text= value;
                                  });
                                  setNotiSettings(notificationSettingsResponse!, _userID);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32,)
                  ],
                ),
              ),
            ),
          )
        ) : Center(
        child: ShimmerEffect()

    ));
  }
  int disableMessage(){
    return (notificationSettingsResponse!.notificationSetting!.messages!.push! ?1:0) + (notificationSettingsResponse!.notificationSetting!.messages!.text!?1:0) +(notificationSettingsResponse!.notificationSetting!.messages!.email!?1:0);
  }
  int disableReminder(){
    return (notificationSettingsResponse!.notificationSetting!.reminders!.push! ?1:0) + (notificationSettingsResponse!.notificationSetting!.reminders!.text!?1:0) +(notificationSettingsResponse!.notificationSetting!.reminders!.email!?1:0);
  }
}

Future<RestApi.Resp> setNotiSettings(NotificationSettingsResponse notificationSettingsResponse, userID) async {
  final completer=Completer<RestApi.Resp>();
  RestApi.callAPI(setNotificationSettingUrl,
    json.encode(
      {
        "NotificationSetting": {
          "UserID": userID,
          "Messages": {
            "Push": notificationSettingsResponse!.notificationSetting!.messages!.push,
            "Email": notificationSettingsResponse!.notificationSetting!.messages!.email,
            "Text": notificationSettingsResponse!.notificationSetting!.messages!.text
          },
          "Reminders": {
            "Push": notificationSettingsResponse!.notificationSetting!.reminders!.push,
            "Email": notificationSettingsResponse!.notificationSetting!.reminders!.email,
            "Text": notificationSettingsResponse!.notificationSetting!.reminders!.text
          },
          "ProductsPromotions": {
            "Push":notificationSettingsResponse!.notificationSetting!.productsPromotions!.push,
            "Email": notificationSettingsResponse!.notificationSetting!.productsPromotions!.email,
            "Text": notificationSettingsResponse!.notificationSetting!.productsPromotions!.text
          },
          "ProfileSupport": {
            "Push": notificationSettingsResponse!.notificationSetting!.profileSupport!.push,
            "Email": notificationSettingsResponse!.notificationSetting!.profileSupport!.email,
            "Text":notificationSettingsResponse!.notificationSetting!.profileSupport!.text
          }
        }
      }
  ),).then((resp){
    //TODO params
    AppEventsUtils.logEvent("notification_settings_updated");
    completer.complete(resp);
  });
  return completer.future;
}
