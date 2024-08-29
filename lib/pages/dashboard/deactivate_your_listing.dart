import 'package:flutter/material.dart';

class DeactivateYourListing extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: new AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0.0,
    ),

    body: new SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: Container(
                          child: Text('Deactivate' '\n${'your listing'}',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 36,
                              color: Color(0xFF371D32),
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset('icons/List-a-Car_Whats-Next.png'),
              ],
            ),
            //texting//
            SizedBox(height: 20),
            Text('You can temporarily deactivate your listing and it will be removed from renting and/or swapping. If you have any confirmed future bookings, you may be charged a cancellation fee.',
              style: TextStyle(
                color: Color(0xff371D32),
                fontSize: 16,
                fontFamily: 'Urbanist'
              ), 
            ),
            SizedBox(height: 10),
            Text('To deactivate your listing, simply email our support team at hello@ridealike.com and provide the details of the vehicle you want deactivited (e.g. Year, Model and Make).',
                style: TextStyle(
                color: Color(0xff371D32),
                fontSize: 16,
                fontFamily: 'Urbanist'
              ),
            ),
           SizedBox(height: 30),
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
                         padding: EdgeInsets.all(16.0),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                         ),  onPressed: () {},
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: <Widget>[
                             Container(
                               child: Text('Contact with us',
                                 style: TextStyle(
                                   color: Color(0xff371D32),
                                   fontSize: 16,
                                   fontFamily: 'Urbanist'
                                 ),
                               ),
                             ),
                             Image.asset('icons/Message-3.png',
                               color: Color(0xff371D32)
                             )
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
                         padding: EdgeInsets.all(16.0),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                         ), onPressed: () {},
                         child: Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                           children: <Widget>[
                             Container(
                               child: Text('Call support',
                                 style: TextStyle(
                                   color: Color(0xff371D32),
                                   fontSize: 16,
                                   fontFamily: 'Urbanist'
                                 ),
                               ),
                             ),
                             Icon(
                               Icons.phone,
                               color: Color(0xff371D32)
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
          ],
        ),
      ),
    )
  );
}
