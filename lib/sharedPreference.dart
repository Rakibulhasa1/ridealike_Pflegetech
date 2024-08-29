import 'package:shared_preferences/shared_preferences.dart';

setPref(String key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}

Future<String?> getPref(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getString(key);
}

removePref(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}