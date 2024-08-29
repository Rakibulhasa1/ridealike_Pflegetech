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
class RentoutGuestStartTripDetails extends StatefulWidget {
  @override
  State createState() => RentoutGuestStartTripDetailsState();
}

class RentoutGuestStartTripDetailsState
    extends State<RentoutGuestStartTripDetails> {
  final startTripBloc = GuestTripDetailsBloc();

  String? damageDesctiption;
  TextEditingController _mileageController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  var receivedData;
  Trips? tripDetails;

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Rentout Guest Start Trip Details"});
  }

  @override
  Widget build(BuildContext context) {
    final receivedData = ModalRoute.of(context)!.settings.arguments as Map;

    InspectionInfo inspectionInfo = receivedData['inspectionData'];
    Trips tripDetails = receivedData["tripsData"];

    String fuelLevel = inspectionInfo.inspectionInfo!.start!.fuelLevel!;
    int mileage = inspectionInfo.inspectionInfo!.start!.mileage ?? 0;

    GuestTripDetailsResponse inspectTripStartResponse =
        GuestTripDetailsResponse(
            tripStartInspection: TripStartInspection(
                exteriorCleanliness:
                    inspectionInfo.inspectionInfo!.start!.exteriorCleanliness,
                interiorCleanliness:
                    inspectionInfo.inspectionInfo!.start!.interiorCleanliness,
                damageImageIDs: List.filled(9, ''),
                exteriorImageIDs: List.filled(9, ''),
                interiorImageIDs: List.filled(9, ''),
                fuelImageIDs: List.filled(2, ''),
                fuelLevel: "",
                mileageImageIDs: List.filled(2, ''),
                inspectionByUserID: tripDetails.userID,
                tripID: tripDetails.tripID));
    startTripBloc.changedStartTripData.call(inspectTripStartResponse);
    startTripBloc.changedDamageSelection
        .call(inspectionInfo.inspectionInfo!.start!.isNoticibleDamage! ? 2 : 1);
    _mileageController.text =
        inspectionInfo.inspectionInfo!.start!.mileage.toString();
    _descriptionController.text =
        inspectionInfo.inspectionInfo!.start!.damageDesctiption!;
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
                                      "Guest Start Trip Details",
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 27,
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
                                      crossAxisSpacing: 3,
                                      mainAxisSpacing: 3,
                                      crossAxisCount: 3,
                                      children: List.generate(3, (i) {
                                        int index = startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs!.length - 3 + i;
                                        final damageImageID = startTripDataSnapshot.data?.tripStartInspection?.damageImageIDs?[index] ?? '';
                                        final inspectionImageID = inspectionInfo.inspectionInfo?.start?.damageImageIDs != null &&
                                            inspectionInfo.inspectionInfo!.start!.damageImageIDs!.length > index
                                            ? inspectionInfo.inspectionInfo!.start!.damageImageIDs![index]
                                            : '';
                                        final imageUrl = damageImageID.isNotEmpty ? damageImageID : inspectionImageID;
                                        final hasImage = imageUrl.isNotEmpty;
                                        List<String> imageUrls = [];
                                        for (int i = 0; i < 3; i++) {
                                          int idx = startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs!.length - 3 + i;
                                          String imgID = startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![idx] != ''
                                              ? startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![idx]
                                              : (inspectionInfo.inspectionInfo?.start?.damageImageIDs != null &&
                                              inspectionInfo.inspectionInfo!.start!.damageImageIDs!.length > idx)
                                              ? inspectionInfo.inspectionInfo!.start!.damageImageIDs![idx]
                                              : '';
                                          imageUrls.add('$storageServerUrl/$imgID');
                                        }

                                        return GestureDetector(
                                          onTap: () {
                                            if (hasImage) {
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
                                                        pageController: PageController(initialPage: i),
                                                        onPageChanged: (index) {},
                                                      ),
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
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                              ),
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
                                          children: List.generate(3, (i) {
                                            int index = startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs!.length - 3 + i;
                                            final exteriorImageIDs = startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs!;
                                            final inspectionExteriorImageIDs = inspectionInfo.inspectionInfo?.start?.exteriorImageIDs;

                                            final imageUrl = exteriorImageIDs[index].isNotEmpty
                                                ? '$storageServerUrl/${exteriorImageIDs[index]}'
                                                : inspectionExteriorImageIDs != null && inspectionExteriorImageIDs.length > index
                                                ? '$storageServerUrl/${inspectionExteriorImageIDs[index]}'
                                                : '';

                                            final hasImage = imageUrl.isNotEmpty;
                                            List<String> imageUrls = [];
                                            for (int i = 0; i < 3; i++) {
                                              int idx = startTripDataSnapshot.data!.tripStartInspection!.exteriorImageIDs!.length - 3 + i;
                                              String imgID = exteriorImageIDs[idx].isNotEmpty
                                                  ? exteriorImageIDs[idx]
                                                  : (inspectionExteriorImageIDs != null && inspectionExteriorImageIDs.length > idx)
                                                  ? inspectionExteriorImageIDs[idx]
                                                  : '';
                                              imageUrls.add('$storageServerUrl/$imgID');
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                if (hasImage) {
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
                                                            pageController: PageController(initialPage: i),
                                                            onPageChanged: (index) {},
                                                          ),
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
                                                  imageUrl,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
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
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFE0E0E0),
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
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
                                          crossAxisSpacing: 3,
                                          mainAxisSpacing: 3,
                                          crossAxisCount: 3,
                                          children: List.generate(3, (i) {
                                            int index = startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs!.length - 3 + i;
                                            final interiorImageIDs = startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs!;
                                            final inspectionInteriorImageIDs = inspectionInfo.inspectionInfo?.start?.interiorImageIDs;

                                            final imageUrl = interiorImageIDs[index].isNotEmpty
                                                ? '$storageServerUrl/${interiorImageIDs[index]}'
                                                : inspectionInteriorImageIDs != null && inspectionInteriorImageIDs.length > index
                                                ? '$storageServerUrl/${inspectionInteriorImageIDs[index]}'
                                                : '';

                                            final hasImage = imageUrl.isNotEmpty;
                                            List<String> imageUrls = [];
                                            for (int i = 0; i < 3; i++) {
                                              int idx = startTripDataSnapshot.data!.tripStartInspection!.interiorImageIDs!.length - 3 + i;
                                              String imgID = interiorImageIDs[idx].isNotEmpty
                                                  ? interiorImageIDs[idx]
                                                  : (inspectionInteriorImageIDs != null && inspectionInteriorImageIDs.length > idx)
                                                  ? inspectionInteriorImageIDs[idx]
                                                  : '';
                                              imageUrls.add('$storageServerUrl/$imgID');
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                if (hasImage) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => Scaffold(
                                                        appBar: AppBar(),
                                                        body: Center(
                                                          child: PhotoViewGallery.builder(
                                                            scrollPhysics: BouncingScrollPhysics(),
                                                            itemCount: imageUrls.length,
                                                            builder: (context, pageIndex) {
                                                              return PhotoViewGalleryPageOptions(
                                                                imageProvider: NetworkImage(imageUrls[pageIndex]),
                                                                minScale: PhotoViewComputedScale.contained * 0.8,
                                                                maxScale: PhotoViewComputedScale.covered * 2,
                                                                heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[pageIndex]),
                                                              );
                                                            },
                                                            pageController: PageController(initialPage: i),
                                                            onPageChanged: (pageIndex) {},
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(12),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: hasImage ? Colors.transparent : Color(0xFFE0E0E0),
                                                  ),
                                                  child: hasImage
                                                      ? Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    height: double.infinity,
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
                                                      : Center(
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
                                        "Select the fuel level before the trip start.",
                                        style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50)),
                                      ),
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Scaffold(
                                                appBar: AppBar(),
                                                body: Container(
                                                  child: PhotoView(
                                                    imageProvider: NetworkImage(
                                                      '${storageServerUrl}/${startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![1] != "" ? startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![1] : inspectionInfo.inspectionInfo!.start!.fuelImageIDs![1]}',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![1] == '' &&
                                            inspectionInfo.inspectionInfo!.start!.fuelImageIDs!.length < 2
                                            ? Container(
                                          child: Image.asset('icons/Scan-Placeholder.png'),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE0E0E0),
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        )
                                            : Container(
                                          alignment: Alignment.bottomCenter,
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                '${storageServerUrl}/${startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![1] != "" ? startTripDataSnapshot.data!.tripStartInspection!.fuelImageIDs![1] : inspectionInfo.inspectionInfo!.start!.fuelImageIDs![1]}',
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                            borderRadius: BorderRadius.circular(12.0),
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
                                            enabled: false,
                                            controller: _mileageController,
                                            decoration: InputDecoration(
                                              hintText: "Enter Mileage",
                                              hintStyle: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Colors.grey,
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Scaffold(
                                                appBar: AppBar(),
                                                body: Container(
                                                  child: PhotoView(
                                                    imageProvider: NetworkImage(
                                                      '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![1] != "" ? startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![1] : inspectionInfo.inspectionInfo!.start!.mileageImageIDs![1]}',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![1] == '' &&
                                            inspectionInfo.inspectionInfo!.start!.mileageImageIDs!.length < 2
                                            ? Container(
                                          child: Image.asset('icons/Scan-Placeholder.png'),
                                          decoration: BoxDecoration(
                                            color: Color(0xFFE0E0E0),
                                            borderRadius: BorderRadius.circular(12.0),
                                          ),
                                        )
                                            : Container(
                                          alignment: Alignment.bottomCenter,
                                          width: 100,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            image: DecorationImage(
                                              image: NetworkImage(
                                                '$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![1] != "" ? startTripDataSnapshot.data!.tripStartInspection!.mileageImageIDs![1] : inspectionInfo.inspectionInfo!.start!.mileageImageIDs![1]}',
                                              ),
                                              fit: BoxFit.fill,
                                            ),
                                            borderRadius: BorderRadius.circular(12.0),
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
