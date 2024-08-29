import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/create_a_profile/bloc/validator.dart';
import 'package:ridealike/pages/list_a_car/request_service/add_photos_documents_request.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:rxdart/rxdart.dart';
class AddFeaturesBloc  extends Object  with  Validators implements BaseBloc{

  final _addPhotosController=BehaviorSubject<CreateCarResponse>();
  final _customFeatureController=BehaviorSubject<CustomFeatures>();
  var _imageListController =BehaviorSubject<HashMap<int, String>>();

  //progressIndicator//
  final _progressIndicatorController =BehaviorSubject<int>();
  Function(int) get changedProgressIndicator => _progressIndicatorController.sink.add;
  Stream<int> get progressIndicator => _progressIndicatorController.stream;

  Function(CreateCarResponse) get changedAddPhotos=>_addPhotosController.sink.add;
  Function(CustomFeatures) get changedCustomFeature=>_customFeatureController.sink.add;
  Function(HashMap<int, String>) get changedImageList=>_imageListController.sink.add;

  Stream<CreateCarResponse>get addPhotos=>_addPhotosController.stream;
  Stream<CustomFeatures>get customFeatures=>_customFeatureController.stream;
  Stream<HashMap<int, String>>get imageList=>_imageListController.stream;


  pickeImageThroughCamera(int i, AsyncSnapshot<HashMap<int, String>> imageListSnapshot,context) async {
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
          preferredCameraDevice: CameraDevice.rear
      );
      switch (i) {
        case 1:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {

              imageListSnapshot.data![1]= json.decode(imageRes.body!)['FileID'];

            }
          }
          break;
        case 2:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              imageListSnapshot.data![2]= json.decode(imageRes.body!)['FileID'];

            }
          }
          break;
        case 3:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));
            if (json.decode(imageRes.body!)['Status'] == 'success') {
              imageListSnapshot.data![3]= json.decode(imageRes.body!)['FileID'];

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

//
//     final pickedFile = await picker.getImage(
//         source: ImageSource.camera,
//         imageQuality: 50,
//         maxHeight: 500,
//         maxWidth: 500,
//         preferredCameraDevice: CameraDevice.rear
//     );
//
//     switch (i) {
//       case 1:
//         {
// //          setState(() {
// //            _imageFile1 = File(pickedFile!.path);
// //          });
//
//           var imageRes = await uploadImage(File(pickedFile!.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//
//             imageListSnapshot.data![1]= json.decode(imageRes.body!)['FileID'];
//
//           }
//         }
//         break;
//       case 2:
//         {
//
//
//           var imageRes = await uploadImage(File(pickedFile!.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             imageListSnapshot.data![2]= json.decode(imageRes.body!)['FileID'];
//
//           }
//         }
//         break;
//       case 3:
//         {
//
//
//           var imageRes = await uploadImage(File(pickedFile!.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             imageListSnapshot.data![3]= json.decode(imageRes.body!)['FileID'];
//
//           }
//         }
//         break;
//     }
    changedImageList.call(imageListSnapshot.data!);
  }

  pickeImageFromGallery(int i, AsyncSnapshot<HashMap<int, String>> imageListSnapshot,context) async {
    final picker = ImagePicker();
    var status = true;

    // if (Platform.isIOS) {
    //   var perm = await Permission.photos.request();
    //   status = perm.isLimited || perm.isGranted;
    // } else {
    //   status = await Permission.storage.request().isGranted;
    // }

    if(status){

      List<Asset> resultList =<Asset>[] ;
      var imageRes;
      var data;
      resultList = await ImageUtils.loadAssets();

      for(var i=0;i<resultList.length;i++){
        data = await resultList[i].getThumbByteData(500, 500, quality: 80);
        imageRes = await ImageUtils.sendImageData(data.buffer.asUint8List(),resultList[i].name!);
      }

      switch (i) {
        case 1: {

          if (imageRes['Status'] == 'success') {
            imageListSnapshot.data![1]= imageRes['FileID'];
          }
        }
        break;
        case 2: {
          if (imageRes['Status'] == 'success') {
            imageListSnapshot.data![2] = imageRes['FileID'];
          }
        }
        break;
        case 3: {
          // var imageRes = await uploadImage(File(pickedFile!.path));

          if (imageRes['Status'] == 'success') {
            imageListSnapshot.data![3]= imageRes['FileID'];
          }
        }
        break;

      }}
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

    //
    // final pickedFile = await picker.getImage(
    //     source: ImageSource.gallery,
    //     imageQuality: 50,
    //     maxHeight: 500,
    //     maxWidth: 500
    // );
    //
    // switch (i) {
    //   case 1:
    //     {
    //
    //       var imageRes = await uploadImage(File(pickedFile!.path));
    //
    //       if (json.decode(imageRes.body!)['Status'] == 'success') {
    //         imageListSnapshot.data![1]= json.decode(imageRes.body!)['FileID'];
    //
    //       }
    //     }
    //     break;
    //   case 2:
    //     {
    //
    //
    //       var imageRes = await uploadImage(File(pickedFile!.path));
    //
    //       if (json.decode(imageRes.body!)['Status'] == 'success') {
    //         imageListSnapshot.data![2]= json.decode(imageRes.body!)['FileID'];
    //
    //       }
    //     }
    //     break;
    //   case 3:
    //     {
    //
    //
    //       var imageRes = await uploadImage(File(pickedFile!.path));
    //
    //       if (json.decode(imageRes.body!)['Status'] == 'success') {
    //         imageListSnapshot.data![3]= json.decode(imageRes.body!)['FileID'];
    //
    //       }
    //     }
    //     break;
    // }
    changedImageList.call(imageListSnapshot.data!);

  }
  checkButtonDisability( CustomFeatures customFeaturesData) {
    if (customFeaturesData.name!.trim()!= "" ) {

      return false;
    } else {
      return true;

    }

  }
  @override
  void dispose() {
    _addPhotosController.close();
    _customFeatureController.close();
    _imageListController.close();
    _progressIndicatorController.close();
  }

}