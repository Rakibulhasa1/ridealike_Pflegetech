import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pinch_zoom/pinch_zoom.dart';

class ImageDetails extends StatelessWidget {
  final List<String>? images;
  final int? initialIndex;
  final String? image;

  ImageDetails({ this.images,  this.initialIndex, this.image});

  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(initialPage: initialIndex!);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: pageController,
          itemCount: images!.length,
          itemBuilder: (context, index) {
            return Center(
              child: PinchZoom(
                zoomEnabled: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: CachedNetworkImage(
                    imageUrl: images![index],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
