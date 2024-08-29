import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/request_service/add_photos_documents_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:rxdart/rxdart.dart';

class AddPhotosToCar extends Object with Validators implements BaseBloc {
  final _photosDocumentsDataController = BehaviorSubject<CreateCarResponse>();
  final _licenseController = BehaviorSubject<bool>();
  final _vinController = BehaviorSubject<bool>();

  Function(CreateCarResponse) get changedPhotosDocumentsData =>
      _photosDocumentsDataController.sink.add;

  Function(bool) get changedLicense => _licenseController.sink.add;

  Function(bool) get changedVin => _vinController.sink.add;
  final ImagePicker picker = ImagePicker();

  Stream<CreateCarResponse> get photosDocumentsData =>
      _photosDocumentsDataController.stream;

  Stream<bool> get license => _licenseController.stream;

  Stream<bool> get vin => _vinController.stream;

  //progressIndicator//
  final _progressIndicatorController = BehaviorSubject<int>();

  Function(int) get changedProgressIndicator =>
      _progressIndicatorController.sink.add;

  Stream<int> get progressIndicator => _progressIndicatorController.stream;

  @override
  void dispose() {
    _photosDocumentsDataController.close();
    _progressIndicatorController.close();
    _licenseController.close();
    _vinController.close();
  }

  photosAndDocuments(CreateCarResponse data,
      {bool completed = true, bool saveAndExit = false}) async {
    var response = await setImagesAndDocuments(data,
        completed: completed, saveAndExit: saveAndExit);
    if (response != null && response.statusCode == 200) {
      var photosDocumentResponse =
          CreateCarResponse.fromJson(json.decode(response.body!));

      return photosDocumentResponse;
    } else {
      return;
    }
  }

  pickImageThroughCamera(int i,
      AsyncSnapshot<CreateCarResponse> photosDocumentsSnapshot, context) async {
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
          preferredCameraDevice: CameraDevice.rear);

      switch (i) {
        case 0:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .mainImageID = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 1:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                  .data!
                  .car!
                  .imagesAndDocuments!
                  .images!
                  .additionalImages!
                  .imageID1 = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 2:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                  .data!
                  .car!
                  .imagesAndDocuments!
                  .images!
                  .additionalImages!
                  .imageID2 = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 3:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                  .data!
                  .car!
                  .imagesAndDocuments!
                  .images!
                  .additionalImages!
                  .imageID3 = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 4:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                  .data!
                  .car!
                  .imagesAndDocuments!
                  .images!
                  .additionalImages!
                  .imageID4 = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 5:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                  .data!
                  .car!
                  .imagesAndDocuments!
                  .images!
                  .additionalImages!
                  .imageID5 = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 6:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                  .data!
                  .car!
                  .imagesAndDocuments!
                  .images!
                  .additionalImages!
                  .imageID6 = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 7:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                  .data!
                  .car!
                  .imagesAndDocuments!
                  .images!
                  .additionalImages!
                  .imageID7 = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 8:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                  .data!
                  .car!
                  .imagesAndDocuments!
                  .images!
                  .additionalImages!
                  .imageID8 = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 9:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                  .data!
                  .car!
                  .imagesAndDocuments!
                  .images!
                  .additionalImages!
                  .imageID9 = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 10:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot
                      .data!.car!.imagesAndDocuments!.carOwnershipDocumentID =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 11:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!
                  .insuranceDocumentID = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 12:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!
                  .insuranceCertID = json.decode(imageRes.body!)['FileID'];
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
                        // await storage.write(
                        //     key: 'route', value: '/verify_identity_ui');
                        // await storage.write(
                        //     key: 'data',
                        //     value: ;

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
    changedPhotosDocumentsData.call(photosDocumentsSnapshot.data!);
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

  pickImageFromGallery(int i,
      AsyncSnapshot<CreateCarResponse> photosDocumentsSnapshot, context) async {
    var status = true;
    print("status" + status.toString());
    if (status) {
      //List<Asset> resultList = await ImageUtils.loadAssets();
      //var data = await resultList[0].getThumbByteData(500, 500, quality: 80);
      List<XFile> resultList = await picker.pickMultiImage();
      var data = await resultList[0].readAsBytes();
      var imageRes = await ImageUtils.sendImageData(
          data.buffer.asUint8List(), resultList[0].name ?? '');

      print(imageRes);
      switch (i) {
        case 0:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            print('imagesAdd$imageRes');
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .mainImageID = imageRes['FileID'];
            }
          }
          break;
        case 1:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .additionalImages!.imageID1 = imageRes['FileID'];
            }
          }
          break;
        case 2:
          {
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .additionalImages!.imageID2 = imageRes['FileID'];
            }
          }
          break;
        case 3:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .additionalImages!.imageID3 = imageRes['FileID'];
            }
          }
          break;
        case 4:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .additionalImages!.imageID4 = imageRes['FileID'];
            }
          }
          break;
        case 5:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .additionalImages!.imageID5 = imageRes['FileID'];
            }
          }
          break;
        case 6:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .additionalImages!.imageID6 = imageRes['FileID'];
            }
          }
          break;
        case 7:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .additionalImages!.imageID7 = imageRes['FileID'];
            }
          }
          break;
        case 8:
          {
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .additionalImages!.imageID8 = imageRes['FileID'];
            }
          }
          break;
        case 9:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!
                  .additionalImages!.imageID9 = imageRes['FileID'];
            }
          }
          break;
        case 10:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!
                  .carOwnershipDocumentID = imageRes['FileID'];
            }
          }
          break;
        case 11:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!
                  .insuranceDocumentID = imageRes['FileID'];
            }
          }
          break;
        case 12:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));
            if (imageRes['Status'] == 'success') {
              photosDocumentsSnapshot.data!.car!.imagesAndDocuments!
                  .insuranceCertID = imageRes['FileID'];
            }
          }
          break;
      }
    } else {
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
                  // await storage.write(key: 'route', value: '/verify_identity_ui');
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
    changedPhotosDocumentsData.call(photosDocumentsSnapshot.data!);
  }

  checkButtonDisable(AsyncSnapshot<CreateCarResponse> photosDocumentsSnapshot) {
    CreateCarResponse createCarResponse = photosDocumentsSnapshot.data!;

    if (createCarResponse.car!.imagesAndDocuments!.license!.province != '' &&
        createCarResponse
                .car!.imagesAndDocuments!.license!.plateNumber!
                .trim() !=
            '' &&
        createCarResponse.car!.imagesAndDocuments!.vin != '' &&
        createCarResponse.car!.imagesAndDocuments!.carOwnershipDocumentID !=
            '' &&
        createCarResponse.car!.imagesAndDocuments!.insuranceDocumentID != '' &&
        createCarResponse.car!.imagesAndDocuments!.images!.mainImageID != '') {
      return false;
    } else {
      return true;
    }
  }

  getCurrentMileage(String _value) {
    switch (_value) {
      case '0':
        return '0-50k km';
      case '50':
        return '50-100k km';

      case '100':
        return '100-150k km';

      case '150':
        return '150-200k km';

      case '200':
        return '200k+ km';
    }
    return '';
  }

  bool checkValidity(CreateCarResponse data) {
    if (data.car!.imagesAndDocuments!.vin!.length != 17) {
      _vinController.sink.addError('Length should be 17 characters.');
      return false;
    }
    return true;
  }
}
