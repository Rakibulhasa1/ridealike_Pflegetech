import 'dart:async';
import 'dart:convert' show json;
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:ridealike/pages/verify_email_view.dart';
class IntroduceYourselfView extends StatefulWidget {
  @override
  State createState() => IntroduceYourselfViewState();
}

class IntroduceYourselfViewState extends State<IntroduceYourselfView> {
  final TextEditingController _aboutMeController = TextEditingController();
  final storage = new FlutterSecureStorage();
  String _profileImageId = '';
  int? _aboutMeCharCount;
  bool _isButtonPressed = false;

  void _settingModalBottomSheet(context) {
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
                    pickeImageThroughCamera(context);
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
                    pickeImageFromGallery(context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
              ],
            ),
          );
        });
  }

  pickeImageThroughCamera(context) async {
    var status = true;
    // if (Platform.isIOS) {
    //   status = await Permission.camera.request().isGranted;
    // }
    final picker = ImagePicker();
    if(status){
      final pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
          maxHeight: 500,
          maxWidth: 500,
          preferredCameraDevice: CameraDevice.rear);

      var imageRes = await uploadImage(File(pickedFile!.path));

      if (json.decode(imageRes.body!)['Status'] == 'success') {
        print(json.decode(imageRes.body!)['FileID']);
        setState(() {
          _profileImageId = json.decode(imageRes.body!)['FileID'];
        });
      }}else {
      Platform.isIOS
          ? showDialog(context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Permission Required'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  'RideAlike needs permission to access your photo library to select a photo.'),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Not now'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text('Open settings'),
                onPressed: () async {
                  await storage.write(
                      key: 'route', value: '/introduce_yourself');
                  await storage.write(
                      key: 'data',
                      value: json.encode(receivedData));

                  openAppSettings().whenComplete(() {
                    return Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        },
      )
          : Container();
    }
  }

  pickeImageFromGallery(context) async {
    var status = true;

    // if (Platform.isIOS) {
    //   var perm = await Permission.photos.request();
    //   status = perm.isLimited || perm.isGranted;
    // } else {
    //   status = await Permission.storage.request().isGranted;
    // }
    // final picker = ImagePicker();
    if(status){
      // final pickedFile = await picker.getImage(
      //     source: ImageSource.gallery,
      //     imageQuality: 50,
      //     maxHeight: 500,
      //     maxWidth: 500);
      //
      // var imageRes = await uploadImage(File(pickedFile.path));
      List<Asset> resultList = await ImageUtils.loadAssets();
      var data = await resultList[0].getThumbByteData(500, 500, quality: 80);
      var imageRes = await ImageUtils.sendImageData(data.buffer.asUint8List(),resultList[0].name ?? "");

      if (imageRes['Status'] == 'success') {

        setState(() {
          _profileImageId = imageRes['FileID'];
        });
        print(_profileImageId);
      }}    else {
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Permission Required'),
            content: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  'RideAlike needs permission to access your photo library to select a photo.'),
            ),
            actions: [
              CupertinoDialogAction(
                child: Text('Not now'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text('Open settings'),
                onPressed: () async {
                  await storage.write(key: 'route', value: '/introduce_yourself');
                  await storage.write(
                      key: 'data',
                      value: json.encode(receivedData));

                  openAppSettings().whenComplete(() {
                    return Navigator.pop(context);
                  });
                },
              ),
            ],
          );

        },
      );
    }
  }

  _countAboutMeCharacter(String value) {
    setState(() {
      _aboutMeCharCount = value.length;


    });
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      receivedData = json.decode(ModalRoute.of(this.context)!.settings.arguments as String) ;

      setState(() {
        _aboutMeController.text = receivedData!['AboutMe'];
        _aboutMeCharCount = _aboutMeController.text.length;
        _profileImageId =
        receivedData!['ImageID'] != null ? receivedData!['ImageID'] : '';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.white,
      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xFFEA9A62)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: new Text(
          'Introduce yourself (will be visible to public)',
          style: TextStyle(
              fontFamily: 'Urbanist', fontSize: 16, color: Color(0xFF371D32)),
        ),
        elevation: 0.0,
      ),

      //Content of tabs
      body: SingleChildScrollView(

        child:   Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Column(
                children: [
                  // Profile Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context),
                              child: _profileImageId != ''
                                  ? Container(
                                alignment: Alignment.bottomCenter,
                                width: 100,
                                height: 100,
                                decoration: new BoxDecoration(
                                  color: Color(0xFFF2F2F2),
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: NetworkImage(
                                        '$storageServerUrl/$_profileImageId'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                                  : Stack(children: [
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  width: 100,
                                  height: 100,
                                  decoration: new BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color:  Color(0xfff44336)),
                                  ),
                                  child: Align(alignment: Alignment.center,
                                    child: Image.asset(
                                        'icons/Profile_Photo_Placeholder.png'),
                                  ),
                                ),
                                Positioned(top: 60,left: 75,
                                  child:
                                  Container(
                                    // margin: EdgeInsets.fromLTRB(0, 50, 0, 0),
                                    width: 32,
                                    height: 32,
                                    decoration: new BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color.fromRGBO(
                                                0, 0, 0, 0.1),
                                            blurRadius: 4.0,
                                          ),
                                        ]),
                                    child: Icon(
                                      Icons.add,
                                      size: 20,
                                      color: Color(0xFF353B50),
                                    ),
                                  ),



                                )
                              ],

                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
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
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(
                                    color:  _aboutMeCharCount == 0 ? Color(0xfff44336) : Colors.transparent,
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                    children: <Widget>[
                                      Column(
                                        children: <Widget>[
                                          TextFormField(
                                            textInputAction: TextInputAction.done,
                                            controller: _aboutMeController,
                                            onChanged: _countAboutMeCharacter,
                                            minLines: 1,
                                            maxLines: 3,
                                            maxLength: 500,
                                            keyboardType: TextInputType.visiblePassword,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              labelText: 'About me',
                                              labelStyle: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32),
                                              ),
                                              hintText:
                                              'Please introduce yourself (This will be visible to all RideAlike users).',
                                              hintStyle: TextStyle(
                                                  fontFamily:
                                                  'Urbanist',
                                                  fontSize: 14,
                                                  fontStyle:
                                                  FontStyle.italic),

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
              SizedBox(height: MediaQuery.of(context).size.height*.35,),
              // Save button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.maxFinite,
                              child:
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  elevation: 0.0,
                                  backgroundColor: Color(0xffFF8F68),
                                  // textColor: Colors.white,
                                  padding: EdgeInsets.all(16.0),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0)),

                                ),
                               onPressed: _isButtonPressed || _profileImageId == '' || _aboutMeController.text=='' ||_aboutMeCharCount==0
                                    ? null
                                    : () async {
                                  await storage.delete(key: 'route');
                                  await storage.delete(key: 'data');
                                  setState(() {
                                    _isButtonPressed = true;
                                  });
                                  if (_profileImageId != '') {
                                    await addProfileImage(receivedData!['ProfileID'], _profileImageId);
                                  }

                                  var response = await addAboutMe(receivedData!['ProfileID'], _aboutMeController.text);

                                  // Navigator.pushNamed(context, '/about_you_tab');
                                  Navigator.pop(context, json.decode(response.body!)['Profile']);
                                },
                                child: _isButtonPressed
                                    ? SizedBox(
                                  height: 18.0,
                                  width: 18.0,
                                  child: new CircularProgressIndicator(
                                      strokeWidth: 2.5),
                                )
                                    : Text(
                                  'Save',
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

  uploadImage(filename) async {
    var stream =
    new http.ByteStream(DelegatingStream.typed(filename.openRead()));
    var length = await filename.length();

    var uri = Uri.parse(uploadUrl);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('files', stream, length,
        filename: basename(filename.path));

    String? jwt = await storage.read(key: 'jwt');
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    request.headers.addAll(headers);

    request.files.add(multipartFile);
    var response = await request.send();

    var response2 = await http.Response.fromStream(response);

    return response2;
  }
}

Future<RestApi.Resp> addAboutMe(_profileID, _aboutMe) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    addAboutMeUrl,
    json.encode({"ProfileID": _profileID, "AboutMe": _aboutMe}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}

Future<RestApi.Resp> addProfileImage(_profileID, _profileImageId) async {
  final completer = Completer<RestApi.Resp>();
  RestApi.callAPI(
    addProfileImageUrl,
    json.encode({"ProfileID": _profileID, "ImageID": _profileImageId}),
  ).then((resp) {
    completer.complete(resp);
  });
  return completer.future;
}