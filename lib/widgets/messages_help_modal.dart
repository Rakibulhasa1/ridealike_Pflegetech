import 'package:flutter/material.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
bool buttonPressed=false;
class MessagesHelpModal extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      body: Container(height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black38,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 32.0),
              width: 280,
              height: MediaQuery.of(context).size.height / 1.6,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        spreadRadius: 0.5,
                        blurRadius: 17,
                        offset: Offset(0.0, 17.0)
                    )
                  ]
              ),
              child: Column(

                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0,bottom: 10),
                    child: Image(
                      image: AssetImage('icons/Get-Help.png'),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0,bottom: 15),
                    child: Center(
                      child: Text("Get help",
                        style: TextStyle(
                            fontFamily: 'SF Pro Display Bold',
                            fontSize: 24,
                            color: Color(0xff371D32)
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: Text(
                        'Have questions? See FAQs or contact support. We’ll be glad to help you!',
                        style: TextStyle(
                            fontFamily: 'Open Sans Regular',
                            fontSize: 16,
                            color: Color(0xff353B50)
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height*.10,
                      decoration: BoxDecoration(
                        color: Color(0xffF2F2F2),
                        borderRadius: new BorderRadius.circular(8.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(

                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('See FAQs',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 18,
                                  color: Color(0xff371D32)
                              ),
                            ),
                            Icon(Icons.live_help,color: Color(0xff371D32),)


                          ],),
                      ),
                    ),
                  )
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(onTap: (){
              Navigator.pop(context);
            },
              child: Text('Cancel', style: TextStyle(
                  fontFamily: 'Open Sans Regular',
                  fontSize: 14,
                  color: Color(0xffFFFFFF)
              ), ),
            ),
          ),
        ],),
      ),
    );
  }
}