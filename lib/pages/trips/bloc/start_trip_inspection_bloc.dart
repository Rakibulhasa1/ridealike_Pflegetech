import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/list_a_car/request_service/add_photos_documents_request.dart';
// import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:ridealike/pages/trips/request_service/start_trip_inspect_request.dart';
import 'package:ridealike/pages/trips/response_model/start_trip_inspect_rental_response.dart';
import 'package:ridealike/pages/trips/response_model/start_trip_response.dart';
import 'package:rxdart/rxdart.dart';

class StartTripBloc implements BaseBloc {
  final _startTripDataController = BehaviorSubject<InspectTripStartResponse>();
  final storage = new FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  Function(InspectTripStartResponse) get changedStartTripData =>
      _startTripDataController.sink.add;

  Stream<InspectTripStartResponse> get startTripData =>
      _startTripDataController.stream;

  final _damageSelectionController = BehaviorSubject<int>();

  Function(int) get changedDamageSelection =>
      _damageSelectionController.sink.add;

  Stream<int> get damageSelection => _damageSelectionController.stream;

  pickeImageThroughCamera(
      int i,
      AsyncSnapshot<InspectTripStartResponse> startTripDataSnapshot,
      context) async {
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
        case 1:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![0] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 2:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![1] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 3:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 4:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![3] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 5:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![4] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 6:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![5] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 7:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![6] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 8:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![7] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 9:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![8] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 10:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![9] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 11:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.damageImageIDs![10] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 12:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.damageImageIDs![11] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 13:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![0] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 14:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.exteriorImageIDs![1] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;
        case 15:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.exteriorImageIDs![2] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;
        case 16:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.exteriorImageIDs![3] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;
        case 17:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.exteriorImageIDs![4] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;
        case 18:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.exteriorImageIDs![5] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;
        case 19:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.exteriorImageIDs![6] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;
        case 20:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.exteriorImageIDs![7] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 21:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.exteriorImageIDs![8] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 22:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.interiorImageIDs![0] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 23:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.interiorImageIDs![1] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 24:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.interiorImageIDs![2] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 25:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.interiorImageIDs![3] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 26:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.interiorImageIDs![4] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 27:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.interiorImageIDs![5] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 28:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.interiorImageIDs![6] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 29:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.interiorImageIDs![7] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 30:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.interiorImageIDs![8] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;  case 31:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.fuelImageIDs![0] = json.decode(imageRes.body!)['FileID'];
          }
        }
        break;
        case 32:
        {
          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            startTripDataSnapshot.data!.tripStartInspection
                !.mileageImageIDs![0] = json.decode(imageRes.body!)['FileID'];
          }
        }
          break;
        case 33:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.fuelImageIDs![1] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 34:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.mileageImageIDs![1] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 35:
          {
            var imageRes =await uploadImage(File (pickedFile!.path));
            if (json.decode(imageRes.body!)['Status']== 'success'){
              startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![2]
                  = json.decode(imageRes.body!)['FileID'];
            }
          }
      }
      changedStartTripData.call(startTripDataSnapshot.data!);
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
  }

  pickeImageFromGallery(int i,
      AsyncSnapshot<InspectTripStartResponse> startTripDataSnapshot,
      context) async {
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

      switch (i) {
        case 1:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![0] =
                  imageRes['FileID'];
            }
          }
          break;
        case 2:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![1] =
                  imageRes['FileID'];
            }
          }
          break;
        case 3:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2] =
                  imageRes['FileID'];
            }
          }
          break;
        case 4:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![3] =
                  imageRes['FileID'];
            }
          }
          break;
        case 5:
          {
            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![4] =
                  imageRes['FileID'];
            }
          }
          break;
        case 6:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![5] =
                  imageRes['FileID'];
            }
          }
          break;
        case 7:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![6] =
                  imageRes['FileID'];
            }
          }
          break;
        case 8:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![7] =
                  imageRes['FileID'];
            }
          }
          break;
        case 9:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![8] =
                  imageRes['FileID'];
            }
          }
          break;
        case 10:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![9] =
                  imageRes['FileID'];
            }
          }
          break;
        case 11:
          {
            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.damageImageIDs![10] = imageRes['FileID'];
            }
          }
          break;
        case 12:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.damageImageIDs![11] = imageRes['FileID'];
            }
          }
          break;
        case 13:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 14:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 15:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![2] = imageRes['FileID'];
            }
          }
          break;
        case 16:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![3] = imageRes['FileID'];
            }
          }
          break;
        case 17:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![4] = imageRes['FileID'];
            }
          }
          break;
        case 18:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![5] = imageRes['FileID'];
            }
          }
          break;
        case 19:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![6] = imageRes['FileID'];
            }
          }
          break;
        case 20:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![7] = imageRes['FileID'];
            }
          }
          break;
        case 21:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.exteriorImageIDs![8] = imageRes['FileID'];
            }
          }
          break;
        case 22:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.interiorImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 23:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.interiorImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 24:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.interiorImageIDs![2] = imageRes['FileID'];
            }
          }
          break;
        case 25:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.interiorImageIDs![3] = imageRes['FileID'];
            }
          }
          break;
        case 26:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.interiorImageIDs![4] = imageRes['FileID'];
            }
          }
          break;
        case 27:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.interiorImageIDs![5] = imageRes['FileID'];
            }
          }
          break;
        case 28:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.interiorImageIDs![6] = imageRes['FileID'];
            }
          }
          break;
        case 29:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.interiorImageIDs![7] = imageRes['FileID'];
            }
          }
          break;
        case 30:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.interiorImageIDs![8] = imageRes['FileID'];
            }
          }
          break;
        case 31:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.fuelImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 32:
          {
            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.mileageImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 33:
          {
            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.fuelImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 34:
          {
            if (imageRes['Status'] == 'success') {
              startTripDataSnapshot.data!.tripStartInspection
                  !.mileageImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
      }
      changedStartTripData.call(startTripDataSnapshot.data!);
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
  void dispose() {
    _startTripDataController.close();
    _damageSelectionController.close();
  }

  // Future<InspectTripStartResponse> startTripInspectionsMethod(
  //     InspectTripStartResponse data) async {
  //   var resp = await startTripAfterInspection(data);
  //   if (resp != null && resp.statusCode == 200) {
  //     InspectTripStartResponse inspectTripStartResponse =
  //         InspectTripStartResponse.fromJson(json.decode(resp.body!));
  //     return inspectTripStartResponse;
  //   } else {
  //     return null;
  //   }
  // }

  Future<InspectTripStartResponse?> startTripInspectionsMethod(
      InspectTripStartResponse data) async {
    var resp = await startTripInspections(data);
    if (resp != null && resp.statusCode == 200) {
      InspectTripStartResponse inspectTripStartResponse =
      InspectTripStartResponse.fromJson(json.decode(resp.body!));
      return inspectTripStartResponse;
    } else {
      return null;
    }
  }

  Future<TripStartResponse?> startTripMethod(tripInspectionData) async {
    var resp = await startTrip(tripInspectionData);
    if (resp != null && resp.statusCode == 200) {
      TripStartResponse tripStartResponse =
          TripStartResponse.fromJson(json.decode(resp.body!));
      return tripStartResponse;
    } else {
      return null;
    }
  }

  checkValidation(InspectTripStartResponse data) {
    if (data!.tripStartInspection!.isNoticibleDamage!) {
      if (data!.tripStartInspection!.damageImageIDs![0] == '' &&
          data!.tripStartInspection!.damageImageIDs![1] == '' &&
          data!.tripStartInspection!.damageImageIDs![2] == '' &&
          data!.tripStartInspection!.damageImageIDs![3] == '' &&
          data!.tripStartInspection!.damageImageIDs![4] == '' &&
          data!.tripStartInspection!.damageImageIDs![5] == '' &&
          data!.tripStartInspection!.damageImageIDs![6] == '' &&
          data!.tripStartInspection!.damageImageIDs![7] == '' &&
          data!.tripStartInspection!.damageImageIDs![8] == '' &&
          data!.tripStartInspection!.damageImageIDs![9] == '' &&
          data!.tripStartInspection!.damageImageIDs![10] == '' &&
          data!.tripStartInspection!.damageImageIDs![11] == '') {
        return false;
      }
    }
    // if (data!.tripStartInspection!.dashboardImageIDs[0] == '' &&
    //     data!.tripStartInspection!.dashboardImageIDs[1] == '') {
    //   return false;
    // }


    if(data!.tripStartInspection!.mileage==0){
     return false;
    }

    return true;
  }
}
