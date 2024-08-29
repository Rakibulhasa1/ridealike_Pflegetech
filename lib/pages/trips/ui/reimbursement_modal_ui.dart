import 'dart:io';

import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/reimbursement_bloc.dart';
import 'package:ridealike/pages/trips/response_model/reimbursment_response.dart';
import "package:ridealike/widgets/digit_formatter.dart";
import 'package:ridealike/widgets/experience_modal.dart';
class ReimbursementModalUi extends StatefulWidget {
  // final tripID;

  // ReimbursementModalUi({this.tripID});

  @override
  State createState() => ReimbursementModalUiState();
}

class ReimbursementModalUiState extends State<ReimbursementModalUi> {
  final reimbursementBloc = ReimbursementBloc();
  var tripID;

  // ReimbursementModalUiState(this.tripID);

//  String _ticketImage = '';

  void _settingModalBottomSheet(context, _imgOrder, ReimbursementResponse data,) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Stack(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Color(0xFFF68E65),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Attach photo',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Color(0xFF371D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                new ListTile(
                  leading: Image.asset('icons/Take-Photo_Sheet.png'),
                  title: Text(
                    'Take photo',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xFF371D32),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    reimbursementBloc.pickeImageThroughCamera(_imgOrder, data, context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
                new ListTile(
                  leading: Image.asset('icons/Attach-Photo_Sheet.png'),
                  title: Text(
                    'Attach photo',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xFF371D32),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    reimbursementBloc.pickeImageFromGallery(
                        _imgOrder, data, context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
              ],
            ),
          );
        });
  }


  @override
  void initState() {
    super.initState();
    ReimbursementResponse reimbursementResponse = ReimbursementResponse(
        reimbursement: Reimbursement(amount: 0.0,description: '',
          // tripID: widget.tripID,
          imageIDs: List.filled(3, ''),));
    reimbursementBloc.changedReimbursementData.call(reimbursementResponse);
  }

  @override
  Widget build(BuildContext context) {
    final tripID = ModalRoute.of(context)!.settings.arguments;
    print('TripId $tripID');

    return Scaffold(
      body: Container(
        alignment: Alignment.bottomLeft,
        color: Color.fromRGBO(64, 64, 64, 1),
        child: StreamBuilder<ReimbursementResponse>(
            stream: reimbursementBloc.reimbursementData,
            builder: (context, reimbursementDataSnapshot) { //another call
              return reimbursementDataSnapshot.hasData &&
                      reimbursementDataSnapshot.data != null
                  ? ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height / 2,
                            maxHeight: MediaQuery.of(context).size.height - 24,
                         ),
                    child: Container(
                      margin: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: ListView(
                            shrinkWrap: true,
                          children:[
                            Padding(
                              padding: const EdgeInsets.only(right: 16, left: 16),
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 12,
                                      bottom: 24
                                  ),
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        alignment: Alignment.center,
                                        child: Text(
                                          "Request reimbursement",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32)),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            color: Color(0xFFFF8F62),
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    "The guest is responsible for any violations, such as speeding, red light, parking or toll tickets during the trip. Please indicate if you've recieved any of these and we'll reimburse you the cost.",
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xFF353B50)),
                                  ),
                                ),
                                Text(
                                  "Tickets and tolls photos",
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Color(0xFF371D32)),
                                ),
                                SizedBox(height: 10),
                                ///enter amount
                                Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFFF2F2F2),
                                      borderRadius: BorderRadius.circular(8.0)), child:
                                TextField(
                                  onChanged: (amount){
                                    reimbursementDataSnapshot.data!.reimbursement!.amount=double.parse(amount.toString());
                                    reimbursementBloc.changedReimbursementData.call(reimbursementDataSnapshot.data!);
                                  },
                                  inputFormatters: [NumberRemoveExtraDotFormatter()],
                                  keyboardType:  Platform.isIOS?

                                  TextInputType.numberWithOptions(signed: true):
                                  TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                      contentPadding: EdgeInsets.all(14.0),
                                      border: InputBorder.none,
                                      labelText: 'Enter amount',
                                      labelStyle: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 12,
                                        color: Color(0xFF353B50),
                                      ),
                                      hintText: 'Enter amount',
                                      counterText: ""),
                                ),
                                ),
                                SizedBox(height: 10),
                                //description
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xfff2f2f2),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(6)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 16.0, top: 10),
                                        child: Text(
                                          "Description",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32)),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8.0, right: 16.0),
                                        child: TextField(
                                          onChanged: (descriptions){
                                            reimbursementDataSnapshot.data!.reimbursement!.description=descriptions;
                                            reimbursementBloc.changedReimbursementData.call(reimbursementDataSnapshot.data!);
                                          },
                                          textInputAction: TextInputAction.done,
                                          minLines: 1,
                                          maxLines: 5,
                                          maxLength: 500,
                                          // maxLengthEnforcement: true,
                                          keyboardType: TextInputType.visiblePassword,
                                          decoration: InputDecoration(
                                              hintText: 'Add a description here',
                                              hintStyle: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF686868),
                                                  fontStyle: FontStyle.italic),
                                              border: InputBorder.none),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //image text
                                Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 10),
                                  child: Text(
                                    "Take a photo, ensuring the date, time, location and amount are clearly visible",
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xFF353B50)),
                                  ),
                                ),
                                //image
                                GridView.count(
                                  primary: false,
                                  shrinkWrap: true,
                                  crossAxisSpacing: 1,
                                  mainAxisSpacing: 1,
                                  crossAxisCount: 3,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => _settingModalBottomSheet(context, 1, reimbursementDataSnapshot.data!),
                                      child: reimbursementDataSnapshot.data!.reimbursement!.imageIDs![0] == ''
                                          ? Container(
                                        child: Image.asset(
                                            'icons/Scan-Placeholder.png'),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE0E0E0),
                                          borderRadius:
                                          new BorderRadius.only(
                                            topLeft:
                                            const Radius.circular(12.0),
                                            bottomLeft:
                                            const Radius.circular(12.0),
                                            topRight:
                                            const Radius.circular(12.0),
                                            bottomRight:
                                            const Radius.circular(12.0),
                                          ),
                                        ),
                                      )
                                          :  Stack(
                                          children: <Widget>[
                                            SizedBox(
                                                child: Image(fit: BoxFit.fill,image:
                                                NetworkImage('$storageServerUrl/${reimbursementDataSnapshot.data!.reimbursement!.imageIDs![0]}'),),
                                                width: double.maxFinite ),
                                            Positioned(right: 5, bottom: 5,
                                              child: InkWell(
                                                  onTap: (){
                                                    reimbursementDataSnapshot.data!.reimbursement!.imageIDs![0]='';
                                                    reimbursementBloc.changedReimbursementData.call(reimbursementDataSnapshot.data!);
                                                  },
                                                  child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                      child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))
                                              ),)

                                          ]
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => _settingModalBottomSheet(context, 2, reimbursementDataSnapshot.data!),
                                      child: reimbursementDataSnapshot.data!.reimbursement!.imageIDs![1] == ''
                                          ? Container(
                                        child: Image.asset(
                                            'icons/Scan-Placeholder.png'),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE0E0E0),
                                          borderRadius:
                                          new BorderRadius.only(
                                            topLeft:
                                            const Radius.circular(12.0),
                                            bottomLeft:
                                            const Radius.circular(12.0),
                                            topRight:
                                            const Radius.circular(12.0),
                                            bottomRight:
                                            const Radius.circular(12.0),
                                          ),
                                        ),
                                      )
                                          :
                                      Stack(
                                          children: <Widget>[
                                            SizedBox(
                                                child: Image(fit: BoxFit.fill,image:
                                                NetworkImage('$storageServerUrl/${reimbursementDataSnapshot.data!.reimbursement!.imageIDs![1]}'),),
                                                width: double.maxFinite ),
                                            Positioned(right: 5, bottom: 5,
                                              child: InkWell(
                                                  onTap: (){
                                                    reimbursementDataSnapshot.data!.reimbursement!.imageIDs![1]='';
                                                    reimbursementBloc.changedReimbursementData.call(reimbursementDataSnapshot.data!);
                                                  },
                                                  child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                      child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))
                                              ),)

                                          ]
                                      ),

                                    ),
                                    GestureDetector(
                                      onTap: () => _settingModalBottomSheet(context, 3, reimbursementDataSnapshot.data!),
                                      child: reimbursementDataSnapshot.data!.reimbursement!.imageIDs![2] == ''
                                          ? Container(
                                        child: Image.asset(
                                            'icons/Scan-Placeholder.png'),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFE0E0E0),
                                          borderRadius:
                                          new BorderRadius.only(
                                            topLeft:
                                            const Radius.circular(12.0),
                                            bottomLeft:
                                            const Radius.circular(12.0),
                                            topRight:
                                            const Radius.circular(12.0),
                                            bottomRight:
                                            const Radius.circular(12.0),
                                          ),
                                        ),
                                      )
                                          :
                                      Stack(
                                          children: <Widget>[
                                            SizedBox(
                                                child: Image(fit: BoxFit.fill,image:
                                                NetworkImage('$storageServerUrl/${reimbursementDataSnapshot.data!.reimbursement!.imageIDs![2]}'),),
                                                width: double.maxFinite ),
                                            Positioned(right: 5, bottom: 5,
                                              child: InkWell(
                                                  onTap: (){
                                                    reimbursementDataSnapshot.data!.reimbursement!.imageIDs![2]='';
                                                    reimbursementBloc.changedReimbursementData.call(reimbursementDataSnapshot.data!);
                                                  },
                                                  child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                      child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))
                                              ),)

                                          ]
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text(
                                    "If you have a different request, contact support.",
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xFF353B50)),
                                  ),
                                ),
                                Divider(),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                              width: double.maxFinite,
                                              child: Container(
                                                margin: EdgeInsets.only(bottom: 8, top: 2),
                                                child: ElevatedButton(style: ElevatedButton.styleFrom(
                                                  elevation: 0.0,
                                                  backgroundColor: Color(0xFFFF8F62),
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadius.circular(8.0)),),
                                                  onPressed: reimbursementBloc.checkValidation(reimbursementDataSnapshot.data!)
                                                      ? () async {
                                                    await reimbursementBloc.requestReimbursementMethod(reimbursementDataSnapshot.data!,tripID as String);

                                                    Navigator.of(context).pop();

                                                    showModalBottomSheet(
                                                      isScrollControlled: true,
                                                      enableDrag: false,
                                                      isDismissible: false,
                                                      shape:
                                                      RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.only(
                                                          topLeft:
                                                          Radius.circular(10),
                                                          topRight:
                                                          Radius.circular(10),
                                                        ),
                                                      ),
                                                      context: context,
                                                      builder: (context) {
                                                        return ExperienceModal(
                                                          onPress: () {
                                                            Navigator.of(context)
                                                                .pop();
                                                          },
                                                          experienceImageSrc:
                                                          "icons/Experience_Bad.png",
                                                          title:
                                                          "We are sorry to hear you had a bad experience",
                                                          subtitle:
                                                          "Our team is working on your case and we'll get back to you shortly",
                                                        );
                                                      },
                                                    );
                                                  }
                                                      : null,
                                                  child: Text(
                                                    'Request reimbursement',
                                                    style: TextStyle(
                                                        fontFamily:
                                                        'Urbanist',
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                          ),
                            ),]

                        ),
                      ),
                  )
                  : Container();
            }),
      ),
    );
  }
}

///old one//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'dart:convert' show Utf8Decoder, json;
// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:async/async.dart';
// import 'package:ridealike/pages/trips/bloc/reimbursement_bloc.dart';
// import 'package:ridealike/pages/trips/response_model/reimbursment_response.dart';
//
// import 'package:ridealike/widgets/experience_modal.dart';
//
// import 'package:image_picker/image_picker.dart';
// import 'package:ridealike/pages/common/constant_url.dart';
//
// class ReimbursementModalUi extends StatefulWidget {
//   final tripID;
//   ReimbursementModalUi({this.tripID});
//   @override
//   State createState() => ReimbursementModalUiState(tripID);
// }
//
// class ReimbursementModalUiState extends State<ReimbursementModalUi> {
//   final reimbursementBloc=ReimbursementBloc();
//   var tripID;
//   ReimbursementModalUiState(this.tripID);
//
// //  String _ticketImage = '';
//
//   void _settingModalBottomSheet(context, _imgOrder, ReimbursementResponse data,){
//     showModalBottomSheet(
//         context: context,
//         builder: (BuildContext bc){
//           return Container(
//             child: new Wrap(
//               children: <Widget>[
//                 Padding(
//                   padding: EdgeInsets.all(12.0),
//                   child: Column(
//                     children: <Widget>[
//                       Container(
//                         child: Stack(
//                           children: <Widget>[
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Text('Cancel',
//                                 style: TextStyle(
//                                   fontFamily: 'Urbanist',
//                                   fontSize: 16,
//                                   color: Color(0xFFF68E65),
//                                 ),
//                               ),
//                             ),
//                             Align(
//                               alignment: Alignment.center,
//                               child: Text('Attach photo',
//                                 style: TextStyle(
//                                   fontFamily: 'Urbanist',
//                                   fontSize: 16,
//                                   color: Color(0xFF371D32),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 new ListTile(
//                   leading: Image.asset('icons/Take-Photo_Sheet.png'),
//                   title: Text('Take photo',
//                     textAlign: TextAlign.start,
//                     style: TextStyle(
//                       fontFamily: 'Urbanist',
//                       fontSize: 16,
//                       color: Color(0xFF371D32),
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     reimbursementBloc.pickeImageThroughCamera(_imgOrder,data,context);
//                   },
//                 ),
//                 Divider(color: Color(0xFFABABAB)),
//                 new ListTile(
//                   leading: Image.asset('icons/Attach-Photo_Sheet.png'),
//                   title: Text('Attach photo',
//                     textAlign: TextAlign.start,
//                     style: TextStyle(
//                       fontFamily: 'Urbanist',
//                       fontSize: 16,
//                       color: Color(0xFF371D32),
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     reimbursementBloc.pickeImageFromGallery(_imgOrder,data,context);
//                   },
//                 ),
//                 Divider(color: Color(0xFFABABAB)),
//               ],
//             ),
//           );
//         }
//     );
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//
//     ReimbursementResponse reimbursementResponse= ReimbursementResponse(reimbursement: Reimbursement
//       (tripID: widget.tripID,imageIDs:List.filled(1, ''),violationDateTime: DateFormat('yyyy-MM-ddTHH:mm:ss.SSS').format(DateTime.now())+'Z',violationDescription: '') );
//     reimbursementBloc.changedReimbursementData.call(reimbursementResponse);
//
//     return Container(
//       alignment: Alignment.bottomLeft,
//       color: Color.fromRGBO(64, 64, 64, 1),
//       child: StreamBuilder<ReimbursementResponse>(
//           stream: reimbursementBloc.reimbursementData,
//           builder: (context, reimbursementDataSnapshot) {
//             return  reimbursementDataSnapshot.hasData && reimbursementDataSnapshot.data!=null?
//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(10),
//                   topRight: Radius.circular(10),
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Padding(
//                     padding: const EdgeInsets.only(
//                       top: 16,
//                       bottom: 24,
//                       left: 16,
//                       right: 16,
//                     ),
//                     child: Stack(
//                       children: [
//                         Container(
//                           width: double.infinity,
//                           alignment: Alignment.center,
//                           child: Text(
//                             "Request reimbursement",
//                             style: TextStyle(
//                                 fontFamily: 'Urbanist',
//                                 fontSize: 16,
//                                 color: Color(0xFF371D32)
//                             ),
//                           ),
//                         ),
//                         InkWell(
//                           onTap: () {
//                             Navigator.of(context).pop();
//                           },
//                           child: Text(
//                             "Cancel",
//                             style: TextStyle(
//                               color: Color(0xFFFF8F62),
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
//                     child: Text("The guest is responsible for any violations, such as speeding, red light, parking or toll tickets during the trip. Please indicate if you've recieved any of these and we'll reimburse you the cost.",
//                       style: TextStyle(
//                           fontFamily: 'Urbanist',
//                           fontSize: 14,
//                           color: Color(0xFF353B50)
//                       ),
//                     ),
//                   ),
//                   Container(
//                     padding: EdgeInsets.all(16.0),
//                     width: MediaQuery.of(context).size.width,
//                     decoration: BoxDecoration(
//                       color: Color(0xfff2f2f2),
//                       borderRadius: BorderRadius.all(Radius.circular(8)),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: <Widget>[
//                         Text("Tickets and tolls photos",
//                           style: TextStyle(
//                               fontFamily: 'Urbanist',
//                               fontSize: 16,
//                               color: Color(0xFF371D32)
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.only(top: 8, bottom: 10),
//                           child: Text("Take photos of violations so the date, time and location are clearly visible.",
//                             style: TextStyle(
//                                 fontFamily: 'Urbanist',
//                                 fontSize: 14,
//                                 color: Color(0xFF353B50)
//                             ),
//                           ),
//                         ),
//                         GridView.count(
//                           primary: false,
//                           shrinkWrap: true,
//                           crossAxisSpacing: 1,
//                           mainAxisSpacing: 1,
//                           crossAxisCount: 3,
//                           children: <Widget>[
//                             GestureDetector(
//                               onTap: () => _settingModalBottomSheet(context, 1,reimbursementDataSnapshot.data),
//                               child: reimbursementDataSnapshot.data.reimbursement.imageIDs![0] == '' ? Container(
//                                 child: Image.asset('icons/Scan-Placeholder.png'),
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFFE0E0E0),
//                                   borderRadius: new BorderRadius.only(
//                                     topLeft: const Radius.circular(12.0),
//                                     bottomLeft: const Radius.circular(12.0),
//                                     topRight: const Radius.circular(12.0),
//                                     bottomRight: const Radius.circular(12.0),
//                                   ),
//                                 ),
//                               ) : Container(
//                                 alignment: Alignment.bottomCenter,
//                                 width: 100,
//                                 height: 100,
//                                 decoration: new BoxDecoration(
//                                   color: Color(0xFFF2F2F2),
//                                   image: DecorationImage(
//                                     image: NetworkImage('$storageServerUrl/${reimbursementDataSnapshot.data.reimbursement.imageIDs![0]}'),
//                                     fit: BoxFit.fill,
//                                   ),
//                                   borderRadius: new BorderRadius.only(
//                                     topLeft: const Radius.circular(12.0),
//                                     bottomLeft: const Radius.circular(12.0),
//                                     topRight: const Radius.circular(12.0),
//                                     bottomRight: const Radius.circular(12.0),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Text(
//                       "If you have a different request, contact support.",
//                       style: TextStyle(
//                           fontFamily: 'Urbanist',
//                           fontSize: 14,
//                           color: Color(0xFF353B50)
//                       ),
//                     ),
//                   ),
//                   Divider(),
//                   Row(
//                     children: <Widget>[
//                       Expanded(
//                         child: Column(
//                           children: <Widget>[
//                             SizedBox(
//                                 width: double.maxFinite,
//                                 child: Container(
//                                   margin: EdgeInsets.all(16.0),
//                                   child: ElevatedButton(style: ElevatedButton.styleFrom(
//                                     elevation: 0.0,
//                                     color: Color(0xFFFF8F62),
//                                     padding: EdgeInsets.all(16.0),
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//                                     onPressed: reimbursementBloc.checkValidation(reimbursementDataSnapshot.data)?() async {
//
//                                       var address = await reimbursementBloc.requestReimbursementMethod(reimbursementDataSnapshot.data);
//
//                                       Navigator.of(context).pop();
//
//                                       showModalBottomSheet(
//                                         isScrollControlled: true,
//                                         enableDrag: false,
//                                         isDismissible: false,
//                                         shape: RoundedRectangleBorder(
//                                           borderRadius: BorderRadius.only(
//                                             topLeft: Radius.circular(10),
//                                             topRight: Radius.circular(10),
//                                           ),
//                                         ),
//                                         context: context,
//                                         builder: (context) {
//                                           return ExperienceModal(
//                                             onPress: () {Navigator.of(context).pop();},
//                                             experienceImageSrc: "icons/Experience_Bad.png",
//                                             title: "We are sorry to hear you had a bad experience",
//                                             subtitle: "Our team is working on your case and we'll get back to you shortly",
//                                           );
//                                         },
//                                       );
//                                     }: null,
//                                     child: Text('Request reimbursement',
//                                       style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 18,
//                                           color: Colors.white
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ):Container();
//           }
//       ),
//
//     );
//   }
// }

