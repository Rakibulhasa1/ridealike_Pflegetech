import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:url_launcher/url_launcher.dart';
Map? profileData;
class SupportDetails extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    profileData = ModalRoute.of(context)!.settings.arguments as Map;
    print('receData$profileData');
   return Scaffold(
      appBar: AppBar(
     iconTheme: IconThemeData(
       color: Color(0xffFF8F68),
     ),
     centerTitle: true,
     title: Text('Support',
       style: TextStyle(
           color: Color(0xff371D32), fontSize: 20, fontFamily: 'Urbanist'),
     ),
   ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
                                  borderRadius:
                                  BorderRadius.circular(8.0)),

                            ),
                               onPressed: () {
                                launchUrl(contactUsUrl);
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.help,color: Color(0xFF371D32),),
                                        SizedBox(width: 10),
                                        Text(
                                          'Contact Us',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    child: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Color(0xFF353B50)),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              ///Feedback
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
                              Navigator.pushNamed(
                                  context, '/profile_feedback_tab',
                                  arguments: profileData);
                            },
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Image.asset('icons/Mail.png'),
                                      SizedBox(width: 10),
                                      Text(
                                        'Give us feedback',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ],
                                  ),
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
              SizedBox(height: 10,),
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
                                  borderRadius:
                                  BorderRadius.circular(8.0)),

                            ),
                                 onPressed: () {
                                Navigator.pushNamed(context, '/submit_claim');
                              },
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Icon(Icons.note_add,color: Color(0xFF371D32),),
                                        SizedBox(width: 10),
                                        Text(
                                          'Submit A Claim',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 16,
                                    child: Icon(
                                        Icons.keyboard_arrow_right,
                                        color: Color(0xFF353B50)),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

           ],),
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