// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json;
//
// const SERVER_IP = 'https://api.car!.ridealike.com';
//
// String _carID = '';
//
// double _perOneHour = 15.0;
// double _perOneDay = 99.0;
//
// double _perExtraKm = 0.3;
// double _perKmDeliveryFee = 1.0;
//
// double _oneWeekDiscount = 15.0;
// double _oneMonthDiscount = 20.0;
//
// String _oneTimeDiscountString = '';
// bool _oneTimeDiscount = false;
//
// bool _hasCustomDelivery = true;
//
// class EditVehiclePricing extends StatefulWidget {
//   @override
//   State createState() => EditVehiclePricingState();
// }
//
// class EditVehiclePricingState extends  State<EditVehiclePricing> {
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
//         _perOneHour = _receivedData['Car']['Pricing']['RentalPricing']['PerHour'].toDouble();
//         _perOneDay = _receivedData['Car']['Pricing']['RentalPricing']['PerDay'].toDouble();
//         // _perExtraKm = _receivedData['Car']['Pricing']['RentalPricing']['PerExtraKMOverLimit'].toDouble();
//         // _perKmDeliveryFee = _receivedData['Car']['Pricing']['RentalPricing']['PerKMRentalDeliveryFee'].toDouble();
//         _perKmDeliveryFee = 1.0;
//         _oneWeekDiscount = _receivedData['Car']['Pricing']['RentalPricing']['BookForWeekDiscountPercentage'].toDouble();
//         _oneMonthDiscount = _receivedData['Car']['Pricing']['RentalPricing']['BookForMonthDiscountPercentage'].toDouble();
//         _oneTimeDiscount = _receivedData['Car']['Pricing']['RentalPricing']['OneTime20DiscountForFirst3Users'];
//         _hasCustomDelivery = _receivedData['Car']['Pricing']['RentalPricing']['EnableCustomDelivery'];
//
//         setState(() {
//           if (_oneTimeDiscount) {
//             _oneTimeDiscountString = '1';
//           }
//         });
//       });
//     });
//   }
//
//   @override
//   Widget build (BuildContext context) {
//     bool _isButtonPressed = false;
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
//         title: Text('6/6',
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
//
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
//                             child: Text('Set your pricing',
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
//                   Image.asset('icons/Price-Tag_Pricing.png'),
//                 ],
//               ),
//               SizedBox(height: 20),
//               // Text
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('To help you set your rates, we make it easy with the suggested pricing below, based on analyzing your vehicle with our market data. You can change the rates to your preferred amounts.',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 16,
//                               color: Color(0xFF353B50),
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
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Vehicle rates',
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
//               // Per hour
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
//                                         Text('Per hour',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text('\$' + '${_perOneHour.round()}',
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
//                                     padding: EdgeInsets.only(right: 16.0, bottom: 0.0, left: 16.0, top: 0.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: <Widget>[
//                                         Text('Suggested: \$15',
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
//                                             child:
//                                             Slider(
//                                               min: 0.0,
//                                               max: 30.0,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   _perOneHour = values;
//                                                 });
//                                               },
//                                               value: _perOneHour,
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
//               // Per day
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
//                                         Text('Per day (24 consecutive hours)',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text('\$' + '${_perOneDay.round()}',
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
//                                     padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 0.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: <Widget>[
//                                         Text('Suggested: \$99',
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
//                                             child:
//                                             Slider(
//                                               min: 0.0,
//                                               max: 199.0,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   _perOneDay = values;
//                                                 });
//                                               },
//                                               value: _perOneDay,
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
//               SizedBox(height: 20),
//               // Section header
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Extras',
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
//               // Per km over the mileage allowance
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
//                                         Expanded(
//                                           child: Column(
//                                             children: <Widget>[
//                                               Text('Per km over the mileage allowance',
//                                                 style: TextStyle(
//                                                   fontFamily: 'Urbanist',
//                                                   fontSize: 16,
//                                                   color: Color(0xFF371D32),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Text('\$' + '${_perExtraKm.toStringAsFixed(2)}',
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
//                                     padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 0.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: <Widget>[
//                                         Text('Suggested: \$0.30',
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
//                                               min: 0.1,
//                                               max: 0.5,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   _perExtraKm = values;
//                                                 });
//                                               },
//                                               value: _perExtraKm,
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
//               // Custom delivery
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
//               SizedBox(height: 10),
//               // Per km delivery fee
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
//                                         Text('Per km delivery fee (rental only)',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text('\$' + '${_perKmDeliveryFee.toStringAsFixed(2)}',
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
//                                     padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 0.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: <Widget>[
//                                         Text('Suggested: \$1',
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
//                                               min: 0.5,
//                                               max: 1.5,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   _perKmDeliveryFee = values;
//                                                 });
//                                               },
//                                               value: _perKmDeliveryFee,
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
//               SizedBox(height: 20),
//               // Section header
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Discounts',
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
//               // 1 week discount
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
//                                         Text('1 week discount',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text('${_oneWeekDiscount.round()}' + '% off',
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
//                                     padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 0.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: <Widget>[
//                                         Text('Suggested: 15% off (\$439.00)',
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
//                                               max: 30.0,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   _oneWeekDiscount = values;
//                                                 });
//                                               },
//                                               value: _oneWeekDiscount,
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
//               // 1 month discount
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
//                                         Text('1 month discount',
//                                           style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             color: Color(0xFF371D32),
//                                           ),
//                                         ),
//                                         Text('${_oneMonthDiscount.round()}' + '% off',
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
//                                     padding: EdgeInsets.only(right: 16.0, bottom: 8.0, left: 16.0, top: 0.0),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.start,
//                                       children: <Widget>[
//                                         Text('Suggested: 20% off (\$1628.00)',
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
//                                               max: 40.0,
//                                               onChanged: (values) {
//                                                 setState(() {
//                                                   _oneMonthDiscount = values;
//                                                 });
//                                               },
//                                               value: _oneMonthDiscount,
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
//               // A one-time discount
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
//                                     children: <Widget>[
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: <Widget>[
//                                             Text('A one-time discount to your first 3 guests',
//                                               style: TextStyle(
//                                                 fontFamily: 'Urbanist',
//                                                 fontSize: 16,
//                                                 color: Color(0xFF371D32),
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
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: <Widget>[
//                                             Text('You can offer a 20% discount to your first 3 guests who rent your vehicle. This will help you to get initial rating and reviews.',
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
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             setState((){
//                                               _oneTimeDiscountString = '1';
//                                               _oneTimeDiscount = true;
//                                             });
//                                           },
//                                           child: Container(
//                                             height: 56.0,
//                                             decoration: new BoxDecoration(
//                                               color: _oneTimeDiscountString == '1' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                               borderRadius: new BorderRadius.circular(8.0),
//                                             ),
//                                             child: Column(
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: <Widget>[
//                                                 Row(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: <Widget>[
//                                                     Expanded(
//                                                       child: Text('OFFER 20% OFF',
//                                                         textAlign: TextAlign.center,
//                                                         style: TextStyle(
//                                                           fontFamily: 'Urbanist',
//                                                           fontSize: 12,
//                                                           color: _oneTimeDiscountString == '1' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Expanded(
//                                         child: GestureDetector(
//                                           onTap: () {
//                                             setState((){
//                                               _oneTimeDiscountString = '0';
//                                               _oneTimeDiscount = false;
//                                             });
//                                           },
//                                           child: Container(
//                                             height: 56.0,
//                                             decoration: new BoxDecoration(
//                                               color: _oneTimeDiscountString == '0' ? Color(0xFFFF8F62) : Color(0xFFE0E0E0).withOpacity(0.5),
//                                               borderRadius: new BorderRadius.circular(8.0),
//                                             ),
//                                             child: Column(
//                                               mainAxisAlignment: MainAxisAlignment.center,
//                                               children: <Widget>[
//                                                 Row(
//                                                   mainAxisAlignment: MainAxisAlignment.center,
//                                                   children: <Widget>[
//                                                     Expanded(
//                                                       child: Text("DON'T ADD AN OFFER",
//                                                         textAlign: TextAlign.center,
//                                                         style: TextStyle(
//                                                           fontFamily: 'Urbanist',
//                                                           fontSize: 12,
//                                                           color: _oneTimeDiscountString == '0' ? Color(0xFFFFFFFF) : Color(0xFF353B50).withOpacity(0.5),
//                                                         ),
//                                                       ),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               ],
//                                             ),
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
//
//                               var res = await setPricing();
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
// }
//
// Future<http.Response> setPricing() async {
//   var res;
//
//   try {
//     res = await http.post(
//       '$SERVER_IP/v1/car.CarService/SetPricing',
//       body: json.encode(
//         {
//           "CarID": _carID,
//           "Pricing": {
//             "RentalPricing": {
//               "PerHour": double.parse(_perOneHour.toString()).round(),
//               "PerDay": double.parse(_perOneDay.toString()).round(),
//               "PerExtraKMOverLimit": double.parse(_perExtraKm.toString()).round(),
//               "EnableCustomDelivery": _hasCustomDelivery,
//               "PerKMRentalDeliveryFee": double.parse(_perKmDeliveryFee.toString()).round(),
//               "BookForWeekDiscountPercentage": double.parse(_oneWeekDiscount.toString()).round(),
//               "BookForMonthDiscountPercentage": double.parse(_oneMonthDiscount.toString()).round(),
//               "OneTime20DiscountForFirst3Users": _oneTimeDiscount
//             },
//             "SwapPricing": {},
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