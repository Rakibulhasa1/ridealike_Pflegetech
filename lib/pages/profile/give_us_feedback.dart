import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;


class ProfileFeedback extends StatefulWidget {
  @override
  _ProfileFeedbackState createState() => _ProfileFeedbackState();
}

class _ProfileFeedbackState extends State<ProfileFeedback> {
  Map? receivedData;
  bool _isButtonPressed = false;
  int _aboutMeCharCount=0;
  String txt ='';
  final TextEditingController _feedbackTextController = TextEditingController();
  _countAboutMeCharacter(String value) {
    if(value.length>9){
      // FocusScope.of(context).requestFocus(FocusNode());
    }

    setState(() {
      _aboutMeCharCount = value.length;



    });

  }
  @override
  void dispose() {
    super.dispose();

  }
  @override
  void initState() {
    super.initState();

      // setState(() {
      //   _aboutMeCharCount = _feedbackTextController.text.length;
      // });

  }
  @override
  Widget build(BuildContext context) {
    receivedData = ModalRoute.of(context)!.settings.arguments as Map;
    print(receivedData!['UserID']);

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: new AppBar(
        centerTitle: true,
        title: Text(
          'Give us feedback',
          style: TextStyle(
              color: Color(0xff371D32), fontSize: 16, fontFamily: 'Urbanist'),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
       child:  Padding(
         padding: EdgeInsets.all(16.0),
         child: Column(
           mainAxisAlignment: MainAxisAlignment.spaceBetween,
           crossAxisAlignment: CrossAxisAlignment.end,
           children: <Widget>[
             Column(
               children: [
                 Container(
                   child: Padding(
                     padding: const EdgeInsets.all(8.0),
                     child: Text(
                       'Let us know how can we improve RideAlike!',
                       style: TextStyle(
                           fontSize: 16,
                           color: Color(0xff371D32),
                           fontFamily: 'Urbanist'),
                       textAlign: TextAlign.start,
                     ),
                   ),
                 ),
                 SizedBox(height: 10.0),
                 Column(
                   children: [
                     // Text field
                     Row(
                       children: <Widget>[
                         Expanded(
                           child: Column(
                             children: [
                               SizedBox(
                                 width: double.maxFinite,
                                 child: Container(
                                   decoration: BoxDecoration(
                                       color: Color(0xFFF2F2F2),
                                       borderRadius: BorderRadius.circular(8.0)),
                                   child: Padding(
                                     padding: EdgeInsets.all(16.0),
                                     child: Column(
                                       children: <Widget>[

                                         Column(
                                           children: <Widget>[
                                             TextFormField(
                                               textInputAction:
                                               TextInputAction.done,
                                               controller: _feedbackTextController,
                                               onChanged: _countAboutMeCharacter,

                                               minLines: 1,
                                               maxLines: 5,
                                               maxLength: 500,
                                               decoration: InputDecoration(
                                                 border: InputBorder.none,
                                                 focusedBorder: InputBorder.none,
                                                 enabledBorder: InputBorder.none,
                                                 errorBorder: InputBorder.none,
                                                 disabledBorder: InputBorder.none,
                                                 labelStyle: TextStyle(
                                                   fontFamily: 'Urbanist',
                                                   fontSize: 16,
                                                   color: Color(0xFF371D32),
                                                 ),
                                                 hintText:
                                                 'Please add feedback',
                                                 hintStyle: TextStyle(
                                                     fontFamily:
                                                     'Urbanist',
                                                     fontSize: 14,
                                                     fontStyle:
                                                     FontStyle.italic),
                                                 // counterText: '',
                                               ),
                                             ),
                                           ],
                                         ),
                                       ],
                                     ),
                                   ),
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ],
                 ),
               ],
             ),
             SizedBox(height: 20),
             Column(crossAxisAlignment: CrossAxisAlignment.end,
               children: [
                 Row(
                   children: [
                     Expanded(
                       child: Column(
                         children: [
                           SizedBox(
                             width: double.maxFinite,
                             child: ElevatedButton(
                               style: ElevatedButton.styleFrom(
                                 elevation: 0.0,
                                 backgroundColor: Color(0xffFF8F68),
                                 // textColor: Colors.white,
                                 padding: EdgeInsets.all(16.0),
                                 shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(8.0)),

                               ),
                               onPressed: _isButtonPressed || _feedbackTextController.text==''||_aboutMeCharCount==0
                                   ? null
                                   : () async {

                                 setState(() {
                                   _isButtonPressed = true;
                                 });
                                 await giveFeedback(receivedData!['UserID'], _feedbackTextController.text);
                                 // Navigator.pushNamed(context, '/support_details');
                                 Navigator.pop(context);
                               },
                               child: _isButtonPressed
                                   ? SizedBox(
                                 height: 18.0,
                                 width: 18.0,
                                 child: new CircularProgressIndicator(
                                     strokeWidth: 2.5),
                               )
                                   : Text(
                                 'Send',
                                 style: TextStyle(
                                     fontFamily: 'Urbanist',
                                     fontSize: 18,
                                     color: Colors.white),
                               ),
                             ),
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               ],
             ),
           ],
         ),
       ),
      ),
    );
  }
}

Future<RestApi.Resp> giveFeedback(_userID, _feedback) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    feedbackUrl,
    json.encode({
      "Feedback": {"UserID": _userID, "Feedback": _feedback}
    }),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}
