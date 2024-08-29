import 'dart:convert' show json;
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:ridealike/pages/common/constant_url.dart';

class VerifyIdentityView extends StatefulWidget {
  @override
  State createState() => VerifyIdentityViewState();
}

class VerifyIdentityViewState extends State<VerifyIdentityView> {
  bool? _isButtonDisabled;
  bool _isButtonPressed = false;

  File? faceImageFile;
  File? dLFrontFile;
  File? dLBackFile;

  String? _profileID;
  String? _faceImageFileID;
  String? _dLFrontFileID;
  String? _dLBackFileID;

  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _isButtonDisabled = true;
  }

  void _checkButtonDisability() {
    if (faceImageFile != null && dLFrontFile != null && dLBackFile != null) {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  void _settingModalBottomSheet(context, _imgType){
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
                dense: true,
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
                  pickeImageThroughCamera(_imgType);
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
                  pickeImageFromGallery(_imgType);
                },          
              ),
              Divider(color: Color(0xFFABABAB)),
            ],
          ),
        );
      }
    );
  }

  pickeImageThroughCamera(String _imgType) async {
    final picker = ImagePicker();

    final img = _imgType == '_faceImageFile' ? await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, 
      maxHeight: 500,
      maxWidth: 500,
      preferredCameraDevice: CameraDevice.front
    ) : await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50, 
      maxHeight: 500,
      maxWidth: 500,
      preferredCameraDevice: CameraDevice.rear
    );

    switch (_imgType) {
      case '_faceImageFile': {
        setState(() {faceImageFile = File(img!.path);});

        var imageRes = await uploadImage(img);

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _faceImageFileID = json.decode(imageRes.body!)['FileID'];
          });                    
        }

        _checkButtonDisability();
      } 
      break;

      case '_dLFront': {
        setState(() {dLFrontFile = File(img!.path);});

        var imageRes = await uploadImage(img);

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _dLFrontFileID = json.decode(imageRes.body!)['FileID'];
          });                    
        }

        _checkButtonDisability();
      }
      break;

      case '_dLBack': {
        setState(() {dLBackFile = File(img!.path);});

        var imageRes = await uploadImage(img);

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _dLBackFileID = json.decode(imageRes.body!)['FileID'];
          });                    
        }

        _checkButtonDisability();
      }
      break;
    }
  }

  pickeImageFromGallery(String _imgType) async {
    final picker = ImagePicker();

    final img = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50, 
      maxHeight: 500, 
      maxWidth: 500,
    );

    switch (_imgType) {
      case '_faceImageFile': {
        setState(() {faceImageFile = File(img!.path);});

        var imageRes = await uploadImage(File(img!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _faceImageFileID = json.decode(imageRes.body!)['FileID'];
          });                    
        }

        _checkButtonDisability();
      } 
      break;

      case '_dLFront': {
        setState(() {dLFrontFile = File(img!.path);});

        var imageRes = await uploadImage(File(img!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _dLFrontFileID = json.decode(imageRes.body!)['FileID'];
          });                    
        }

        _checkButtonDisability();
      }
      break;

      case '_dLBack': {
        setState(() {dLBackFile = File(img!.path);});

        var imageRes = await uploadImage(File(img!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _dLBackFileID = json.decode(imageRes.body!)['FileID'];
          });                    
        }

        _checkButtonDisability();
      }
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

    if (receivedData != null && receivedData['PhoneVerification'] != null && receivedData['PhoneVerification']['ProfileID'] != null) {
      _profileID = receivedData['PhoneVerification']['ProfileID'];
    } 

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),

      //Content of tabs
      body: new SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Text
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            child: Text('Verify your identity',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 36,
                                color: Color(0xFF371D32),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('icons/ID_Verify-ID.png'),
                ],
              ),
              SizedBox(height: 20),
              // Text
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text('All our members go through a verification process. It is to ensure the safety of our like-minded community. Please take a photo of yourself and your driver\'s license.',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xFF353B50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Selfie
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Add a photo of your face (wont be visible to public)',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            color: Color(0xFF371D32),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _settingModalBottomSheet(context, '_faceImageFile'),
                          child: (faceImageFile == null) ? SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: new BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: 99.0, bottom: 99.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFFABABAB),
                                  size: 50.0,
                                ),
                              ),
                            ),
                          ) : SizedBox(
                            width: double.maxFinite,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(faceImageFile!, fit: BoxFit.cover)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // DL front & back
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Scan your driver\'s license front and back (wont be visible to public)',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            color: Color(0xFF371D32),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _settingModalBottomSheet(context, '_dLFront'),
                          child: (dLFrontFile == null) ? SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: new BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: 99.0, bottom: 99.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFFABABAB),
                                  size: 50.0,
                                ),
                              ),
                            ),
                          ) : SizedBox(
                            width: double.maxFinite,
                            child: ClipRRect(
                              borderRadius:BorderRadius.circular(12.0),
                              child: Image.file(dLFrontFile!, fit: BoxFit.cover)
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                          onTap: () => _settingModalBottomSheet(context, '_dLBack'),
                          child: (dLBackFile == null) ? SizedBox(
                            width: double.maxFinite,
                            child: Container(
                              decoration: new BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: new BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: 99.0, bottom: 99.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Color(0xFFABABAB),
                                  size: 50.0,
                                ),
                              ),
                            ),
                          ) : SizedBox(
                            width: double.maxFinite,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(dLBackFile!, fit: BoxFit.cover)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Submit button
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
                                padding: EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0)),

                            ),
                            onPressed: _isButtonDisabled! ? null : () async {
                              setState(() {
                                _isButtonDisabled = true;
                                _isButtonPressed = true;
                              });

                              var res = await addIdentityImages(_profileID, _faceImageFileID, _dLFrontFileID, _dLBackFileID);

                              Map mapRes = json.decode(res.body!);
                              print('mapRes$mapRes');

                              if (res != null) {
                                setState(() {
                                  _isButtonDisabled = false;
                                  _isButtonPressed = false;
                                });

                                Navigator.pushNamed(
                                  context,
                                  '/verification_in_progress',
                                  arguments: mapRes,
                                );
                              } else {
                                setState(() {
                                  _isButtonDisabled = false;
                                  _isButtonPressed = false;
                                });
                              }
                            },
                            child: _isButtonPressed ? SizedBox(
                              height: 18.0,
                              width: 18.0,
                              child: new CircularProgressIndicator(strokeWidth: 2.5),
                            ) : Text('Verify profile now',
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

addIdentityImages(profileID, faceImageID, dLFrontID, dlBackID) async {
  await http.post(
    Uri.parse(addIdentityImageUrl),
    // addIdentityImageUrl as Uri,
    body: json.encode({
      "ProfileID": profileID,
      "ImageID": faceImageID,
    }),
  );

  await http.post(
    Uri.parse(addDLFrontImageUrl),
    // addDLFrontImageUrl as Uri,
    body: json.encode({
      "ProfileID": profileID,
      "ImageID": dLFrontID,
    }),
  );

 var res = await http.post(
   Uri.parse(addDLBackImageUrl),
   // addDLBackImageUrl as Uri,
    body: json.encode({
      "ProfileID": profileID,
      "ImageID": dlBackID,
    }),
  );

  return res; 
}



