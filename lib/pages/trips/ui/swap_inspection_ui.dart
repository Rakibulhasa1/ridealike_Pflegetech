import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/rent_out_inspect_bloc.dart';
import 'package:ridealike/pages/trips/request_service/rate_trip_guest_request.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/rent_out_inspect_trips_response.dart';
import 'package:ridealike/pages/trips/response_model/swap_agree_carinfo_response.dart';
import 'package:ridealike/widgets/radio_button.dart';
import 'package:ridealike/widgets/rectangle_box.dart';
import 'package:ridealike/widgets/toggle_box.dart';
import 'package:shimmer/shimmer.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../../../utils/app_events/app_events_utils.dart';

class SwapInspectionUi extends StatefulWidget {
  // static const String routeName = "/inspect";
  @override
  _SwapInspectionUiState createState() => _SwapInspectionUiState();
}

class _SwapInspectionUiState extends State<SwapInspectionUi> {
  final rentOutInspectBloc=RentOutInspectBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Swap Inspection"});
  }

  void _settingModalBottomSheet(context, _imgOrder, AsyncSnapshot<InspectTripEndRentoutResponse> inspectDataSnapshot){
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc){
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
                            child: Text('Cancel',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 16,
                                color: Color(0xFFF68E65),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.center, 
                            child: Text('Attach photo',
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
                title: Text('Take photo',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF371D32),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  rentOutInspectBloc.pickeImageThroughCamera(_imgOrder, inspectDataSnapshot,context);
                },          
              ),
              Divider(color: Color(0xFFABABAB)),
              new ListTile(
                leading: Image.asset('icons/Attach-Photo_Sheet.png'),
                title: Text('Attach photo',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 16,
                    color: Color(0xFF371D32),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  rentOutInspectBloc.pickeImageFromGallery(_imgOrder, inspectDataSnapshot,context);
                },          
              ),
              Divider(color: Color(0xFFABABAB)),
            ],
          ),
        );
      }
    );
  }


  @override
  Widget build(BuildContext context) {
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
    Trips tripDetails = receivedData['trip'];
    String tripType = receivedData['tripType'];
    String onBackPress = receivedData['onBackPress'];
    String path = receivedData['PATH'];
    rentOutInspectBloc.getSwapAgreementTermsService(tripDetails);


    InspectTripEndRentoutResponse response = InspectTripEndRentoutResponse(

        tripEndInspectionRentout: TripEndInspectionRentout(inspectionByUserID: tripDetails.hostUserID, tripID: tripDetails.swapData!.otherTripID, damageDesctiption: '',
            damageImageIDs: List.filled(12, ''), isNoticibleDamage: false,cleanliness: 'Poor', isAddedMileageWithinAllocated: false,
            isFuelSameLevelAsBefore: false, isTicketsTolls: true, kmOverTheLimit: 120, requestedChargeForFuel: 25,
            requestedCleaningFee: -1,ticketsTollsReimbursement: TicketsTollsReimbursement(imageIDs:List.filled(3, ''),amount: 0,description: '' ),

        )
    );
    RateTripGuestRequest rateTripGuestRequest=RateTripGuestRequest(tripID: tripDetails.swapData!.otherTripID,inspectionByUserID: tripDetails.userID,rateGuest:'0',reviewGuestDescription: '' );

    rentOutInspectBloc.changedInspectData.call(response);
    rentOutInspectBloc.changedRateTripGuest.call(rateTripGuestRequest);
    rentOutInspectBloc.changedDamageSelection.call(0);



    return Scaffold(key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        title: InkWell(
          onTap: () {
            if (onBackPress != null && onBackPress=='PUSH'){
              Navigator.of(context).pushNamed(path, arguments: {
                'tripType': tripType,
                'trip': tripDetails
              });
            } else{
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
          return inspectDataSnapshot.hasData && inspectDataSnapshot.data! != null?
          StreamBuilder<int>(
            stream: rentOutInspectBloc.damageSelection,
            builder: (context, damageSelectionSnapshot) {
              return StreamBuilder<SwapAgreementCarInfoResponse>(
                stream: rentOutInspectBloc.swapAgreement,
                builder: (context, swapAgreementSnapshot) {
                  return  swapAgreementSnapshot.hasData?
                  Container(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Inspect your \nvehicle",
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 36,
                                        color: Color(0xFF371D32),
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                    Center(
                                      child: (swapAgreementSnapshot.data!.swapAgreementTerms!.myCar!.imagesAndDocuments!.images!.mainImageID!= null
                                          || swapAgreementSnapshot.data!.swapAgreementTerms!.myCar!.imagesAndDocuments!.images!.mainImageID != '') ? CircleAvatar(
                                        backgroundImage: NetworkImage('$storageServerUrl/${swapAgreementSnapshot.data!.swapAgreementTerms!.myCar!.imagesAndDocuments!.images!.mainImageID}'),
                                        radius: 25,
                                      )
                                      : CircleAvatar(
                                        backgroundImage: AssetImage('images/car-placeholder.png'),
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
                                    isSelected: [damageSelectionSnapshot.data==1, damageSelectionSnapshot.data==2],
                                    // isSelected: [!inspectDataSnapshot.data!.tripEndInspectionRentout!.isNoticibleDamage, inspectDataSnapshot.data!.tripEndInspectionRentout!.isNoticibleDamage],
                                    onPress: (selectedValue){
                                      rentOutInspectBloc.changedDamageSelection.call(selectedValue+1);
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.isNoticibleDamage = (selectedValue ==1);
                                      rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                ),
                                SizedBox(height: 10),
                                RectangleBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Take photos of new damage",
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32)
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      GridView.count(
                                        primary: false,
                                        shrinkWrap: true,
                                        crossAxisSpacing: 1,
                                        mainAxisSpacing: 1,
                                        crossAxisCount: 3,
                                        children: List.generate(12, (index) =>
                                            GestureDetector(
                                              onTap: damageSelectionSnapshot.data!=2
                                                  ? () => {}
                                                  : () => _settingModalBottomSheet(context, index+1, inspectDataSnapshot),
                                              child: inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![index] == '' ?
                                              Container(
                                                child: Image.asset('icons/Scan-Placeholder.png'),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE0E0E0),
                                                  borderRadius:
                                                  // for left corner photo boxes
                                                  index % 3 == 0 ? BorderRadius.only(
                                                    topLeft: const Radius.circular(12.0),
                                                    bottomLeft: const Radius.circular(12.0),
                                                  ):
                                                  // for right corner photo boxes
                                                  (index == 2 || index == 5 || index == 8 || index == 11) ?
                                                  BorderRadius.only(
                                                    topRight: const Radius.circular(12.0),
                                                    bottomRight: const Radius.circular(12.0),
                                                  ):
                                                  null,
                                                ),
                                              ) :
                                              Stack(
                                                  children: <Widget>[
                                                    SizedBox(
                                                        child: Image(fit: BoxFit.fill,image:
                                                        NetworkImage('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![index]}'),),
                                                        width: double.maxFinite ),
                                                    Positioned(right: 5, bottom: 5,
                                                      child: InkWell(
                                                          onTap: (){
                                                            inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![index]='';
                                                            rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                                          },
                                                          child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                              child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                  ]
                                              ),
                                            ),
                                        ),
                                      ),
                                      // GridView.count(
                                      //   primary: false,
                                      //   shrinkWrap: true,
                                      //   crossAxisSpacing: 1,
                                      //   mainAxisSpacing: 1,
                                      //   crossAxisCount: 3,
                                      //   children:
                                      //   // <Widget>[
                                      //   //   GestureDetector(
                                      //   //     onTap: damageSelectionSnapshot.data!=2
                                      //   //         ? () => {}
                                      //   //         : () => _settingModalBottomSheet(context, 1, inspectDataSnapshot),
                                      //   //     child: inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![0] == '' ?
                                      //   //     Container(
                                      //   //       child: Image.asset('icons/Scan-Placeholder.png'),
                                      //   //       decoration: BoxDecoration(
                                      //   //         color: Color(0xFFE0E0E0),
                                      //   //         borderRadius: new BorderRadius.only(
                                      //   //           topLeft: const Radius.circular(12.0),
                                      //   //           bottomLeft: const Radius.circular(12.0),
                                      //   //         ),
                                      //   //       ),
                                      //   //     ) :
                                      //   //     Stack(
                                      //   //         children: <Widget>[
                                      //   //           SizedBox(
                                      //   //               child: Image(fit: BoxFit.fill,image:
                                      //   //               NetworkImage('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![0]}'),),
                                      //   //               width: double.maxFinite ),
                                      //   //           Positioned(right: 5, bottom: 5,
                                      //   //             child: InkWell(
                                      //   //                 onTap: (){
                                      //   //                   inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![0]='';
                                      //   //                   rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                      //   //                 },
                                      //   //                 child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                      //   //                     child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)
                                      //   //
                                      //   //         ]
                                      //   //     ),
                                      //   //
                                      //   //   ),
                                      //   //
                                      //   //   GestureDetector(
                                      //   //     onTap:damageSelectionSnapshot.data!=2
                                      //   //         ? () => {}
                                      //   //         : () => _settingModalBottomSheet(context, 2, inspectDataSnapshot),
                                      //   //     child: inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![1] == '' ? Container(
                                      //   //       child: Image.asset('icons/Scan-Placeholder.png'),
                                      //   //       color: Color(0xFFE0E0E0),
                                      //   //     ) :  Stack(
                                      //   //         children: <Widget>[
                                      //   //           SizedBox(
                                      //   //               child: Image(fit: BoxFit.fill,image:
                                      //   //               NetworkImage('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![1]}'),),
                                      //   //               width: double.maxFinite ),
                                      //   //           Positioned(right: 5, bottom: 5,
                                      //   //             child: InkWell(
                                      //   //                 onTap: (){
                                      //   //                   inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![1]='';
                                      //   //                   rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                      //   //                 },
                                      //   //                 child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                      //   //                     child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)
                                      //   //
                                      //   //         ]
                                      //   //     )
                                      //   //
                                      //   //   ),
                                      //   //   GestureDetector(
                                      //   //     onTap: damageSelectionSnapshot.data!=2
                                      //   //         ? () => {}
                                      //   //         :() => _settingModalBottomSheet(context, 3, inspectDataSnapshot),
                                      //   //     child: inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![2] == '' ? Container(
                                      //   //       child: Image.asset('icons/Scan-Placeholder.png'),
                                      //   //       decoration: BoxDecoration(
                                      //   //         color: Color(0xFFE0E0E0),
                                      //   //         borderRadius: new BorderRadius.only(
                                      //   //           topRight: const Radius.circular(12.0),
                                      //   //           bottomRight: const Radius.circular(12.0),
                                      //   //         ),
                                      //   //       ),
                                      //   //     ) : Stack(
                                      //   //         children: <Widget>[
                                      //   //           SizedBox(
                                      //   //               child: Image(fit: BoxFit.fill,image:
                                      //   //               NetworkImage('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![2]}'),),
                                      //   //               width: double.maxFinite ),
                                      //   //           Positioned(right: 5, bottom: 5,
                                      //   //             child: InkWell(
                                      //   //                 onTap: (){
                                      //   //                   inspectDataSnapshot.data!.tripEndInspectionRentout!.damageImageIDs![2]='';
                                      //   //                   rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                      //   //                 },
                                      //   //                 child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                      //   //                     child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)
                                      //   //
                                      //   //         ]
                                      //   //     ),
                                      //   //
                                      //   //
                                      //   //   ),
                                      //   // ],
                                      // ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.all(5.0),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                    color: Color(0xfff2f2f2),
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 10),
                                            child: Text("Tell us about new damage",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 16,
                                                color: Color(0xFF371D32)
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                        const EdgeInsets.only(left: 8.0, right: 16.0),
                                        child: TextField(
                                          textInputAction: TextInputAction.done,
                                          maxLines: 5,
                                          enabled: damageSelectionSnapshot.data==2,
                                          onChanged: (description){
                                            inspectDataSnapshot.data!.tripEndInspectionRentout!.damageDesctiption=description;
                                            rentOutInspectBloc.changedInspectData.call( inspectDataSnapshot.data!);
                                          },
                                          decoration: InputDecoration(
                                            hintText: 'Add a description here',
                                            hintStyle: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 14,
                                              color: Color(0xFF686868),
                                              fontStyle: FontStyle.italic
                                            ),
                                            border: InputBorder.none
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["POOR", "GOOD", "EXCELLENT"],
                                    isSelected: [
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.cleanliness =='Poor',
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.cleanliness =='Good',
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.cleanliness =='Excellent'
                                    ],
                                    onPress: (selectedValue){
                                      switch(selectedValue){
                                        case 0:
                                          inspectDataSnapshot.data!.tripEndInspectionRentout!.cleanliness ='Poor';
                                          break;
                                        case 1:
                                          inspectDataSnapshot.data!.tripEndInspectionRentout!.cleanliness ='Good';
                                          inspectDataSnapshot.data!.tripEndInspectionRentout!.requestedCleaningFee =0;
                                          break;
                                        case 2:
                                          inspectDataSnapshot.data!.tripEndInspectionRentout!.cleanliness ='Excellent';
                                          inspectDataSnapshot.data!.tripEndInspectionRentout!.requestedCleaningFee =0;
                                          break;

                                      }
                                      rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title: "Cleanliness in the end of the trip",
                                ),
                                SizedBox(height: 10),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["NO", "REQUEST \$30"],
                                    isSelected: [
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.requestedCleaningFee==0,
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.requestedCleaningFee==30
                                    ],
                                    onPress:
                                        (selectedValue){
                                      if (inspectDataSnapshot.data!.tripEndInspectionRentout!.cleanliness=='Poor') {
                                        switch (selectedValue) {
                                          case 0:
                                            inspectDataSnapshot.data!
                                                .tripEndInspectionRentout!
                                                .requestedCleaningFee = 0;
                                            break;
                                          case 1:
                                            inspectDataSnapshot.data!
                                                .tripEndInspectionRentout!
                                                .requestedCleaningFee = 30;
                                            break;
                                        }
                                        rentOutInspectBloc.changedInspectData.call(
                                            inspectDataSnapshot.data!);
                                      }
                                    },
                                  ),
                                  title: "Request a cleaning fee?",
                                ),
                                SizedBox(height: 10),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["YES", "NO"],
                                    isSelected: [
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.isFuelSameLevelAsBefore!,
                                      !inspectDataSnapshot.data!.tripEndInspectionRentout!.isFuelSameLevelAsBefore!
                                    ],
                                    onPress: (selectedValue){
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.isFuelSameLevelAsBefore= selectedValue==0;
                                      if (inspectDataSnapshot.data!.tripEndInspectionRentout!.isFuelSameLevelAsBefore!){
                                        inspectDataSnapshot.data!.tripEndInspectionRentout!.requestedChargeForFuel=0;
                                      }
                                      rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title: "Is the fuel at the same level as before the trip?",
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        children: [
                                          SizedBox(
                                            width: double.maxFinite,
                                            child: Container(
                                              decoration: new BoxDecoration(
                                                color: Color(0xFFF2F2F2),
                                                borderRadius: new BorderRadius.circular(8.0),
                                              ),
                                              child: Container(
                                                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                                                  children: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 16, top: 8,right: 16,bottom: 16),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            child: AutoSizeText("How much do you want to charge for fuel?",maxLines: 3,
                                                              style: TextStyle(
                                                                fontFamily: 'Urbanist',
                                                                fontSize: 16,
                                                                color: Color(0xFF371D32),
                                                              ),
                                                            ),
                                                            width: MediaQuery.of(context).size.width*.60,
                                                          ),
                                                          SizedBox(width: 6,),
                                                          Text('\$${inspectDataSnapshot.data!.tripEndInspectionRentout!.requestedChargeForFuel}',
                                                            style: TextStyle(
                                                              fontFamily: 'Urbanist',
                                                              fontSize: 14,
                                                              color: Color(0xFF353B50),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: EdgeInsets.only(bottom: 8.0),
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                            child: SliderTheme(
                                                              data: SliderThemeData(
                                                                thumbColor: Color(0xffFFFFFF),
                                                                trackShape: RoundedRectSliderTrackShape(),
                                                                trackHeight: 4.0,
                                                                activeTrackColor: Color(0xffFF8F62),
                                                                inactiveTrackColor: Color(0xFFE0E0E0),
                                                                tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4.0),
                                                                activeTickMarkColor: Color(0xffFF8F62),
                                                                inactiveTickMarkColor: Color(0xFFE0E0E0),
                                                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: 14.0),
                                                              ),
                                                              child: Slider(
                                                                max: 100,
                                                                min: 0,
                                                                onChanged:  (double value){
                                                                  if (!inspectDataSnapshot.data!.tripEndInspectionRentout!.isFuelSameLevelAsBefore!) {
                                                                    inspectDataSnapshot.data!.tripEndInspectionRentout!.requestedChargeForFuel =
                                                                        int.parse(value.toStringAsFixed(0));
                                                                    rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                                                  }
                                                                },
                                                                value: inspectDataSnapshot.data!.tripEndInspectionRentout!.requestedChargeForFuel! as double,
                                                                divisions: 4,
                                                              // ),
                                                            ),
                                                          ),)
                                                        ],
                                                      ),
                                                    ),
                                                  ],
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
                                swapAgreementSnapshot.data!.swapAgreementTerms!.myCar!.preference!.dailyMileageAllowance=='Limited'?
                                Column(children: [
                                  ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["YES", "NO"],
                                    isSelected: [
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.isAddedMileageWithinAllocated!,
                                      !inspectDataSnapshot.data!.tripEndInspectionRentout!.isAddedMileageWithinAllocated!
                                    ],
                                    onPress: (selectedValue){
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.isAddedMileageWithinAllocated= selectedValue == 0;
                                      if (inspectDataSnapshot.data!.tripEndInspectionRentout!.isAddedMileageWithinAllocated!){
                                        inspectDataSnapshot.data!.tripEndInspectionRentout!.kmOverTheLimit = 0;
                                      }
                                      rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title: "Is the total mileage within the limit of ${swapAgreementSnapshot.data!.swapAgreementTerms!.myCar!.preference!.limit} km?",
                                ),
                                  SizedBox(height: 10),
                                  // SliderBox(
                                  //   title: "How many KM are over the limit?",
                                  //   onChange: (double value){
                                  //     if (!inspectDataSnapshot.data!.tripEndInspectionRentout!.isAddedMileageWithinAllocated) {
                                  //       inspectDataSnapshot.data!.tripEndInspectionRentout!.kmOverTheLimit = int.parse(value.toStringAsFixed(0));rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                  //     }
                                  //   },
                                  //   maxValue: 1000,
                                  //   minValue: 0,
                                  //   sliderValue: inspectDataSnapshot.data!.tripEndInspectionRentout!.kmOverTheLimit,
                                  // ),
                                  SizedBox(height: 10),],):
                                Container(),
                                ToggleBox(
                                  toggleButtons: RadioButton(
                                    items: ["NO", "YES"],
                                    isSelected: [
                                      !inspectDataSnapshot.data!.tripEndInspectionRentout!.isTicketsTolls!,
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.isTicketsTolls!
                                    ],
                                    onPress: (selectedValue){
                                      inspectDataSnapshot.data!.tripEndInspectionRentout!.isTicketsTolls = selectedValue == 1;
                                      rentOutInspectBloc.changedInspectData.call(inspectDataSnapshot.data!);
                                    },
                                  ),
                                  title: "Any tickets or tolls??",
                                  subtitle: "The driver is responsible for any violations, such as speeding, red light, parking or toll tickets during their trip. Please indicate if you've received any of these. You can also get reimbursement for tickets later.",
                                ),
                                SizedBox(height: 10),
                                /// tolls amount
                                Column(      crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Tickets and tolls amount",
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32)
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                          color: Color(0xFFF2F2F2),
                                          borderRadius: BorderRadius.circular(8.0)), child:
                                    TextField(
                                      enabled: inspectDataSnapshot.data!.tripEndInspectionRentout!.isTicketsTolls,
                                      onChanged:(amount){
                                        inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.amount=int.parse(amount.toString());
                                        rentOutInspectBloc.changedInspectData.call( inspectDataSnapshot.data!);
                                      },
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                      keyboardType:  Platform.isIOS?
                                      TextInputType.numberWithOptions(signed: true):
                                      TextInputType.number,
                                      textInputAction: TextInputAction.done,
                                      decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(14.0),
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
                                  ],),

                                SizedBox(height: 10),
                                RectangleBox(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tickets and tolls photos",
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32)
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 8, bottom: 10),
                                        child: Text(
                                          "Take photos of violations so the date, time and location are clearly visible.",
                                          style: TextStyle(
                                            fontFamily: 'Urbanist',
                                            fontSize: 14,
                                            color: Color(0xFF353B50)
                                          ),
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
                                            onTap:() => inspectDataSnapshot.data!.tripEndInspectionRentout!.isTicketsTolls!?
                                            _settingModalBottomSheet(context, 13,inspectDataSnapshot): null,
                                            child: inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![0] == ''
                                            ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topLeft: const Radius.circular(12.0),
                                                  bottomLeft: const Radius.circular(12.0),
                                                  topRight: const Radius.circular(12.0),
                                                  bottomRight: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) : Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![0]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![0]='';
                                                          rentOutInspectBloc.changedInspectData(inspectDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))
                                                    ),)

                                                ]
                                            ),

                                          ),
                                          GestureDetector(
                                            onTap: () => inspectDataSnapshot.data!.tripEndInspectionRentout!.isTicketsTolls!? _settingModalBottomSheet(context, 14,inspectDataSnapshot): null,
                                            child: inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![1] == '' ?
                                            Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topLeft: const Radius.circular(12.0),
                                                  bottomLeft: const Radius.circular(12.0),
                                                  topRight: const Radius.circular(12.0),
                                                  bottomRight: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) : Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![1]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![1]='';
                                                          rentOutInspectBloc.changedInspectData(inspectDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))
                                                    ),)

                                                ]
                                            ),

                                          ),
                                          GestureDetector(
                                            onTap: () => inspectDataSnapshot.data!.tripEndInspectionRentout!.isTicketsTolls!? _settingModalBottomSheet(context, 15,inspectDataSnapshot): null,
                                            child: inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![2] == '' ?
                                            Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topLeft: const Radius.circular(12.0),
                                                  bottomLeft: const Radius.circular(12.0),
                                                  topRight: const Radius.circular(12.0),
                                                  bottomRight: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![2]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          inspectDataSnapshot.data!.tripEndInspectionRentout!.ticketsTollsReimbursement!.imageIDs![2]='';
                                                          rentOutInspectBloc.changedInspectData(inspectDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))
                                                    ),)

                                                ]
                                            ),

                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 10),
                                //Rating//
                                StreamBuilder<RateTripGuestRequest>(
                                  stream: rentOutInspectBloc.rateTripGuest,
                                  builder: (context, rateTripGuestSnapshot) {
                                    return rateTripGuestSnapshot.hasData  && rateTripGuestSnapshot.data!=null?
                                      Container(
                                      padding: EdgeInsets.all(5.0),
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        color: Color(0xfff2f2f2),
                                        borderRadius: BorderRadius.all(Radius.circular(6)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0, right: 16.0, top: 10),
                                                child: Text("Rate your guest",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontFamily: 'Urbanist',
                                                    fontSize: 16,
                                                    color: Color(0xFF371D32)
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 10),
                                                child: SmoothStarRating(
                                                  allowHalfRating: false,
                                                    onRatingChanged: (v) {
                                                rateTripGuestSnapshot.data!.rateGuest=v.toStringAsFixed(0);
                                                rentOutInspectBloc.changedRateTripGuest.call(rateTripGuestSnapshot.data!);

                                                  },
                                                  starCount: 5,
                                                  rating: double.parse(rateTripGuestSnapshot.data!.rateGuest!),
                                                  size: 20.0,
                                                  // isReadOnly: false,
                                                  // fullRatedIconData: Icons.blur_off,
                                                  // halfRatedIconData: Icons.blur_on,
                                                  color: Color(0xffFF8F68),
                                                  borderColor: Color(0xffFF8F68),
                                                  spacing:0.0
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(left: 8.0, right: 16.0),
                                            child: TextField(
                                              maxLines: 5,
                                              textInputAction: TextInputAction.done,
                                         onChanged: (description){
                                           rateTripGuestSnapshot.data!.reviewGuestDescription=description.toString();
                                           rentOutInspectBloc.changedRateTripGuest.call( rateTripGuestSnapshot.data!);
                                         },
                                              decoration: InputDecoration(
                                                hintText: 'Write a review (optional)',
                                                hintStyle: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                  fontSize: 14,
                                                  color: Color(0xFF686868),
                                                  fontStyle: FontStyle.italic
                                                ),
                                                border: InputBorder.none
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ):Container();
                                  }
                                ),
                                SizedBox(height: 20),
                              ],
                            ),
                          ),
                          Divider(),
                          inspectDataSnapshot.hasError ? Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Text(inspectDataSnapshot.error.toString(),
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
                          ) : new Container(),
                          inspectDataSnapshot.hasError ? SizedBox(height: 10) : new Container(),

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
                                          style: ElevatedButton.styleFrom(
                                            elevation: 0.0,
                                            backgroundColor: Color(0xFFFF8F62),
                                            padding: EdgeInsets.all(16.0),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                                          ),
                                          onPressed: damageSelectionSnapshot.data!=0 && rentOutInspectBloc.checkValidation(inspectDataSnapshot.data!)?
                                              () async {
                                            var res = await rentOutInspectBloc.inspectRentout(inspectDataSnapshot.data!,tripDetails);
                                            if (res != null && res.status!.success!) {
                                              Navigator.pushNamed(
                                                context,
                                                '/inspection_completed',
                                                arguments: {'tripType': tripType, 'trip': tripDetails,'damage':inspectDataSnapshot.data!.tripEndInspectionRentout!.isNoticibleDamage},
                                              );
                                            } else {
                                              // show snackbar useing rentOutInspectBloc.errorMessage

                                              final snackBar = SnackBar(content: Text(rentOutInspectBloc.errorMessage),);
                                              // _scaffoldKey.currentState.showSnackBar(snackBar);
                                              ScaffoldMessenger.of(context).showSnackBar(snackBar);

                                              Future.delayed(Duration(seconds: 2), (){
                                                Navigator.of(context).pushNamed(path, arguments: {
                                                  'tripType': tripType,
                                                  'trip': tripDetails
                                                });
                                              });
                                            }
                                          }: null,
                                          child: Text('Complete Inspection',
                                            style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 18,
                                              color: Colors.white
                                            ),
                                          ),
                                        ),
                                      )
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ) : SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 220,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 12.0, right: 12),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: MediaQuery.of(context).size.width / 3,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 14,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 250,
                        width: MediaQuery.of(context).size.width,
                        child: Shimmer.fromColors(
                            baseColor: Colors.grey.shade300,
                            highlightColor: Colors.grey.shade100,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 16.0, right: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(10)),
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            height: 14,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                  ),
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
                }
              );
            }
          ):Container();
        }
      ),
    );
  }
}

