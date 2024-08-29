import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:info_popup/info_popup.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/list_a_car/bloc/add_photos_to_car_bloc.dart';
import 'package:ridealike/pages/list_a_car/response_model/create_car_response_model.dart';
import 'package:ridealike/widgets/sized_text.dart';

import '../../../utils/app_events/app_events_utils.dart';

class AddPhotosToListingUi extends StatefulWidget {
  @override
  State createState() => AddPhotosToListingUiState();
}

class AddPhotosToListingUiState extends State<AddPhotosToListingUi> {
  var photosDocumentsBloc = AddPhotosToCar();
  bool _licensePlateShowInput = false;
  bool exitPressed = false;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Add Photos To Your Listing"});
  }

  void _settingModalBottomSheet(context, _imgOrder,
      AsyncSnapshot<CreateCarResponse> photosDocumentsSnapshot) {
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
                    photosDocumentsBloc.pickImageThroughCamera(
                        _imgOrder, photosDocumentsSnapshot, context);
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
                    photosDocumentsBloc.pickImageFromGallery(
                        _imgOrder, photosDocumentsSnapshot, context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    dynamic routeData = ModalRoute.of(context)!.settings.arguments;
    CreateCarResponse data = CreateCarResponse.fromJson(
        (routeData['carResponse'] as CreateCarResponse).toJson());

    var purpose = routeData['purpose'];
    bool pushNeeded = routeData['PUSH'] == null ? false : routeData['PUSH'];
    String? pushRouteName = routeData['ROUTE_NAME'];
    CreateCarResponse receivedData = CreateCarResponse.fromJson(data.toJson());
    if (receivedData.car!.imagesAndDocuments!.currentKilometers == '' ||
        double.parse(receivedData.car!.imagesAndDocuments!.currentKilometers!) ==
            0) {
      receivedData.car!.imagesAndDocuments!.currentKilometers = '0';
    }
    photosDocumentsBloc.changedPhotosDocumentsData.call(receivedData);
    photosDocumentsBloc.changedProgressIndicator.call(0);
    photosDocumentsBloc.changedLicense.call(true);
    photosDocumentsBloc.changedVin.call(true);

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        centerTitle: true,
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            if (pushNeeded) {
              Navigator.pushNamed(context, pushRouteName!, arguments: {
                'carResponse': routeData['carResponse'],
                'purpose': purpose
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          '2/6',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 16,
            color: Color(0xff371D32),
          ),
        ),
        actions: <Widget>[
          StreamBuilder<CreateCarResponse>(
              stream: photosDocumentsBloc.photosDocumentsData,
              builder: (context, photosDocumentsDataSnapshot) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async {
                        if (!exitPressed) {
                          exitPressed = true;
                          CreateCarResponse response =
                              await photosDocumentsBloc.photosAndDocuments(
                                  photosDocumentsDataSnapshot.data!,
                                  completed: false,
                                  saveAndExit: true);
                          Navigator.pushNamed(context, '/dashboard_tab',
                              arguments: response);
                        }
                      },
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.only(right: 16),
                          child: receivedData.car!.imagesAndDocuments!.completed!
                              ? Text('')
                              : Text(
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
                );
              }),
        ],
        elevation: 0.0,
      ),

      //Content of tabs
      body: StreamBuilder<CreateCarResponse>(
          stream: photosDocumentsBloc.photosDocumentsData,
          builder: (context, photosDocumentsSnapshot) {
            return photosDocumentsSnapshot.hasData &&
                    photosDocumentsSnapshot.data != null
                ? StreamBuilder<int>(
                    stream: photosDocumentsBloc.progressIndicator,
                    builder: (context, progressIndicatorSnapshot) {
                      return Container(
                        child: new SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: <Widget>[
                                // Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Image.asset(
                                        'icons/Photos_Listing-Photos.png'),
                                  ],
                                ),
                                SizedBox(height: 20),
                                // License plate
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: double.maxFinite,
                                            child: Text(
                                              'License plate',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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

                                ///Province
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: double.maxFinite,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0.0,
                                                backgroundColor: Color(0xFFF2F2F2),
                                                padding: EdgeInsets.all(16.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0)),

                                              ),
                                                 onPressed: purpose == 3
                                                    ? () => {}
                                                    : () {
                                                        Navigator.pushNamed(
                                                          context,
                                                          '/license_province_ui',
                                                          arguments:
                                                              photosDocumentsSnapshot
                                                                  .data,
                                                        ).then((value) {
                                                          if (value != null) {
                                                            photosDocumentsBloc
                                                                .changedPhotosDocumentsData
                                                                .call(value as CreateCarResponse);
                                                          }
                                                        });
                                                      },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      child: Row(children: [
                                                        Text(
                                                          'Province',
                                                          style: TextStyle(
                                                            fontWeight: FontWeight.w600,
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 16,
                                                            color: Color(
                                                                0xFF371D32),
                                                          ),
                                                        ),
                                                      ]),
                                                    ),
                                                    Container(
                                                      child: Row(
                                                        children: <Widget>[
                                                          SizedText(
                                                            deviceWidth:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            textWidthPercentage:
                                                                0.55,
                                                            text: photosDocumentsSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .imagesAndDocuments!
                                                                        .license!
                                                                        .province !=
                                                                    ''
                                                                ? photosDocumentsSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .imagesAndDocuments!
                                                                    .license!
                                                                    .province!
                                                                : "",
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 14,
                                                            textColor: Color(
                                                                0xFF353B50),
                                                          ),
                                                          Icon(
                                                              Icons
                                                                  .keyboard_arrow_right,
                                                              color: Color(
                                                                  0xFF353B50)),
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

                                /// License plate number

                                StreamBuilder<bool>(
                                    stream: photosDocumentsBloc.license,
                                    builder: (context, licenseSnapshot) {
                                      return Column(
                                        children: [
                                          licenseSnapshot.hasData &&
                                                  licenseSnapshot.data == true
                                              ? GestureDetector(
                                                  onTap: photosDocumentsSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .verification!
                                                                  .verificationStatus ==
                                                              'Submitted' ||
                                                          photosDocumentsSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .verification!
                                                                  .verificationStatus ==
                                                              'Verified' ||
                                                          photosDocumentsSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .verification!
                                                                  .verificationStatus ==
                                                              'Blocked' ||
                                                          photosDocumentsSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .verification!
                                                                  .verificationStatus ==
                                                              'Updated'
                                                      ? () => {}
                                                      : () {
                                                          photosDocumentsBloc
                                                              .changedLicense
                                                              .call(false);
                                                        },
                                                  child: SizedBox(
                                                    width: double.maxFinite,
                                                    child: Container(
                                                      height: 60,
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xffF2F2F2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'License plate number',
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                          Text(
                                                            photosDocumentsSnapshot
                                                                .data!
                                                                .car!
                                                                .imagesAndDocuments!
                                                                .license!
                                                                .plateNumber!,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xff353B50),
                                                                letterSpacing:
                                                                    -0.2,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontFamily:
                                                                    'Urbanist'),
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
                                                            width: double
                                                                .maxFinite,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xFFF2F2F2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0)),
                                                              child: Focus(
                                                                child:
                                                                    TextFormField(
                                                                  autofocus:
                                                                      licenseSnapshot.data ==
                                                                              false
                                                                          ? true
                                                                          : false,
                                                                  initialValue: photosDocumentsSnapshot
                                                                      .data!
                                                                      .car!
                                                                      .imagesAndDocuments!
                                                                      .license!
                                                                      .plateNumber,
                                                                  onChanged:
                                                                      (String
                                                                          value) {
                                                                    if (value
                                                                            .length >=
                                                                        8) {
                                                                      photosDocumentsBloc
                                                                          .changedLicense
                                                                          .call(
                                                                              true);
                                                                      if (value
                                                                              .length >
                                                                          8) {
                                                                        return;
                                                                      }
                                                                    }
                                                                    photosDocumentsSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .imagesAndDocuments!
                                                                        .license!
                                                                        .plateNumber = value;
                                                                    photosDocumentsBloc
                                                                        .changedPhotosDocumentsData
                                                                        .call(photosDocumentsSnapshot
                                                                            .data!);
                                                                  },
                                                                  maxLength: 8,
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter.allow(
                                                                        (RegExp(
                                                                            r'[A-Z0-9 ]')),
                                                                        replacementString:
                                                                            '')
                                                                  ],
                                                                  textCapitalization:
                                                                      TextCapitalization
                                                                          .characters,
                                                                  decoration: InputDecoration(
                                                                      contentPadding:
                                                                          EdgeInsets.all(
                                                                              16.0),
                                                                      border: InputBorder
                                                                          .none,
                                                                      hintText:
                                                                          'License plate number',hintStyle: TextStyle(
                                                                    fontFamily: 'Urbanist'
                                                                  ),
                                                                      counterText:
                                                                          ""),
                                                                ),
                                                                onFocusChange:
                                                                    (hasFocus) {
                                                                  if (!hasFocus) {
                                                                    photosDocumentsBloc
                                                                        .changedLicense
                                                                        .call(
                                                                            true);
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          licenseSnapshot.hasError
                                              ? Align(
                                                  child: Text(
                                                    '${licenseSnapshot.error}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Urbanist',
                                                      fontSize: 14,
                                                      color: Color(0xFFF55A51),
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                )
                                              : Container(),
                                          licenseSnapshot.hasError
                                              ? SizedBox(
                                                  height: 10,
                                                )
                                              : Container(),
                                        ],
                                      );
                                    }),

                                SizedBox(height: 30),

                                ///  Current kilometers
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
                                                borderRadius:
                                                    new BorderRadius.circular(
                                                        8.0),
                                              ),
                                              child: Container(
                                                child: Column(
                                                  children: <Widget>[
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(16.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          Text(
                                                            'Current kilometers',
                                                            style: TextStyle(
                                                              fontWeight: FontWeight.w600,
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                          Text(
                                                            photosDocumentsBloc
                                                                .getCurrentMileage(
                                                                    photosDocumentsSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .imagesAndDocuments!
                                                                        .currentKilometers!),
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF353B50),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          bottom: 8.0),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: SliderTheme(
                                                              data:
                                                                  SliderThemeData(
                                                                thumbColor: Color(
                                                                    0xffFFFFFF),
                                                                trackShape:
                                                                    RoundedRectSliderTrackShape(),
                                                                trackHeight:
                                                                    4.0,
                                                                activeTrackColor:
                                                                    Color(
                                                                        0xffFF8F62),
                                                                inactiveTrackColor:
                                                                    Color(
                                                                        0xFFE0E0E0),
                                                                tickMarkShape:
                                                                    RoundSliderTickMarkShape(
                                                                        tickMarkRadius:
                                                                            4.0),
                                                                activeTickMarkColor:
                                                                    Color(
                                                                        0xffFF8F62),
                                                                inactiveTickMarkColor:
                                                                    Color(
                                                                        0xFFE0E0E0),
                                                                thumbShape:
                                                                    RoundSliderThumbShape(
                                                                        enabledThumbRadius:
                                                                            14.0),
                                                              ),
                                                              child: Slider(
                                                                min: 0.0,
                                                                max: 200.0,
                                                                onChanged:
                                                                    (values) {
                                                                  int _value =
                                                                      values
                                                                          .round();
                                                                  photosDocumentsSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .imagesAndDocuments!
                                                                          .currentKilometers =
                                                                      _value
                                                                          .toString();
                                                                  photosDocumentsBloc
                                                                      .changedPhotosDocumentsData
                                                                      .call(photosDocumentsSnapshot
                                                                          .data!);
                                                                },
                                                                value: double.parse(
                                                                    photosDocumentsSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .imagesAndDocuments!
                                                                        .currentKilometers!),
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

                                /// Scan your car ownership///
                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Upload your vehicle ownership ',  style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          color: Color(0xFF353B50),
                                        ),),

                                        InfoPopupWidget(
                                          arrowTheme: InfoPopupArrowTheme(
                                            color: Color(0xffFF8F68),
                                            arrowDirection: ArrowDirection.up,
                                          ),
                                          contentTheme: InfoPopupContentTheme(
                                            infoContainerBackgroundColor: Color(0xFF575757),
                                            infoTextStyle: TextStyle(color: Colors.white,fontFamily: 'Urbanist',fontSize: 16),
                                            contentPadding: const EdgeInsets.all(8),
                                            contentBorderRadius: BorderRadius.all(Radius.circular(10)),
                                            infoTextAlign: TextAlign.start,
                                          ),
                                          contentTitle:
                                          'This will only be visible to Guests, and only when they are renting your vehicle. It is also required by our Insurance company for vehicle verification purposes.',
                                          child:
                                          SvgPicture.asset(
                                            'svg/icon-i.svg',
                                            width: 32,
                                            height: 32,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('(Both plate vehicle portions)', style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Color(0xFF353B50),
                                    ),
                                    ),
                                    // Text
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: double.maxFinite,
                                                child: Text(
                                                  // 'This won’t be visible to the public and is required for verification purposes only.',
                                                  '',
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


                                    /// Ownership Image picker
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                  onTap:
                                                      // purpose == 3
                                                      //     ? () => {}
                                                      photosDocumentsSnapshot
                                                                      .data!
                                                                      .car!
                                                                      .verification!
                                                                      .verificationStatus ==
                                                                  'Submitted' ||
                                                              photosDocumentsSnapshot
                                                                      .data!
                                                                      .car!
                                                                      .verification!
                                                                      .verificationStatus ==
                                                                  'Verified' ||
                                                              photosDocumentsSnapshot
                                                                      .data!
                                                                      .car!
                                                                      .verification!
                                                                      .verificationStatus ==
                                                                  'Blocked' ||
                                                              photosDocumentsSnapshot
                                                                      .data!
                                                                      .car!
                                                                      .verification!
                                                                      .verificationStatus ==
                                                                  'Updated'
                                                          ? () => {}
                                                          : () => _settingModalBottomSheet(
                                                              context,
                                                              10,
                                                              photosDocumentsSnapshot),
                                                  child: photosDocumentsSnapshot
                                                              .data!
                                                              .car!
                                                              .imagesAndDocuments!
                                                              .carOwnershipDocumentID ==
                                                          ''
                                                      ? SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16.0),
                                                            decoration:
                                                                new BoxDecoration(
                                                              color: Color(
                                                                  0xFFF2F2F2),
                                                              borderRadius:
                                                                  new BorderRadius
                                                                          .circular(
                                                                      12.0),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 99.0,
                                                                      bottom:
                                                                          99.0),
                                                              child: Icon(
                                                                Icons
                                                                    .camera_alt,
                                                                color: Color(
                                                                    0xFFABABAB),
                                                                size: 50.0,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            // child: Image.file(_ownsershipImageFile),
                                                            child:
                                                                Image.network(
                                                              '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.carOwnershipDocumentID}',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30.0),

                                ///scan insurance document Id///
                                Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Upload your current Proof of Insurance ',  style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Urbanist',
                                          fontSize: 18,
                                          color: Color(0xFF353B50),
                                        ),),

                                        InfoPopupWidget(
                                          arrowTheme: InfoPopupArrowTheme(
                                            color: Color(0xffFF8F68),
                                            arrowDirection: ArrowDirection.up,
                                          ),
                                          contentTheme: InfoPopupContentTheme(
                                            infoContainerBackgroundColor: Color(0xFF575757),
                                            infoTextStyle: TextStyle(color: Colors.white,fontFamily: 'Urbanist',fontSize: 16),
                                            contentPadding: const EdgeInsets.all(8),
                                            contentBorderRadius: BorderRadius.all(Radius.circular(10)),
                                            infoTextAlign: TextAlign.start,
                                          ),
                                          contentTitle:
                                          'This is not visible to Guests or Public, but is required by our Insurance company as proof of eligibility for RideAlike\'s commercial insurance. Your personal Insurance coverage is not utilized by RideAlike.',
                                          child:
                                          SvgPicture.asset(
                                            'svg/icon-i.svg',
                                            width: 32,
                                            height: 32,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text('(Pink slip)', style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Color(0xFF353B50),
                                    ),
                                    ),
                                    // RichText(
                                    //   text: TextSpan(
                                    //     style: TextStyle(
                                    //       fontWeight: FontWeight.w600,
                                    //       fontFamily: 'Urbanist',
                                    //       fontSize: 18,
                                    //       color: Color(0xFF371D32),
                                    //     ),
                                    //     children: [
                                    //       TextSpan(
                                    //         text:
                                    //             'Upload your current Proof of Insurance ',
                                    //       ),
                                    //       TextSpan(
                                    //         style: TextStyle(
                                    //           fontWeight: FontWeight.w500,
                                    //           fontFamily: 'Urbanist',
                                    //           fontSize: 16,
                                    //           color: Color(0xFF353B50),
                                    //         ),
                                    //         text: '(Pink slip)',
                                    //       ),
                                    //       // TextSpan(
                                    //       //     text: ' FAQ',
                                    //       //     style: TextStyle(
                                    //       //       color: Colors.blue,
                                    //       //     ),
                                    //       //     recognizer: TapGestureRecognizer()..onTap = (){UrlLauncher.launchUrl(faqUrl);}
                                    //       // ),
                                    //     ],
                                    //   ),
                                    // ),
                                    SizedBox(height: 10),
                                    // Text


                                    /// insurance Id Image picker
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              GestureDetector(
                                                  onTap: () =>
                                                      _settingModalBottomSheet(
                                                          context,
                                                          11,
                                                          photosDocumentsSnapshot),
                                                  child: photosDocumentsSnapshot
                                                              .data!
                                                              .car!
                                                              .imagesAndDocuments!
                                                              .insuranceDocumentID ==
                                                          ''
                                                      ? SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          child: Container(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    16.0),
                                                            decoration:
                                                                new BoxDecoration(
                                                              color: Color(
                                                                  0xFFF2F2F2),
                                                              borderRadius:
                                                                  new BorderRadius
                                                                          .circular(
                                                                      12.0),
                                                            ),
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 99.0,
                                                                      bottom:
                                                                          99.0),
                                                              child: Icon(
                                                                Icons
                                                                    .camera_alt,
                                                                color: Color(
                                                                    0xFFABABAB),
                                                                size: 50.0,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : SizedBox(
                                                          width:
                                                              double.maxFinite,
                                                          child: ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                            child:
                                                                Image.network(
                                                              '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.insuranceDocumentID}',
                                                              fit: BoxFit.cover,
                                                            ),
                                                          ),
                                                        )),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.0),
                                  ],
                                ),

                                /// Scan Insurance certificate///
                                // Column(
                                //   children: [
                                //     Row(
                                //       children: <Widget>[
                                //         Expanded(
                                //           child: Column(
                                //             crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //             children: [
                                //               SizedBox(
                                //                 width: double.maxFinite,
                                //                 child:
                                //                 SizedText( deviceWidth: SizeConfig.deviceWidth!,
                                //                   textWidthPercentage: 0.4,
                                //                   text:'Upload your insurance certificate',
                                //                   fontFamily: 'Urbanist',
                                //                   fontSize: 18,
                                //                   textColor: Color(0xFF371D32),
                                //
                                //                 ),
                                //               ),
                                //             ],
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //     // SizedBox(height: 10),
                                //     // // Text
                                //     // Row(
                                //     //   children: <Widget>[
                                //     //     Expanded(
                                //     //       child: Column(
                                //     //         crossAxisAlignment:
                                //     //         CrossAxisAlignment.start,
                                //     //         children: [
                                //     //           SizedBox(
                                //     //             width: double.maxFinite,
                                //     //             child: AutoSizeText(
                                //     //               'This is not visible to Guests or Public, but is required by our Insurance company as proof of eligibility for RideAlike\'s commercial insurance. Your personal Insurance coverage is not utilized by RideAlike.',
                                //     //               style: TextStyle(
                                //     //                 fontFamily: 'Urbanist',
                                //     //                 fontSize: 16,
                                //     //                 color: Color(0xFF353B50),
                                //     //               ),maxLines: 5,
                                //     //             ),
                                //     //           ),
                                //     //         ],
                                //     //       ),
                                //     //     ),
                                //     //   ],
                                //     // ),
                                //     SizedBox(height: 30),
                                //     /// insurance certificate Image picker
                                //     Row(
                                //       children: <Widget>[
                                //         Expanded(
                                //           child: Column(
                                //             crossAxisAlignment:
                                //             CrossAxisAlignment.start,
                                //             children: [
                                //               GestureDetector(
                                //                   onTap: () =>
                                //                       _settingModalBottomSheet(
                                //                           context, 12,
                                //                           photosDocumentsSnapshot),
                                //                   child: photosDocumentsSnapshot.data!.car!.imagesAndDocuments.insuranceCertID== ''
                                //                       ? SizedBox(
                                //                     width: double.maxFinite,
                                //                     child: Container(
                                //                       padding: EdgeInsets.all(16.0),
                                //                       decoration:
                                //                       new BoxDecoration(
                                //                         color:
                                //                         Color(0xFFF2F2F2),
                                //                         borderRadius:
                                //                         new BorderRadius.circular(12.0),
                                //                       ),
                                //                       child: Padding(
                                //                         padding:
                                //                         EdgeInsets.only(top: 99.0, bottom: 99.0),
                                //                         child: Icon(
                                //                           Icons.camera_alt,
                                //                           color: Color(0xFFABABAB), size: 50.0,
                                //                         ),
                                //                       ),
                                //                     ),
                                //                   )
                                //                       : SizedBox(
                                //                     width: double.maxFinite,
                                //                     child: ClipRRect(
                                //                       borderRadius:
                                //                       BorderRadius
                                //                           .circular(12.0),
                                //                       // child: Image.file(_ownsershipImageFile),
                                //                       child: Image.network(
                                //                         '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments.insuranceCertID}',
                                //                         fit: BoxFit.cover,
                                //                       ),
                                //                     ),
                                //                   )),
                                //             ],
                                //           ),
                                //         ),
                                //       ],
                                //     ),
                                //     SizedBox(height: 10.0),
                                //   ],
                                // ),
                                SizedBox(height: 30.0),
                                /// VIN
                                StreamBuilder<bool>(
                                    stream: photosDocumentsBloc.vin,
                                    builder: (context, vinSnapshot) {
                                      return Column(
                                        children: [
                                          vinSnapshot.hasData &&
                                                  vinSnapshot.data == true
                                              ? GestureDetector(
                                                  onTap: photosDocumentsSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .verification!
                                                                  .verificationStatus ==
                                                              'Submitted' ||
                                                          photosDocumentsSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .verification!
                                                                  .verificationStatus ==
                                                              'Verified' ||
                                                          photosDocumentsSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .verification!
                                                                  .verificationStatus ==
                                                              'Blocked' ||
                                                          photosDocumentsSnapshot
                                                                  .data!
                                                                  .car!
                                                                  .verification!
                                                                  .verificationStatus ==
                                                              'Updated'
                                                      ? () => {}
                                                      : () {
                                                          photosDocumentsBloc
                                                              .changedVin
                                                              .call(false);
                                                        },
                                                  child: SizedBox(
                                                    width: double.maxFinite,
                                                    child: Container(
                                                      height: 60,
                                                      padding:
                                                          EdgeInsets.all(16),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xffF2F2F2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8)),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'VIN',
                                                            style: TextStyle(

                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Color(
                                                                  0xFF371D32),
                                                            ),
                                                          ),
                                                          Text(
                                                            photosDocumentsSnapshot
                                                                .data!
                                                                .car!
                                                                .imagesAndDocuments!
                                                                .vin!,
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xff353B50),
                                                                letterSpacing:
                                                                    -0.2,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal,
                                                                fontFamily:
                                                                    'Open Sans Regular'),
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
                                                            width: double
                                                                .maxFinite,
                                                            child: Container(
                                                              decoration: BoxDecoration(
                                                                  color: Color(
                                                                      0xFFF2F2F2),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8.0)),
                                                              child:
                                                                  TextFormField(
                                                                autofocus:
                                                                    vinSnapshot.data ==
                                                                            false
                                                                        ? true
                                                                        : false,
                                                                initialValue:
                                                                    photosDocumentsSnapshot
                                                                        .data!
                                                                        .car!
                                                                        .imagesAndDocuments!
                                                                        .vin!,
                                                                onChanged:
                                                                    (String
                                                                        value) {
                                                                  if (value
                                                                          .length ==
                                                                      17) {
                                                                    photosDocumentsBloc
                                                                        .changedVin
                                                                        .call(
                                                                            true);
                                                                  }
                                                                  photosDocumentsSnapshot
                                                                      .data!
                                                                      .car!
                                                                      .imagesAndDocuments!
                                                                      .vin = value;
                                                                  photosDocumentsBloc
                                                                      .changedPhotosDocumentsData
                                                                      .call(photosDocumentsSnapshot
                                                                          .data!);
                                                                },
                                                                maxLength: 17,
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter.allow(
                                                                      RegExp(
                                                                          r'[A-Z0-9_]'),
                                                                      replacementString:
                                                                          '')
                                                                ],
                                                                textCapitalization:
                                                                    TextCapitalization
                                                                        .characters,
                                                                decoration: InputDecoration(
                                                                    contentPadding:
                                                                        EdgeInsets.all(
                                                                            16.0),
                                                                    border:
                                                                        InputBorder
                                                                            .none,
                                                                    hintText:
                                                                        'VIN',
                                                                    counterText:
                                                                        ""),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          vinSnapshot.hasError
                                              ? Align(
                                                  child: Text(
                                                    '${vinSnapshot.error}',
                                                    style: TextStyle(
                                                      fontFamily:
                                                          'Urbanist',
                                                      fontSize: 14,
                                                      color: Color(0xFFF55A51),
                                                    ),
                                                  ),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                )
                                              : Container(),
                                          vinSnapshot.hasError
                                              ? SizedBox(
                                                  height: 10,
                                                )
                                              : Container(),
                                        ],
                                      );
                                    }),

                                SizedBox(height: 30.0),

                                /// Main photo
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Add a main photo for your car',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Urbanist',
                                              fontSize: 18,
                                              color: Color(0xFF371D32),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'The main photo is the default photo your Guests will see on your listing and listing previews.',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF353B50),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          GestureDetector(
                                              onTap: () =>
                                                  _settingModalBottomSheet(
                                                      context,
                                                      0,
                                                      photosDocumentsSnapshot),
                                              child: photosDocumentsSnapshot
                                                          .data!
                                                          .car!
                                                          .imagesAndDocuments!
                                                          .images!
                                                          .mainImageID ==
                                                      ''
                                                  ? SizedBox(
                                                      width: double.maxFinite,
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        decoration:
                                                            new BoxDecoration(
                                                          color:
                                                              Color(0xFFF2F2F2),
                                                          borderRadius:
                                                              new BorderRadius
                                                                      .circular(
                                                                  8.0),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 99.0,
                                                                  bottom: 99.0),
                                                          child: Icon(
                                                            Icons.camera_alt,
                                                            color: Color(
                                                                0xFFABABAB),
                                                            size: 50.0,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      width: double.maxFinite,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                        child: Image.network(
                                                            '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.mainImageID}',
                                                            fit: BoxFit.cover),
                                                      ),
                                                    )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 30),

                                /// Additional photos
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Add additional photos',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Urbanist',
                                              fontSize: 18,
                                              color: Color(0xFF371D32),
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                          Text(
                                            'The main photo is the default photo your Guests will see on your listing and listing previews.',
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
                                                  onTap: () =>
                                                      _settingModalBottomSheet(
                                                          context,
                                                          1,
                                                          photosDocumentsSnapshot),
                                                  child: photosDocumentsSnapshot
                                                              .data!
                                                              .car!
                                                              .imagesAndDocuments!
                                                              .images!
                                                              .additionalImages!
                                                              .imageID1 ==
                                                          ''
                                                      ? Container(
                                                          color: Colors
                                                              .transparent,
                                                          child: Container(
                                                            child: Image.asset(
                                                                'icons/Add-Photo_Placeholder.png'),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFF2F2F2),
                                                              borderRadius:
                                                                  new BorderRadius
                                                                      .only(
                                                                topLeft:
                                                                    const Radius
                                                                            .circular(
                                                                        12.0),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Stack(
                                                          children: <Widget>[
                                                              SizedBox(
                                                                  child: Image(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    image: NetworkImage(
                                                                        '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.additionalImages!.imageID1}'),
                                                                  ),
                                                                  width: double
                                                                      .maxFinite),
                                                              Positioned(
                                                                right: 5,
                                                                bottom: 5,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      photosDocumentsSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .imagesAndDocuments!
                                                                          .images!
                                                                          .additionalImages!
                                                                          .imageID1 = '';
                                                                      photosDocumentsBloc
                                                                          .changedPhotosDocumentsData
                                                                          .call(
                                                                              photosDocumentsSnapshot.data!);
                                                                    },
                                                                    child: CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        radius: 10,
                                                                        child: Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Color(0xffF55A51),
                                                                          size:
                                                                              20,
                                                                        ))),
                                                              )
                                                            ])),
                                              GestureDetector(
                                                onTap: () =>
                                                    _settingModalBottomSheet(
                                                        context,
                                                        2,
                                                        photosDocumentsSnapshot),
                                                child: photosDocumentsSnapshot
                                                            .data!
                                                            .car!
                                                            .imagesAndDocuments!
                                                            .images!
                                                            .additionalImages!
                                                            .imageID2 ==
                                                        ''
                                                    ? Container(
                                                        child: Image.asset(
                                                            'icons/Add-Photo_Placeholder.png'),
                                                        color:
                                                            Color(0xFFF2F2F2),
                                                      )
                                                    : Stack(children: <Widget>[
                                                        SizedBox(
                                                            child: Image(
                                                              fit: BoxFit.fill,
                                                              image: NetworkImage(
                                                                  '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.additionalImages!.imageID2}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: InkWell(
                                                              onTap: () {
                                                                photosDocumentsSnapshot
                                                                    .data!
                                                                    .car!
                                                                    .imagesAndDocuments!
                                                                    .images!
                                                                    .additionalImages!
                                                                    .imageID2 = '';
                                                                photosDocumentsBloc
                                                                    .changedPhotosDocumentsData
                                                                    .call(photosDocumentsSnapshot
                                                                        .data!);
                                                              },
                                                              child:
                                                                  CircleAvatar(
                                                                      backgroundColor:
                                                                          Colors
                                                                              .white,
                                                                      radius:
                                                                          10,
                                                                      child:
                                                                          Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Color(
                                                                            0xffF55A51),
                                                                        size:
                                                                            20,
                                                                      ))),
                                                        )
                                                      ]),
                                              ),
                                              GestureDetector(
                                                onTap: () =>
                                                    _settingModalBottomSheet(
                                                        context,
                                                        3,
                                                        photosDocumentsSnapshot),
                                                child: Container(
                                                    color: Colors.transparent,
                                                    child: photosDocumentsSnapshot
                                                                .data!
                                                                .car!
                                                                .imagesAndDocuments!
                                                                .images!
                                                                .additionalImages!
                                                                .imageID3 ==
                                                            ''
                                                        ? Container(
                                                            child: Image.asset(
                                                                'icons/Add-Photo_Placeholder.png'),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFF2F2F2),
                                                              borderRadius:
                                                                  new BorderRadius
                                                                      .only(
                                                                topRight:
                                                                    const Radius
                                                                            .circular(
                                                                        12.0),
                                                              ),
                                                            ),
                                                          )
                                                        : Stack(
                                                            children: <Widget>[
                                                                SizedBox(
                                                                    child:
                                                                        Image(
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      image: NetworkImage(
                                                                          '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.additionalImages!.imageID3}'),
                                                                    ),
                                                                    width: double
                                                                        .maxFinite),
                                                                Positioned(
                                                                  right: 5,
                                                                  bottom: 5,
                                                                  child: InkWell(
                                                                      onTap: () {
                                                                        photosDocumentsSnapshot
                                                                            .data!
                                                                            .car!
                                                                            .imagesAndDocuments!
                                                                            .images!
                                                                            .additionalImages!
                                                                            .imageID3 = '';
                                                                        photosDocumentsBloc
                                                                            .changedPhotosDocumentsData
                                                                            .call(photosDocumentsSnapshot.data!);
                                                                      },
                                                                      child: CircleAvatar(
                                                                          backgroundColor: Colors.white,
                                                                          radius: 10,
                                                                          child: Icon(
                                                                            Icons.delete,
                                                                            color:
                                                                                Color(0xffF55A51),
                                                                            size:
                                                                                20,
                                                                          ))),
                                                                )
                                                              ])),
                                              ),
                                              GestureDetector(
                                                  onTap: () =>
                                                      _settingModalBottomSheet(
                                                          context,
                                                          4,
                                                          photosDocumentsSnapshot),
                                                  child: photosDocumentsSnapshot
                                                              .data!
                                                              .car!
                                                              .imagesAndDocuments!
                                                              .images!
                                                              .additionalImages!
                                                              .imageID4 ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Add-Photo_Placeholder.png'),
                                                          color:
                                                              Color(0xFFF2F2F2),
                                                        )
                                                      : Stack(
                                                          children: <Widget>[
                                                              SizedBox(
                                                                  child: Image(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    image: NetworkImage(
                                                                        '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.additionalImages!.imageID4}'),
                                                                  ),
                                                                  width: double
                                                                      .maxFinite),
                                                              Positioned(
                                                                right: 5,
                                                                bottom: 5,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      photosDocumentsSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .imagesAndDocuments!
                                                                          .images!
                                                                          .additionalImages!
                                                                          .imageID4 = '';
                                                                      photosDocumentsBloc
                                                                          .changedPhotosDocumentsData
                                                                          .call(
                                                                              photosDocumentsSnapshot.data!);
                                                                    },
                                                                    child: CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        radius: 10,
                                                                        child: Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Color(0xffF55A51),
                                                                          size:
                                                                              20,
                                                                        ))),
                                                              )
                                                            ])),
                                              GestureDetector(
                                                  onTap: () =>
                                                      _settingModalBottomSheet(
                                                          context,
                                                          5,
                                                          photosDocumentsSnapshot),
                                                  child: photosDocumentsSnapshot
                                                              .data!
                                                              .car!
                                                              .imagesAndDocuments!
                                                              .images!
                                                              .additionalImages!
                                                              .imageID5 ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Add-Photo_Placeholder.png'),
                                                          color:
                                                              Color(0xFFF2F2F2),
                                                        )
                                                      : Stack(
                                                          children: <Widget>[
                                                              SizedBox(
                                                                  child: Image(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    image: NetworkImage(
                                                                        '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.additionalImages!.imageID5}'),
                                                                  ),
                                                                  width: double
                                                                      .maxFinite),
                                                              Positioned(
                                                                right: 5,
                                                                bottom: 5,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      photosDocumentsSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .imagesAndDocuments!
                                                                          .images!
                                                                          .additionalImages!
                                                                          .imageID5 = '';
                                                                      photosDocumentsBloc
                                                                          .changedPhotosDocumentsData
                                                                          .call(
                                                                              photosDocumentsSnapshot.data!);
                                                                    },
                                                                    child: CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        radius: 10,
                                                                        child: Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Color(0xffF55A51),
                                                                          size:
                                                                              20,
                                                                        ))),
                                                              )
                                                            ])),
                                              GestureDetector(
                                                  onTap: () =>
                                                      _settingModalBottomSheet(
                                                          context,
                                                          6,
                                                          photosDocumentsSnapshot),
                                                  child: photosDocumentsSnapshot
                                                              .data!
                                                              .car!
                                                              .imagesAndDocuments!
                                                              .images!
                                                              .additionalImages!
                                                              .imageID6 ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Add-Photo_Placeholder.png'),
                                                          color:
                                                              Color(0xFFF2F2F2),
                                                        )
                                                      : Stack(
                                                          children: <Widget>[
                                                              SizedBox(
                                                                  child: Image(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    image: NetworkImage(
                                                                        '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.additionalImages!.imageID6}'),
                                                                  ),
                                                                  width: double
                                                                      .maxFinite),
                                                              Positioned(
                                                                right: 5,
                                                                bottom: 5,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      photosDocumentsSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .imagesAndDocuments!
                                                                          .images!
                                                                          .additionalImages!
                                                                          .imageID6 = '';
                                                                      photosDocumentsBloc
                                                                          .changedPhotosDocumentsData
                                                                          .call(
                                                                              photosDocumentsSnapshot.data!);
                                                                    },
                                                                    child: CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        radius: 10,
                                                                        child: Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Color(0xffF55A51),
                                                                          size:
                                                                              20,
                                                                        ))),
                                                              )
                                                            ])),
                                              GestureDetector(
                                                onTap: () =>
                                                    _settingModalBottomSheet(
                                                        context,
                                                        7,
                                                        photosDocumentsSnapshot),
                                                child: Container(
                                                    color: Colors.transparent,
                                                    child: photosDocumentsSnapshot
                                                                .data!
                                                                .car!
                                                                .imagesAndDocuments!
                                                                .images!
                                                                .additionalImages!
                                                                .imageID7 ==
                                                            ''
                                                        ? Container(
                                                            child: Image.asset(
                                                                'icons/Add-Photo_Placeholder.png'),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFF2F2F2),
                                                              borderRadius:
                                                                  new BorderRadius
                                                                      .only(
                                                                bottomLeft:
                                                                    const Radius
                                                                            .circular(
                                                                        12.0),
                                                              ),
                                                            ),
                                                          )
                                                        : Stack(
                                                            children: <Widget>[
                                                                SizedBox(
                                                                    child:
                                                                        Image(
                                                                      fit: BoxFit
                                                                          .fill,
                                                                      image: NetworkImage(
                                                                          '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.additionalImages!.imageID7}'),
                                                                    ),
                                                                    width: double
                                                                        .maxFinite),
                                                                Positioned(
                                                                  right: 5,
                                                                  bottom: 5,
                                                                  child: InkWell(
                                                                      onTap: () {
                                                                        photosDocumentsSnapshot
                                                                            .data!
                                                                            .car!
                                                                            .imagesAndDocuments!
                                                                            .images!
                                                                            .additionalImages!
                                                                            .imageID7 = '';
                                                                        photosDocumentsBloc
                                                                            .changedPhotosDocumentsData
                                                                            .call(photosDocumentsSnapshot.data!);
                                                                      },
                                                                      child: CircleAvatar(
                                                                          backgroundColor: Colors.white,
                                                                          radius: 10,
                                                                          child: Icon(
                                                                            Icons.delete,
                                                                            color:
                                                                                Color(0xffF55A51),
                                                                            size:
                                                                                20,
                                                                          ))),
                                                                )
                                                              ])),
                                              ),
                                              GestureDetector(
                                                  onTap: () =>
                                                      _settingModalBottomSheet(
                                                          context,
                                                          8,
                                                          photosDocumentsSnapshot),
                                                  child: photosDocumentsSnapshot
                                                              .data!
                                                              .car!
                                                              .imagesAndDocuments!
                                                              .images!
                                                              .additionalImages!
                                                              .imageID8 ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Add-Photo_Placeholder.png'),
                                                          color:
                                                              Color(0xFFF2F2F2),
                                                        )
                                                      : Stack(
                                                          children: <Widget>[
                                                              SizedBox(
                                                                  child: Image(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    image: NetworkImage(
                                                                        '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.additionalImages!.imageID8}'),
                                                                  ),
                                                                  width: double
                                                                      .maxFinite),
                                                              Positioned(
                                                                right: 5,
                                                                bottom: 5,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      photosDocumentsSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .imagesAndDocuments!
                                                                          .images!
                                                                          .additionalImages!
                                                                          .imageID8 = '';
                                                                      photosDocumentsBloc
                                                                          .changedPhotosDocumentsData
                                                                          .call(
                                                                              photosDocumentsSnapshot.data!);
                                                                    },
                                                                    child: CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        radius: 10,
                                                                        child: Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Color(0xffF55A51),
                                                                          size:
                                                                              20,
                                                                        ))),
                                                              )
                                                            ])),
                                              GestureDetector(
                                                  onTap: () =>
                                                      _settingModalBottomSheet(
                                                          context,
                                                          9,
                                                          photosDocumentsSnapshot),
                                                  child: photosDocumentsSnapshot
                                                              .data!
                                                              .car!
                                                              .imagesAndDocuments!
                                                              .images!
                                                              .additionalImages!
                                                              .imageID9 ==
                                                          ''
                                                      ? Container(
                                                          color: Colors
                                                              .transparent,
                                                          child: Container(
                                                            child: Image.asset(
                                                                'icons/Add-Photo_Placeholder.png'),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFF2F2F2),
                                                              borderRadius:
                                                                  new BorderRadius
                                                                      .only(
                                                                bottomRight:
                                                                    const Radius
                                                                            .circular(
                                                                        12.0),
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : Stack(
                                                          children: <Widget>[
                                                              SizedBox(
                                                                  child: Image(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    image: NetworkImage(
                                                                        '$storageServerUrl/${photosDocumentsSnapshot.data!.car!.imagesAndDocuments!.images!.additionalImages!.imageID9}'),
                                                                  ),
                                                                  width: double
                                                                      .maxFinite),
                                                              Positioned(
                                                                right: 5,
                                                                bottom: 5,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      photosDocumentsSnapshot
                                                                          .data!
                                                                          .car!
                                                                          .imagesAndDocuments!
                                                                          .images!
                                                                          .additionalImages!
                                                                          .imageID9 = '';
                                                                      photosDocumentsBloc
                                                                          .changedPhotosDocumentsData
                                                                          .call(
                                                                              photosDocumentsSnapshot.data!);
                                                                    },
                                                                    child: CircleAvatar(
                                                                        backgroundColor: Colors.white,
                                                                        radius: 10,
                                                                        child: Icon(
                                                                          Icons
                                                                              .delete,
                                                                          color:
                                                                              Color(0xffF55A51),
                                                                          size:
                                                                              20,
                                                                        ))),
                                                              )
                                                            ])),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 30),

                                /// Next button
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
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0)),

                                              ),
                                               onPressed: progressIndicatorSnapshot
                                                              .data ==
                                                          1 ||
                                                      photosDocumentsBloc
                                                          .checkButtonDisable(
                                                              photosDocumentsSnapshot)
                                                  ? null
                                                  : () async {
                                                      if (!photosDocumentsBloc
                                                          .checkValidity(
                                                              photosDocumentsSnapshot
                                                                  .data!)) {
                                                        return;
                                                      }
                                                      photosDocumentsBloc
                                                          .changedProgressIndicator
                                                          .call(1);
                                                      CreateCarResponse
                                                          response =
                                                          await photosDocumentsBloc
                                                              .photosAndDocuments(
                                                                  photosDocumentsSnapshot
                                                                      .data!);

                                                      if (response != null) {
                                                        if (pushNeeded) {
                                                          Navigator.pushNamed(
                                                              context,
                                                              pushRouteName!,
                                                              arguments: {
                                                                'carResponse':
                                                                    response,
                                                                'purpose':
                                                                    purpose
                                                              });
                                                        } else {
                                                          Navigator.pop(context,
                                                              response);
                                                        }
                                                      }
                                                    },
                                              child: progressIndicatorSnapshot
                                                          .data ==
                                                      0
                                                  ? Text(
                                                      'Next',
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 18,
                                                          color: Colors.white),
                                                    )
                                                  : SizedBox(
                                                      height: 18.0,
                                                      width: 18.0,
                                                      child:
                                                          new CircularProgressIndicator(
                                                              strokeWidth: 2.5),
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
                    })
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new CircularProgressIndicator(strokeWidth: 2.5)
                      ],
                    ),
                  );
          }),
    );
  }
}
