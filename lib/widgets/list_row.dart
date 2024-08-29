import 'package:flutter/material.dart';

class ListRow extends StatelessWidget {
  final Widget? leading;
  final Widget trailing;
  final Widget title;
  final Widget? subtitle;
  final bool showDivider;

  ListRow({
    this.leading,
    this.subtitle,
    this.showDivider = true,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (leading != null) leading!,
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 28,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        title,
                        if (subtitle != null)
                          Padding(
                            padding: EdgeInsets.only(
                              top: 8,
                            ),
                            child: subtitle,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  child: trailing,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(),
      ],
    );
  }
}
