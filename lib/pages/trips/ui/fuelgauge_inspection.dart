import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/host_start_trip_inspection_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/host_start_inspect_rental_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

final storage = new FlutterSecureStorage();

class FuelGaugeInspectionUI extends StatefulWidget {
  @override
  State createState() => FuelGaugeInspectionUIState();
}

class FuelGaugeInspectionUIState extends State<FuelGaugeInspectionUI> {
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
                              SizedBox(height: 10),
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

                              Image.asset(
                                'images/fuel.png',
                                width: 150, // Set the desired width
                                height: 150, // Set the desired height
                              ),

                              ///fuel gauge

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
                                      'Take photo(s) of the fuel gauge.'
                                      // "Take photos of a dashboard before the trip"
                                      ,
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF371D32)),
                                    ),
                                    // Text(
                                    //   "To capture fuel level",
                                    //   style: TextStyle(
                                    //       fontFamily: 'Urbanist',
                                    //       fontSize: 14,
                                    //       color: Color(0xFF353B50)),
                                    // ),
                                    Text(
                                        "Select the fuel level before the trip start.", style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xFF353B50)),),

                                    ///fuel gauge dropdown button
                                    ///
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
                                            .fuelLevel!),
                                        DropdownButton(

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

                                    // Row(
                                    //   mainAxisAlignment:
                                    //       MainAxisAlignment.spaceBetween,
                                    //   children: [
                                    //     // Text(fuelLevel),
                                    //     // DropdownButton(
                                    //     //   underline: SizedBox(),
                                    //     //   items: <String>[

                                    //     //   ].map((String value) {
                                    //     //     return DropdownMenuItem<String>(
                                    //     //       value: value,
                                    //     //       child: Text(value),
                                    //     //     );
                                    //     //   }).toList(),
                                    //     //   onChanged: (value) {
                                    //     //     setState(() {
                                    //     //       fuelLevel = value;
                                    //     //     });
                                    //     //   },
                                    //     // ),
                                    //     DropdownButton(
                                    //       underline: SizedBox(),
                                    //       items: <String>[
                                    //         '1/8',
                                    //         '1/4',
                                    //         '3/8',
                                    //         '1/2',
                                    //         '5/8',
                                    //         '3/4',
                                    //         '7/8',
                                    //         'Full'
                                    //       ].map((String value) {
                                    //         return DropdownMenuItem<String>(
                                    //           value: value,
                                    //           child: Text(value),
                                    //         );
                                    //       }).toList(),
                                    //       onChanged: (value) {
                                    //         // setState(() {
                                    //         //   fuelLevel = value;
                                    //         // });
                                    //         startTripDataSnapshot
                                    //             .data
                                    //             .tripStartInspection
                                    //             .fuelLevel = value;
                                    //         startTripBloc.changedStartTripData
                                    //             .call(startTripDataSnapshot
                                    //                 .data);
                                    //       },
                                    //     ),
                                    //     // FindDropdown(
                                    //     //   items: [
                                    //     //     '1/8',
                                    //     //     '1/4',
                                    //     //     '3/8',
                                    //     //     '1/2',
                                    //     //     '5/8',
                                    //     //     '3/4',
                                    //     //     '7/8',
                                    //     //     'Full'
                                    //     //   ],
                                    //     //   label: "Select the suitable option",
                                    //     //   onChanged: (String item) =>
                                    //     //       print(item),
                                    //     //   selectedItem: "1/8",
                                    //     // )
                                    //   ],
                                    // ),
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
                                          onTap: ()
                                          // damageSelectionSnapshot
                                          //                 .data !=
                                          //             1 &&
                                          //         damageSelectionSnapshot
                                          //                 .data !=
                                          //             2
                                          //     ? () => {}
                                          //     : ()
                                          =>
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
                                                        .call(
                                                        startTripDataSnapshot
                                                            .data!);
                                                  },
                                                  child: CircleAvatar(
                                                      backgroundColor:
                                                      Colors.white,
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

                              ///odometer

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
                                               padding: EdgeInsets.all(16.0),
                                               shape: RoundedRectangleBorder(
                                                   borderRadius:
                                                   BorderRadius.circular(
                                                       8.0)),
                                             ),


                                              onPressed: (){


                                                Navigator.pushNamed(
                                                  context,
                                                  '/odometer_inspection_ui',
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
