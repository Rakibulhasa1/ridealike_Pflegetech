// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json, base64, ascii;
//
// Future<http.Response> fetchCarMake() async {
//   final response = await http.post('https://api.car!.ridealike.com/v1/car.CarService/GetAllCarBodyTrim',
//     body: json.encode(
//       {}
//     ),
//   // );
//
//   if (response.statusCode == 200) {
//     // If the server did return a 200 OK response,
//     // then parse the JSON.
//     return response;
//   } else {
//     // If the server did not return a 200 OK response,
//     // then throw an exception.
//     throw Exception('Failed to load data');
//   }
// }
//
// class EditCarBodyTrim extends StatefulWidget {
//   @override
//   State createState() => EditCarBodyTrimState();
// }
//
// class EditCarBodyTrimState extends State<EditCarBodyTrim> {
//   List _carBodyTrimData;
//
//   var arguments = {
//     '_bodyTrimID': '',
//     '_carData' : {}
//   };
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(Duration.zero,() async {
//       final Map _data = ModalRoute.of(context).settings.arguments;
//
//       var res = await fetchCarMake();
//
//       setState(() {
//         _carBodyTrimData = json.decode(res.body!)['CarBodyTrims'].where((i) => i['ModelID'] == _data['_modelID']).toList();
//       });
//     });
//   }
//
//   @override
//   Widget build (BuildContext context) {
//
//     final Map receivedData = ModalRoute.of(context).settings.arguments;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       //App Bar
//       appBar: new AppBar(
//         leading: new IconButton(
//           icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         actions: <Widget>[
//           GestureDetector(
//             onTap: () {
//
//             },
//             child: Center(
//               child: Container(
//                 margin: EdgeInsets.only(right: 16),
//                 child: Text('Cancel',
//                   style: TextStyle(
//                     fontFamily: 'Urbanist',
//                     fontSize: 16,
//                     color: Color(0xffFF8F68),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//         elevation: 0.0,
//       ),
//
//       //Content of tabs
//       body: Column(
//         children: <Widget>[
//           // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: Container(
//                           padding: EdgeInsets.all(16.0),
//                           child: Text('Body trim',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 36,
//                               color: Color(0xFF371D32),
//                               fontWeight: FontWeight.bold
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 30),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: <Widget>[
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: Container(
//                           padding: EdgeInsets.only(left: 16.0, bottom: 4.0),
//                           child: Row(
//                             children: <Widget>[
//                               Text(receivedData['_carData']['_make'],
//                                 style: TextStyle(
//                                   fontFamily: 'Urbanist',
//                                   fontSize: 12,
//                                   color: Color(0xFF371D32).withOpacity(0.5)
//                                 ),
//                               ),
//                               Text(' / ' + receivedData['_carData']['_model'],
//                                 style: TextStyle(
//                                   fontFamily: 'Urbanist',
//                                   fontSize: 12,
//                                   color: Color(0xFF371D32).withOpacity(0.5)
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             Divider(
//               color: Color(0xff371D32),
//               thickness: 0.1,
//             ),
//             Expanded(
//               child: _carBodyTrimData != null ? new ListView.separated (
//               separatorBuilder: (context, index) => Divider(
//                 color: Color(0xff371D32),
//                 thickness: 0.1,
//               ),
//               itemCount: _carBodyTrimData.length,
//               itemBuilder: (BuildContext ctxt, int index) {
//                 return GestureDetector(
//                   onTap: () {
//                     receivedData['_carData']['_bodyTrim'] = _carBodyTrimData[index]['Name'];
//
//                     arguments['_bodyTrimID'] = _carBodyTrimData[index]['BodyTrimID'];
//                     arguments['_carData'] = receivedData['_carData'];
//
//                     Navigator.pushNamed(
//                       context,
//                       '/edit_car_style',
//                       arguments: arguments,
//                     );
//                   },
//                   child: SizedBox(
//                     width: double.maxFinite,
//                     child: Padding(
//                       padding: EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8.0, left: 16.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(_carBodyTrimData[index]['Name'],
//                                   style: TextStyle(
//                                     fontFamily: 'Urbanist',
//                                     fontSize: 16,
//                                     color: Color(0xFF371D32),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Container(
//                             width: 16,
//                             child: Icon(
//                               Icons.keyboard_arrow_right,
//                               color: Color(0xFF353B50),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               }
//             ) : Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                   new CircularProgressIndicator(strokeWidth: 2.5)
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }