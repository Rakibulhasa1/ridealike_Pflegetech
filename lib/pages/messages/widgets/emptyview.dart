import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String message;

  EmptyView({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: this.message != null
              ? Text(
                  this.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                )
              : Container(),
        ),
      ),
    );
  }
}
