import 'package:blur/blur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Popup widget that you can you by default to show some information
class CustomSnackBar extends StatefulWidget {
  final String? title;
  final String? message;
  final Widget? icon;

  CustomSnackBar({
    Key? key,
    required this.title,
    required this.message,
    required this.icon,
  }) : super(key: key);

  const CustomSnackBar.show({
    Key? key,
    this.title,
    this.message,
    this.icon,
  });

  @override
  _CustomSnackBarState createState() => _CustomSnackBarState();
}

class _CustomSnackBarState extends State<CustomSnackBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Blur(
      blur: 5,
      borderRadius: BorderRadius.all(Radius.circular(15)),
      blurColor: CupertinoColors.lightBackgroundGray,
      overlay: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        width: double.infinity,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(height: 15, width: 15, child: widget.icon),
                    SizedBox(
                      width: 5,
                    ),
                    Expanded(
                      child: Text(
                        "RIDEALIKE",
                        style: theme.textTheme.bodyText2!.merge(
                          TextStyle(
                            color: Colors.black54,
                            fontSize: 12.5,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                /*SizedBox(
                  height: 2.5,
                ),*/
                Text(
                  widget.title!,
                  style: theme.textTheme.bodyText2!.merge(
                    TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  widget.message!,
                  style: theme.textTheme.bodyText2!.merge(
                    TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
      child: Container(
        height: 90,
        width: double.infinity,
      ),
    );
  }
}
