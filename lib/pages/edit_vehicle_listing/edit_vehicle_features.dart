// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json;
//
// const SERVER_IP = 'https://api.car!.ridealike.com';
//
// var _carFeatures =  {
//   "_carID": '',
//   "_hasAirConditioning": false,
//   "_hasHeatedSeats": false,
//   "_hasVentilatedSeats": false,
//   "_hasBluetoothAudio": false,
//   "_hasUSBChargingPort": false,
//   "_hasAppleCarPlay": false,
//   "_hasAndroidAuto": false,
//   "_hasSunroof": false,
//   "_hasAllWheelDrive": false,
//   "_hasBikeRack": false,
//   "_hasSkiRack": false,
//   "_hasSnowTires": false,
//   "_remoteStart": false,
//   "_freeWifi": false,
//   "_hasChildSeat": false,
//   "_hasSpareTire": false,
//   "_hasGPSTrackingDevice": false,
//   "_hasDashCamera": false,
//   "_customFeatures": [],
//   "_fuelType": '91-94_PREMIUM',
//   "_transmission": 'AUTOMATIC',
//   "_numberOfDoors": '4',
//   "_numberOfSeats": 5.0,
//   "_truckBoxSize": ''
// };
//
// class EditVehicleFeatures extends StatefulWidget {
//   @override
//   State createState() => EditVehicleFeaturesState();
// }
//
// class EditVehicleFeaturesState extends  State<EditVehicleFeatures> {
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(Duration.zero,() async {
//       final Map _receivedData = ModalRoute.of(context).settings.arguments;
//
//       print(_receivedData['Car']['Features']['NumberOfDoors']);
//
//       setState(() {
//         _carFeatures['_hasAirConditioning'] = _receivedData['Car']['Features']['Interior']['HasAirConditioning'];
//         _carFeatures['_hasHeatedSeats'] = _receivedData['Car']['Features']['Interior']['HasHeatedSeats'];
//         _carFeatures['_hasVentilatedSeats'] = _receivedData['Car']['Features']['Interior']['HasVentilatedSeats'];
//         _carFeatures['_hasBluetoothAudio'] = _receivedData['Car']['Features']['Interior']['HasBluetoothAudio'];
//         _carFeatures['_hasUSBChargingPort'] = _receivedData['Car']['Features']['Interior']['HasUsbChargingPort'];
//         _carFeatures['_hasAppleCarPlay'] = _receivedData['Car']['Features']['Interior']['HasAppleCarPlay'];
//         _carFeatures['_hasAndroidAuto'] = _receivedData['Car']['Features']['Interior']['HasAndroidAuto'];
//         _carFeatures['_hasSunroof'] = _receivedData['Car']['Features']['Interior']['HasSunroof'];
//
//         _carFeatures['_hasAllWheelDrive'] = _receivedData['Car']['Features']['Exterior']['HasAllWheelDrive'];
//         _carFeatures['_hasBikeRack'] = _receivedData['Car']['Features']['Exterior']['HasBikeRack'];
//         _carFeatures['_hasSkiRack'] = _receivedData['Car']['Features']['Exterior']['HasSkiRack'];
//         _carFeatures['_hasSnowTires'] = _receivedData['Car']['Features']['Exterior']['HasSnowTires'];
//
//         _carFeatures['_remoteStart'] = _receivedData['Car']['Features']['Comfort']['RemoteStart'];
//         _carFeatures['_freeWifi'] = _receivedData['Car']['Features']['Comfort']['FreeWifi'];
//
//         _carFeatures['_hasChildSeat'] = _receivedData['Car']['Features']['SafetyAndPrivacy']['HasChildSeat'];
//         _carFeatures['_hasSpareTire'] = _receivedData['Car']['Features']['SafetyAndPrivacy']['HasSpareTire'];
//         _carFeatures['_hasGPSTrackingDevice'] = _receivedData['Car']['Features']['SafetyAndPrivacy']['HasGPSTrackingDevice'];
//         _carFeatures['_hasDashCamera'] = _receivedData['Car']['Features']['SafetyAndPrivacy']['HasDashCamera'];
//
//         _carFeatures['_customFeatures'] = _receivedData['Car']['Features']['CustomFeatures'];
//
//         _carFeatures['_fuelType'] = _receivedData['Car']['Features']['FuelType'];
//         _carFeatures['_transmission'] = _receivedData['Car']['Features']['Transmission'];
//         _carFeatures['_numberOfDoors'] = _receivedData['Car']['Features']['NumberOfDoors'];
//         _carFeatures['_numberOfSeats'] = _receivedData['Car']['Features']['NumberOfSeats'].toDouble();
//         _carFeatures['_truckBoxSize'] = _receivedData['Car']['Features']['TruckBoxSize'];
//       });
//     });
//   }
//
//   @override
//   Widget build (BuildContext context) {
//
//     bool _isButtonPressed = false;
//
//     // final  Map receivedData = ModalRoute.of(context).settings.arguments;
//
//     // if (receivedData != null && receivedData['Car'] != null && receivedData['Car']['ID'] != null) {
//     //   _carFeatures['_carID'] = receivedData['Car']['ID'];
//     // } else {
//     //   _carFeatures = receivedData;
//     //   // print(_carFeatures);
//     // }
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
//         centerTitle: true,
//         title: Text('3/6',
//           style: TextStyle(
//             fontFamily: 'Urbanist',
//             fontSize: 16,
//             color: Color(0xff371D32),
//           ),
//         ),
//         actions: <Widget>[
//           Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: <Widget>[
//               GestureDetector(
//                 onTap: () {
//                   Navigator.pushNamed(
//                     context,
//                     '/dashboard_tab'
//                   );
//                 },
//                 child: Center(
//                   child: Container(
//                     margin: EdgeInsets.only(right: 16),
//                     child: Text('Save & Exit',
//                       style: TextStyle(
//                         fontFamily: 'Urbanist',
//                         fontSize: 16,
//                         color: Color(0xffFF8F68),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//         elevation: 0.0,
//       ),
//
//       //Content of tabs
//       body: _carFeatures['_carID'] != '' ? new SingleChildScrollView(
//         child: Padding(
//           padding: EdgeInsets.all(16.0),
//           child: Column(
//             children: <Widget>[
//               // Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Container(
//                             child: Text('Select vehicle\'s features',
//                               style: TextStyle(
//                                 fontFamily: 'Urbanist',
//                                 fontSize: 36,
//                                 color: Color(0xFF371D32),
//                                 fontWeight: FontWeight.bold
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Image.asset('icons/Star-Features.png'),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // Header text
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Text('We have preselected features based on your VIN, but you can make changes or additions below.',
//                           style: TextStyle(
//                             fontFamily: 'Urbanist',
//                             fontSize: 16,
//                             color: Color(0xFF353B50),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // Fuel type
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Container(
//                             padding: EdgeInsets.all(16.0),
//                             decoration: new BoxDecoration(
//                               color: Color(0xFFF2F2F2),
//                               borderRadius: new BorderRadius.circular(8.0),
//                             ),
//                             child: Column(
//                               children: <Widget>[
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: <Widget>[
//                                     Container(
//                                       child: Row(
//                                         children: [
//                                           Text('Fuel type',
//                                             style: TextStyle(
//                                               fontFamily: 'Urbanist',
//                                               fontSize: 16,
//                                               color: Color(0xFF371D32),
//                                             ),
//                                           ),
//                                         ]
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 SizedBox(height: 10),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: <Widget>[
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           setState((){
//                                             _carFeatures['_fuelType'] = '87_REGULAR';
//                                           });
//                                         },
//                                         child: Container(
//                                           height: 56.0,
//                                           decoration: new BoxDecoration(
//                                             color: _carFeatures['_fuelType'] == '87_REGULAR' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                             borderRadius: new BorderRadius.circular(8.0),
//                                           ),
//                                           child: Column(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Expanded(
//                                                     child: Text('87 \nREGULAR',
//                                                       textAlign: TextAlign.center,
//                                                       style: TextStyle(
//                                                         fontFamily: 'Urbanist',
//                                                         fontSize: 12,
//                                                         color: _carFeatures['_fuelType'] == '87_REGULAR' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           setState((){
//                                             _carFeatures['_fuelType'] = '91-94_PREMIUM';
//                                           });
//                                         },
//                                         child: Container(
//                                           height: 56.0,
//                                           decoration: new BoxDecoration(
//                                             color: _carFeatures['_fuelType'] == '91-94_PREMIUM' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                             borderRadius: new BorderRadius.circular(8.0),
//                                           ),
//                                           child: Column(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Expanded(
//                                                     child: Text('91-94 \nPREMIUM',
//                                                       textAlign: TextAlign.center,
//                                                       style: TextStyle(
//                                                         fontFamily: 'Urbanist',
//                                                         fontSize: 12,
//                                                         color: _carFeatures['_fuelType'] == '91-94_PREMIUM' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           setState((){
//                                             _carFeatures['_fuelType'] = 'DIESEL';
//                                           });
//                                         },
//                                         child: Container(
//                                           height: 56.0,
//                                           decoration: new BoxDecoration(
//                                             color: _carFeatures['_fuelType'] == 'DIESEL' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                             borderRadius: new BorderRadius.circular(8.0),
//                                           ),
//                                           child: Column(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Expanded(
//                                                     child: Text('DIESEL',
//                                                       textAlign: TextAlign.center,
//                                                       style: TextStyle(
//                                                         fontFamily: 'Urbanist',
//                                                         fontSize: 12,
//                                                         color: _carFeatures['_fuelType'] == 'DIESEL' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     Expanded(
//                                       child: GestureDetector(
//                                         onTap: () {
//                                           setState((){
//                                             _carFeatures['_fuelType'] = 'ELECTRIC';
//                                           });
//                                         },
//                                         child: Container(
//                                           height: 56.0,
//                                           decoration: new BoxDecoration(
//                                             color: _carFeatures['_fuelType'] == 'ELECTRIC' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                             borderRadius: new BorderRadius.circular(8.0),
//                                           ),
//                                           child: Column(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Expanded(
//                                                     child: Text('ELECTRIC',
//                                                       textAlign: TextAlign.center,
//                                                       style: TextStyle(
//                                                         fontFamily: 'Urbanist',
//                                                         fontSize: 12,
//                                                         color: _carFeatures['_fuelType'] == 'ELECTRIC' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//                                                       ),
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               // Transmission
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
//                               borderRadius: BorderRadius.circular(8)
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(16.0),
//                               child: Column(
//                                 children: <Widget>[
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Container(
//                                         child: Row(
//                                           children: [
//                                             Text('Transmission',
//                                               style: TextStyle(
//                                                 fontFamily: 'Urbanist',
//                                                 fontSize: 16,
//                                                 color: Color(0xFF371D32),
//                                               ),
//                                             ),
//                                           ]
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
//                                             setState((){
//                                               _carFeatures['_transmission'] = 'AUTOMATIC';
//                                             });
//                                           },
//                                           color: _carFeatures['_transmission'] == 'AUTOMATIC' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('AUTOMATIC',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _carFeatures['_transmission'] == 'AUTOMATIC' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//                                             setState((){
//                                               _carFeatures['_transmission'] = 'MANUAL';
//                                             });
//                                           },
//                                           color: _carFeatures['_transmission'] == 'MANUAL' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('MANUAL',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _carFeatures['_transmission'] == 'MANUAL' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//               SizedBox(height: 10),
//               // Number of doors
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
//                               borderRadius: BorderRadius.circular(8)
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(16.0),
//                               child: Column(
//                                 children: <Widget>[
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: <Widget>[
//                                       Container(
//                                         child: Row(
//                                           children: [
//                                             Text('Number of doors',
//                                               style: TextStyle(
//                                                 fontFamily: 'Urbanist',
//                                                 fontSize: 16,
//                                                 color: Color(0xFF371D32),
//                                               ),
//                                             ),
//                                           ]
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
//                                             setState((){
//                                               _carFeatures['_numberOfDoors'] = 2;
//                                             });
//                                           },
//                                           color: _carFeatures['_numberOfDoors'] == 2 ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('2',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _carFeatures['_numberOfDoors'] == 2 ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//                                             setState((){
//                                               _carFeatures['_numberOfDoors'] = 4;
//                                             });
//                                           },
//                                           color: _carFeatures['_numberOfDoors'] == 4 ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('4',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _carFeatures['_numberOfDoors'] == 4 ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//               SizedBox(height: 10),
//               // Number of seats
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Container(
//                             decoration: new BoxDecoration(
//                               color: Color(0xFFF2F2F2),
//                               borderRadius: new BorderRadius.circular(8.0),
//                             ),
//                             child: Container(
//                               child: Column(
//                                 children: <Widget>[
//                                   Padding(
//                                     padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 16.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: <Widget>[
//                                         Text('Number of seats',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text(double.parse(_carFeatures['_numberOfSeats'].toString()).round().toString(),
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 14,
//                                             color: Color(0xFF353B50),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.only(bottom: 8.0),
//                                     child: Row(
//                                       children: <Widget>[
//                                         Expanded(
//                                           child: SliderTheme(
//                                             data: SliderThemeData(
//                                               thumbColor: Color(0xffFFFFFF),
//                                               trackShape: RoundedRectSliderTrackShape(),
//                                               trackHeight: 4.0,
//                                               activeTrackColor: Color(0xffFF8F62),
//                                               inactiveTrackColor: Color(0xFFE0E0E0),
//                                               tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4.0),
//                                               activeTickMarkColor: Color(0xffFF8F62),
//                                               inactiveTickMarkColor: Color(0xFFE0E0E0),
//                                               thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14.0),
//                                             ),
//                                             child: Slider(
//                                               min: 2.0,
//                                               max: 8.0,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   _carFeatures['_numberOfSeats'] = values;
//                                                 });
//                                               },
//                                               value: _carFeatures['_numberOfSeats'],
//                                               divisions: 6,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
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
//               // Truck box size
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
//                               borderRadius: BorderRadius.circular(8)
//                             ),
//                             child: Padding(
//                               padding: EdgeInsets.all(16.0),
//                               child: Column(
//                                 children: <Widget>[
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     children: <Widget>[
//                                       Container(
//                                         child: Row(
//                                           children: [
//                                             Text('Truck box size',
//                                               style: TextStyle(
//                                                 fontFamily: 'Urbanist',
//                                                 fontSize: 16,
//                                                 color: Color(0xFF371D32),
//                                               ),
//                                             ),
//                                           ]
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
//                                             setState((){
//                                               _carFeatures['_truckBoxSize'] = 'SHORT';
//                                             });
//                                           },
//                                           color: _carFeatures['_truckBoxSize'] == 'SHORT' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('SHORT',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _carFeatures['_truckBoxSize'] == 'SHORT' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//                                             setState((){
//                                               _carFeatures['_truckBoxSize'] = 'STANDARD';
//                                             });
//                                           },
//                                           color: _carFeatures['_truckBoxSize'] == 'STANDARD' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('STD',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _carFeatures['_truckBoxSize'] == 'STANDARD' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//                                             setState((){
//                                               _carFeatures['_truckBoxSize'] = 'LONG';
//                                             });
//                                           },
//                                           color: _carFeatures['_truckBoxSize'] == 'LONG' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('LONG',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _carFeatures['_truckBoxSize'] == 'LONG' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//               // Interior
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Interior features',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 18,
//                               color: Color(0xFF371D32),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               // Air CarPlay
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasAndroidAuto'] = !_carFeatures['_hasAndroidAuto'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Android.png'),
//                                       SizedBox(width: 10),
//                                       Text('Android auto',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasAndroidAuto'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasAppleCarPlay'] = !_carFeatures['_hasAppleCarPlay'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Apple.png'),
//                                       SizedBox(width: 10),
//                                       Text('Apple CarPlay',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasAppleCarPlay'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasAirConditioning'] = !_carFeatures['_hasAirConditioning'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/AC.png'),
//                                       SizedBox(width: 10),
//                                       Text('Air conditioning',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasAirConditioning'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasBluetoothAudio'] = !_carFeatures['_hasBluetoothAudio'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Bluetooth.png'),
//                                       SizedBox(width: 10),
//                                       Text('Bluetooth audio',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasBluetoothAudio'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasHeatedSeats'] = !_carFeatures['_hasHeatedSeats'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Heated_Seats.png'),
//                                       SizedBox(width: 10),
//                                       Text('Heated seats',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasHeatedSeats'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasSunroof'] = !_carFeatures['_hasSunroof'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Sun.png'),
//                                       SizedBox(width: 10),
//                                       Text('Sunroof',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasSunroof'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10.0),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasUSBChargingPort'] = !_carFeatures['_hasUSBChargingPort'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/AC.png'),
//                                       SizedBox(width: 10),
//                                       Text('USB charging port',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasUSBChargingPort'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasVentilatedSeats'] = !_carFeatures['_hasVentilatedSeats'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Ventilated_seats.png'),
//                                       SizedBox(width: 10),
//                                       Text('Ventilated seats',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasVentilatedSeats'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // Exterior
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Exterior features',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 18,
//                               color: Color(0xFF371D32),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasAllWheelDrive'] = !_carFeatures['_hasAllWheelDrive'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/AWD.png'),
//                                       SizedBox(width: 10),
//                                       Text('All-wheel drive',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasAllWheelDrive'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasBikeRack'] = !_carFeatures['_hasBikeRack'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Bike.png'),
//                                       SizedBox(width: 10),
//                                       Text('Bike rack',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasBikeRack'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasSkiRack'] = !_carFeatures['_hasSkiRack'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Image.asset('icons/Ski.png'),
//                                       SizedBox(width: 10),
//                                       Text('Ski rack',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasSkiRack'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasSnowTires'] = !_carFeatures['_hasSnowTires'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Snow-tires.png'),
//                                       SizedBox(width: 10),
//                                       Text('Snow tires',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasSnowTires'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // Comfort
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Comfort features',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 18,
//                               color: Color(0xFF371D32),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_freeWifi'] = !_carFeatures['_freeWifi'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Wifi.png'),
//                                       SizedBox(width: 10),
//                                       Text('Free Wi-Fi',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_freeWifi'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_remoteStart'] = !_carFeatures['_remoteStart'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Remote-start.png'),
//                                       SizedBox(width: 10),
//                                       Text('Remote start',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_remoteStart'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // Safety and privacy
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Safety and privacy features',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 18,
//                               color: Color(0xFF371D32),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasChildSeat'] = !_carFeatures['_hasChildSeat'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Child-seat.png'),
//                                       SizedBox(width: 10),
//                                       Text('Child seat',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasChildSeat'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasDashCamera'] = !_carFeatures['_hasDashCamera'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Camera.png'),
//                                       SizedBox(width: 10),
//                                       Text('Dash camera',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasDashCamera'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasGPSTrackingDevice'] = !_carFeatures['_hasGPSTrackingDevice'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Location.png'),
//                                       SizedBox(width: 10),
//                                       Text('GPS tracking',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasGPSTrackingDevice'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               setState(() {
//                                 _carFeatures['_hasSpareTire'] = !_carFeatures['_hasSpareTire'];
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Image.asset('icons/Tire.png'),
//                                       SizedBox(width: 10),
//                                       Text('Spare tire included',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(
//                                   Icons.check,
//                                   size: 20,
//                                   color: _carFeatures['_hasSpareTire'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               // Text
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: <Widget>[
//                         Text('24/7 roadside assisstance will be included for your guests free of charge.',
//                           style: TextStyle(
//                             fontFamily: 'Urbanist',
//                             fontSize: 14,
//                             color: Color(0xFF353B50),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // Custom features
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Custom features',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 18,
//                               color: Color(0xFF371D32),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 10),
//               _carFeatures['_customFeatures'] != null ? Column(
//                 children: <Widget>[
//                   for(var item in _carFeatures['_customFeatures']) Row(
//                     children: <Widget>[
//                       Expanded(
//                         child: Column(
//                           children: [
//                             SizedBox(
//                               width: double.maxFinite,
//                               child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                 elevation: 0.0,
//                                 color: Color(0xFFF2F2F2),
//                                 padding: EdgeInsets.all(16.0),
//                                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                 onPressed: () {
//                                   var _editCustomFeatureData = {
//                                     "_data": item,
//                                     "_carFeatures": _carFeatures
//                                   };
//                                   Navigator.pushNamed(
//                                     context,
//                                     '/edit_edit_a_feature',
//                                     arguments: _editCustomFeatureData,
//                                   );
//                                 },
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: <Widget>[
//                                     Container(
//                                       child: Row(
//                                         children: <Widget>[
//                                           Image.asset('icons/Star.png'),
//                                           SizedBox(width: 10),
//                                           Text(item['Name'].toString(),
//                                             style: TextStyle(
//                                               fontFamily: 'Urbanist',
//                                               fontSize: 16,
//                                               color: Color(0xFF371D32),
//                                             ),
//                                           ),
//                                         ]
//                                       ),
//                                     ),
//                                     Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
//                                   ],
//                                 )
//                               ),
//                             ),
//                             SizedBox(height: 10.0),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ) : SizedBox(height: 10),
//               // Add new feature
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFF2F2F2),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: () {
//                               Navigator.pushNamed(
//                                 context,
//                                 '/edit_add_a_feature',
//                                 arguments: _carFeatures,
//                               );
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Image.asset('icons/Star.png'),
//                                       SizedBox(width: 10),
//                                       Text('Add a feature',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 30),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xffFF8F68),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             // onPressed: _isButtonPressed ? null : () async {
//                             onPressed: () async {
//                               // setState(() {
//                               //   _isButtonPressed = true;
//                               // });
//
//                               var res = await setFeatures();
//
//                               var arguments = json.decode(res.body!);
//
//                               Navigator.pushNamed(
//                                 context,
//                                 '/review_your_listing',
//                                 arguments: arguments,
//                               );
//
//                               // if (res != null) {
//                               //   Navigator.pushNamed(
//                               //     context,
//                               //     '/set_your_car_rules',
//                               //     arguments: arguments,
//                               //   );
//                               // } else {
//                               //   setState(() {
//                               //     _isButtonPressed = false;
//                               //   });
//                               // }
//                             },
//                             child: _isButtonPressed ? SizedBox(
//                               height: 18.0,
//                               width: 18.0,
//                               child: new CircularProgressIndicator(strokeWidth: 2.5),
//                             ) :Text('Next',
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
//             ],
//           ),
//         ),
//       )
//       : Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[new CircularProgressIndicator()],
//         ),
//       ),
//     );
//   }
// }
//
// Future<http.Response> setFeatures() async {
//   var res = await http.post(
//     '$SERVER_IP/v1/car.CarService/SetFeatures',
//     body: json.encode(
//       {
//         "CarID": _carFeatures['_carID'],
//         "Features": {
//           "FuelType": _carFeatures['_fuelType'],
//           "Transmission": _carFeatures['_transmission'],
//           "NumberOfDoors": _carFeatures['_numberOfDoors'],
//           "NumberOfSeats": double.parse(_carFeatures['_numberOfSeats'].toString()).round(),
//           "TruckBoxSize": _carFeatures['_truckBoxSize'],
//           "Interior": {
//             "HasAirConditioning": _carFeatures['_hasAirConditioning'],
//             "HasHeatedSeats": _carFeatures['_hasHeatedSeats'],
//             "HasVentilatedSeats": _carFeatures['_hasVentilatedSeats'],
//             "HasBluetoothAudio": _carFeatures['_hasBluetoothAudio'],
//             "HasAppleCarPlay": _carFeatures['_hasAppleCarPlay'],
//             "HasAndroidAuto": _carFeatures['_hasAndroidAuto'],
//             "HasSunroof": _carFeatures['_hasSunroof'],
//             "HasUsbChargingPort": _carFeatures['_hasUsbChargingPort']
//           },
//           "Exterior": {
//             "HasAllWheelDrive": _carFeatures['_hasAllWheelDrive'],
//             "HasBikeRack": _carFeatures['_hasBikeRack'],
//             "HasSkiRack": _carFeatures['_hasSkiRack'],
//             "HasSnowTires": _carFeatures['_hasSnowTires']
//           },
//           "Comfort": {
//             "RemoteStart": _carFeatures['_remoteStart'],
//             "FreeWifi": _carFeatures['_freeWifi']
//           },
//           "SafetyAndPrivacy": {
//             "HasChildSeat": _carFeatures['_hasChildSeat'],
//             "HasSpareTire": _carFeatures['_hasSpareTire'],
//             "HasGPSTrackingDevice": _carFeatures['_hasGPSTrackingDevice'],
//             "HasDashCamera": _carFeatures['_hasDashCamera']
//           },
//           "CustomFeatures": _carFeatures['_customFeatures'],
//           "Completed": true
//         }
//       }
//     ),
//   );
//
//   return res;
// }
