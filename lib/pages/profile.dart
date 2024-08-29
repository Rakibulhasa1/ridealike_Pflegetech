import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  @override
  Widget build (BuildContext context) => new Scaffold(

    //App Bar
    appBar: new AppBar(
      leading: new IconButton(
        icon: new Icon(Icons.arrow_back, color: Color(0xFFEA9A62)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      elevation: 0.0,
    ),

    //Content of tabs
    body: new SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
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
                        child: Text('Profile',
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
              Container(
                width: 50,
                height: 50,
                decoration: new BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.1),
                    blurRadius: 8.0,
                  ),]
                ),
                child: Icon(
                  Icons.notifications_active,
                  size: 24,
                  color: Color(0xFF371D32),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xFFF2F2F2),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                          ),onPressed: () {

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  Center(
                                    child: CircleAvatar(
                                      backgroundImage: AssetImage('images/user.jpg'),
                                      radius: 25,
                                    )
                                  )
                                ],
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('John Doe',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 16,
                                      color: Color(0xFF371D32)
                                    ),
                                  ),
                                  Text('Verification in progress',
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 14,
                                      color: Color(0xFF353B50),
                                    ),
                                  )
                                ],
                              )
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xFFF2F2F2),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: [
                                    Icon(Icons.mail, color: Color(0xFF3C2235)),
                                    SizedBox(width: 10),
                                    Text('Verify your email',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: new BoxDecoration(
                                  color: Color(0xFFF55A51),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xFFF2F2F2),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: [
                                    // Icon(Icons.party_mode, color: Color(0xFF3C2235)),
                                    Image.asset('icons/Introduce Yourself.png'),
                                    SizedBox(width: 10),
                                    Text('Introduce yourself',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: new BoxDecoration(
                                  color: Color(0xFFF55A51),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xFFF2F2F2),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),onPressed: () {

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: [
                                    Icon(Icons.notifications_active, color: Color(0xFF3C2235)),
                                    SizedBox(width: 10),
                                    Text('Notification settings',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                              Container(
                                width: 16,
                                child: Icon(
                                  Icons.keyboard_arrow_right, 
                                  color: Color(0xFF353B50)
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xFFF2F2F2),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: [
                                    Icon(Icons.payment, color: Color(0xFF3C2235)),
                                    SizedBox(width: 10),
                                    Text('Payment method',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                              Container(
                                width: 16,
                                child: Icon(
                                  Icons.keyboard_arrow_right, 
                                  color: Color(0xFF353B50)
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xFFF2F2F2),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ),onPressed: () {

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: [
                                    // Icon(Icons.print, color: Color(0xFF3C2235)),
                                    Image.asset('icons/Payout Method.png'),
                                    SizedBox(width: 10),
                                    Text('Payout method',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                              Container(
                                width: 16,
                                child: Icon(
                                  Icons.keyboard_arrow_right, 
                                  color: Color(0xFF353B50)
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.maxFinite,
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xFFF2F2F2),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                            ), onPressed: () {

                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(
                                child: Row(
                                  children: [
                                    Icon(Icons.info, color: Color(0xFF3C2235)),
                                    SizedBox(width: 10),
                                    Text('FAQs',
                                      style: TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 16,
                                        color: Color(0xFF371D32),
                                      ),
                                    ),
                                  ]
                                ),
                              ),
                              Container(
                                width: 16,
                                child: Icon(
                                  Icons.keyboard_arrow_right, 
                                  color: Color(0xFF353B50)
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ]
        ),
      ),
    ),

    bottomNavigationBar: NavigationBarTheme(

      data: NavigationBarThemeData(
          labelTextStyle: MaterialStateProperty.all(
            TextStyle(fontFamily: 'Urbanist'),
          )
      ),
      child: NavigationBar( indicatorColor: Color(0xffFFd2bd),
          // selectedIndex: _selectedIndex,
          // onTap: onTabTapped,
        destinations: [
            NavigationDestination(
              // icon: Icon(Icons.directions_car, size: 24, color: Color.fromRGBO(55, 29, 50, 0.5)),
                 icon: Icon(Icons.directions_car,color: Colors.grey,),
              selectedIcon:
              Icon(Icons.directions_car,color:Colors.black,),
              label: 'Discover',
                // style: TextStyle(
                //   fontFamily: 'Urbanist',
                //   fontSize: 10,
                //   color: Color(0xFF371D32),
                // ),

            ),
            NavigationDestination(
              // icon: Icon(Icons.list, size: 24, color: Color.fromRGBO(55, 29, 50, 0.5)),
              icon: Image.asset('icons/List a Car.png'),
              label: 'List a Car',
              //   style: TextStyle(
              //     fontFamily: 'Urbanist',
              //     fontSize: 10,
              //     color: Color(0xFF371D32),
              //   ),
              // ),
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle, size: 24, color: Color(0xFFEA9A62)),
              // icon: Icon(Icons.account_circle_rounded,color:Colors.grey,),
              label: 'Profile',
              //   style: TextStyle(
              //     fontFamily: 'Urbanist',
              //     fontSize: 10,
              //     color: Color(0xFFEA9A62),
              //   ),
              // )
            ),
          ],
        ),
    ),
  );
}

int _selectedIndex = 0;

void onTabTapped(int index) {
  // setState(() {
  //   _selectedIndex = index;
  // });
}