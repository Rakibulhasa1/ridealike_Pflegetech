// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:ridealike/pages/common/base_bloc.dart';
// import 'package:ridealike/pages/trips/request_service/start_trip_inspect_request.dart';
// import 'package:ridealike/pages/trips/response_model/guest_end_trip_details_response.dart';
// import 'package:ridealike/pages/trips/response_model/start_trip_response.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:http/http.dart' as http;
// import 'package:permission_handler/permission_handler.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:path/path.dart';
// import 'package:async/async.dart';
// import 'dart:async';
// import 'package:multi_image_picker/multi_image_picker.dart';
// import 'package:ridealike/pages/common/constant_url.dart';
// import 'package:ridealike/pages/messages/utils/imageutils.dart';
// import 'package:ridealike/pages/list_a_car/request_service/add_photos_documents_request.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
//
// class EndTripDetailsBloc implements BaseBloc {
//   final _endTripDetailsDataController = BehaviorSubject<EndTripDetailsResponse>();
//
//   Function(EndTripDetailsResponse) get changedStartTripData =>
//       _endTripDetailsDataController.sink.add;
//
//   Stream<EndTripDetailsResponse> get startTripData =>
//       _endTripDetailsDataController.stream;
//
//   final _damageSelectionController = BehaviorSubject<int>();
//
//   Function(int) get changedDamageSelection =>
//       _damageSelectionController.sink.add;
//
//   Stream<int> get damageSelection => _damageSelectionController.stream;
//
//   pickeImageThroughCamera(
//       int i,
//       AsyncSnapshot<InspectTripStartResponse> startTripDataSnapshot,
//       context) async {
//     var status = true;
//     if (Platform.isIOS) {
//       status = await Permission.camera.request().isGranted;
//     }
//
//     final picker = ImagePicker();
//     if (status) {
//       final pickedFile = await picker.getImage(
//           source: ImageSource.camera,
//           imageQuality: 50,
//           maxHeight: 500,
//           maxWidth: 500,
//           preferredCameraDevice: CameraDevice.rear);
//
//       switch (i) {
//         case 1:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![0] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 2:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![1] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 3:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 4:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![3] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 5:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![4] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 6:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![5] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 7:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![6] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 8:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![7] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 9:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![8] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 10:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![9] =
//               json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 11:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .damageImageIDs![10] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 12:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .damageImageIDs![11] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 13:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![0] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 14:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![1] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 15:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![2] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 16:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![3] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 17:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![4] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 18:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![5] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 19:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![6] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;
//         case 20:
//           {
//             var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (json.decode(imageRes.body!)['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![7] = json.decode(imageRes.body!)['FileID'];
//             }
//           }
//           break;  case 21:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .exteriorImageIDs![8] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 22:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .interiorImageIDs![0] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 23:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .interiorImageIDs![1] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 24:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .interiorImageIDs![2] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 25:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .interiorImageIDs![3] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 26:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .interiorImageIDs![4] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 27:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .interiorImageIDs![5] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 28:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .interiorImageIDs![6] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 29:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .interiorImageIDs![7] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 30:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 .interiorImageIDs![8] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 31:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 !.fuelImageIDs![0] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;  case 32:
//         {
//           var imageRes = await uploadImage(File(pickedFile.path));
//
//           if (json.decode(imageRes.body!)['Status'] == 'success') {
//             startTripDataSnapshot.data!.tripStartInspection
//                 !.mileageImageIDs![0] = json.decode(imageRes.body!)['FileID'];
//           }
//         }
//         break;
//       }
//       changedStartTripData.call(startTripDataSnapshot.data!);
//     } else {
//       Platform.isIOS
//           ? showDialog(
//         context: context,
//         builder: (context) {
//           return CupertinoAlertDialog(
//             title: Text('Permission Required'),
//             content: Text(
//                 'RideAlike needs permission to access your photo library to select a photo.'),
//             actions: [
//               CupertinoDialogAction(
//                 child: Text('Not now'),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//               CupertinoDialogAction(
//                 child: Text('Open settings'),
//                 onPressed: () async {
//                   // await storage.write(
//                   //     key: 'route', value: '/verify_identity_ui');
//                   // await storage.write(
//                   //     key: 'data',
//                   //     value: ;
//
//                   openAppSettings().whenComplete(() {
//                     return Navigator.pop(context);
//                   });
//                 },
//               ),
//             ],
//           );
//         },
//       )
//           : Container();
//     }
//   }
//
//   pickImageFromGallery(
//       int i,
//       AsyncSnapshot<InspectTripStartResponse> startTripDataSnapshot,
//       context) async {
//     var status = true;
//
//     if (Platform.isIOS) {
//       var perm = await Permission.photos.request();
//       status = perm.isLimited || perm.isGranted;
//     } else {
//       status = await Permission.storage.request().isGranted;
//     }
//     final picker = ImagePicker();
//     if (status) {
// //   final pickedFile = await picker.getImage(
// //     source: ImageSource.gallery,
// //     imageQuality: 50,
// //     maxHeight: 500,
// //     maxWidth: 500
// // );
//       List<Asset> resultList = List<Asset>();
//
//       var imageRes;
//       var data;
//       resultList = await ImageUtils.loadAssets();
//
//       for (var i = 0; i < resultList.length; i++) {
//         data = await resultList[i].getThumbByteData(500, 500, quality: 80);
//         imageRes = await ImageUtils.sendImageData(
//             data.buffer.asUint8List(), resultList[i].name);
//       }
//
//       switch (i) {
//         case 1:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![0] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 2:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![1] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 3:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 4:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![3] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 5:
//           {
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![4] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 6:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![5] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 7:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![6] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 8:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![7] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 9:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![8] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 10:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![9] =
//               imageRes['FileID'];
//             }
//           }
//           break;
//         case 11:
//           {
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .damageImageIDs![10] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 12:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .damageImageIDs![11] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 13:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![0] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 14:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![1] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 15:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![2] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 16:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![3] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 17:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![4] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 18:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![5] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 19:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![6] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 20:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![7] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 21:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .exteriorImageIDs![8] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 22:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .interiorImageIDs![0] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 23:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .interiorImageIDs![1] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 24:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .interiorImageIDs![2] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 25:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .interiorImageIDs![3] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 26:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .interiorImageIDs![4] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 27:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .interiorImageIDs![5] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 28:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .interiorImageIDs![6] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 29:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .interiorImageIDs![7] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 30:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   .interiorImageIDs![8] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 31:
//           {
//             // var imageRes = await uploadImage(File(pickedFile.path));
//
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   !.fuelImageIDs![0] = imageRes['FileID'];
//             }
//           }
//           break;
//         case 32:
//           {
//             if (imageRes['Status'] == 'success') {
//               startTripDataSnapshot.data!.tripStartInspection
//                   !.mileageImageIDs![0] = imageRes['FileID'];
//             }
//           }
//           break;
//       }
//       changedStartTripData.call(startTripDataSnapshot.data!);
//     } else {
//       showDialog(
//         context: context,
//         builder: (context) {
//           return CupertinoAlertDialog(
//             title: Text('Permission Required'),
//             content: Text(
//                 'RideAlike needs permission to access your photo library to select a photo.'),
//             actions: [
//               CupertinoDialogAction(
//                 child: Text('Not now'),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//               CupertinoDialogAction(
//                 child: Text('Open settings'),
//                 onPressed: () async {
//                   openAppSettings().whenComplete(() {
//                     return Navigator.pop(context);
//                   });
//                 },
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
//
//   @override
//   void dispose() {
//     _endTripDetailsDataController.close();
//     _damageSelectionController.close();
//   }
//
//   // Future<InspectTripStartResponse> startTripInspectionsMethod(
//   //     InspectTripStartResponse data) async {
//   //   var resp = await startTripAfterInspection(data);
//   //   if (resp != null && resp.statusCode == 200) {
//   //     InspectTripStartResponse inspectTripStartResponse =
//   //         InspectTripStartResponse.fromJson(json.decode(resp.body!));
//   //     return inspectTripStartResponse;
//   //   } else {
//   //     return null;
//   //   }
//   // }
//
//   Future<EndTripDetailsResponse> startTripInspectionsMethod(
//       EndTripDetailsResponse data) async {
//     var resp = await startTripInspections(data);
//     if (resp != null && resp.statusCode == 200) {
//       EndTripDetailsResponse inspectTripStartResponse =
//       EndTripDetailsResponse.fromJson(json.decode(resp.body!));
//       return inspectTripStartResponse;
//     } else {
//       return null;
//     }
//   }
//
//   Future<TripStartResponse> startTripMethod(tripInspectionData) async {
//     var resp = await startTrip(tripInspectionData);
//     if (resp != null && resp.statusCode == 200) {
//       TripStartResponse tripStartResponse =
//       TripStartResponse.fromJson(json.decode(resp.body!));
//       return tripStartResponse;
//     } else {
//       return null;
//     }
//   }
//
//   // checkValidation(InspectTripStartResponse data) {
//   //   if (data!.tripStartInspection!.isNoticibleDamage) {
//   //     if (data!.tripStartInspection!.damageImageIDs![0] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![1] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![2] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![3] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![4] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![5] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![6] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![7] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![8] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![9] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![10] == '' &&
//   //         data!.tripStartInspection!.damageImageIDs![11] == '') {
//   //       return false;
//   //     }
//   //   }
//   //   if (data!.tripStartInspection!.dashboardImageIDs[0] == '' &&
//   //       data!.tripStartInspection!.dashboardImageIDs[1] == '') {
//   //     return false;
//   //   }
//   //
//   //
//   //   // if(data!.tripStartInspection!.cleanliness == null){
//   //   //  return false;
//   //   // }
//   //
//   //   return true;
//   // }
// }
