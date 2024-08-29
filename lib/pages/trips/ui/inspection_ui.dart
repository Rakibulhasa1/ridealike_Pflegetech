import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:photo_view/photo_view.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/inspection_info_bloc.dart';
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
import 'package:photo_view/photo_view_gallery.dart';
class InspectionUi extends StatefulWidget {
  static const String routeName = "/inspect";

  @override
  _InspectionUiState createState() => _InspectionUiState();
}

class _InspectionUiState extends State<InspectionUi> {
  final rentOutInspectBloc = RentOutInspectBloc();
  final inspectionInfoBloc = InspectionInfoBloc();
  String fuelLevel = "Select the suitable option";
  int? mileage;
  double rating = 0;
  bool shouldUpdateButtonValue = true;
  var receivedData;
  Trips? tripDetails;
  TextEditingController mileageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController rateGuestController = TextEditingController();
  FocusNode _damageDesctiptionfocusNode = FocusNode();
  FocusNode _mileagefocusNode = FocusNode();
  FocusNode _amountfocusNode = FocusNode();
  FocusNode _rateguestfocusNode = FocusNode();

  @override
  void dispose() {
    _damageDesctiptionfocusNode.dispose();
    _amountfocusNode.dispose();
    _rateguestfocusNode.dispose();
    _mileagefocusNode.dispose();
    super.dispose();
  }

  void _handleTapOutside() {
    _damageDesctiptionfocusNode.unfocus();
    _mileagefocusNode.unfocus();
    _rateguestfocusNode.unfocus();
    _amountfocusNode.unfocus();
  }

  void _settingModalBottomSheet(context, _imgOrder,
      AsyncSnapshot<InspectTripEndRentoutResponse> inspectDataSnapshot) {
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
                    rentOutInspectBloc.pickeImageThroughCamera(
                        _imgOrder, inspectDataSnapshot, context);
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
                    rentOutInspectBloc.pickeImageFromGallery(
                        _imgOrder, inspectDataSnapshot, context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
              ],
            ),
          );
        });
  }

  final TextEditingController _enterAmountController = TextEditingController();

  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Inspection"});
  }

  @override
  Widget build(BuildContext context) {
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

    Trips tripDetails = receivedData['trip'];
    Trips tripDetail = receivedData["tripsData"];
    String tripType = receivedData['tripType'];
    String? onBackPress = receivedData['onBackPress'];
    String? path = receivedData['PATH'];
    InspectionInfo? inspectionInfo = receivedData['inspectionData'];
    String fuelLevel = inspectionInfo!.inspectionInfo!.endRental!.fuelLevel!;

    mileageController.text =
        inspectionInfo.inspectionInfo!.endRental!.mileage.toString();
    descriptionController.text =
        inspectionInfo.inspectionInfo!.endRental!.damageDesctiption!;
    InspectTripEndRentoutResponse response = InspectTripEndRentoutResponse(
        tripEndInspectionRentout: TripEndInspectionRentout(
            inspectionByUserID: tripDetails.hostUserID,
            tripID: tripDetails.tripID,
            damageDesctiption: '',
            fuelLevel: '',
            fuelImageIDs: List.filled(2, ''),
            mileage: 0,
            mileageImageIDs: List.filled(2, ''),
            pickUpFee: false,
            dropOffFee: false,
            kmFee: false,
            damageImageIDs: List.filled(12, ''),
            exteriorImageIDs: List.filled(12, ''),
            interiorImageIDs: List.filled(12, ''),
            isNoticibleDamage: false,
            interiorCleanliness:
                inspectionInfo.inspectionInfo!.endRental!.interiorCleanliness,
            exteriorCleanliness:
                inspectionInfo.inspectionInfo!.endRental!.exteriorCleanliness,
            cleanliness: 'Poor',
            isAddedMileageWithinAllocated: false,
            exteriorCleanFee: false,
            interiorCleanFee: false,
            fuelFee: false,
            isFuelSameLevelAsBefore: false,
            isTicketsTolls: false,
            kmOverTheLimit: 120,
            requestedChargeForFuel: 25,
            ticketsTollsReimbursement: TicketsTollsReimbursement(
                imageIDs: List.filled(3, ''), amount: 0, description: '')));
    RateTripGuestRequest rateTripGuestRequest = RateTripGuestRequest(
        tripID: tripDetails.tripID,
        inspectionByUserID: tripDetails.userID,
        rateGuest: '0',
        reviewGuestDescription: '');

    rentOutInspectBloc.changedInspectData.call(response);
    rentOutInspectBloc.changedRateTripGuest.call(rateTripGuestRequest);
    rentOutInspectBloc.changedDamageSelection.call(0);
    rentOutInspectBloc.changedInspectData.call(response);
    rentOutInspectBloc.changedDamageSelection.call(
        inspectionInfo.inspectionInfo!.endRental!.isNoticibleDamage! ? 2 : 1);

    return GestureDetector(
      onTap: _handleTapOutside,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
          title: InkWell(
            onTap: () {
              if (onBackPress != null && onBackPress == 'PUSH') {
                Navigator.of(context).pushNamed(path!,
                    arguments: {'tripType': tripType, 'trip': tripDetails});
              } else {
                Navigator.of(context).pop();
              }
            },
            child: IntrinsicWidth(
              child: Container(
                height: 56,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Color(0xFFFF8F62),
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
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
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Inspect your \nvehicle",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 36,
                                                color: Color(0xFF371D32),
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Center(
                                            child: (tripDetails.carImageId !=
                                                        null ||
                                                    tripDetails.carImageId !=
                                                        '')
                                                ? CircleAvatar(
                                                    backgroundImage: NetworkImage(
                                                        '$storageServerUrl/${tripDetails.carImageId}'),
                                                    radius: 25,
                                                  )
                                                : CircleAvatar(
                                                    backgroundImage: AssetImage(
                                                        'images/car-placeholder.png'),
                                                    radius: 25,
                                                  ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 32),
                                      ToggleBox(
                                        title: "Any new damage after the trip?",
                                        toggleButtons: RadioButton(
                                          items: ["NO", "YES"],
                                          isSelected: [
                                            damageSelectionSnapshot.data == 1,
                                            damageSelectionSnapshot.data == 2
                                          ],
                                          onPress: (selectedValue) {
                                            rentOutInspectBloc
                                                .changedDamageSelection
                                                .call(selectedValue + 1);
                                            inspectDataSnapshot
                                                    .data!
                                                    .tripEndInspectionRentout!
                                                    .isNoticibleDamage =
                                                (selectedValue == 1);
                                            rentOutInspectBloc
                                                .changedInspectData
                                                .call(
                                                    inspectDataSnapshot.data!);
                                          },
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      RectangleBox(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Take photos of new damage",
                                              style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 16,
                                                  color: Color(0xFF371D32)),
                                            ),
                                            SizedBox(height: 10),
                                            GridView.count(
                                              primary: false,
                                              shrinkWrap: true,
                                              crossAxisSpacing: 3,
                                              mainAxisSpacing: 3,
                                              crossAxisCount: 3,
                                              children: List.generate(6, (index) {
                                                bool hasDamageImage = inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![index] != null &&
                                                    inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![index]!.isNotEmpty;
                                                bool hasEndRentalImage = inspectionInfo.inspectionInfo!.endRental!.damageImageIDs!.length > index;

                                                String imageUrl = hasDamageImage
                                                    ? '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![index]}'
                                                    : hasEndRentalImage
                                                    ? '$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.damageImageIDs![index]}'
                                                    : '';
                                                List<String> imageUrls = [];
                                                for (int i = 0; i < inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs!.length; i++) {
                                                  if (inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![i]!.isNotEmpty) {
                                                    imageUrls.add('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![i]}');
                                                  }
                                                }
                                                for (int i = 0; i < inspectionInfo.inspectionInfo!.endRental!.damageImageIDs!.length; i++) {
                                                  if (inspectionInfo.inspectionInfo!.endRental!.damageImageIDs![i].isNotEmpty) {
                                                    imageUrls.add('$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.damageImageIDs![i]}');
                                                  }
                                                }

                                                return GestureDetector(
                                                  onTap: () {
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
                                                              pageController: PageController(initialPage: index),
                                                              onPageChanged: (pageIndex) {},
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8.0),
                                                    child: imageUrl.isEmpty
                                                        ? Container(
                                                      color: Color(0xFFE0E0E0),
                                                      child: Image.asset('icons/Scan-Placeholder.png'),
                                                    )
                                                        : Image(
                                                      fit: BoxFit.cover,
                                                      image: NetworkImage(imageUrl),
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
                                                            7,
                                                            inspectDataSnapshot),
                                                    child: inspectDataSnapshot
                                                                .data!
                                                                .tripEndInspectionRentout!
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
                                                                  BorderRadius.all(Radius.circular(8)),
                                                            ),
                                                          )
                                                        : Stack(children: <Widget>[
                                                            SizedBox(
                                                                child: Image(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: NetworkImage(
                                                                      '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![6]}'),
                                                                ),
                                                                width: double
                                                                    .maxFinite),
                                                            Positioned(
                                                              right: 5,
                                                              bottom: 5,
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    inspectDataSnapshot
                                                                        .data!
                                                                        .tripEndInspectionRentout!
                                                                        .damageImageIDs![6] = '';
                                                                    rentOutInspectBloc
                                                                        .changedInspectData
                                                                        .call(inspectDataSnapshot
                                                                            .data!);
                                                                  },
                                                                  child: CircleAvatar(
                                                                      backgroundColor: Colors.white,
                                                                      radius: 10,
                                                                      child: Icon(
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
                                                    onTap: () =>
                                                        _settingModalBottomSheet(
                                                            context,
                                                            8,
                                                            inspectDataSnapshot),
                                                    child: inspectDataSnapshot
                                                                .data!
                                                                .tripEndInspectionRentout!
                                                                .damageImageIDs![7] ==
                                                            ''
                                                        ? Container(
                                                            child: Image.asset(
                                                                'icons/Scan-Placeholder.png'),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Color(
                                                                  0xFFE0E0E0),
                                                                  borderRadius:
                                                                  BorderRadius.all(Radius.circular(8)),
                                                            ),
                                                          )
                                                        : Stack(children: <Widget>[
                                                            SizedBox(
                                                                child: Image(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: NetworkImage(
                                                                      '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![7]}'),
                                                                ),
                                                                width: double
                                                                    .maxFinite),
                                                            Positioned(
                                                              right: 5,
                                                              bottom: 5,
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    inspectDataSnapshot
                                                                        .data!
                                                                        .tripEndInspectionRentout!
                                                                        .damageImageIDs![7] = '';
                                                                    rentOutInspectBloc
                                                                        .changedInspectData
                                                                        .call(inspectDataSnapshot
                                                                            .data!);
                                                                  },
                                                                  child: CircleAvatar(
                                                                      backgroundColor: Colors.white,
                                                                      radius: 10,
                                                                      child: Icon(
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
                                                    onTap: () =>
                                                        _settingModalBottomSheet(
                                                            context,
                                                            9,
                                                            inspectDataSnapshot),
                                                    child: inspectDataSnapshot
                                                                .data!
                                                                .tripEndInspectionRentout!
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
                                                                  BorderRadius.all(Radius.circular(8)),
                                                            ),
                                                          )
                                                        : Stack(children: <Widget>[
                                                            SizedBox(
                                                                child: Image(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: NetworkImage(
                                                                      '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![8]}'),
                                                                ),
                                                                width: double
                                                                    .maxFinite),
                                                            Positioned(
                                                              right: 5,
                                                              bottom: 5,
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    inspectDataSnapshot
                                                                        .data!
                                                                        .tripEndInspectionRentout!
                                                                        .damageImageIDs![8] = '';
                                                                    rentOutInspectBloc
                                                                        .changedInspectData
                                                                        .call(inspectDataSnapshot
                                                                            .data!);
                                                                  },
                                                                  child: CircleAvatar(
                                                                      backgroundColor: Colors.white,
                                                                      radius: 10,
                                                                      child: Icon(
                                                                        Icons
                                                                            .delete,
                                                                        color: Color(
                                                                            0xffF55A51),
                                                                        size:
                                                                            20,
                                                                      ))),
                                                            )
                                                          ])),
//
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Container(
                                        padding: EdgeInsets.all(5.0),
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                                      const EdgeInsets.only(
                                                          left: 8.0,
                                                          right: 16.0,
                                                          top: 10),
                                                  child: Text(
                                                    "Tell us about new damage",
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 16,
                                                        color:
                                                            Color(0xFF371D32)),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0, right: 16.0),
                                              child: TextField(
                                                controller:
                                                    descriptionController,
                                                focusNode:
                                                    _damageDesctiptionfocusNode,
                                                textInputAction:
                                                    TextInputAction.done,
                                                maxLines: 5,
                                                enabled: damageSelectionSnapshot
                                                        .data ==
                                                    2,
                                                onChanged: (description) {
                                                  inspectDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRentout!
                                                          .damageDesctiption =
                                                      description;
                                                  rentOutInspectBloc
                                                      .changedInspectData
                                                      .call(inspectDataSnapshot
                                                          .data!);
                                                },
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'Add a description here',
                                                    hintStyle: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color:
                                                            Color(0xFF686868),
                                                        fontStyle:
                                                            FontStyle.italic),
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
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
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
                                                          .call(
                                                              inspectDataSnapshot
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
                                                          .call(
                                                              inspectDataSnapshot
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
                                                          .call(
                                                              inspectDataSnapshot
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
                                      SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xfff2f2f2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
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
                                              bool hasExteriorImage =
                                                  inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![index] != null &&
                                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![index]!.isNotEmpty;
                                              bool hasEndRentalImage =
                                                  inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs!.length > index;

                                              String imageUrl = hasExteriorImage
                                                  ? '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![index]}'
                                                  : hasEndRentalImage
                                                  ? '$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs![index]}'
                                                  : '';

                                              List<String> imageUrls = [];
                                              for (int i = 0; i < inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs!.length; i++) {
                                                if (inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![i]!.isNotEmpty) {
                                                  imageUrls.add('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![i]}');
                                                }
                                              }
                                              for (int i = 0; i < inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs!.length; i++) {
                                                if (inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs![i].isNotEmpty) {
                                                  imageUrls.add('$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.exteriorImageIDs![i]}');
                                                }
                                              }

                                              return GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => Scaffold(
                                                        appBar: AppBar(),
                                                        body: PhotoViewGallery.builder(
                                                          scrollPhysics: const BouncingScrollPhysics(),
                                                          itemCount: imageUrls.length,
                                                          builder: (context, pageIndex) {
                                                            return PhotoViewGalleryPageOptions(
                                                              imageProvider: NetworkImage(imageUrls[pageIndex]),
                                                              minScale: PhotoViewComputedScale.contained * 0.8,
                                                              maxScale: PhotoViewComputedScale.covered * 2,
                                                              heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[pageIndex]),
                                                            );
                                                          },
                                                          pageController: PageController(initialPage: index),
                                                          onPageChanged: (pageIndex) {},
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8.0),
                                                  child: imageUrl.isEmpty
                                                      ? Container(
                                                    color: Color(0xFFE0E0E0),
                                                    child: Image.asset('icons/Scan-Placeholder.png', fit: BoxFit.cover),
                                                  )
                                                      : Image.network(
                                                    imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Container(
                                                        color: Color(0xFFE0E0E0),
                                                        child: Image.asset('icons/Scan-Placeholder.png'),
                                                      );
                                                    },
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
                                                            inspectDataSnapshot),
                                                    child: inspectDataSnapshot
                                                                .data!
                                                                .tripEndInspectionRentout!
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
                                                                  BorderRadius.all(Radius.circular(8)),
                                                            ),
                                                          )
                                                        : Stack(children: <Widget>[
                                                            SizedBox(
                                                                child: Image(
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: NetworkImage(
                                                                      '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![6]}'),
                                                                ),
                                                                width: double
                                                                    .maxFinite),
                                                            Positioned(
                                                              right: 5,
                                                              bottom: 5,
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    inspectDataSnapshot
                                                                        .data!
                                                                        .tripEndInspectionRentout!
                                                                        .exteriorImageIDs![6] = '';
                                                                    rentOutInspectBloc
                                                                        .changedInspectData
                                                                        .call(inspectDataSnapshot
                                                                            .data!);
                                                                  },
                                                                  child: CircleAvatar(
                                                                      backgroundColor: Colors.white,
                                                                      radius: 10,
                                                                      child: Icon(
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
                                                              20,
                                                              inspectDataSnapshot),
                                                      child: inspectDataSnapshot
                                                                      .data!
                                                                      .tripEndInspectionRentout!
                                                                      .exteriorImageIDs![
                                                                  7] ==
                                                              ''
                                                          ? Container(
                                                              child: Image.asset(
                                                                  'icons/Scan-Placeholder.png'),
                                                              decoration: BoxDecoration(
                                                                borderRadius:
                                                                BorderRadius.all(Radius.circular(8)),
                                                                color: Color(
                                                                    0xFFE0E0E0),
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
                                                                            '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![7]}'),
                                                                      ),
                                                                      width: double
                                                                          .maxFinite),
                                                                  Positioned(
                                                                    right: 5,
                                                                    bottom: 5,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          inspectDataSnapshot
                                                                              .data!
                                                                              .tripEndInspectionRentout!
                                                                              .exteriorImageIDs![7] = '';
                                                                          rentOutInspectBloc
                                                                              .changedInspectData
                                                                              .call(inspectDataSnapshot.data!);
                                                                        },
                                                                        child: CircleAvatar(
                                                                            backgroundColor: Colors.white,
                                                                            radius: 10,
                                                                            child: Icon(
                                                                              Icons.delete,
                                                                              color: Color(0xffF55A51),
                                                                              size: 20,
                                                                            ))),
                                                                  )
                                                                ])),
                                                  GestureDetector(
                                                      onTap: () =>
                                                          _settingModalBottomSheet(
                                                              context,
                                                              21,
                                                              inspectDataSnapshot),
                                                      child: inspectDataSnapshot
                                                                      .data!
                                                                      .tripEndInspectionRentout!
                                                                      .exteriorImageIDs![
                                                                  8] ==
                                                              ''
                                                          ? Container(
                                                              child: Image.asset(
                                                                  'icons/Scan-Placeholder.png'),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Color(
                                                                    0xFFE0E0E0),
                                                                    borderRadius:
                                                                    BorderRadius.all(Radius.circular(8)),
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
                                                                            '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.exteriorImageIDs![8]}'),
                                                                      ),
                                                                      width: double
                                                                          .maxFinite),
                                                                  Positioned(
                                                                    right: 5,
                                                                    bottom: 5,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          inspectDataSnapshot
                                                                              .data!
                                                                              .tripEndInspectionRentout!
                                                                              .exteriorImageIDs![8] = '';
                                                                          rentOutInspectBloc
                                                                              .changedInspectData
                                                                              .call(inspectDataSnapshot.data!);
                                                                        },
                                                                        child: CircleAvatar(
                                                                            backgroundColor: Colors.white,
                                                                            radius: 10,
                                                                            child: Icon(
                                                                              Icons.delete,
                                                                              color: Color(0xffF55A51),
                                                                              size: 20,
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
                                      Container(
                                        padding: const EdgeInsets.all(16.0),
                                        decoration: BoxDecoration(
                                          color: Color(0xfff2f2f2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
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
                                                            .interiorCleanliness! ==
                                                        'Poor',
                                                    press: () {
                                                      inspectDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRentout!
                                                          .interiorCleanliness = 'Poor';
                                                      rentOutInspectBloc
                                                          .changedInspectData
                                                          .call(
                                                              inspectDataSnapshot
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
                                                            .interiorCleanliness! ==
                                                        'Good',
                                                    press: () {
                                                      inspectDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRentout!
                                                          .interiorCleanliness = 'Good';
                                                      rentOutInspectBloc
                                                          .changedInspectData
                                                          .call(
                                                              inspectDataSnapshot
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
                                                            .interiorCleanliness! ==
                                                        'Excellent',
                                                    press: () {
                                                      inspectDataSnapshot
                                                              .data!
                                                              .tripEndInspectionRentout!
                                                              .interiorCleanliness =
                                                          'Excellent';
                                                      rentOutInspectBloc
                                                          .changedInspectData
                                                          .call(
                                                              inspectDataSnapshot
                                                                  .data!);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Color(0xfff2f2f2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Text(
                                                "Take photos of the car interior",
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
                                                  bool hasInteriorImage =
                                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![index] != null &&
                                                          inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![index]!.isNotEmpty;
                                                  bool hasEndRentalImage =
                                                      inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs!.length > index;

                                                  String imageUrl = hasInteriorImage
                                                      ? '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![index]}'
                                                      : hasEndRentalImage
                                                      ? '$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs![index]}'
                                                      : '';
                                                  List<String> imageUrls = [];
                                                  for (int i = 0; i < inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs!.length; i++) {
                                                    if (inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![i]!.isNotEmpty) {
                                                      imageUrls.add('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![i]}');
                                                    }
                                                  }
                                                  for (int i = 0; i < inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs!.length; i++) {
                                                    if (inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs![i].isNotEmpty) {
                                                      imageUrls.add('$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.interiorImageIDs![i]}');
                                                    }
                                                  }

                                                  return GestureDetector(
                                                    onTap: () {
                                                      if (imageUrl.isNotEmpty) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => Scaffold(
                                                              appBar: AppBar(),
                                                              body: PhotoViewGallery.builder(
                                                                scrollPhysics: const BouncingScrollPhysics(),
                                                                itemCount: imageUrls.length,
                                                                builder: (context, pageIndex) {
                                                                  return PhotoViewGalleryPageOptions(
                                                                    imageProvider: NetworkImage(imageUrls[pageIndex]),
                                                                    minScale: PhotoViewComputedScale.contained * 0.8,
                                                                    maxScale: PhotoViewComputedScale.covered * 2,
                                                                    heroAttributes: PhotoViewHeroAttributes(tag: imageUrls[pageIndex]),
                                                                  );
                                                                },
                                                                pageController: PageController(initialPage: index),
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      child: imageUrl.isNotEmpty
                                                          ? Image.network(
                                                        imageUrl,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (context, error, stackTrace) {
                                                          return Container(
                                                            color: Color(0xFFE0E0E0),
                                                            child: Image.asset('icons/Scan-Placeholder.png'),
                                                          );
                                                        },
                                                      )
                                                          : Container(
                                                        color: Color(0xFFE0E0E0),
                                                        child: Image.asset('icons/Scan-Placeholder.png'),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                              SizedBox(height: 5,),
                                          GridView.count(
                                                primary: false,
                                                shrinkWrap: true,
                                                crossAxisSpacing: 3,
                                                mainAxisSpacing: 3,
                                                crossAxisCount: 3,
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _settingModalBottomSheet(
                                                            context,
                                                            28,
                                                            inspectDataSnapshot),
                                                    child: inspectDataSnapshot
                                                                .data!
                                                                .tripEndInspectionRentout!
                                                                .interiorImageIDs![6] ==
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
                                                                  fit: BoxFit
                                                                      .fill,
                                                                  image: NetworkImage(
                                                                      '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![6]}'),
                                                                ),
                                                                width: double
                                                                    .maxFinite),
                                                            Positioned(
                                                              right: 5,
                                                              bottom: 5,
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    inspectDataSnapshot
                                                                        .data!
                                                                        .tripEndInspectionRentout!
                                                                        .interiorImageIDs![6] = '';
                                                                    rentOutInspectBloc
                                                                        .changedInspectData
                                                                        .call(inspectDataSnapshot
                                                                            .data!);
                                                                  },
                                                                  child: CircleAvatar(
                                                                      backgroundColor: Colors.white,
                                                                      radius: 10,
                                                                      child: Icon(
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
                                                              inspectDataSnapshot),
                                                      child: inspectDataSnapshot
                                                                      .data!
                                                                      .tripEndInspectionRentout!
                                                                      .interiorImageIDs![
                                                                  7] ==
                                                              ''
                                                          ? Container(
                                                              child: Image.asset(
                                                                  'icons/Scan-Placeholder.png'),
                                                              color: Color(
                                                                  0xFFE0E0E0),
                                                            )
                                                          : Stack(
                                                              children: <Widget>[
                                                                  SizedBox(
                                                                      child:
                                                                          Image(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        image: NetworkImage(
                                                                            '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![7]}'),
                                                                      ),
                                                                      width: double
                                                                          .maxFinite),
                                                                  Positioned(
                                                                    right: 5,
                                                                    bottom: 5,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          inspectDataSnapshot
                                                                              .data!
                                                                              .tripEndInspectionRentout!
                                                                              .interiorImageIDs![7] = '';
                                                                          rentOutInspectBloc
                                                                              .changedInspectData
                                                                              .call(inspectDataSnapshot.data!);
                                                                        },
                                                                        child: CircleAvatar(
                                                                            backgroundColor: Colors.white,
                                                                            radius: 10,
                                                                            child: Icon(
                                                                              Icons.delete,
                                                                              color: Color(0xffF55A51),
                                                                              size: 20,
                                                                            ))),
                                                                  )
                                                                ])),
                                                  GestureDetector(
                                                      onTap: () =>
                                                          _settingModalBottomSheet(
                                                              context,
                                                              30,
                                                              inspectDataSnapshot),
                                                      child: inspectDataSnapshot
                                                                      .data!
                                                                      .tripEndInspectionRentout!
                                                                      .interiorImageIDs![
                                                                  8] ==
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
                                                          : Stack(
                                                              children: <Widget>[
                                                                  SizedBox(
                                                                      child:
                                                                          Image(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        image: NetworkImage(
                                                                            '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.interiorImageIDs![8]}'),
                                                                      ),
                                                                      width: double
                                                                          .maxFinite),
                                                                  Positioned(
                                                                    right: 5,
                                                                    bottom: 5,
                                                                    child: InkWell(
                                                                        onTap: () {
                                                                          inspectDataSnapshot
                                                                              .data!
                                                                              .tripEndInspectionRentout!
                                                                              .interiorImageIDs![8] = '';
                                                                          rentOutInspectBloc
                                                                              .changedInspectData
                                                                              .call(inspectDataSnapshot.data!);
                                                                        },
                                                                        child: CircleAvatar(
                                                                            backgroundColor: Colors.white,
                                                                            radius: 10,
                                                                            child: Icon(
                                                                              Icons.delete,
                                                                              color: Color(0xffF55A51),
                                                                              size: 20,
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
                                      SizedBox(height: 10),
                                      Column(
                                        children: [
                                          SizedBox(height: 20),
                                          Container(
                                            padding: EdgeInsets.all(10.0),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            decoration: BoxDecoration(
                                              color: Color(0xfff2f2f2),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
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
                                                    "Select the fuel level after the trip end.",  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF353B50)),),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(inspectDataSnapshot
                                                                .data!
                                                                .tripEndInspectionRentout!
                                                                .fuelLevel ==
                                                            ''
                                                        ? fuelLevel
                                                        : inspectDataSnapshot
                                                            .data!
                                                            .tripEndInspectionRentout!
                                                            .fuelLevel!,  style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 14,
                                                        color: Color(0xFF353B50)),),
                                                    Theme(
                                                      data: Theme.of(context)
                                                          .copyWith(
                                                              canvasColor:
                                                                  Colors.white),
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
                                                                  color: Color(
                                                                      0xFF353B50)),
                                                            ),
                                                          );
                                                        }).toList(),
                                                        onChanged: (value) {
                                                          inspectDataSnapshot
                                                                  .data!
                                                                  .tripEndInspectionRentout!
                                                                  .fuelLevel =
                                                              value as String?;
                                                          rentOutInspectBloc
                                                              .changedInspectData
                                                              .call(
                                                                  inspectDataSnapshot
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
                                                  onTap: () {
                                                    String imageUrl = inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![0] != ''
                                                        ? '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![0]}'
                                                        : '$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.fuelImageIDs![0]}';

                                                    if (imageUrl.isNotEmpty) {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) => Scaffold(
                                                            appBar: AppBar(),
                                                            body: Container(
                                                              color: Colors.black,
                                                              child: PhotoView(
                                                                imageProvider: NetworkImage(imageUrl),
                                                                initialScale: PhotoViewComputedScale.contained,
                                                                minScale: PhotoViewComputedScale.contained * 0.8,
                                                                maxScale: PhotoViewComputedScale.covered * 2,
                                                                heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  child: inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![0] == '' &&
                                                      inspectionInfo.inspectionInfo!.endRental!.fuelImageIDs!.length < 1
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
                                                            '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![0] != "" ? inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![0] : inspectionInfo.inspectionInfo!.endRental!.fuelImageIDs![0]}'),
                                                        fit: BoxFit.fill,
                                                      ),
                                                      borderRadius: BorderRadius.circular(12.0),
                                                    ),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () => _settingModalBottomSheet(context, 36, inspectDataSnapshot),
                                                  child: inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![1] == ''
                                                      ? Container(
                                                    child: Image.asset('icons/Scan-Placeholder.png'),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFFE0E0E0),
                                                      borderRadius: BorderRadius.circular(12.0),
                                                    ),
                                                  )
                                                      : Stack(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        child: Image(
                                                          fit: BoxFit.fill,
                                                          image: NetworkImage(
                                                              '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![1]}'),
                                                        ),
                                                        width: double.maxFinite,
                                                      ),
                                                      Positioned(
                                                        right: 5,
                                                        bottom: 5,
                                                        child: InkWell(
                                                          onTap: () {
                                                            inspectDataSnapshot.data!.tripEndInspectionRentout!.fuelImageIDs![1] = '';
                                                            rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
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
                                                ),
                                              ],
                                            )
                                            ],
                                            ),
                                          ),
                                          SizedBox(height: 10),
                                        ],
                                      ),
                                      Container(
                                        padding: EdgeInsets.all(10.0),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Color(0xfff2f2f2),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
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
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                    child: TextField(
                                                  maxLength: 6,
                                                  focusNode: _mileagefocusNode,
                                                  onChanged: (mileage) {
                                                    inspectDataSnapshot
                                                            .data!
                                                            .tripEndInspectionRentout!
                                                            .mileage =
                                                        int.parse(
                                                            mileage.toString());
                                                    rentOutInspectBloc
                                                        .changedInspectData
                                                        .call(
                                                            inspectDataSnapshot
                                                                .data!);
                                                  },
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
                                                      child: Icon(
                                                          Icons.arrow_drop_up),
                                                      onTap: () {
                                                        int tempMileage = int.parse(
                                                                mileageController
                                                                    .text
                                                                    .toString()) +
                                                            100;
                                                        mileageController.text =
                                                            tempMileage
                                                                .toString();
                                                        mileageController
                                                                .selection =
                                                            TextSelection.fromPosition(
                                                                TextPosition(
                                                                    offset: mileageController
                                                                        .text
                                                                        .length));
                                                      },
                                                    ),
                                                    InkWell(
                                                      child: Icon(Icons
                                                          .arrow_drop_down),
                                                      onTap: () {
                                                        int tempMileage = int.parse(
                                                                mileageController
                                                                    .text
                                                                    .toString()) -
                                                            100;
                                                        mileageController.text =
                                                            tempMileage
                                                                .toString();
                                                        mileageController
                                                                .selection =
                                                            TextSelection.fromPosition(
                                                                TextPosition(
                                                                    offset: mileageController
                                                                        .text
                                                                        .length));
                                                      },
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
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
                                                String imageUrl = inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![0] != ''
                                                    ? '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![0]}'
                                                    : '$storageServerUrl/${inspectionInfo.inspectionInfo!.endRental!.mileageImageIDs![0]}';

                                                if (imageUrl.isNotEmpty) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => Scaffold(
                                                        appBar: AppBar(),
                                                        body: Container(
                                                          color: Colors.black,
                                                          child: PhotoView(
                                                            imageProvider: NetworkImage(imageUrl),
                                                            initialScale: PhotoViewComputedScale.contained,
                                                            minScale: PhotoViewComputedScale.contained * 0.8,
                                                            maxScale: PhotoViewComputedScale.covered * 2,
                                                            heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                              child: inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![0] == '' &&
                                                  inspectionInfo.inspectionInfo!.endRental!.mileageImageIDs!.length < 1
                                                  ? Container(
                                                child: Image.asset('icons/Scan-Placeholder.png'),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE0E0E0),
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: const Radius.circular(12.0),
                                                    bottomLeft: const Radius.circular(12.0),
                                                    topRight: const Radius.circular(12.0),
                                                    bottomRight: const Radius.circular(12.0),
                                                  ),
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
                                                        '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![0] != '' ? inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![0] : inspectionInfo.inspectionInfo!.endRental!.mileageImageIDs![0]}'),
                                                    fit: BoxFit.fill,
                                                  ),
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: const Radius.circular(12.0),
                                                    bottomLeft: const Radius.circular(12.0),
                                                    topRight: const Radius.circular(12.0),
                                                    bottomRight: const Radius.circular(12.0),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () => _settingModalBottomSheet(context, 32, inspectDataSnapshot),
                                              child: inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![1] == ''
                                                  ? Container(
                                                child: Image.asset('icons/Scan-Placeholder.png'),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE0E0E0),
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: const Radius.circular(12.0),
                                                    bottomLeft: const Radius.circular(12.0),
                                                    topRight: const Radius.circular(12.0),
                                                    bottomRight: const Radius.circular(12.0),
                                                  ),
                                                ),
                                              )
                                                  : Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                    child: Image(
                                                      fit: BoxFit.fill,
                                                      image: NetworkImage(
                                                          '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![1]}'),
                                                    ),
                                                    width: double.maxFinite,
                                                  ),
                                                  Positioned(
                                                    right: 5,
                                                    bottom: 5,
                                                    child: InkWell(
                                                      onTap: () {
                                                        inspectDataSnapshot.data!.tripEndInspectionRentout!.mileageImageIDs![1] = '';
                                                        rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
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
                                            ),
                                          ],
                                        )
                                        ],
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      ToggleBox(
                                        toggleButtons: RadioButton(
                                          items: ["YES", "NO"],
                                          isSelected: [
                                            inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .pickUpFee!,
                                            !inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .pickUpFee!
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
                                            rentOutInspectBloc
                                                .changedInspectData
                                                .call(
                                                    inspectDataSnapshot.data!);
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
                                            !inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .dropOffFee!
                                          ],
                                          onPress: (selectedValue) {
                                            inspectDataSnapshot
                                                    .data!
                                                    .tripEndInspectionRentout!
                                                    .dropOffFee =
                                                selectedValue == 0;
                                            if (inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .dropOffFee!) {
                                              inspectDataSnapshot
                                                  .data!
                                                  .tripEndInspectionRentout!
                                                  .kmOverTheLimit = 0;
                                            }
                                            rentOutInspectBloc
                                                .changedInspectData
                                                .call(
                                                    inspectDataSnapshot.data!);
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
                                            inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .kmFee!,
                                            !inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .kmFee!
                                          ],
                                          onPress: (selectedValue) {
                                            inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .kmFee = selectedValue == 0;
                                            if (inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .kmFee!) {
                                              inspectDataSnapshot
                                                  .data!
                                                  .tripEndInspectionRentout!
                                                  .kmOverTheLimit = 0;
                                            }
                                            rentOutInspectBloc
                                                .changedInspectData
                                                .call(
                                                    inspectDataSnapshot.data!);
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
                                            inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .fuelFee!,
                                            !inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .fuelFee!
                                          ],
                                          onPress: (selectedValue) {
                                            inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .fuelFee = selectedValue == 0;
                                            if (inspectDataSnapshot
                                                .data!
                                                .tripEndInspectionRentout!
                                                .fuelFee!) {
                                              inspectDataSnapshot
                                                  .data!
                                                  .tripEndInspectionRentout!
                                                  .kmOverTheLimit = 0;
                                            }
                                            rentOutInspectBloc
                                                .changedInspectData
                                                .call(
                                                    inspectDataSnapshot.data!);
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
                                            rentOutInspectBloc
                                                .changedInspectData
                                                .call(
                                                    inspectDataSnapshot.data!);
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
                                            rentOutInspectBloc
                                                .changedInspectData
                                                .call(
                                                    inspectDataSnapshot.data!);
                                          },
                                        ),
                                        title:
                                            "Do you want to charge you guest for interior cleanliness",
                                      ),
                                      SizedBox(height: 10),
                                      StreamBuilder<RateTripGuestRequest>(
                                          stream:
                                              rentOutInspectBloc.rateTripGuest,
                                          builder:
                                              (context, rateTripGuestSnapshot) {
                                            return rateTripGuestSnapshot
                                                        .hasData &&
                                                    rateTripGuestSnapshot
                                                            .data !=
                                                        null
                                                ? Container(
                                                    padding:
                                                        EdgeInsets.all(5.0),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    decoration: BoxDecoration(
                                                      color: Color(0xfff2f2f2),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  6)),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                                      right:
                                                                          16.0,
                                                                      top: 10),
                                                              child: Text(
                                                                "Rate your guest",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style: TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        16,
                                                                    color: Color(
                                                                        0xFF371D32)),
                                                              ),
                                                            ),
                                                            Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            8.0,
                                                                        right:
                                                                            8.0,
                                                                        top:
                                                                            10),
                                                                child: RatingBar
                                                                    .builder(
                                                                  itemSize:
                                                                      30.0,
                                                                  initialRating:
                                                                      3,
                                                                  minRating: 1,
                                                                  direction: Axis
                                                                      .horizontal,
                                                                  allowHalfRating:
                                                                      true,
                                                                  itemCount: 5,
                                                                  itemPadding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              4.0),
                                                                  itemBuilder:
                                                                      (context,
                                                                              _) =>
                                                                          Icon(
                                                                    Icons.star,
                                                                    color: Color(
                                                                        0xFFF68E65),
                                                                  ),
                                                                  onRatingUpdate:
                                                                      (rating) {
                                                                    print(
                                                                        rating);
                                                                  },
                                                                )),
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0,
                                                                  right: 16.0),
                                                          child: TextField(
                                                            focusNode:
                                                                _rateguestfocusNode,
                                                            maxLines: 5,
                                                            controller:
                                                                rateGuestController,
                                                            textInputAction:
                                                                TextInputAction
                                                                    .done,
                                                            onChanged:
                                                                (description) {
                                                              rateTripGuestSnapshot
                                                                      .data!
                                                                      .reviewGuestDescription =
                                                                  description
                                                                      .toString();
                                                              rentOutInspectBloc
                                                                  .changedRateTripGuest
                                                                  .call(rateTripGuestSnapshot
                                                                      .data!);
                                                            },
                                                            decoration: InputDecoration(
                                                                hintText:
                                                                    'Write a review (optional)',
                                                                hintStyle: TextStyle(
                                                                    fontFamily:
                                                                        'Urbanist',
                                                                    fontSize:
                                                                        14,
                                                                    color: Color(
                                                                        0xFF686868),
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .italic),
                                                                border:
                                                                    InputBorder
                                                                        .none),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : Container();
                                          }),
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
                                                    .isTicketsTolls =
                                                selectedValue == 1;
                                            rentOutInspectBloc
                                                .changedInspectData
                                                .call(
                                                    inspectDataSnapshot.data!);
                                          },
                                        ),
                                        title: "Any tickets or tolls??",
                                        subtitle:
                                            "The driver is responsible for any violations, such as speeding, red light, parking or toll tickets during their trip. Please indicate if you've received any of these. You can also get reimbursement for tickets later.",
                                      ),
                                      SizedBox(height: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                              focusNode: _amountfocusNode,
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
                                                    int.parse(
                                                        amount.toString());
                                                rentOutInspectBloc
                                                    .changedInspectData
                                                    .call(inspectDataSnapshot
                                                        .data!);
                                              },
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              keyboardType: Platform.isIOS
                                                  ? TextInputType
                                                      .numberWithOptions(
                                                          signed: true)
                                                  : TextInputType.number,
                                              textInputAction:
                                                  TextInputAction.done,
                                              decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.all(14.0),
                                                  border: InputBorder.none,
                                                  labelText: 'Enter amount',
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
                                              padding: EdgeInsets.only(
                                                  top: 8, bottom: 10),
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
                                                  onTap: () => inspectDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRentout!
                                                          .isTicketsTolls!
                                                      ? _settingModalBottomSheet(
                                                          context,
                                                          33,
                                                          inspectDataSnapshot)
                                                      : null,
                                                  child: inspectDataSnapshot
                                                              .data!
                                                              .tripEndInspectionRentout!
                                                              .ticketsTollsReimbursement!
                                                              .imageIDs![0] ==
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
                                                      : Stack(
                                                          children: <Widget>[
                                                              SizedBox(
                                                                  child: Image(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    image: NetworkImage(
                                                                        '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![0]}'),
                                                                  ),
                                                                  width: double
                                                                      .maxFinite),
                                                              Positioned(
                                                                right: 5,
                                                                bottom: 5,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      inspectDataSnapshot
                                                                          .data!
                                                                          .tripEndInspectionRentout!
                                                                          .ticketsTollsReimbursement!
                                                                          .imageIDs![0] = '';
                                                                      rentOutInspectBloc
                                                                          .changedInspectData(
                                                                              inspectDataSnapshot.data!);
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
                                                            ]),
                                                ),
                                                GestureDetector(
                                                  onTap: () => inspectDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRentout!
                                                          .isTicketsTolls!
                                                      ? _settingModalBottomSheet(
                                                          context,
                                                          34,
                                                          inspectDataSnapshot)
                                                      : null,
                                                  child: inspectDataSnapshot
                                                              .data!
                                                              .tripEndInspectionRentout!
                                                              .ticketsTollsReimbursement!
                                                              .imageIDs![1] ==
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
                                                      : Stack(
                                                          children: <Widget>[
                                                              SizedBox(
                                                                  child: Image(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    image: NetworkImage(
                                                                        '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![1]}'),
                                                                  ),
                                                                  width: double
                                                                      .maxFinite),
                                                              Positioned(
                                                                right: 5,
                                                                bottom: 5,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      inspectDataSnapshot
                                                                          .data!
                                                                          .tripEndInspectionRentout!
                                                                          .ticketsTollsReimbursement!
                                                                          .imageIDs![1] = '';
                                                                      rentOutInspectBloc
                                                                          .changedInspectData(
                                                                              inspectDataSnapshot.data!);
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
                                                            ]),
                                                ),
                                                GestureDetector(
                                                  onTap: () => inspectDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRentout!
                                                          .isTicketsTolls!
                                                      ? _settingModalBottomSheet(
                                                          context,
                                                          35,
                                                          inspectDataSnapshot)
                                                      : null,
                                                  child: inspectDataSnapshot
                                                              .data!
                                                              .tripEndInspectionRentout!
                                                              .ticketsTollsReimbursement!
                                                              .imageIDs![2] ==
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
                                                      : Stack(
                                                          children: <Widget>[
                                                              SizedBox(
                                                                  child: Image(
                                                                    fit: BoxFit
                                                                        .fill,
                                                                    image: NetworkImage(
                                                                        '$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![2]}'),
                                                                  ),
                                                                  width: double
                                                                      .maxFinite),
                                                              Positioned(
                                                                right: 5,
                                                                bottom: 5,
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      inspectDataSnapshot
                                                                          .data!
                                                                          .tripEndInspectionRentout!
                                                                          .ticketsTollsReimbursement!
                                                                          .imageIDs![2] = '';
                                                                      rentOutInspectBloc
                                                                          .changedInspectData(
                                                                              inspectDataSnapshot.data!);
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
                                                            ]),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 20),
                                    ],
                                  ),
                                ),
                                Divider(),
                                inspectDataSnapshot.hasError
                                    ? Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                Text(
                                                  inspectDataSnapshot.error
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFFF55A51),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : new Container(),
                                inspectDataSnapshot.hasError
                                    ? SizedBox(height: 10)
                                    : new Container(),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: <Widget>[
                                          SizedBox(
                                              width: double.maxFinite,
                                              child: Container(
                                                margin: EdgeInsets.all(16.0),
                                                child: ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    elevation: 0.0,
                                                    backgroundColor:
                                                        Color(0xFFFF8F62),
                                                    padding:
                                                        EdgeInsets.all(16.0),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8.0)),
                                                  ),
                                                  onPressed: damageSelectionSnapshot
                                                                  .data !=
                                                              0 &&
                                                          rentOutInspectBloc
                                                              .checkValidation(
                                                                  inspectDataSnapshot
                                                                      .data!)
                                                      ? () async {
                                                          var res = await rentOutInspectBloc
                                                              .inspectRentout(
                                                                  inspectDataSnapshot
                                                                      .data!,
                                                                  tripDetails);
                                                          AppEventsUtils.logEvent(
                                                              "trip_other_fees",
                                                              params: {
                                                                "cleaningFee": res!
                                                                    .tripEndInspectionRentout!
                                                                    .requestedChargeForFuel,
                                                                "KmOverTheLimit": res
                                                                    .tripEndInspectionRentout!
                                                                    .kmOverTheLimit,
                                                                "fuelCharge": res
                                                                    .tripEndInspectionRentout!
                                                                    .requestedChargeForFuel,
                                                                "latePickUpFee":
                                                                    tripDetails
                                                                        .otherFees!
                                                                        .latePickup,
                                                                "lateReturnFee":
                                                                    tripDetails
                                                                        .otherFees!
                                                                        .lateReturn,
                                                              });
                                                          if (res.status!
                                                              .success!) {
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/inspection_completed',
                                                              arguments: {
                                                                'tripType':
                                                                    tripType,
                                                                'trip':
                                                                    tripDetails,
                                                                'damage': inspectDataSnapshot
                                                                    .data!
                                                                    .tripEndInspectionRentout!
                                                                    .isTicketsTolls
                                                              },
                                                            );
                                                          } else {}
                                                        }
                                                      : null,
                                                  child: Text(
                                                    'Complete Inspection',
                                                    style: TextStyle(
                                                        fontFamily: 'Urbanist',
                                                        fontSize: 18,
                                                        color: Colors.white),
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
                          ),
                        );
                      })
                  : Container();
            }),
      ),
    );
  }
}
