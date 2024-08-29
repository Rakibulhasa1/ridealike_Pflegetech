import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/models/existing_verification_images.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart';
import 'package:ridealike/pages/create_a_profile/request_service/verify_identity.dart';
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:ridealike/utils/enums.dart';
import 'package:ridealike/widgets/custom_image_field.dart';

class UpdateYourIdentityPage extends StatefulWidget {
  final ExistingVerificationImages existingVerificationImages;

  UpdateYourIdentityPage({required this.existingVerificationImages});

  @override
  _UpdateYourIdentityPageState createState() => _UpdateYourIdentityPageState();
}

class _UpdateYourIdentityPageState extends State<UpdateYourIdentityPage> {
  ImageState faceImageState = ImageState.inserted,
      licenceFrontImageState = ImageState.inserted,
      licenceBackImageState = ImageState.inserted;

  ValueNotifier<bool> updated = ValueNotifier<bool>(false);

  ValueNotifier<String>? faceImageID, licenceFrontImageID, licenceBackImageID;

  void _settingModalBottomSheet(BuildContext context, UpdateIdentityImageType imageType) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Column(
            mainAxisSize: MainAxisSize.min,
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
                ListTile(
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
                    pickImageThroughCamera(imageType, context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
                ListTile(
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
                    pickImageFromGallery(imageType, context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
              ],
          );
        });
  }

  pickImageThroughCamera(UpdateIdentityImageType imageType, context) async {
    var status = true;
    // if (Platform.isIOS) {
    //   status = await Permission.camera.request().isGranted;
    // }

    final picker = ImagePicker();
    if (status) {
      final img = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
          maxHeight: 500,
          maxWidth: 500,
          preferredCameraDevice: imageType == UpdateIdentityImageType.face ?
          CameraDevice.front : CameraDevice.rear);

      switch (imageType) {
        case UpdateIdentityImageType.face:
          {
            var faceImageRes = await uploadImage(File(img!.path));
            var faceRes = json.decode(faceImageRes.body!);
            print("faceImage $uploadImage");
            print("faceImage $faceRes");

            if (faceRes['Status'] == 'success') {
                faceImageState = ImageState.updated;
                faceImageID!.value = faceRes['FileID'];
                enableButton(true);
              print('faceFileId${faceRes['FileID']}');
            }
          }
          break;

        case UpdateIdentityImageType.licenceFront:
          {
            var dlFrontImageRes = await uploadImage(File(img!.path));
            var frontRes = json.decode(dlFrontImageRes.body!);
            print("frontImage$frontRes");
            if (frontRes['Status'] == 'success') {
              licenceFrontImageID!.value = frontRes['FileID'];
              licenceFrontImageState = ImageState.updated;
              enableButton(true);
              print('frontImageFileId${frontRes['FileID']}');
            }
          }
          break;

        case UpdateIdentityImageType.licenceBack:
          {
            var dlBackImageRes = await uploadImage(File(img!.path));
            var backRes = json.decode(dlBackImageRes.body!);
            print('backRes $backRes');
            if (backRes['Status'] == 'success') {
              licenceBackImageID!.value = backRes['FileID'];
              licenceBackImageState = ImageState.updated;
              enableButton(true);
              print('backImageFileId${backRes['FileID']}');
            }
          }
          break;
      }
    }
    else {
      Platform.isIOS
          ? showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Permission Required'),
            content: Text(
                'RideAlike needs permission to access your photo library to select a photo.'),
            actions: [
              CupertinoDialogAction(
                child: Text('Not now'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text('Open settings'),
                onPressed: () async {
                  await storage.write(key: 'route', value: '/verify_identity_ui');
                  // await storage.write(key: 'data', value: json.encode(createProfileResponse.toJson()));

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

  pickImageFromGallery(UpdateIdentityImageType imageType, context) async {
    var status = true;

    // if (Platform.isIOS) {
    //   var perm = await Permission.photos.request();
    //   status = perm.isLimited || perm.isGranted;
    // } else {
    //   status = await Permission.storage.request().isGranted;
    // }
    // final picker = ImagePicker();

    if (status) {
      // List<Asset> resultList =List<Asset>() ;
      List<Asset> resultList = [];

      var imageRes;
      var data;
      resultList = await ImageUtils.loadAssets();

      for(var i=0;i<resultList.length;i++){
        data = await resultList[i].getThumbByteData(500, 500, quality: 80);
        imageRes = await ImageUtils.sendImageData(data.buffer.asUint8List(),resultList[i].name ??"");
      }
      switch (imageType) {
        case UpdateIdentityImageType.face:
          {
            if (imageRes['Status'] == 'success') {
              faceImageState = ImageState.updated;
              faceImageID!.value = imageRes['FileID'];
              enableButton(true);
            }
          }
          break;

        case UpdateIdentityImageType.licenceFront:
          {
            // var dlFrontImageRes = await uploadImage(File(img.path));
            // var frontRes = json.decode(dlFrontImageRes.body!);
            // print("frontImage$frontRes");
            if (imageRes['Status'] == 'success') {
              licenceFrontImageState = ImageState.updated;
              licenceFrontImageID!.value = imageRes['FileID'];
              enableButton(true);
            }
          }
          break;

        case UpdateIdentityImageType.licenceBack:
          {
            // var dlBackImageRes = await uploadImage(File(img.path));
            // var backRes = json.decode(dlBackImageRes.body!);
            // print('backRes $backRes');
            if (imageRes['Status'] == 'success') {
              licenceBackImageState = ImageState.updated;
              licenceBackImageID!.value = imageRes['FileID'];
              enableButton(true);
            }
          }
          break;
      }
    }
    else {
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Permission Required'),
            content: Text(
                'RideAlike needs permission to access your photo library to select a photo.'),
            actions: [
              CupertinoDialogAction(
                child: Text('Not now'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text('Open settings'),
                onPressed: () async {
                  await storage.write(
                      key: 'route', value: '/verify_identity_ui');
                  // await storage.write(
                  //     key: 'data',
                  //     value: json.encode(createProfileResponse.toJson()));

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

  void enableButton(bool value){
    if(updated.value == false){
      updated.value = true;
    }
  }

  void updateIdentityVerification(){
    try {
      callAPI(updateIdentityVerificationUrl, json.encode({
        "ProfileID": widget.existingVerificationImages.profileID,
        "ImageID": faceImageID!.value,
        "DLFrontImageID": licenceFrontImageID!.value,
        "DLBackImageID": licenceBackImageID!.value
      })).then((response) {
        if(response.statusCode == 200)
          // Navigator.pushReplacementNamed(context, '/about_you_tab');
          Navigator.pushNamed(context, '/profile');

        else
          showErrorMessage();
      });
    } catch (e) {
      print(e);
      showErrorMessage();
    }
  }

  void showErrorMessage(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error!'),
        content: Text('Something went wrong! Please try again'),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: Text('ok'),
          )
        ],
      )
    );
  }

  @override
  void initState() {
    super.initState();
    faceImageID = ValueNotifier<String>(widget.existingVerificationImages.faceImage!);
    licenceFrontImageID = ValueNotifier<String>(widget.existingVerificationImages.licenceFrontImage!);
    licenceBackImageID = ValueNotifier<String>(widget.existingVerificationImages.licenceBackImage!);
  }

  @override
  Widget build(BuildContext context) {
    print(widget.existingVerificationImages.profileID);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Color(0xffFF8F68),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Text
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Update your Identity',
                        style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 32,
                            color: Color(0xFF371D32),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Image.asset('icons/ID_Verify-ID.png'),
                  ],
                ),
                SizedBox(height: 20),
                // Text
                Text(
                  'All our members go through a verification process. It is to ensure the safety of our like-minded community. Please take a photo of yourself and your driver\'s license.',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF353B50),
                  ),
                ),
                SizedBox(height: 30),
                // face image text
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      color: Color(0xFF371D32),
                    ),
                    children: [
                      TextSpan(
                        // text: 'Add a photo of your face (wont be visible to public)',
                        text: 'Add a photo of your face ',
                      ),
                      TextSpan(
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF353B50),
                        ),
                        text: '(This picture won\'t be visible to the public, and is only displayed to the other party during pick-up of a rental/swap vehicle to help RideAlike members identify each other).',
                      ),

                    ],
                  ),
                ),
                SizedBox(height: 10),
                //face image field
                CustomImageField(
                  imageId: faceImageID,
                  imageState: faceImageState,
                  onTap: () {
                    _settingModalBottomSheet(
                        context, UpdateIdentityImageType.face);
                  },),
                SizedBox(height: 30),
                // licence front & back text
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      color: Color(0xFF371D32),
                    ),
                    children: [
                      TextSpan(
                        text: 'Upload your driver\'s license front and back ',
                      ),
                      TextSpan(
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 16,
                          color: Color(0xFF353B50),
                        ),
                        text: '(These pictures won\'t be visible to the public, and are only used to verify that you have a current and valid license, to meet RideAlike\'s eligibility requirements).',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                //licence front
                CustomImageField(
                  imageId: licenceFrontImageID,
                  imageState: licenceFrontImageState,
                  onTap: () {
                    _settingModalBottomSheet(
                        context, UpdateIdentityImageType.licenceFront);
                  },),
                SizedBox(height: 10),
                //licence back
                CustomImageField(
                  imageId: licenceBackImageID,
                  imageState: licenceBackImageState,
                  onTap: () {
                    _settingModalBottomSheet(
                        context, UpdateIdentityImageType.licenceBack);
                  },),
                SizedBox(height: 30),
                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ValueListenableBuilder(
                      valueListenable: updated,
                      builder: (context, value, child) {
                        print('value: ' + value.toString());
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Color(0xffFF8F68),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    8.0)),

                          ),
                            onPressed: value == true ? updateIdentityVerification : null,
                          child:  Text(
                            'Update profile now',
                            style: TextStyle(
                                fontFamily:
                                'Urbanist',
                                fontSize: 18,
                                color: Colors.white),
                          ),
                        );}
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}
