import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as notify;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:ridealike/libs/top_snackbar_flutter/lib/custom_snack_bar.dart';
import 'package:ridealike/main.dart' as Main;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/profile_by_user_ids_response.dart';
import 'package:ridealike/pages/trips/response_model/rent_agree_carinfo_response.dart';
import 'package:ridealike/pages/trips/response_model/swap_agree_carinfo_response.dart';

import '../libs/top_snackbar_flutter/lib/custom_snack_bar.dart';
import '../libs/top_snackbar_flutter/lib/top_snack_bar.dart';
import '../main.dart';

class PushNotifications {
  static FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static String _message = "";

  static final storage = new FlutterSecureStorage();
  static Trips? tripResponse;
  static Trips? swapTripResponse;

  //TODO
  static Future<String?> initNotification() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission(
            alert: true,
            announcement: false,
            badge: true,
            carPlay: false,
            criticalAlert: false,
            provisional: false,
            sound: true,
          );

      if (kDebugMode) {
            _messaging.subscribeToTopic("ridealike");
          }

      debugPrint('User granted permission: ${settings.authorizationStatus}');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            debugPrint('Got a message whilst in the foreground!');
            debugPrint('Message data: ${message.data}');

            if (message.notification != null) {
              debugPrint(
                  'Message also contained a notification: ${message.notification}');
              _showPushDialog(message.notification!);
            }
          });
      return await _messaging.getToken();
    } catch (e) {
      return null;
    }
  }

  static Future<RestApi.Resp> getTripByID(String tripID) async {
    var getTripByIDCompleter = Completer<RestApi.Resp>();
    RestApi.callAPI(getTripByIDUrl, json.encode({"TripID": tripID}))
        .then((resp) {
      getTripByIDCompleter.complete(resp);
    });

    return getTripByIDCompleter.future;
  }

  static Future<RestApi.Resp> getProfileByID(String userID) async {
    var getTripByIDCompleter = Completer<RestApi.Resp>();
    RestApi.callAPI(getProfileByUserIDUrl, json.encode({"UserID": userID}))
        .then((resp) {
      getTripByIDCompleter.complete(resp);
    });

    return getTripByIDCompleter.future;
  }

  static Future<Resp> getRentAgreementId(rentAgreementID, userId) async {
    var rentAgreementIdCompleter = Completer<Resp>();
    callAPI(getRentAgreementUrl,
            json.encode({"RentAgreementID": rentAgreementID, "UserID": userId}))
        .then((resp) {
      rentAgreementIdCompleter.complete(resp);
    });
    return rentAgreementIdCompleter.future;
  }

  static Future<Resp> getSwapAgreementId(swapAgreementID, userId) async {
    var rentAgreementIdCompleter = Completer<Resp>();
    callAPI(getSwapArgeementTermsUrl,
            json.encode({"SwapAgreementID": swapAgreementID, "UserID": userId}))
        .then((resp) {
      rentAgreementIdCompleter.complete(resp);
    });
    return rentAgreementIdCompleter.future;
  }

  static Future<void> getTripCarProfileInfo(String tripID) async {
    String? userID = await storage.read(key: 'user_id');
    var tripResp = await getTripByID(tripID);
    if (tripResp != null) {
      tripResponse = Trips.fromJson(json.decode(tripResp.body!)['Trip']);
      tripResponse?.userID = userID!;
    }

    var profileResponse = await getProfileByID(tripResponse!.guestUserID!);
    if (profileResponse != null) {
      tripResponse?.guestProfile =
          Profiles.fromJson(json.decode(profileResponse.body!)['Profile']);
    }

    var hostProfileResponse = await getProfileByID(tripResponse!.hostUserID!);
    if (hostProfileResponse != null) {
      tripResponse!.hostProfile =
          Profiles.fromJson(json.decode(hostProfileResponse.body!)['Profile']);
    }
    if (tripResponse!.tripType != 'Swap') {
      var rentAgreement =
          await getRentAgreementId(tripResponse?.rentAgreementID, userID);
      RentAgreementCarInfoResponse rentAgreementCarInfoResponse;
      if (rentAgreement != null && rentAgreement.statusCode == 200) {
        rentAgreementCarInfoResponse = RentAgreementCarInfoResponse.fromJson(
            json.decode(rentAgreement.body!));
        tripResponse!.car = rentAgreementCarInfoResponse.rentAgreement!.car;
        tripResponse!.carName =
            rentAgreementCarInfoResponse.rentAgreement!.car!.name;
        tripResponse!.carImageId = rentAgreementCarInfoResponse
            .rentAgreement!.car!.imagesAndDocuments!.images!.mainImageID;
        tripResponse!.carLicense = rentAgreementCarInfoResponse
            .rentAgreement!.car!.imagesAndDocuments!.license!.plateNumber;
        tripResponse!.carYear =
            rentAgreementCarInfoResponse.rentAgreement!.car!.about!.year;
      }
      print("*************************88-================");
    } else {
      var swapTripResp =
          await getTripByID(tripResponse!.swapData!.otherTripID!);
      swapTripResponse =
          Trips.fromJson(json.decode(swapTripResp.body!)['Trip']);
      var swapTripAgreement =
          await getSwapAgreementId(swapTripResponse!.swapAgreementID, userID);
      SwapAgreementCarInfoResponse swapAgreementCarInfoResponse;
      if (swapTripAgreement != null && swapTripAgreement.statusCode == 200) {
        swapAgreementCarInfoResponse = SwapAgreementCarInfoResponse.fromJson(
            json.decode(swapTripAgreement.body!));
        tripResponse!.car =
            swapAgreementCarInfoResponse.swapAgreementTerms!.theirCar;
        tripResponse!.myCarForSwap =
            swapAgreementCarInfoResponse.swapAgreementTerms!.myCar;
        swapTripResponse!.car =
            swapAgreementCarInfoResponse.swapAgreementTerms!.myCar;
        swapTripResponse!.myCarForSwap =
            swapAgreementCarInfoResponse.swapAgreementTerms!.theirCar;
      }
    }
    String tripStatusPeriod = '';
    //TripUndefined, Booked, Cancelled, Started, Ended, Completed
    if (tripResponse!.tripStatus == 'Booked') {
      tripStatusPeriod = 'Upcoming';
    } else if (tripResponse!.tripStatus == 'Started') {
      tripStatusPeriod = 'Current';
    } else {
      tripStatusPeriod = 'Past';
    }
    if (tripResponse!.tripStatus == 'Cancelled') {
      Navigator.pushNamed(Main.scaffoldKey.currentContext!,
          '/trips_cancelled_details_notification',
          arguments: {'trip': tripResponse, 'backPressPop': true});
    } else if (tripResponse!.tripStatus == 'Cancelled' &&
        tripResponse!.tripType == 'Swap') {
      Navigator.pushNamed(Main.scaffoldKey.currentContext!,
          '/trips_cancelled_details_notification',
          arguments: {'trip': tripResponse, 'backPressPop': true});
    } else if (tripResponse!.tripType == 'Swap') {
      Navigator.pushNamed(
        Main.scaffoldKey.currentContext!,
        '/trips_rental_details_ui',
        arguments: {
          'tripType': tripStatusPeriod,
          'trip': tripResponse,
          'backPressPop': true
        },
      );
    } else if (tripResponse!.guestUserID == tripResponse!.userID) {
      Navigator.pushNamed(
        Main.scaffoldKey.currentContext!,
        '/trips_rental_details_ui',
        arguments: {
          'tripType': tripStatusPeriod,
          'trip': tripResponse,
          'backPressPop': true
        },
      );
    } else if (tripResponse!.hostUserID == tripResponse!.userID) {
      Navigator.pushNamed(
          Main.scaffoldKey.currentContext!, '/trips_rent_out_details_ui',
          arguments: {
            'tripType': tripStatusPeriod,
            'trip': tripResponse,
            'backPressPop': true
          });
    }
  }

  static notify.FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      notify.FlutterLocalNotificationsPlugin();

  /*static Future<String> setupFirebase() {
    var completer = Completer<String>();
    Future.delayed(Duration(seconds: 0), () {
      print("firebase setup start");
      eventBus.on<PushEvent>().listen((event) {
        if (NavigationService.navigationKey.currentState!.mounted) {
          print("events:::${event.data}");
          _showPushDialog(event.data);
        }
      });
      //TODO ONLY FOR TEST DO NOT MERGE
      //_fcm.subscribeToTopic("ridealike");
      //
      print("firebase setup done");
    });

    return completer.future;
  }*/

  static void _showPushDialog(RemoteNotification message) {
    print("_showPushDialog:::$message");
    var data = message;

    if (data.body == _message) {
      return;
    }

    _message = data.body!;
    showTopSnackBar(
      Overlay.of(scaffoldKey.currentContext!),
      CustomSnackBar.show(
        title: data.title,
        message: data.body,
        icon: Image.asset("images/Logo.png"),
      ),
    );
  }

  static Future<void> _handleNotification(
      Map<dynamic, dynamic> message, bool dialog, String tripInfo) async {
    var data = message['notification'];
    var _tripInfo = message['data']['trip'];
    if (dialog) {
      print("open notification");
    } else {
      //TODO
      _showNotification(data['title'], data['body'], _tripInfo);
    }
  }

  //TODO
  static Future _showNotification(
      String title, String body, String tripInfo) async {
    var initializationSettingsAndroid =
        notify.AndroidInitializationSettings('launcher_icon');
    var initializationSettingsIOS = notify.IOSInitializationSettings();
    var initializationSettings = new notify.InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      //onSelectNotification: onSelectNotification
    );
    var notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();

    var androidPlatformChannelSpecifics = notify.AndroidNotificationDetails(
      'ridealike_channel',
      'RideAlike',
      'RideAlike Notification Service',
      importance: notify.Importance.max,
      priority: notify.Priority.high,
      playSound: true,
      enableLights: true,
      ticker: 'RideAlike Notification',
      sound: notify.RawResourceAndroidNotificationSound("notification"),
    );

    print(
        "notification details${androidPlatformChannelSpecifics.additionalFlags}");
    print("notification details${androidPlatformChannelSpecifics.category}");
    print("notification details${androidPlatformChannelSpecifics.channelId}");
    print("notification details${androidPlatformChannelSpecifics.channelName}");
    print(
        "notification details${androidPlatformChannelSpecifics.channelAction}");
    var iOSPlatformChannelSpecifics = notify.IOSNotificationDetails(
        presentSound: true, presentBadge: true, presentAlert: true);
    var platformChannelSpecifics = notify.NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: tripInfo,
    );
  }

  static Future? onSelectNotification(payload) {
    print("onNotoficationClick$payload");
    try {
      var _tripInfo = jsonDecode(payload);
      print("onNotoficationClick${_tripInfo['Trip']['TripID']}");
      getTripCarProfileInfo(_tripInfo['Trip']['TripID']);
    } catch (e) {
      print("$e from notification");
    }
  }
}
