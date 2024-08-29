// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
//
// import 'package:jiffy/jiffy.dart';
// import 'package:some_calendar/some_calendar.dart';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json;
//
// String _carID = '';
//
// double _sameDayCutOff = 12.0;
// double _shortestTrip = 2.0;
// double _longestTrip = 3.0;
// double _swapWithin = 100.0;
//
// String _advanceNotice = 'SameDay';
// String _bookingWindow = '';
//
// String _shortestTripToString = '1 day (24hrs)';
// String _longestTripToString = '5 days';
//
// bool _economy = false;
// bool _compact = false;
// bool _midSize = false;
// bool _fullSize = true;
// bool _sports = true;
// bool _compactSUV = false;
// bool _midSizeSUV = false;
// bool _fullSizeSUV = true;
// bool _sportsSUV = true;
// bool _pickupTruck = false;
// bool _minivan = false;
// bool _van = false;
//
// bool _swapEnabled = false;
//
// const SERVER_IP = 'https://api.car!.ridealike.com';
//
// class EditVehicleAvailability extends StatefulWidget {
//   @override
//   State createState() => EditVehicleAvailabilityState();
// }
//
// class EditVehicleAvailabilityState extends  State<EditVehicleAvailability> {
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(Duration.zero,() async {
//       final Map _receivedData = ModalRoute.of(context).settings.arguments;
//
//       setState(() {
//         _carID = _receivedData['Car']['ID'];
//
//         _sameDayCutOff = _receivedData['Car']['Availability']['RentalAvailability']['SameDayCutOffTime']['hours'].toDouble();
//         _shortestTrip = _receivedData['Car']['Availability']['RentalAvailability']['ShortestTrip'].toDouble();
//         _longestTrip = _receivedData['Car']['Availability']['RentalAvailability']['LongestTrip'].toDouble();
//         _advanceNotice = _receivedData['Car']['Availability']['RentalAvailability']['AdvanceNotice'];
//         _bookingWindow = _receivedData['Car']['Availability']['RentalAvailability']['BookingWindow'];
//
//         _swapWithin = _receivedData['Car']['Availability']['SwapAvailability']['SwapWithin'].toDouble();
//         _economy = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['Economy'];
//         _compact = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['Compact'];
//         _midSize = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['MidSize'];
//         _fullSize = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['FullSize'];
//         _sports = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['Sports'];
//         _compactSUV = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['CompactSUV'];
//         _midSizeSUV = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['MidSizeSUV'];
//         _fullSizeSUV = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['FullSizeSUV'];
//         _sportsSUV = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['SportsSUV'];
//         _pickupTruck = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['PickupTruck'];
//         _minivan = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['Minivan'];
//         _van = _receivedData['Car']['Availability']['SwapAvailability']['SwapVehiclesType']['Van'];
//
//         switch(_receivedData['Car']['Availability']['RentalAvailability']['ShortestTrip']) {
//           case 1:
//             _shortestTripToString = '1 hour';
//             break;
//           case 2:
//             _shortestTripToString = '1 day (24hrs)';
//             break;
//           case 3:
//             _shortestTripToString = '1 week';
//             break;
//           case 4:
//             _shortestTripToString = '1 month';
//             break;
//         }
//
//         switch(_receivedData['Car']['Availability']['RentalAvailability']['LongestTrip']) {
//           case 1:
//             _longestTripToString = '1 day';
//             break;
//           case 2:
//             _longestTripToString = '3 days';
//             break;
//           case 3:
//             _longestTripToString = '5 days';
//             break;
//           case 4:
//             _longestTripToString = '1 week';
//             break;
//           case 5:
//             _longestTripToString = '2 weeks';
//             break;
//           case 6:
//             _longestTripToString = '1 month';
//             break;
//           case 7:
//             _longestTripToString = 'Any';
//             break;
//         }
//
//         if (_receivedData['Preference']['ListingType']['SwapEnabled']) {
//         setState(() {
//           _swapEnabled = true;
//         });
//       }
//       });
//     });
//   }
//
//   // final _scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   Widget build (BuildContext context) {
//
//     bool _isButtonPressed = false;
//     List<DateTime> selectedDates = List();
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       // key: _scaffoldKey,
//
//       //App Bar
//       appBar: new AppBar(
//         leading: new IconButton(
//           icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         centerTitle: true,
//         title: Text('5/6',
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
//                         color: Color(0xFFFF8F62),
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
//       body: new SingleChildScrollView(
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
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Container(
//                             child: Text('Set vehicle\'s availability',
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
//                   Image.asset('icons/Calendar_Car-Availability.png'),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // Section header
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Rental availability',
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
//               // Advance notince
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
//                                       Text('Advance notice',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 5),
//                                   Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: <Widget>[
//                                             Text('Select how much notice you need before the trip can be booked.',
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
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                           elevation: 0.0,
//                                           padding: EdgeInsets.all(16.0),
//                                           onPressed: () {
//                                             setState(() {
//                                               _advanceNotice = 'SameDay';
//                                             });
//                                           },
//                                           color: _advanceNotice == 'SameDay' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('SAME DAY',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _advanceNotice == 'SameDay' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//                                   SizedBox(height: 5),
//                                   Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                           elevation: 0.0,
//                                           padding: EdgeInsets.all(16.0),
//                                           onPressed: () {
//                                             setState(() {
//                                               _advanceNotice = 'AtLeast1Day';
//                                             });
//                                           },
//                                           color: _advanceNotice == 'AtLeast1Day' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('AT LEAST 1 DAY’S NOTICE',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _advanceNotice == 'AtLeast1Day' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//                                   SizedBox(height: 5),
//                                   Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                           elevation: 0.0,
//                                           padding: EdgeInsets.all(16.0),
//                                           onPressed: () {
//                                             setState(() {
//                                               _advanceNotice = 'AtLeast3Day';
//                                             });
//                                           },
//                                           color: _advanceNotice == 'AtLeast3Day' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('AT LEAST 3 DAYS’ NOTICE',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _advanceNotice == 'AtLeast3Day' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//                                   SizedBox(height: 5),
//                                   Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                           elevation: 0.0,
//                                           padding: EdgeInsets.all(16.0),
//                                           onPressed: () {
//                                             setState(() {
//                                               _advanceNotice = 'AtLeast5Day';
//                                             });
//                                           },
//                                           color: _advanceNotice == 'AtLeast5Day' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('AT LEAST 5 DAYS’ NOTICE',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _advanceNotice == 'AtLeast5Day' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//                                   SizedBox(height: 5),
//                                   Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                           elevation: 0.0,
//                                           padding: EdgeInsets.all(16.0),
//                                           onPressed: () {
//                                             setState(() {
//                                               _advanceNotice = 'AtLeast7Day';
//                                             });
//                                           },
//                                           color: _advanceNotice == 'AtLeast7Day' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                           child: Column(
//                                             children: <Widget>[
//                                               Row(
//                                                 mainAxisAlignment: MainAxisAlignment.center,
//                                                 children: <Widget>[
//                                                   Text('AT LEAST 7 DAYS’ NOTICE',
//                                                     style: TextStyle(
//                                                       fontFamily: 'Urbanist',
//                                                       fontSize: 12,
//                                                       color: _advanceNotice == 'AtLeast7Day' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
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
//               // Same day cut-off time
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
//                             child: Container(
//                               child: Column(
//                                 children: <Widget>[
//                                   Padding(
//                                     padding: EdgeInsets.all(16.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: <Widget>[
//                                         Text('Same day cut-off time',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text('${_sameDayCutOff.round() > 12 ? (_sameDayCutOff.round() - 12) : _sameDayCutOff.round()}' + ':00 ' + '${_sameDayCutOff.round() > 12 ? 'PM' : 'AM'}',
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
//                                               min: 0.0,
//                                               max: 24.0,
//                                               onChanged: _advanceNotice == 'SameDay' ? (values) {
//                                                 setState(() {
//                                                   _sameDayCutOff = values;
//                                                 });
//                                               } : null,
//                                               value: _sameDayCutOff,
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
//               // Booking window
//               // Row(
//               //   children: <Widget>[
//               //     Expanded(
//               //       child: Column(
//               //         children: [
//               //           SizedBox(
//               //             width: double.maxFinite,
//               //             child: Container(
//               //               decoration: BoxDecoration(
//               //                 color: Color(0xFFF2F2F2),
//               //                 borderRadius: BorderRadius.circular(8.0)
//               //               ),
//               //               child: Padding(
//               //                 padding: EdgeInsets.all(16.0),
//               //                 child: Column(
//               //                   children: <Widget>[
//               //                     Row(
//               //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //                       children: <Widget>[
//               //                         Text('Booking window',
//               //                           style: TextStyle(
//               //                             fontFamily: 'Urbanist',
//               //                             fontSize: 16,
//               //                             color: Color(0xFF371D32),
//               //                           ),
//               //                         ),
//               //                       ],
//               //                     ),
//               //                     SizedBox(height: 5),
//               //                     Row(
//               //                       children: <Widget>[
//               //                         Expanded(
//               //                           child: Column(
//               //                             crossAxisAlignment: CrossAxisAlignment.start,
//               //                             children: <Widget>[
//               //                               Text('Select how far into the future your car\'s calendar will show as available.',
//               //                                 style: TextStyle(
//               //                                   fontFamily: 'Urbanist',
//               //                                   fontSize: 14,
//               //                                   color: Color(0xFF353B50),
//               //                                 ),
//               //                               ),
//               //                             ],
//               //                           ),
//               //                         ),
//               //                       ],
//               //                     ),
//               //                     SizedBox(height: 10),
//               //                     Row(
//               //                       children: <Widget>[
//               //                         Expanded(
//               //                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//               //                             elevation: 0.0,
//               //                             padding: EdgeInsets.all(16.0),
//               //                             onPressed: () {
//               //                               setState(() {
//               //                                 _bookingWindow = 'AllFutureDates';
//               //                               });
//               //                             },
//               //                             color: _bookingWindow == 'AllFutureDates' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//               //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//               //                             child: Column(
//               //                               children: <Widget>[
//               //                                 Row(
//               //                                   mainAxisAlignment: MainAxisAlignment.center,
//               //                                   children: <Widget>[
//               //                                     Text('ALL FUTURE DATES ARE AVAILABLE',
//               //                                       style: TextStyle(
//               //                                         fontFamily: 'Urbanist',
//               //                                         fontSize: 12,
//               //                                         color: _bookingWindow == 'AllFutureDates' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//               //                                       ),
//               //                                     ),
//               //                                   ],
//               //                                 ),
//               //                               ],
//               //                             ),
//               //                           ),
//               //                         ),
//               //                       ],
//               //                     ),
//               //                     SizedBox(height: 5),
//               //                     Row(
//               //                       children: <Widget>[
//               //                         Expanded(
//               //                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//               //                             elevation: 0.0,
//               //                             padding: EdgeInsets.all(16.0),
//               //                             onPressed: () {
//               //                               setState(() {
//               //                                 _bookingWindow = 'Months1';
//               //                               });
//               //                             },
//               //                             color: _bookingWindow == 'Months1' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//               //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//               //                             child: Column(
//               //                               children: <Widget>[
//               //                                 Row(
//               //                                   mainAxisAlignment: MainAxisAlignment.center,
//               //                                   children: <Widget>[
//               //                                     Text('1 MONTH INTO THE FUTURE',
//               //                                       style: TextStyle(
//               //                                         fontFamily: 'Urbanist',
//               //                                         fontSize: 12,
//               //                                         color: _bookingWindow == 'Months1' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//               //                                       ),
//               //                                     ),
//               //                                   ],
//               //                                 ),
//               //                               ],
//               //                             ),
//               //                           ),
//               //                         ),
//               //                       ],
//               //                     ),
//               //                     SizedBox(height: 5),
//               //                     Row(
//               //                       children: <Widget>[
//               //                         Expanded(
//               //                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//               //                             elevation: 0.0,
//               //                             padding: EdgeInsets.all(16.0),
//               //                             onPressed: () {
//               //                               setState(() {
//               //                                 _bookingWindow = 'Months3';
//               //                               });
//               //                             },
//               //                             color: _bookingWindow == 'Months3' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//               //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//               //                             child: Column(
//               //                               children: <Widget>[
//               //                                 Row(
//               //                                   mainAxisAlignment: MainAxisAlignment.center,
//               //                                   children: <Widget>[
//               //                                     Text('3 MONTHS INTO THE FUTURE',
//               //                                       style: TextStyle(
//               //                                         fontFamily: 'Urbanist',
//               //                                         fontSize: 12,
//               //                                         color: _bookingWindow == 'Months3' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//               //                                       ),
//               //                                     ),
//               //                                   ],
//               //                                 ),
//               //                               ],
//               //                             ),
//               //                           ),
//               //                         ),
//               //                       ],
//               //                     ),
//               //                     SizedBox(height: 5),
//               //                     Row(
//               //                       children: <Widget>[
//               //                         Expanded(
//               //                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//               //                             elevation: 0.0,
//               //                             padding: EdgeInsets.all(16.0),
//               //                             onPressed: () {
//               //                               setState(() {
//               //                                 _bookingWindow = 'Months6';
//               //                               });
//               //                             },
//               //                             color: _bookingWindow == 'Months6' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//               //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//               //                             child: Column(
//               //                               children: <Widget>[
//               //                                 Row(
//               //                                   mainAxisAlignment: MainAxisAlignment.center,
//               //                                   children: <Widget>[
//               //                                     Text('6 MONTHS INTO THE FUTURE',
//               //                                       style: TextStyle(
//               //                                         fontFamily: 'Urbanist',
//               //                                         fontSize: 12,
//               //                                         color: _bookingWindow == 'Months6' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//               //                                       ),
//               //                                     ),
//               //                                   ],
//               //                                 ),
//               //                               ],
//               //                             ),
//               //                           ),
//               //                         ),
//               //                       ],
//               //                     ),
//               //                     SizedBox(height: 5),
//               //                     Row(
//               //                       children: <Widget>[
//               //                         Expanded(
//               //                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//               //                             elevation: 0.0,
//               //                             padding: EdgeInsets.all(16.0),
//               //                             onPressed: () {
//               //                               setState(() {
//               //                                 _bookingWindow = 'Months12';
//               //                               });
//               //                             },
//               //                             color: _bookingWindow == 'Months12' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//               //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//               //                             child: Column(
//               //                               children: <Widget>[
//               //                                 Row(
//               //                                   mainAxisAlignment: MainAxisAlignment.center,
//               //                                   children: <Widget>[
//               //                                     Text('12 MONTHS INTO THE FUTURE',
//               //                                       style: TextStyle(
//               //                                         fontFamily: 'Urbanist',
//               //                                         fontSize: 12,
//               //                                         color: _bookingWindow == 'Months12' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//               //                                       ),
//               //                                     ),
//               //                                   ],
//               //                                 ),
//               //                               ],
//               //                             ),
//               //                           ),
//               //                         ),
//               //                       ],
//               //                     ),
//               //                     SizedBox(height: 5),
//               //                     Row(
//               //                       children: <Widget>[
//               //                         Expanded(
//               //                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//               //                             elevation: 0.0,
//               //                             padding: EdgeInsets.all(16.0),
//               //                             onPressed: () {
//               //                               setState(() {
//               //                                 _bookingWindow = 'BookingWindowUndefined';
//               //                               });
//               //                             },
//               //                             color: _bookingWindow == 'BookingWindowUndefined' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//               //                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//               //                             child: Column(
//               //                               children: <Widget>[
//               //                                 Row(
//               //                                   mainAxisAlignment: MainAxisAlignment.center,
//               //                                   children: <Widget>[
//               //                                     Text('DATES UNAVAILABLE BY DEFAULT',
//               //                                       style: TextStyle(
//               //                                         fontFamily: 'Urbanist',
//               //                                         fontSize: 12,
//               //                                         color: _bookingWindow == 'BookingWindowUndefined' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//               //                                       ),
//               //                                     ),
//               //                                   ],
//               //                                 ),
//               //                               ],
//               //                             ),
//               //                           ),
//               //                         ),
//               //                       ],
//               //                     ),
//               //                   ],
//               //                 ),
//               //               ),
//               //             ),
//               //           ),
//               //         ],
//               //       ),
//               //     ),
//               //   ],
//               // ),
//               // SizedBox(height: 10),
//               // Shortest trip
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
//                             child: Container(
//                               child: Column(
//                                 children: <Widget>[
//                                   Padding(
//                                     padding: EdgeInsets.all(16.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: <Widget>[
//                                         Text('Shortest trip',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text(_shortestTripToString,
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
//                                           child:
//                                           SliderTheme(
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
//                                               min: 1.0,
//                                               max: 4.0,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   int _value = values.round();
//
//                                                   switch(_value) {
//                                                     case 1:
//                                                       _shortestTripToString = '1 hour';
//                                                       break;
//                                                     case 2:
//                                                       _shortestTripToString = '1 day (24hrs)';
//                                                       break;
//                                                     case 3:
//                                                       _shortestTripToString = '1 week';
//                                                       break;
//                                                     case 4:
//                                                       _shortestTripToString = '1 month';
//                                                       break;
//                                                   }
//                                                   _shortestTrip = values;
//                                                 });
//                                               },
//                                               value: _shortestTrip,
//                                               divisions: 3,
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
//               // Longest trip
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
//                             child: Container(
//                               child: Column(
//                                 children: <Widget>[
//                                   Padding(
//                                     padding: EdgeInsets.all(16.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: <Widget>[
//                                         Text('Longest trip',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text(_longestTripToString,
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
//                                               min: 1.0,
//                                               max: 7.0,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   int _value = values.round();
//
//                                                   switch(_value) {
//                                                     case 1:
//                                                       _longestTripToString = '1 day';
//                                                       break;
//                                                     case 2:
//                                                       _longestTripToString = '3 days';
//                                                       break;
//                                                     case 3:
//                                                       _longestTripToString = '5 days';
//                                                       break;
//                                                     case 4:
//                                                       _longestTripToString = '1 week';
//                                                       break;
//                                                     case 5:
//                                                       _longestTripToString = '2 weeks';
//                                                       break;
//                                                     case 6:
//                                                       _longestTripToString = '1 month';
//                                                       break;
//                                                     case 7:
//                                                       _longestTripToString = 'Any';
//                                                       break;
//                                                   }
//
//                                                   _longestTrip = values;
//                                                 });
//                                               },
//                                               value: _longestTrip,
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
//               // Manage calendar
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
//                                       Text('Manage your calendar',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   SizedBox(height: 5),
//                                   Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: <Widget>[
//                                             Text('Select dates to block or unblock.',
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
//                                   SizedBox(height: 20),
//                                   Row(
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: SomeCalendar(
//                                           primaryColor: Color(0xFFFF8F68),
//                                           textColor: Color(0xff353B50),
//                                           mode: SomeMode.Multi,
//                                           isWithoutDialog: true,
//                                           scrollDirection: Axis.horizontal,
//                                           selectedDates: selectedDates,
//                                           startDate: Jiffy().subtract(years: 3),
//                                           lastDate: Jiffy().add(months: 9),
//                                           done: (date) {
//                                             setState(() {
//                                               selectedDates = date;
//
//                                               // showSnackbar(selectedDates.toString());
//                                             });
//                                           },
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
//               // Section header
//               _swapEnabled ? Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Swap area',
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
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 10) : new Container(),
//               _swapEnabled ? Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Text('Select the maximum distance for visibility of your vehicle by other hosts looking to swap',
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
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 10) : new Container(),
//               // Swap within
//               _swapEnabled ? Row(
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
//                             child: Container(
//                               child: Column(
//                                 children: <Widget>[
//                                   Padding(
//                                     padding: EdgeInsets.all(16.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: <Widget>[
//                                         Text('Swap within',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text(_swapWithin.round().toString() + ' km',
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
//                                             data:
//                                             SliderThemeData(
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
//                                               min: 1.0,
//                                               max: 200.0,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   _swapWithin = values;
//                                                 });
//                                               },
//                                               value: _swapWithin,
//                                               // divisions: 3,
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
//               ) : new Container(),
//               // Section header
//               _swapEnabled ? SizedBox(height: 30) : new Container(),
//               _swapEnabled ? Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Swap vehicle types',
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
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 10) : new Container(),
//               _swapEnabled ? Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Text('Select the types of vehicles that you are interested in swapping your vehicle for.',
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
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 10) : new Container(),
//               // Economy & Compact
//               _swapEnabled ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                                 _economy = !_economy;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Economy',
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
//                                   color: _economy ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 10),
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
//                                 _compact = !_compact;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Compact',
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
//                                   color: _compact ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 10) : new Container(),
//               // Mid-Size & Full-Size
//               _swapEnabled ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                                 _midSize = !_midSize;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Mid-Size',
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
//                                   color: _midSize ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 10),
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
//                                 _fullSize = !_fullSize;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Full-Size',
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
//                                   color: _fullSize ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 10) : new Container(),
//               // Sport
//               _swapEnabled ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                                 _sports = !_sports;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Sport',
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
//                                   color: _sports ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: new Container(),
//                   ),
//                 ],
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 20) : new Container(),
//               // Compact SUV & Mid-Size SUV
//               _swapEnabled ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                                 _compactSUV = !_compactSUV;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Compact SUV',
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
//                                   color: _compactSUV ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 10),
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
//                                 _midSizeSUV = !_midSizeSUV;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Mid-Size SUV',
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
//                                   color: _midSizeSUV ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 10) : new Container(),
//               // Full-Size SUV & Sport SUV
//               _swapEnabled ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                                 _fullSizeSUV = !_fullSizeSUV;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Full-Size SUV',
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
//                                   color: _fullSizeSUV ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 10),
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
//                                 _sportsSUV = !_sportsSUV;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Sport SUV',
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
//                                   color: _sportsSUV ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 20) : new Container(),
//               // Pick-up truck & Minivan
//               _swapEnabled ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                                 _pickupTruck = !_pickupTruck;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Pick-up truck',
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
//                                   color: _pickupTruck ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 10),
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
//                                 _minivan = !_minivan;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Minivan',
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
//                                   color: _minivan ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 10) : new Container(),
//               // Van
//               _swapEnabled ? Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
//                                 _van = !_van;
//                               });
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Van',
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
//                                   color: _van ? Color(0xFFFF8F68) : Colors.transparent,
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: new Container(),
//                   ),
//                 ],
//               ) : new Container(),
//               _swapEnabled ? SizedBox(height: 30) : new Container(),
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
//
//                               var res = await setCarAvailability();
//
//                               var arguments = json.decode(res.body!);
//
//                               if (res != null) {
//                                 Navigator.pushNamed(
//                                   context,
//                                   '/review_your_listing',
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
//                             ) : Text('Next',
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
//       ),
//     );
//   }
//   // void showSnackbar(String x) {
//   //   _scaffoldKey.currentState.showSnackBar(SnackBar(
//   //     content: Text(x),
//   //   ));
//   // }
// }
//
// Future<http.Response> setCarAvailability() async {
//   var res;
//
//   try {
//     res = await http.post(
//       '$SERVER_IP/v1/car.CarService/SetAvailability',
//       body: json.encode(
//         {
//           "CarID": _carID,
//           "Availability": {
//             "RentalAvailability": {
//               "AdvanceNotice": _advanceNotice,
//               "SameDayCutOffTime": {
//                 "hours": double.parse(_sameDayCutOff.toString()).round().toString(),
//                 "minutes": 0,
//                 "seconds": 0,
//                 "nanos": 0
//               },
//               "BookingWindow": _bookingWindow  != '' ? _bookingWindow : 'BookingWindowUndefined',
//               "ShortestTrip": double.parse(_shortestTrip.toString()).round().toString(),
//               "LongestTrip": double.parse(_longestTrip.toString()).round().toString()
//             },
//             "SwapAvailability": {
//               "SwapWithin": double.parse(_swapWithin.toString()).round().toString(),
//               "SwapVehiclesType": {
//                 "Economy": _economy,
//                 "Compact": _compact,
//                 "MidSize": _midSize,
//                 "FullSize": _fullSize,
//                 "Sports": _sports,
//                 "CompactSUV": _compactSUV,
//                 "MidSizeSUV": _midSizeSUV,
//                 "FullSizeSUV": _fullSizeSUV,
//                 "SportsSUV": _sportsSUV,
//                 "PickupTruck": _pickupTruck,
//                 "Minivan": _minivan,
//                 "Van": _van
//               }
//             },
//             "Completed": true
//           }
//         }
//       ),
//     );
//   } catch (error) {
//
//   }
//
//   return res;
// }