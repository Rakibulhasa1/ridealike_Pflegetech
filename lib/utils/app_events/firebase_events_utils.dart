import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseEventsUtils {
  // static final _firebaseAnalytics = FirebaseAnalytics();
  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
  FirebaseAnalyticsObserver(analytics: analytics);

  static void logEvent(String event, {Map<String, dynamic>? params}) {
    if (params != null) {
      analytics.logEvent(name: event, parameters: params);
    } else {
      analytics.logEvent(name: event);
    }
  }
}
