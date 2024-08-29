import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  @override
  Widget build (BuildContext context) => new Scaffold(
    body: new Container(
      //Here you can set what ever background color you need.
      // backgroundColor: Color(0xFF7CB7B6),
      decoration: new BoxDecoration(color: Color(0xFF7CB7B6)),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/create_profile_or_sign_in');
        },
        child: Center(
          child: new Text('Discover',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 36,
              color: Color(0xFF371D32),
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ),
    ),
  ) ;
  // @override
  // Widget build(BuildContext context) => GridView.count(
  //   primary: false,
  //   padding: const EdgeInsets.all(20),
  //   crossAxisSpacing: 10,
  //   mainAxisSpacing: 10,
  //   crossAxisCount: 3,
  //   children: <Widget>[
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/create_profile_or_sign_in');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.face,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Create profile or Sign in',
  //                 textAlign: TextAlign.center,
  //               )
  //             ]
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/profile');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.verified_user,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Profile',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/verify_phone_number');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.mobile_screen_share,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Verify phone number',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/introduce_yourself');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.perm_identity,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Introduce yourself',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ]
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/verify_email');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.mail,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Verify email',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/verify_security_code');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.security,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Verify security code',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/verification_in_progress');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.settings,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Verification in progress',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/create_profile');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.person_add,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Create a profile',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/list_your_car');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.directions_car,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('List your car',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/car_details');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.local_car_wash,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Car details',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/discover_swap');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.swap_horiz,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Discover swap',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/discover_rent');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.attach_money,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Discover rent',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //     GestureDetector(
  //       onTap: () {
  //         Navigator.of(context).pushNamed('/verify_identity');
  //       },
  //       child: Padding(
  //         padding: EdgeInsets.all(5.0),
  //         child: Card(
  //           color: Colors.blueGrey,
  //           child: new Column(
  //             crossAxisAlignment: CrossAxisAlignment.center,
  //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: <Widget>[
  //               new Icon(
  //                 Icons.attach_money,
  //                 size: 22.0,
  //                 color: Colors.black
  //               ),
  //               new Text('Verify identify',
  //                 textAlign: TextAlign.center,
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   ],
  // );


}
