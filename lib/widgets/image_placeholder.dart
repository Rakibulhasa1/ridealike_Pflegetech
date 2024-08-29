import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  final BorderRadiusGeometry? borderRadius;
  final Function()? onDelete;
  const ImagePlaceholder({Key? key, this.borderRadius, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius:
              borderRadius == null ? BorderRadius.circular(0) : borderRadius!,
          child: Image.network(
            "https://images.unsplash.com/photo-1533945731234-1d47cc3a906b?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=668&q=80",
            width: 100,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Material(
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onDelete,
              child: Container(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.delete,
                  color: Theme.of(context).errorColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
