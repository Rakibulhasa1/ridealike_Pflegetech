// import 'package:flutter/material.dart';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json, base64, ascii;
//
// // const SERVER_IP = 'http://192.168.1.167:5000';
//
// class Profile extends StatelessWidget {
//   Profile(this.jwt, this.payload);
//
//   factory Profile.fromBase64(String jwt) =>
//     Profile(
//       jwt,
//       json.decode(
//         ascii.decode(
//           base64.decode(base64.normalize(jwt.split(".")[1]))
//         )
//       )
//     );
//
//   final String jwt;
//   final Map<String, dynamic> payload;
//
//   @override
//   Widget build (BuildContext context) => new Scaffold(
//
//     //App Bar
//     appBar: new AppBar(
//       title: new Text(
//         'Profile',
//         style: new TextStyle(
//           fontSize: Theme.of(context).platform == TargetPlatform.iOS ? 17.0 : 20.0,
//         ),
//       ),
//       elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 4.0,
//     ),
//
//     //Content of tabs
//     body: new PageView(
//       children: <Widget>[
//         Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             children: <Widget>[
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Card(
//                             color: Color(0xFFF2F2F2),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5)),
//                             child: Padding(
//                               padding: EdgeInsets.all(16.0),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: <Widget>[
//                                   Column(
//                                     children: <Widget>[
//                                       Center(
//                                         child: CircleAvatar(
//                                           backgroundImage: AssetImage('images/user.jpg'),
//                                         )
//                                       )
//                                     ],
//                                   ),
//                                   SizedBox(width: 10),
//                                   Column(
//                                     children: <Widget>[
//                                       Text('John Doe',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold
//                                         ),
//                                       ),
//                                       Text('Verification in progress',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                         ),
//                                       )
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//
//               SizedBox(height: 15),
//
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             color: Color(0xFFF2F2F2),
//                             textColor: Color(0xFF3C2235),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5)),
//                             onPressed: () {
//
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.mail, color: Color(0xFF3C2235)),
//                                       SizedBox(width: 10),
//                                       Text('Verify your email',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(Icons.brightness_1, color: Color(0xFFFF5B57)),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 15),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             color: Color(0xFFF2F2F2),
//                             textColor: Color(0xFF3C2235),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5)),
//                             onPressed: () {
//
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.party_mode, color: Color(0xFF3C2235)),
//                                       SizedBox(width: 10),
//                                       Text('Introduce yourself',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(Icons.brightness_1, color: Color(0xFFFF5B57)),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 40),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             color: Color(0xFFF2F2F2),
//                             textColor: Color(0xFF3C2235),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5)),
//                             onPressed: () {
//
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.notifications_active, color: Color(0xFF3C2235)),
//                                       SizedBox(width: 10),
//                                       Text('Notification settings',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(Icons.keyboard_arrow_right, color: Color(0xFF3C2235)),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 15),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             color: Color(0xFFF2F2F2),
//                             textColor: Color(0xFF3C2235),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5)),
//                             onPressed: () {
//
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.payment, color: Color(0xFF3C2235)),
//                                       SizedBox(width: 10),
//                                       Text('Payment method',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(Icons.keyboard_arrow_right, color: Color(0xFF3C2235)),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 15),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             color: Color(0xFFF2F2F2),
//                             textColor: Color(0xFF3C2235),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5)),
//                             onPressed: () {
//
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.print, color: Color(0xFF3C2235)),
//                                       SizedBox(width: 10),
//                                       Text('Payout method',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(Icons.keyboard_arrow_right, color: Color(0xFF3C2235)),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 15),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             color: Color(0xFFF2F2F2),
//                             textColor: Color(0xFF3C2235),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7.5)),
//                             onPressed: () {
//
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Icon(Icons.info, color: Color(0xFF3C2235)),
//                                       SizedBox(width: 10),
//                                       Text('FAQs',
//                                         style: TextStyle(
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(Icons.keyboard_arrow_right, color: Color(0xFF3C2235)),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ]
//           ),
//         )
//       ],
//     ),
//
//     // body: Center(
//     //   child: FutureBuilder(
//     //     future: http.read('$SERVER_IP/data', headers: {"Authorization": jwt}),
//     //     builder: (context, snapshot) =>
//     //       snapshot.hasData ?
//     //       Column(children: <Widget>[
//     //         Text("${payload['username']}, here's the data:"),
//     //         Text(snapshot.data, style: Theme.of(context).textTheme.display1)
//     //       ],)
//     //       :
//     //       snapshot.hasError ? Text("An error occurred") : CircularProgressIndicator(strokeWidth: 2.5)
//     //   ),
//     // ),
//   );
// }