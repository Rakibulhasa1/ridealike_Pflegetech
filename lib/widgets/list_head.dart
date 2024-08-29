import 'package:flutter/material.dart';

class ListHead extends StatelessWidget {
  final String title;
  const ListHead({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 12,
              color: Color(0xFF371D32).withOpacity(0.5)
            ),
          ),
        ),
        Divider(),
      ],
    );
  }
}
