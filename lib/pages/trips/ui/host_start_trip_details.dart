import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/start_trip_inspection_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/inspection_info_response.dart';
import 'package:ridealike/pages/trips/response_model/start_trip_inspect_rental_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/custom_buttom.dart';

class HostStartTripDetails extends StatefulWidget {
  @override
  State createState() => HostStartTripDetailsState();
}

class HostStartTripDetailsState extends State<HostStartTripDetails> {
  final startTripBloc = StartTripBloc();

  TextEditingController _mileageController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

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
                  onTap: () {},
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
                  onTap: () {},
                ),
                Divider(color: Color(0xFFABABAB)),
              ],
            ),
          );
        });
  }

  var receivedData;
  Trips? tripDetails;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Host Start Trip Details"});
  }

  @override
  Widget build(BuildContext context) {
    final receivedData = ModalRoute.of(context)!.settings.arguments as Map;

    Trips tripDetails = receivedData["tripsData"];
    InspectionInfo inspectionInfo = receivedData['inspectionData'];
    String fuelLevel = inspectionInfo.inspectionInfo!.startHost!.fuelLevel!;
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
                dashboardImageIDs: List.filled(2, ''),
                damageDesctiption: "",
                fuelImageIDs: List.filled(1, ''),
                fuelLevel: "",
                mileageImageIDs: List.filled(1, ''),
                inspectionByUserID: tripDetails.userID,
                tripID: tripDetails.tripID));
    startTripBloc.changedStartTripData.call(inspectTripStartResponse);
    startTripBloc.changedDamageSelection.call(
        inspectionInfo.inspectionInfo!.startHost!.isNoticibleDamage! ? 2 : 1);
    _mileageController.text =
        inspectionInfo.inspectionInfo!.startHost!.mileage.toString();
    _descriptionController.text =
        inspectionInfo.inspectionInfo!.startHost!.damageDesctiption!;
    return Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<InspectTripStartResponse>(
          stream: startTripBloc.startTripData,
          builder: (context, startTripDataSnapshot) {
            return startTripDataSnapshot.hasData &&
                    startTripDataSnapshot.data != null
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
                                      "Host Start Trip Details",
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 28,
                                          color: Color(0xFF371D32),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Center(
                                      child: (tripDetails.carImageId != null ||
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
                                                      .isNoticibleDamage = true;
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
                                                                  .damageImageIDs![
                                                              0] ==
                                                          '' &&
                                                      inspectionInfo
                                                              .inspectionInfo!
                                                              .startHost!
                                                              .damageImageIDs!
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
                                                        ),
                                                      ),
                                                    )
                                                  : Stack(children: <Widget>[
                                                      SizedBox(
                                                          child: Image(
                                                            fit: BoxFit.fill,
                                                            image: NetworkImage(
                                                                '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![0] != '' ? startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![0] : inspectionInfo.inspectionInfo!.startHost!.damageImageIDs![0]}'),
                                                          ),
                                                          width:
                                                              double.maxFinite),
                                                      Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: Container())
                                                    ]),
                                            ),
                                            GestureDetector(
                                                child: startTripDataSnapshot
                                                                    .data!
                                                                    .tripStartInspection!
                                                                    .damageImageIDs![
                                                                1] ==
                                                            '' &&
                                                        inspectionInfo
                                                                .inspectionInfo!
                                                                .startHost!
                                                                .damageImageIDs!
                                                                .length <
                                                            2
                                                    ? Container(
                                                        child: Image.asset(
                                                            'icons/Scan-Placeholder.png'),
                                                        color:
                                                            Color(0xFFE0E0E0),
                                                      )
                                                    : Stack(children: <Widget>[
                                                        SizedBox(
                                                            child: Image(
                                                              fit: BoxFit.fill,
                                                              image: NetworkImage(
                                                                  '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![1] != '' ? startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![1] : inspectionInfo.inspectionInfo!.startHost!.damageImageIDs![1]}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: Container(),
                                                        )
                                                      ])),
                                            GestureDetector(
                                                child: startTripDataSnapshot
                                                                    .data!
                                                                    .tripStartInspection!
                                                                    .damageImageIDs![
                                                                2] ==
                                                            '' &&
                                                        inspectionInfo
                                                                .inspectionInfo!
                                                                .startHost!
                                                                .damageImageIDs!
                                                                .length <
                                                            3
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
                                                                  '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2] != '' ? startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2] : inspectionInfo.inspectionInfo!.startHost!.damageImageIDs![2]}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: Container(),
                                                        )
                                                      ])
//
                                                ),
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
                                          controller: _descriptionController,
                                          textInputAction: TextInputAction.done,
                                          maxLines: 5,
                                          enabled:
                                              damageSelectionSnapshot.data == 2,
                                          onChanged: (description) {},
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
                                                    .call(startTripDataSnapshot
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
                                                    .call(startTripDataSnapshot
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
                                                    .call(startTripDataSnapshot
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
                                          children: <Widget>[
                                            GestureDetector(
                                              child: startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .exteriorImageIDs![
                                                              0] ==
                                                          '' &&
                                                      inspectionInfo
                                                              .inspectionInfo!
                                                              .startHost!
                                                              .exteriorImageIDs!
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
                                                        ),
                                                      ),
                                                    )
                                                  : Stack(children: <Widget>[
                                                      SizedBox(
                                                          child: Image(
                                                            fit: BoxFit.fill,
                                                            image: NetworkImage(
                                                                '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![0] != '' ? startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![0] : inspectionInfo.inspectionInfo!.startHost!.exteriorImageIDs![0]}'),
                                                          ),
                                                          width:
                                                              double.maxFinite),
                                                      Positioned(
                                                        right: 5,
                                                        bottom: 5,
                                                        child: Container(),
                                                      )
                                                    ]),
                                            ),
                                            GestureDetector(
                                                child: startTripDataSnapshot
                                                                    .data!
                                                                    .tripStartInspection!
                                                                    .exteriorImageIDs![
                                                                1] ==
                                                            '' &&
                                                        inspectionInfo
                                                                .inspectionInfo!
                                                                .startHost!
                                                                .exteriorImageIDs!
                                                                .length <
                                                            2
                                                    ? Container(
                                                        child: Image.asset(
                                                            'icons/Scan-Placeholder.png'),
                                                        color:
                                                            Color(0xFFE0E0E0),
                                                      )
                                                    : Stack(children: <Widget>[
                                                        SizedBox(
                                                            child: Image(
                                                              fit: BoxFit.fill,
                                                              image: NetworkImage(
                                                                  '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![1] != '' ? startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![1] : inspectionInfo.inspectionInfo!.startHost!.exteriorImageIDs![1]}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: Container(),
                                                        )
                                                      ])),
                                            GestureDetector(
                                                child: startTripDataSnapshot
                                                                    .data!
                                                                    .tripStartInspection!
                                                                    .exteriorImageIDs![
                                                                2] ==
                                                            '' &&
                                                        inspectionInfo
                                                                .inspectionInfo!
                                                                .startHost!
                                                                .exteriorImageIDs!
                                                                .length <
                                                            3
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
                                                                  '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![2] != '' ? startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![2] : inspectionInfo.inspectionInfo!.startHost!.exteriorImageIDs![2]}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: Container(),
                                                        )
                                                      ])
//
                                                ),
//                                         GestureDetector(
//                                             onTap: () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 16,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .exteriorImageIDs![3] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.exteriorImageIDs
//                                                     !.length < 4 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFE0E0E0),
//                                                 borderRadius: new BorderRadius
//                                                     .only(
//                                                   topLeft: const Radius
//                                                       .circular(12.0),
//                                                   bottomLeft: const Radius
//                                                       .circular(12.0),
//                                                 ),
//                                               ),
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![3] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![3]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .exteriorImageIDs![3]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
//                                         GestureDetector(
//                                             onTap: () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 17,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .exteriorImageIDs![4] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.exteriorImageIDs
//                                                     !.length < 5 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               color: Color(0xFFE0E0E0),
//
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![4] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![4]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .exteriorImageIDs![4]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //                                      Container(
// //                                        alignment: Alignment.bottomCenter,
// //                                        width: 100,
// //                                        height: 100,
// //                                        decoration: new BoxDecoration(
// //                                          color: Color(0xFFF2F2F2),
// //                                          image: DecorationImage(
// //                                            image: NetworkImage('https://api.storage.ridealike.anexa.dev/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2]}'),
// //                                            fit: BoxFit.fill,
// //                                          ),
// //                                          borderRadius: new BorderRadius.only(
// //                                            topRight: const Radius.circular(12.0),
// //                                            bottomRight: const Radius.circular(12.0),
// //                                          ),
// //                                        ),
// //                                      ),
//                                         ),
//                                         GestureDetector(
//                                             onTap: () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 18,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .exteriorImageIDs![5] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.exteriorImageIDs
//                                                     !.length < 6 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFE0E0E0),
//                                                 borderRadius: new BorderRadius
//                                                     .only(
//                                                   topRight: const Radius
//                                                       .circular(12.0),
//                                                   bottomRight: const Radius
//                                                       .circular(12.0),
//                                                 ),
//                                               ),
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![5] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![5]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .exteriorImageIDs![5]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
//                                         GestureDetector(
//                                             onTap: () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 19,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .exteriorImageIDs![6] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.exteriorImageIDs
//                                                     !.length < 7 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFE0E0E0),
//                                                 borderRadius: new BorderRadius
//                                                     .only(
//                                                   topLeft: const Radius
//                                                       .circular(12.0),
//                                                   bottomLeft: const Radius
//                                                       .circular(12.0),
//                                                 ),
//                                               ),
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![6] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![6]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .exteriorImageIDs![6]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
//                                         GestureDetector(
//                                             onTap: () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 20,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .exteriorImageIDs![7] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.exteriorImageIDs
//                                                     !.length < 8 ? Container(
//                                                 child: Image.asset(
//                                                     'icons/Scan-Placeholder.png'),
//                                                 color: Color(0xFFE0E0E0)
//
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![7] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![7]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .exteriorImageIDs![7]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
//                                         GestureDetector(
//                                             onTap: () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 21,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .exteriorImageIDs![8] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.exteriorImageIDs
//                                                     !.length < 9 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFE0E0E0),
//                                                 borderRadius: new BorderRadius
//                                                     .only(
//                                                   topRight: const Radius
//                                                       .circular(12.0),
//                                                   bottomRight: const Radius
//                                                       .circular(12.0),
//                                                 ),
//                                               ),
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![8] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .exteriorImageIDs![8]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .exteriorImageIDs![8]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
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
                                                    .call(startTripDataSnapshot
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
                                                    .call(startTripDataSnapshot
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
                                                    .call(startTripDataSnapshot
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
                                          children: <Widget>[
                                            GestureDetector(
                                              child: startTripDataSnapshot
                                                                  .data!
                                                                  .tripStartInspection!
                                                                  .interiorImageIDs![
                                                              0] ==
                                                          '' &&
                                                      inspectionInfo
                                                              .inspectionInfo!
                                                              .startHost!
                                                              .interiorImageIDs!
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
                                                        ),
                                                      ),
                                                    )
                                                  : Stack(children: <Widget>[
                                                      SizedBox(
                                                          child: Image(
                                                            fit: BoxFit.fill,
                                                            image: NetworkImage(
                                                                '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![0] != '' ? startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![0] : inspectionInfo.inspectionInfo!.startHost!.interiorImageIDs![0]}'),
                                                          ),
                                                          width:
                                                              double.maxFinite),
                                                      Positioned(
                                                        right: 5,
                                                        bottom: 5,
                                                        child: Container(),
                                                      )
                                                    ]),
                                            ),
                                            GestureDetector(
                                                child: startTripDataSnapshot
                                                                    .data!
                                                                    .tripStartInspection!
                                                                    .interiorImageIDs![
                                                                1] ==
                                                            '' &&
                                                        inspectionInfo
                                                                .inspectionInfo!
                                                                .startHost!
                                                                .interiorImageIDs!
                                                                .length <
                                                            2
                                                    ? Container(
                                                        child: Image.asset(
                                                            'icons/Scan-Placeholder.png'),
                                                        color:
                                                            Color(0xFFE0E0E0),
                                                      )
                                                    : Stack(children: <Widget>[
                                                        SizedBox(
                                                            child: Image(
                                                              fit: BoxFit.fill,
                                                              image: NetworkImage(
                                                                  '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![1] != '' ? startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![1] : inspectionInfo.inspectionInfo!.startHost!.interiorImageIDs![1]}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: Container(),
                                                        )
                                                      ])),
                                            GestureDetector(
                                                child: startTripDataSnapshot
                                                                    .data!
                                                                    .tripStartInspection!
                                                                    .interiorImageIDs![
                                                                2] ==
                                                            '' &&
                                                        inspectionInfo
                                                                .inspectionInfo!
                                                                .startHost!
                                                                .interiorImageIDs!
                                                                .length <
                                                            3
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
                                                                  '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![2] != '' ? startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![2] : inspectionInfo.inspectionInfo!.startHost!.interiorImageIDs![2]}'),
                                                            ),
                                                            width: double
                                                                .maxFinite),
                                                        Positioned(
                                                          right: 5,
                                                          bottom: 5,
                                                          child: Container(),
                                                        )
                                                      ])
//
                                                ),
//                                         GestureDetector(
//                                             onTap: damageSelectionSnapshot
//                                                 .data != 1 &&
//                                                 damageSelectionSnapshot.data !=
//                                                     2
//                                                 ? () => {}
//                                                 : () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 25,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .interiorImageIDs![3] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.interiorImageIDs
//                                                     !.length < 4 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFE0E0E0),
//                                                 borderRadius: new BorderRadius
//                                                     .only(
//                                                   topLeft: const Radius
//                                                       .circular(12.0),
//                                                   bottomLeft: const Radius
//                                                       .circular(12.0),
//                                                 ),
//                                               ),
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![3] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![3]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .interiorImageIDs![3]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
//                                         GestureDetector(
//                                             onTap: damageSelectionSnapshot
//                                                 .data != 1 &&
//                                                 damageSelectionSnapshot.data !=
//                                                     2
//                                                 ? () => {}
//                                                 : () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 26,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .interiorImageIDs![4] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.interiorImageIDs
//                                                     !.length < 5 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               color: Color(0xFFE0E0E0),
//
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![4] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![4]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .interiorImageIDs![4]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //                                      Container(
// //                                        alignment: Alignment.bottomCenter,
// //                                        width: 100,
// //                                        height: 100,
// //                                        decoration: new BoxDecoration(
// //                                          color: Color(0xFFF2F2F2),
// //                                          image: DecorationImage(
// //                                            image: NetworkImage('https://api.storage.ridealike.anexa.dev/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2]}'),
// //                                            fit: BoxFit.fill,
// //                                          ),
// //                                          borderRadius: new BorderRadius.only(
// //                                            topRight: const Radius.circular(12.0),
// //                                            bottomRight: const Radius.circular(12.0),
// //                                          ),
// //                                        ),
// //                                      ),
//                                         ),
//                                         GestureDetector(
//                                             onTap: damageSelectionSnapshot
//                                                 .data != 1 &&
//                                                 damageSelectionSnapshot.data !=
//                                                     2
//                                                 ? () => {}
//                                                 : () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 27,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .interiorImageIDs![5] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.interiorImageIDs
//                                                     !.length < 6 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFE0E0E0),
//                                                 borderRadius: new BorderRadius
//                                                     .only(
//                                                   topRight: const Radius
//                                                       .circular(12.0),
//                                                   bottomRight: const Radius
//                                                       .circular(12.0),
//                                                 ),
//                                               ),
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![5] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![5]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .interiorImageIDs![5]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
//                                         GestureDetector(
//                                             onTap:() =>
//                                                 _settingModalBottomSheet(
//                                                     context, 28,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .interiorImageIDs![6] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.interiorImageIDs
//                                                     !.length < 7 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFE0E0E0),
//                                                 borderRadius: new BorderRadius
//                                                     .only(
//                                                   topLeft: const Radius
//                                                       .circular(12.0),
//                                                   bottomLeft: const Radius
//                                                       .circular(12.0),
//                                                 ),
//                                               ),
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![6] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![6]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .interiorImageIDs![6]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
//                                         GestureDetector(
//                                             onTap: damageSelectionSnapshot
//                                                 .data != 1 &&
//                                                 damageSelectionSnapshot.data !=
//                                                     2
//                                                 ? () => {}
//                                                 : () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 29,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .interiorImageIDs![7] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.interiorImageIDs
//                                                     !.length < 8 ? Container(
//                                                 child: Image.asset(
//                                                     'icons/Scan-Placeholder.png'),
//                                                 color: Color(0xFFE0E0E0)
//
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![7] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![7]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .interiorImageIDs![7]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
//                                         GestureDetector(
//                                             onTap: damageSelectionSnapshot
//                                                 .data != 1 &&
//                                                 damageSelectionSnapshot.data !=
//                                                     2
//                                                 ? () => {}
//                                                 : () =>
//                                                 _settingModalBottomSheet(
//                                                     context, 30,
//                                                     startTripDataSnapshot),
//                                             child: startTripDataSnapshot.data
//                                                 .tripStartInspection
//                                                 .interiorImageIDs![8] == '' &&
//                                                 inspectionInfo.inspectionInfo
//                                                     !.startHost!.interiorImageIDs
//                                                     !.length < 9 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration: BoxDecoration(
//                                                 color: Color(0xFFE0E0E0),
//                                                 borderRadius: new BorderRadius
//                                                     .only(
//                                                   topRight: const Radius
//                                                       .circular(12.0),
//                                                   bottomRight: const Radius
//                                                       .circular(12.0),
//                                                 ),
//                                               ),
//                                             ) :
//                                             Stack(
//                                                 children: <Widget>[
//                                                   SizedBox(
//                                                       child: Image(
//                                                         fit: BoxFit.fill, image:
//                                                       NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![8] !=
//                                                               ''
//                                                               ? startTripDataSnapshot
//                                                               .data
//                                                               .tripStartInspection
//                                                               .interiorImageIDs![8]
//                                                               : inspectionInfo
//                                                               .inspectionInfo
//                                                               !.startHost!
//                                                               .interiorImageIDs![8]}'),),
//                                                       width: double.maxFinite),
//                                                   Positioned(
//                                                     right: 5, bottom: 5,
//                                                     child: Container(),)
//
//                                                 ]
//                                             )
// //
//                                         ),
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
                                            color: Color(0xFF371D32)),
                                      ),
                                      Text(
                                        "To capture fuel level",
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50)),
                                      ),
                                      Text(
                                          "Select the fuel level before the trip start."),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(startTripDataSnapshot
                                                      .data!
                                                      .tripStartInspection!
                                                      .fuelLevel ==
                                                  ""
                                              ? fuelLevel
                                              : startTripDataSnapshot
                                                  .data!
                                                  .tripStartInspection!
                                                  .fuelLevel!),
                                          DropdownButton(
                                            underline: SizedBox(),
                                            items:
                                                <String>[].map((String value) {
                                              return DropdownMenuItem<String>(
                                                value: value,
                                                child: Text(value),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              startTripDataSnapshot
                                                  .data!
                                                  .tripStartInspection!
                                                  .fuelLevel = value as String?;
                                              startTripBloc.changedStartTripData
                                                  .call(startTripDataSnapshot
                                                      .data!);
                                            },
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        color: Colors.black,
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
                                                    31,
                                                    startTripDataSnapshot),
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
                                                      color: Color(0xFFE0E0E0),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(12.0),
                                                        bottomLeft: const Radius
                                                            .circular(12.0),
                                                        topRight: const Radius
                                                            .circular(12.0),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(12.0),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    width: 100,
                                                    height: 100,
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Color(0xFFF2F2F2),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![0] != "" ? startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![0] : inspectionInfo.inspectionInfo!.startHost!.fuelImageIDs![0]}'),
                                                        fit: BoxFit.fill,
                                                      ),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(12.0),
                                                        bottomLeft: const Radius
                                                            .circular(12.0),
                                                        topRight: const Radius
                                                            .circular(12.0),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(12.0),
                                                      ),
                                                    ),
                                                  ),
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
                                            enabled: false,
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
                                            keyboardType: TextInputType.number,
                                          )),
                                          Column(
                                            children: [
                                              InkWell(
                                                child:
                                                    Icon(Icons.arrow_drop_up),
                                                onTap: () {},
                                              ),
                                              InkWell(
                                                child:
                                                    Icon(Icons.arrow_drop_down),
                                                onTap: () {},
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
                                            onTap: () =>
                                                _settingModalBottomSheet(
                                                    context,
                                                    32,
                                                    startTripDataSnapshot),
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
                                                      color: Color(0xFFE0E0E0),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(12.0),
                                                        bottomLeft: const Radius
                                                            .circular(12.0),
                                                        topRight: const Radius
                                                            .circular(12.0),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(12.0),
                                                      ),
                                                    ),
                                                  )
                                                : Container(
                                                    alignment:
                                                        Alignment.bottomCenter,
                                                    width: 100,
                                                    height: 100,
                                                    decoration:
                                                        new BoxDecoration(
                                                      color: Color(0xFFF2F2F2),
                                                      image: DecorationImage(
                                                        image: NetworkImage(
                                                            '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0] != '' ? startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0] : inspectionInfo.inspectionInfo!.startHost!.mileageImageIDs![0]}'),
                                                        fit: BoxFit.fill,
                                                      ),
                                                      borderRadius:
                                                          new BorderRadius.only(
                                                        topLeft: const Radius
                                                            .circular(12.0),
                                                        bottomLeft: const Radius
                                                            .circular(12.0),
                                                        topRight: const Radius
                                                            .circular(12.0),
                                                        bottomRight:
                                                            const Radius
                                                                .circular(12.0),
                                                      ),
                                                    ),
                                                  ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Divider(),
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                      );
                    })
                : Container();
          },
        ));
  }
}
