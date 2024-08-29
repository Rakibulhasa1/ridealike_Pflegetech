import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/rent_out_inspect_bloc.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_guest_request.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/inspection_info_response.dart';
import 'package:ridealike/pages/trips/response_model/rent_out_inspect_trips_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/custom_buttom.dart';
import 'package:ridealike/widgets/radio_button.dart';
import 'package:ridealike/widgets/rectangle_box.dart';
import 'package:ridealike/widgets/toggle_box.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class HostEndTripDetails extends StatefulWidget {
  @override
  State createState() => HostEndTripDetailsState();
}

class HostEndTripDetailsState extends State<HostEndTripDetails> {
  final rentOutInspectBloc = RentOutInspectBloc();

//  final inspectionInfoBloc = GuestTripDetailsInfoBloc();

  TextEditingController _mileageController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController ticketsamount = TextEditingController();

  var receivedData;
  Trips? tripDetails;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Host End Trip Details"});
  }

  @override
  Widget build(BuildContext context) {
    final receivedData = ModalRoute.of(context)!.settings.arguments as Map;

    Trips tripDetails = receivedData["tripsData"];
    InspectionInfo inspectionInfo = receivedData['inspectionData'];
    String fuelLevel = inspectionInfo.inspectionInfo!.endRentout!.fuelLevel!;
    int mileage = inspectionInfo.inspectionInfo!.endRentout!.mileage ?? 0;

    InspectTripEndRentoutResponse inspectTripStartResponse =
        InspectTripEndRentoutResponse(
            tripEndInspectionRentout: TripEndInspectionRentout(
                exteriorCleanliness: inspectionInfo
                    .inspectionInfo!.endRentout!.exteriorCleanliness,
                interiorCleanliness: inspectionInfo
                    .inspectionInfo!.endRentout!.interiorCleanliness,
                isTicketsTolls:
                    inspectionInfo.inspectionInfo!.endRentout!.isTicketsTolls,
                damageImageIDs: List.filled(9, ''),
                exteriorImageIDs: List.filled(9, ''),
                interiorImageIDs: List.filled(9, ''),
                fuelImageIDs: List.filled(2, ''),
                fuelLevel: "",
                pickUpFee: inspectionInfo.inspectionInfo!.endRentout!.pickUpFee,
                dropOffFee:
                    inspectionInfo.inspectionInfo!.endRentout!.dropOffFee,
                kmFee: inspectionInfo.inspectionInfo!.endRentout!.kmFee,
                isAddedMileageWithinAllocated: false,
                exteriorCleanFee:
                    inspectionInfo.inspectionInfo!.endRentout!.exteriorCleanFee,
                interiorCleanFee:
                    inspectionInfo.inspectionInfo!.endRentout!.interiorCleanFee,
                fuelFee: inspectionInfo.inspectionInfo!.endRentout!.fuelFee,
                isFuelSameLevelAsBefore: false,
                ticketsTollsReimbursement: TicketsTollsReimbursement(
                    imageIDs: List.filled(3, ''), amount: 0, description: ''),
                damageDesctiption: "",
                mileageImageIDs: List.filled(2, ''),
                inspectionByUserID: tripDetails.userID,
                tripID: tripDetails.tripID));
    rentOutInspectBloc.changedInspectData.call(inspectTripStartResponse);
    rentOutInspectBloc.changedDamageSelection.call(
        inspectionInfo.inspectionInfo!.endRentout!.isNoticibleDamage! ? 2 : 1);
    _mileageController.text =
        inspectionInfo.inspectionInfo!.endRentout!.mileage.toString();
    ticketsamount.text =
        inspectionInfo.inspectionInfo!.endRentout!.mileage.toString();
    _descriptionController.text =
        inspectionInfo.inspectionInfo!.endRentout!.damageDesctiption!;
    return Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<InspectTripEndRentoutResponse>(
          stream: rentOutInspectBloc.inspectData,
          builder: (context, inspectDataSnapshot) {
            return inspectDataSnapshot.hasData &&
                    inspectDataSnapshot.data != null
                ? StreamBuilder<int>(
                    stream: rentOutInspectBloc.damageSelection,
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
                                      "Host End Trip Details",
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
                                          "Any noticeable damage after the trip?",
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
                                                  inspectDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRentout!
                                                      .isNoticibleDamage = false;
                                                  rentOutInspectBloc
                                                      .changedInspectData
                                                      .call(inspectDataSnapshot
                                                          .data!);
                                                  rentOutInspectBloc
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
                                                  inspectDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRentout!
                                                      .isNoticibleDamage = true;
                                                  rentOutInspectBloc
                                                      .changedInspectData
                                                      .call(inspectDataSnapshot
                                                          .data!);
                                                  rentOutInspectBloc
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
                                      crossAxisSpacing: 3,
                                      mainAxisSpacing: 3,
                                      crossAxisCount: 3,
                                      children: List.generate(3, (index) {
                                        int imageIndex = inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs!.length - 3 + index;
                                        String damageImageID = inspectDataSnapshot.data?.tripEndInspectionRentout?.damageImageIDs?[imageIndex] ?? '';
                                        String inspectionImageID = '';
                                        if (inspectionInfo.inspectionInfo?.endRentout?.damageImageIDs != null &&
                                            inspectionInfo.inspectionInfo!.endRentout!.damageImageIDs!.length > imageIndex) {
                                          inspectionImageID = inspectionInfo.inspectionInfo!.endRentout!.damageImageIDs![imageIndex];
                                        }
                                        String imageUrl = damageImageID.isNotEmpty ? damageImageID : inspectionImageID;
                                        bool hasImage = imageUrl.isNotEmpty;
                                        return GestureDetector(
                                          onTap: () {
                                            if (hasImage) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Scaffold(
                                                    appBar: AppBar(),
                                                    body: PhotoView(
                                                      imageProvider: NetworkImage('$storageServerUrl/$imageUrl'),
                                                      minScale: PhotoViewComputedScale.contained * 0.8,
                                                      maxScale: PhotoViewComputedScale.covered * 2,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: hasImage
                                                ? Image.network(
                                              '$storageServerUrl/$imageUrl',
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  color: Color(0xFFE0E0E0),
                                                  child: Center(
                                                    child: Text(
                                                      'Image not found',
                                                      style: TextStyle(color: Colors.red),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                                : Container(
                                              color: Color(0xFFE0E0E0),
                                              child: Center(
                                                child: Image.asset('icons/Scan-Placeholder.png'),
                                              ),
                                            ),
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
                                        "Exterior car Cleanliness after the trip",
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
                                              isSelected: inspectDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRentout!
                                                      .exteriorCleanliness ==
                                                  'Poor',
                                              press: () {
                                                inspectDataSnapshot
                                                    .data!
                                                    .tripEndInspectionRentout!
                                                    .exteriorCleanliness = 'Poor';
                                                rentOutInspectBloc
                                                    .changedInspectData
                                                    .call(inspectDataSnapshot
                                                        .data!);
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                            child: CustomButton(
                                              title: 'GOOD',
                                              isSelected: inspectDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRentout!
                                                      .exteriorCleanliness ==
                                                  'Good',
                                              press: () {
                                                inspectDataSnapshot
                                                    .data!
                                                    .tripEndInspectionRentout!
                                                    .exteriorCleanliness = 'Good';
                                                rentOutInspectBloc
                                                    .changedInspectData
                                                    .call(inspectDataSnapshot
                                                        .data!);
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                            child: CustomButton(
                                              title: 'EXCELLENT',
                                              isSelected: inspectDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRentout!
                                                      .exteriorCleanliness ==
                                                  'Excellent',
                                              press: () {
                                                inspectDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRentout!
                                                        .exteriorCleanliness =
                                                    'Excellent';
                                                rentOutInspectBloc
                                                    .changedInspectData
                                                    .call(inspectDataSnapshot
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
                                          crossAxisSpacing: 3,
                                          mainAxisSpacing: 3,
                                          crossAxisCount: 3,
                                          children: List.generate(3, (index) {
                                            int imageIndex = 3 + index;
                                            bool showPlaceholder = true;
                                            String imageUrl = '';

                                            if (inspectDataSnapshot.data?.tripEndInspectionRentout?.exteriorImageIDs != null &&
                                                inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs!.length > imageIndex &&
                                                inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![imageIndex]!.isNotEmpty) {
                                              imageUrl = inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![imageIndex]!;
                                              showPlaceholder = false;
                                            } else if (inspectionInfo.inspectionInfo?.endRentout?.exteriorImageIDs != null &&
                                                inspectionInfo.inspectionInfo!.endRentout!.exteriorImageIDs!.length > imageIndex) {
                                              imageUrl = inspectionInfo.inspectionInfo!.endRentout!.exteriorImageIDs![imageIndex]!;
                                              showPlaceholder = false;
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                if (!showPlaceholder) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => Scaffold(
                                                        appBar: AppBar(),
                                                        body: PhotoView(
                                                          imageProvider: NetworkImage('$storageServerUrl/$imageUrl'),
                                                          minScale: PhotoViewComputedScale.contained * 0.8,
                                                          maxScale: PhotoViewComputedScale.covered * 2,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: showPlaceholder
                                                    ? Container(
                                                  color: Color(0xFFE0E0E0),
                                                  child: Center(
                                                    child: Image.asset('icons/Scan-Placeholder.png'),
                                                  ),
                                                )
                                                    : Image.network(
                                                  '$storageServerUrl/$imageUrl',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Color(0xFFE0E0E0),
                                                      child: Center(
                                                        child: Text(
                                                          'Image not found',
                                                          style: TextStyle(color: Colors.red),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
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
                                      Text(
                                        "Interior car Cleanliness after the trip",
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
                                              isSelected: inspectDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRentout!
                                                      .interiorCleanliness ==
                                                  'Poor',
                                              press: () {
                                                inspectDataSnapshot
                                                    .data!
                                                    .tripEndInspectionRentout!
                                                    .interiorCleanliness = 'Poor';
                                                rentOutInspectBloc
                                                    .changedInspectData
                                                    .call(inspectDataSnapshot
                                                        .data!);
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                            child: CustomButton(
                                              title: 'GOOD',
                                              isSelected: inspectDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRentout!
                                                      .interiorCleanliness ==
                                                  'Good',
                                              press: () {
                                                inspectDataSnapshot
                                                    .data!
                                                    .tripEndInspectionRentout!
                                                    .interiorCleanliness = 'Good';
                                                rentOutInspectBloc
                                                    .changedInspectData
                                                    .call(inspectDataSnapshot
                                                        .data!);
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 10.0),
                                          Expanded(
                                            child: CustomButton(
                                              title: 'EXCELLENT',
                                              isSelected: inspectDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRentout!
                                                      .interiorCleanliness ==
                                                  'Excellent',
                                              press: () {
                                                inspectDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRentout!
                                                        .interiorCleanliness =
                                                    'Excellent';
                                                rentOutInspectBloc
                                                    .changedInspectData
                                                    .call(inspectDataSnapshot
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
                                          crossAxisSpacing: 3,
                                          mainAxisSpacing: 3,
                                          crossAxisCount: 3,
                                          children: List.generate(3, (index) {
                                            int imageIndex = 7 + index;
                                            bool showPlaceholder = true;
                                            String imageUrl = '';

                                            if (inspectDataSnapshot.data?.tripEndInspectionRentout?.interiorImageIDs != null &&
                                                inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs!.length > imageIndex &&
                                                inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![imageIndex]!.isNotEmpty) {
                                              imageUrl = inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![imageIndex]!;
                                              showPlaceholder = false;
                                            } else if (inspectionInfo.inspectionInfo?.endRentout?.interiorImageIDs != null &&
                                                inspectionInfo.inspectionInfo!.endRentout!.interiorImageIDs!.length > imageIndex) {
                                              imageUrl = inspectionInfo.inspectionInfo!.endRentout!.interiorImageIDs![imageIndex]!;
                                              showPlaceholder = false;
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                if (!showPlaceholder) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => Scaffold(
                                                        appBar: AppBar(),
                                                        body: PhotoView(
                                                          imageProvider: NetworkImage('$storageServerUrl/$imageUrl'),
                                                          minScale: PhotoViewComputedScale.contained * 0.8,
                                                          maxScale: PhotoViewComputedScale.covered * 2,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: showPlaceholder
                                                    ? Container(
                                                  color: Color(0xFFE0E0E0),
                                                  child: Center(
                                                    child: Image.asset('icons/Scan-Placeholder.png'),
                                                  ),
                                                )
                                                    : Image.network(
                                                  '$storageServerUrl/$imageUrl',
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Container(
                                                      color: Color(0xFFE0E0E0),
                                                      child: Center(
                                                        child: Text(
                                                          'Image not found',
                                                          style: TextStyle(color: Colors.red),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
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
                                          "Select the fuel level after the trip end."),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(inspectDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRentout!
                                                      .fuelLevel ==
                                                  ""
                                              ? fuelLevel
                                              : inspectDataSnapshot
                                                  .data!
                                                  .tripEndInspectionRentout!
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
                                              inspectDataSnapshot
                                                  .data!
                                                  .tripEndInspectionRentout!
                                                  .fuelLevel = value as String?;
                                              rentOutInspectBloc
                                                  .changedInspectData
                                                  .call(inspectDataSnapshot
                                                      .data!);
                                            },
                                          ),
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
                                            child: inspectDataSnapshot
                                                            .data!
                                                            .tripEndInspectionRentout!
                                                            .fuelImageIDs![1] ==
                                                        '' &&
                                                    inspectionInfo
                                                            .inspectionInfo!
                                                            .endRentout!
                                                            .fuelImageIDs!
                                                            .length <
                                                        2
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
                                                            '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![1] != "" ? inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![1] : inspectionInfo.inspectionInfo!.endRentout!.fuelImageIDs![1]}'),
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
                                            child: inspectDataSnapshot
                                                                .data!
                                                                .tripEndInspectionRentout!
                                                                .mileageImageIDs![
                                                            1] ==
                                                        '' &&
                                                    inspectionInfo
                                                            .inspectionInfo!
                                                            .endRentout!
                                                            .mileageImageIDs!
                                                            .length <
                                                        2
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
                                                            '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![1] != '' ? inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![1] : inspectionInfo.inspectionInfo!.endRentout!.mileageImageIDs![1]}'),
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
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["NO", "YES"],
                                    isSelected: [
                                      !inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .isTicketsTolls!,
                                      inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .isTicketsTolls!
                                    ],
                                    onPress: (selectedValue) {
                                      inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .isTicketsTolls = selectedValue == 1;
                                      rentOutInspectBloc.changedInspectData
                                          .call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title: "Any tickets or tolls??",
                                  subtitle:
                                      "The driver is responsible for any violations, such as speeding, red light, parking or toll tickets during their trip. Please indicate if you've received any of these. You can also get reimbursement for tickets later.",
                                ),
                                SizedBox(height: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tickets and tolls amount",
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32)),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius:
                                              BorderRadius.circular(8.0)),
                                      child: TextField(
                                        controller: ticketsamount,
                                        enabled: inspectDataSnapshot
                                            .data!
                                            .tripEndInspectionRentout!
                                            .isTicketsTolls,
                                        onChanged: (amount) {
                                          inspectDataSnapshot
                                                  .data!
                                                  .tripEndInspectionRentout!
                                                  .ticketsTollsReimbursement!
                                                  .amount =
                                              int.parse(amount.toString());
                                          rentOutInspectBloc.changedInspectData
                                              .call(inspectDataSnapshot.data!);
                                        },
                                        textInputAction: TextInputAction.done,
                                        decoration: InputDecoration(
                                            contentPadding:
                                                EdgeInsets.all(14.0),
                                            border: InputBorder.none,
                                            labelStyle: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 12,
                                              color: Color(0xFF353B50),
                                            ),
                                            hintText: 'Enter amount',
                                            counterText: ""),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                RectangleBox(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tickets and tolls photos",
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 16,
                                            color: Color(0xFF371D32)),
                                      ),
                                      Padding(
                                        padding:
                                            EdgeInsets.only(top: 0, bottom: 10),
                                        child: Text(
                                          "Take photos of violations so the date, time and location are clearly visible.",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xFF353B50)),
                                        ),
                                      ),
                                      GridView.count(
                                        primary: false,
                                        shrinkWrap: true,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                        crossAxisCount: 3,
                                        children: <Widget>[
                                          GestureDetector(
                                            child: inspectDataSnapshot
                                                            .data!
                                                            .tripEndInspectionRentout!
                                                            .ticketsTollsReimbursement!
                                                            .imageIDs![0] ==
                                                        '' &&
                                                    inspectionInfo
                                                            .inspectionInfo!
                                                            .endRentout!
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
                                                            '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![0] != "" ? inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![0] : inspectionInfo.inspectionInfo!.endRentout!.fuelImageIDs![0]}'),
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
                                          GestureDetector(
                                            child: inspectDataSnapshot
                                                            .data!
                                                            .tripEndInspectionRentout!
                                                            .ticketsTollsReimbursement!
                                                            .imageIDs![1] ==
                                                        '' &&
                                                    inspectionInfo
                                                            .inspectionInfo!
                                                            .endRentout!
                                                            .fuelImageIDs!
                                                            .length <
                                                        2
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
                                                            '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![1] != "" ? inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![1] : inspectionInfo.inspectionInfo!.endRentout!.fuelImageIDs![1]}'),
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
                                SizedBox(height: 20),
                                StreamBuilder<RateTripGuestRequest>(
                                    stream: rentOutInspectBloc.rateTripGuest,
                                    builder: (context, rateTripGuestSnapshot) {
                                      return rateTripGuestSnapshot.hasData &&
                                              rateTripGuestSnapshot.data != null
                                          ? Container(
                                              padding: EdgeInsets.all(5.0),
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                color: Color(0xfff2f2f2),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(6)),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: <Widget>[
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0,
                                                                right: 16.0,
                                                                top: 10),
                                                        child: Text(
                                                          "Rate your guest",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 16,
                                                              color: Color(
                                                                  0xFF371D32)),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0,
                                                                right: 8.0,
                                                                top: 10),
                                                        child: SmoothStarRating(
                                                            allowHalfRating:
                                                                false,
                                                            onRatingChanged:
                                                                (v) {
                                                              rateTripGuestSnapshot
                                                                      .data!
                                                                      .rateGuest =
                                                                  v.toStringAsFixed(
                                                                      0);
                                                              rentOutInspectBloc
                                                                  .changedRateTripGuest
                                                                  .call(rateTripGuestSnapshot
                                                                      .data!);
                                                            },
                                                            starCount: 5,
                                                            size: 20.0,
                                                            color: Color(
                                                                0xffFF8F68),
                                                            borderColor: Color(
                                                                0xffFF8F68),
                                                            spacing: 0.0),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 8.0,
                                                            right: 16.0),
                                                    child: TextField(
                                                      maxLines: 5,
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      onChanged: (description) {
                                                        rateTripGuestSnapshot
                                                                .data!
                                                                .reviewGuestDescription =
                                                            description
                                                                .toString();
                                                        rentOutInspectBloc
                                                            .changedRateTripGuest
                                                            .call(
                                                                rateTripGuestSnapshot
                                                                    .data!);
                                                      },
                                                      decoration: InputDecoration(
                                                          hintText:
                                                              'Write a review (optional)',
                                                          hintStyle: TextStyle(
                                                              fontFamily:
                                                                  'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(
                                                                  0xFF686868),
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic),
                                                          border:
                                                              InputBorder.none),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container();
                                    }),
                                Divider(),
                                SizedBox(height: 10),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["YES", "NO"],
                                    isSelected: [
                                      inspectDataSnapshot.data!
                                          .tripEndInspectionRentout!.pickUpFee!,
                                      !inspectDataSnapshot.data!
                                          .tripEndInspectionRentout!.pickUpFee!
                                    ],
                                    onPress: (selectedValue) {
                                      inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .pickUpFee = selectedValue == 0;
                                      if (inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .pickUpFee!) {
                                        inspectDataSnapshot
                                            .data!
                                            .tripEndInspectionRentout!
                                            .requestedChargeForFuel = 0;
                                      }
                                      rentOutInspectBloc.changedInspectData
                                          .call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title:
                                      "Do you want to charge you guest for Pickup Fee?",
                                ),
                                SizedBox(height: 10),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["YES", "NO"],
                                    isSelected: [
                                      inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .dropOffFee!,
                                      !inspectDataSnapshot.data!
                                          .tripEndInspectionRentout!.dropOffFee!
                                    ],
                                    onPress: (selectedValue) {
                                      inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .dropOffFee = selectedValue == 0;
                                      if (inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .dropOffFee!) {
                                        inspectDataSnapshot
                                            .data!
                                            .tripEndInspectionRentout!
                                            .kmOverTheLimit = 0;
                                      }
                                      rentOutInspectBloc.changedInspectData
                                          .call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title:
                                      "Do you want to charge you guest for dropoff fee?",
                                ),
                                SizedBox(height: 10),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["YES", "NO"],
                                    isSelected: [
                                      inspectDataSnapshot.data!
                                          .tripEndInspectionRentout!.kmFee!,
                                      !inspectDataSnapshot.data!
                                          .tripEndInspectionRentout!.kmFee!
                                    ],
                                    onPress: (selectedValue) {
                                      inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .kmFee = selectedValue == 0;
                                      if (inspectDataSnapshot.data!
                                          .tripEndInspectionRentout!.kmFee!) {
                                        inspectDataSnapshot
                                            .data!
                                            .tripEndInspectionRentout!
                                            .kmOverTheLimit = 0;
                                      }
                                      rentOutInspectBloc.changedInspectData
                                          .call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title:
                                      "Do you want to charge you guest with ${tripDetails.car!.preference!.limit}km for Extra Mileage useage??",
                                ),
                                SizedBox(height: 10),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["YES", "NO"],
                                    isSelected: [
                                      inspectDataSnapshot.data!
                                          .tripEndInspectionRentout!.fuelFee!,
                                      !inspectDataSnapshot.data!
                                          .tripEndInspectionRentout!.fuelFee!
                                    ],
                                    onPress: (selectedValue) {
                                      inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .fuelFee = selectedValue == 0;
                                      if (inspectDataSnapshot.data!
                                          .tripEndInspectionRentout!.fuelFee!) {
                                        inspectDataSnapshot
                                            .data!
                                            .tripEndInspectionRentout!
                                            .kmOverTheLimit = 0;
                                      }
                                      rentOutInspectBloc.changedInspectData
                                          .call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title:
                                      "Do you want to charge you guest for Low Fuel??",
                                ),
                                SizedBox(height: 10),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["YES", "NO"],
                                    isSelected: [
                                      inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .exteriorCleanFee!,
                                      !inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .exteriorCleanFee!
                                    ],
                                    onPress: (selectedValue) {
                                      inspectDataSnapshot
                                              .data!
                                              .tripEndInspectionRentout!
                                              .exteriorCleanFee =
                                          selectedValue == 0;
                                      if (inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .exteriorCleanFee!) {
                                        inspectDataSnapshot
                                            .data!
                                            .tripEndInspectionRentout!
                                            .kmOverTheLimit = 0;
                                      }
                                      rentOutInspectBloc.changedInspectData
                                          .call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title:
                                      "Do you want to charge you guest for exterior cleanliness",
                                ),
                                SizedBox(height: 10),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["YES", "NO"],
                                    isSelected: [
                                      inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .interiorCleanFee!,
                                      !inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .interiorCleanFee!
                                    ],
                                    onPress: (selectedValue) {
                                      inspectDataSnapshot
                                              .data!
                                              .tripEndInspectionRentout!
                                              .interiorCleanFee =
                                          selectedValue == 0;
                                      if (inspectDataSnapshot
                                          .data!
                                          .tripEndInspectionRentout!
                                          .interiorCleanFee!) {
                                        inspectDataSnapshot
                                            .data!
                                            .tripEndInspectionRentout!
                                            .kmOverTheLimit = 0;
                                      }
                                      rentOutInspectBloc.changedInspectData
                                          .call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title:
                                      "Do you want to charge you guest for interior cleanliness",
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
