import 'package:flutter/material.dart';

import 'package:ridealike/utils/enums.dart';
import 'package:ridealike/pages/common/constant_url.dart';

class CustomImageField extends StatelessWidget {
  final Function()? onTap;
  final ImageState? imageState;
  final ValueNotifier<String>? imageId;

  CustomImageField({this.imageState, this.imageId, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: imageState == ImageState.empty ?
      Container(
        width: double.maxFinite,
        padding: EdgeInsets.only(
            top: 99.0, bottom: 99.0),
        decoration: new BoxDecoration(
          color: Color(0xFFF2F2F2),
          borderRadius:
          new BorderRadius.circular(12.0),
        ),
        child: Icon(
          Icons.camera_alt,
          color: Color(0xFFABABAB),
          size: 50.0,
        ),
      ) :
      SizedBox(
        width: double.maxFinite,
        child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: ValueListenableBuilder(
              valueListenable: imageId!,
              builder: (context, value, child) => Image.network(
                '$storageServerUrl/$value',
                fit: BoxFit.cover,
              ),
            )),
      ),
    );
  }
}
