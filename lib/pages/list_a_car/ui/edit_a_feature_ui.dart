import 'dart:convert' show json;
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';

import '../../../utils/app_events/app_events_utils.dart';

class EditFeatureUi extends StatefulWidget {
  @override
  State createState() => EditFeatureUiState();
}

class EditFeatureUiState extends  State<EditFeatureUi> {

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final storage = new FlutterSecureStorage();

  bool? _isButtonDisabled;

  int _descriptionCharCount = 0;

  bool _nameShowInput = false;

  String name='';

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Edit A Feature"});
    Future.delayed(Duration.zero,() async {
      CustomFeatures customFeatures = ModalRoute.of(context)!.settings.arguments as CustomFeatures;


      setState(() {
        _nameController.text = customFeatures.name!;
        name = customFeatures.name!;
        _descriptionController.text = customFeatures.description!;
        _descriptionCharCount = customFeatures.description!.length;

        for(var i = 0; i < customFeatures.imageIDs!.length; i++){
          if (i == 0){
            _imageID1 = customFeatures.imageIDs![i];
          } else if (i == 1) {
            _imageID2 = customFeatures.imageIDs![i];
          } else if (i == 2) {
            _imageID3 = customFeatures.imageIDs![i];
          }
        }
      });
    });

    _isButtonDisabled = true;

    _nameController.clear();
    _descriptionController.clear();
  }

  void _settingModalBottomSheet(context, _imgOrder){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
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
                  pickeImageThroughCamera(_imgOrder);
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
                  pickeImageFromGallery(_imgOrder);
                },          
              ),
              Divider(color: Color(0xFFABABAB)),
            ],
          ),
        );
      }
    );
  }

  File? _imageFile1;
  File? _imageFile2;
  File? _imageFile3;

  String _imageID1 = '';
  String _imageID2 = '';
  String _imageID3 = '';

  pickeImageThroughCamera(int i) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.camera, 
      imageQuality: 50, 
      maxHeight: 500,
      maxWidth: 500,
      preferredCameraDevice: CameraDevice.rear
    );

    switch (i) {
      case 1: {
        setState(() {_imageFile1 = File(pickedFile!.path);});

        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _imageID1 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 2: {
        setState(() {_imageFile2 = File(pickedFile!.path);});

        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _imageID2 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 3: {
        setState(() {_imageFile3 = File(pickedFile!.path);});

        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _imageID3 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
    }
  }

  pickeImageFromGallery(int i) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 50, 
      maxHeight: 500,
      maxWidth: 500
    );

    switch (i) {
      case 1: {
        setState(() {_imageFile1 = File(pickedFile!.path);});

        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _imageID1 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 2: {
        setState(() {_imageFile2 = File(pickedFile!.path);});

        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _imageID2 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
      case 3: {
        setState(() {_imageFile3 = File(pickedFile!.path);});

        var imageRes = await uploadImage(File(pickedFile!.path));

        if (json.decode(imageRes.body!)['Status'] == 'success') {
          setState(() {
            _imageID3 = json.decode(imageRes.body!)['FileID'];
          });                    
        }
      }
      break;
    }
  }
  
  @override
  Widget build (BuildContext context) {
    CustomFeatures customFeatures = ModalRoute.of(context)!.settings.arguments as CustomFeatures;

    _countDescriptionCharacter(String value) {
      setState(() {
        _descriptionCharCount = value.length;
      });
    }
    checkButtonDisability( ) {
      var name=_nameController.text;
      name=customFeatures.name!;
      if (name!= "" ) {
       setState(() {
         _isButtonDisabled=false;
       });
      } else {
        _isButtonDisabled= true;

      }

    }
    
    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pop(
              context, {"Status": "EDIT", "Data":customFeatures},
            );
          },
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pop(
                    context, {"Status": "REMOVE", "Data":customFeatures},
                  );
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text('Remove',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xffFF8F68),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
        elevation: 0.0,
      ),

      //Content of tabs
      body: SingleChildScrollView(
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
                            child: Text('Edit a feature',
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
                              controller: _nameController,
                              onChanged: (value ){
                                setState(() {
                                  name = value;
                                });
                              },
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]'),replacementString: '')],
                              textCapitalization: TextCapitalization.characters,
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('Description',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                    Text(_descriptionCharCount.toString() + '/500',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xFF353B50),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: <Widget>[
                                    TextFormField(
                                      textInputAction: TextInputAction.done,
                                      controller: _descriptionController,
                                      onChanged: _countDescriptionCharacter,
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
                                        counterText: '',
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
                    child: Column(
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
                              onTap: () => _settingModalBottomSheet(context, 1),
                              child: _imageID1 == '' ? Container(
                                color: Colors.transparent,
                                child: Container(
                                  child: Image.asset('icons/Add-Photo_Placeholder.png'),
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
                                    image: NetworkImage('$storageServerUrl/$_imageID1'),
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(12.0),
                                    bottomLeft: const Radius.circular(12.0),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 2),
                              child: _imageID2 == '' ? Container(
                                child: Image.asset('icons/Add-Photo_Placeholder.png'),
                                color: Color(0xFFF2F2F2),
                              ) : Container(
                                alignment: Alignment.bottomCenter,
                                width: 100,
                                height: 100,
                                decoration: new BoxDecoration(
                                  color: Color(0xFFF2F2F2),
                                  image: DecorationImage(
                                    image: NetworkImage('$storageServerUrl/$_imageID2'),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 3),
                              child: Container(
                                color: Colors.transparent,
                                child: _imageID3 == '' ? Container(
                                  child: Image.asset('icons/Add-Photo_Placeholder.png'),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    borderRadius: new BorderRadius.only(
                                      topRight: const Radius.circular(12.0),
                                      bottomRight: const Radius.circular(12.0),
                                    ),
                                  ),
                                ) : Container(
                                  alignment: Alignment.bottomCenter,
                                  width: 100,
                                  height: 100,
                                  decoration: new BoxDecoration(
                                    color: Color(0xFFF2F2F2),
                                    image: DecorationImage(
                                      image: NetworkImage('$storageServerUrl/$_imageID3'),
                                      fit: BoxFit.fill,
                                    ),
                                    borderRadius: new BorderRadius.only(
                                      topRight: const Radius.circular(12.0),
                                      bottomRight: const Radius.circular(12.0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Color(0xffFF8F68),
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                            ),
                              onPressed: name == null ||  name.trim()==''?null:() {


                              setState(() {
                                customFeatures.name = _nameController.text;
                                customFeatures.description = _descriptionController.text;
                                customFeatures.imageIDs = [_imageID1, _imageID2, _imageID3];
                              });

                              Navigator.pop(
                                context, {"Status": "EDIT", "Data":customFeatures}
                              );
                            },
                            child: Text('Save',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 18,
                                color: Colors.white
                              ),
                            ),
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

  uploadImage(filename) async {
    var stream = new http.ByteStream(DelegatingStream.typed(filename.openRead()));
    var length = await filename.length();

    var uri = Uri.parse(uploadUrl);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('files', stream, length, filename: Path.basename(filename.path));

    String? jwt = await storage.read(key: 'jwt');
    Map<String, String> headers = { "Authorization": "Bearer $jwt"};
    request.headers.addAll(headers);

    request.files.add(multipartFile);
    var response = await request.send();

    var response2 = await http.Response.fromStream(response);
    
    return response2;
  }
}
