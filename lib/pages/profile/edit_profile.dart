import 'dart:async';
import 'dart:convert' show json;
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/main.dart' as Main;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:ridealike/pages/trips/bloc/trips_bloc.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile_name.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> with WidgetsBindingObserver {
  Map? _profileData;
  String _profileImageId = '';
  String? profileID;
  String resVerificationStatus = '';
  String resEmailVerificationStatus = '';
  bool deleteSuccess = false;
  String _userID = '';
  int _currentTripCount = 0;
  int _upcomingTripCount = 0;
  var res;
  Map arguments = {'Profile': {}, 'ProfileID': {}};
  final storage = new FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();

  Future<RestApi.Resp> fetchProfileData(_profileID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getProfileUrl,
      json.encode({
        "ProfileID": _profileID,
      }),
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

  Future<RestApi.Resp> getVerificationStatusByProfileID(_profileID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      getVerificationStatusByProfileIDUrl,
      json.encode({
        "ProfileID": _profileID,
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Edit Profile"});
    callFetchProfileData();
  }

  callFetchProfileData() async {
    profileID = await storage.read(key: 'profile_id');

    if (profileID != null) {
      res = await fetchProfileData(profileID);
      var verificationStatus =
          await getVerificationStatusByProfileID(profileID);

      setState(() {
        print(res.body!);
        _profileData = json.decode(res.body!)['Profile'];
        resVerificationStatus =
            json.decode(verificationStatus.body!)['Verification']
                ['PhoneVerification']['VerificationStatus'];
        // resEmailVerificationStatus = json.decode(verificationStatus.body!)['Verification']['EmailVerification']['VerificationStatus'];

        _profileImageId =
            _profileData!['ImageID'] != null ? _profileData!['ImageID'] : '';
      });
    }
  }

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
    if (status) {
      final pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
          maxHeight: 500,
          maxWidth: 500,
          preferredCameraDevice: CameraDevice.front);

      var imageRes = await uploadImage(File(pickedFile!.path));

      if (json.decode(imageRes.body!)['Status'] == 'success') {
        print(json.decode(imageRes.body!)['FileID']);
        setState(() {
          _profileImageId = json.decode(imageRes.body!)['FileID'];
        });
      }
      await addProfileImage(profileID, _profileImageId);
    } else {
      Platform.isIOS
          ? showDialog(
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
                        await storage.write(
                            key: 'route', value: '/profile_edit_tab');

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
    //await checkForStoragePermission(context);
    //print("status" +status.toString());
    if (status) {
      List<XFile> resultList = await picker.pickMultiImage();
      var data = await resultList[0].readAsBytes();
      var imageRes = await ImageUtils.sendImageData(
          data.buffer.asUint8List(), resultList[0].name ?? '');
      print(imageRes);
      if (imageRes['Status'] == 'success') {
        setState(() {
          _profileImageId = imageRes['FileID'];
        });
        await addProfileImage(profileID, _profileImageId);
      }
    } else {
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
                  await storage.write(key: 'route', value: '/profile_edit_tab');
                  openAppSettings().whenComplete(() {
                    //return Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        },
      );
    }
  }

  //TODO
  Future<bool> checkForStoragePermission(BuildContext context) async {
    // 1. Request storage permission if necessary
    var storageStatus = await Permission.mediaLibrary.status;
    if (!storageStatus.isGranted) {
      if (await Permission.mediaLibrary.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        return true;
      }
      if (storageStatus.isDenied) {
        // Permission denied, show informative dialog and guide to app settings
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
                    await storage.write(
                        key: 'route', value: '/profile_edit_tab');
                    openAppSettings().whenComplete(() {
                      //return Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          },
        );
        return false;
      } else if (storageStatus.isPermanentlyDenied) {
        // Permanently denied, guide user to app settings
        await openAppSettings();
        return false;
      }
      throw Exception('Storage permission required to create folder.');
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    dynamic recvData = ModalRoute.of(context)!.settings.arguments;
    if (recvData != null) {
      resEmailVerificationStatus = recvData['EMAIL_VERIFICATION'];
    }
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Profile Information',
          style: TextStyle(
              color: Color(0xff371D32),
              fontSize: 16,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w500),
        ),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),
      body: _profileData != null
          ? SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        (_profileData != null && _profileImageId != '')
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(
                                    '$storageServerUrl/$_profileImageId'),
                                radius: 50,
                              )
                            : CircleAvatar(
                                backgroundImage: AssetImage('images/user.png'),
                                radius: 50,
                                backgroundColor: Colors.white,
                              ),
                        (_profileData != null && _profileImageId != '' && false)
                            ? Positioned(
                                top: 50,
                                left: 75,
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: new BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.1),
                                          blurRadius: 4.0,
                                        ),
                                      ]),
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _profileImageId = '';
                                        _profileData!['ImageID'] = '';
                                      });
                                    },
//                                        _settingModalBottomSheet(context),
                                    child: Icon(
                                      Icons.delete,
                                      size: 24,
                                      color: Color(0xFF353B50),
                                    ),
                                  ),
                                ),
                              )
                            : Positioned(
                                top: 50,
                                left: 75,
                                child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: new BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.1),
                                          blurRadius: 4.0,
                                        ),
                                      ]),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _settingModalBottomSheet(context),
                                    child: Icon(
                                      Icons.add,
                                      size: 24,
                                      color: Color(0xFF353B50),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Color(0xFFF2F2F2),
                                    padding: EdgeInsets.all(16.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                EditProfileName(
                                                  firstName: _profileData![
                                                      'FirstName'],
                                                  lastName:
                                                      _profileData!['LastName'],
                                                )));
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Name',
                                                style: TextStyle(
                                                    color: Color(0xff353B50),
                                                    fontFamily: 'Urbanist',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    letterSpacing: -0.2),
                                              ),
                                              SizedBox(width: 15),
                                              Text(
                                                _profileData!['FirstName'] +
                                                    " " +
                                                    _profileData!['LastName'],
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  letterSpacing: -0.4,
                                                  color: Color(0xff371D32),
                                                ),
                                              ),
                                            ]),
                                      ),
                                      Container(
                                        width: 16,
                                        child: Icon(Icons.keyboard_arrow_right,
                                            color: Color(0xFF353B50)),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    // Change email
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Color(0xFFF2F2F2),
                                    padding: EdgeInsets.all(16.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                  ),
                                  onPressed: () {
//                                    arguments['profileData']=json.decode(res.body!)['Profile'];
                                    arguments['Profile'] = _profileData;
                                    arguments['ProfileID'] =
                                        _profileData!['ProfileID'];

                                    Navigator.pushNamed(context,
                                            '/profile_change_email_tab',
                                            arguments: arguments
//                                        arguments: {
//                                          'profileData': _profileData1,
//                                        }
                                            )
                                        .then((value) {
                                      setState(() {
                                        if (value != null) {
                                          _profileData = value as Map;
                                        }
                                      });
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Email',
                                                style: TextStyle(
                                                    color: Color(0xff353B50),
                                                    fontFamily: 'Urbanist',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    letterSpacing: -0.2),
                                              ),
                                              SizedBox(width: 15),
                                              Text(
                                                _profileData!['Email'],
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  letterSpacing: -0.4,
                                                  color: Color(0xff371D32),
                                                ),
                                              ),
                                            ]),
                                      ),
                                      Container(
                                        width: 16,
                                        child: Icon(Icons.keyboard_arrow_right,
                                            color: Color(0xFF353B50)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    resEmailVerificationStatus == 'Pending'
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                                'A verification link has been sent to your updated email address.',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 14,
                                  color: Colors.black,
                                )),
                          )
                        : Container(),
                    resEmailVerificationStatus == 'Pending'
                        ? SizedBox(
                            height: 8,
                          )
                        : Container(),

                    // Change phone
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Color(0xFFF2F2F2),
                                    padding: EdgeInsets.all(16.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                  ),
                                  onPressed: () {
                                    arguments['Profile'] = _profileData;
                                    arguments['ProfileID'] =
                                        _profileData!['ProfileID'];
                                    Navigator.pushNamed(context,
                                            '/profile_change_phone_tab',
                                            arguments: arguments)
                                        .then((value) {
                                      setState(() {
                                        if (value != null) {
                                          _profileData = value as Map;
                                        }
                                      });
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Mobile number',
                                                style: TextStyle(
                                                    color: Color(0xff353B50),
                                                    fontFamily: 'Urbanist',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    letterSpacing: -0.2),
                                              ),
                                              SizedBox(width: 15),
                                              Text(
                                                _profileData != null
                                                    ? _profileData![
                                                        'PhoneNumber']
                                                    : ' ',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  letterSpacing: -0.4,
                                                  color: Color(0xff371D32),
                                                ),
                                              ),
                                            ]),
                                      ),
                                      Container(
                                        width: 16,
                                        child: Icon(Icons.keyboard_arrow_right,
                                            color: Color(0xFF353B50)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    resVerificationStatus == 'Pending'
                        ? Text('Failed to verify phone number.',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 14,
                              color: Color(0xFFF55A51),
                            ))
                        : Container(),
                    resVerificationStatus == 'Pending'
                        ? SizedBox(
                            height: 15,
                          )
                        : Container(),

                    //change password//
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Color(0xFFF2F2F2),
                                    padding: EdgeInsets.all(16.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                  ),
                                  onPressed: () {
                                    arguments['Profile'] = _profileData;
                                    arguments['ProfileID'] =
                                        _profileData!['ProfileID'];
                                    Navigator.pushNamed(
                                        context, '/profile_change_password_tab',
                                        arguments: arguments);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Password',
                                                style: TextStyle(
                                                    color: Color(0xff353B50),
                                                    fontFamily: 'Urbanist',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    letterSpacing: -0.2),
                                              ),
                                              SizedBox(width: 15),
                                              Text(
                                                '******',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  letterSpacing: -0.4,
                                                  color: Color(0xff371D32),
                                                ),
                                              ),
                                            ]),
                                      ),
                                      Container(
                                        width: 16,
                                        child: Icon(Icons.keyboard_arrow_right,
                                            color: Color(0xFF353B50)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0.0,
                                    backgroundColor: Color(0xFFF2F2F2),
                                    padding: EdgeInsets.all(16.0),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                  ),
                                  onPressed: () {
                                    arguments['Profile'] = _profileData;
                                    arguments['ProfileID'] =
                                        _profileData!['ProfileID'];
                                    Navigator.pushNamed(
                                        context, '/profile_change_about_me_tab',
                                        arguments: arguments);
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .75,
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'About me',
                                                style: TextStyle(
                                                    color: Color(0xff353B50),
                                                    fontFamily: 'Urbanist',
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    fontSize: 12,
                                                    letterSpacing: -0.2),
                                              ),
                                              SizedBox(width: 15),
                                              AutoSizeText(
                                                _profileData!['AboutMe'],
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.normal,
                                                  fontSize: 16,
                                                  letterSpacing: -0.4,
                                                  color: Color(0xff371D32),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ]),
                                      ),
                                      Container(
                                        width: 16,
                                        child: Icon(Icons.keyboard_arrow_right,
                                            color: Color(0xFF353B50)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(
                                width: double.maxFinite,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      elevation: 0.0,
                                      backgroundColor: Color(0xFFff2323),
                                      padding: EdgeInsets.all(12.0),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                    ),
                                    onPressed: () {
                                      showRemoveAccountDialog(context);
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Container(
                                          child: Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.auto_delete_sharp,
                                                color: Colors.white,
                                              ),
                                              SizedBox(width: 10),
                                              Text(
                                                'Delete RideAlike Account',
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  letterSpacing: -0.4,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Container(
                                        //   width: 16,
                                        //   child: Icon(
                                        //       Icons.keyboard_arrow_right,
                                        //       color: Color(0xFF353B50)),
                                        // ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : Center(child: ShimmerEffect()),
    );
  }

  void showRemoveAccountDialog(BuildContext context1) {
    showDialog(
      context: context1,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Delete'),
          content: Text(
              'Are you sure you want to delete your profile and all cars associated with it?'),
          actions: [
            CupertinoDialogAction(
              child: Text('CANCEL'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: Text('DELETE'),
              onPressed: () async {
                var currentTrip =
                    await TripsBloc().allTripsGroupStatus(200, 0, "Current");
                var upcomingTrip =
                    await TripsBloc().allTripsGroupStatus(200, 0, "Upcoming");
                _upcomingTripCount = upcomingTrip!.trips!.length;
                _currentTripCount = currentTrip!.trips!.length;
                if (_currentTripCount != 0) {
                  Navigator.of(context).pop();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text("Delete Error"),
                          content: Text(
                              "You have a current trip in progress. Please try after ending the trip"),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('CANCEL'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      });
                } else if (_upcomingTripCount != 0) {
                  Navigator.of(context).pop();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return CupertinoAlertDialog(
                          title: Text("Delete User"),
                          content: Text(
                              "You have an Upcoming trip. Do you want to cancel your trips? You will be charged accordingly"),
                          actions: [
                            CupertinoDialogAction(
                              child: Text('CANCEL'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            CupertinoDialogAction(
                              child: Text('PROCEED'),
                              onPressed: () => deleteLocals(context),
                            )
                          ],
                        );
                      });
                } else {
                  deleteLocals(context);
                }
              },
            ),
          ],
        );
      },
    );
  }

  void deleteLocals(BuildContext context) async {
    var deleteUserRes = await deleteUser(_userID);
    deleteSuccess = json.decode(deleteUserRes.body!)["Status"]["success"];

    if (deleteSuccess) {
      AppEventsUtils.logEvent("account_deleted", params: {"account_status": "Deleted"});
      Navigator.of(context).pop();
      await storage.deleteAll();
      Main.notificationCount.value = 0;
      FlutterAppBadger.removeBadge();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushNamed(context, '/signin_ui');
    }
  }

  Future<RestApi.Resp> deleteUser(userID) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      deleteUserUrl,
      json.encode({"UserID": userID, "ForceDelete": true}),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  uploadImage(filename) async {
    try {
      var stream =
          new http.ByteStream(DelegatingStream.typed(filename.openRead()));
      var length = await filename.length();
      print("upload2::");
      var uri = Uri.parse(uploadUrl);
      var request = new http.MultipartRequest("POST", uri);
      var multipartFile = new http.MultipartFile('files', stream, length,
          filename: basename(filename.path));

      String? jwt = await storage.read(key: 'jwt');
      Map<String, String> headers = {"Authorization": "Bearer $jwt"};
      request.headers.addAll(headers);

      request.files.add(multipartFile);
      var response = await request.send();

      print(response.statusCode);

      var response2 = await http.Response.fromStream(response);

      print(response2.statusCode);

      return response2;
    } catch (e) {
      print(e.toString());
    }
  }
}
