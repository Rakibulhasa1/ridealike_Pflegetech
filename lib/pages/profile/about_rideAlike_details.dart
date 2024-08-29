import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/profile/policy_page.dart';
import 'package:ridealike/widgets/profile_page_block.dart';
import 'package:url_launcher/url_launcher.dart';
class AboutRideAlikeDetails extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xffFF8F68),
        ),
        centerTitle: true,
        title: Text('About RideAlike ',
          style: TextStyle(
              color: Color(0xff371D32), fontSize: 20, fontFamily: 'Urbanist'),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: 
          Column(
            children: [
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xFFF2F2F2),
                            padding: EdgeInsets.all(12.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),

                          ),
                         onPressed: () {
                            // Navigator.pushNamed(context, '/profile_faqs_tab',);
                            launchUrl(faqUrl);
                          },
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(children: [
                                  Image.asset('icons/Info.png'),
                                  SizedBox(width: 10),
                                  Text(
                                    'FAQs',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Color(0xFF371D32),
                                    ),
                                  ),
                                ]),
                              ),
                              Container(
                                width: 16,
                                child: Icon(Icons.keyboard_arrow_right,
                                    color: Color(0xFF353B50)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            // Refer a Friend
            ProfilePageBlock(text: 'Refer-a-Friend',
              iconData: Icons.emoji_people,
              onPressed: (){
              launchUrl(referAFriend);
              },),
            SizedBox(height: 10),

            // Blog
            ProfilePageBlock(text: 'Blog',
              iconData: Icons.description,
              onPressed: (){
              launchUrl(blogUrl);
              },),
            SizedBox(height: 10),

            // Policies
            ProfilePageBlock(text: 'Policies & Insurance',
                iconData: Icons.policy,
                onPressed:  (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => PolicyPage(),
                  ));
                }
            ),
            SizedBox(height: 10),
          ],

          ),
        ),),);

  }

}


void launchUrl(String url) async {
  if (await canLaunch(url)) {
    launch(url);
  } else {
    throw "Could not launch $url";
  }
}