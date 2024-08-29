// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
//
// import 'package:http/http.dart' as http;
// import 'dart:convert' show Utf8Decoder, json;
//
// import 'package:flutter/services.dart';
// import 'package:ridealike/pages/common/constant_url.dart';
//
//
// class CreateProfileView extends StatefulWidget {
//   @override
//   State createState() => CreateProfileViewState();
// }
//
// class CreateProfileViewState extends State<CreateProfileView> {
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//
//   bool _isButtonDisabled = true;
//   bool _isButtonPressed = false;
//   bool _hidePassword = true;
//   bool _hasError = false;
//
//   bool _termsAndCondition = true;
//   bool _promotionalMaterials = false;
//
//   bool _error1 = false;
//   bool _error2 = false;
//   bool _error3 = false;
//
//   final storage = new FlutterSecureStorage();
//
//   String _sameEmailError = '';
//   bool _hasSameEmailError = false;
//
//   @override
//   void initState() {
//     super.initState();
//
//     _firstNameController.addListener(_checkInputValue);
//     _lastNameController.addListener(_checkInputValue);
//     _emailController.addListener(_checkInputValue);
//     _passwordController.addListener(_checkInputValue);
//     _lastNameController.addListener(_checkInputValue);
//   }
//
//   @override
//   void dispose() {
//     // Clean up the controller when the widget is removed from the widget tree.
//     // This also removes the _printLatestValue listener.
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   void _checkInputValue() {
//     var firstName = _firstNameController.text;
//     var lastName = _lastNameController.text;
//     var email = _emailController.text;
//     var password = _passwordController.text;
//
//     if (firstName != "" && lastName != "" && email != "" && password != "" && _termsAndCondition) {
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
//   Widget build(BuildContext context) => new Scaffold(
//     backgroundColor: Colors.white,
//
//     //App Bar
//     appBar: new AppBar(
//       leading: new IconButton(
//         icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
//         onPressed: () {
//           Navigator.pushNamed(
//             context,
//             '/create_profile_or_sign_in'
//           );
//         },
//       ),
//       elevation: 0.0,
//     ),
//
//     body: new SingleChildScrollView(
//       child: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           children: <Widget>[
//             // Header
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: Container(
//                           child: Text('Create a profile',
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
//                 Image.asset('icons/Profile_Create-Profile.png'),
//               ],
//             ),
//             SizedBox(height: 25),
//             // First name
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF2F2F2),
//                             borderRadius: BorderRadius.circular(8.0)
//                           ),
//                           child: TextFormField(
//                             controller: _firstNameController,
//                             inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'^[a-zA-Z ]+$')))],
//                             textCapitalization: TextCapitalization.sentences,
//                             decoration: InputDecoration(
//                               contentPadding: EdgeInsets.all(22.0),
//                               border: InputBorder.none,
//                               labelText: 'First name',
//                               labelStyle: TextStyle(
//                                 fontFamily: 'Urbanist',
//                                 fontSize: 12,
//                                 color: Color(0xFF353B50),
//                               ),
//                               hintText: 'Enter first name'
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             // Last name
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF2F2F2),
//                             borderRadius: BorderRadius.circular(8.0)
//                           ),
//                           child: TextFormField(
//                             controller: _lastNameController,
//                             inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'^[a-zA-Z ]+$')))],
//                             textCapitalization: TextCapitalization.sentences,
//                             decoration: InputDecoration(
//                               contentPadding: EdgeInsets.all(22.0),
//                               border: InputBorder.none,
//                               labelText: 'Last name',
//                               labelStyle: TextStyle(
//                                 fontFamily: 'Urbanist',
//                                 fontSize: 12,
//                                 color: Color(0xFF353B50),
//                               ),
//                               hintText: 'Enter last name'
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             // Email
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF2F2F2),
//                             borderRadius: BorderRadius.circular(8.0)
//                           ),
//                           child: TextFormField(
//                             controller: _emailController,
//                             inputFormatters: [FilteringTextInputFormatter.allow((RegExp(r'^[a-zA-Z0-9@._-]+$')))],
//                             decoration: InputDecoration(
//                               contentPadding: EdgeInsets.all(22.0),
//                               border: InputBorder.none,
//                               labelText: 'Email',
//                               labelStyle: TextStyle(
//                                 fontFamily: 'Urbanist',
//                                 fontSize: 12,
//                                 color: Color(0xFF353B50),
//                               ),
//                               hintText: 'Please enter email'
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(height: 10),
//             _hasSameEmailError ? Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text(_sameEmailError,
//                         style: TextStyle(
//                           fontFamily: 'Urbanist',
//                           fontSize: 14,
//                           color: Color(0xFFF55A51),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ) : new Container(),
//             _hasSameEmailError ? SizedBox(height: 15) : new Container(),
//             // Password
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Color(0xFFF2F2F2),
//                             borderRadius: BorderRadius.circular(8.0),
//                             border: Border.all(color: _hasError ? Color(0xFFF55A51) : Colors.transparent),
//                           ),
//                           child: TextFormField(
//                             controller: _passwordController,
//                             obscureText: _hidePassword,
//                             decoration: InputDecoration(
//                               contentPadding: EdgeInsets.all(22.0),
//                               border: InputBorder.none,
//                               labelText: 'Password',
//                               labelStyle: TextStyle(
//                                 fontFamily: 'Urbanist',
//                                 fontSize: 12,
//                                 color: Color(0xFF353B50),
//                               ),
//                               hintText: 'Please enter password',
//                               suffixIcon: GestureDetector(
//                                 onTap: () {
//                                   setState(() {
//                                     _hidePassword = !_hidePassword;
//                                   });
//                                 },
//                                 child: Image.asset('icons/Show_Password.png'),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             _hasError ? Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Text('Your password needs to:',
//                         style: TextStyle(
//                           fontFamily: 'Urbanist',
//                           fontSize: 14,
//                           color: Color(0xFFF55A51),
//                         ),
//                       ),
//                       SizedBox(height: 5),
//                       Text('• Be at least 8 characters long',
//                         style: TextStyle(
//                           fontFamily: 'Urbanist',
//                           fontSize: 14,
//                           color: _error1 ? Color(0xFFF55A51) : Color(0xFF5CAEAC),
//                         ),
//                       ),
//                       Text('• Include both lower and upper case',
//                         style: TextStyle(
//                           fontFamily: 'Urbanist',
//                           fontSize: 14,
//                           color: _error2 ? Color(0xFFF55A51) : Color(0xFF5CAEAC),
//                         ),
//                       ),
//                       Text('• Include at least 1 number or symbol',
//                         style: TextStyle(
//                           fontFamily: 'Urbanist',
//                           fontSize: 14,
//                           color: _error3 ? Color(0xFFF55A51) : Color(0xFF5CAEAC),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ) : new Container(),
//             SizedBox(height: 30),
//             // Terms & Conditions
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: Container(
//                           padding: EdgeInsets.all(16.0),
//                           decoration: new BoxDecoration(
//                             color: Color(0xFFF2F2F2),
//                             borderRadius: new BorderRadius.circular(8.0),
//                           ),
//                           child: Column(
//                             children: <Widget>[
//                               GestureDetector(
//                                 child: Row(
//                                   children: <Widget>[
//                                     Container(
//                                       height: 26,
//                                       width: 26,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.rectangle,
//                                         color: Colors.transparent,
//                                         borderRadius: BorderRadius.circular(6.0),
//                                         border: Border.all(
//                                           color: Color(0xFF353B50),
//                                           width: 2,
//                                         ),
//                                       ),
//                                       child: Icon(
//                                         Icons.check,
//                                         size: 22,
//                                         color: _termsAndCondition ? Color(0xFFFF8F68) : Colors.transparent,
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           SizedBox(
//                                             width: double.maxFinite,
//                                             child: RichText(
//                                               text: TextSpan(
//                                                 style: TextStyle(
//                                                   fontFamily: 'Urbanist',
//                                                   fontSize: 14,
//                                                   color: Color(0xFF353B50),
//                                                 ),
//                                                 children: <TextSpan>[
//                                                   TextSpan(text: 'I agree to RideAlike '),
//                                                   TextSpan(text: 'Terms & Conditions ',
//                                                     style: TextStyle(
//                                                       fontWeight: FontWeight.bold
//                                                     ),
//                                                   ),
//                                                   TextSpan(text: 'and'),
//                                                   TextSpan(text: ' Privacy Policy',
//                                                     style: TextStyle(
//                                                       fontWeight: FontWeight.bold
//                                                     ),
//                                                   ),
//                                                 ]
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 onTap: () {
//                                   setState(() {
//                                     _termsAndCondition = !_termsAndCondition;
//                                   });
//                                   _checkInputValue();
//                                 },
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
//             SizedBox(height: 10),
//             // Promotional Materials
//             Row(
//               children: <Widget>[
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: Container(
//                           padding: EdgeInsets.all(16.0),
//                           decoration: new BoxDecoration(
//                             color: Color(0xFFF2F2F2),
//                             borderRadius: new BorderRadius.circular(8.0),
//                           ),
//                           child: Column(
//                             children: <Widget>[
//                               GestureDetector(
//                                 child: Row(
//                                   children: <Widget>[
//                                     Container(
//                                       height: 26,
//                                       width: 26,
//                                       decoration: BoxDecoration(
//                                         shape: BoxShape.rectangle,
//                                         color: Colors.transparent,
//                                         borderRadius: BorderRadius.circular(6.0),
//                                         border: Border.all(
//                                           color: Color(0xFF353B50),
//                                           width: 2,
//                                         ),
//                                       ),
//                                       child: Icon(
//                                         Icons.check,
//                                         size: 22,
//                                         color: _promotionalMaterials ? Color(0xFFFF8F68) : Colors.transparent,
//                                       ),
//                                     ),
//                                     SizedBox(width: 10),
//                                     Expanded(
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: <Widget>[
//                                           Text(
//                                             'I agree to receive promotional materials and product updates.',
//                                             style: TextStyle(
//                                               fontFamily: 'Urbanist',
//                                               fontSize: 14,
//                                               color: Color(0xFF353B50),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 onTap: () {
//                                   setState(() {
//                                     _promotionalMaterials = !_promotionalMaterials;
//                                   });
//                                 },
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
//             SizedBox(height: 20),
//             // Next button
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       SizedBox(
//                         width: double.maxFinite,
//                         child: ElevatedButton(style: ElevatedButton.styleFrom(
//                           elevation: 0.0,
//                           color: Color(0xffFF8F68),
//                           padding: EdgeInsets.all(16.0),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                           onPressed: _isButtonDisabled ? null : () async {
//                             var firstName = _firstNameController.text;
//                             var lastName = _lastNameController.text;
//                             var email = _emailController.text;
//                             var password = _passwordController.text;
//
//                             if (password.length < 8 || !validateCharCase(password) || !validateSpecChar(password)) {
//                               setState(() {
//                                 _hasError = true;
//                               });
//                               if (password.length < 8) {
//                                 setState(() {
//                                   _error1 = true;
//                                 });
//                               } else {
//                                 setState(() {
//                                   _error1 = false;
//                                 });
//                               }
//
//                               if (!validateCharCase(password)) {
//                                 setState(() {
//                                   _error2 = true;
//                                 });
//                               } else {
//                                 setState(() {
//                                   _error2 = false;
//                                 });
//                               }
//
//                               if (!validateSpecChar(password)) {
//                                 setState(() {
//                                   _error3 = true;
//                                 });
//                               } else {
//                                 setState(() {
//                                   _error3 = false;
//                                 });
//                               }
//
//                             } else {
//                               setState(() {
//                                 _hasError = false;
//                               });
//                             }
//
//                             if (!_hasError) {
//                               setState(() {
//                                 _isButtonDisabled = true;
//                                 _isButtonPressed = true;
//                               });
//
//                               var res = await attemptSignUp(firstName, lastName, email, password);
//
//                               if (res.statusCode == 200) {
//                                 var arguments = json.decode(res.body!);
//
//                                 await storage.deleteAll();
//
//                                 await storage.write(key: 'profile_id', value: arguments['User']['ProfileID']);
//                                 await storage.write(key: 'user_id', value: arguments['User']['UserID']);
//                                 await storage.write(key: 'jwt', value: arguments['JWT']);
//
//                                 await acceptTermsPolicy(arguments['User']['ProfileID']);
//                                 await sendEmailVerificationLink(arguments['User']['UserID']);
//
//                                 // if (_promotionalMaterials) {
//                                 //   await acceptPromotion(arguments['User']['ProfileID']);
//                                 // }
//
//                                 Navigator.pushNamed(
//                                   context, '/verify_phone_number',
//                                   arguments: arguments
//                                 );
//                               } else {
//                                 setState(() {
//                                   _isButtonDisabled = false;
//                                   _isButtonPressed = false;
//                                   _sameEmailError = json.decode(res.body!)['details'][0]['Message'];
//                                   _hasSameEmailError = true;
//                                 });
//                               }
//                             } else {
//                               setState(() {
//                                 _isButtonDisabled = false;
//                                 _isButtonPressed = false;
//                               });
//                             }
//                           },
//                           child: _isButtonPressed ? SizedBox(
//                             height: 18.0,
//                             width: 18.0,
//                             child: new CircularProgressIndicator(strokeWidth: 2.5),
//                           ) : Text('Next',
//                             style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 18,
//                               color: Colors.white
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }
//
// validateCharCase(String value) {
//   String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z]).{2,}$';
//   RegExp regExp = new RegExp(pattern);
//   return regExp.hasMatch(value);
// }
// validateSpecChar(String value) {
//   String pattern = r'^(?=.*?[!@#\$&*~0-9]).{1,}$';
//   RegExp regExp = new RegExp(pattern);
//   return regExp.hasMatch(value);
// }
//
// Future<Resp> attemptSignUp(String firstName, String lastName, String email, String password) async {
//   var completer = Completer<Resp>();
//
//   callAPI(
//     registerUrl,
//     json.encode({
//       "Email": email,
//       "Password": password,
//       "FirstName": firstName,
//       "LastName": lastName
//     }),
//     ).then((resp) {
//       completer.complete(resp);
//     }
//   );
//
//   return completer.future;
// }
//
// Future<RestApi.Resp> sendEmailVerificationLink(_userID) async {
//   final completer=Completer<RestApi.Resp>();
//   RestApi.callAPI(sendEmailVerificationLinkUrl,  json.encode(
//       {
//         "UserID": _userID,
//       }
//   ),).then((resp){
//     completer.complete(resp);
//   });
//   return completer.future;
// }
//
// class Resp {
//   int statusCode;
//   String body;
//
//   Resp({
//     this.statusCode,
//     this.body,
//   });
// }
//
// Future<Resp> callAPI(String url, String payload) async {
//   var completer = Completer<Resp>();
//   var apiUrl = Uri.parse(url);
//   var client = HttpClient(); // `new` keyword optional
//
//   // Create request
//   HttpClientRequest request;
//   request = await client.postUrl(apiUrl);
//
//   // Write data
//   request.write(payload);
//
//   // Send the request
//   HttpClientResponse response;
//   response = await request.close();
//
//   // Handle the response
//   var resStream = response.transform(Utf8Decoder());
//   await for (var data in resStream) {
//     completer.complete(Resp(body: data, statusCode: response.statusCode));
//     break;
//   }
//
//   return completer.future;
// }
//
// Future<http.Response> acceptTermsPolicy(String profileID) async {
//   var res = await http.post(
//     acceptTermsAndConditionsUrl_userServer,
//     body: json.encode({
//       "ProfileID": profileID,
//     }),
//   );
//
//   return res;
// }
//
// Future<http.Response> acceptPromotion(String profileID) async {
//   var res = await http.post(
//     acceptPromotionalUpdatesUrl_userServer,
//     body: json.encode({
//       "ProfileID": profileID,
//     }),
//   );
//
//   return res;
// }
