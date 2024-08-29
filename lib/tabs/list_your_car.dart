import 'dart:convert' show json;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/utils/size_config.dart';

import '../utils/app_events/app_events_utils.dart';

Future<http.Response> fetchListCarBanner() async {
  final response = await http.post(
    Uri.parse(getListCarBannerUrl), // Parse the string to Uri
    body: json.encode({}),
  );

  if (response.statusCode == 200) {
    return response;
  } else {
    throw Exception('Failed to load data');
  }
}

// Future<http.Response> fetchListCarBanner() async {
//   final response = await http.post(
//     getListCarBannerUrl as Uri,
//     body: json.encode({}),
//   );
//
//   if (response.statusCode == 200) {
//     return response;
//   } else {
//     throw Exception('Failed to load data');
//   }
// }

List<T> map<T>(List list, Function handler) {
  List<T> result = [];
  for (var i = 0; i < list.length; i++) {
    result.add(handler(i, list[i]));
  }

  return result;
}

class ListYourCar extends StatefulWidget {
  @override
  _ListYourCarState createState() => _ListYourCarState();
}

class _ListYourCarState extends State<ListYourCar> {
  int _current = 0;

  bool _loggedIn = false;

  List _banners = [];
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "List Your Car"});
    _fetchBanners();
  }

  _fetchBanners() async {
    var res = await fetchListCarBanner();

    setState(() {
      _banners = json.decode(res.body!)['ImageIDs'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _banners.length > 0
          ? SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                // Slider
                CarouselSlider(

                  items: map<Widget>(
                    _banners,
                        (index, i) {
                      var container = Container(
                        height:
                        MediaQuery.of(context).size.height *
                            .70,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          children: <Widget>[
                            Container(
                              child: i['ImageID'] != null &&
                                  i['ImageID'] != ''
                                  ? ClipRRect(
                                child: Image(
                                  image: NetworkImage(
                                      '$storageServerUrl/${i['ImageID']}'),
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                BorderRadius.circular(
                                    12),
                              )
                                  : Icon(
                                Icons.image,
                                color: Color(0xFFABABAB),
                                size: 50.0,
                              ),
                              height: 200,
                              width: MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.9,
                            ),
                            SizedBox(
                              height: 15,
                            ),

                            SizedBox(
                              width: MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.9,
                              child: AutoSizeText(
                                i['Title'],
                                style: TextStyle(
                                    color: Color(0xff371D32),
                                    fontSize: 30,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.bold),
                                maxFontSize: 30,
                                minFontSize: 20,
                                stepGranularity: 1,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 10),

                            SizedBox(
                              child: AutoSizeText(
                                '${i['SubTitle']}',
                                style: TextStyle(
                                  fontFamily:
                                  'Urbanist',
                                  fontSize: 16,
                                  color:
                                  Color(0xff371D32),
                                ),
                                maxFontSize: 20,
                                minFontSize: 10,
                                stepGranularity: 1,
                                maxLines: 7,
                                overflow: TextOverflow.ellipsis,
                              ),
                              width:
                              MediaQuery.of(context)
                                  .size
                                  .width *
                                  0.9,
                            ),
                          ],
                        ),
                      );
                      return container;
                    },
                  ).toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    height:
                    MediaQuery.of(context).size.height * .70,
                    autoPlayInterval:Duration(seconds: 6),
                    viewportFraction: 2.0,
                    enlargeCenterPage: true,
                    onPageChanged: (index, CarouselPageChangedReason reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),

                ),
                Container(
                  margin: EdgeInsets.only(left: 15, right: 15),
                  width: SizeConfig.deviceWidth,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0.0,
                      backgroundColor: Color(0xffFF8F68),
                      padding: EdgeInsets.all(10.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),

                    ),
                     onPressed: () async {
                      String? profileID = await storage.read(key: 'profile_id');

                      if (profileID != null) {
                        setState(() {
                          _loggedIn = true;
                        });
                      } else {
                        setState(() {
                          _loggedIn = false;
                        });
                      }

                      if (_loggedIn) {
                        Navigator.pushNamed(context, '/what_will_happen_next_ui');
                      } else {
                        Navigator.pushNamed(context, '/create_profile_or_sign_in');
                      }
                    },
                    child: Text('Start Earning',
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 18,
                          color: Colors.white
                      ),
                    ),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              padding:
                                  EdgeInsets.only(top: 16.0, bottom: 16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: map<Widget>(
                                  _banners,
                                  (index, url) {
                                    return Container(
                                      width: 8.0,
                                      height: 8.0,
                                      margin:
                                          EdgeInsets.only(left: 4, right: 4),
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: _current == index
                                              ? Color(0xffFF8F68)
                                              : Color(0xffE0E0E0)),
                                    );
                                  },
                                ),
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
          )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[new CircularProgressIndicator()],
              ),
            ),
    );
  }
}
