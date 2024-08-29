import 'dart:async';
import 'dart:convert' show json;
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/common/rest_api_util.dart' as RestApi;

final TextEditingController _licensePlateController = TextEditingController();
final TextEditingController _vinController = TextEditingController();

class AddPhotosToListing extends StatefulWidget {
  @override
  State createState() => AddPhotosToListingState();
}

class AddPhotosToListingState extends State<AddPhotosToListing> {
  final storage = new FlutterSecureStorage();

  @override
  void initState() {
    super.initState();

    _carPhotos = {
      "_carID": '',
      "_licenseProvince": '',
      "_licensePlateNumber": '',
      "_currentKilometers": 100.0,
      "_carOwnershipDocumentID": '',
      "_vin": '',
      "_mainImageID": '',
      "_imageID1": '',
      "_imageID2": '',
      "_imageID3": '',
      "_imageID4": '',
      "_imageID5": '',
      "_imageID6": '',
      "_imageID7": '',
      "_imageID8": '',
      "_imageID9": '',
    };

    _isButtonDisabled = true;
    _licensePlateShowInput = false;
    _vinShowInput = false;

    _currentMileageToString = '50-100k km';

    // _licensePlateController.clear();
    // _vinController.clear();
  }

  var _carPhotos = {
    "_carID": '',
    "_licenseProvince": '',
    "_licensePlateNumber": '',
    "_currentKilometers": 25.0,
    "_carOwnershipDocumentID": '',
    "_vin": '',
    "_mainImageID": '',
    "_imageID1": '',
    "_imageID2": '',
    "_imageID3": '',
    "_imageID4": '',
    "_imageID5": '',
    "_imageID6": '',
    "_imageID7": '',
    "_imageID8": '',
    "_imageID9": '',
  };

  var _licenseError = '';
  var _vinError = '';

  bool? _isButtonDisabled;
  bool _isButtonPressed = false;

  String _currentMileageToString = '50-100k km';

  bool _licensePlateShowInput = false;

  bool _vinShowInput = false;

  void _settingModalBottomSheet(context, _imgOrder) {
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
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Color(0xFFF68E65),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Attach photo',
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
                  title: Text(
                    'Take photo',
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
                  title: Text(
                    'Attach photo',
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
        });
  }

  File? _mainImageID;
  File? _imageID1;
  File? _imageID2;
  File? _imageID3;
  File? _imageID4;
  File? _imageID5;
  File? _imageID6;
  File? _imageID7;
  File? _imageID8;
  File? _imageID9;

  File? _ownsershipImageFile;

  _checkButtonDisability() {
    if (_carPhotos['_licenseProvince'] != '' &&
        _carPhotos['_licensePlateNumber'] != '' &&
        _carPhotos['_vin'] != '' &&
        _carPhotos['_carOwnershipDocumentID'] != '' &&
        _carPhotos['_mainImageID'] != '') {
      setState(() {
        _isButtonDisabled = false;
      });
    } else {
      setState(() {
        _isButtonDisabled = true;
      });
    }
  }

  pickeImageThroughCamera(int i) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxHeight: 500,
        maxWidth: 500,
        preferredCameraDevice: CameraDevice.rear);

    switch (i) {
      case 0:
        {
          setState(() {
            _mainImageID = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_mainImageID'] = json.decode(imageRes.body!)['FileID'];
            });
          }

          _checkButtonDisability();
        }
        break;
      case 1:
        {
          setState(() {
            _imageID1 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID1'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 2:
        {
          setState(() {
            _imageID2 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID2'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 3:
        {
          setState(() {
            _imageID3 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID3'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 4:
        {
          setState(() {
            _imageID4 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID4'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 5:
        {
          setState(() {
            _imageID5 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID5'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 6:
        {
          setState(() {
            _imageID6 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID6'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 7:
        {
          setState(() {
            _imageID7 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID7'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 8:
        {
          setState(() {
            _imageID8 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID8'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 9:
        {
          setState(() {
            _imageID9 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID9'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 10:
        {
          setState(() {
            _ownsershipImageFile = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_carOwnershipDocumentID'] =
                  json.decode(imageRes.body!)['FileID'];
            });
          }

          _checkButtonDisability();
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
        maxWidth: 500);

    switch (i) {
      case 0:
        {
          setState(() {
            _mainImageID = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_mainImageID'] = json.decode(imageRes.body!)['FileID'];
            });
          }

          _checkButtonDisability();
        }
        break;
      case 1:
        {
          setState(() {
            _imageID1 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID1'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 2:
        {
          setState(() {
            _imageID2 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID2'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 3:
        {
          setState(() {
            _imageID3 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID3'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 4:
        {
          setState(() {
            _imageID4 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID4'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 5:
        {
          setState(() {
            _imageID5 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID5'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 6:
        {
          setState(() {
            _imageID6 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID6'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 7:
        {
          setState(() {
            _imageID7 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID7'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 8:
        {
          setState(() {
            _imageID8 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID8'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 9:
        {
          setState(() {
            _imageID9 = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_imageID9'] = json.decode(imageRes.body!)['FileID'];
            });
          }
        }
        break;
      case 10:
        {
          setState(() {
            _ownsershipImageFile = File(pickedFile!.path);
          });

          var imageRes = await uploadImage(File(pickedFile!.path));

          if (json.decode(imageRes.body!)['Status'] == 'success') {
            setState(() {
              _carPhotos['_carOwnershipDocumentID'] =
                  json.decode(imageRes.body!)['FileID'];
            });
          }

          _checkButtonDisability();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    if (receivedData != null &&
        receivedData['Car'] != null &&
        receivedData['Car']['ID'] != null) {
      _carPhotos['_carID'] = receivedData['Car']['ID'];
    } else {
      _carPhotos = receivedData as Map<String, Object>;
      _checkButtonDisability();
    }

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pushNamed(context, '/tell_us_about_your_car',
                arguments: receivedData);
          },
        ),
        centerTitle: true,
        title: Text(
          '2/6',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: Color(0xff371D32),
          ),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/dashboard_tab');
                },
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text(
                      'Save & Exit',
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
      body: new SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            child: Text(
                              'Upload photos and documents',
                              style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 36,
                                  color: Color(0xFF371D32),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('icons/Photos_Listing-Photos.png'),
                ],
              ),
              SizedBox(height: 20),
              // License plate
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            'License plate',
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
              // Text
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'This will only be visible to Guests that have agreed to rent your car, and is required for verification purposes.',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 14,
                            color: Color(0xFF353B50),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // Province
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(
                            style:ElevatedButton.styleFrom(
                              elevation: 0.0,
                              backgroundColor: Color(0xFFF2F2F2),
                              padding: EdgeInsets.all(16.0),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0)),

                            ),
                               onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/license_province',
                                  arguments: _carPhotos,
                                );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Container(
                                    child: Row(children: [
                                      Text(
                                        'Province',
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32),
                                        ),
                                      ),
                                    ]),
                                  ),
                                  Container(
                                    child: Row(
                                      children: <Widget>[
                                        Text(
                                          _carPhotos['_licenseProvince'] != ''
                                              ? _carPhotos['_licenseProvince'].toString()
                                              : "",
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                        Icon(Icons.keyboard_arrow_right,
                                            color: Color(0xFF353B50)),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // License plate number
              _licensePlateShowInput
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _licensePlateShowInput = false;
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
                                    Text(
                                      'License plate number',
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
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: TextFormField(
                                    // autofocus: true,
                                    controller: _licensePlateController,
                                    onChanged: (String value) {
                                      _carPhotos['_licensePlateNumber'] = value;

                                      _checkButtonDisability();
                                    },
                                    maxLength: 7,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^[A-Z0-9.,&\- ]+$'))
                                    ],
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(16.0),
                                        border: InputBorder.none,
                                        hintText: 'License plate number',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14, // Adjust the font size as needed
                                          color: Colors.grey, // You can customize the color as well
                                        ),
                                        counterText: ""),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 30),
              //  Current kilometers
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            decoration: new BoxDecoration(
                              color: Color(0xFFF2F2F2),
                              borderRadius: new BorderRadius.circular(8.0),
                            ),
                            child: Container(
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Text(
                                          'Current kilometers',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                        Text(
                                          _currentMileageToString,
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: SliderTheme(
                                            data: SliderThemeData(
                                              thumbColor: Color(0xffFFFFFF),
                                              trackShape:
                                                  RoundedRectSliderTrackShape(),
                                              trackHeight: 4.0,
                                              activeTrackColor:
                                                  Color(0xffFF8F62),
                                              inactiveTrackColor:
                                                  Color(0xFFE0E0E0),
                                              tickMarkShape:
                                                  RoundSliderTickMarkShape(
                                                      tickMarkRadius: 4.0),
                                              activeTickMarkColor:
                                                  Color(0xffFF8F62),
                                              inactiveTickMarkColor:
                                                  Color(0xFFE0E0E0),
                                              thumbShape: RoundSliderThumbShape(
                                                  enabledThumbRadius: 14.0),
                                            ),
                                            child: Slider(
                                              min: 50.0,
                                              max: 250.0,
                                              onChanged: (values) {
                                                setState(() {
                                                  int _value = values.round();

                                                  switch (_value) {
                                                    case 50:
                                                      {
                                                        setState(() {
                                                          _currentMileageToString =
                                                              '0-50k km';
                                                        });
                                                      }
                                                      break;

                                                    case 100:
                                                      {
                                                        setState(() {
                                                          _currentMileageToString =
                                                              '50-100k km';
                                                        });
                                                      }
                                                      break;

                                                    case 150:
                                                      {
                                                        setState(() {
                                                          _currentMileageToString =
                                                              '100-150k km';
                                                        });
                                                      }
                                                      break;

                                                    case 200:
                                                      {
                                                        setState(() {
                                                          _currentMileageToString =
                                                              '150-200k km';
                                                        });
                                                      }
                                                      break;

                                                    case 250:
                                                      {
                                                        setState(() {
                                                          _currentMileageToString =
                                                              '200+ km';
                                                        });
                                                      }
                                                  }

                                                  _carPhotos[
                                                          '_currentKilometers'] =
                                                      values;
                                                });
                                              },
                                              // value: _carPhotos[
                                              //     '_currentKilometers'] ,
                                              value: (_carPhotos['_currentKilometers'] as double?) ?? 50.0,
                                              divisions: 4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30.0),
              // Scan your car ownership
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            'Scan your car ownership',
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
              // Text
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text(
                            'This won’t be visible to the public and is required for verification purposes only.',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xFF353B50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Ownweship Image picker
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () => _settingModalBottomSheet(context, 10),
                            child: _carPhotos['_carOwnershipDocumentID'] == ''
                                ? SizedBox(
                                    width: double.maxFinite,
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      decoration: new BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        borderRadius:
                                            new BorderRadius.circular(12.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 99.0, bottom: 99.0),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Color(0xFFABABAB),
                                          size: 50.0,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: double.maxFinite,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      // child: Image.file(_ownsershipImageFile),
                                      child: Image.network(
                                          '$storageServerUrl/${_carPhotos['_carOwnershipDocumentID']}'),
                                    ),
                                  )),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              // VIN
              _vinShowInput
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          _vinShowInput = false;
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
                                    Text(
                                      'VIN',
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
                                      borderRadius: BorderRadius.circular(8.0)),
                                  child: TextFormField(
                                    // autofocus: true,
                                    controller: _vinController,
                                    onChanged: (String value) {
                                      _carPhotos['_vin'] = value;

                                      _checkButtonDisability();
                                    },
                                    maxLength: 17,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          (RegExp(r'^[A-Z0-9_]+$')))
                                    ],
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(16.0),
                                        border: InputBorder.none,
                                        hintText: 'VIN',
                                        hintStyle: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14, // Adjust the font size as needed
                                          color: Colors.grey, // You can customize the color as well
                                        ),
                                        counterText: ""),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 30.0),
              // Main photo
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add a main photo for your car',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            color: Color(0xFF371D32),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'The main photo is the default photo your guests will see on your listing and listing previews.',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            color: Color(0xFF353B50),
                          ),
                        ),
                        SizedBox(height: 10),
                        GestureDetector(
                            onTap: () => _settingModalBottomSheet(context, 0),
                            child: _carPhotos['_mainImageID'] == ''
                                ? SizedBox(
                                    width: double.maxFinite,
                                    child: Container(
                                      padding: EdgeInsets.all(16.0),
                                      decoration: new BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        borderRadius:
                                            new BorderRadius.circular(8.0),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            top: 99.0, bottom: 99.0),
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Color(0xFFABABAB),
                                          size: 50.0,
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox(
                                    width: double.maxFinite,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.network(
                                          '$storageServerUrl/${_carPhotos['_mainImageID']}'),
                                    ),
                                  )),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              // Additional photos
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add additional photos',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            color: Color(0xFF371D32),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'The main photo is the default photo your guests will see on your listing and listing previews.',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 16,
                            color: Color(0xFF353B50),
                          ),
                        ),
                        SizedBox(height: 10),
                        GridView.count(
                          primary: false,
                          shrinkWrap: true,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                          crossAxisCount: 3,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 1),
                              child: _carPhotos['_imageID1'] == ''
                                  ? Container(
                                      color: Colors.transparent,
                                      child: Container(
                                        child: Image.asset(
                                            'icons/Add-Photo_Placeholder.png'),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius: new BorderRadius.only(
                                            topLeft:
                                                const Radius.circular(12.0),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      alignment: Alignment.bottomCenter,
                                      width: 100,
                                      height: 100,
                                      decoration: new BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '$storageServerUrl/${_carPhotos['_imageID1']}'),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: new BorderRadius.only(
                                          topLeft: const Radius.circular(12.0),
                                        ),
                                      ),
                                    ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 2),
                              child: _carPhotos['_imageID2'] == ''
                                  ? Container(
                                      child: Image.asset(
                                          'icons/Add-Photo_Placeholder.png'),
                                      color: Color(0xFFF2F2F2),
                                    )
                                  : Container(
                                      alignment: Alignment.bottomCenter,
                                      width: 100,
                                      height: 100,
                                      decoration: new BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '$storageServerUrl/${_carPhotos['_imageID2']}'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 3),
                              child: Container(
                                color: Colors.transparent,
                                child: _carPhotos['_imageID3'] == ''
                                    ? Container(
                                        child: Image.asset(
                                            'icons/Add-Photo_Placeholder.png'),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius: new BorderRadius.only(
                                            topRight:
                                                const Radius.circular(12.0),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        alignment: Alignment.bottomCenter,
                                        width: 100,
                                        height: 100,
                                        decoration: new BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                '$storageServerUrl/${_carPhotos['_imageID3']}'),
                                            fit: BoxFit.fill,
                                          ),
                                          borderRadius: new BorderRadius.only(
                                            topRight:
                                                const Radius.circular(12.0),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 4),
                              child: _carPhotos['_imageID4'] == ''
                                  ? Container(
                                      child: Image.asset(
                                          'icons/Add-Photo_Placeholder.png'),
                                      color: Color(0xFFF2F2F2),
                                    )
                                  : Container(
                                      alignment: Alignment.bottomCenter,
                                      width: 100,
                                      height: 100,
                                      decoration: new BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '$storageServerUrl/${_carPhotos['_imageID4']}'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 5),
                              child: _carPhotos['_imageID5'] == ''
                                  ? Container(
                                      child: Image.asset(
                                          'icons/Add-Photo_Placeholder.png'),
                                      color: Color(0xFFF2F2F2),
                                    )
                                  : Container(
                                      alignment: Alignment.bottomCenter,
                                      width: 100,
                                      height: 100,
                                      decoration: new BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '$storageServerUrl/${_carPhotos['_imageID5']}'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 6),
                              child: _carPhotos['_imageID6'] == ''
                                  ? Container(
                                      child: Image.asset(
                                          'icons/Add-Photo_Placeholder.png'),
                                      color: Color(0xFFF2F2F2),
                                    )
                                  : Container(
                                      alignment: Alignment.bottomCenter,
                                      width: 100,
                                      height: 100,
                                      decoration: new BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '$storageServerUrl/${_carPhotos['_imageID6']}'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 7),
                              child: Container(
                                color: Colors.transparent,
                                child: _carPhotos['_imageID7'] == ''
                                    ? Container(
                                        child: Image.asset(
                                            'icons/Add-Photo_Placeholder.png'),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius: new BorderRadius.only(
                                            bottomLeft:
                                                const Radius.circular(12.0),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        alignment: Alignment.bottomCenter,
                                        width: 100,
                                        height: 100,
                                        decoration: new BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                '$storageServerUrl/${_carPhotos['_imageID7']}'),
                                            fit: BoxFit.fill,
                                          ),
                                          borderRadius: new BorderRadius.only(
                                            bottomLeft:
                                                const Radius.circular(12.0),
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 8),
                              child: _carPhotos['_imageID8'] == ''
                                  ? Container(
                                      child: Image.asset(
                                          'icons/Add-Photo_Placeholder.png'),
                                      color: Color(0xFFF2F2F2),
                                    )
                                  : Container(
                                      alignment: Alignment.bottomCenter,
                                      width: 100,
                                      height: 100,
                                      decoration: new BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '$storageServerUrl/${_carPhotos['_imageID8']}'),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                            ),
                            GestureDetector(
                              onTap: () => _settingModalBottomSheet(context, 9),
                              child: _carPhotos['_imageID9'] == ''
                                  ? Container(
                                      color: Colors.transparent,
                                      child: Container(
                                        child: Image.asset(
                                            'icons/Add-Photo_Placeholder.png'),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius: new BorderRadius.only(
                                            bottomRight:
                                                const Radius.circular(12.0),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      alignment: Alignment.bottomCenter,
                                      width: 100,
                                      height: 100,
                                      decoration: new BoxDecoration(
                                        color: Color(0xFFF2F2F2),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              '$storageServerUrl/${_carPhotos['_imageID9']}'),
                                          fit: BoxFit.fill,
                                        ),
                                        borderRadius: new BorderRadius.only(
                                          bottomRight:
                                              const Radius.circular(12.0),
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
              // Drag
              // Row(
              //   children: <Widget>[
              //     Expanded(
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         children: <Widget>[
              //           Text('Drag photos to rearrange.',
              //             style: TextStyle(
              //               fontFamily: 'Urbanist',
              //               fontSize: 14,
              //               color: Color(0xFF353B50),
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
              SizedBox(height: 30),
              // Next button
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: ElevatedButton(style: ElevatedButton.styleFrom(
                            elevation: 0.0,
                            backgroundColor: Color(0xffFF8F68),
                            padding: EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0)),),
                            onPressed: _isButtonDisabled!
                                ? null
                                : () async {
                                    // onPressed: () async {
                                    // setState(() {
                                    //   _isButtonDisabled = true;
                                    //   _isButtonPressed = true;
                                    // });

                                    var res =
                                        await setImagesAndDocuments(_carPhotos);

                                    var arguments = json.decode(res.body!);

                                    // if (res != null) {
                                    //   Navigator.pushNamed(
                                    //     context,
                                    //     '/what_features_do_you_have',
                                    //     arguments: arguments,
                                    //   );
                                    // } else {
                                    //   setState(() {
                                    //     _isButtonDisabled = false;
                                    //     _isButtonPressed = false;
                                    //   });
                                    // }

                                    Navigator.pushNamed(
                                      context,
                                      '/what_features_do_you_have',
                                      arguments: arguments,
                                    );
                                  },
                            child: _isButtonPressed
                                ? SizedBox(
                                    height: 18.0,
                                    width: 18.0,
                                    child: new CircularProgressIndicator(
                                        strokeWidth: 2.5),
                                  )
                                : Text(
                                    'Next',
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 18,
                                        color: Colors.white),
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
    );
  }

  Future<RestApi.Resp> setImagesAndDocuments(_carPhotos) async {
    final completer = Completer<RestApi.Resp>();
    RestApi.callAPI(
      setImagesAndDocumentsUrl,
      json.encode({
        "CarID": _carPhotos['_carID'],
        "ImagesAndDocuments": {
          "License": {
            "Province": _carPhotos['_licenseProvince'],
            "PlateNumber": _carPhotos['_licensePlateNumber']
          },
          "CurrentKilometers":
              double.parse(_carPhotos['_currentKilometers'].toString())
                  .round()
                  .toString(),
          "CarOwnershipDocumentID": _carPhotos['_carOwnershipDocumentID'],
          "InsuranceDocumentID": _carPhotos['InsuranceDocumentID'],
          "Vin": _carPhotos['_vin'],
          "Images": {
            "MainImageID": _carPhotos['_mainImageID'],
            "AdditionalImages": {
              "ImageID1": _carPhotos['_imageID1'],
              "ImageID2": _carPhotos['_imageID2'],
              "ImageID3": _carPhotos['_imageID3'],
              "ImageID4": _carPhotos['_imageID4'],
              "ImageID5": _carPhotos['_imageID5'],
              "ImageID6": _carPhotos['_imageID6'],
              "ImageID7": _carPhotos['_imageID7'],
              "ImageID8": _carPhotos['_imageID8'],
              "ImageID9": _carPhotos['_imageID9']
            }
          },
          "Completed": true
        }
      }),
    ).then((resp) {
      completer.complete(resp);
    });
    return completer.future;
  }

  uploadImage(filename) async {
    var stream =
        new http.ByteStream(DelegatingStream.typed(filename.openRead()));
    var length = await filename.length();

    var uri = Uri.parse(uploadUrl);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('files', stream, length,
        filename: basename(filename.path));

    String? jwt = await storage.read(key: 'jwt');
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    request.headers.addAll(headers);

    request.files.add(multipartFile);
    var response = await request.send();

    var response2 = await http.Response.fromStream(response);

    return response2;
  }
}
