// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';

// class BottomNavigationBar extends StatelessWidget {
//   @override
//   Widget build (BuildContext context) => new Scaffold(
//     bottomNavigationBar: Theme.of(context).platform == TargetPlatform.iOS ?
//       new CupertinoTabBar(
//         activeColor: Colors.blueGrey,
//         selectedIndex: _selectedIndex,
//         onTap: onTabTapped,
//         items: [
//           NavigationDestination(icon: Icon(Icons.event), title: Text("Page 1")),
//           NavigationDestination(icon: Icon(Icons.group), title: Text("Page 2")),
//           NavigationDestination(icon: Icon(Icons.camera_alt), title: Text("Page 3")),
//         ],
//       ):
//       new NavigationBar(
//         selectedIndex: _selectedIndex,
//         onTap: onTabTapped,
//         items: [
//           NavigationDestination(icon: Icon(Icons.event), title: Text("Page 1")),
//           NavigationDestination(icon: Icon(Icons.group), title: Text("Page 2")),
//           NavigationDestination(icon: Icon(Icons.camera_alt), title: Text("Page 3")),
//         ],
//     ),
//   );
// }


// int _selectedIndex = 0;

// void onTabTapped(int index) {
//     // setState(() {
//     //   _selectedIndex = index;
//     // });
//   }