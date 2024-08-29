import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


final List<dynamic> _textList = [
  {
    "header": "Earn extra income",
    "body": "Listing your vehicle with RideAlike can easily earn you \$500 per month or more, helping manage your vehicle or other expenses. ""\nAnd we quickly deposit your earnings after each trip. See our FAQ for more information."
  },
  {
    "header": "List with confidence",
    "body": "When you list with RideAlike, you enjoy the comforts of knowing that RideAlike has reviews the driving history of all Guests to meet our standards, provides up to \$2MM insurance coverage and roadside assistance.  "
        "See our FAQ for more information."
  },
  {
    "header": "You stay in control",
    "body": "When you list with RideAlike, you set the pricing, rules for Guests, and your vehicle’s availability. And you can change your settings at any time."
  }
];

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
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build (BuildContext context) => new Scaffold(
    backgroundColor: Colors.white,

    appBar: new AppBar(
      leading: new Container(),
      actions: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () async {
                String? profileID = await storage.read(key: 'profile_id');

                if (profileID != null) {
                  Navigator.pushNamed(
                    context, 
                    '/what_will_happen_next'
                  );
                } else {
                  Navigator.pushNamed(
                    context,
                    '/create_profile_or_sign_in'
                  );
                }
              },
              child: Center(
                child: Container(
                  margin: EdgeInsets.only(right: 16),
                  child: Text('Skip',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xFFFF8F62),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
      elevation: 0.0,
    ),

    body: new SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(left: 16.0, right: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            // Slider
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Container(
                          decoration: new BoxDecoration(
                            color: Color(0xFFF2F2F2),
                            borderRadius: new BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 99.0, bottom: 99.0),
                            child: Icon(
                              Icons.image,
                              color: Color(0xFFABABAB),
                              size: 50.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                         height:  MediaQuery.of(context).size.width*0.60,
                        child: CarouselSlider(
                          // height:,
                          items: map<Widget>(_textList, (index, i) {
                            var container = Container(
                              width: MediaQuery.of(context).size.width*0.90,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(i['header'],
                                  // textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: Color(0xff371D32),
                                      fontSize: 36,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: Column(
                                      children: <Widget>[
                                        Flexible(
                                          child: AutoSizeText(i['body'],
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xff371D32),
                                            ),
                                            maxLines: 8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );

                            return container;
                            },
                          ).toList(),


                          options: CarouselOptions(
                            // onPageChanged: (index) {
                            //   setState(() {
                            //     _current = index;
                            //   });
                            // },
                            onPageChanged: (int index, CarouselPageChangedReason reason) {
                              setState(() {
                                _current = index;
                              });
                            },
                            autoPlay: true,
                            viewportFraction: 2.0,
                            enlargeCenterPage: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Container(
                          padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: map<Widget>(
                              _textList,
                              (index, url) {
                                return Container(
                                  width: 8.0,
                                  height: 8.0,
                                  margin: EdgeInsets.only(left: 4, right: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _current == index ? Color(0xffFF8F68) : Color(0xffE0E0E0)
                                  ),
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
      ),
    ),
  );
}