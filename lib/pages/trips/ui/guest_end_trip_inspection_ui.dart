import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/end_trip_bloc.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_car_request.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_host_request.dart';
import 'package:ridealike/pages/trips/response_model/end_trip_inspect_rental_response.dart';

// import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/custom_buttom.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

class EndTripUi extends StatefulWidget {
  @override
  State createState() => EndTripUiState();
}

class EndTripUiState extends State<EndTripUi> {
  String fuelLevel = "Select the suitable option";
  int mileage = 0;
  String? damageDesctiption;

  final endTripRentalBloc = EndTripRentalBloc();
  TextEditingController _mileageController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  FocusNode _damageDesctiptionfocusNode = FocusNode();
  FocusNode _mileagefocusNode = FocusNode();
  FocusNode _hostreview = FocusNode();
  FocusNode _vehiclereview = FocusNode();

  @override
  void dispose() {
    _damageDesctiptionfocusNode.dispose();
    _hostreview.dispose();
    _mileagefocusNode.dispose();
    _vehiclereview.dispose();
    super.dispose();
  }

  void _handleTapOutside() {
    _damageDesctiptionfocusNode.unfocus();
    _mileagefocusNode.unfocus();
    _vehiclereview.unfocus();
    _hostreview.unfocus();
  }

  void _settingModalBottomSheet(context, _imgOrder,
      AsyncSnapshot<InspectTripEndRentalResponse> endTripDataSnapshot) {
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
                    endTripRentalBloc.pickeImageThroughCamera(
                        _imgOrder, endTripDataSnapshot, context);
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
                    endTripRentalBloc.pickeImageFromGallery(
                        _imgOrder, endTripDataSnapshot, context);
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
        params: {"page_name": "Guest End Trip Duration"});
  }

  @override
  Widget build(BuildContext context) {
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    Trips tripDetails = receivedData['TRIP_DATA'];
    Trips? swapTripDetails = receivedData['SWAP_TRIP'];

    InspectTripEndRentalResponse inspectTripEndRentalResponse =
        InspectTripEndRentalResponse(
            tripEndInspectionRental: TripEndInspectionRental(
      tripID: tripDetails.tripID,
      isNoticibleDamage: false,
      inspectionByUserID: tripDetails.userID,
      mileage: 0,
      damageImageIDs: List.filled(15, ''),
      damageDesctiption: '',
      fuelReceiptImageIDs: List.filled(2, ''),
      exteriorCleanliness: "",
      interiorCleanliness: '',
      exteriorImageIDs: List.filled(15, ''),
      interiorImageIDs: List.filled(15, ''),
      fuelImageIDs: List.filled(2, ''),
      mileageImageIDs: List.filled(2, ''),
      fuelLevel: '',
    ));

    RateTripCarRequest rateTripCarRequest = RateTripCarRequest(
        inspectionByUserID: tripDetails.userID,
        tripID: tripDetails.tripID,
        rateCar: '0',
        reviewCarDescription: '');

    RateTripHostRequest rateTripHostRequest = RateTripHostRequest(
        tripID: tripDetails.tripID,
        inspectionByUserID: tripDetails.userID,
        rateHost: '0',
        reviewHostDescription: '');

    endTripRentalBloc.changedTripRateCar.call(rateTripCarRequest);
    endTripRentalBloc.changedTripRateHost.call(rateTripHostRequest);
    endTripRentalBloc.changedEndTripData.call(inspectTripEndRentalResponse);
    endTripRentalBloc.changedDamageSelection.call(0);

    return GestureDetector(
      onTap: _handleTapOutside,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: StreamBuilder<InspectTripEndRentalResponse>(
            stream: endTripRentalBloc.endTripData,
            builder: (context, endTripDataSnapshot) {
              return endTripDataSnapshot.hasData &&
                      endTripDataSnapshot.data! != null
                  ? StreamBuilder<int>(
                      stream: endTripRentalBloc.damageSelection,
                      builder: (context, damageSelectionSnapshot) {
                        return Container(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      Text('            ')
                                    ],
                                  ),
                                  SizedBox(height: 30),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Text(
                                        "End trip",
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
                                                  '$storageServerUrl/${tripDetails.carImageId}',
                                                ),
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
                                  tripDetails.tripType == 'Swap'
                                      ? Container()
                                      : Text(
                                          "Return inspection",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 24,
                                              color: Color(0xFF371D32),
                                              fontWeight: FontWeight.bold),
                                        ),
                                  SizedBox(height: 20),
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
                                            "Any new damage after the trip?",
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
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
                                                    endTripDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRental!
                                                        .isNoticibleDamage = false;
                                                    endTripRentalBloc
                                                        .changedEndTripData
                                                        .call(
                                                            endTripDataSnapshot
                                                                .data!);
                                                    endTripRentalBloc
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
                                                    endTripDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRental!
                                                        .isNoticibleDamage = true;
                                                    endTripRentalBloc
                                                        .changedEndTripData
                                                        .call(
                                                            endTripDataSnapshot
                                                                .data!);
                                                    endTripRentalBloc
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
                                  SizedBox(height: 10.0),

                                  Container(
                                    padding: EdgeInsets.all(16.0),
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
                                          "Take photos of car if any damage",
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
                                        int damageIndex = index;
                                        return GestureDetector(
                                          onTap: (damageSelectionSnapshot.data != 1 && damageSelectionSnapshot.data != 2)
                                              ? () => {}
                                              : () => _settingModalBottomSheet(context, damageIndex + 1, endTripDataSnapshot),
                                          child: endTripDataSnapshot.data!.tripEndInspectionRental!.damageImageIDs![damageIndex] == ''
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
                                                  image: NetworkImage('$storageServerUrl/${endTripDataSnapshot.data!.tripEndInspectionRental!.damageImageIDs![damageIndex]}'),
                                                ),
                                                width: double.maxFinite,
                                              ),
                                              Positioned(
                                                right: 5,
                                                bottom: 5,
                                                child: InkWell(
                                                  onTap: () {
                                                    endTripDataSnapshot.data!.tripEndInspectionRental!.damageImageIDs![damageIndex] = '';
                                                    endTripRentalBloc.changedEndTripData.call(endTripDataSnapshot.data!);
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
                                    ),

                                    ],
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xfff2f2f2),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(8)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 16.0,
                                              right: 16.0,
                                              left: 16.0),
                                          child: Text(
                                            "Tell us what happened (optional)",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)),
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 16, right: 16),
                                          child: TextField(
                                            enabled:
                                                damageSelectionSnapshot.data !=
                                                        2
                                                    ? false
                                                    : true,
                                            focusNode:
                                                _damageDesctiptionfocusNode,
                                            maxLines: 5,
                                            controller: descriptionController,
                                            textInputAction:
                                                TextInputAction.done,
                                            onChanged: (description) {
                                              endTripDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRental!
                                                      .damageDesctiption =
                                                  description;
                                              endTripRentalBloc
                                                  .changedEndTripData
                                                  .call(endTripDataSnapshot
                                                      .data!);
                                            },
                                            decoration: InputDecoration(
                                                hintText:
                                                    'Add description here',
                                                hintStyle: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 14,
                                                    color: Color(0xFF686868),
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
                                                isSelected: endTripDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRental!
                                                        .exteriorCleanliness ==
                                                    'Poor',
                                                press: () {
                                                  endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
                                                          .exteriorCleanliness =
                                                      'Poor';
                                                  endTripRentalBloc
                                                      .changedEndTripData
                                                      .call(endTripDataSnapshot
                                                          .data!);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              child: CustomButton(
                                                title: 'GOOD',
                                                isSelected: endTripDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRental!
                                                        .exteriorCleanliness ==
                                                    'Good',
                                                press: () {
                                                  endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
                                                          .exteriorCleanliness =
                                                      'Good';
                                                  endTripRentalBloc
                                                      .changedEndTripData
                                                      .call(endTripDataSnapshot
                                                          .data!);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              child: CustomButton(
                                                title: 'EXCELLENT',
                                                isSelected: endTripDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRental!
                                                        .exteriorCleanliness ==
                                                    'Excellent',
                                                press: () {
                                                  endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
                                                          .exteriorCleanliness =
                                                      'Excellent';
                                                  endTripRentalBloc
                                                      .changedEndTripData
                                                      .call(endTripDataSnapshot
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
//
//                             ///exterior image
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
                                          int imageIndex = index + 13;
                                          return GestureDetector(
                                            onTap: () => _settingModalBottomSheet(context, imageIndex, endTripDataSnapshot),
                                            child: endTripDataSnapshot.data!.tripEndInspectionRental!.exteriorImageIDs![index] == ''
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
                                                    image: NetworkImage('$storageServerUrl/${endTripDataSnapshot.data!.tripEndInspectionRental!.exteriorImageIDs![index]}'),
                                                  ),
                                                  width: double.maxFinite,
                                                ),
                                                Positioned(
                                                  right: 5,
                                                  bottom: 5,
                                                  child: InkWell(
                                                    onTap: () {
                                                      endTripDataSnapshot.data!.tripEndInspectionRental!.exteriorImageIDs![index] = '';
                                                      endTripRentalBloc.changedEndTripData.call(endTripDataSnapshot.data!);
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
                                                isSelected: endTripDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRental!
                                                        .interiorCleanliness ==
                                                    'Poor',
                                                press: () {
                                                  endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
                                                          .interiorCleanliness =
                                                      'Poor';
                                                  endTripRentalBloc
                                                      .changedEndTripData
                                                      .call(endTripDataSnapshot
                                                          .data!);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              child: CustomButton(
                                                title: 'GOOD',
                                                isSelected: endTripDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRental!
                                                        .interiorCleanliness ==
                                                    'Good',
                                                press: () {
                                                  endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
                                                          .interiorCleanliness =
                                                      'Good';
                                                  endTripRentalBloc
                                                      .changedEndTripData
                                                      .call(endTripDataSnapshot
                                                          .data!);
                                                },
                                              ),
                                            ),
                                            SizedBox(width: 10.0),
                                            Expanded(
                                              child: CustomButton(
                                                title: 'EXCELLENT',
                                                isSelected: endTripDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRental!
                                                        .interiorCleanliness ==
                                                    'Excellent',
                                                press: () {
                                                  endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
                                                          .interiorCleanliness =
                                                      'Excellent';
                                                  endTripRentalBloc
                                                      .changedEndTripData
                                                      .call(endTripDataSnapshot
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
//
//                             ///interior image
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
                                          int imageIndex = index + 22;
                                          return GestureDetector(
                                            onTap: () => _settingModalBottomSheet(context, imageIndex, endTripDataSnapshot),
                                            child: endTripDataSnapshot.data!.tripEndInspectionRental!.interiorImageIDs![index] == ''
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
                                                    image: NetworkImage('$storageServerUrl/${endTripDataSnapshot.data!.tripEndInspectionRental!.interiorImageIDs![index]}'),
                                                  ),
                                                  width: double.maxFinite,
                                                ),
                                                Positioned(
                                                  right: 5,
                                                  bottom: 5,
                                                  child: InkWell(
                                                    onTap: () {
                                                      endTripDataSnapshot.data!.tripEndInspectionRental!.interiorImageIDs![index] = '';
                                                      endTripRentalBloc.changedEndTripData.call(endTripDataSnapshot.data!);
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
                                      ),

                                      ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),

//
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
                                          "Select the fuel level after the trip end.",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xFF353B50)),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
                                                          .fuelLevel ==
                                                      ''
                                                  ? fuelLevel
                                                  : endTripDataSnapshot
                                                      .data!
                                                      .tripEndInspectionRental!
                                                      .fuelLevel!,
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 14,
                                                color: Colors
                                                    .black,
                                              ),
                                            ),
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
                                                          color: Color(
                                                              0xFF353B50)),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
                                                          .fuelLevel =
                                                      value as String?;
                                                  endTripRentalBloc
                                                      .changedEndTripData
                                                      .call(endTripDataSnapshot
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
                                                      endTripDataSnapshot),
                                              child: endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
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
                                                              '$storageServerUrl/${endTripDataSnapshot.data!.tripEndInspectionRental!.fuelImageIDs![0]}'),
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
                                                endTripDataSnapshot
                                                        .data!
                                                        .tripEndInspectionRental!
                                                        .mileage =
                                                    int.parse(
                                                        mileage.toString());
                                                endTripRentalBloc
                                                    .changedEndTripData
                                                    .call(endTripDataSnapshot
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
                                                                        .text
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
                                                      endTripDataSnapshot),
                                              child: endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
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
                                                              '$storageServerUrl/${endTripDataSnapshot.data!.tripEndInspectionRental!.mileageImageIDs![0]}'),
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
                                          "Take photo(s) of fuel receipt(s)",
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 16,
                                              color: Color(0xFF371D32)),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          'Take photo(s) of your receipts as proof of inheritance to the host fuel requirement',
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xFF353B50)),
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
                                                      33,
                                                      endTripDataSnapshot),
                                              child: endTripDataSnapshot
                                                          .data!
                                                          .tripEndInspectionRental!
                                                          .fuelReceiptImageIDs![0] ==
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
                                                              '$storageServerUrl/${endTripDataSnapshot.data!.tripEndInspectionRental!.fuelReceiptImageIDs![0]}'),
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
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 10),

                                  StreamBuilder<RateTripCarRequest>(
                                      stream: endTripRentalBloc.tripRateCar,
                                      builder: (context, tripRateCarSnapshot) {
                                        return tripRateCarSnapshot.hasData &&
                                                tripRateCarSnapshot.data != null
                                            ? Container(
                                                padding: EdgeInsets.all(5.0),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  color: Color(0xfff2f2f2),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
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
                                                            "Rate the vehicle",
                                                            textAlign: TextAlign
                                                                .center,
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
                                                          child:
                                                              SmoothStarRating(
                                                                  allowHalfRating:
                                                                      false,
                                                                  onRatingChanged:
                                                                      (v) {
                                                                    tripRateCarSnapshot
                                                                            .data!
                                                                            .rateCar =
                                                                        v.toStringAsFixed(
                                                                            0);
                                                                    endTripRentalBloc
                                                                        .changedTripRateCar
                                                                        .call(tripRateCarSnapshot
                                                                            .data!);
                                                                  },
                                                                  starCount: 5,
                                                                  rating: double.parse(
                                                                      tripRateCarSnapshot
                                                                          .data!
                                                                          .rateCar!),
                                                                  size: 20.0,
                                                                  color: Color(
                                                                      0xffFF8F68),
                                                                  borderColor:
                                                                      Color(
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
                                                        focusNode:
                                                            _vehiclereview,
                                                        minLines: 1,
                                                        maxLines: 5,
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        onChanged: (review) {
                                                          tripRateCarSnapshot
                                                                  .data!
                                                                  .reviewCarDescription =
                                                              review;
                                                          endTripRentalBloc
                                                              .changedTripRateCar
                                                              .call(
                                                                  tripRateCarSnapshot
                                                                      .data!);
                                                        },
                                                        decoration: InputDecoration(
                                                            hintText:
                                                                'Write a vehicle review(optional)',
                                                            hintStyle: TextStyle(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xFF686868),
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal),
                                                            border: InputBorder
                                                                .none),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container();
                                      }),

                                  SizedBox(height: 10),

                                  StreamBuilder<RateTripHostRequest>(
                                      stream: endTripRentalBloc.tripRateHost,
                                      builder: (context, tripRateHostSnapshot) {
                                        return tripRateHostSnapshot.hasData &&
                                                tripRateHostSnapshot.data! !=
                                                    null
                                            ? Container(
                                                padding: EdgeInsets.all(5.0),
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: BoxDecoration(
                                                  color: Color(0xfff2f2f2),
                                                  borderRadius:
                                                      BorderRadius.all(
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
                                                            "Rate the host",
                                                            textAlign: TextAlign
                                                                .center,
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
                                                          child:
                                                              SmoothStarRating(
                                                                  allowHalfRating:
                                                                      false,
                                                                  onRatingChanged:
                                                                      (v) {
                                                                    tripRateHostSnapshot
                                                                            .data!
                                                                            .rateHost =
                                                                        v.toStringAsFixed(
                                                                            0);
                                                                    endTripRentalBloc
                                                                        .changedTripRateHost
                                                                        .call(tripRateHostSnapshot
                                                                            .data!);
                                                                  },
                                                                  starCount: 5,
                                                                  rating: double.parse(
                                                                      tripRateHostSnapshot
                                                                          .data!
                                                                          .rateHost!),
                                                                  size: 20.0,
                                                                  color: Color(
                                                                      0xffFF8F68),
                                                                  borderColor:
                                                                      Color(
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
                                                        focusNode: _hostreview,
                                                        minLines: 1,
                                                        maxLines: 5,
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        onChanged:
                                                            (hostReviews) {
                                                          tripRateHostSnapshot
                                                                  .data!
                                                                  .reviewHostDescription =
                                                              hostReviews;
                                                          endTripRentalBloc
                                                              .changedTripRateHost
                                                              .call(
                                                                  tripRateHostSnapshot
                                                                      .data!);
                                                        },
                                                        decoration: InputDecoration(
                                                            hintText:
                                                                'Write a host review(optional)',
                                                            hintStyle: TextStyle(
                                                                fontFamily:
                                                                    'Urbanist',
                                                                fontSize: 14,
                                                                color: Color(
                                                                    0xFF686868),
                                                                fontStyle:
                                                                    FontStyle
                                                                        .normal),
                                                            border: InputBorder
                                                                .none),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Container();
                                      }),
                                  SizedBox(height: 10),
                                  endTripDataSnapshot.hasError
                                      ? Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  Text(
                                                    endTripDataSnapshot.error
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
                                  endTripDataSnapshot.hasError
                                      ? SizedBox(height: 10)
                                      : new Container(),
                                  tripDetails.tripType == 'Swap'
                                      ? Column(
                                          children: [
                                            SizedBox(height: 16),
                                            Divider(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 16, right: 16, top: 8),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Column(
                                                      children: <Widget>[
                                                        SizedBox(
                                                            width: double
                                                                .maxFinite,
                                                            child: Container(
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child:
                                                                    ElevatedButton(
                                                                  style: ElevatedButton
                                                                      .styleFrom(
                                                                    elevation:
                                                                        0.0,
                                                                    backgroundColor:
                                                                        Color(
                                                                            0xFFFF8F62),
                                                                    padding:
                                                                        EdgeInsets.all(
                                                                            16.0),
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0)),
                                                                  ),
                                                                  onPressed: (damageSelectionSnapshot.data == 1 ||
                                                                              damageSelectionSnapshot.data ==
                                                                                  2) &&
                                                                          endTripRentalBloc.checkValidity(
                                                                              endTripDataSnapshot.data!,
                                                                              tripDetails)
                                                                      ? () async {
                                                                          var res =
                                                                              await endTripRentalBloc.endTripInspectionsMethod(endTripDataSnapshot.data!);
                                                                          var res2 = await endTripRentalBloc.endTripMethod(
                                                                              tripDetails.tripID!,
                                                                              tripDetails);

                                                                          if (res2 != null &&
                                                                              res2.status!.success!) {
                                                                            Navigator.pushNamed(
                                                                              context,
                                                                              '/swap_inspection_ui',
                                                                              arguments: {
                                                                                'tripType': "Past",
                                                                                'onBackPress': 'PUSH',
                                                                                'PATH': '/trips_rental_details_ui',
                                                                                'trip': tripDetails
                                                                              },
                                                                            );
                                                                          }
                                                                        }
                                                                      : null,
                                                                  child: Text(
                                                                    tripDetails.tripType ==
                                                                            'Swap'
                                                                        ? 'Next: Inspect your vehicle'
                                                                        : 'Inspect your vehicle',
                                                                    style: TextStyle(
                                                                        fontFamily:
                                                                            'Urbanist',
                                                                        fontSize:
                                                                            18,
                                                                        color: Colors
                                                                            .white),
                                                                  ),
                                                                ))),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  SizedBox(
                                                    width: double.maxFinite,
                                                    child: ElevatedButton(
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        elevation: 0.0,
                                                        backgroundColor:
                                                            Color(0xffFF8F68),
                                                        padding: EdgeInsets.all(
                                                            16.0),
                                                        shape: RoundedRectangleBorder(
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
                                                              endTripRentalBloc
                                                                  .checkValidity(
                                                                      endTripDataSnapshot
                                                                          .data!,
                                                                      tripDetails)
                                                          ? () async {
                                                              var res = await endTripRentalBloc
                                                                  .endTripInspectionsMethod(
                                                                      endTripDataSnapshot
                                                                          .data!);
                                                              var res2 = await endTripRentalBloc
                                                                  .endTripMethod(
                                                                      tripDetails
                                                                          .tripID!,
                                                                      tripDetails);

                                                              AppEventsUtils
                                                                  .logEvent(
                                                                      "trip_end_successful",
                                                                      params: {
                                                                        "trip_id":
                                                                        tripDetails
                                                                            .tripID,
                                                                        "start_date": tripDetails.startDateTime?.toIso8601String(),
                                                                        "end_date": tripDetails.endDateTime?.toIso8601String(),
                                                                        "car_id": tripDetails
                                                                            .car!.iD,
                                                                    "car_name":
                                                                        tripDetails
                                                                            .car!
                                                                            .about!
                                                                            .make,
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

                                                              if (res2 !=
                                                                      null &&
                                                                  res2.status!
                                                                      .success!) {

                                                                Navigator
                                                                    .pushNamed(
                                                                  context,
                                                                  '/trip_ended',
                                                                  arguments:
                                                                      tripDetails,
                                                                );
                                                              }
                                                            }
                                                          : null,
                                                      child: Text(
                                                        'End trip',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'Urbanist',
                                                            fontSize: 18,
                                                            color:
                                                                Colors.white),
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
