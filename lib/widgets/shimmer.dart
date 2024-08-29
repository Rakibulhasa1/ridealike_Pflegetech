import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerEffect extends StatelessWidget {
  const ShimmerEffect({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [  SizedBox(
          height: 10,
        ),
          SizedBox(
            height: 220,
            width: MediaQuery.of(context).size.width,
            child: Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
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
                      padding: const EdgeInsets.only(left: 12.0, right: 12),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )),
              ),
            ],
          ),
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
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
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
                      padding: const EdgeInsets.only(left: 12.0, right: 12),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )),
              ),
              // SizedBox(
              //   height: 15,
              //   width: MediaQuery.of(context).size.width / 4,
              //   child: Shimmer.fromColors(
              //       baseColor: Colors.grey.shade300,
              //       highlightColor: Colors.grey.shade100,
              //       child: Padding(
              //         padding: const EdgeInsets.only(left: 16.0, right: 16),
              //         child: Container(
              //           decoration: BoxDecoration(
              //               color: Colors.grey[300],
              //               borderRadius: BorderRadius.circular(10)),
              //         ),
              //       )),
              // ),
            ],
          ),
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
                  padding: const EdgeInsets.only(left: 12.0, right: 12),
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
                      padding: const EdgeInsets.only(left: 12.0, right: 12),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    )),
              ),
              // SizedBox(
              //   height: 15,
              //   width: MediaQuery.of(context).size.width / 4,
              //   child: Shimmer.fromColors(
              //       baseColor: Colors.grey.shade300,
              //       highlightColor: Colors.grey.shade100,
              //       child: Padding(
              //         padding: const EdgeInsets.only(left: 16.0, right: 16),
              //         child: Container(
              //           decoration: BoxDecoration(
              //               color: Colors.grey[300],
              //               borderRadius: BorderRadius.circular(10)),
              //         ),
              //       )),
              // ),
            ],
          )
          ,],
      ),
    );
  }
}