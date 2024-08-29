import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/guest_trip_details_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/guest_trip_details_response.dart';
import 'package:ridealike/pages/trips/response_model/inspection_info_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/custom_buttom.dart';
import 'package:photo_view/photo_view_gallery.dart';
class RentoutGuestEndTripDetails extends StatefulWidget {
  @override
  State createState() => RentoutGuestEndTripDetailsState();
}

class RentoutGuestEndTripDetailsState
    extends State<RentoutGuestEndTripDetails> {
  final startTripBloc = GuestTripDetailsBloc();

//  final inspectionInfoBloc = GuestTripDetailsInfoBloc();

  TextEditingController _mileageController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  var receivedData;
  Trips? tripDetails;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Rentout Guest End Trip Details"});
  }

  @override
  Widget build(BuildContext context) {
    final receivedData = ModalRoute.of(context)!.settings.arguments as Map;

    Trips tripDetails = receivedData["tripsData"];
    InspectionInfo inspectionInfo = receivedData['inspectionData'];
    String fuelLevel = inspectionInfo.inspectionInfo!.endRental!.fuelLevel!;
    int mileage = inspectionInfo.inspectionInfo!.endRental!.mileage ?? 0;

    GuestTripDetailsResponse inspectTripStartResponse =
        GuestTripDetailsResponse(
            tripStartInspection: TripStartInspection(
                exteriorCleanliness: inspectionInfo
                    .inspectionInfo!.endRental!.exteriorCleanliness,
                interiorCleanliness: inspectionInfo
                    .inspectionInfo!.endRental!.interiorCleanliness,
                damageImageIDs: List.filled(9, ''),
                exteriorImageIDs: List.filled(9, ''),
                interiorImageIDs: List.filled(9, ''),
                dashboardImageIDs: List.filled(2, ''),
                fuelImageIDs: List.filled(1, ''),
                fuelLevel: "",
                mileageImageIDs: List.filled(1, ''),
                inspectionByUserID: tripDetails.userID,
                tripID: tripDetails.tripID));
    startTripBloc.changedStartTripData.call(inspectTripStartResponse);
    startTripBloc.changedDamageSelection.call(
        inspectionInfo.inspectionInfo!.endRental!.isNoticibleDamage! ? 2 : 1);
    _mileageController.text =
        inspectionInfo.inspectionInfo!.endRental!.mileage.toString();
    _descriptionController.text =
        inspectionInfo.inspectionInfo!.endRental!.damageDesctiption!;
    return Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<GuestTripDetailsResponse>(
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
                                      "Guest End Trip Details",
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
                                      crossAxisSpacing: 3,
                                      mainAxisSpacing: 3,
                                      crossAxisCount: 3,
                                      children: List.generate(6, (index) {
                                        String imageUrl = '';
                                        String imageId = '';
                                        if (index < startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs!.length &&
                                            startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![index] != '') {
                                          imageId = startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![index];
                                          imageUrl = '$storageServerUrl/$imageId';
                                        } else if (index < inspectionInfo.inspectionInfo!.endRental!.damageImageIDs!.length &&
                                            inspectionInfo.inspectionInfo!.endRental!.damageImageIDs![index] != '') {
                                          imageId = inspectionInfo.inspectionInfo!.endRental!.damageImageIDs![index];
                                          imageUrl = '$storageServerUrl/$imageId';
                                        }

                                        List<String> imageUrls = [];
                                        for (int i = 0; i < 6; i++) {
                                          if (i < startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs!.length &&
                                              startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![i] != '') {
                                            imageUrls.add('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![i]}');
                                          } else if (i < inspectionInfo.inspectionInfo!.endRental!.damageImageIDs!.length &&
                                              inspectionInfo.inspectionInfo!.endRental!.damageImageIDs![i] != '') {
                                            imageUrls.add('$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.damageImageIDs![i]}');
                                          } else {
                                            imageUrls.add('');
                                          }
                                        }

                                        return GestureDetector(
                                          onTap: () {
                                            if (imageId.isNotEmpty) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => Scaffold(
                                                    appBar: AppBar(),
                                                    body: Center(
                                                      child: PhotoViewGallery.builder(
                                                        scrollPhysics: BouncingScrollPhysics(),
                                                        itemCount: imageUrls.length,
                                                        builder: (context, index) {
                                                          return PhotoViewGalleryPageOptions(
                                                            imageProvider: NetworkImage(imageUrls[index]),
                                                            minScale: PhotoViewComputedScale.contained * 0.8,
                                                            maxScale: PhotoViewComputedScale.covered * 2,
                                                            heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
                                                          );
                                                        },
                                                        pageController: PageController(initialPage: index),
                                                        onPageChanged: (index) {},
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            height: 150,
                                            child: imageId.isNotEmpty
                                                ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image(
                                                fit: BoxFit.cover,
                                                image: NetworkImage(imageUrl),
                                              ),
                                            )
                                                : Container(
                                              color: Color(0xFFE0E0E0),
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                            ),
                                          ),
                                        );
                                      }),
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
                                          crossAxisSpacing: 3,
                                          mainAxisSpacing: 3,
                                          crossAxisCount: 3,
                                          children: List.generate(6, (index) {
                                            String imageUrl = '';
                                            String imageId = '';

                                            if (index < startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs!.length &&
                                                startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![index] != '') {
                                              imageId = startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![index];
                                              imageUrl = '$storageServerUrl/$imageId';
                                            } else if (index < inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs!.length &&
                                                inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs![index] != '') {
                                              imageId = inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs![index];
                                              imageUrl = '$storageServerUrl/$imageId';
                                            }

                                            List<String> imageUrls = [];
                                            for (int i = 0; i < 6; i++) {
                                              if (i < startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs!.length &&
                                                  startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![i] != '') {
                                                imageUrls.add('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs![i]}');
                                              } else if (i < inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs!.length &&
                                                  inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs![i] != '') {
                                                imageUrls.add('$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs![i]}');
                                              } else {
                                                imageUrls.add('');
                                              }
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                if (imageId.isNotEmpty) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => Scaffold(
                                                        appBar: AppBar(),
                                                        body: Center(
                                                          child: PhotoViewGallery.builder(
                                                            scrollPhysics: BouncingScrollPhysics(),
                                                            itemCount: imageUrls.length,
                                                            builder: (context, index) {
                                                              return PhotoViewGalleryPageOptions(
                                                                imageProvider: NetworkImage(imageUrls[index]),
                                                                minScale: PhotoViewComputedScale.contained * 0.8,
                                                                maxScale: PhotoViewComputedScale.covered * 2,
                                                                heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
                                                              );
                                                            },
                                                            pageController: PageController(initialPage: index),
                                                            onPageChanged: (index) {},
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                height: 150,
                                                child: imageId.isNotEmpty
                                                    ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(imageUrl),
                                                  ),
                                                )
                                                    : Container(
                                                  color: Color(0xFFE0E0E0),
                                                  child: Image.asset('icons/Scan-Placeholder.png'),
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
                                          children: List.generate(6, (index) {
                                            String imageUrl = '';
                                            String imageId = '';

                                            if (index < startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs!.length &&
                                                startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![index] != '') {
                                              imageId = startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![index];
                                              imageUrl = '$storageServerUrl/$imageId';
                                            } else if (index < inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs!.length &&
                                                inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs![index] != '') {
                                              imageId = inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs![index];
                                              imageUrl = '$storageServerUrl/$imageId';
                                            }
                                            List<String> imageUrls = [];
                                            for (int i = 0; i < 6; i++) {
                                              if (i < startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs!.length &&
                                                  startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![i] != '') {
                                                imageUrls.add('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs![i]}');
                                              } else if (i < inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs!.length &&
                                                  inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs![i] != '') {
                                                imageUrls.add('$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs![i]}');
                                              } else {
                                                imageUrls.add('');
                                              }
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                if (imageId.isNotEmpty) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => Scaffold(
                                                        appBar: AppBar(),
                                                        body: Center(
                                                          child: PhotoViewGallery.builder(
                                                            scrollPhysics: BouncingScrollPhysics(),
                                                            itemCount: imageUrls.length,
                                                            builder: (context, index) {
                                                              return PhotoViewGalleryPageOptions(
                                                                imageProvider: NetworkImage(imageUrls[index]),
                                                                minScale: PhotoViewComputedScale.contained * 0.8,
                                                                maxScale: PhotoViewComputedScale.covered * 2,
                                                                heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[index]),
                                                              );
                                                            },
                                                            pageController: PageController(initialPage: index),
                                                            onPageChanged: (index) {},
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: Container(
                                                width: double.infinity,
                                                height: double.infinity,
                                                child: imageId.isNotEmpty
                                                    ? ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: Image(
                                                    fit: BoxFit.cover,
                                                    image: NetworkImage(imageUrl),
                                                  ),
                                                )
                                                    : Container(
                                                  color: Color(0xFFE0E0E0),
                                                  child: Image.asset('icons/Scan-Placeholder.png'),
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
                                          "Select the fuel level after the trip end.",style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xFF353B50)),),
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
                                  GridView.count(
                                    primary: false,
                                    shrinkWrap: true,
                                    crossAxisSpacing: 1,
                                    mainAxisSpacing: 1,
                                    crossAxisCount: 3,
                                    children: <Widget>[
                                      GestureDetector(
                                        onTap: () {
                                          String imageUrl = startTripDataSnapshot.data!.tripStartInspection!.dashboardImageIDs![0] != ''
                                              ? '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.dashboardImageIDs![0]}'
                                              : '$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.fuelImageIDs![0]}';
                                          if (imageUrl.isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                  appBar: AppBar(),
                                                  body: Center(
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12.0),
                                                      child: PhotoView(
                                                        imageProvider: NetworkImage(imageUrl),
                                                        minScale: PhotoViewComputedScale.contained * 0.8,
                                                        maxScale: PhotoViewComputedScale.covered * 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.dashboardImageIDs![0] == '' &&
                                                inspectionInfo.inspectionInfo!.endRental!.fuelImageIDs!.length < 1
                                                ? Image.asset(
                                              'icons/Scan-Placeholder.png',
                                              fit: BoxFit.cover,
                                            )
                                                : Image.network(
                                              '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.dashboardImageIDs![0] != '' ? startTripDataSnapshot.data!.tripStartInspection!.dashboardImageIDs![0] : inspectionInfo.inspectionInfo!.endRental!.fuelImageIDs![0]}',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
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
                                                color: Colors
                                                    .grey,
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
                                        onTap: () {
                                          String imageUrl = startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0] != ''
                                              ? '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0]}'
                                              : '$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.mileageImageIDs![0]}';
                                          if (imageUrl.isNotEmpty) {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Scaffold(
                                                  appBar: AppBar(),
                                                  body: Center(
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(12.0),
                                                      child: PhotoView(
                                                        imageProvider: NetworkImage(imageUrl),
                                                        minScale: PhotoViewComputedScale.contained * 0.8,
                                                        maxScale: PhotoViewComputedScale.covered * 2,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12.0),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.grey[300],
                                            ),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0] == '' &&
                                                inspectionInfo.inspectionInfo!.endRental!.mileageImageIDs!.length < 1
                                                ? Image.asset(
                                              'icons/Scan-Placeholder.png',
                                              fit: BoxFit.cover,
                                            )
                                                : Image.network(
                                              '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0] != '' ? startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![0] : inspectionInfo.inspectionInfo!.endRental!.mileageImageIDs![0]}',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )

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
