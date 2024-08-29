import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String title;

  const CustomTextField(this.title);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _writeMode = false;
  final TextEditingController _enterAmountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _writeMode = true;
        });
      },
      child: Container(
        padding: EdgeInsets.all(5.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Color(0xfff2f2f2),
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
          child: _writeMode
              ? SizedBox(
                  height: 19,
                  child:
                  TextField(
                    autofocus: true,
                      onEditingComplete: (){
                        print('on completed: ' + _enterAmountController.text);
                      },
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8),
                          border: InputBorder.none, prefixText: '\$')),
                )
              : Text(
                  widget.title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xFF371D32)),
                ),
        ),
      ),
    );
  }
}
