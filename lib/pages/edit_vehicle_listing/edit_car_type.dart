// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json;
//
//
// Future<http.Response> fetchCarType() async {
//   final response = await http.post('https://api.car!.ridealike.com/v1/car.CarService/GetAllCarType',
//     body: json.encode(
//       {}
//     ),
//   );
//
//   if (response.statusCode == 200) {
//     return response;
//   } else {
//     throw Exception('Failed to load data');
//   }
// }
//
// class EditCarType extends StatefulWidget {
//   @override
//   State createState() => EditCarTypeState();
// }
//
// class EditCarTypeState extends State<EditCarType> {
//   List _carTypeData = [];
//
//   @override
//   void initState() {
//     super.initState();
//     callFetchCarType();
//   }
//
//   callFetchCarType() async {
//     var res = await fetchCarType();
//
//     setState(() {
//      _carTypeData = json.decode(res.body!)['CarTypes'];
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
//                 child: Text('Deselect all',
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
//       body: _carTypeData.length > 0 ? Column(
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
//                           child: Text('Type',
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
//             SizedBox(height: 15),
//             Expanded(
//               child: _carTypeData != null ? new ListView.separated (
//               separatorBuilder: (context, index) => Divider(
//                 color: Color(0xff371D32),
//                 thickness: 0.1,
//               ),
//               itemCount: _carTypeData.length,
//               itemBuilder: (BuildContext ctxt, int index) {
//                 return GestureDetector(
//                   onTap: () {
//                     receivedData['_type'] = _carTypeData[index]['Name'];
//
//                     Navigator.pushNamed(
//                       context,
//                       '/edit_about_your_vehicle',
//                       arguments: receivedData,
//                     );
//                   },
//                   child: SizedBox(
//                     width: double.maxFinite,
//                     child: Padding(
//                       padding: EdgeInsets.only(top: 8.0, right: 16.0, bottom: 8.0, left: 16.0),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: <Widget>[
//                           Container(
//                             child: Row(
//                               children: [
//                                 Text(_carTypeData[index]['Name'],
//                                   style: TextStyle(
//                                     fontFamily: 'Urbanist',
//                                     fontSize: 16,
//                                     color: Color(0xFF371D32),
//                                   ),
//                                 ),
//                               ]
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
//       ) : Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             new CircularProgressIndicator(strokeWidth: 2.5)
//           ],
//         ),
//       ),
//     );
//   }
// }