import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({Key? key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment
          .start,
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: Shimmer
              .fromColors(
              baseColor:
              Color(
                  0xffEA9475),
              highlightColor:
              Color(
                  0xffF68E65),
              child:
              Padding(
                padding: const EdgeInsets
                    .only(
                    left:
                    12.0,
                    right:
                    6),
                child:
                Container(
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.grey[300],
                    borderRadius:
                    BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              )),
        ),
        SizedBox(
          height: 150,
          width: 150,
          child: Shimmer
              .fromColors(
              baseColor:
              Color(
                  0xffEA9475),
              highlightColor:
              Color(
                  0xffF68E65),
              child:
              Padding(
                padding: const EdgeInsets
                    .only(
                    left:
                    6,
                    right:
                    6),
                child:
                Container(
                  decoration: BoxDecoration(
                      color:
                      Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                ),
              )),
        ),
        SizedBox(
          height: 150,
          width: 150,
          child: Shimmer
              .fromColors(
              baseColor:
              Color(
                  0xffEA9475),
              highlightColor:
              Color(
                  0xffF68E65),
              child:
              Padding(
                padding: const EdgeInsets
                    .only(
                    left:
                    6,
                    right:
                    6),
                child:
                Container(
                  decoration: BoxDecoration(
                      color:
                      Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                ),
              )),
        ),
        SizedBox(
          height: 150,
          width: 150,
          child: Shimmer
              .fromColors(
              baseColor:
              Color(
                  0xffEA9475),
              highlightColor:
              Color(
                  0xffF68E65),
              child:
              Padding(
                padding: const EdgeInsets
                    .only(
                    left:
                    6,
                    right:
                    6),
                child:
                Container(
                  decoration: BoxDecoration(
                      color:
                      Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                ),
              )),
        ),
        SizedBox(
          height: 150,
          width: 150,
          child: Shimmer
              .fromColors(
              baseColor:
              Color(
                  0xffEA9475),
              highlightColor:
              Color(
                  0xffF68E65),
              child:
              Padding(
                padding: const EdgeInsets
                    .only(
                    left:
                    6,
                    right:
                    12),
                child:
                Container(
                  decoration: BoxDecoration(
                      color:
                      Colors.grey[300],
                      borderRadius: BorderRadius.circular(10)),
                ),
              )),
        ),
      ],
    );
  }
}
