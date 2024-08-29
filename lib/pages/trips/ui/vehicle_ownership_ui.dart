import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/trips/response_model/get_all_user_trips_group_status_response.dart';



class TripVehicleOwnerShip extends StatefulWidget {
  @override
  _TripVehicleOwnerShipState createState() => _TripVehicleOwnerShipState();
}

class _TripVehicleOwnerShipState extends State<TripVehicleOwnerShip> {


  @override
  Widget build(BuildContext context) {
    final TripAllUserStatusGroupResponse ownerShipId = ModalRoute.of(context)!.settings.arguments as TripAllUserStatusGroupResponse;
    print('ownerShipId${ownerShipId.vehicleOwnershipDocument}');
    return Scaffold( backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(icon: Icon(Icons.arrow_back, color: Color(0xffFF8F68)),onPressed: (){
          Navigator.pop(context);
        },),
          centerTitle: true,
          title: Text(
            'Vehicle ownership document',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 16,
              color: Color(0xff371D32),
            ),
          ),
        ),
        body:  ownerShipId.vehicleOwnershipDocument !=null && ownerShipId.vehicleOwnershipDocument !=''?
        Container(
          child: Padding(
            padding: const EdgeInsets.only(top: 45,left: 20,right: 20),
            child: Image.network('$storageServerUrl/${ownerShipId.vehicleOwnershipDocument}',
         ),
          ),):
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new CircularProgressIndicator(strokeWidth: 2.5)
            ],
          ),
        ),


    );
  }
}