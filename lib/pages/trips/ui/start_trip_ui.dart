import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/bloc/start_trip_inspection_bloc.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';
import 'package:ridealike/pages/trips/response_model/start_trip_inspect_rental_response.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';
import 'package:ridealike/widgets/custom_buttom.dart';
class StartTripUi extends StatefulWidget {
  @override
  State createState() => StartTripUiState();
}

class StartTripUiState extends State<StartTripUi> {

  final startTripBloc=StartTripBloc();


  void _settingModalBottomSheet(context, _imgOrder, AsyncSnapshot<InspectTripStartResponse> startTripDataSnapshot){
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
                    startTripBloc.pickeImageThroughCamera(_imgOrder,startTripDataSnapshot,context);
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
                    startTripBloc.pickeImageFromGallery(_imgOrder,startTripDataSnapshot,context);
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
  void initState(){
    super.initState();
    AppEventsUtils.logEvent("view_trip_start");
  }

  @override
  Widget build(BuildContext context) {
    final receivedData = ModalRoute.of(context)!.settings.arguments;
    Trips tripDetails = receivedData as Trips;
    InspectTripStartResponse inspectTripStartResponse =
    InspectTripStartResponse(tripStartInspection: TripStartInspection(exteriorCleanliness: null,damageImageIDs: List.filled(12, ''),
        dashboardImageIDs: List.filled(2, ''),inspectionByUserID:tripDetails.userID, tripID:tripDetails.tripID));
    startTripBloc.changedStartTripData.call(inspectTripStartResponse);
    startTripBloc.changedDamageSelection.call(0);
    return Scaffold(
      body: StreamBuilder<InspectTripStartResponse>(
          stream: startTripBloc.startTripData,
          builder: (context, startTripDataSnapshot) {
            return startTripDataSnapshot.hasData && startTripDataSnapshot.data!=null?
            StreamBuilder<int>(
                stream: startTripBloc.damageSelection,
                builder: (context, damageSelectionSnapshot) {
                  return Container(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: 40),
                            Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text("Cancel",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFFF68E65)
                                    ),
                                  ),
                                ),
                                Text("",
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Color(0xFF371D32)
                                  ),
                                ),
                                Text('             '),

                              ],
                            ),
                            SizedBox(height: 30),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text("Start trip",
                                  style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 36,
                                      color: Color(0xFF371D32),
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                                Center(
                                  child: (tripDetails.carImageId != null || tripDetails.carImageId != '') ? CircleAvatar(
                                    backgroundImage: NetworkImage('$storageServerUrl/${tripDetails.carImageId}'),
                                    radius: 17.5,
                                  )
                                      : CircleAvatar(
                                    backgroundImage: AssetImage('images/car-placeholder.png'),
                                    radius: 17.5,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                            Container(
                              decoration: BoxDecoration(
                                color: Color(0xfff2f2f2),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Any noticeable damage before the trip?",
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32)
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text("Inspect vehicle's inside and outside for any visual damage, like dents, scratches or broken parts.",
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 14,
                                          color: Color(0xFF353B50)
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Expanded(
                                          child: CustomButton(
                                            title: 'NO',
                                            isSelected: damageSelectionSnapshot.data==1?true:false,
                                            press: () {
                                              startTripDataSnapshot.data!.tripStartInspection!.isNoticibleDamage= false;
                                              startTripBloc.changedStartTripData.call(startTripDataSnapshot.data!);
                                              startTripBloc.changedDamageSelection.call(1);
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10.0),
                                        Expanded(
                                          child: CustomButton(
                                            title: 'YES',
                                            isSelected:  damageSelectionSnapshot.data==2?true:false,
                                            press: () {
                                              startTripDataSnapshot.data!.tripStartInspection!.isNoticibleDamage= true;
                                              startTripBloc.changedStartTripData.call(startTripDataSnapshot.data!);
                                              startTripBloc.changedDamageSelection.call(2);
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
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Take photos of existing damage",
                                      style: TextStyle(
                                          fontFamily: 'Urbanist',
                                          fontSize: 16,
                                          color: Color(0xFF371D32)
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
                                          onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                              ? () => {} : () => _settingModalBottomSheet(context, 1,startTripDataSnapshot),
                                          child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![0] == '' ?
                                          Container(
                                            child: Image.asset('icons/Scan-Placeholder.png'),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFE0E0E0),
                                              borderRadius: new BorderRadius.only(
                                                topLeft: const Radius.circular(12.0),
                                                bottomLeft: const Radius.circular(12.0),
                                              ),
                                            ),
                                          ) :
                                          Stack(
                                              children: <Widget>[
                                                SizedBox(
                                                    child: Image(fit: BoxFit.fill,image:
                                                    NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![0]}'),),
                                                    width: double.maxFinite ),
                                                Positioned(right: 5, bottom: 5,
                                                  child: InkWell(
                                                      onTap: (){
                                                        startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![0]='';
                                                        startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                      },
                                                      child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                          child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))
                                                  ),)

                                              ]
                                          ),
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 2,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![1] == '' ?
                                            Container(child: Image.asset('icons/Scan-Placeholder.png'), color: Color(0xFFE0E0E0),) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![1]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![1]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 3,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2] == '' ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topRight: const Radius.circular(12.0),
                                                  bottomRight: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
//
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 4,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![3] == '' ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topLeft: const Radius.circular(12.0),
                                                  bottomLeft: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![3]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![3]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
//
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 5,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![4] == '' ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'), color: Color(0xFFE0E0E0),

                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![4]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![4]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
//                                      Container(
//                                        alignment: Alignment.bottomCenter,
//                                        width: 100,
//                                        height: 100,
//                                        decoration: new BoxDecoration(
//                                          color: Color(0xFFF2F2F2),
//                                          image: DecorationImage(
//                                            image: NetworkImage('https://api.storage.ridealike.anexa.dev/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![2]}'),
//                                            fit: BoxFit.fill,
//                                          ),
//                                          borderRadius: new BorderRadius.only(
//                                            topRight: const Radius.circular(12.0),
//                                            bottomRight: const Radius.circular(12.0),
//                                          ),
//                                        ),
//                                      ),
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 6,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![5] == '' ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topRight: const Radius.circular(12.0),
                                                  bottomRight: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![5]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![5]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
//
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 7,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![6] == '' ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topLeft: const Radius.circular(12.0),
                                                  bottomLeft: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![6]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![6]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
//
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 8,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![7] == '' ? Container(
                                                child: Image.asset('icons/Scan-Placeholder.png'), color: Color(0xFFE0E0E0)

                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![7]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![7]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
//
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 9,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![8] == '' ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topRight: const Radius.circular(12.0),
                                                  bottomRight: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![8]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![8]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
//
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 10,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![9] == '' ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topLeft: const Radius.circular(12.0),
                                                  bottomLeft: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![9]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![9]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
//
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 11,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![10] == '' ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'), color: Color(0xFFE0E0E0),

                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![10]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![10]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )
//
                                        ),
                                        GestureDetector(
                                            onTap: damageSelectionSnapshot.data!=1 && damageSelectionSnapshot.data!=2
                                                ? () => {}
                                                :() => _settingModalBottomSheet(context, 12,startTripDataSnapshot),
                                            child: startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![11] == '' ? Container(
                                              child: Image.asset('icons/Scan-Placeholder.png'),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFE0E0E0),
                                                borderRadius: new BorderRadius.only(
                                                  topRight: const Radius.circular(12.0),
                                                  bottomRight: const Radius.circular(12.0),
                                                ),
                                              ),
                                            ) :
                                            Stack(
                                                children: <Widget>[
                                                  SizedBox(
                                                      child: Image(fit: BoxFit.fill,image:
                                                      NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![11]}'),),
                                                      width: double.maxFinite ),
                                                  Positioned(right: 5, bottom: 5,
                                                    child: InkWell(
                                                        onTap: (){
                                                          startTripDataSnapshot.data!.tripStartInspection!.damageImageIDs![11]='';
                                                          startTripBloc.changedStartTripData.call( startTripDataSnapshot.data!);
                                                        },
                                                        child: CircleAvatar(backgroundColor: Colors.white,radius: 10,
                                                            child: Icon(Icons.delete,color: Color(0xffF55A51),size: 20,))),)

                                                ]
                                            )

                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xfff2f2f2),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Take photo(s) of the odometer and fuel gauge.'
                                    // "Take photos of a dashboard before the trip"
                                    ,
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32)
                                    ),
                                  ),
                                  Text("To capture existing mileage and fuel level",
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        color: Color(0xFF353B50)
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
                                        onTap: () => _settingModalBottomSheet(context, 13,startTripDataSnapshot),
                                        child: startTripDataSnapshot.data!.tripStartInspection!.dashboardImageIDs![0] == '' ?
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
                                        Container(
                                          alignment: Alignment.bottomCenter,
                                          width: 100,
                                          height: 100,
                                          decoration: new BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            image: DecorationImage(
                                              image: NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.dashboardImageIDs![0]}'),
                                              fit: BoxFit.fill,
                                            ),
                                            borderRadius: new BorderRadius.only(
                                              topLeft: const Radius.circular(12.0),
                                              bottomLeft: const Radius.circular(12.0),
                                              topRight: const Radius.circular(12.0),
                                              bottomRight: const Radius.circular(12.0),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap:

                                            () => _settingModalBottomSheet(context, 14,startTripDataSnapshot),
                                        child: startTripDataSnapshot.data!.tripStartInspection!.dashboardImageIDs![1] == '' ?
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
                                        Container(
                                          alignment: Alignment.bottomCenter,
                                          width: 100,
                                          height: 100,
                                          decoration: new BoxDecoration(
                                            color: Color(0xFFF2F2F2),
                                            image: DecorationImage(
                                              image: NetworkImage('$storageServerUrl/${startTripDataSnapshot.data!.tripStartInspection!.dashboardImageIDs![1]}'),
                                              fit: BoxFit.fill,
                                            ),
                                            borderRadius: new BorderRadius.only(
                                              topLeft: const Radius.circular(12.0),
                                              bottomLeft: const Radius.circular(12.0),
                                              topRight: const Radius.circular(12.0),
                                              bottomRight: const Radius.circular(12.0),
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
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Color(0xfff2f2f2),
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("Cleanliness before the trip",
                                    style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32)
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: CustomButton(
                                          title: 'POOR',
                                          isSelected: startTripDataSnapshot.data!.tripStartInspection!.exteriorCleanliness == 'Poor',
                                          press: () {
                                            startTripDataSnapshot.data!.tripStartInspection!.exteriorCleanliness = 'Poor';
                                            startTripBloc.changedStartTripData.call(startTripDataSnapshot.data!);

                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10.0),
                                      Expanded(
                                        child: CustomButton(
                                          title: 'GOOD',
                                          isSelected: startTripDataSnapshot.data!.tripStartInspection!.exteriorCleanliness == 'Good',
                                          press: () {

                                            startTripDataSnapshot.data!.tripStartInspection!.exteriorCleanliness = 'Good';
                                            startTripBloc.changedStartTripData.call(startTripDataSnapshot.data!);
                                          },
                                        ),
                                      ),
                                      SizedBox(width: 10.0),
                                      Expanded(
                                        child: CustomButton(
                                          title: 'EXCELLENT',
                                          isSelected: startTripDataSnapshot.data!.tripStartInspection!.exteriorCleanliness == 'Excellent',
                                          press: () {

                                            startTripDataSnapshot.data!.tripStartInspection!.exteriorCleanliness = 'Excellent';
                                            startTripBloc.changedStartTripData.call(startTripDataSnapshot.data!);
                                          },
                                        ),
                                      ),
                                    ],
                                  )
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
                                        child: ElevatedButton(style: ElevatedButton.styleFrom(
                                          elevation: 0.0,
                                          backgroundColor: Color(0xffFF8F68),
                                          padding: EdgeInsets.all(16.0),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),),
                                          onPressed:
                                          ( damageSelectionSnapshot.data==1 || damageSelectionSnapshot.data==2 )&&
                                              startTripBloc.checkValidation(startTripDataSnapshot.data!)?() async {
                                            // var res = await startTripBloc.startTripInspectionsMethod(startTripDataSnapshot.data!);
                                            var res2 = await startTripBloc.startTripMethod(startTripDataSnapshot.data!.tripStartInspection!.tripID);
                                            // print("Check validation: " + s);
                                            AppEventsUtils.logEvent("trip_start_successful",
                                                params: {
                                                  "tripId":tripDetails.tripID,
                                                  "tripStartStatus": res2!.status!.success,
                                                  "carName":tripDetails.car!.about!.make,
                                                  "host":tripDetails.hostProfile!.firstName
                                                });

                                            if(res2.status!.success!) {
                                              Navigator.pushNamed(
                                                context,
                                                '/trip_started',
                                                arguments: tripDetails,
                                              );
                                            }
                                          }:(){
                                            print("trip cant be started");
                                          },
                                          child: Text('Start trip',
                                            style: TextStyle(
                                                fontFamily: 'Urbanist',
                                                fontSize: 18,
                                                color: Colors.white
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
                }
            ):Container();
          }
      ),
    );
  }
}