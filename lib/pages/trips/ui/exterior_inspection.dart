import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/host_start_trip_inspection_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/host_start_inspect_rental_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/custom_buttom.dart';

final storage = new FlutterSecureStorage();

class ExteriorInspectionUI extends StatefulWidget {
  @override
  State createState() => ExteriorInspectionUIState();
}

class ExteriorInspectionUIState extends State<ExteriorInspectionUI> {
  final startTripBloc = HostStartTripBloc();
  String fuelLevel = "Select the suitable option";
  // mileageController.text = mileage.toString();
  int mileage=0;
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
    // Remove focus from the text field when tapped outside
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
                    // setState(() {

                    // });
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
    AppEventsUtils.logEvent("view_trip_start");
  }

  @override
  Widget build(BuildContext context) {
    final receivedData = ModalRoute.of(context)!.settings.arguments;
    Trips tripDetails = receivedData as Trips;
    HostInspectTripStartResponse inspectTripStartResponse =
    HostInspectTripStartResponse(
        tripStartInspection: TripStartInspection(
            damageDesctiption: damageDesctiption,
            fuelLevel: '',
            mileage: 0,
            exteriorCleanliness: '',
            interiorImageIDs: List.filled(3, ''),
            interiorCleanliness: '',
            damageImageIDs: List.filled(12, ''),
            exteriorImageIDs: List.filled(3, ''),
            dashboardImageIDs: List.filled(14, ''),
            fuelImageIDs: List.filled(2, ''),
            mileageImageIDs: List.filled(2, ''),
            inspectionByUserID: tripDetails.userID,
            tripID: tripDetails.tripID));
    startTripBloc.changedStartTripData.call(inspectTripStartResponse);
    startTripBloc.changedDamageSelection.call(0);


    return GestureDetector(
      onTap: _handleTapOutside,
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: StreamBuilder<HostInspectTripStartResponse>(
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


                                ],
                              ),

                              Image.asset('images/exterior.png'),
                              SizedBox(height: 5),

                              // Row(
                              //   mainAxisAlignment:
                              //   MainAxisAlignment.spaceBetween,
                              //   children: <Widget>[
                              //     Text(
                              //       "Start Your Trip",
                              //       style: TextStyle(
                              //           fontFamily: 'Urbanist',
                              //           fontSize: 36,
                              //           color: Color(0xFF371D32),
                              //           fontWeight: FontWeight.bold),
                              //     ),
                              //     Center(
                              //       child: (tripDetails.carImageId != null ||
                              //           tripDetails.carImageId != '')
                              //           ? CircleAvatar(
                              //         backgroundImage: NetworkImage(
                              //             '$storageServerUrl/${tripDetails.carImageId}'),
                              //         radius: 17.5,
                              //       )
                              //           : CircleAvatar(
                              //         backgroundImage: AssetImage(
                              //             'images/car-placeholder.png'),
                              //         radius: 17.5,
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              SizedBox(height: 5),




                              SizedBox(height: 10),


                              ///exterior button
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
                                          fontWeight: FontWeight.w600,
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

                              ///exterior image
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
                                            fontWeight: FontWeight.w600,
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
                                            onTap:
                                            // damageSelectionSnapshot
                                            //                 .data !=
                                            //             1 &&
                                            //         damageSelectionSnapshot
                                            //                 .data !=
                                            //             2
                                            //     ? () => {}
                                            //     :
                                                () => _settingModalBottomSheet(
                                                context,
                                                13,
                                                startTripDataSnapshot),
                                            child: startTripDataSnapshot
                                                .data!
                                                .tripStartInspection!
                                                .exteriorImageIDs![0] ==
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
                                                ),
                                              ),
                                            )
                                                : Stack(children: <Widget>[
                                              SizedBox(
                                                  child: Image(
                                                    fit: BoxFit.fill,
                                                    image: NetworkImage(
                                                        '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![0]}'),
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
                                                          .exteriorImageIDs![0] = '';
                                                      startTripBloc
                                                          .changedStartTripData
                                                          .call(
                                                          startTripDataSnapshot
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
                                          GestureDetector(
                                              onTap:
                                              //  damageSelectionSnapshot
                                              //                 .data !=
                                              //             1 &&
                                              //         damageSelectionSnapshot
                                              //                 .data !=
                                              //             2
                                              //     ? () => {}
                                              //     :
                                                  () => _settingModalBottomSheet(
                                                  context,
                                                  14,
                                                  startTripDataSnapshot),
                                              child: startTripDataSnapshot
                                                  .data!
                                                  .tripStartInspection!
                                                  .exteriorImageIDs![1] ==
                                                  ''
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
                                                          '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![1]}'),
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
                                                            .exteriorImageIDs![1] = '';
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
                                              ])),
                                          GestureDetector(
                                              onTap:
                                              //  damageSelectionSnapshot
                                              //                 .data !=
                                              //             1 &&
                                              //         damageSelectionSnapshot
                                              //                 .data !=
                                              //             2
                                              //     ? () => {}
                                              //     :
                                                  () => _settingModalBottomSheet(
                                                  context,
                                                  15,
                                                  startTripDataSnapshot),
                                              child: startTripDataSnapshot
                                                  .data!
                                                  .tripStartInspection!
                                                  .exteriorImageIDs![2] ==
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
                                                          '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![2]}'),
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
                                                            .exteriorImageIDs![2] = '';
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
                                              ])
//
                                          ),
//
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),


                              SizedBox(height: 10),

//                                 ///interior image

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
                                            onTap: () {

                                            },
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.all(16.0),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                        8.0)),
                                                // backgroundColor: (damageSelectionSnapshot
                                                //     .data ==
                                                //     1 ||
                                                //     damageSelectionSnapshot
                                                //         .data ==
                                                //         2)
                                                //     &&
                                                //     startTripBloc
                                                //         .checkValidationExterior(
                                                //         startTripDataSnapshot
                                                //             .data!)
                                                //     ? Color(0xffFF8F68)
                                                //     : Colors.grey,
                                              ),



                                              onPressed: (){


                                                Navigator.pushNamed(
                                                  context,
                                                  '/interior_inspection_ui',
                                                  arguments:
                                                  tripDetails,
                                                );
                                              },
                                              child: Text(
                                                'Next',
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

//
