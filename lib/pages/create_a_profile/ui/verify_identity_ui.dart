import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/services/text_formatter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:info_popup/info_popup.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/create_a_profile/bloc/verify_identity_bloc.dart';
import 'package:ridealike/pages/create_a_profile/response_model/add_identity_image_response.dart';
import 'package:ridealike/pages/create_a_profile/response_model/create_profile_response_model.dart';
import 'package:ridealike/pages/create_a_profile/response_model/options_lists.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

class VerifyIdentityUi extends StatefulWidget {
  @override
  State createState() => VerifyIdentityUiState();
}

class VerifyIdentityUiState extends State<VerifyIdentityUi> {
  var verifyIdentityBloc = VerifyIdentityBloc();
  final storage = FlutterSecureStorage();
  String _profileID = "";
  String? userID;
  CreateProfileResponse? createProfileResponse;
  List? heardOptionsList;
  String? checkValidityDL;

  TextEditingController _otherOptionFieldController =
      TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    //AppEventsUtils.logEvent("registration_verify_doc_view");
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Verify Your Identify"});
    verifyIdentityBloc.changedVerifyButton.call(true);
    verifyIdentityBloc.getHeardOptionsList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _settingModalBottomSheet(context, _imgType) {
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
                ListTile(
                  leading: Image.asset('icons/Take-Photo_Sheet.png'),
                  dense: true,
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
                    verifyIdentityBloc.pickImageThroughCamera(
                        _imgType, context);
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
                    verifyIdentityBloc.pickImageFromGallery(_imgType, context);
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
    final CreateProfileResponse createProfileResponse =
        CreateProfileResponse.fromJson(
            json.decode(ModalRoute.of(context)!.settings.arguments as String ?? ""));
    verifyIdentityBloc.createProfileResponse = createProfileResponse;

    _profileID = createProfileResponse.user!.profileID!;
    print('ProfileID $_profileID');

    verifyIdentityBloc.changedProgressIndicator.call(0);

    return Scaffold(
      backgroundColor: Colors.white,

      //App Bar
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            //Navigator.pushNamed(context, '/create_profile');
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
      ),

      //Content of tabs
      body: new SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left:16.0,right: 16),
          child: Column(
            children: <Widget>[
              // Text
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
                              'Verify your identity',
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
                  // Image.asset('icons/ID_Verify-ID.png'),
                ],
              ),
              SizedBox(height: 5),
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
                            'All our members go through a verification process. It is to ensure the safety of our like-minded community. Please take a photo of yourself and your driver\'s license.',
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
              SizedBox(height: 5),
              // Selfie
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Upload a photo of your face",
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF353B50),
                          ),
                        ),
                        InfoPopupWidget(
                          arrowTheme: InfoPopupArrowTheme(
                            color: Color(0xffFF8F68),
                            arrowDirection: ArrowDirection.up,
                          ),
                          contentTheme: InfoPopupContentTheme(
                            infoContainerBackgroundColor: Color(0xFF575757),
                            infoTextStyle: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                            ),
                            contentPadding: const EdgeInsets.all(8),
                            contentBorderRadius: BorderRadius.all(Radius.circular(10)),
                            infoTextAlign: TextAlign.start,
                          ),
                          contentTitle:
                          'Add a photo of your face (This picture won’t be visible to the public, and is only displayed to the other party during pick-up of a rental/swap vehicle to help RideAlike members identify each other)',
                          child: SvgPicture.asset(
                            'svg/oui_i-in-circle.svg',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    StreamBuilder<String>(
                      stream: verifyIdentityBloc.faceImageFile,
                      builder: (context, faceImageFileSnapshot) {
                        return GestureDetector(
                          onTap: () => _settingModalBottomSheet(context, '_faceImageFile'),
                          child: SizedBox(
                            width: double.maxFinite,
                            height: 220,
                            child: faceImageFileSnapshot.hasData &&
                                faceImageFileSnapshot.data!.isNotEmpty
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.network(
                                '$storageServerUrl/${faceImageFileSnapshot.data}',
                                fit: BoxFit.cover,
                              ),
                            )
                                : Container(
                              decoration: BoxDecoration(
                                color: Color(0xFFF2F2F2),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                child: Image.asset(
                                  'images/profile.png',
                                  width: 170,
                                  height: 170,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Divider(
                      color: Color(0xFFB2B2B2).withOpacity(0.6),
                      thickness: 4,
                    )
                  ],
                ),
              ),
            ],
          ),
              SizedBox(height: 10),
              // DL front & back
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Driver’s license images",
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF353B50),
                            ),
                          ),
                          InfoPopupWidget(
                            arrowTheme: InfoPopupArrowTheme(
                              color: Color(0xffFF8F68),
                              arrowDirection: ArrowDirection.up,
                            ),
                            contentTheme: InfoPopupContentTheme(
                              infoContainerBackgroundColor: Color(0xFF575757),
                              infoTextStyle: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                              ),
                              contentPadding: const EdgeInsets.all(8),
                              contentBorderRadius: BorderRadius.all(Radius.circular(10)),
                              infoTextAlign: TextAlign.start,
                            ),
                            contentTitle:
                            'All our members go through a verification process. It is to ensure the safety of our like-minded community. Please take a photo of yourself and your driver’s license.',
                            child: SvgPicture.asset(
                              'svg/oui_i-in-circle.svg',
                              width: 30,
                              height: 30,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Upload your driver’s license front and back photos",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF353B50),
                        ),
                      ),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Text(
                                "License front-side:",
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF353B50),
                                ),
                              ),
                              SizedBox(height: 15),
                              StreamBuilder<String>(
                                stream: verifyIdentityBloc.dlFrontFile,
                                builder: (context, dlFrontFileSnapshot) {
                                  return GestureDetector(
                                    onTap: () => _settingModalBottomSheet(context, '_dLFront'),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width / 2.5,
                                      height: 170,
                                      child: dlFrontFileSnapshot.hasData && dlFrontFileSnapshot.data!.isNotEmpty
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: Image.network(
                                          '$storageServerUrl/${dlFrontFileSnapshot.data}',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Color(0xFFABABAB),
                                            size: 50.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          Container(
                            width: 2,
                            height: 170,
                            color: Colors.grey.shade300,
                          ),
                          Column(
                            children: [
                              Text(
                                "License back-side:",
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF353B50),
                                ),
                              ),
                              SizedBox(height: 15),
                              StreamBuilder<String>(
                                stream: verifyIdentityBloc.dlBackFile,
                                builder: (context, dlBackFileSnapshot) {
                                  return GestureDetector(
                                    onTap: () => _settingModalBottomSheet(context, '_dLBack'),
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width / 2.5,
                                      height: 170,
                                      child: dlBackFileSnapshot.hasData && dlBackFileSnapshot.data!.isNotEmpty
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0),
                                        child: Image.network(
                                          '$storageServerUrl/${dlBackFileSnapshot.data}',
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : Container(
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius: BorderRadius.circular(12.0),
                                        ),
                                        child: Padding(
                                          padding: EdgeInsets.only(top: 50.0, bottom: 50.0),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Color(0xFFABABAB),
                                            size: 50.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Divider(
                        color: Color(0xFFB2B2B2).withOpacity(0.6),
                        thickness: 4,
                      )
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),

              ///drop down
              StreamBuilder<OptionsList>(
                  stream: verifyIdentityBloc.heardOptionsList,
                  builder: (context, heardOptionsListSnapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How did you hear about us?',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 18,
                            color: Color(0xFF371D32),
                          ),
                        ),

                        InputDecorator(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0)),
                            contentPadding: EdgeInsets.all(10),
                          ),
                          child: heardOptionsListSnapshot.hasData == true &&
                                  heardOptionsListSnapshot.data != null
                              ?  Theme(
                              data: Theme.of(context).copyWith(
                                  canvasColor: Colors.white
                              ),
                                child: DropdownButton<String>(
                                    value: heardOptionsListSnapshot
                                        .data!.selectedValue,
                                    isExpanded: true,
                                    items: heardOptionsListSnapshot
                                        .data!.heardOptions!
                                        .map((HeardOptions value) {
                                      return DropdownMenuItem<String>(
                                        value: value.optionName,
                                        child: Text(value.optionName!),
                                      );
                                    }).toList(),
                                    onChanged: (selectedOptions) {
                                      heardOptionsListSnapshot
                                          .data!.selectedValue = selectedOptions;
                                      verifyIdentityBloc
                                          .changedHeardOptionsListController
                                          .call(heardOptionsListSnapshot.data!);
                                    },
                                  ),
                              )
                              : Container(),
                        ),

                        heardOptionsListSnapshot.hasData == true &&
                                heardOptionsListSnapshot.data != null &&
                                heardOptionsListSnapshot.data!.selectedValue ==
                                    'Other'
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: double.maxFinite,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Color(0xFFF2F2F2),
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              border: Border.all(
                                                color: Color(0xFFCCCCCC).withOpacity(0.5), 
                                                width: 1.5, 
                                              ),
                                            ),
                                            child: TextFormField(
                                              maxLines: 3,
                                              controller:
                                                  _otherOptionFieldController,
                                              onChanged: (value) {
                                                if (value.length > 100) {
                                                  value =
                                                      value.substring(0, 100);
                                                }
                                                heardOptionsListSnapshot
                                                    .data!.othersValue = value;
                                                verifyIdentityBloc
                                                    .changedHeardOptionsListController
                                                    .call(
                                                        heardOptionsListSnapshot
                                                            .data!);
                                              },
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .allow(
                                                        (RegExp('[a-zA-Z ]')),
                                                        replacementString: '')
                                              ],
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(left:10.0,right: 10,bottom: 0,top: 10),
                                                  border: InputBorder.none,
                                                  labelText: 'Please describe other options',
                                                  hintMaxLines: 3,
                                                  labelStyle: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF353B50),
                                                  ),
                                                  hintStyle: TextStyle(fontFamily: 'Urbanist'),
                                                  hintText:
                                                      '',),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Container(),

                           SizedBox(height: 20,),

                        /// Submit button
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: double.maxFinite,
                                    child: StreamBuilder<bool>(
                                        stream: verifyIdentityBloc
                                            .nextIdentityButton,
                                        builder: (context, snapshot) {
                                          return StreamBuilder<bool>(
                                              stream: verifyIdentityBloc
                                                  .verifyButton,
                                              builder: (context,
                                                  verifyButtonSnapshot) {
                                                return StreamBuilder<int>(
                                                    stream: verifyIdentityBloc
                                                        .progressIndicator,
                                                    builder: (context,
                                                        progressIndicatorSnapshot) {
                                                      return ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: snapshot
                                                              .hasData &&
                                                              verifyButtonSnapshot
                                                                  .data! && checkValidityDL!="invalidData"
                                                              ? Color(0xffFF8F68)
                                                              : Colors.grey,
                                                          padding: EdgeInsets.all(
                                                              16.0),
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                  8.0)),
                                                        ),



                                                        onPressed: snapshot
                                                                    .hasData &&
                                                                heardOptionsListSnapshot
                                                                    .hasData &&
                                                                heardOptionsListSnapshot
                                                                        .data!
                                                                        .selectedValue !=
                                                                    null &&
                                                                progressIndicatorSnapshot
                                                                        .data ==
                                                                    0 && checkValidityDL!="invalidData"
                                                            ? () async {
                                                                await storage
                                                                    .delete(
                                                                        key:
                                                                            'route');
                                                                await storage
                                                                    .delete(
                                                                        key:
                                                                            'data');
                                                                if (progressIndicatorSnapshot
                                                                            .data ==
                                                                        0 &&
                                                                    createProfileResponse !=
                                                                        null) {
                                                                  verifyIdentityBloc
                                                                      .changedProgressIndicator
                                                                      .call(1);
                                                                  AddIdentityImagesResponse
                                                                      identityRes =
                                                                      await verifyIdentityBloc
                                                                          .submitIdentityImageButton(
                                                                              createProfileResponse);
                                                                  print(
                                                                      'identityButton$identityRes');
                                                                  AppEventsUtils
                                                                      .logEvent(
                                                                          "registration_all_doc_license_added",
                                                                          params: {
                                                                        "verificationStatus": identityRes
                                                                            .verification!
                                                                            .verificationStatus,
                                                                        "licence":
                                                                            "true",
                                                                      });
                                                                  await verifyIdentityBloc
                                                                      .profileWelcomeEmailCheck(
                                                                          createProfileResponse);
                                                                  await verifyIdentityBloc
                                                                      .submitProfileStatusCheck(
                                                                          createProfileResponse);

                                                                  if (identityRes !=
                                                                          null &&
                                                                      identityRes
                                                                              .status!
                                                                              .success ==
                                                                          true) {
                                                                    await storage
                                                                        .delete(
                                                                            key:
                                                                                'photo');
                                                                    Navigator.pushNamed(
                                                                            context,
                                                                            '/verification_in_progress',
                                                                            arguments:
                                                                                createProfileResponse)
                                                                        .then(
                                                                            (value) {
                                                                      verifyIdentityBloc
                                                                          .changedVerifyButton
                                                                          .call(
                                                                              true);
                                                                      verifyIdentityBloc
                                                                          .changedProgressIndicator
                                                                          .call(
                                                                              0);
                                                                    });
                                                                  } else {
                                                                    verifyIdentityBloc
                                                                        .changedVerifyButton
                                                                        .call(
                                                                            true);
                                                                    verifyIdentityBloc
                                                                        .changedProgressIndicator
                                                                        .call(
                                                                            0);
                                                                  }
                                                                }
                                                              }
                                                            : null,
                                                        child: progressIndicatorSnapshot
                                                                    .hasData &&
                                                                progressIndicatorSnapshot
                                                                        .data ==
                                                                    1
                                                            ? SizedBox(
                                                                height: 18.0,
                                                                width: 18.0,
                                                                child: new CircularProgressIndicator(
                                                                    strokeWidth:
                                                                        2.5),
                                                              )
                                                            : Text(
                                                                'Submit profile',
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        18,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                      );
                                                    });
                                              });
                                        }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 30),
                      ],
                    );
                  }),
              // SizedBox(height: 30),
              // /// Submit button
              // Row(
              //   children: [
              //     Expanded(
              //       child: Column(
              //         children: [
              //           SizedBox(
              //             width: double.maxFinite,
              //             child: StreamBuilder<bool>(
              //                 stream: verifyIdentityBloc.nextIdentityButton,
              //                 builder: (context, snapshot) {
              //                   return StreamBuilder<bool>(
              //                       stream: verifyIdentityBloc.verifyButton,
              //                       builder: (context, verifyButtonSnapshot) {
              //                         return StreamBuilder<int>(
              //                             stream: verifyIdentityBloc
              //                                 .progressIndicator,
              //                             builder: (context,
              //                                 progressIndicatorSnapshot) {
              //                               return ElevatedButton(style: ElevatedButton.styleFrom(
              //                                 elevation: 0.0,
              //                                 color: snapshot.hasData &&
              //                                         verifyButtonSnapshot.data
              //                                     ? Color(0xffFF8F68)
              //                                     : Colors.grey,
              //                                 padding: EdgeInsets.all(16.0),
              //                                 shape: RoundedRectangleBorder(
              //                                     borderRadius:
              //                                         BorderRadius.circular(
              //                                             8.0)),
              //                                 onPressed: snapshot.hasData &&
              //                                         progressIndicatorSnapshot.data == 0
              //                                     ? () async {
              //                                   await storage.delete(key: 'route');
              //                                   await storage.delete(key: 'data');
              //                                         if (progressIndicatorSnapshot.data ==
              //                                             0 && createProfileResponse != null) {
              //                                           verifyIdentityBloc.changedProgressIndicator
              //                                               .call(1);
              //                                           AddIdentityImagesResponse
              //                                               identityRes =
              //                                               await verifyIdentityBloc
              //                                                   .submitIdentityImageButton(
              //                                                       createProfileResponse);
              //                                           print('identityButton$identityRes');
              //
              //                                           await verifyIdentityBloc.profileWelcomeEmailCheck(createProfileResponse);
              //                                          await verifyIdentityBloc.submitProfileStatusCheck(createProfileResponse);
              //
              //
              //                                           if (identityRes != null &&
              //                                               identityRes.status.success == true) {
              //                                             await storage.delete(key: 'photo');
              //                                             Navigator.pushNamed(context, '/verification_in_progress',
              //                                                     arguments: createProfileResponse)
              //                                                 .then((value) {
              //                                               verifyIdentityBloc.changedVerifyButton.call(true);
              //                                               verifyIdentityBloc.changedProgressIndicator.call(0);
              //                                             });
              //                                           } else {
              //                                             verifyIdentityBloc.changedVerifyButton.call(true);
              //                                             verifyIdentityBloc.changedProgressIndicator.call(0);
              //                                           }
              //                                         }
              //                                       }
              //                                     : null,
              //                                 child: progressIndicatorSnapshot
              //                                             .hasData &&
              //                                         progressIndicatorSnapshot
              //                                                 .data ==
              //                                             1
              //                                     ? SizedBox(
              //                                         height: 18.0,
              //                                         width: 18.0,
              //                                         child:
              //                                             new CircularProgressIndicator(
              //                                                 strokeWidth: 2.5),
              //                                       )
              //                                     : Text(
              //                                         'Verify profile now',
              //                                         style: TextStyle(
              //                                             fontFamily:
              //                                                 'Urbanist',
              //                                             fontSize: 18,
              //                                             color: Colors.white),
              //                                       ),
              //                               );
              //                             });
              //                       });
              //                 }),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  void displayDialog(BuildContext context, String title, String text) =>
      showDialog(
        context: context,
        builder: (context) =>
            AlertDialog(title: Text(title), content: Text(text)),
      );
}
