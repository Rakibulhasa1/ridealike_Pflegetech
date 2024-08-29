import 'package:flutter/material.dart';
import 'package:ridealike/widgets/calendar.dart';

class ManageYourCalendar extends StatefulWidget {
  @override
  _ManageYourCalendarState createState() => _ManageYourCalendarState();
}

class _ManageYourCalendarState extends State<ManageYourCalendar> {
  
  @override
  Widget build(BuildContext context) {
    final  dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

    bool _isButtonPressed = false;

    return Scaffold(
      backgroundColor: Colors.white,
      
      appBar: new AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back, color: Color(0xFFFF8F68)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: () {},
                child: Center(
                  child: Container(
                    margin: EdgeInsets.only(right: 16),
                    child: Text(
                      'Save & Exit',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 16,
                        color: Color(0xFFFF8F68),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Center(
                child: Container(
                  height: 2,
                  width: 79,
                  margin: EdgeInsets.only(right: 16),
                  child: LinearProgressIndicator(
                    value: 0.24,
                    backgroundColor: Color(0xFFF2F2F2),
                  ),
                ),
              ),
            ],
          ),
        ],
        elevation: 0.0,
      ),
      
      body: new SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Container(
                            child: Text('Manage your Calendar',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 36,
                                color: Color(0xFF371D32),
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Image.asset('icons/Calendar_Manage-Calendar.png'),
                ],
              ),
              SizedBox(height: 15),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.maxFinite,
                          child: Text('Select dates to block or unblock.',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 16,
                              color: Color(0xFF353B50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Calendar(),
              SizedBox(
                width: double.maxFinite,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0.0,
                    backgroundColor: Color(0xFFFF8F68),
                    padding: EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                  ),
                   onPressed: _isButtonPressed ? null : () {
                    setState(() {
                      _isButtonPressed = true;
                    });
                    
                    Navigator.pushNamed(
                      context, 
                      '/price_your_car',
                      arguments: receivedData,
                    );
                  },
                  child: _isButtonPressed ? SizedBox(
                    height: 18.0,
                    width: 18.0,
                    child: new CircularProgressIndicator(strokeWidth: 2.5),
                  ) : Text('Next: Pricing',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 18,
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
