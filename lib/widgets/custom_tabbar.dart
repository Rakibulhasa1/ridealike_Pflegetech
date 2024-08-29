import 'package:flutter/material.dart';
class CustomTabBar extends StatefulWidget {
  const CustomTabBar({Key? key});

  @override
  _CustomTabBarState createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar> {

  int selectedTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TabBar(
          labelPadding: EdgeInsets.symmetric(vertical: 16.0,horizontal: 16),
          isScrollable: true,
          indicatorWeight: 4.0,
          unselectedLabelColor: Colors.grey,
          onTap: (index) {
            setState(() {
              selectedTabIndex = index;
            });
          },
          // indicator: BoxDecoration(
          //   // Customize the indicator's appearance
          //   color: Color(0xffFF8F68),// Set the indicator's background color
          //   borderRadius: BorderRadius.circular(8), // Set the indicator's border radius
          // ),
          // indicatorSize: TabBarIndicatorSize.label,
          tabs: [
            Tab(
              child: Column(
                children: [
                  Image.asset(
                    'images/nearby.png',
                    width: 30,
                    height: 30,
                  ),

                  Text("Cars nearby",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Urbanist'

                  ),
                  ),
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Image.asset(
                    'images/car.png',
                    width: 30,
                    height: 30,
                  ),
                  Text("Top cars this month",style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Urbanist'

                  ),),

                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Image.asset(
                    'images/tap.png',
                    width: 30,
                    height: 30,
                  ),
                  Text("Recently Viewed",style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Urbanist'

                  ),),
                ],
              ),
            ),
            Tab(
              child: Column(
                children: [
                  Image.asset(
                    'images/history.png',
                    width: 30,
                    height: 30,
                  ),
                  Text("Previously booked",style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Urbanist'

                  ),),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
