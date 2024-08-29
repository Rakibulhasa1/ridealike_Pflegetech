import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' show Utf8Decoder, json;
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'package:ridealike/pages/common/constant_url.dart';

import 'package:ridealike/widgets/experience_modal.dart';

import 'package:image_picker/image_picker.dart';


class ReimbursementModal extends StatefulWidget {
  final tripID;
  ReimbursementModal({this.tripID});
  @override
  State createState() => ReimbursementModalState(tripID);
}

class ReimbursementModalState extends State<ReimbursementModal> {
  var tripID;
  ReimbursementModalState(this.tripID);
  final storage = new FlutterSecureStorage();

  String _ticketImage = '';

  void _settingModalBottomSheet(context, _imgOrder){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
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
                            child: Text('Cancel',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xFFF68E65),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center, 
                            child: Text('Attach photo',
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
                title: Text('Take photo',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF371D32),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickeImageThroughCamera(_imgOrder);
                },          
              ),
              Divider(color: Color(0xFFABABAB)),
              new ListTile(
                leading: Image.asset('icons/Attach-Photo_Sheet.png'),
                title: Text('Attach photo',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF371D32),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickeImageFromGallery(_imgOrder);
                },          
              ),
              Divider(color: Color(0xFFABABAB)),
            ],
          ),
        );
      }
    );
  }

  pickeImageThroughCamera(int i) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 50, 
      maxHeight: 500,
      maxWidth: 500,
      preferredCameraDevice: CameraDevice.rear
    );

    switch (i) {
      case 1: {
        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _ticketImage = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
    }
  }

  pickeImageFromGallery(int i) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50, 
      maxHeight: 500,
      maxWidth: 500
    );

    switch (i) {
      case 1: {
        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _ticketImage = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomLeft,
      color: Color.fromRGBO(64, 64, 64, 1),
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  top: 16,
                  bottom: 24,
                  left: 16,
                  right: 16,
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
                          color: Color(0xFF371D32)
                        ),
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
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Text("The guest is responsible for any violations, such as speeding, red light, parking or toll tickets during the trip. Please indicate if you've recieved any of these and we'll reimburse you the cost.",
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    color: Color(0xFF353B50)
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xfff2f2f2),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Tickets and tolls photos",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xFF371D32)
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 8, bottom: 10),
                      child: Text("Take photos of violations so the date, time and location are clearly visible.",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: Color(0xFF353B50)
                        ),
                      ),
                    ),
                    GridView.count(
                      primary: false,
                      shrinkWrap: true,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                      crossAxisCount: 3,
                      children: <Widget>[
                        GestureDetector(
                          onTap: () => _settingModalBottomSheet(context, 1),
                          child: _ticketImage == '' ? Container(
                            child: Image.asset('icons/Scan-Placeholder.png'),
                            decoration: BoxDecoration(
                              color: Color(0xFFE0E0E0),
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(12.0),
                                bottomLeft: const Radius.circular(12.0),
                                topRight: const Radius.circular(12.0),
                                bottomRight: const Radius.circular(12.0),
                              ),
                            ),
                          ) : Container(
                            alignment: Alignment.bottomCenter,
                            width: 100,
                            height: 100,
                            decoration: new BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              image: DecorationImage(
                                image: NetworkImage('$storageServerUrl/$_ticketImage'),
                                fit: BoxFit.fill,
                              ),
                              borderRadius: new BorderRadius.only(
                                topLeft: const Radius.circular(12.0),
                                bottomLeft: const Radius.circular(12.0),
                                topRight: const Radius.circular(12.0),
                                bottomRight: const Radius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "If you have a different request, contact support.",
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    color: Color(0xFF353B50)
                  ),
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
                            margin: EdgeInsets.all(16.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                backgroundColor: Color(0xFFFF8F62),
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                              ),
                             onPressed: () async {
                                print(_ticketImage);
                                var address = await requestReimbursement(tripID, _ticketImage);

                                Navigator.of(context).pop();

                                showModalBottomSheet(
                                  isScrollControlled: true,
                                  enableDrag: false,
                                  isDismissible: false,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  context: context,
                                  builder: (context) {
                                    return ExperienceModal(
                                      onPress: () {Navigator.of(context).pop();},
                                      experienceImageSrc: "icons/Experience_Bad.png",
                                      title: "We are sorry to hear you had a bad experience",
                                      subtitle: "Our team is working o your case and we'll get back to you shortly",
                                    );
                                  },
                                );
                              },
                              child: Text('Request reimbursement',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 18,
                                  color: Colors.white
                                ),
                              ), 
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      
    );
  }

  uploadImage(filename) async {
    var stream = new http.ByteStream(DelegatingStream.typed(filename.openRead()));
    var length = await filename.length();

    var uri = Uri.parse(uploadUrl);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('files', stream, length, filename: basename(filename.path));

    String? jwt = await storage.read(key: 'user_id');
    Map<String, String> headers = { "Authorization": "Bearer $jwt"};
    request.headers.addAll(headers);

    request.files.add(multipartFile);
    var response = await request.send();

    var response2 = await http.Response.fromStream(response);
    
    return response2;
  }
}

Future<http.Response> requestReimbursement(tripID, _tickedImageId) async {
  var res;

  try {
    res = await http.post(
      Uri.parse(requestReimbursementUrl),
      // requestReimbursementUrl as Uri,
      body: json.encode(
        {
          "Reimbursement": {
            "TripID": tripID,
            "ViolationDateTime": "2020-07-17T22:59:00.982Z",
            "ViolationDescription": "string",
            "ImageIDs": [_tickedImageId]
          }
        }
      ),
    );
  } catch (error) {}

  return res;
}
