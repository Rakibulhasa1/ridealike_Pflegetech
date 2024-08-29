import 'package:url_launcher/url_launcher.dart';

class UrlLauncher{
  static void launchUrl(String url) async {
    if (await canLaunch(url) !=null) {
      launch(url);
    } else {
      throw "Could not launch $url";
    }
  }
}