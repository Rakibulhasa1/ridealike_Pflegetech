import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/widgets/custom_buttom.dart';

class StartTrip extends StatefulWidget {
  @override
  State createState() => StartTripState();
}

class StartTripState extends State<StartTrip> {
  bool _isSelected = false;
  String _cleanliness = 'POOR';
  final storage = new FlutterSecureStorage();

  String _damageImage1 = '';
  String _damageImage2 = '';
  String _damageImage3 = '';
  String _dashboardImage = '';

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
    // var status = true;
    // if (Platform.isIOS) {
    //   status = await Permission.camera.request().isGranted;
    // }
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
            _damageImage1 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 2: {
        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _damageImage2 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 3: {
        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _damageImage3 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 4: {
        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _dashboardImage = json.decode(imageRes.body!)['FileID'];
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
            _damageImage1 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 2: {
        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _damageImage2 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 3: {
        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _damageImage3 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 4: {
        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _dashboardImage = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final receivedData = ModalRoute.of(context)!.settings.arguments;
    Trips tripDetails = receivedData as Trips;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xFFF68E65)
                      ),
                    ),
                  ),
                  Text("Text",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xFF371D32)
                    ),
                  ),
                  Container()
                ],
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text("Start trip",
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 36,
                      color: Color(0xFF371D32),
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  Center(
                    child: (tripDetails.carImageId != null || tripDetails.carImageId != '') ? CircleAvatar(
                      backgroundImage: NetworkImage('$storageServerUrl/${tripDetails.carImageId}'),
                      radius: 17.5,
                    )
                    : CircleAvatar(
                      backgroundImage: AssetImage('images/car-placeholder.png'),
                      radius: 17.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  color: Color(0xfff2f2f2),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Any noticeable damage before the trip?",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF371D32)
                        ),
                      ),
                      SizedBox(height: 8),
                      Text("Inspect car's inside and outside for any visual damage, like dents, scratches or broken parts.",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: Color(0xFF353B50)
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          CustomButton(
                            title: 'NO',
                            isSelected: !_isSelected,
                            press: () {
                              setState(() {
                                _isSelected = !_isSelected;
                              });
                            },
                          ),
                          SizedBox(width: 10.0),
                          CustomButton(
                            title: 'YES',
                            isSelected: _isSelected,
                            press: () {
                              setState(() {
                                _isSelected = !_isSelected;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color(0xfff2f2f2),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text("Take photos of existing damage",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF371D32)
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
                            child: _damageImage1 == '' ? Container(
                              child: Image.asset('icons/Scan-Placeholder.png'),
                              decoration: BoxDecoration(
                                color: Color(0xFFE0E0E0),
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(12.0),
                                  bottomLeft: const Radius.circular(12.0),
                                ),
                              ),
                            ) : Container(
                              alignment: Alignment.bottomCenter,
                              width: 100,
                              height: 100,
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                image: DecorationImage(
                                  image: NetworkImage('$storageServerUrl/${_damageImage1}'),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: new BorderRadius.only(
                                  topLeft: const Radius.circular(12.0),
                                  bottomLeft: const Radius.circular(12.0),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _settingModalBottomSheet(context, 2),
                            child: _damageImage2 == '' ? Container(
                              child: Image.asset('icons/Scan-Placeholder.png'),
                              color: Color(0xFFE0E0E0),
                            ) : Container(
                              alignment: Alignment.bottomCenter,
                              width: 100,
                              height: 100,
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                image: DecorationImage(
                                  image: NetworkImage('$storageServerUrl/${_damageImage2}'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _settingModalBottomSheet(context, 3),
                            child: _damageImage3 == '' ? Container(
                              child: Image.asset('icons/Scan-Placeholder.png'),
                              decoration: BoxDecoration(
                                color: Color(0xFFE0E0E0),
                                borderRadius: new BorderRadius.only(
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
                                  image: NetworkImage('$storageServerUrl/${_damageImage3}'),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: new BorderRadius.only(
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
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(10.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xfff2f2f2),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Take photos of a dashboard before the trip",
                      style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF371D32)
                        ),
                    ),
                    Text("To capture existing mileage and fuel level", 
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Color(0xFF353B50)
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
                          onTap: () => _settingModalBottomSheet(context, 4),
                          child: _dashboardImage == '' ? Container(
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
                                image: NetworkImage('$storageServerUrl/${_dashboardImage}'),
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
              SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16.0),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Color(0xfff2f2f2),
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text("Cleanliness before the trip",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xFF371D32)
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        CustomButton(
                          title: 'POOR',
                          isSelected: _cleanliness == 'POOR',
                          press: () {
                            setState(() {
                              _cleanliness = 'POOR';
                            });
                          },
                        ),
                        SizedBox(width: 5),
                        CustomButton(
                          title: 'GOOD',
                          isSelected: _cleanliness == 'GOOD',
                          press: () {
                            setState(() {
                              _cleanliness = 'GOOD';
                            });
                          },
                        ),
                        SizedBox(width: 5),
                        CustomButton(
                          title: 'EXCELLENT',
                          isSelected: _cleanliness == 'EXCELLENT',
                          press: () {
                            setState(() {
                              _cleanliness = 'EXCELLENT';
                            });
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              SizedBox(height: 10),
              Divider(),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xffFF8F68),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                          ),
                            onPressed: () async {
                              var data = {
                                '_isSelected': _isSelected,
                                '_damageImage1': _damageImage1,
                                '_damageImage2': _damageImage2,
                                '_damageImage3': _damageImage3,
                                '_dashboardImage': _dashboardImage,
                                '_cleanliness': _cleanliness
                              };
                              var res = await startTripInspections(tripDetails.tripID, tripDetails.userID, data);
                              var res2 = await startTrip(tripDetails.tripID);

                              print(json.decode(res.body!));

                              Navigator.pushNamed(
                                context,
                                '/trip_started',
                                arguments: tripDetails,
                              );
                            },
                            child: Text('Start trip',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 18,
                                color: Colors.white
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
            ],
          ),
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

    String? jwt = await storage.read(key: 'jwt');
    Map<String, String> headers = { "Authorization": "Bearer $jwt"};
    request.headers.addAll(headers);

    request.files.add(multipartFile);
    var response = await request.send();

    var response2 = await http.Response.fromStream(response);
    
    return response2;
  }
}

Future<http.Response> startTripInspections(_tripID, _userID, data) async {
  var res;

  print(_tripID);
  print(_userID);
  print(data);

  try {
    res = await http.post(
      Uri.parse(inspectTripStartUrl),
      // inspectTripStartUrl as Uri,
      body: json.encode(
        {
          "TripStartInspection": {
            "IsNoticibleDamage": data['_isSelected'],
            "DamageImageIDs": [data['_damageImage1'], data['_damageImage3'], data['_damageImage3']],
            "DashboardImageIDs": [data['_dashboardImage']],
            "Cleanliness": 'CleanlinessUndefined',
            "TripID": _tripID,
            "InspectionByUserID": _userID
          }
        }
      ),
    );
  } catch (error) {}

  return res;
}

Future<http.Response> startTrip(_tripID) async {
  var res;

  try {
    res = await http.post(
      Uri.parse(startTripUrl),
      // startTripUrl as Uri,
      body: json.encode(
        {
          "TripID": _tripID
        }
      ),
    );
  } catch (error) {}

  return res;
}
