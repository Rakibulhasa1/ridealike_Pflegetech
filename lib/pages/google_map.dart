import 'dart:async';

import 'package:flutter/material.dart';
//
// import 'package:search_map_place/search_map_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:search_map_place_updated/search_map_place_updated.dart';

class GoogleMapExample extends StatefulWidget {
  @override
  State createState() => GoogleMapExampleState();
}

class GoogleMapExampleState extends State<GoogleMapExample> {
  static var location = LatLng(40.730610, -73.935242);
  GoogleMapController? mapController;

  Completer<GoogleMapController> _mapController = Completer();

  final Set<Marker> _markers = new Set();
  CameraPosition _initialCamera = CameraPosition(
    target: location,
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            zoomGesturesEnabled: true,
            initialCameraPosition: _initialCamera,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) {
              _mapController.complete(controller);
            },
//                (controller){setState(() {
//              mapController=controller;
//            });
//            },
            onTap: (latLong) {
              // print("lat  ${latLong.latitude}");
              // print("long  ${latLong.longitude}");
              setState(() {
                location = latLong;
              });
            },
            markers: this.myMarker(),
          ),
          Positioned(
            top: 15,
            right: 15,
            left: 15,
            child:
            SearchMapPlaceWidget(
              placeholder: 'Enter the address',
              iconColor: Color(0xff371D32),
              bgColor: Colors.white,
              textColor:Color(0xff371D32),
              icon: Icons.search,
              // apiKey: "AIzaSyALNTeZ3VJjy58ogMajutj_m_kmDwPAQDA",
              apiKey: googleApiKeyUrl,
              onSelected: (place) async {
                // print(place.fullJSON);
                final geolocation = await place.geolocation;
                final GoogleMapController controller = await _mapController.future;
                setState(() {
                  location = geolocation!.coordinates;
                });
                //  print(geolocation.coordinates);
                controller.animateCamera(CameraUpdate.newLatLng(geolocation!.coordinates));
                controller.animateCamera(CameraUpdate.newLatLngBounds(geolocation!.bounds, 0));
              },
            ),
          )
        ],
      ),
    );
  }

  Set<Marker> myMarker() {
    setState(() {
      _markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_initialCamera.toString()),
        position: location,
//        infoWindow: InfoWindow(
//          title: 'Historical the City',
//          snippet: '5 Star Rating',
//        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });

    return _markers;
  }

}