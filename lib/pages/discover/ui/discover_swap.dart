import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/discover/bloc/discover_bloc.dart';
import 'package:ridealike/pages/swap/swap_guest.dart';
import 'package:ridealike/pages/swap/swap_logged_in.dart';

import '../../../utils/app_events/app_events_utils.dart';

class DiscoverSwap extends StatefulWidget {
  @override
  _DiscoverSwapState createState() => _DiscoverSwapState();
}

class _DiscoverSwapState extends State<DiscoverSwap> {
   bool? _loggedIn;
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Discover Swap"});
    checkLoginStatus();
  }

  checkLoginStatus() async {
    String? userID = await storage.read(key: 'user_id');
    if (userID != null) {
      setState(() {
        _loggedIn = true;
      });
    } else {
      setState(() {
        _loggedIn = false;
      });
    }
  }
  final discoverBloc = DiscoverBloc();
  FocusNode _damageDesctiptionfocusNode = FocusNode();
  bool _swapSettingsEnabled = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        actions: [
          Visibility(
            visible: _swapSettingsEnabled,
            child: Container(
              margin: EdgeInsets.only(right: 15, top: 4),
              height: 38,
              width: 38,
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/swap_preferences_tab');
                },
                child: Icon(
                  Icons.settings,
                  color: Color(0xff371D32),
                ),
                backgroundColor: Color(0xffFFFFFF),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(child:
                _loggedIn != null
                    ? _loggedIn!
                    ? SwapLoggedIn()
                    : SwapGuest()
                    : Container()
            ),
          ],
        ),
      ),
    );


    // return SwapGuest();
  }
}
