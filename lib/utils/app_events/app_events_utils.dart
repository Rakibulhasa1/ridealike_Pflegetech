import 'package:ridealike/utils/app_events/mixpanel_util.dart';

class AppEventsUtils {
  static Future<void>? init() {
    MixpanelUtil.initMixpanel();
    //FacebookAppEventsUtils.init();
    return null;
  }

  static void logEvent(String event, { Map<String, dynamic>? params}) {
    print(":::" + event + ":::");
    print(":::" + params.toString() + ":::");
    try {
      if (params != null) {
        MixpanelUtil.logEvent(event, properties: params);
      } else {
        MixpanelUtil.logEvent(event);
      }
    } catch (e) {
      print(e);
    }
  }
}
