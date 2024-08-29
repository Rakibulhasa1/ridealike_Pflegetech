import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/list_a_car/bloc/add_features_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/app_events/app_events_utils.dart';
//import 'package:ridealike/pages/profile/give_us_feedback.dart';

class AddFeatureUi extends StatefulWidget {
  @override
  State createState() => AddFeatureUiState();
}

class AddFeatureUiState extends State<AddFeatureUi> {
  var addFeaturesBloc = AddFeaturesBloc();


  bool _nameShowInput = false;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Add A Feature"});

  }

  void _settingModalBottomSheet(context, _imgOrder, AsyncSnapshot<HashMap<int, String>> imageListSnapshot) {
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
                              child: Text('Cancel',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Color(0xFFF68E65),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text('Attach photo',
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
                  title: Text('Take photo',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xFF371D32),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    addFeaturesBloc.pickeImageThroughCamera(_imgOrder, imageListSnapshot,context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
                new ListTile(
                  leading: Image.asset('icons/Attach-Photo_Sheet.png'),
                  title: Text('Attach photo',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xFF371D32),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    addFeaturesBloc.pickeImageFromGallery(_imgOrder, imageListSnapshot,context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
              ],
            ),
          );
        }
    );
  }




  @override
  Widget build(BuildContext context) {
  CreateCarResponse createCarResponse = ModalRoute.of(context)!.settings.arguments as CreateCarResponse;
  addFeaturesBloc.changedProgressIndicator.call(0);
  addFeaturesBloc.changedAddPhotos.call(createCarResponse);
  addFeaturesBloc.changedCustomFeature.call(CustomFeatures(name: '', description: '', imageIDs: []));
  addFeaturesBloc.changedImageList.call(HashMap<int, String> ());


    return Scaffold(
      backgroundColor: Colors.white,
      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pop(
              context, createCarResponse,
            );
          },
        ),
        elevation: 0.0,
      ),

      //Content of tabs
      body: StreamBuilder<CustomFeatures>(
        stream: addFeaturesBloc.customFeatures,
        builder: (context, customFeatureSnapshot) {
          return customFeatureSnapshot.hasData && customFeatureSnapshot.data!= null ?
          StreamBuilder<HashMap<int, String>>(
            stream: addFeaturesBloc.imageList,
            builder: (context, imageListSnapshot) {
              return Container(
                child: new SingleChildScrollView(
                  child: GestureDetector(
                    onTap: () {
                      FocusScopeNode currentFocus = FocusScope.of(context);

                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                    },

                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: <Widget>[
                          // Header
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        child: Text('Add a feature',
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 36,
                                              color: Color(0xFF371D32),
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          // Sub header
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Text('Describe your custom feature',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Name
                          _nameShowInput ? GestureDetector(
                            onTap: () {
                              setState(() {
                                _nameShowInput = false;
                              });
                            },
                            child: SizedBox(
                              width: double.maxFinite,
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                decoration: new BoxDecoration(
                                  color: Color(0xFFF2F2F2),
                                  borderRadius: new BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      child: Row(
                                        children: [
                                          Text('Name',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                          : Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius: BorderRadius.circular(8.0)
                                        ),
                                        child: TextFormField(
                                          initialValue: customFeatureSnapshot.data!.name,
                                          onChanged: (name ){
                                            customFeatureSnapshot.data!.name = name;
                                            addFeaturesBloc.changedCustomFeature.call(customFeatureSnapshot.data!);

                                          },
                                          inputFormatters:
                                          [ FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]'), replacementString: '' )],
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.all(16.0),
                                            border: InputBorder.none,
                                            hintText: 'Name',
                                            counterText: ""
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Description
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Container(
                                        padding: EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            borderRadius: BorderRadius.circular(8.0)
                                        ),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween,
                                              children: <Widget>[
                                                Text('Description',
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                  ),
                                                ),
                                                // Text( '${customFeatureSnapshot.data.description.length} /500' ,
                                                //   style: TextStyle(
                                                //     fontFamily: 'Urbanist',
                                                //     fontSize: 14,
                                                //     color: Color(0xFF353B50),
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                            Column(
                                              children: <Widget>[
                                                TextFormField(
                                                  textInputAction: TextInputAction.done,
                                                  initialValue: customFeatureSnapshot.data!.description,
                                                  onChanged: (description){
                                                    customFeatureSnapshot.data!.description = description;
                                                    addFeaturesBloc.changedCustomFeature.call(customFeatureSnapshot.data!);
                                                  },
                                                  minLines: 1,
                                                  maxLines: 5,
                                                  maxLength: 500,
                                              // maxLengthEnforced: true,
                                              keyboardType: TextInputType.visiblePassword,
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    hintText: 'Add feature description',
                                                    hintStyle: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        fontStyle: FontStyle.italic
                                                    ),

                                                  ),
                                                ),
                                              ],
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
                          SizedBox(height: 40),
                          // Add photos
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: Text('Add photos',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          // Image picker
                          Row(
                            children: <Widget>[
                              Expanded(
                                child: imageListSnapshot.hasData && imageListSnapshot.data!= null ?
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GridView.count(
                                      primary: false,
                                      shrinkWrap: true,
                                      crossAxisSpacing: 1,
                                      mainAxisSpacing: 1,
                                      crossAxisCount: 3,
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () =>
                                              _settingModalBottomSheet(context, 1, imageListSnapshot),
                                          child: imageListSnapshot.data![1] == null || imageListSnapshot.data![1]  == '' ? Container(
                                            color: Colors.transparent,
                                            child: Container(
                                              child: Image.asset(
                                                  'icons/Add-Photo_Placeholder.png',),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF2F2F2),
                                                borderRadius: new BorderRadius.only(
                                                  topLeft: const Radius.circular(12.0),
                                                  bottomLeft: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ),
                                          ) : Container(
                                            alignment: Alignment.bottomCenter,
                                            width: 100,
                                            height: 100,
                                            decoration: new BoxDecoration(
                                              color: Color(0xFFF2F2F2),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    '$storageServerUrl/${imageListSnapshot.data![1]}'),
                                                fit: BoxFit.cover,
                                              ),
                                              borderRadius: new BorderRadius.only(
                                                topLeft: const Radius.circular(12.0),
                                                bottomLeft: const Radius.circular(12.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              _settingModalBottomSheet(context, 2,imageListSnapshot),
                                          child: imageListSnapshot.data![2] == null || imageListSnapshot.data![2]  == '' ? Container(
                                            child: Image.asset(
                                                'icons/Add-Photo_Placeholder.png'),
                                            color: Color(0xFFF2F2F2),
                                          ) : Container(
                                            alignment: Alignment.bottomCenter,
                                            width: 100,
                                            height: 100,
                                            decoration: new BoxDecoration(
                                              color: Color(0xFFF2F2F2),
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    '$storageServerUrl/${imageListSnapshot.data![2]}'),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () =>
                                              _settingModalBottomSheet(context, 3, imageListSnapshot),
                                          child: Container(
                                            color: Colors.transparent,
                                            child: imageListSnapshot.data![3] == null || imageListSnapshot.data![3]  == '' ? Container(
                                              child: Image.asset(
                                                  'icons/Add-Photo_Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF2F2F2),
                                                borderRadius: new BorderRadius.only(
                                                  topRight: const Radius.circular(12.0),
                                                  bottomRight: const Radius.circular(
                                                      12.0),
                                                ),
                                              ),
                                            ) : Container(
                                              alignment: Alignment.bottomCenter,
                                              width: 100,
                                              height: 100,
                                              decoration: new BoxDecoration(
                                                color: Color(0xFFF2F2F2),
                                                image: DecorationImage(
                                                  image: NetworkImage(
                                                      '$storageServerUrl/${imageListSnapshot.data![3]}'),
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius: new BorderRadius.only(
                                                  topRight: const Radius.circular(12.0),
                                                  bottomRight: const Radius.circular(
                                                      12.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ) : Container(),
                              ),
                            ],
                          ),
                          SizedBox(height: 30),
                          // Save button
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  children: [
                                    SizedBox(
                                      width: double.maxFinite,
                                      child: StreamBuilder<int>(
                                        stream: addFeaturesBloc.progressIndicator,
                                        builder: (context, progressIndicatorSnapshot) {
                                          return ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              backgroundColor: Color(0xffFF8F68),
                                              padding: EdgeInsets.all(16.0),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                            ),
                                           // onPressed: _isButtonDisabled ? null : () async {
                                            onPressed: progressIndicatorSnapshot.data==1 || addFeaturesBloc.checkButtonDisability(customFeatureSnapshot.data!)? null: () async {
                                              addFeaturesBloc.changedProgressIndicator.call(1);
                                              customFeatureSnapshot.data!.imageIDs!.addAll(imageListSnapshot.data!.values);
                                              createCarResponse.car!.features!.customFeatures!.add(customFeatureSnapshot.data!);
                                              Navigator.pop(
                                                context, createCarResponse
                                              );

                                              // Navigator.pop(
                                              //   context,receivedData,
                                              // );
                                            },
                                            child: progressIndicatorSnapshot.data==0?
                                            Text('Save',
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 18,
                                                color: Colors.white
                                              ),
                                            ):       SizedBox(
                                              height: 18.0,
                                              width: 18.0,
                                              child: new CircularProgressIndicator(strokeWidth: 2.5),
                                            ) ,
                                          );
                                        }
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
          ) :SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 220,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, right: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: MediaQuery.of(context).size.width / 3,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 14,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 14,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
        }
      ),
    );
  }
}

//uploadImage(filename) async {
//  var stream = new http.ByteStream(DelegatingStream.typed(filename.openRead()));
//  var length = await filename.length();
//
//  var uri = Uri.parse(uploadUrl);
//  var request = new http.MultipartRequest("POST", uri);
//  var multipartFile = new http.MultipartFile('files', stream, length, filename: basename(filename.path));
//
//  request.files.add(multipartFile);
//  var response = await request.send();
//
//  var response2 = await http.Response.fromStream(response);
//
//  return response2;
//}
