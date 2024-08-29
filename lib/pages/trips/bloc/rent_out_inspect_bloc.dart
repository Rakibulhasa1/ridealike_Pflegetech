import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/list_a_car/request_service/add_photos_documents_request.dart';
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_guest_request.dart';
import 'package:ridealike/pages/trips/request_service/rent_out_inspection_request.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/rent_out_inspect_trips_response.dart';
import 'package:ridealike/pages/trips/response_model/start_trip_response.dart';
import 'package:ridealike/pages/trips/response_model/swap_agree_carinfo_response.dart';
import 'package:rxdart/rxdart.dart';

class RentOutInspectBloc implements BaseBloc {
  String errorMessage = "";
  final _rentOutInspectController = BehaviorSubject<InspectTripEndRentoutResponse>();
  final _rateTripGuestController = BehaviorSubject<RateTripGuestRequest>();
  final _swapAgreementController = BehaviorSubject<SwapAgreementCarInfoResponse>();
  final storage = new FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  Function(InspectTripEndRentoutResponse) get changedInspectData =>
      _rentOutInspectController.sink.add;

  Function(RateTripGuestRequest) get changedRateTripGuest =>
      _rateTripGuestController.sink.add;

  Function(SwapAgreementCarInfoResponse) get changedSwapAgreement =>
      _swapAgreementController.sink.add;

  Stream<InspectTripEndRentoutResponse> get inspectData =>
      _rentOutInspectController.stream;

  Stream<RateTripGuestRequest> get rateTripGuest =>
      _rateTripGuestController.stream;

  Stream<SwapAgreementCarInfoResponse> get swapAgreement =>
      _swapAgreementController.stream;

  SwapAgreementCarInfoResponse? swapAgreementCarInfoResponse;


  final _damageSelectionController = BehaviorSubject<int>();

  Function(int) get changedDamageSelection =>
      _damageSelectionController.sink.add;

  Stream<int> get damageSelection => _damageSelectionController.stream;

  @override
  void dispose() {
    _rentOutInspectController.close();
    _rateTripGuestController.close();
    _damageSelectionController.close();
    _swapAgreementController.close();
  }

  Future<InspectTripEndRentoutResponse?> inspectRentout(
      InspectTripEndRentoutResponse data, Trips tripDetails) async {
    var resp = await inspectTripEndRentout(data);
    if (resp != null && resp.statusCode == 200) {
      InspectTripEndRentoutResponse inspectTripEndRentoutResponse =
          InspectTripEndRentoutResponse.fromJson(json.decode(resp.body!));
      await rateGuest(tripDetails);
      return inspectTripEndRentoutResponse;
    } else {
      // _rentOutInspectController.sink.addError(json.decode(resp.body!)['error']);
      errorMessage = json.decode(resp.body!)['error'];

      return null;
    }
  }

  pickeImageThroughCamera(int i, AsyncSnapshot<InspectTripEndRentoutResponse> inspectDataSnapshot, context) async {
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

      if(i < 13){
        var imageRes = await uploadImage(File(pickedFile!.path));
        if (json.decode(imageRes.body!)['Status'] == 'success') {
          inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![i-1] = json.decode(imageRes.body!)['FileID'];
        }
      }else{
        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
       //   inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![i-13] = json.decode(imageRes.body!)['FileID'];
        }
      }
      switch (i) {
        case 1:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![0] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 2:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![1] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 3:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![2] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 4:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![3] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 5:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![4] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 6:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![5] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 7:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![6] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 8:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![7] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 9:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![8] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 10:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![9] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 11:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.damageImageIDs![10] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 12:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!
                  .damageImageIDs![11] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 13:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![0] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 14:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![1] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 15:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![2] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 16:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!
                  .exteriorImageIDs![3] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 17:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!
                  .exteriorImageIDs![4] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 18:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![5] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 19:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![6] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 20:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![7] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 21:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![8] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 22:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![0] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 23:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![1] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 24:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![2] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 25:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![3] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 26:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![4] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 27:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![5] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 28:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![6] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 29:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![7] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 30:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![8] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;

        case 36:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![1] =
              json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 32:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.mileageImageIDs![1] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 33:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.ticketsTollsReimbursement!.imageIDs![0] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 34:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.ticketsTollsReimbursement!.imageIDs![1] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 35:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.ticketsTollsReimbursement!.imageIDs![2] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;

      }

      changedInspectData.call(inspectDataSnapshot.data!);
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
  pickeImageFromGallery(int i, AsyncSnapshot<InspectTripEndRentoutResponse> inspectDataSnapshot, context) async {
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

      if(i < 13){
        if (imageRes['Status'] == 'success') {
          inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![i-1] = imageRes['FileID'];
        }
      }else{
        // if (imageRes['Status'] == 'success') {
        //   inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![i-13] = imageRes['FileID'];
        // }
      }
      switch (i) {
        case 1:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![0] =
              imageRes['FileID'];
            }
          }
          break;
        case 2:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![1] =
              imageRes['FileID'];
            }
          }
          break;
        case 3:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![2] =
              imageRes['FileID'];
            }
          }
          break;
        case 4:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![3] =
              imageRes['FileID'];
            }
          }
          break;
        case 5:
          {
            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![4] =
              imageRes['FileID'];
            }
          }
          break;
        case 6:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![5] =
              imageRes['FileID'];
            }
          }
          break;
        case 7:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![6] =
              imageRes['FileID'];
            }
          }
          break;
        case 8:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![7] =
              imageRes['FileID'];
            }
          }
          break;
        case 9:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![8] =
              imageRes['FileID'];
            }
          }
          break;
        case 10:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![9] =
              imageRes['FileID'];
            }
          }
          break;
        case 11:
          {
            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.damageImageIDs![10] = imageRes['FileID'];
            }
          }
          break;
        case 12:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.damageImageIDs![11] = imageRes['FileID'];
            }
          }
          break;
        case 13:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.ticketsTollsReimbursement!.imageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 14:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.ticketsTollsReimbursement!.imageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 15:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.ticketsTollsReimbursement!.imageIDs![2] = imageRes['FileID'];
            }
          }
          break;
        case 16:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 17:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 18:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![2] = imageRes['FileID'];
            }
          }
          break;
        case 19:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![3] = imageRes['FileID'];
            }
          }
          break;
        case 20:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![4] = imageRes['FileID'];
            }
          }
          break;
        case 21:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.exteriorImageIDs![5] = imageRes['FileID'];
            }
          }
          break;
        case 22:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 23:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 24:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![2] = imageRes['FileID'];
            }
          }
          break;
        case 25:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![3] = imageRes['FileID'];
            }
          }
          break;
        case 26:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![4] = imageRes['FileID'];
            }
          }
          break;
        case 27:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![5] = imageRes['FileID'];
            }
          }
          break;
        case 28:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![6] = imageRes['FileID'];
            }
          }
          break;
        case 29:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![7] = imageRes['FileID'];
            }
          }
          break;
        case 30:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.interiorImageIDs![8] = imageRes['FileID'];
            }
          }
          break;
        case 36:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![1] =
              imageRes['FileID'];
            }
          }
          break;
        case 32:
          {
            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.mileageImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 33:
          {
            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.ticketsTollsReimbursement!.imageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 34:
          {
            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.ticketsTollsReimbursement!.imageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 35:
          {
            if (imageRes['Status'] == 'success') {
              inspectDataSnapshot.data!.tripEndInspectionRentout
                  !.ticketsTollsReimbursement!.imageIDs![2] = imageRes['FileID'];
            }
          }
          break;
      }
      changedInspectData.call(inspectDataSnapshot.data!);
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

  Future<void> rateGuest(Trips trips) async {
    // call Host rate if available
    if (trips.guestRatingReviewAdded == false) {
      RateTripGuestRequest rateTripGuestRequest =
          _rateTripGuestController.stream.value;
      if (double.parse(rateTripGuestRequest.rateGuest!) != 0) {
        // call service here
        var resp = await rentOutRateTripGuest(rateTripGuestRequest);
        TripStartResponse tripStartResponse =
            TripStartResponse.fromJson(json.decode(resp.body!));
        if (tripStartResponse != null) {
          trips.guestRatingReviewAdded = true;
        }
      }
    }
  }

  Future<void> getSwapAgreementTermsService(Trips trips) async {
    var userID = await storage.read(key: 'user_id');
    var response = await getSwapAgreementTerms(trips.swapAgreementID, userID);
    if (response != null && response.statusCode == 200) {
      swapAgreementCarInfoResponse = SwapAgreementCarInfoResponse.fromJson(json.decode(response.body!));
      changedSwapAgreement.call(swapAgreementCarInfoResponse!);
    }
  }

  checkValidation(InspectTripEndRentoutResponse data) {
    if (data!.tripEndInspectionRentout!.isTicketsTolls!) {
      if (data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![0] == '' &&
          data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![1] == '' &&
          data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![2] == '' ) {
        return false;
      }
    }
    if (data!.tripEndInspectionRentout!.isTicketsTolls!) {
      if (data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.amount ==0) {
        return false;
      }
    }
    return true;
  }
}
