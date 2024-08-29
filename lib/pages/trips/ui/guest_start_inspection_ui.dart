import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/inspection_info_bloc.dart';
import 'package:ridealike/pages/trips/bloc/start_trip_inspection_bloc.dart';
import 'package:ridealike/pages/trips/request_service/start_trip_inspect_request.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/inspection_info_response.dart';
import 'package:ridealike/pages/trips/response_model/start_trip_inspect_rental_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/custom_buttom.dart';

class GuestStartInspectionInfo extends StatefulWidget {
  @override
  State createState() => GuestStartInspectionInfoState();
}

class GuestStartInspectionInfoState extends State<GuestStartInspectionInfo> {
  final startTripBloc = StartTripBloc();
  final inspectionInfoBloc = InspectionInfoBloc();
  String? damageDesctiption;
  TextEditingController _mileageController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  FocusNode _damageDesctiptionfocusNode = FocusNode();
  FocusNode _mileagefocusNode = FocusNode();

  @override
  void dispose() {
    _damageDesctiptionfocusNode.dispose();
    _mileagefocusNode.dispose();
    super.dispose();
  }

  void _handleTapOutside() {
    _damageDesctiptionfocusNode.unfocus();
    _mileagefocusNode.unfocus();
  }

  void _settingModalBottomSheet(context, _imgOrder,
      AsyncSnapshot<InspectTripStartResponse> startTripDataSnapshot) {
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
                    startTripBloc.pickeImageThroughCamera(
                        _imgOrder, startTripDataSnapshot, context);
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
                    startTripBloc.pickeImageFromGallery(
                        _imgOrder, startTripDataSnapshot, context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
              ],
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Guest Start Inspection"});
  }

  @override
  Widget build(BuildContext context) {
    final receivedData = ModalRoute.of(context)!.settings.arguments as Map;
    Trips tripDetails = receivedData["tripsData"];
    InspectionInfo inspectionInfo = receivedData['inspectionData'];
    String? fuelLevel = inspectionInfo.inspectionInfo!.startHost!.fuelLevel;
    int mileage = inspectionInfo.inspectionInfo!.startHost!.mileage ?? 0;

    InspectTripStartResponse inspectTripStartResponse =
        InspectTripStartResponse(
            tripStartInspection: TripStartInspection(
                exteriorCleanliness: inspectionInfo
                    .inspectionInfo!.startHost!.exteriorCleanliness,
                interiorCleanliness: inspectionInfo
                    .inspectionInfo!.startHost!.interiorCleanliness,
                damageImageIDs: List.filled(12, ''),
                exteriorImageIDs: List.filled(9, ''),
                interiorImageIDs: List.filled(9, ''),
                dashboardImageIDs: List.filled(9, ''),
                fuelImageIDs: List.filled(9, ''),
                mileage: mileage,
                fuelLevel: "",
                damageDesctiption: "",
                mileageImageIDs: List.filled(9, ''),
                inspectionByUserID: tripDetails.userID,
                tripID: tripDetails.tripID));
    startTripBloc.changedStartTripData.call(inspectTripStartResponse);
    startTripBloc.changedDamageSelection.call(
        inspectionInfo.inspectionInfo!.startHost!.isNoticibleDamage! ? 2 : 1);
    _mileageController.text =
        inspectionInfo.inspectionInfo!.startHost!.mileage.toString();
    _descriptionController.text =
        inspectionInfo.inspectionInfo!.startHost!.damageDesctiption!;
    return GestureDetector(
      onTap: _handleTapOutside,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: StreamBuilder<InspectTripStartResponse>(
            stream: startTripBloc.startTripData,
            builder: (context, startTripDataSnapshot) {
              return startTripDataSnapshot.hasData &&
                      startTripDataSnapshot.data! != null
                  ? StreamBuilder<int>(
                      stream: startTripBloc.damageSelection,
                      builder: (context, damageSelectionSnapshot) {
                        return Container(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: <Widget>[
                                  SizedBox(height: 40),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Cancel",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFFF68E65)),
                                        ),
                                      ),
                                      Text(
                                        "",
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32)),
                                      ),
                                      Text('             '),
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "Start trip",
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 36,
                                            color: Color(0xFF371D32),
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Center(
                                        child: (tripDetails.carImageId !=
                                                    null ||
                                                tripDetails.carImageId != '')
                                            ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    '$storageServerUrl/${tripDetails.carImageId}'),
                                                radius: 17.5,
                                              )
                                            : CircleAvatar(
                                                backgroundImage: AssetImage(
                                                    'images/car-placeholder.png'),
                                                radius: 17.5,
                                              ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Any noticeable damage before the trip?",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Inspect vehicle's inside and outside for any visual damage, like dents, scratches or broken parts.",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Color(0xFF353B50)),
                                          ),
                                          SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Expanded(
                                                child: CustomButton(
                                                  title: 'NO',
                                                  isSelected:
                                                      damageSelectionSnapshot
                                                                  .data ==
                                                              1
                                                          ? true
                                                          : false,
                                                  press: () {
                                                    startTripDataSnapshot
                                                            .data!
                                                            .tripStartInspection!
                                                            .isNoticibleDamage =
                                                        false;
                                                    startTripBloc
                                                        .changedStartTripData
                                                        .call(
                                                            startTripDataSnapshot
                                                                .data!);
                                                    startTripBloc
                                                        .changedDamageSelection
                                                        .call(1);
                                                  },
                                                ),
                                              ),
                                              SizedBox(width: 10.0),
                                              Expanded(
                                                child: CustomButton(
                                                  title: 'YES',
                                                  isSelected:
                                                      damageSelectionSnapshot
                                                                  .data ==
                                                              2
                                                          ? true
                                                          : false,
                                                  press: () {
                                                    startTripDataSnapshot
                                                            .data!
                                                            .tripStartInspection!
                                                            .isNoticibleDamage =
                                                        true;
                                                    startTripBloc
                                                        .changedStartTripData
                                                        .call(
                                                            startTripDataSnapshot
                                                                .data!);
                                                    startTripBloc
                                                        .changedDamageSelection
                                                        .call(2);
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Take photos of car if any damages",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
                                          ),
                                      GridView.builder(
                                        primary: false,
                                        shrinkWrap: true,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 3,
                                          mainAxisSpacing: 1,
                                        ),
                                        itemCount: 6,
                                        itemBuilder: (context, index) {
                                          String imageUrl;
                                          bool isImageEmpty;
                                          if (index < startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs!.length) {
                                            imageUrl = startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![index];
                                            isImageEmpty = imageUrl.isEmpty &&
                                                inspectionInfo.inspectionInfo!.startHost!.damageImageIDs!.length <= index;
                                          } else {
                                            imageUrl = '';
                                            isImageEmpty = true;
                                          }

                                          return GestureDetector(
                                            onTap: () {
                                              if (!isImageEmpty) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => Scaffold(
                                                      appBar: AppBar(),
                                                      body: Center(
                                                        child: PhotoView(
                                                          imageProvider: NetworkImage(
                                                            '$storageServerUrl/${imageUrl.isNotEmpty ? imageUrl : inspectionInfo.inspectionInfo!.startHost!.damageImageIDs![index]}',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: isImageEmpty
                                                ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: BorderRadius.circular(12.0),
                                              ),
                                            )
                                                : Stack(
                                              children: <Widget>[
                                                Container(
                                                  height: 150,
                                                  width: double.infinity,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                    BorderRadius.all(Radius.circular(8)),
                                                    child: Image(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(
                                                        '$storageServerUrl/${imageUrl.isNotEmpty ? imageUrl : inspectionInfo.inspectionInfo!.startHost!.damageImageIDs![index]}',
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),

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
                                                          7,
                                                          startTripDataSnapshot),
                                                  child: startTripDataSnapshot
                                                              .data!
                                                              .tripStartInspection!
                                                              .damageImageIDs![6] ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Scan-Placeholder.png'),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                    .only(
                                                              topLeft:
                                                                  const Radius
                                                                      .circular(
                                                                      12.0),
                                                              bottomLeft:
                                                                  const Radius
                                                                      .circular(
                                                                      12.0),
                                                            ),
                                                          ),
                                                        )
                                                      : Stack(children: <Widget>[
                                                          SizedBox(
                                                              child: Image(
                                                                fit:
                                                                    BoxFit.fill,
                                                                image: NetworkImage(
                                                                    '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![6]}'),
                                                              ),
                                                              width: double
                                                                  .maxFinite),
                                                          Positioned(
                                                            right: 5,
                                                            bottom: 5,
                                                            child: InkWell(
                                                                onTap: () {
                                                                  startTripDataSnapshot
                                                                      .data!
                                                                      .tripStartInspection!
                                                                      .damageImageIDs![6] = '';
                                                                  startTripBloc
                                                                      .changedStartTripData
                                                                      .call(startTripDataSnapshot
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
                                                          8,
                                                          startTripDataSnapshot),
                                                  child: startTripDataSnapshot
                                                              .data!
                                                              .tripStartInspection!
                                                              .damageImageIDs![7] ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Scan-Placeholder.png'),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                          ),
                                                        )
                                                      : Stack(children: <Widget>[
                                                          SizedBox(
                                                              child: Image(
                                                                fit:
                                                                    BoxFit.fill,
                                                                image: NetworkImage(
                                                                    '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![7]}'),
                                                              ),
                                                              width: double
                                                                  .maxFinite),
                                                          Positioned(
                                                            right: 5,
                                                            bottom: 5,
                                                            child: InkWell(
                                                                onTap: () {
                                                                  startTripDataSnapshot
                                                                      .data!
                                                                      .tripStartInspection!
                                                                      .damageImageIDs![7] = '';
                                                                  startTripBloc
                                                                      .changedStartTripData
                                                                      .call(startTripDataSnapshot
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
                                                          startTripDataSnapshot),
                                                  child: startTripDataSnapshot
                                                              .data!
                                                              .tripStartInspection!
                                                              .damageImageIDs![8] ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Scan-Placeholder.png'),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                    .only(
                                                              topRight:
                                                                  const Radius
                                                                      .circular(
                                                                      12.0),
                                                              bottomRight:
                                                                  const Radius
                                                                      .circular(
                                                                      12.0),
                                                            ),
                                                          ),
                                                        )
                                                      : Stack(children: <Widget>[
                                                          SizedBox(
                                                              child: Image(
                                                                fit:
                                                                    BoxFit.fill,
                                                                image: NetworkImage(
                                                                    '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![8]}'),
                                                              ),
                                                              width: double
                                                                  .maxFinite),
                                                          Positioned(
                                                            right: 5,
                                                            bottom: 5,
                                                            child: InkWell(
                                                                onTap: () {
                                                                  startTripDataSnapshot
                                                                      .data!
                                                                      .tripStartInspection!
                                                                      .damageImageIDs![8] = '';
                                                                  startTripBloc
                                                                      .changedStartTripData
                                                                      .call(startTripDataSnapshot
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
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.all(5.0),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(6)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0,
                                                  right: 16.0,
                                                  top: 10),
                                              child: Text(
                                                "Describe Any damages(optional)",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 8.0, right: 16.0),
                                          child: TextField(
                                            focusNode:
                                                _damageDesctiptionfocusNode,
                                            controller: _descriptionController,
                                            textInputAction:
                                                TextInputAction.done,
                                            maxLines: 5,
                                            enabled:
                                                damageSelectionSnapshot.data ==
                                                    2,
                                            onChanged: (value) {
                                              damageDesctiption = (value);
                                              startTripDataSnapshot
                                                      .data!
                                                      .tripStartInspection!
                                                      .damageDesctiption =
                                                  damageDesctiption;
                                              startTripBloc.changedStartTripData
                                                  .call(startTripDataSnapshot
                                                      .data!);
                                            },
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Add a description here',
                                                hintStyle: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF686868),
                                                ),
                                                border: InputBorder.none),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Exterior car Cleanliness before the trip",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32)),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: CustomButton(
                                                title: 'POOR',
                                                isSelected: startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .exteriorCleanliness ==
                                                    'Poor',
                                                press: () {
                                                  startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .exteriorCleanliness =
                                                      'Poor';
                                                  startTripBloc
                                                      .changedStartTripData
                                                      .call(
                                                          startTripDataSnapshot
                                                              .data!);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              child: CustomButton(
                                                title: 'GOOD',
                                                isSelected: startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .exteriorCleanliness ==
                                                    'Good',
                                                press: () {
                                                  startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .exteriorCleanliness =
                                                      'Good';
                                                  startTripBloc
                                                      .changedStartTripData
                                                      .call(
                                                          startTripDataSnapshot
                                                              .data!);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              child: CustomButton(
                                                title: 'EXCELLENT',
                                                isSelected: startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .exteriorCleanliness ==
                                                    'Excellent',
                                                press: () {
                                                  startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .exteriorCleanliness =
                                                      'Excellent';
                                                  startTripBloc
                                                      .changedStartTripData
                                                      .call(
                                                          startTripDataSnapshot
                                                              .data!);
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Take photos of the car exterior",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
                                          ),

                                      GridView.count(
                                        primary: false,
                                        shrinkWrap: true,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                        crossAxisCount: 3,
                                        children: List.generate(6, (index) {
                                          String imageUrl;
                                          bool isImageEmpty;

                                          if (index < startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs!.length) {
                                            imageUrl = startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![index];
                                            isImageEmpty = imageUrl.isEmpty &&
                                                inspectionInfo.inspectionInfo!.startHost!.exteriorImageIDs!.length <= index;
                                          } else {
                                            imageUrl = '';
                                            isImageEmpty = true;
                                          }

                                          return GestureDetector(
                                            onTap: () {
                                              if (!isImageEmpty) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => Scaffold(
                                                      appBar: AppBar(),
                                                      body: Center(
                                                        child: PhotoView(
                                                          imageProvider: NetworkImage(
                                                            '$storageServerUrl/${imageUrl.isNotEmpty ? imageUrl : inspectionInfo.inspectionInfo!.startHost!.exteriorImageIDs![index]}',
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            child: isImageEmpty
                                                ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                              ),
                                            )
                                                : Container(
                                              height: 150,
                                              width: double.infinity,
                                              child: Image(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(
                                                  '$storageServerUrl/${imageUrl.isNotEmpty ? imageUrl : inspectionInfo.inspectionInfo!.startHost!.exteriorImageIDs![index]}',
                                                ),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),

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
                                                          19,
                                                          startTripDataSnapshot),
                                                  child: startTripDataSnapshot
                                                              .data!
                                                              .tripStartInspection!
                                                              .exteriorImageIDs![6] ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Scan-Placeholder.png'),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                                borderRadius:
                                                                new BorderRadius
                                                                    .only(
                                                                  topLeft:
                                                                  const Radius
                                                                      .circular(
                                                                      12.0),
                                                                  bottomLeft:
                                                                  const Radius
                                                                      .circular(
                                                                      12.0),
                                                                ),

                                                          ),
                                                        )
                                                      : Stack(children: <Widget>[
                                                          SizedBox(
                                                              child: Image(
                                                                fit:
                                                                    BoxFit.fill,
                                                                image: NetworkImage(
                                                                    '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![6]}'),
                                                              ),
                                                              width: double
                                                                  .maxFinite),
                                                          Positioned(
                                                            right: 5,
                                                            bottom: 5,
                                                            child: InkWell(
                                                                onTap: () {
                                                                  startTripDataSnapshot
                                                                      .data!
                                                                      .tripStartInspection!
                                                                      .exteriorImageIDs![6] = '';
                                                                  startTripBloc
                                                                      .changedStartTripData
                                                                      .call(startTripDataSnapshot
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
                                                          20,
                                                          startTripDataSnapshot),
                                                  child: startTripDataSnapshot
                                                              .data!
                                                              .tripStartInspection!
                                                              .exteriorImageIDs![7] ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Scan-Placeholder.png'),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                          ),
                                                        )
                                                      : Stack(children: <Widget>[
                                                          SizedBox(
                                                              child: Image(
                                                                fit:
                                                                    BoxFit.fill,
                                                                image: NetworkImage(
                                                                    '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![7]}'),
                                                              ),
                                                              width: double
                                                                  .maxFinite),
                                                          Positioned(
                                                            right: 5,
                                                            bottom: 5,
                                                            child: InkWell(
                                                                onTap: () {
                                                                  startTripDataSnapshot
                                                                      .data!
                                                                      .tripStartInspection!
                                                                      .exteriorImageIDs![7] = '';
                                                                  startTripBloc
                                                                      .changedStartTripData
                                                                      .call(startTripDataSnapshot
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
                                                          21,
                                                          startTripDataSnapshot),
                                                  child: startTripDataSnapshot
                                                              .data!
                                                              .tripStartInspection!
                                                              .exteriorImageIDs![8] ==
                                                          ''
                                                      ? Container(
                                                          child: Image.asset(
                                                              'icons/Scan-Placeholder.png'),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                0xFFE0E0E0),
                                                            borderRadius:
                                                                new BorderRadius
                                                                    .only(
                                                              topRight:
                                                                  const Radius
                                                                      .circular(
                                                                      12.0),
                                                              bottomRight:
                                                                  const Radius
                                                                      .circular(
                                                                      12.0),
                                                            ),
                                                          ),
                                                        )
                                                      : Stack(children: <Widget>[
                                                          SizedBox(
                                                              child: Image(
                                                                fit:
                                                                    BoxFit.fill,
                                                                image: NetworkImage(
                                                                    '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![8]}'),
                                                              ),
                                                              width: double
                                                                  .maxFinite),
                                                          Positioned(
                                                            right: 5,
                                                            bottom: 5,
                                                            child: InkWell(
                                                                onTap: () {
                                                                  startTripDataSnapshot
                                                                      .data!
                                                                      .tripStartInspection!
                                                                      .exteriorImageIDs![8] = '';
                                                                  startTripBloc
                                                                      .changedStartTripData
                                                                      .call(startTripDataSnapshot
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
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Interior car Cleanliness before the trip",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32)),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: CustomButton(
                                                title: 'POOR',
                                                isSelected: startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .interiorCleanliness ==
                                                    'Poor',
                                                press: () {
                                                  startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .interiorCleanliness =
                                                      'Poor';
                                                  startTripBloc
                                                      .changedStartTripData
                                                      .call(
                                                          startTripDataSnapshot
                                                              .data!);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              child: CustomButton(
                                                title: 'GOOD',
                                                isSelected: startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .interiorCleanliness ==
                                                    'Good',
                                                press: () {
                                                  startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .interiorCleanliness =
                                                      'Good';
                                                  startTripBloc
                                                      .changedStartTripData
                                                      .call(
                                                          startTripDataSnapshot
                                                              .data!);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              child: CustomButton(
                                                title: 'EXCELLENT',
                                                isSelected: startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .interiorCleanliness ==
                                                    'Excellent',
                                                press: () {
                                                  startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .interiorCleanliness =
                                                      'Excellent';
                                                  startTripBloc
                                                      .changedStartTripData
                                                      .call(
                                                          startTripDataSnapshot
                                                              .data!);
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Take photos of the car Interior",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
                                          ),
                                      GridView.count(
                                        primary: false,
                                        shrinkWrap: true,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                        crossAxisCount: 3,
                                        children: List.generate(6, (index) {
                                          String imageUrl = startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![index];
                                          bool isImageEmpty = imageUrl.isEmpty &&
                                              inspectionInfo.inspectionInfo!.startHost!.interiorImageIDs!.length <= index;

                                          return GestureDetector(
                                            onTap: () => _settingModalBottomSheet(context, 25 + index, startTripDataSnapshot),
                                            child: isImageEmpty
                                                ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(index == 0 ? 12.0 : 0),
                                                  bottomLeft: Radius.circular(index == 0 ? 12.0 : 0),
                                                  topRight: Radius.circular(index == 2 ? 12.0 : 0),
                                                  bottomRight: Radius.circular(index == 2 ? 12.0 : 0),
                                                ),
                                              ),
                                            )
                                                : Stack(
                                              children: <Widget>[
                                                SizedBox(
                                                  child: Image(
                                                    fit: BoxFit.fill,
                                                    image: NetworkImage('$storageServerUrl/${imageUrl.isNotEmpty ? imageUrl : inspectionInfo.inspectionInfo!.startHost!.interiorImageIDs![index]}'),
                                                  ),
                                                  width: double.maxFinite,
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),

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
                                                        28,
                                                        startTripDataSnapshot),
                                                child: startTripDataSnapshot
                                                            .data!
                                                            .tripStartInspection!
                                                            .interiorImageIDs![6] ==
                                                        ''
                                                    ? Container(
                                                        child: Image.asset(
                                                            'icons/Scan-Placeholder.png'),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFE0E0E0),
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topLeft:
                                                                const Radius
                                                                    .circular(
                                                                    12.0),
                                                            bottomLeft:
                                                                const Radius
                                                                    .circular(
                                                                    12.0),
                                                          ),
                                                        ),
                                                      )
                                                    : Stack(children: <Widget>[
                                                        SizedBox(
                                                            child: Image(
                                                              fit: BoxFit.fill,
                                                              image: NetworkImage(
                                                                  '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![6]}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: InkWell(
                                                              onTap: () {
                                                                startTripDataSnapshot
                                                                    .data!
                                                                    .tripStartInspection!
                                                                    .interiorImageIDs![6] = '';
                                                                startTripBloc
                                                                    .changedStartTripData
                                                                    .call(startTripDataSnapshot
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
                                                        29,
                                                        startTripDataSnapshot),
                                                child: startTripDataSnapshot
                                                            .data!
                                                            .tripStartInspection!
                                                            .interiorImageIDs![7] ==
                                                        ''
                                                    ? Container(
                                                        child: Image.asset(
                                                            'icons/Scan-Placeholder.png'),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFE0E0E0),
                                                        ),
                                                      )
                                                    : Stack(children: <Widget>[
                                                        SizedBox(
                                                            child: Image(
                                                              fit: BoxFit.fill,
                                                              image: NetworkImage(
                                                                  '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![7]}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: InkWell(
                                                              onTap: () {
                                                                startTripDataSnapshot
                                                                    .data!
                                                                    .tripStartInspection!
                                                                    .interiorImageIDs![7] = '';
                                                                startTripBloc
                                                                    .changedStartTripData
                                                                    .call(startTripDataSnapshot
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
                                                        30,
                                                        startTripDataSnapshot),
                                                child: startTripDataSnapshot
                                                            .data!
                                                            .tripStartInspection!
                                                            .interiorImageIDs![8] ==
                                                        ''
                                                    ? Container(
                                                        child: Image.asset(
                                                            'icons/Scan-Placeholder.png'),
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              Color(0xFFE0E0E0),
                                                          borderRadius:
                                                              new BorderRadius
                                                                  .only(
                                                            topRight:
                                                                const Radius
                                                                    .circular(
                                                                    12.0),
                                                                bottomRight:
                                                                const Radius
                                                                    .circular(
                                                                    12.0),
                                                          ),
                                                        ),
                                                      )
                                                    : Stack(children: <Widget>[
                                                        SizedBox(
                                                            child: Image(
                                                              fit: BoxFit.fill,
                                                              image: NetworkImage(
                                                                  '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![8]}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: InkWell(
                                                              onTap: () {
                                                                startTripDataSnapshot
                                                                    .data!
                                                                    .tripStartInspection!
                                                                    .interiorImageIDs![8] = '';
                                                                startTripBloc
                                                                    .changedStartTripData
                                                                    .call(startTripDataSnapshot
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
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Take photo(s) of the fuel gauge.',
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32),
                                          ),
                                        ),
                                        Text(
                                          "To capture fuel level",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xFF353B50)),
                                        ),
                                        Text(
                                            "Select the fuel level before the trip start.",
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xFF371D32),
                                            )),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .fuelLevel!
                                                        .isEmpty
                                                    ? fuelLevel ?? ''
                                                    : startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .fuelLevel!,
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32),
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                  canvasColor: Colors.white),
                                              child: DropdownButton(
                                                underline: SizedBox(),
                                                items: <String>[
                                                  '1/8',
                                                  '1/4',
                                                  '3/8',
                                                  '1/2',
                                                  '5/8',
                                                  '3/4',
                                                  '7/8',
                                                  'Full'
                                                ].map((String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(
                                                      value,
                                                      style: TextStyle(
                                                          fontFamily:
                                                              'Urbanist',
                                                          fontSize: 14,
                                                          color:
                                                              Color(0xFF371D32),
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .fuelLevel =
                                                      value as String?;
                                                  startTripBloc
                                                      .changedStartTripData
                                                      .call(
                                                          startTripDataSnapshot
                                                              .data!);
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          color: Colors.black,
                                        ),

                                        ///fuel gauge image
                                        GridView.count(
                                          primary: false,
                                          shrinkWrap: true,
                                          crossAxisSpacing: 1,
                                          mainAxisSpacing: 1,
                                          crossAxisCount: 3,
                                          children: <Widget>[
                                            GestureDetector(
                                              child: startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .dashboardImageIDs![
                                                              0] ==
                                                          '' &&
                                                      inspectionInfo
                                                              .inspectionInfo!
                                                              .startHost!
                                                              .fuelImageIDs!
                                                              .length <
                                                          1
                                                  ? Container(
                                                      child: Image.asset(
                                                          'icons/Scan-Placeholder.png'),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFE0E0E0),
                                                        borderRadius:
                                                            new BorderRadius
                                                                .only(
                                                          topLeft: const Radius
                                                              .circular(12.0),
                                                          bottomLeft:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                          topRight: const Radius
                                                              .circular(12.0),
                                                          bottomRight:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      width: 100,
                                                      height: 100,
                                                      decoration:
                                                          new BoxDecoration(
                                                        color:
                                                            Color(0xFFF2F2F2),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![0] != "" ? startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![0] : inspectionInfo.inspectionInfo!.startHost!.fuelImageIDs![0]}'),
                                                          fit: BoxFit.fill,
                                                        ),
                                                        borderRadius:
                                                            new BorderRadius
                                                                .only(
                                                          topLeft: const Radius
                                                              .circular(12.0),
                                                          bottomLeft:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                          topRight: const Radius
                                                              .circular(12.0),
                                                          bottomRight:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _settingModalBottomSheet(
                                                      context,
                                                      33,
                                                      startTripDataSnapshot),
                                              child: startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .fuelImageIDs![1] ==
                                                      ''
                                                  ? Container(
                                                      child: Image.asset(
                                                          'icons/Scan-Placeholder.png'),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFE0E0E0),
                                                        borderRadius:
                                                            new BorderRadius
                                                                .only(
                                                          topLeft: const Radius
                                                              .circular(12.0),
                                                          bottomLeft:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                          topRight: const Radius
                                                              .circular(12.0),
                                                          bottomRight:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                        ),
                                                      ),
                                                    )
                                                  : Stack(children: <Widget>[
                                                      SizedBox(
                                                          child: Image(
                                                            fit: BoxFit.fill,
                                                            image: NetworkImage(
                                                                '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![1]}'),
                                                          ),
                                                          width:
                                                              double.maxFinite),
                                                      Positioned(
                                                        right: 5,
                                                        bottom: 5,
                                                        child: InkWell(
                                                            onTap: () {
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .fuelImageIDs![1] = '';
                                                              startTripBloc
                                                                  .changedStartTripData
                                                                  .call(startTripDataSnapshot
                                                                      .data!);
                                                            },
                                                            child: CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                radius: 10,
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  color: Color(
                                                                      0xffF55A51),
                                                                  size: 20,
                                                                ))),
                                                      )
                                                    ]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.all(10.0),
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          'Take photo(s) of the odometer',
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32)),
                                        ),
                                        Text(
                                          "To capture mileage",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xFF353B50)),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                child: TextField(
                                              maxLength: 6,
                                              focusNode: _mileagefocusNode,
                                              onChanged: (mileage) {
                                                startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .mileage =
                                                    int.parse(
                                                        mileage.toString());
                                                startTripBloc
                                                    .changedStartTripData
                                                    .call(startTripDataSnapshot
                                                        .data!);
                                              },
                                              controller: _mileageController,
                                              decoration: InputDecoration(
                                                hintText: "Enter Mileage",
                                                hintStyle: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  // Adjust the font size as needed
                                                  color: Colors
                                                      .grey, // You can customize the color as well
                                                ),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            )),
                                            Column(
                                              children: [
                                                InkWell(
                                                  child:
                                                      Icon(Icons.arrow_drop_up),
                                                  onTap: () {
                                                    int tempMileage = int.parse(
                                                            _mileageController
                                                                .text
                                                                .toString()) +
                                                        100;
                                                    _mileageController.text =
                                                        tempMileage.toString();
                                                    _mileageController
                                                            .selection =
                                                        TextSelection.fromPosition(
                                                            TextPosition(
                                                                offset:
                                                                    _mileageController
                                                                        .text!
                                                                        .length));
                                                  },
                                                ),
                                                InkWell(
                                                  child: Icon(
                                                      Icons.arrow_drop_down),
                                                  onTap: () {
                                                    int tempMileage = int.parse(
                                                            _mileageController
                                                                .text
                                                                .toString()) -
                                                        100;
                                                    _mileageController.text =
                                                        tempMileage < 0
                                                            ? "0"
                                                            : tempMileage
                                                                .toString();
                                                    _mileageController
                                                            .selection =
                                                        TextSelection.fromPosition(
                                                            TextPosition(
                                                                offset:
                                                                    _mileageController
                                                                        .text!
                                                                        .length));
                                                  },
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        GridView.count(
                                          primary: false,
                                          shrinkWrap: true,
                                          crossAxisSpacing: 1,
                                          mainAxisSpacing: 1,
                                          crossAxisCount: 3,
                                          children: <Widget>[
                                            GestureDetector(
                                              child: startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .mileageImageIDs![
                                                              0] ==
                                                          '' &&
                                                      inspectionInfo
                                                              .inspectionInfo!
                                                              .startHost!
                                                              .mileageImageIDs!
                                                              .length <
                                                          1
                                                  ? Container(
                                                      child: Image.asset(
                                                          'icons/Scan-Placeholder.png'),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFE0E0E0),
                                                        borderRadius:
                                                            new BorderRadius
                                                                .only(
                                                          topLeft: const Radius
                                                              .circular(12.0),
                                                          bottomLeft:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                          topRight: const Radius
                                                              .circular(12.0),
                                                          bottomRight:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      width: 100,
                                                      height: 100,
                                                      decoration:
                                                          new BoxDecoration(
                                                        color:
                                                            Color(0xFFF2F2F2),
                                                        image: DecorationImage(
                                                          image: NetworkImage(
                                                              '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0] != '' ? startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0] : inspectionInfo.inspectionInfo!.startHost!.mileageImageIDs![0]}'),
                                                          fit: BoxFit.fill,
                                                        ),
                                                        borderRadius:
                                                            new BorderRadius
                                                                .only(
                                                          topLeft: const Radius
                                                              .circular(12.0),
                                                          bottomLeft:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                          topRight: const Radius
                                                              .circular(12.0),
                                                          bottomRight:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                        ),
                                                      ),
                                                    ),
                                            ),
                                            GestureDetector(
                                              onTap: () =>
                                                  _settingModalBottomSheet(
                                                      context,
                                                      34,
                                                      startTripDataSnapshot),
                                              child: startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .mileageImageIDs![1] ==
                                                      ''
                                                  ? Container(
                                                      child: Image.asset(
                                                          'icons/Scan-Placeholder.png'),
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFE0E0E0),
                                                        borderRadius:
                                                            new BorderRadius
                                                                .only(
                                                          topLeft: const Radius
                                                              .circular(12.0),
                                                          bottomLeft:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                          topRight: const Radius
                                                              .circular(12.0),
                                                          bottomRight:
                                                              const Radius
                                                                  .circular(
                                                                  12.0),
                                                        ),
                                                      ),
                                                    )
                                                  : Stack(children: <Widget>[
                                                      SizedBox(
                                                          child: Image(
                                                            fit: BoxFit.fill,
                                                            image: NetworkImage(
                                                                '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![1]}'),
                                                          ),
                                                          width:
                                                              double.maxFinite),
                                                      Positioned(
                                                        right: 5,
                                                        bottom: 5,
                                                        child: InkWell(
                                                            onTap: () {
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .mileageImageIDs![1] = '';
                                                              startTripBloc
                                                                  .changedStartTripData
                                                                  .call(startTripDataSnapshot
                                                                      .data!);
                                                            },
                                                            child: CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .white,
                                                                radius: 10,
                                                                child: Icon(
                                                                  Icons.delete,
                                                                  color: Color(
                                                                      0xffF55A51),
                                                                  size: 20,
                                                                ))),
                                                      )
                                                    ]),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Divider(),
                                  Divider(),
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
                                                  backgroundColor:
                                                      damageSelectionSnapshot
                                                                      .data ==
                                                                  1 ||
                                                              damageSelectionSnapshot
                                                                      .data ==
                                                                  2
                                                          ? Color(0xffFF8F68)
                                                          : Colors.grey,
                                                  padding: EdgeInsets.all(16.0),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8.0)),
                                                ),
                                                onPressed: damageSelectionSnapshot
                                                                .data ==
                                                            1 ||
                                                        damageSelectionSnapshot
                                                                .data ==
                                                            2
                                                    ? () async {
                                                        var res2 =
                                                            await startTripBloc
                                                                .startTripMethod({
                                                          "IsNoticibleDamage":
                                                              damageSelectionSnapshot
                                                                          .data ==
                                                                      1
                                                                  ? false
                                                                  : true,
                                                          "DamageDesctiption":
                                                              "",
                                                          "DamageImageIDs":
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .damageImageIDs,
                                                          "ExteriorCleanliness":
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .exteriorCleanliness,
                                                          "ExteriorImageIDs":
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .exteriorImageIDs,
                                                          "InteriorCleanliness":
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .interiorCleanliness,
                                                          "InteriorImageIDs":
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .interiorImageIDs,
                                                          "FuelLevel":
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .fuelLevel,
                                                          "Mileage":
                                                              _mileageController
                                                                  .text,
                                                          "FuelImageIDs":
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .fuelImageIDs,
                                                          "MileageImageIDs":
                                                              startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .mileageImageIDs,
                                                          "TripID": tripDetails
                                                              .tripID,
                                                          "InspectionByUserID":
                                                              tripDetails
                                                                  .guestUserID
                                                        });


                                                        print(
                                                            "tripinspectionInfo$res2");

                                                        if (res2 != null && res2
                                                            .status!.success!) {
                                                          AppEventsUtils.logEvent(
                                                              "trip_start_successful",
                                                              params: {
                                                                "trip_id":
                                                                tripDetails
                                                                    .tripID,
                                                                "start_date": tripDetails.startDateTime?.toIso8601String(),
                                                                "end_date": tripDetails.endDateTime?.toIso8601String(),
                                                                "car_id": tripDetails
                                                                    .car!.iD,
                                                                "car_name":tripDetails
                                                                    .car!
                                                                    .about!
                                                                    .make! +
                                                                    ' ' +
                                                                    tripDetails
                                                                        .car!
                                                                        .about!
                                                                        .model!,
                                                                "car_trips":tripDetails
                                                                    .car!
                                                                    .numberOfTrips,
                                                                "car_rating":tripDetails
                                                                    .car!
                                                                    .rating,
                                                                "location": tripDetails.location,
                                                                "host_rating": tripDetails.hostProfile!.profileRating!.toStringAsFixed(1),
                                                                "host_trips": tripDetails.hostProfile!.numberOfTrips,
                                                              });
                                                          Navigator.pushNamed(
                                                            context,
                                                            '/trip_started',
                                                            arguments:
                                                                tripDetails,
                                                          );
                                                        }
                                                        startTripAfterInspection(
                                                            tripDetails
                                                                .tripID!);
                                                      }
                                                    : () {
                                                        print(
                                                            "trip cant be started");
                                                      },
                                                child: Text(
                                                  'Start Trip',
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
                                  SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                  : Container();
            },
          )),
    );
  }
}
