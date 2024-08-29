import 'package:fluster/fluster.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker extends Clusterable {
  final int id;
  final LatLng position;
  BitmapDescriptor? icon;
  final void Function()? onTap;
  bool? isSelfLocation = false;

  MapMarker({
    required this.id,
    required this.position,
    this.icon,
    this.onTap,
    isCluster = false,

    clusterId,
    pointsSize,
    childMarkerId, this.isSelfLocation
  }) : super(
    markerId: id.toString(),
    latitude: position.latitude,
    longitude: position.longitude,
    isCluster: isCluster,
    clusterId: clusterId,
    pointsSize: pointsSize,
    childMarkerId: childMarkerId,
  );

  Marker toMarker() => Marker(
    markerId: MarkerId(isCluster! ? 'cl_$id' : id.toString()),
    position: LatLng(
      position.latitude,
      position.longitude,
    ),
    icon: icon!,
    onTap: onTap,
  );
}