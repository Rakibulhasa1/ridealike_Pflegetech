import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/create_a_profile/request_service/verify_identity.dart';
import 'package:ridealike/pages/create_a_profile/response_model/add_identity_image_response.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/pages/create_a_profile/response_model/options_lists.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:rxdart/rxdart.dart';
class VerifyIdentityBloc extends Object with Validators implements BaseBloc {
  CreateProfileResponse? createProfileResponse;
//controller//
  final _faceImageFileController = BehaviorSubject<String>();
  final _dLFrontFileController = BehaviorSubject<String>();
  final _dLBackFileController = BehaviorSubject<String>();
  final ImagePicker picker = ImagePicker();
  final _progressIndicatorController = BehaviorSubject<int>();
  final _verifyButtonController = BehaviorSubject<bool>();
  final _heardOptionsListController = BehaviorSubject<OptionsList>();

  //sink data//
  Function(String) get changedFaceImageFile =>
      _faceImageFileController.sink.add;
  Function(String) get changedDlFrontFile => _dLFrontFileController.sink.add;
  Function(String) get changedDlBackFile => _dLBackFileController.sink.add;
  Function(int) get changedProgressIndicator =>
      _progressIndicatorController.sink.add;
  Function(bool) get changedVerifyButton => _verifyButtonController.sink.add;
  Function(OptionsList) get changedHeardOptionsListController => _heardOptionsListController.sink.add;

  //get data..//
  Stream<String> get faceImageFile => _faceImageFileController.stream;
  Stream<String> get dlFrontFile => _dLFrontFileController.stream;
  Stream<String> get dlBackFile => _dLBackFileController.stream;
  Stream<int> get progressIndicator => _progressIndicatorController.stream;
  Stream<bool> get verifyButton => _verifyButtonController.stream;
  Stream<OptionsList> get heardOptionsList => _heardOptionsListController.stream;

  final storage = new FlutterSecureStorage();
  Stream<bool> get nextIdentityButton =>
      Rx.combineLatest([faceImageFile, dlFrontFile, dlBackFile], (values) {
        if (values[0] == '' || values[1] == '' || values[2] == '') {
          return false;
        } else {
          return true;
        }
      });

  pickImageThroughCamera(String _imgType, context) async {
    var status = true;
    // if (Platform.isIOS) {
    //   status = await Permission.camera.request().isGranted;
    // }

    final picker = ImagePicker();
    if (status) {
      final img = _imgType == '_faceImageFile'
          ? await picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 50,
              maxHeight: 500,
              maxWidth: 500,
              preferredCameraDevice: CameraDevice.front)
          : await picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 50,
              maxHeight: 500,
              maxWidth: 500,
              preferredCameraDevice: CameraDevice.rear);

      switch (_imgType) {
        case '_faceImageFile':
          {
            var faceImageRes = await uploadImage(File(img!.path));
            var faceRes = json.decode(faceImageRes.body!);
            print("faceImage $uploadImage");
            print("faceImage $faceRes");

            if (faceRes['Status'] == 'success') {
              changedFaceImageFile.call(faceRes['FileID']);
              print('faceFileId${faceRes['FileID']}');
            }
          }
          break;

        case '_dLFront':
          {
            var dlFrontImageRes = await uploadImage(File(img!.path));
            var frontRes = json.decode(dlFrontImageRes.body!);
            print('backRes $frontRes');
            if (frontRes['Status'] == 'success') {
              changedDlFrontFile.call(frontRes['FileID']);
              print('backImageFileId${frontRes['FileID']}');
            }
          }
          break;

        case '_dLBack':
          {
            var dlBackImageRes = await uploadImage(File(img!.path));
            var backRes = json.decode(dlBackImageRes.body!);
            print('backRes $backRes');
            if (backRes['Status'] == 'success') {
              changedDlBackFile.call(backRes['FileID']);
              print('backImageFileId${backRes['FileID']}');
            }
          }
          break;
      }
    } else {
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
                        await storage.write(
                            key: 'route', value: '/verify_identity_ui');
                        await storage.write(
                            key: 'data', value: json.encode(createProfileResponse!.toJson()));

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

    // final img = _imgType == '_faceImageFile'
    //     ? await picker.getImage(
    //         source: ImageSource.camera,
    //         imageQuality: 50,
    //         maxHeight: 500,
    //         maxWidth: 500,
    //         preferredCameraDevice: CameraDevice.front)
    //     : await picker.getImage(
    //         source: ImageSource.camera,
    //         imageQuality: 50,
    //         maxHeight: 500,
    //         maxWidth: 500,
    //         preferredCameraDevice: CameraDevice.rear);

    // switch (_imgType) {
    //   case '_faceImageFile':
    //     {
    //       var faceImageRes = await uploadImage(File(img.path));
    //       var faceRes = json.decode(faceImageRes.body!);
    //       print("faceImage $uploadImage");
    //       print("faceImage $faceRes");

    //       if (faceRes['Status'] == 'success') {
    //         changedFaceImageFile.call(faceRes['FileID']);
    //         print('faceFileId${faceRes['FileID']}');
    //       }
    //     }
    //     break;

    //   case '_dLFront':
    //     {
    //       var dlFrontImageRes = await uploadImage(File(img.path));
    //       var frontRes = json.decode(dlFrontImageRes.body!);
    //       print("frontImage$frontRes");
    //       if (frontRes['Status'] == 'success') {
    //         changedDlFrontFile.call(frontRes['FileID']);
    //         print('frontImageFileId${frontRes['FileID']}');
    //       }
    //     }
    //     break;

    //   case '_dLBack':
    //     {
    //       var dlBackImageRes = await uploadImage(File(img.path));
    //       var backRes = json.decode(dlBackImageRes.body!);
    //       print('backRes $backRes');
    //       if (backRes['Status'] == 'success') {
    //         changedDlBackFile.call(backRes['FileID']);
    //         print('backImageFileId${backRes['FileID']}');
    //       }
    //     }
    //     break;
    // }
  }
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
  pickImageFromGallery(String _imgType, context) async {
    var status = true;
    print("status" +status.toString());
    if (status) {
      //List<Asset> resultList = await ImageUtils.loadAssets();
      //var data = await resultList[0].getThumbByteData(500, 500, quality: 80);
      List<XFile> resultList = await picker.pickMultiImage();
      var data = await resultList[0].readAsBytes();
      var imageRes = await ImageUtils.sendImageData(
          data.buffer.asUint8List(), resultList[0].name ?? '');

      print(imageRes);
      switch (_imgType) {
        case '_faceImageFile':
          {
            // var faceImageRes = await uploadImage(File(img.path));
            // var faceRes = json.decode(faceImageRes.body!);
            // print("faceImage $uploadImage");
            // print("faceImage $faceRes");

            if (imageRes['Status'] == 'success') {

              changedFaceImageFile.call(imageRes['FileID']);


              // print('faceFileId${faceRes['FileID']}');
            }
          }
          break;

       case '_dLFront':
          {
            // var dlBackImageRes = await uploadImage(File(img.path));
            // var backRes = json.decode(dlBackImageRes.body!);
            // print('backRes $backRes');
            if (imageRes['Status'] == 'success') {
              changedDlFrontFile.call(imageRes['FileID']);
              // print('backImageFileId${backRes['FileID']}');
            }
          }
          break;

        case '_dLBack':
          {
            // var dlBackImageRes = await uploadImage(File(img.path));
            // var backRes = json.decode(dlBackImageRes.body!);
            // print('backRes $backRes');
            if (imageRes['Status'] == 'success') {
              changedDlBackFile.call(imageRes['FileID']);
              // print('backImageFileId${backRes['FileID']}');
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
                  await storage.write(
                      key: 'data',
                      value: json.encode(createProfileResponse!.toJson()));

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

  submitIdentityImageButton(CreateProfileResponse responseData) async {
    _verifyButtonController.sink.add(false);
    _progressIndicatorController.sink.add(1);

    var res = await addIdentityImages(
        responseData.user!.profileID,
        _faceImageFileController.stream.value,
        _dLFrontFileController.stream.value,
        _dLBackFileController.stream.value);
    print('responseIdentityButton${res.body}');

    var identityImageRes =
        AddIdentityImagesResponse.fromJson(json.decode(res.body!));
    print('identityResModel$identityImageRes');
    _progressIndicatorController.sink.add(0);
    return identityImageRes;
  }

  profileWelcomeEmailCheck(CreateProfileResponse responseData) async {
    var res = await welcomeEmailProfile(responseData.user!.userID!);
    if (res != null && res.statusCode == 200) {
      return;
    }
  }
  submitProfileStatusCheck(CreateProfileResponse responseData,) async {
    OptionsList  headFromData=_heardOptionsListController.stream.value;
    String selectedValue=headFromData.selectedValue!;
    if(selectedValue=='Other'){
      selectedValue=headFromData.othersValue!;
    }
    var res = await submitProfileStatus(responseData.user!.profileID!,selectedValue);
    if (res != null && res.statusCode == 200) {
      return;
    }
  }
  getHeardOptionsList() async {
    var response = await fetchDropDownList();
    if (response != null && response.statusCode == 200) {
      OptionsList optionListData= OptionsList.fromJson(json.decode(response.body!));
      var otherOption = HeardOptions(iD: 'o',optionName: 'Other');
      optionListData.heardOptions!.add(otherOption);
      changedHeardOptionsListController.call(optionListData);
     return ;
    }
  }
  Future getSenecaUrlResponse(String fileID)async{
    var response = await HttpClient.get(senecaUrl+fileID);
    print("response form seneca$response");
    return response;
  }

  @override
  void dispose() {
    _faceImageFileController.close();
    _dLFrontFileController.close();
    _dLBackFileController.close();
    _progressIndicatorController.close();
    _verifyButtonController.close();
  }
}
