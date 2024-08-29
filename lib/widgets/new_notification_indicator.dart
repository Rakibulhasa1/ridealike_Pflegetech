// import 'package:flutter/material.dart';
// class NotificationIndicator extends StatelessWidget {
//   final newNotification;
//   const NotificationIndicator({Key key,this.newNotification}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return  ValueListenableBuilder(
//       builder: (BuildContext context, int value, Widget child) {
//         return value !=0
//             ? Stack(
//           children: [
//             Icon(Icons.account_circle_rounded,color:Colors.grey,),
//             Positioned(
//               left: 10,
//               child: Container(
//                 height: 12.5,
//                 width: 12.5,
//                 decoration: BoxDecoration(
//                   color: Color(0xffFF8F68),
//                   border: Border.all(
//                     color: Color(0xffFF8F68),
//                   ),
//                   borderRadius: BorderRadius.all(
//                     Radius.circular(20),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         )
//             : Icon(Icons.account_circle_rounded,color:Colors.grey,);
//       },
//       valueListenable: newNotification,
//     ) ;
//   }
// }
//
