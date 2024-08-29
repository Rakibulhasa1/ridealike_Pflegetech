// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// import 'package:http/http.dart' as http;
// import 'dart:convert' show json;
// import 'dart:async';

// import 'google_map.dart';
// import 'package:ridealike/pages/google_map.dart';

// const SERVER_IP = 'https://api.car!.ridealike.com';

// bool _hasCustomDelivery = false;

// Completer<GoogleMapController> _mapController = Completer();

// final CameraPosition _initialCamera = CameraPosition(
//   target: LatLng(-20.3000, -40.2990),
//   zoom: 14.0000,
// );

// final TextEditingController _locationNotes = TextEditingController();

// class PickupAndReturnLocation extends StatefulWidget {
//   @override
//   State createState() => PickupAndReturnLocationState();
// }


// class PickupAndReturnLocationState extends State<PickupAndReturnLocation> {

//   @override
//   Widget build(BuildContext context) {
//     final Map receivedData = ModalRoute.of(context).settings.arguments;

//     bool _isButtonPressed = false;

//     return Scaffold(
//         backgroundColor: Colors.white,

//         //App Bar
//         appBar: new AppBar(
//           leading: new IconButton(
//             icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           actions: <Widget>[
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 GestureDetector(
//                   onTap: () {},
//                   child: Center(
//                     child: Container(
//                       margin: EdgeInsets.only(right: 16),
//                       child: Text(
//                         'Save & Exit',
//                         style: TextStyle(
//                           fontFamily: 'Urbanist',
//                           fontSize: 16,
//                           color: Color(0xFFFF8F62),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Center(
//                   child: Container(
//                     height: 2,
//                     width: 79,
//                     margin: EdgeInsets.only(right: 16),
//                     child: LinearProgressIndicator(
//                       value: 0.24,
//                       backgroundColor: Color(0xFFF2F2F2),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           elevation: 0.0,
//         ),

//         //Content of tabs
//         body: new SingleChildScrollView(
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: <Widget>[
//                 // Header
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: <Widget>[
//                     Expanded(
//                       child: Column(
//                         children: [
//                           SizedBox(
//                             width: double.maxFinite,
//                             child: Container(
//                               child: Text(
//                                 'Pickup and return location',
//                                 style: TextStyle(
//                                     fontFamily: 'Urbanist',
//                                     fontSize: 36,
//                                     color: Color(0xFF371D32),
//                                     fontWeight: FontWeight.bold),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Image.asset('icons/Location_Car-Location.png'),
//                   ],
//                 ),
//                 SizedBox(height: 20),
//                 // Text
//                 Row(
//                   children: <Widget>[
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             width: double.maxFinite,
//                             child: Text(
//                               'Enter the address where you would like your guests to pickup and return your car. This will be visible only to guests who successfully booked the trip.',
//                               style: TextStyle(
//                                 fontFamily: 'Urbanist',
//                                 fontSize: 16,
//                                 color: Color(0xFF353B50),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 20),

//                 // new map implemented//
//                 Container(
//                   height: 350,
//                   child: ClipRRect(
//                     borderRadius: BorderRadius.all(Radius.circular(8)),
//                     child: GoogleMapExample()
//                   ),
//                 ),
//               SizedBox(height: 10),
//               // Location note
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Color(0xFFF2F2F2),
//                               borderRadius: BorderRadius.circular(8.0)
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(16.0),
//                               child: Column(
//                                 children: <Widget>[
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: <Widget>[
//                                       Text('Location notes (optional)',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     children: <Widget>[
//                                       TextFormField(
//                                           controller: _locationNotes,
//                                           // validator: (value) {
//                                           //   if (value.isEmpty) {
//                                           //     return 'About me is required';
//                                           //   }
//                                           //   return null;
//                                           // },
//                                           maxLines: 5,
//                                           decoration: InputDecoration(
//                                             border: InputBorder.none,
//                                             hintText: 'Add notes how to locate your car. For example, what’s the access code to the garage or what’s the underground parking level?',
//                                             hintStyle: TextStyle(
//                                               fontFamily: 'Urbanist',
//                                               fontSize: 14,
//                                               fontStyle: FontStyle.italic
//                                             ),
//                                           ),
//                                         ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               // Enable custom delivery
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Color(0xFFF2F2F2),
//                               borderRadius: BorderRadius.circular(8.0)
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(16.0),
//                               child: Column(
//                                 children: <Widget>[
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Text('Enable custom delivery?',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 10),
//                                   Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: Column(
//                                           children: <Widget>[
//                                             Text('You can offer an extra car delivery to popular locations such as airports, train stations, and lodgings or to a location your guest selects.',
//                                               style: TextStyle(
//                                                 fontFamily: 'Urbanist',
//                                                 fontSize: 14,
//                                                 color: Color(0xFF353B50),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 10),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                           elevation: 0.0,
//                                           padding: EdgeInsets.all(16.0),
//                                           onPressed: () {
//                                             setState(() {
//                                               _hasCustomDelivery = !_hasCustomDelivery;
//                                             });
//                                           },
//                                           color: _hasCustomDelivery ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('YES',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _hasCustomDelivery ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Expanded(
//                                         child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                           elevation: 0.0,
//                                           padding: EdgeInsets.all(16.0),
//                                           onPressed: () {
//                                             setState(() {
//                                               _hasCustomDelivery = !_hasCustomDelivery;
//                                             });
//                                           },
//                                           color: _hasCustomDelivery ? Color(0xFFE0E0E0).withOpacity(0.5) : Color(0xFFFF8F62),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('NO',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _hasCustomDelivery ? Color(0xFF353B50).withOpacity(0.5) : Color(0xFFFFFFFF),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // Next button
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFFF8F62),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: _isButtonPressed ? null : () async {
//                               setState(() {
//                                 _isButtonPressed = true;
//                               });

//                               var address = await GoogleMapExampleState.addressLine(GoogleMapExampleState.location);
// //                              receivedData['Car']['ID']='bc9226d7-9ffc-403b-892e-fcb5d3cdd1e4';
//                               var res = await setPickupAndReturn(receivedData['Car']['ID'], GoogleMapExampleState.location, address);
//                               print(res);
//                               print(res.body!);
//                               var arguments = json.decode(res.body!);
//                               print(arguments);

//                               if (res != null) {
//                                 Navigator.pushNamed(
//                                   context,
//                                   '/set_your_car_availability',
//                                   arguments: arguments,
//                                 );
//                               } else {
//                                 setState(() {
//                                   _isButtonPressed = false;
//                                 });
//                               }
//                             },
//                             child: _isButtonPressed ? SizedBox(
//                               height: 18.0,
//                               width: 18.0,
//                               child: new CircularProgressIndicator(strokeWidth: 2.5),
//                             ) : Text('Next: Availability',
//                               style: TextStyle(
//                                 fontFamily: 'Urbanist',
//                                 fontSize: 18,
//                                 color: Colors.white
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               ],
//             ),
//           ),
//         ));
//   }
// }

// Future<http.Response> setPickupAndReturn(_carID, LatLng latLong,String address) async {
//   var res;

//   try {
//     res = await http.post(
//       '$SERVER_IP/v1/car.CarService/SetPickupAndReturn',
//       body: json.encode({
//         "CarID": _carID,
//         "PickupAndReturn": {
//           "Location": {
//             "Location": address,
//             "Latitude":latLong.latitude,
//             "Longitude":latLong.longitude,
//             "Notes": _locationNotes.text
//           },
//           "HasCustomDelivery": _hasCustomDelivery
//         }
//       }),
//     );
//   } catch (error) {

//   }

//   return res;
// }
