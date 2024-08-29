import 'dart:async';
import 'dart:convert' show Utf8Decoder, json;
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/list_a_car/request_service/add_photos_documents_request.dart';
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:ridealike/pages/trips/request_service/end_trip_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_car_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_guest_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_host_request.dart';
import 'package:ridealike/pages/trips/request_service/rent_out_inspection_request.dart';
import 'package:ridealike/pages/trips/response_model/end_trip_inspect_rental_response.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/start_trip_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:rxdart/rxdart.dart';

class EndTripRentalBloc implements BaseBloc {
  final _endTripDataController =
      BehaviorSubject<InspectTripEndRentalResponse>();
  final _tripRateCarController = BehaviorSubject<RateTripCarRequest>();
  final _tripRateHostController = BehaviorSubject<RateTripHostRequest>();
  final _rateTripGuestController = BehaviorSubject<RateTripGuestRequest>();
  final storage = new FlutterSecureStorage();
  final ImagePicker picker = ImagePicker();
  final _endTripDeleteDataController =
      BehaviorSubject<InspectTripEndRentalResponse>();

  Function(InspectTripEndRentalResponse) get changedStartTripData =>
      _endTripDeleteDataController.sink.add;

  Stream<InspectTripEndRentalResponse> get startTripData =>
      _endTripDeleteDataController.stream;

  Function(InspectTripEndRentalResponse) get changedEndTripData =>
      _endTripDataController.sink.add;

  Function(RateTripCarRequest) get changedTripRateCar =>
      _tripRateCarController.sink.add;

  Function(RateTripHostRequest) get changedTripRateHost =>
      _tripRateHostController.sink.add;

  Function(RateTripGuestRequest) get changedRateTripGuest =>
      _rateTripGuestController.sink.add;

  Stream<InspectTripEndRentalResponse> get endTripData =>
      _endTripDataController.stream;

  Stream<RateTripCarRequest> get tripRateCar => _tripRateCarController.stream;

  Stream<RateTripHostRequest> get tripRateHost =>
      _tripRateHostController.stream;

  Stream<RateTripGuestRequest> get rateTripGuest =>
      _rateTripGuestController.stream;

  final _damageSelectionController = BehaviorSubject<int>();

  Function(int) get changedDamageSelection =>
      _damageSelectionController.sink.add;

  Stream<int> get damageSelection => _damageSelectionController.stream;

  @override
  void dispose() {
    _endTripDataController.close();
    _tripRateCarController.close();
    _tripRateHostController.close();
    _damageSelectionController.close();
    _endTripDeleteDataController.close();
    _rateTripGuestController.close();
  }

  Future<InspectTripEndRentalResponse?> endTripInspectionsMethod(
      InspectTripEndRentalResponse data) async {
    var resp = await endTripInspections(data);
    if (resp != null && resp.statusCode == 200) {
      InspectTripEndRentalResponse inspectTripEndRentalResponse =
          InspectTripEndRentalResponse.fromJson(json.decode(resp.body!));
      return inspectTripEndRentalResponse;
    } else {
      return null;
    }
  }

  Future<TripStartResponse?> endTripMethod(
      String tripID, Trips tripDetails) async {
    var resp = await endTrip(tripID);
    if (resp != null && resp.statusCode == 200) {
      TripStartResponse tripStartResponse =
          TripStartResponse.fromJson(json.decode(resp.body!));

      await rateThisTripAndHost(tripDetails);

      return tripStartResponse;
    } else {
      _endTripDataController.sink.add(json.decode(resp.body!)['error']);
      return null;
    }
  }

  pickeImageThroughCamera(
      int i,
      AsyncSnapshot<InspectTripEndRentalResponse> endTripDataSnapshot,
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
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![0] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 2:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![1] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 3:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![2] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 4:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![3] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 5:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![4] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 6:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![5] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 7:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![6] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 8:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![7] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 9:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![8] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 10:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![9] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 11:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![10] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 12:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![11] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 13:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![0] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 14:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![1] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 15:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![2] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 16:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![3] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 17:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![4] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 18:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![5] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 19:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![6] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 20:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![7] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 21:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![8] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 22:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![0] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 23:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![1] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 24:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![2] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 25:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![3] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 26:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![4] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 27:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![5] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 28:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![6] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 29:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![7] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 30:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![8] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 31:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .fuelImageIDs![0] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 32:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .mileageImageIDs![0] = json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 33:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot
                      .data!.tripEndInspectionRental!.fuelReceiptImageIDs![0] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
        case 34:
          {
            var imageRes = await uploadImage(File(pickedFile!.path));

            if (json.decode(imageRes.body!)['Status'] == 'success') {
              endTripDataSnapshot
                      .data!.tripEndInspectionRental!.fuelReceiptImageIDs![1] =
                  json.decode(imageRes.body!)['FileID'];
            }
          }
          break;
      }
      changedEndTripData.call(endTripDataSnapshot.data!);
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

  pickeImageFromGallery(
      int i,
      AsyncSnapshot<InspectTripEndRentalResponse> endTripDataSnapshot,
      context) async {
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
        case 1:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 2:
          {
            // var imageRes = await uploadImage(File(pickedFile!.path));

            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 3:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![2] = imageRes['FileID'];
            }
          }
          break;
        case 4:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![3] = imageRes['FileID'];
            }
          }
          break;
        case 5:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![4] = imageRes['FileID'];
            }
          }
          break;
        case 6:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![5] = imageRes['FileID'];
            }
          }
          break;
        case 7:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![6] = imageRes['FileID'];
            }
          }
          break;
        case 8:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![7] = imageRes['FileID'];
            }
          }
          break;
        case 9:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![8] = imageRes['FileID'];
            }
          }
          break;
        case 10:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![9] = imageRes['FileID'];
            }
          }
          break;
        case 11:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![10] = imageRes['FileID'];
            }
          }
          break;
        case 12:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .damageImageIDs![11] = imageRes['FileID'];
            }
          }
          break;
        case 13:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 14:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 15:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![2] = imageRes['FileID'];
            }
          }
          break;
        case 16:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![3] = imageRes['FileID'];
            }
          }
          break;
        case 17:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![4] = imageRes['FileID'];
            }
          }
          break;
        case 18:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![5] = imageRes['FileID'];
            }
          }
          break;
        case 19:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![6] = imageRes['FileID'];
            }
          }
          break;
        case 20:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![7] = imageRes['FileID'];
            }
          }
          break;
        case 21:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .exteriorImageIDs![8] = imageRes['FileID'];
            }
          }
          break;
        case 22:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 23:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
        case 24:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![2] = imageRes['FileID'];
            }
          }
          break;
        case 25:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![3] = imageRes['FileID'];
            }
          }
          break;
        case 26:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![4] = imageRes['FileID'];
            }
          }
          break;
        case 27:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![5] = imageRes['FileID'];
            }
          }
          break;
        case 28:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![6] = imageRes['FileID'];
            }
          }
          break;
        case 29:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![7] = imageRes['FileID'];
            }
          }
          break;
        case 30:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .interiorImageIDs![8] = imageRes['FileID'];
            }
          }
          break;
        case 31:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .fuelImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 32:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .mileageImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 33:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .fuelReceiptImageIDs![0] = imageRes['FileID'];
            }
          }
          break;
        case 34:
          {
            if (imageRes['Status'] == 'success') {
              endTripDataSnapshot.data!.tripEndInspectionRental!
                  .fuelReceiptImageIDs![1] = imageRes['FileID'];
            }
          }
          break;
      }
      changedEndTripData.call(endTripDataSnapshot.data!);
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

  Future<void> rateThisTripAndHost(Trips trips) async {
    // call Rate trip if available
    if (trips.carRatingReviewAdded == false) {
      RateTripCarRequest rateTripCarRequest =
          _tripRateCarController.stream.value;
      if (double.parse(rateTripCarRequest.rateCar!) != 0) {
        // call service here
        var resp = await rentalRateTripCar(rateTripCarRequest);
        TripStartResponse tripStartResponse =
            TripStartResponse.fromJson(json.decode(resp.body!));
        if (tripStartResponse != null) {
          trips.carRatingReviewAdded = tripStartResponse.status!.success;
        }
      }
    }
    // call Host rate if available
    if (trips.hostRatingReviewAdded == false) {
      RateTripHostRequest rateTripHostRequest =
          _tripRateHostController.stream.value;
      if (double.parse(rateTripHostRequest.rateHost!) != 0) {
        AppEventsUtils.logEvent("trip_reviewed_as_guest", params: {
          "trip_id": trips.tripID,
          "location": trips.location,
          "start_date": trips.startDateTime?.toIso8601String(),
          "end_date": trips.endDateTime?.toIso8601String(),
          "car_id": trips.carID,
          "car_name": trips.carName,
          "car_rating": trips.car!.rating?.toStringAsFixed(1),
          "car_trips": trips.car!.numberOfTrips,
          "host_rating": trips.hostProfile!.profileRating?.toStringAsFixed(1),
          "host_trips": trips.hostProfile!.numberOfTrips
        });
        // call service here
        var resp = await rentalRateTripHost(rateTripHostRequest);
        TripStartResponse tripStartResponse =
            TripStartResponse.fromJson(json.decode(resp.body!));
        if (tripStartResponse != null) {
          trips.hostRatingReviewAdded = tripStartResponse.status!.success;
        }
      }
    }
  }

  Future<void> rateGuest(Trips trips) async {
    // call Host rate if available
    if (trips.guestRatingReviewAdded == false) {
      RateTripGuestRequest rateTripGuestRequest =
          _rateTripGuestController.stream.value;
      if (double.parse(rateTripGuestRequest.rateGuest!) != 0) {
        AppEventsUtils.logEvent("trip_reviewed_as_host", params: {
          "trip_id": trips.tripID,
          "location": trips.location,
          "start_date": trips.startDateTime?.toIso8601String(),
          "end_date": trips.endDateTime?.toIso8601String(),
          "car_id": trips.carID,
          "car_name": trips.carName,
          "car_rating": trips.car!.rating?.toStringAsFixed(1),
          "car_trips": trips.car!.numberOfTrips,
          "host_rating": trips.hostProfile!.profileRating?.toStringAsFixed(1),
          "host_trips": trips.hostProfile!.numberOfTrips
        });
        // call service here
        var resp = await rentOutRateTripGuest(rateTripGuestRequest);
        TripStartResponse tripStartResponse =
            TripStartResponse.fromJson(json.decode(resp.body!));
        if (tripStartResponse != null) {
          trips.guestRatingReviewAdded = tripStartResponse.status!.success;
        }
      }
    }
  }

  checkValidity(
    InspectTripEndRentalResponse data,
    Trips tripDetails,
  ) {
    int mileage = 0;
    if (data!.tripEndInspectionRental!.isNoticibleDamage!) {
      if (data!.tripEndInspectionRental!.damageImageIDs![0] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![1] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![2] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![3] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![4] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![5] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![6] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![7] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![8] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![9] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![10] == '' &&
          data!.tripEndInspectionRental!.damageImageIDs![11] == '') {
        return false;
      }
    }
    if (data!.tripEndInspectionRental!.exteriorCleanliness == null) {
      return false;
    }
    if (data!.tripEndInspectionRental!.interiorCleanliness == null) {
      return false;
    }

    if (data!.tripEndInspectionRental!.interiorImageIDs![0] == '' &&
        data!.tripEndInspectionRental!.interiorImageIDs![1] == '' &&
        data!.tripEndInspectionRental!.interiorImageIDs![2] == '') {
      return false;
    }
    if (data!.tripEndInspectionRental!.exteriorImageIDs![0] == '' &&
        data!.tripEndInspectionRental!.exteriorImageIDs![1] == '' &&
        data!.tripEndInspectionRental!.exteriorImageIDs![2] == '') {
      return false;
    }

    if (data!.tripEndInspectionRental!.mileageImageIDs![0] == '' &&
        data!.tripEndInspectionRental!.mileageImageIDs![1] == '') {
      return false;
    }
    if (data!.tripEndInspectionRental!.fuelImageIDs![0] == '' &&
        data!.tripEndInspectionRental!.fuelImageIDs![1] == '') {
      return false;
    }
    if (data!.tripEndInspectionRental!.fuelReceiptImageIDs![0] == '' &&
        data!.tripEndInspectionRental!.fuelReceiptImageIDs![1] == '') {
      return false;
    }

    if (data!.tripEndInspectionRental!.interiorCleanliness == null) {
      return false;
    }

    // if(data!.tripEndInspectionRental!.isNoticibleDamage){

    if (data!.tripEndInspectionRental!.fuelLevel!.trim() == '') {
      return false;
    }

//}

//if(data!.tripEndInspectionRental!.isNoticibleDamage){
    if (data!.tripEndInspectionRental!.mileage == 0) {
      return false;
    }
//}

    // if(tripDetails.car!.features.fuelType!='electric' && tripDetails.car!.features.fuelType!='87 regular' ) {
    //   if(data!.tripEndInspectionRental!.fuelReceiptImageIDs[0]=='' && data!.tripEndInspectionRental!.fuelReceiptImageIDs[1]==''){
    //     return false ;
    //   }
    // }

    return true;
  }
}
