import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:ridealike/pages/common/constant_url.dart';

class MixpanelUtil {
  static Mixpanel? _mixpanel;
  static final _storage = FlutterSecureStorage();

  static Future<void> initMixpanel() async {
    _mixpanel = await Mixpanel.init(mixpanelToken,
        optOutTrackingDefault: false, trackAutomaticEvents: true);
  }

  static Future<void> resetMixpanel() async {
    _mixpanel!.reset();
  }

  static Future<void> logEvent(String event,
      {Map<String, dynamic>? properties}) async {
    if (_mixpanel != null) {
      if (properties == null) {
        properties = Map<String, dynamic>();
      }
      properties["time_date"] = _formatLogDateTime(DateTime.now().toIso8601String());
      if (Platform.isIOS) {
        properties["channel"] = "iOS";
      } else {
        properties["channel"] = "Android";
      }
      var userId = await _storage.read(key: 'user_id');
      var profileId = await _storage.read(key: 'profile_id');
      if (userId != null && profileId != null) {
        properties["ridealike_user_id"] = userId;
        properties["ridealike_profile_id"] = profileId;
      }
      _mixpanel!.track(event, properties: properties);
    }
  }

  static String _formatLogDateTime(String date) {
    DateFormat inputFormat = DateFormat("yyyy-MM-ddTHH:mm:ssZ");
    DateTime dateTime = inputFormat.parse(date);
    DateFormat outputFormat = DateFormat("hh:mm a - MMM d - yyyy");
    String dateInString = outputFormat.format(dateTime);
    return dateInString;
  }
}
