import 'package:flutter/material.dart';
class CarsNearby extends StatefulWidget {
  const CarsNearby({Key? key});

  @override
  State<CarsNearby> createState() => _CarsNearbyState();
}

class _CarsNearbyState extends State<CarsNearby> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: Colors.red,
        child: Center(
          child: Text(
            "Red Container for the first tab",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
