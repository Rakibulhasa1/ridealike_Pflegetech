import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class NotificationsDetails extends StatelessWidget{


   @override
   Widget build(BuildContext context){
     final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;
     return  Scaffold(
         backgroundColor: Color(0xffFFFFFF),
         appBar: new AppBar(
           leading: new IconButton(
             icon: new Icon(Icons.arrow_back, color: Color(0xffFF8F68)),
             onPressed: () => Navigator.of(context).pop(),
           ),title: Text('Notifications details', style: TextStyle(
           fontFamily: 'Urbanist',
           fontSize: 16,
           color: Color(0xff371D32),
         ),),centerTitle: true,
           elevation: 0.0,
         ),
         body: receivedData != null ?
         SingleChildScrollView(
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(mainAxisAlignment: MainAxisAlignment.start,
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 AutoSizeText(receivedData['title'],
                   style: TextStyle(
                       fontFamily: 'Urbanist',
                       color: Color(0xff371D32),
                       fontSize: 16
                   ),
                 ),
                 SizedBox(height: 20,),
                 SizedBox(
                   child: AutoSizeText(receivedData['body'],
                     style: TextStyle(
                         fontFamily: 'Urbanist',
                         color: Color(0xff371D32),
                         fontSize: 16
                     ),
                   ),
                 ),
               ],
             ),
           ),
         )  :
         Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: <Widget>[
               new CircularProgressIndicator(strokeWidth: 2.5)
             ],
           ),
         ));
   }
 }
