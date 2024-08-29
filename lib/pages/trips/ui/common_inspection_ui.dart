import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/host_start_trip_inspection_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/host_start_inspect_rental_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/custom_buttom.dart';

final storage = new FlutterSecureStorage();



class CommonInspectionUI extends StatefulWidget {
  @override
  State createState() => CommonInspectionUIState();
}

class CommonInspectionUIState extends State<CommonInspectionUI> {
  final startTripBloc = HostStartTripBloc();
  String fuelLevel = "Select the suitable option";

  int mileage = 0;
  String? damageDesctiption;

  TextEditingController mileageController = TextEditingController();
  TextEditingController _damagedescriptionController = TextEditingController();
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
      AsyncSnapshot<HostInspectTripStartResponse> startTripDataSnapshot) {
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
                                  fontFamily: 'SFProDisplayRegular',
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
                      fontFamily: 'SFProDisplayRegular',
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
                      fontFamily: 'SFProDisplayRegular',
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
        params: {"page_name": "Common Inspection"});
  }

  @override
  Widget build(BuildContext context) {
    final receivedData = ModalRoute.of(context)!.settings.arguments;
    Trips? tripDetails = receivedData! as Trips?;
    HostInspectTripStartResponse inspectTripStartResponse =
        HostInspectTripStartResponse(
            tripStartInspection: TripStartInspection(
                damageDesctiption: damageDesctiption,
                fuelLevel: '',
                mileage: 0,
                exteriorCleanliness: '',
                interiorImageIDs: List.filled(6, ''),
                interiorCleanliness: '',
                damageImageIDs: List.filled(12, ''),
                exteriorImageIDs: List.filled(6, ''),
                dashboardImageIDs: List.filled(14, ''),
                fuelImageIDs: List.filled(2, ''),
                mileageImageIDs: List.filled(2, ''),
                inspectionByUserID: tripDetails!.userID,
                tripID: tripDetails!.tripID));
    startTripBloc.changedStartTripData.call(inspectTripStartResponse);
    startTripBloc.changedDamageSelection.call(0);

    return GestureDetector(
      onTap: _handleTapOutside,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<HostInspectTripStartResponse>(
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
                                              fontFamily: 'SFProDisplayRegular',
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
                                        child: (tripDetails!.carImageId !=
                                                    null ||
                                                tripDetails!.carImageId != '')
                                            ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    '$storageServerUrl/${tripDetails!.carImageId}'),
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
                                          Row(
                                            children: [
                                              Text(
                                                "Any noticeable damage before the trip?",
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32)),
                                              ),
                                              Text(' *', style: TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.red),)
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            "Inspect vehicle's inside and outside for any visual damage, like dents, scratches or broken parts.",
                                            style: TextStyle(
                                                fontFamily: 'OpenSans',
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
                                          Row(
                                            children: [
                                              Text(
                                                "Take photos of car if any damages",
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32)),
                                              ),
                                              Text(' *', style: TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.red),)
                                            ],
                                          ),
                                          GridView.count(
                                            primary: false,
                                            shrinkWrap: true,
                                            crossAxisSpacing: 1,
                                            mainAxisSpacing: 1,
                                            crossAxisCount: 3,
                                            children: List.generate(6, (index) {
                                              return GestureDetector(
                                                onTap: () => _settingModalBottomSheet(
                                                  context,
                                                  index + 1,
                                                  startTripDataSnapshot,
                                                ),
                                                child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![index] == ''
                                                    ? Container(
                                                  child: Image.asset('icons/Scan-Placeholder.png'),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFE0E0E0),
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(index == 0 || index == 3 ? 12.0 : 0.0),
                                                      bottomLeft: Radius.circular(index == 0 || index == 3 ? 12.0 : 0.0),
                                                      topRight: Radius.circular(index == 2 || index == 5 ? 12.0 : 0.0),
                                                      bottomRight: Radius.circular(index == 2 || index == 5 ? 12.0 : 0.0),
                                                    ),
                                                  ),
                                                )
                                                    : Stack(
                                                  children: <Widget>[
                                                    SizedBox(
                                                      child: Image(
                                                        fit: BoxFit.fill,
                                                        image: NetworkImage(
                                                          '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![index]}',
                                                        ),
                                                      ),
                                                      width: double.maxFinite,
                                                    ),
                                                    Positioned(
                                                      right: 5,
                                                      bottom: 5,
                                                      child: InkWell(
                                                        onTap: () {
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![index] = '';
                                                          startTripBloc.changedStartTripData.call(startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors.white,
                                                          radius: 10,
                                                          child: Icon(
                                                            Icons.delete,
                                                            color: Color(0xffF55A51),
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          )

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
                                            controller:
                                                _damagedescriptionController,
                                            textInputAction:
                                                TextInputAction.done,
                                            maxLines: 5,
                                            enabled:
                                                damageSelectionSnapshot.data ==
                                                    2,
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Add a description here',
                                                hintStyle: TextStyle(
                                                  fontFamily:
                                                      'Urbanist',
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
                                        Row(
                                          children: [
                                            Text(
                                              "Exterior car Cleanliness before the trip",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32)),
                                            ),
                                            Text(' *', style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.red),)
                                          ],
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
                                              return GestureDetector(
                                                onTap: () => _settingModalBottomSheet(
                                                  context,
                                                  index + 13,
                                                  startTripDataSnapshot,
                                                ),
                                                child: startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![index] == ''
                                                    ? Container(
                                                  child: Image.asset('icons/Scan-Placeholder.png'),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFE0E0E0),
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(index == 0 || index == 3 ? 12.0 : 0.0),
                                                      bottomLeft: Radius.circular(index == 0 || index == 3 ? 12.0 : 0.0),
                                                      topRight: Radius.circular(index == 2 || index == 5 ? 12.0 : 0.0),
                                                      bottomRight: Radius.circular(index == 2 || index == 5 ? 12.0 : 0.0),
                                                    ),
                                                  ),
                                                )
                                                    : Stack(
                                                  children: <Widget>[
                                                    SizedBox(
                                                      child: Image(
                                                        fit: BoxFit.fill,
                                                        image: NetworkImage(
                                                          '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![index]}',
                                                        ),
                                                      ),
                                                      width: double.maxFinite,
                                                    ),
                                                    Positioned(
                                                      right: 5,
                                                      bottom: 5,
                                                      child: InkWell(
                                                        onTap: () {
                                                          startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![index] = '';
                                                          startTripBloc.changedStartTripData.call(startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors.white,
                                                          radius: 10,
                                                          child: Icon(
                                                            Icons.delete,
                                                            color: Color(0xffF55A51),
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          )

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
                                        Row(
                                          children: [
                                            Text(
                                              "Interior car Cleanliness before the trip",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32)),
                                            ),
                                            Text(' *', style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.red),)
                                          ],
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
                                          Row(
                                            children: [
                                              Text(
                                                "Take photos of the car Interior",
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32)),
                                              ),
                                              Text(' *', style: TextStyle(
                                                  fontSize: 22,
                                                  color: Colors.red),)
                                            ],
                                          ),
                                          GridView.count(
                                            primary: false,
                                            shrinkWrap: true,
                                            crossAxisSpacing: 1,
                                            mainAxisSpacing: 1,
                                            crossAxisCount: 3,
                                            children: List.generate(6, (index) {
                                              return GestureDetector(
                                                onTap: () => _settingModalBottomSheet(
                                                  context,
                                                  index + 22,
                                                  startTripDataSnapshot,
                                                ),
                                                child: startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![index] == ''
                                                    ? Container(
                                                  child: Image.asset('icons/Scan-Placeholder.png'),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFE0E0E0),
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(index == 0 ? 12.0 : 0.0),
                                                      bottomLeft: Radius.circular(index == 0 ? 12.0 : 0.0),
                                                      topRight: Radius.circular(index == 2 ? 12.0 : 0.0),
                                                      bottomRight: Radius.circular(index == 2 ? 12.0 : 0.0),
                                                    ),
                                                  ),
                                                )
                                                    : Stack(
                                                  children: <Widget>[
                                                    SizedBox(
                                                      child: Image(
                                                        fit: BoxFit.fill,
                                                        image: NetworkImage(
                                                          '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![index]}',
                                                        ),
                                                      ),
                                                      width: double.maxFinite,
                                                    ),
                                                    Positioned(
                                                      right: 5,
                                                      bottom: 5,
                                                      child: InkWell(
                                                        onTap: () {
                                                          startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![index] = '';
                                                          startTripBloc.changedStartTripData.call(startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(
                                                          backgroundColor: Colors.white,
                                                          radius: 10,
                                                          child: Icon(
                                                            Icons.delete,
                                                            color: Color(0xffF55A51),
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                          )

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
                                        Row(
                                          children: [
                                            Text(
                                              'Take photo(s) of the fuel gauge.',
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32)),
                                            ),
                                            Text(' *', style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.red),)
                                          ],
                                        ),
                                        Text(
                                          "To capture fuel level",
                                          style: TextStyle(
                                              fontFamily: 'OpenSans',
                                              fontSize: 14,
                                              color: Color(0xFF353B50)),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                                "Select the fuel level before the trip start.", style: TextStyle(
                                                fontFamily: 'OpenSans',
                                                fontSize: 14,
                                                color: Color(0xFF353B50))),
                                            Text(' *', style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.red),)
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(startTripDataSnapshot
                                                        .data!
                                                        .tripStartInspection!
                                                        .fuelLevel ==
                                                    ''
                                                ? fuelLevel
                                                : startTripDataSnapshot
                                                    .data!
                                                    .tripStartInspection!
                                                    .fuelLevel!,  style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.black,
                                              fontFamily: 'Urbanist',
                                            ),),
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
                                                        fontSize:
                                                            13,
                                                        fontFamily: 'Urbanist'
                                                      ),
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
                                                          .fuelImageIDs![0] ==
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
                                                                '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![0]}'),
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
                                                                  .fuelImageIDs![0] = '';
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
                                        Row(
                                          children: [
                                            Text(
                                              'Take photo(s) of the odometer',
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32)),
                                            ),
                                            Text(' *', style: TextStyle(
                                                fontSize: 22,
                                                color: Colors.red),)
                                          ],
                                        ),
                                        Text(
                                          "To capture mileage",
                                          style: TextStyle(
                                              fontFamily: 'OpenSans',
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
                                              focusNode: _mileagefocusNode,
                                              controller: mileageController,
                                              decoration: InputDecoration(
                                                hintText: "Enter Mileage ",
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
                                                            mileageController
                                                                .text
                                                                .toString()) +
                                                        100;
                                                    mileageController.text =
                                                        tempMileage.toString();
                                                    mileageController
                                                            .selection =
                                                        TextSelection.fromPosition(
                                                            TextPosition(
                                                                offset:
                                                                    mileageController
                                                                        .text
                                                                        .length));
                                                  },
                                                ),
                                                InkWell(
                                                  child: Icon(
                                                      Icons.arrow_drop_down),
                                                  onTap: () {
                                                    int tempMileage = int.parse(
                                                            mileageController
                                                                .text
                                                                .toString()) -
                                                        100;
                                                    mileageController.text =
                                                        tempMileage.toString();
                                                    mileageController
                                                            .selection =
                                                        TextSelection.fromPosition(
                                                            TextPosition(
                                                                offset:
                                                                    mileageController
                                                                        .text
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
                                              onTap: () =>
                                                  _settingModalBottomSheet(
                                                      context,
                                                      32,
                                                      startTripDataSnapshot),
                                              child: startTripDataSnapshot
                                                          .data!
                                                          .tripStartInspection!
                                                          .mileageImageIDs![0] ==
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
                                                                '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0]}'),
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
                                                                  .mileageImageIDs![0] = '';
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
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              width: double.maxFinite,
                                              child: GestureDetector(
                                                onTap: () {},
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0.0,
                                                    backgroundColor: (damageSelectionSnapshot
                                                                        .data ==
                                                                    1 ||
                                                                damageSelectionSnapshot
                                                                        .data ==
                                                                    2) &&
                                                            startTripBloc
                                                                .checkValidation(
                                                                    startTripDataSnapshot
                                                                        .data!)
                                                        ? Color(0xffFF8F68)
                                                        : Colors.grey,
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                  ),
                                                  onPressed: (damageSelectionSnapshot
                                                                      .data ==
                                                                  1 ||
                                                              damageSelectionSnapshot
                                                                      .data ==
                                                                  2) &&
                                                          startTripBloc
                                                              .checkValidation(
                                                                  startTripDataSnapshot
                                                                      .data!)
                                                      ? () async {
                                                          (damageSelectionSnapshot
                                                                          .data ==
                                                                      1 ||
                                                                  damageSelectionSnapshot
                                                                          .data ==
                                                                      2) &&
                                                              startTripBloc
                                                                  .checkValidation(
                                                                      startTripDataSnapshot
                                                                          .data!);

                                                          var multiUploader =
                                                              await startTripBloc
                                                                  .startTripInspectionsMethod(
                                                                      startTripDataSnapshot
                                                                          .data!);

                                                          if (multiUploader!
                                                              .status!
                                                              .success!) {
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/host_trip_started',
                                                              arguments:
                                                                  tripDetails,
                                                            );
                                                          }

                                                          AppEventsUtils.logEvent(
                                                              "trip_start_successful",
                                                              params: {
                                                                "tripId":
                                                                    tripDetails
                                                                        .tripID,
                                                                "tripStartStatus":
                                                                    multiUploader!
                                                                        .status!
                                                                        .success,
                                                                "carName":
                                                                    tripDetails
                                                                        .car!
                                                                        .about!
                                                                        .make,
                                                                "host": tripDetails
                                                                    .hostProfile!
                                                                    .firstName
                                                              });
                                                        }
                                                      : () {
                                                          print(
                                                              "trip cant be started");
                                                        },
                                                  child: Text(
                                                    'Finish Inspection',
                                                    style: TextStyle(
                                                        fontFamily:
                                                            'Urbanist',
                                                        fontSize: 18,
                                                        color: Colors.white),
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
                                ],
                              ),
                            ),
                          ),
                        );
                      })
                  : Container();
            }),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
//
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path/path.dart';
// import 'package:ridealike/pages/trips/bloc/host_start_trip_inspection_bloc.dart';
// import 'package:ridealike/pages/trips/response_model/host_start_inspect_rental_response.dart';
// import 'package:ridealike/pages/trips/ui/exterior_inspection.dart';
//
// import 'package:ridealike/widgets/custom_buttom.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert' show json;
//
// import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
// import 'package:ridealike/pages/common/constant_url.dart';
// import 'package:ridealike/utils/app_events/app_events_utils.dart';
//
// import 'dart:async';
//
// import 'package:async/async.dart';
//
// final storage = new FlutterSecureStorage();
//
// class CommonInspectionUI extends StatefulWidget {
//   @override
//   State createState() => CommonInspectionUIState();
// }
//
// class CommonInspectionUIState extends State<CommonInspectionUI> {
//   final startTripBloc = HostStartTripBloc();
//   String fuelLevel = "Select the suitable option";
//   // mileageController.text = mileage.toString();
//    int mileage=0;
//    String? damageDesctiption;
//
//   TextEditingController mileageController = TextEditingController();
//   TextEditingController _damagedescriptionController = TextEditingController();
//   FocusNode _damageDesctiptionfocusNode = FocusNode();
//   FocusNode _mileagefocusNode = FocusNode();
//   @override
//   void dispose() {
//     _damageDesctiptionfocusNode.dispose();
//     _mileagefocusNode.dispose();
//     super.dispose();
//   }
//
//   void _handleTapOutside() {
//     // Remove focus from the text field when tapped outside
//     _damageDesctiptionfocusNode.unfocus();
//     _mileagefocusNode.unfocus();
//   }
//   void _settingModalBottomSheet(context, _imgOrder,
//       AsyncSnapshot<HostInspectTripStartResponse> startTripDataSnapshot) {
//     showModalBottomSheet(
//         context: context,
//         builder: (BuildContext bc) {
//           return Container(
//             child: new Wrap(
//               children: <Widget>[
//                 Padding(
//                   padding: EdgeInsets.all(12.0),
//                   child: Column(
//                     children: <Widget>[
//                       Container(
//                         child: Stack(
//                           children: <Widget>[
//                             GestureDetector(
//                               onTap: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Text(
//                                 'Cancel',
//                                 style: TextStyle(
//                                   fontFamily: 'Urbanist',
//                                   fontSize: 16,
//                                   color: Color(0xFFF68E65),
//                                 ),
//                               ),
//                             ),
//                             Align(
//                               alignment: Alignment.center,
//                               child: Text(
//                                 'Attach photo',
//                                 style: TextStyle(
//                                   fontFamily: 'Urbanist',
//                                   fontSize: 16,
//                                   color: Color(0xFF371D32),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 new ListTile(
//                   leading: Image.asset('icons/Take-Photo_Sheet.png'),
//                   title: Text(
//                     'Take photo',
//                     textAlign: TextAlign.start,
//                     style: TextStyle(
//                       fontFamily: 'Urbanist',
//                       fontSize: 16,
//                       color: Color(0xFF371D32),
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     startTripBloc.pickeImageThroughCamera(
//                         _imgOrder, startTripDataSnapshot, context);
//                     // setState(() {
//
//                     // });
//                   },
//                 ),
//                 Divider(color: Color(0xFFABABAB)),
//                 new ListTile(
//                   leading: Image.asset('icons/Attach-Photo_Sheet.png'),
//                   title: Text(
//                     'Attach photo',
//                     textAlign: TextAlign.start,
//                     style: TextStyle(
//                       fontFamily: 'Urbanist',
//                       fontSize: 16,
//                       color: Color(0xFF371D32),
//                     ),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                     startTripBloc.pickeImageFromGallery(
//                         _imgOrder, startTripDataSnapshot, context);
//                   },
//                 ),
//                 Divider(color: Color(0xFFABABAB)),
//               ],
//             ),
//           );
//         });
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     AppEventsUtils.logEvent("view_trip_start");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final receivedData = ModalRoute.of(context)!.settings.arguments;
//     Trips tripDetails = receivedData as Trips;
//     HostInspectTripStartResponse inspectTripStartResponse =
//     HostInspectTripStartResponse(
//         tripStartInspection: TripStartInspection(
//           damageDesctiption: damageDesctiption,
//             fuelLevel: '',
//           mileage: 0,
//             exteriorCleanliness: '',
//             interiorImageIDs: List.filled(3, ''),
//             interiorCleanliness: '',
//             damageImageIDs: List.filled(12, ''),
//             exteriorImageIDs: List.filled(3, ''),
//             dashboardImageIDs: List.filled(14, ''),
//             fuelImageIDs: List.filled(2, ''),
//             mileageImageIDs: List.filled(2, ''),
//             inspectionByUserID: tripDetails!.userID,
//             tripID: tripDetails!.tripID));
//     startTripBloc.changedStartTripData.call(inspectTripStartResponse);
//     startTripBloc.changedDamageSelection.call(0);
//
//
//     return GestureDetector(
//       onTap: _handleTapOutside,
//       child: Scaffold(
//         backgroundColor: Color(0xFFFFFFFF),
//         body: StreamBuilder<HostInspectTripStartResponse>(
//             stream: startTripBloc.startTripData,
//             builder: (context, startTripDataSnapshot) {
//               return startTripDataSnapshot.hasData &&
//                   startTripDataSnapshot.data! != null
//                   ? StreamBuilder<int>(
//                   stream: startTripBloc.damageSelection,
//                   builder: (context, damageSelectionSnapshot) {
//                     return Container(
//                       child: SingleChildScrollView(
//                         child: Padding(
//                           padding: const EdgeInsets.all(16.0),
//                           child: Column(
//                             children: <Widget>[
//                               SizedBox(height: 10),
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: <Widget>[
//                                   GestureDetector(
//                                     onTap: () {
//                                       Navigator.pop(context);
//                                     },
//                                     child: Text(
//                                       "Cancel",
//                                       textAlign: TextAlign.center,
//                                       style: TextStyle(
//                                           fontFamily: 'Urbanist',
//                                           fontSize: 16,
//                                           color: Color(0xFFF68E65)),
//                                     ),
//                                   ),
//
//
//                                 ],
//                               ),
//
//                               Image.asset('images/23665137_bwink_tsp_01_single_091.png'),
//                               SizedBox(height: 5),
//
//                               Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.spaceBetween,
//                                 children: <Widget>[
//                                   Text(
//                                     "Start Your Trip",
//                                     style: TextStyle(
//                                         fontFamily: 'Urbanist',
//                                         fontSize: 36,
//                                         color: Color(0xFF371D32),
//                                         fontWeight: FontWeight.bold),
//                                   ),
//                                   Center(
//                                     child: (tripDetails!.carImageId != null ||
//                                         tripDetails!.carImageId != '')
//                                         ? CircleAvatar(
//                                       backgroundImage: NetworkImage(
//                                           '$storageServerUrl/${tripDetails!.carImageId}'),
//                                       radius: 17.5,
//                                     )
//                                         : CircleAvatar(
//                                       backgroundImage: AssetImage(
//                                           'images/car-placeholder.png'),
//                                       radius: 17.5,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 5),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Color(0xfff2f2f2),
//                                   borderRadius:
//                                   BorderRadius.all(Radius.circular(8)),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       Text(
//                                         "Any noticeable damage before the trip?",
//                                         style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600,
//                                             color: Color(0xFF371D32)),
//                                       ),
//                                       SizedBox(height: 8),
//                                       Text(
//                                         "Inspect vehicle's inside and outside for any visual damage, like dents, scratches or broken parts.",
//                                         style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 14,
//                                             color: Color(0xFF353B50)),
//                                       ),
//                                       SizedBox(height: 10),
//
//                                       ///any damage button
//                                       Row(
//                                         mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                         children: <Widget>[
//                                           Expanded(
//                                             child: CustomButton(
//                                               title: 'NO',
//                                               isSelected:
//                                               damageSelectionSnapshot
//                                                   .data ==
//                                                   1
//                                                   ? true
//                                                   : false,
//                                               press: () {
//
//
//                                                 startTripDataSnapshot
//                                                     .data!!
//                                                     .tripStartInspection!!
//                                                     .isNoticibleDamage =
//                                                 false;
//                                                 startTripBloc
//                                                     .changedStartTripData
//                                                     .call(
//                                                     startTripDataSnapshot
//                                                         .data!!);
//                                                 startTripBloc
//                                                     .changedDamageSelection
//                                                     .call(1);
//                                               },
//                                             ),
//                                           ),
//                                           SizedBox(width: 10.0),
//                                           Expanded(
//                                             child: CustomButton(
//                                               title: 'YES',
//                                               isSelected:
//                                               damageSelectionSnapshot
//                                                   .data ==
//                                                   2
//                                                   ? true
//                                                   : false,
//                                               press: () {
//
//                                                 startTripDataSnapshot
//                                                     .data!!
//                                                     .tripStartInspection!!
//                                                     .isNoticibleDamage = true;
//                                                 startTripBloc
//                                                     .changedStartTripData
//                                                     .call(
//                                                     startTripDataSnapshot
//                                                         .data!!);
//                                                 startTripBloc
//                                                     .changedDamageSelection
//                                                     .call(2);
//                                               },
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(height: 10),
//
//                               Container(
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(
//                                   color: Color(0xfff2f2f2),
//                                   borderRadius:
//                                   BorderRadius.all(Radius.circular(8)),
//                                 ),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: <Widget>[
//                                       Text(
//                                         "Take photos of car if any damages",
//                                         style: TextStyle(
//                                             fontFamily: 'Urbanist',
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w600,
//                                             color: Color(0xFF371D32)),
//                                       ),
//                                       //  SizedBox(height: 8),
//                                       GridView.count(
//                                         primary: false,
//                                         shrinkWrap: true,
//                                         crossAxisSpacing: 2,
//                                         mainAxisSpacing: 2,
//                                         crossAxisCount: 3,
//                                         children: <Widget>[
//                                           GestureDetector(
//                                             onTap:
//
//                                                 () => _settingModalBottomSheet(
//                                                 context,
//                                                 1,
//                                                 startTripDataSnapshot),
//                                             child: startTripDataSnapshot
//                                                 .data!!
//                                                 .tripStartInspection!!
//                                                 .damageImageIDs![0] ==
//                                                 ''
//                                                 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration: BoxDecoration(
//                                                 color:
//                                                 Color(0xFFE0E0E0),
//                                                 borderRadius:
//                                                 new BorderRadius
//                                                     .only(
//                                                   topLeft: const Radius
//                                                       .circular(12.0),
//                                                   bottomLeft:
//                                                   const Radius
//                                                       .circular(
//                                                       12.0),
//                                                   // topRight: const Radius
//                                                   //     .circular(12.0),
//                                                   // bottomRight:
//                                                   // const Radius
//                                                   //     .circular(
//                                                   //     12.0),
//                                                 ),
//                                               ),
//                                             )
//                                                 : Stack(children: <Widget>[
//                                               SizedBox(
//                                                   child: Image(
//                                                     fit: BoxFit.fill,
//                                                     image: NetworkImage(
//                                                         '$storageServerUrl/${startTripDataSnapshot.data!!.tripStartInspection!!.damageImageIDs![0]}'),
//                                                   ),
//                                                   width:
//                                                   double.maxFinite),
//                                               Positioned(
//                                                 right: 5,
//                                                 bottom: 5,
//                                                 child: InkWell(
//                                                     onTap: () {
//
//
//                                                       startTripDataSnapshot
//                                                           .data!!
//                                                           .tripStartInspection!!
//                                                           .damageImageIDs![0] = '';
//                                                       startTripBloc
//                                                           .changedStartTripData
//                                                           .call(
//                                                           startTripDataSnapshot
//                                                               .data!!);
//                                                     },
//                                                     child: CircleAvatar(
//                                                         backgroundColor:
//                                                         Colors
//                                                             .white,
//                                                         radius: 10,
//                                                         child: Icon(
//                                                           Icons.delete,
//                                                           color: Color(
//                                                               0xffF55A51),
//                                                           size: 20,
//                                                         ))
//                                                 ),
//                                               )
//                                             ]),
//                                           ),
//                                           GestureDetector(
//                                               onTap:
//                                               // damageSelectionSnapshot
//                                               //                 .data! !=
//                                               //             1 &&
//                                               //         damageSelectionSnapshot
//                                               //                 .data! !=
//                                               //             2
//                                               //     ? () => {}
//                                               //     :
//                                                   () => _settingModalBottomSheet(
//                                                   context,
//                                                   2,
//                                                   startTripDataSnapshot),
//                                               child: startTripDataSnapshot
//                                                   .data!!
//                                                   .tripStartInspection!!
//                                                   .damageImageIDs![1] ==
//                                                   ''
//                                                   ? Container(
//                                                 child: Image.asset(
//                                                     'icons/Scan-Placeholder.png'),
//                                                 color:
//                                                 Color(0xFFE0E0E0),
//                                               )
//                                                   : Stack(children: <Widget>[
//                                                 SizedBox(
//                                                     child: Image(
//                                                       fit: BoxFit.fill,
//                                                       image: NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot.data!!.tripStartInspection!!.damageImageIDs![1]}'),
//                                                     ),
//                                                     width: double
//                                                         .maxFinite),
//                                                 Positioned(
//                                                   right: 5,
//                                                   bottom: 5,
//                                                   child: InkWell(
//                                                       onTap: () {
//                                                         startTripDataSnapshot
//                                                             .data!!
//                                                             .tripStartInspection!!
//                                                             .damageImageIDs![1] = '';
//                                                         startTripBloc
//                                                             .changedStartTripData
//                                                             .call(startTripDataSnapshot
//                                                             .data!!);
//                                                       },
//                                                       child:
//                                                       CircleAvatar(
//                                                           backgroundColor:
//                                                           Colors
//                                                               .white,
//                                                           radius:
//                                                           10,
//                                                           child:
//                                                           Icon(
//                                                             Icons
//                                                                 .delete,
//                                                             color: Color(
//                                                                 0xffF55A51),
//                                                             size:
//                                                             20,
//                                                           ))),
//                                                 )
//                                               ])),
//                                           GestureDetector(
//                                               onTap:
//                                               // damageSelectionSnapshot
//                                               //                 .data! !=
//                                               //             1 &&
//                                               //         damageSelectionSnapshot
//                                               //                 .data! !=
//                                               //             2
//                                               //     ? () => {}
//                                               //     :
//                                                   () => _settingModalBottomSheet(
//                                                   context,
//                                                   3,
//                                                   startTripDataSnapshot),
//                                               child: startTripDataSnapshot
//                                                   .data!!
//                                                   .tripStartInspection!!
//                                                   .damageImageIDs![2] ==
//                                                   ''
//                                                   ? Container(
//                                                 child: Image.asset(
//                                                     'icons/Scan-Placeholder.png'),
//                                                 decoration:
//                                                 BoxDecoration(
//                                                   color:
//                                                   Color(0xFFE0E0E0),
//                                                   borderRadius:
//                                                   new BorderRadius
//                                                       .only(
//                                                     // topLeft: const Radius
//                                                     //     .circular(12.0),
//                                                     // bottomLeft:
//                                                     // const Radius
//                                                     //     .circular(
//                                                     //     12.0),
//                                                     topRight: const Radius
//                                                         .circular(12.0),
//                                                     bottomRight:
//                                                     const Radius
//                                                         .circular(
//                                                         12.0),
//                                                   ),
//                                                 ),
//                                               )
//                                                   : Stack(children: <Widget>[
//                                                 SizedBox(
//                                                     child: Image(
//                                                       fit: BoxFit.fill,
//                                                       image: NetworkImage(
//                                                           '$storageServerUrl/${startTripDataSnapshot.data!!.tripStartInspection!!.damageImageIDs![2]}'),
//                                                     ),
//                                                     width: double
//                                                         .maxFinite),
//                                                 Positioned(
//                                                   right: 5,
//                                                   bottom: 5,
//                                                   child: InkWell(
//                                                       onTap: () {
//                                                         startTripDataSnapshot
//                                                             .data!!
//                                                             .tripStartInspection!!
//                                                             .damageImageIDs![2] = '';
//                                                         startTripBloc
//                                                             .changedStartTripData
//                                                             .call(startTripDataSnapshot
//                                                             .data!!);
//                                                       },
//                                                       child:
//                                                       CircleAvatar(
//                                                           backgroundColor:
//                                                           Colors
//                                                               .white,
//                                                           radius:
//                                                           10,
//                                                           child:
//                                                           Icon(
//                                                             Icons
//                                                                 .delete,
//                                                             color: Color(
//                                                                 0xffF55A51),
//                                                             size:
//                                                             20,
//                                                           ))),
//                                                 )
//                                               ])
// //
//                                           ),
//                                         GestureDetector(
//                                             onTap:
//                                             // damageSelectionSnapshot
//                                             //                 .data! !=
//                                             //             1 &&
//                                             //         damageSelectionSnapshot
//                                             //                 .data! !=
//                                             //             2
//                                             //     ? () => {}
//                                             //     :
//                                                 () => _settingModalBottomSheet(
//                                                 context,
//                                                 4,
//                                                 startTripDataSnapshot),
//                                             child: startTripDataSnapshot
//                                                 .data!!
//                                                 .tripStartInspection!!
//                                                 .damageImageIDs![3] ==
//                                                 ''
//                                                 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration:
//                                               BoxDecoration(
//                                                 color:
//                                                 Color(0xFFE0E0E0),
//                                                 borderRadius:
//                                                 new BorderRadius
//                                                     .only(
//                                                   topLeft: const Radius
//                                                       .circular(12.0),
//                                                   bottomLeft:
//                                                   const Radius
//                                                       .circular(
//                                                       12.0),
//                                                 ),
//                                               ),
//                                             )
//                                                 : Stack(children: <Widget>[
//                                               SizedBox(
//                                                   child: Image(
//                                                     fit: BoxFit.fill,
//                                                     image: NetworkImage(
//                                                         '$storageServerUrl/${startTripDataSnapshot.data!!.tripStartInspection!!.damageImageIDs![3]}'),
//                                                   ),
//                                                   width: double
//                                                       .maxFinite),
//                                               Positioned(
//                                                 right: 5,
//                                                 bottom: 5,
//                                                 child: InkWell(
//                                                     onTap: () {
//                                                       startTripDataSnapshot
//                                                           .data!!
//                                                           .tripStartInspection!!
//                                                           .damageImageIDs![3] = '';
//                                                       startTripBloc
//                                                           .changedStartTripData
//                                                           .call(startTripDataSnapshot
//                                                           .data!!);
//                                                     },
//                                                     child:
//                                                     CircleAvatar(
//                                                         backgroundColor:
//                                                         Colors
//                                                             .white,
//                                                         radius:
//                                                         10,
//                                                         child:
//                                                         Icon(
//                                                           Icons
//                                                               .delete,
//                                                           color: Color(
//                                                               0xffF55A51),
//                                                           size:
//                                                           20,
//                                                         ))),
//                                               )
//                                             ])
// //
//                                         ),
//                                         GestureDetector(
//                                             onTap:
//                                             //  damageSelectionSnapshot
//                                             //                 .data! !=
//                                             //             1 &&
//                                             //         damageSelectionSnapshot
//                                             //                 .data! !=
//                                             //             2
//                                             //     ? () => {}
//                                             //     :
//                                                 () => _settingModalBottomSheet(
//                                                 context,
//                                                 5,
//                                                 startTripDataSnapshot),
//                                             child: startTripDataSnapshot
//                                                 .data!!
//                                                 .tripStartInspection!!
//                                                 .damageImageIDs![4] ==
//                                                 ''
//                                                 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               color:
//                                               Color(0xFFE0E0E0),
//                                             )
//                                                 : Stack(children: <Widget>[
//                                               SizedBox(
//                                                   child: Image(
//                                                     fit: BoxFit.fill,
//                                                     image: NetworkImage(
//                                                         '$storageServerUrl/${startTripDataSnapshot.data!!.tripStartInspection!!.damageImageIDs![4]}'),
//                                                   ),
//                                                   width: double
//                                                       .maxFinite),
//                                               Positioned(
//                                                 right: 5,
//                                                 bottom: 5,
//                                                 child: InkWell(
//                                                     onTap: () {
//                                                       startTripDataSnapshot
//                                                           .data!!
//                                                           .tripStartInspection!!
//                                                           .damageImageIDs![4] = '';
//                                                       startTripBloc
//                                                           .changedStartTripData
//                                                           .call(startTripDataSnapshot
//                                                           .data!!);
//                                                     },
//                                                     child:
//                                                     CircleAvatar(
//                                                         backgroundColor:
//                                                         Colors
//                                                             .white,
//                                                         radius:
//                                                         10,
//                                                         child:
//                                                         Icon(
//                                                           Icons
//                                                               .delete,
//                                                           color: Color(
//                                                               0xffF55A51),
//                                                           size:
//                                                           20,
//                                                         ))),
//                                               )
//                                             ])),
//                                         GestureDetector(
//                                             onTap:
//                                             // damageSelectionSnapshot
//                                             //                 .data! !=
//                                             //             1 &&
//                                             //         damageSelectionSnapshot
//                                             //                 .data! !=
//                                             //             2
//                                             //     ? () => {}
//                                             //     :
//                                                 () => _settingModalBottomSheet(
//                                                 context,
//                                                 6,
//                                                 startTripDataSnapshot),
//                                             child: startTripDataSnapshot
//                                                 .data!!
//                                                 .tripStartInspection!!
//                                                 .damageImageIDs![5] ==
//                                                 ''
//                                                 ? Container(
//                                               child: Image.asset(
//                                                   'icons/Scan-Placeholder.png'),
//                                               decoration:
//                                               BoxDecoration(
//                                                 color:
//                                                 Color(0xFFE0E0E0),
//                                                 borderRadius:
//                                                 new BorderRadius
//                                                     .only(
//                                                   topRight: const Radius
//                                                       .circular(12.0),
//                                                   bottomRight:
//                                                   const Radius
//                                                       .circular(
//                                                       12.0),
//                                                 ),
//                                               ),
//                                             )
//                                                 : Stack(children: <Widget>[
//                                               SizedBox(
//                                                   child: Image(
//                                                     fit: BoxFit.fill,
//                                                     image: NetworkImage(
//                                                         '$storageServerUrl/${startTripDataSnapshot.data!!.tripStartInspection!!.damageImageIDs![5]}'),
//                                                   ),
//                                                   width: double
//                                                       .maxFinite),
//                                               Positioned(
//                                                 right: 5,
//                                                 bottom: 5,
//                                                 child: InkWell(
//                                                     onTap: () {
//                                                       startTripDataSnapshot
//                                                           .data!!
//                                                           .tripStartInspection!!
//                                                           .damageImageIDs![5] = '';
//                                                       startTripBloc
//                                                           .changedStartTripData
//                                                           .call(startTripDataSnapshot
//                                                           .data!!);
//                                                     },
//                                                     child:
//                                                     CircleAvatar(
//                                                         backgroundColor:
//                                                         Colors
//                                                             .white,
//                                                         radius:
//                                                         10,
//                                                         child:
//                                                         Icon(
//                                                           Icons
//                                                               .delete,
//                                                           color: Color(
//                                                               0xffF55A51),
//                                                           size:
//                                                           20,
//                                                         ))),
//                                               )
//                                             ])),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//
//                               /// damage image section
//                               SizedBox(height: 10),
//
//                               ///damage description
//                               Container(
//                                 padding: EdgeInsets.all(5.0),
//                                 width: MediaQuery.of(context).size.width,
//                                 decoration: BoxDecoration(
//                                   color: Color(0xfff2f2f2),
//                                   borderRadius:
//                                   BorderRadius.all(Radius.circular(6)),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment:
//                                   CrossAxisAlignment.start,
//                                   children: <Widget>[
//                                     Row(
//                                       mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                       children: <Widget>[
//                                         Padding(
//                                           padding: const EdgeInsets.only(
//                                               left: 8.0,
//                                               right: 16.0,
//                                               top: 10),
//                                           child: Text(
//                                             "Describe Any damages (optional)",
//                                             textAlign: TextAlign.center,
//                                             style: TextStyle(
//                                                 fontFamily: 'Urbanist',
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: Color(0xFF371D32)),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     Padding(
//                                       padding: const EdgeInsets.only(
//                                           left: 8.0, right: 16.0),
//                                       child: TextField(
//                                         focusNode: _damageDesctiptionfocusNode,
//                                         onChanged: (value) {
//                                           damageDesctiption = (value);
//                                           startTripDataSnapshot
//                                               .data!!
//                                               .tripStartInspection!!
//                                               .damageDesctiption = damageDesctiption;
//                                           startTripBloc.changedStartTripData
//                                               .call(startTripDataSnapshot
//                                               .data!!);
//                                         },
//                                         controller:
//                                         _damagedescriptionController,
//                                         textInputAction: TextInputAction.done,
//
//                                         maxLines: 2,
//                                         enabled:
//                                         damageSelectionSnapshot.data == 2,
//                                    //     onChanged: (description) {},
//                                         decoration: InputDecoration(
//                                             hintText:
//                                             'Add a description here',
//                                             hintStyle: TextStyle(
//                                               fontFamily:
//                                               'Urbanist',
//                                               fontSize: 14,
//                                               color: Color(0xFF686868),
//                                             ),
//                                             border: InputBorder.none),
//                                         // validator: (value) {
//                                         //   if (value == null ||
//                                         //       value.isEmpty) {
//                                         //     return '';
//                                         //   }
//                                         //   return null;
//                                         // },
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               SizedBox(height: 10),
//
//
//
//
//
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       children: [
//                                         SizedBox(
//                                           width: double.maxFinite,
//                                           child: GestureDetector(
//                                             onTap: () {
//
//                                             },
//                                             child: ElevatedButton(
//                                               style: ElevatedButton.styleFrom(
//                                                 backgroundColor: (damageSelectionSnapshot
//                                                     .data ==
//                                                     1 ||
//                                                     damageSelectionSnapshot
//                                                         .data ==
//                                                         2) &&
//                                                     startTripBloc
//                                                         .checkValidation(
//                                                         startTripDataSnapshot
//                                                             .data!!)
//                                                     ? Color(0xffFF8F68)
//                                                     : Colors.grey,
//                                                 padding: EdgeInsets.all(16.0),
//                                                 shape: RoundedRectangleBorder(
//                                                     borderRadius:
//                                                     BorderRadius.circular(
//                                                         8.0)),
//                                               ),
//
//
//                                               onPressed: (){
//
//
//                                                 Navigator.pushNamed(
//                                                   context,
//                                                   '/exterior_inspection_ui',
//                                                   arguments:
//                                                   tripDetails,
//                                                 );
//                                               },
//
//
//
//
//                                                 // AppEventsUtils.logEvent(
//                                                 //     "trip_start_successful",
//                                                 //     params: {
//                                                 //       "tripId":
//                                                 //           tripDetails
//                                                 //               .tripID,
//                                                 //       "tripStartStatus":
//                                                 //           multiUploader
//                                                 //               .status
//                                                 //               .success,
//                                                 //       "carName":
//                                                 //           tripDetails
//                                                 //               .car
//                                                 //               .about
//                                                 //               .make,
//                                                 //       "host": tripDetails
//                                                 //           .hostProfile
//                                                 //           .firstName
//                                                 //     });
//
//                                               child: Text(
//                                                 'Next',
//                                                 style: TextStyle(
//                                                     fontFamily:
//                                                     'Urbanist',
//                                                     fontSize: 18,
//                                                     color: Colors.white),
//                                               ),
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               SizedBox(height: 10),
//                             ],
//                           ),
//                         ),
//                       ),
//                     );
//                   })
//                   : Container();
//             }),
//       ),
//     );
//   }
// }
//
// //
