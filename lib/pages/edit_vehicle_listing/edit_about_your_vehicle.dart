// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json;
//
// import 'package:image_picker/image_picker.dart';
//
// import 'dart:io';
// import 'package:path/path.dart' as Path;
// import 'package:async/async.dart';
// import 'package:flutter/services.dart';
//
// import '../google_map.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// const SERVER_IP = 'https://api.car!.ridealike.com';
//
// var _carData =  {
//   "_carID": '',
//   "_type": '',
//   "_year": DateTime.now().year.toString(),
//   "_make": '',
//   "_model": '',
//   "_bodyTrim": '',
//   "_style": '',
//   "_vehicleDescription": '',
//   "_locationAddress": '',
//   "_locationLatitude": '',
//   "_locationLongitude": '',
//   "_locationNotes": '',
//   "_carOwnedBy": "Myself",
//   "_neverBrandedOrSalvageTitle": false
// };
//
// int _descriptionCharCount = 0;
// int _locationNoteCharCount = 0;
//
// final TextEditingController _notesController = TextEditingController();
// final TextEditingController _locationNotes = TextEditingController();
//
// class EditAboutYourVehicle extends StatefulWidget {
//   @override
//   State createState() => EditAboutYourVehicleState();
// }
//
// class EditAboutYourVehicleState extends State<EditAboutYourVehicle> {
//
//   bool _isButtonDisabled = true;
//   bool _isButtonPressed = false;
//   final storage = new FlutterSecureStorage();
//
//   @override
//   void initState() {
//     super.initState();
//
//     Future.delayed(Duration.zero,() async {
//       final Map _receivedData = ModalRoute.of(context).settings.arguments;
//
//       setState(() {
//         _notesController.text = _receivedData['Car']['About']['VehicleDescription'];
//         _locationNotes.text = _receivedData['Car']['About']['Location']['Notes'];
//
//         _carData['_carID'] = _receivedData['Car']['ID'];
//         _carData['_year'] = _receivedData['Car']['About']['Year'];
//         _carData['_make'] = _receivedData['Car']['About']['Make'];
//         _carData['_model'] = _receivedData['Car']['About']['Model'];
//         _carData['_bodyTrim'] = _receivedData['Car']['About']['CarBodyTrim'];
//         _carData['_style'] = _receivedData['Car']['About']['Style'];
//         _carData['_vehicleDescription'] = _receivedData['Car']['About']['VehicleDescription'];
//         _carData['_locationAddress'] = _receivedData['Car']['About']['Location']['Address'];
//         _carData['_locationLatitude'] = _receivedData['Car']['About']['Location']['LatLng']['Latitude'];
//         _carData['_locationLongitude'] = _receivedData['Car']['About']['Location']['LatLng']['Longitude'];
//         _carData['_locationNotes'] = _receivedData['Car']['About']['Location']['Notes'];
//         _carData['_carOwnedBy'] = _receivedData['Car']['About']['CarOwnedBy'];
//         _carData['_neverBrandedOrSalvageTitle'] = _receivedData['Car']['About']['NeverBrandedOrSalvageTitle'];
//       });
//     });
//   }
//
//   void openYearPicker(context) {
//     showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     builder: (BuildContext context) => Container(
//       width: MediaQuery.of(context).size.width,
//       height: MediaQuery.of(context).size.height * 0.60,
//       child: YearPicker(
//         selectedDate: DateTime(int.parse(_carData['_year'])),
//         firstDate: DateTime(DateTime.now().year - 49),
//         lastDate: DateTime(DateTime.now().year + 1),
//         onChanged: (val) {
//           setState(() {
//             _carData['_year'] =  val.year.toString();
//           });
//
//           Navigator.pop(context);
//         },
//       ),
//     ));
//   }
//
//   File ownsershipImageFile;
//
//   pickOwnershipImageFromGallery() async {
//     final picker = ImagePicker();
//
//     final img = await picker.getImage(
//       source: ImageSource.gallery,
//       imageQuality: 50,
//       maxHeight: 768,
//       maxWidth: 1366,
//       preferredCameraDevice: CameraDevice.rear
//     );
//
//     if (img != null) {
//       setState(() {
//         ownsershipImageFile = File(img.path);
//       });
//
//       var imageRes = await uploadImage(ownsershipImageFile);
//
//       if (json.decode(imageRes.body!)['Status'] == 'success') {
//         setState(() {
//           _carData['_carOwnershipDocumentID'] = json.decode(imageRes.body!)['FileID'];
//         });
//         _checkButtonDisability();
//       }
//     }
//   }
//
//   _checkButtonDisability() {
//     if (_carData['_make'] != "" && _carData['_model'] != "" && _carData['_bodyTrim'] != "" && _carData['_style'] != "" && _carData['_neverBrandedOrSalvageTitle']) {
//       setState(() {
//         _isButtonDisabled = false;
//       });
//     } else {
//       setState(() {
//         _isButtonDisabled = true;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     _countDescriptionCharacter(String value) {
//       setState(() {
//         _descriptionCharCount = value.length;
//       });
//     }
//
//     _countLocationNotesCharacter(String value) {
//       setState(() {
//         _locationNoteCharCount = value.length;
//       });
//     }
//
//     return Scaffold(
//         backgroundColor: Colors.white,
//
//         //App Bar
//         appBar: new AppBar(
//           leading: new IconButton(
//             icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
//             onPressed: () => Navigator.of(context).pop(),
//           ),
//           centerTitle: true,
//           title: Text('1/6',
//             style: TextStyle(
//               fontFamily: 'Urbanist',
//               fontSize: 16,
//               color: Color(0xff371D32),
//             ),
//           ),
//           actions: <Widget>[
//             Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 GestureDetector(
//                   onTap: () {
//                     Navigator.pushNamed(
//                       context,
//                       '/dashboard_tab'
//                     );
//                   },
//                   child: Center(
//                     child: Container(
//                       margin: EdgeInsets.only(right: 16),
//                       child: Text('Save & Exit',
//                         style: TextStyle(
//                           fontFamily: 'Urbanist',
//                           fontSize: 16,
//                           color: Color(0xFFFF8F62),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//           elevation: 0.0,
//         ),
//
//         //Content of tabs
//         body: _carData['_carID'] != '' ? new SingleChildScrollView(
//           child: GestureDetector(
//             onTap: () {
//             FocusScopeNode currentFocus = FocusScope.of(context);
//
//               if (!currentFocus.hasPrimaryFocus) {
//                 currentFocus.unfocus();
//               }
//             },
//
//             child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: <Widget>[
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
//                             child: Text('Tell us about your vehicle',
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
//                   Image.asset('icons/Car_Tell-Us-About-Car.png'),
//                 ],
//               ),
//               SizedBox(height: 30),
//               // What car do you have?
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Row(
//                             children: <Widget>[
//                               Text('Vehicle information',
//                                 style: TextStyle(
//                                   fontFamily: 'Urbanist',
//                                   fontSize: 18,
//                                   color: Color(0xFF371D32),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 20),
//               // Type
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
//                                 '/edit_car_type',
//                                 arguments: _carData
//                               );
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(children: [
//                                     Text('Type',
//                                       style: TextStyle(
//                                         fontFamily: 'Urbanist',
//                                         fontSize: 16,
//                                         color: Color(0xFF371D32),
//                                       ),
//                                     ),
//                                   ]),
//                                 ),
//                                 Container(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Text(_carData['_type'],
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 14,
//                                           color: Color(0xFF353B50),
//                                         ),
//                                       ),
//                                       Icon(
//                                         Icons.keyboard_arrow_right,
//                                         color: Color(0xFF353B50)
//                                       ),
//                                     ],
//                                   ),
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
//               // Year
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
//                             onPressed: () => openYearPicker(context),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Year',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Container(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Text(_carData['_year'],
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 14,
//                                           color: Color(0xFF353B50),
//                                         ),
//                                       ),
//                                       Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
//                                     ],
//                                   ),
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
//               // Make
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
//                                 '/edit_car_make',
// //                                '/pickup_and_return_location',
//                                 arguments: _carData
//                               );
//                             },
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Make',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Container(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Text(_carData['_make'],
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 14,
//                                           color: Color(0xFF353B50),
//                                         ),
//                                       ),
//                                       Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
//                                     ],
//                                   ),
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
//               // Model
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
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Model',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Container(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Text(_carData['_model'],
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 14,
//                                           color: Color(0xFF353B50),
//                                         ),
//                                       ),
//                                     Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
//                                     ],
//                                   ),
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
//               // Body trim
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
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Body trim',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Container(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Text(_carData['_bodyTrim'],
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 14,
//                                           color: Color(0xFF353B50),
//                                         ),
//                                       ),
//                                     Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
//                                     ],
//                                   ),
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
//               // Style
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
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: <Widget>[
//                                 Container(
//                                   child: Row(
//                                     children: [
//                                       Text('Style',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                     ]
//                                   ),
//                                 ),
//                                 Container(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Text(_carData['_style'],
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 14,
//                                           color: Color(0xFF353B50),
//                                         ),
//                                       ),
//                                     Icon(Icons.keyboard_arrow_right, color: Color(0xFF353B50)),
//                                     ],
//                                   ),
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
//               SizedBox(height: 35),
//               // Notes header
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Personalize your listing',
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
//               // Notes input
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Container(
//                             padding: EdgeInsets.all(16.0),
//                             decoration: BoxDecoration(
//                               color: Color(0xFFF2F2F2),
//                               borderRadius: BorderRadius.circular(8.0)
//                             ),
//                             child: Column(
//                               children: <Widget>[
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: <Widget>[
//                                     Text('Vehicle description',
//                                       style: TextStyle(
//                                         fontFamily: 'Urbanist',
//                                         fontSize: 16,
//                                         color: Color(0xFF371D32),
//                                       ),
//                                     ),
//                                     Text(_descriptionCharCount.toString() + '/500',
//                                       style: TextStyle(
//                                         fontFamily: 'Urbanist',
//                                         fontSize: 14,
//                                         color: Color(0xFF353B50),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 Column(
//                                   children: <Widget>[
//                                     TextFormField(
//                                       textInputAction: TextInputAction.done,
//                                       controller: _notesController,
//                                       onChanged: _countDescriptionCharacter,
//                                       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9.,&\- ]+$'))],
//                                       minLines: 1,
//                                       maxLines: 5,
//                                       maxLength: 500,
//                                       decoration: InputDecoration(
//                                         border: InputBorder.none,
//                                         hintText: 'You can entice guests to book your vehicle by providing more information, such as “very economical, fun to drive, etc.”',
//                                         hintStyle: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 14,
//                                           fontStyle: FontStyle.italic
//                                         ),
//                                         counterText: '',
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
//               SizedBox(height: 35),
//               // vehicle location
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Where is your vehicle located?',
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
//               // Text
//               SizedBox(height: 10),
//               Row(
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: Text('Enter the address where you would like your guests to pickup and return your vehicle. This information is visible only to Guests who have successfully booked your vehicle.',
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
//               SizedBox(height: 10),
//               // Google map
//               Container(
//                 height: 350,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.all(Radius.circular(8)),
//                   child: GoogleMapExample()
//                 ),
//               ),
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
//                                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                     children: <Widget>[
//                                       Text('Location notes (optional)',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFF371D32),
//                                         ),
//                                       ),
//                                       Text(_locationNoteCharCount.toString() + '/500',
//                                         style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 14,
//                                           color: Color(0xFF353B50),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   Column(
//                                     children: <Widget>[
//                                       TextFormField(
//                                         textInputAction: TextInputAction.done,
//                                           controller: _locationNotes,
//                                           onChanged: _countLocationNotesCharacter,
//                                           inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9.,&\- ]+$'))],
//                                           minLines: 1,
//                                           maxLines: 5,
//                                           maxLength: 500,
//                                           decoration: InputDecoration(
//                                             border: InputBorder.none,
//                                             hintText: 'Add notes how to locate your car. For example, what’s the access code to the garage or what’s the underground parking level?',
//                                             hintStyle: TextStyle(
//                                               fontFamily: 'Urbanist',
//                                               fontSize: 14,
//                                               fontStyle: FontStyle.italic
//                                             ),
//                                             counterText: '',
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
//                           child: Text('I’m listing a vehicle owned by',
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
//               SizedBox(height: 20),
//               // Select
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
//                                 GestureDetector(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Container(
//                                         height: 26,
//                                         width: 26,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: Colors.transparent,
//                                           border: Border.all(
//                                             color: Color(0xFF353B50),
//                                             width: 2,
//                                           ),
//                                         ),
//                                         child: Padding(
//                                           padding: EdgeInsets.all(7.0),
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               color: _carData['_carOwnedBy'] == "Myself" ? Color(0xFFFF8F62) : Colors.transparent,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Container(
//                                         child: Row(
//                                           children: <Widget>[
//                                             Text('Myself',
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
//                                   onTap: () {
//                                     setState(() {
//                                       _carData['_carOwnedBy'] = "Myself";
//                                     });
//                                     _checkButtonDisability();
//                                   },
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
//                           child: Container(
//                             padding: EdgeInsets.all(16.0),
//                             decoration: new BoxDecoration(
//                               color: Color(0xFFF2F2F2),
//                               borderRadius: new BorderRadius.circular(8.0),
//                             ),
//                             child: Column(
//                               children: <Widget>[
//                                 GestureDetector(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Container(
//                                         height: 26,
//                                         width: 26,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: Colors.transparent,
//                                           border: Border.all(
//                                             color: Color(0xFF353B50),
//                                             width: 2,
//                                           ),
//                                         ),
//                                         child: Padding(
//                                           padding: EdgeInsets.all(7.0),
//                                           child: Container(
//                                             decoration: BoxDecoration(
//                                               shape: BoxShape.circle,
//                                               color: _carData['_carOwnedBy'] == "Business" ? Color(0xFFFF8F62) : Colors.transparent,
//                                             ),
//                                           ),
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Container(
//                                         child: Row(
//                                           children: <Widget>[
//                                             Text('A business',
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
//                                   onTap: () {
//                                     setState(() {
//                                       _carData['_carOwnedBy'] = "Business";
//                                     });
//                                     _checkButtonDisability();
//                                   },
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
//               SizedBox(height: 20),
//               // Salvage
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
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               children: <Widget>[
//                                 GestureDetector(
//                                   child: Row(
//                                     children: <Widget>[
//                                       Container(
//                                         height: 26,
//                                         width: 26,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.rectangle,
//                                           color: Colors.transparent,
//                                           borderRadius: BorderRadius.circular(6.0),
//                                           border: Border.all(
//                                             color: Color(0xFF353B50),
//                                             width: 2,
//                                           ),
//                                         ),
//                                         child: Icon(
//                                           Icons.check,
//                                           size: 22,
//                                           color: _carData['_neverBrandedOrSalvageTitle'] ? Color(0xFFFF8F68) : Colors.transparent,
//                                         ),
//                                       ),
//                                       SizedBox(width: 10),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: <Widget>[
//                                             Text('This vehicle has never had a branded or salvage title',
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
//                                   onTap: () {
//                                     setState(() {
//                                       _carData['_neverBrandedOrSalvageTitle'] = !_carData['_neverBrandedOrSalvageTitle'];
//                                     });
//                                     _checkButtonDisability();
//                                   },
//                                 ),
//                                 SizedBox(height: 12),
//                                 SizedBox(
//                                   child: Text('A salvage title is a form of vehicle title branding, which notes that the vehicle has been damaged and/or deemed a total loss by an insurance company that paid a claim on it.',
//                                     style: TextStyle(
//                                       fontFamily: 'Urbanist',
//                                       fontSize: 14,
//                                       color: Color(0xFF353B50),
//                                     ),
//                                   ),
//                                 ),
//                                 SizedBox(height: 10),
//                               ],
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
//                 children: <Widget>[
//                   Expanded(
//                     child: Column(
//                       children: <Widget>[
//                         SizedBox(
//                           width: double.maxFinite,
//                           child: ElevatedButton(style: ElevatedButton.styleFrom(
//                             elevation: 0.0,
//                             color: Color(0xFFFF8F62),
//                             padding: EdgeInsets.all(16.0),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                             onPressed: _isButtonDisabled ? null : () async {
//                             // onPressed: () async {
//                               // setState(() {
//                               //   _isButtonDisabled = true;
//                               //   _isButtonPressed = true;
//                               // });
//
//                               var address = await GoogleMapExampleState.addressLine(GoogleMapExampleState.location);
//                               LatLng latLong = GoogleMapExampleState.location;
//                               // var res = await setPickupAndReturn(receivedData['Car']['ID'], GoogleMapExampleState.location, address);
//
//                               // print(address);
//                               // print(latLong.latitude);
//                               // print(latLong.longitude);
//
//                               _carData['_locationAddress'] =  address;
//                               _carData['_locationLatitude'] =  latLong.latitude;
//                               _carData['_locationLongitude'] =  latLong.longitude;
//
//                               var res = await setAbout(_carData);
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
//                               //     '/add_photos_to_your_listing',
//                               //     arguments: arguments,
//                               //   );
//                               // } else {
//                               //   setState(() {
//                               //     _isButtonDisabled = false;
//                               //     _isButtonPressed = false;
//                               //   });
//                               // }
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
//           ),
//       )
//       : Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[new CircularProgressIndicator()],
//         ),
//       ),
//     );
//   }
//
//   uploadImage(filename) async {
//     var stream = new http.ByteStream(DelegatingStream.typed(filename.openRead()));
//     var length = await filename.length();
//
//     var uri = Uri.parse('https://api.storage.ridealike.com/upload');
//     var request = new http.MultipartRequest("POST", uri);
//     var multipartFile = new http.MultipartFile('files', stream, length, filename: Path.basename(filename.path));
//
//     String jwt = await storage.read(key: 'jwt');
//     Map<String, String> headers = { "Authorization": "Bearer $jwt"};
//     request.headers.addAll(headers);
//
//     request.files.add(multipartFile);
//     var response = await request.send();
//
//     var response2 = await http.Response.fromStream(response);
//
//     return response2;
//   }
// }
//
// Future<http.Response> setAbout(carData) async {
//   var res;
//
//   try {
//     res = await http.post('$SERVER_IP/v1/car.CarService/SetAbout',
//       body: json.encode(
//         {
//           "CarID": carData['_carID'],
//           "About": {
//             "Year": carData['_year'],
//             "Make": carData['_make'],
//             "Model": carData['_model'],
//             "CarBodyTrim": carData['_bodyTrim'],
//             "Style": carData['_style'],
//             "VehicleDescription": _notesController.text,
//             "Location": {
//               "Address": carData['_locationAddress'],
//               "LatLng": {
//                 "Latitude": carData['_locationLatitude'],
//                 "Longitude": carData['_locationLongitude']
//               },
//               "Notes": _locationNotes.text,
//             },
//             "NeverBrandedOrSalvageTitle": carData['_neverBrandedOrSalvageTitle'],
//             "CarOwnedBy": carData['_carOwnedBy'],
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