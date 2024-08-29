import 'dart:async';
import 'dart:ui';

import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridealike/widgets/map_marker.dart';
import 'package:ridealike/widgets/swap_car_list_cluster_non_search.dart';

import '../pages/discover/response_model/fetchNewCarResponse.dart';
class SwapClusterUtils{
  static Fluster<MapMarker>? _fluster;
  static double currentZoom = 11.0000;
  static final Color _clusterColor = Color(0xffFF8F68);
  static final Color _clusterTextColor = Colors.white;

  static void initFluster(
      {List? markers,
        BuildContext? context,
        Stream<FetchNewCarResponse>? stream,
        void Function()? onModalClose,
        List? carData,
        String? startDate,
        String? endDate}){

    _fluster = Fluster<MapMarker>(
        minZoom: 0,
        maxZoom: 22,
        radius: 150,
        extent: 1024,
        nodeSize: 64,
        points: markers,
        createCluster: (
            BaseCluster cluster,
            double lng,
            double lat,
            ){
          return MapMarker(
              id: cluster.id!,
              position: LatLng(lat, lng),
              isCluster: cluster.isCluster,
              clusterId: cluster.id,
              pointsSize: cluster.pointsSize,
              childMarkerId: cluster.childMarkerId,
              onTap: () {
                showClusterCarsModal(
                    clusterId: cluster.id!,
                    context: context!,
                    stream: stream!,
                    onModalClose: onModalClose!,
                    carData: carData!,
                    startDate: startDate!,
                    endDate: endDate!);
              }
          );
        }
    );

  }

  static Future<BitmapDescriptor> getClusterMarker(
      {int? clusterSize,
        Color? clusterColor,
        Color? textColor,
        int? width}) async {
    assert(clusterSize != null);
    assert(clusterColor != null);
    assert(width != null);

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = clusterColor!;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double radius = width! / 2;

    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );

    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );

    final image = await pictureRecorder.endRecording().toImage(
      radius.toInt() * 2,
      radius.toInt() * 2,
    );
    final data = await image.toByteData(format: ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  static Future updateMarkers([double? updatedZoom]) async {
    if (_fluster == null || updatedZoom == currentZoom) return;

    if (updatedZoom != null) {
      currentZoom = updatedZoom;
    }

    final updatedMarkers = await Future.wait(_fluster!.clusters(
        [-180, -85, 180, 85], currentZoom.toInt()).map((mapMarker) async {
      if (mapMarker.isCluster!) {
        mapMarker.icon = await getClusterMarker(
          clusterSize: mapMarker.pointsSize,
          clusterColor: _clusterColor,
          textColor: _clusterTextColor,
          width: 80,
        );
      }

      return mapMarker.toMarker();
    }).toList());

    return updatedMarkers;

  }


  //bottom modal sheet
  static void showClusterCarsModal(
      {int? clusterId,
        BuildContext? context,
        Stream<FetchNewCarResponse>? stream,
        void Function()?  onModalClose,
        List? carData,
        String? startDate,
        String? endDate}){
    //children inside a cluster
    List<MapMarker> points = _fluster!.points(clusterId!);

    //bottom modal
    showModalBottomSheet(
      context: context!,
      builder: (context){

        // non search
        return
          SwapCarListClusterNonSearch(stream: stream, points: points,);
        // search
        // CarListClusterOnSearch(points: points, carData: carData, startDate: startDate, endDate: endDate,);
      },
    ).whenComplete(onModalClose!);
  }
}




