import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/base_bloc.dart';
import 'package:ridealike/pages/list_a_car/request_service/add_photos_documents_request.dart';
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:ridealike/pages/trips/request_service/request_reimbursement.dart';
import 'package:ridealike/pages/trips/response_model/reimbursment_response.dart';
import 'package:rxdart/rxdart.dart';
class ReimbursementBloc implements BaseBloc{
  final _reimbursementController=BehaviorSubject<ReimbursementResponse>();
  Function(ReimbursementResponse) get changedReimbursementData =>_reimbursementController.sink.add ;
  Stream<ReimbursementResponse> get reimbursementData=>_reimbursementController.stream;


  pickeImageThroughCamera(int i, ReimbursementResponse data,context) async {
    var status = true;
    // if (Platform.isIOS) {
    //   status = await Permission.camera.request().isGranted;
    // }
    final picker = ImagePicker();
  if(status)
  {
    final pickedFile = await picker.pickImage(
    source: ImageSource.camera,
    imageQuality: 50,
    maxHeight: 500,
    maxWidth: 500,
    preferredCameraDevice: CameraDevice.rear
);

switch (i) {
  case 1: {
    var imageRes = await uploadImage(File(pickedFile!.path));

    if (json.decode(imageRes.body!)['Status'] == 'success') {
      data.reimbursement!.imageIDs![0] = json.decode(imageRes.body!)['FileID'];
    }
  }
  break;
  case 2: {
    var imageRes = await uploadImage(File(pickedFile!.path));

    if (json.decode(imageRes.body!)['Status'] == 'success') {
      data.reimbursement!.imageIDs![1] = json.decode(imageRes.body!)['FileID'];
    }
  }
  break;
  case 3: {
    var imageRes = await uploadImage(File(pickedFile!.path));

    if (json.decode(imageRes.body!)['Status'] == 'success') {
      data.reimbursement!.imageIDs![2] = json.decode(imageRes.body!)['FileID'];
    }
  }
  break;
}
changedReimbursementData.call(data);}
  else{
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

  pickeImageFromGallery(int i, ReimbursementResponse data,context) async {
    var status = true;

    // if (Platform.isIOS) {
    //   var perm = await Permission.photos.request();
    //   status = perm.isLimited || perm.isGranted;
    // } else {
    //   status = await Permission.storage.request().isGranted;
    // }
    // final picker = ImagePicker();
    var imageRes;
  if(status)
   {

  List<Asset> resultList = await ImageUtils.loadAssets();
  var imageName = resultList[0].name ?? '';
  var imageData = await resultList[0].getThumbByteData(500, 500, quality: 80);
  imageRes = await ImageUtils.sendImageData(imageData.buffer.asUint8List(),imageName);
  switch (i) {
  case 1: {

    if (imageRes['Status'] == 'success') {
      data.reimbursement!.imageIDs![0] =imageRes['FileID'];
    }
  }
  break;
    case 2: {
    if (imageRes['Status'] == 'success') {
      data.reimbursement!.imageIDs![1] =imageRes['FileID'];
    }
  }
  break;
    case 3: {

    if (imageRes['Status'] == 'success') {
      data.reimbursement!.imageIDs![2] =imageRes['FileID'];
    }
  }
  break;
  }
    changedReimbursementData.call(data);
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

   @override
  void dispose() {
    _reimbursementController.close();
  }

  requestReimbursementMethod(ReimbursementResponse data,String tripID)async {
    var resp=await requestReimbursement(data,tripID);
    if(resp!=null && resp.statusCode==200){
      ReimbursementResponse reimbursementResponse=ReimbursementResponse.fromJson(json.decode(resp.body!));
      return reimbursementResponse;
    }else{
      return null ;
    }
  }

  checkValidation(ReimbursementResponse data) {
    if ( data.reimbursement!.imageIDs![0]==''&& data.reimbursement!.imageIDs![1]=='' &&data.reimbursement!.imageIDs![2]==''){
      return false;
    }
if ( data.reimbursement!.amount==0){
      return false;
    }
if ( data.reimbursement!.description==''){
      return false;
    }

    return true;
  }

}