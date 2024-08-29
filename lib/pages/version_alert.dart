import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:url_launcher/url_launcher.dart';

// import 'package:open_appstore/open_appstore.dart';

import '../main.dart';

class VersionAlert extends StatefulWidget {
  const VersionAlert({Key? key}) : super(key: key);

  @override
  State<VersionAlert> createState() => _VersionAlertState();
}

class _VersionAlertState extends State<VersionAlert> {
  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {

    onBackPressed();
    return true;
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    BackButtonInterceptor.add(myInterceptor);
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Text("Alert!"),
            content: Text("Please update RideAlike app to continue."),
            actions: [
              ElevatedButton(
                child: Text("Update"),
                onPressed: () {
                  _launchAppStore();
                  // OpenAppstore.launch(
                  //     androidAppId: "com.ridealike.app",
                  //     iOSAppId: "1571154008");
                },
              ),
              ElevatedButton(
                child: Text("Cancel"),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        },
      );
    });
  }

  void _launchAppStore() async {
    // Replace the URLs with the actual URLs for your app on the respective app stores
    final androidUrl = "https://play.google.com/store/apps/details?id=com.ridealike.app";
    final iOSUrl = "https://apps.apple.com/app/id1571154008";

    if (await canLaunch(androidUrl)) {
      await launch(androidUrl);
    } else if (await canLaunch(iOSUrl)) {
      await launch(iOSUrl);
    } else {
      // Handle the case where the URLs cannot be launched
      print("Could not launch app store.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(),
    );
  }
}
