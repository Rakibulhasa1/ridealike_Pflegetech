import 'package:flutter/material.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';


class ChancesToSwap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppEventsUtils.logEvent("page_viewed",
        params: {"page_name": "Chance To Swap"});
    final dynamic receivedData = ModalRoute.of(context)?.settings.arguments;

    print(receivedData);

    return Scaffold(
      body: Container(
        color: Colors.black38,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.only(top: 32.0),
                width: MediaQuery.of(context).size.width / 1.1,
                height: MediaQuery.of(context).size.height / 2,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      spreadRadius: 0.5,
                      blurRadius: 17,
                      offset: Offset(0.0, 17.0)
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (receivedData["myCarID"] != null)
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(
                              "$storageServerUrl/"+receivedData["myCarID"].toString()),
                          radius: 30,
                        )
                            : CircleAvatar(
                          backgroundImage: AssetImage('images/car-image.jpg'),
                          radius: 30,
                          backgroundColor: Color(0xFFF2F2F2),
                        ),
                        SizedBox(width: 10.0),
                        Image(
                          fit: BoxFit.cover,
                          image: AssetImage('icons/Swap.png'),
                        ),
                        SizedBox(width: 10.0),
                        (receivedData["otherCarID"] != null)
                            ? CircleAvatar(
                          backgroundImage: NetworkImage(
                              "$storageServerUrl/"+receivedData["otherCarID"].toString()),
                          radius: 30,
                        )
                            : CircleAvatar(
                          backgroundImage: AssetImage('images/car-image.jpg'),
                          radius: 30,
                          backgroundColor: Color(0xFFF2F2F2),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: Text("It's a chance to swap!",
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 24,
                            color: Color(0xFF371D32)
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Center(
                      child: Text("Start a discussion to negotiate your terms.",
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 14,
                          color: Color(0xFF353B50)
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(top: 40.0, right: 10, left: 10, bottom: 10),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0.0,
                          backgroundColor: Color(0xffFF8F68),
                          padding: EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),

                        ),
                        onPressed: () {
                          AppEventsUtils.logEvent("swap_start_message");
                          Thread threadData = new Thread(
                            id: "1123571113", 
                            userId: receivedData['UserID'], 
                            image: receivedData['ImageID'] != "" ? receivedData['ImageID'] : "", 
                            name: receivedData['FirstName'] + ' ' + receivedData['LastName'], 
                            message: '', 
                            time: '', 
                            messages: []
                          );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              settings: RouteSettings(name: "/messages"),
                              builder: (context) => MessageListView(
                                thread: threadData,
                              ),
                            ),
                          ).then((value) => Navigator.pop(context));
                        },
                        child: Text('Arrange swap now',
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

            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Opacity(
                opacity: 1,
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Text("Skip for now",
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 14,
                        color: Colors.white
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
