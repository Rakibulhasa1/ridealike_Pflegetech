import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:ridealike/main.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/events/inboxEvent.dart';
import 'package:ridealike/pages/messages/events/messageEvent.dart';
import 'package:ridealike/pages/messages/models/message.dart';
import 'package:ridealike/pages/messages/models/swap.dart';
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/pages/messagelist/messagelistView.dart';
import 'package:ridealike/pages/messages/utils/eventbusutils.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/pages/messages/utils/socket_client.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

class ThreadListController extends ControllerMVC {
  StreamController<List<Thread>> threadStreamController =
      StreamController<List<Thread>>();
  List<Thread> _threadList = [];
  List<String> _userIdList = [];
  StreamSubscription? inboxSubscription;
  StreamSubscription? messageSubscription;
  var visiblePercentage;
  String userId = "";
  final storage = new FlutterSecureStorage();
  bool dataLoaded = false;
  bool socketOn = false;

  int getThreadSize() {
    return _threadList.length;
  }

  List<Thread> getThread() {
    return _threadList;
  }

  /*void startSocket() {
    if (!socketOn) {
      SocketClient.init().then((value) {
        print("connected");
        socketOn = true;
        getThreadList();
      });
    }else{
      getThreadList();
    }
  }*/

  void getThreadList() async {
    try {
      var msgToSend = {
        "token": await storage.read(key: 'jwt'),
        "userId": await storage.read(key: 'user_id'),
      };
      var dataToSend = {"dataType": "InitData", "data": msgToSend};
      print(jsonEncode(dataToSend));
      SocketClient.send(dataToSend);
    } catch (e) {
      print(e);
    }
  }

  void sendThreadRead(Thread thread, BuildContext context) async {
    try {
      var msgToSend = {
        "threadId": thread.id,
        "senderId": userId,
      };
      var dataToSend = {"dataType": "ThreadReadData", "data": msgToSend};
      print(jsonEncode(dataToSend));
      SocketClient.send(dataToSend);
      goToMessageList(thread, context);
    } catch (e) {
      print(e);
    }
  }

  void addThread(Thread newThread) {
    bool _isNew = true;
    int? _index;
    for (var i = 0; i < _threadList.length; i++) {
      if (_threadList[i].id == newThread.id) {
        _isNew = false;
        _index = i;
      }
    }

    if (_isNew) {
      _threadList.add(newThread);
    } else {
      _threadList.removeAt(_index!);
      _threadList.insert(_index, newThread);
    }
    threadStreamController.add(_threadList);
  }

  void goToMessageList(Thread thread, BuildContext context) {
    newMessage.value = false;
    Navigator.push(
      context,
      MaterialPageRoute(
          settings: RouteSettings(name: "/messages"),
          builder: (context) => MessageListView(
                thread: thread,
                initSocket: true,
              )),
    ).then((value) => getThreadList());
  }

  @override
  void initState() {
    super.initState();
    //AppEventsUtils.logEvent("messaging_thread_view");
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Messaging Thread View"});
    setUserID();
    setUpEventBus();
    Future.delayed(Duration(seconds: 10), () {
      if (_threadList.isEmpty && !threadStreamController.isClosed) {
        threadStreamController.add([]);
      }
    });
  }

  setUserID() async {
    userId = (await storage.read(key: 'user_id'))!;
  }

  void setUpEventBus() {
    inboxSubscription =
        EventBusUtils.getInstance().on<InboxEvent>().listen((event) {
      print("InboxListener:::");
      if (visiblePercentage == 100.0) {
        try {
          _threadList.clear();
          _userIdList.clear();
          var data = event.data;
          var threadData = data["data"];
          if (threadData["threads"] != null) {
            List threadList = threadData["threads"];
            for (var threadItem in threadList) {
              List<Message> messages = [];
              if (threadItem["messages"] != null) {
                List messageList = threadItem["messages"];
                print("**********************");
                print(threadItem["user1_read"]);
                print(threadItem["user2_read"]);
                print("**********************");
                for (var message in messageList) {
                  //print(message);
                  if (message["messageType"] == "Text") {
                    messages.add(
                      Message(
                        threadId: message["threadId"],
                        senderId: message["senderId"],
                        receiverId: message["receiverId"],
                        message: message["messageBody"],
                        type: message["messageType"],
                        time: message["createdAt"],
                      ),
                    );
                  } else if (message["messageType"] == "Image") {
                    messages.add(
                      Message(
                        threadId: message["threadId"],
                        senderId: message["senderId"],
                        receiverId: message["receiverId"],
                        message: "Image",
                        type: "Image",
                        time: message["createdAt"],
                      ),
                    );
                  } else if (message["messageType"] == "SwapAgreementCard") {
                    messages.add(
                      Message.swap(
                        threadId: message["threadId"],
                        senderId: message["senderId"],
                        receiverId: message["receiverId"],
                        message: "SwapAgreementCard",
                        type: "SwapAgreementCard",
                        time: message["createdAt"],
                        swap: Swap(
                          userId: message["senderId"],
                          agreementId: message["messageBody"],
                        ),
                      ),
                    );
                  } else {}
                }
              }

              Thread thread = Thread(
                  id: threadItem["threadId"].toString(),
                  userId: threadItem["userId1"] == userId
                      ? threadItem["userId2"]
                      : threadItem["userId1"],
                  name: "",
                  message: messages.length > 0 ? messages[0].message : "",
                  time: threadItem["updatedAt"],
                  image: "",
                  seen: threadItem["userId1"] == userId
                      ? threadItem["user1_read"]
                      : threadItem["user2_read"],
                  messages: messages);

              /*if(!thread.seen){
                newMessage.value = true;
              }else{
                newMessage.value = false;
              }*/

              _userIdList.add(thread.userId);

              _threadList.add(thread);
            }

            _threadList.sort((a, b) =>
                DateTime.parse(a.time).compareTo(DateTime.parse(b.time)));

            threadStreamController.add(_threadList.reversed.toList());
            //

            getProfileData();
          } else {
            threadStreamController.add([]);
          }
        } catch (e) {
          print(e);
        }
      }
    });
    messageSubscription =
        EventBusUtils.getInstance().on<MessageEvent>().listen((event) {
      print("MessageListener:::");
      if (visiblePercentage == 100.0) {
        getThreadList();
      }
    });
  }

  void getProfileData() async {
    try {
      var data = {"UserIDs": _userIdList};
      //print(data);
      final response = await HttpClient.post(getProfilesByUserIDsUrl, data,
          token: await storage.read(key: 'jwt') as String);

      //print(response.toString());
      var status = response["Status"];
      if (status["success"]) {
        var profiles = response["Profiles"];
        for (var profile in profiles) {
          String userId = profile["UserID"];
          String name =
              profile["FirstName"] + " " + '${profile["LastName"][0]}.';
          String imageId = profile["ImageID"];
          String verificationStatus = profile["VerificationStatus"];
          for (int i = 0; i < _threadList.length; i++) {
            if (_threadList[i].userId == userId) {
              _threadList[i].name = name;
              _threadList[i].image = imageId.trim().length > 0
                  ? "$storageServerUrl/" + imageId
                  : "";
              _threadList[i].verificationStatus = verificationStatus;
              //print(_threadList[i].image);
            }
          }
        }
        threadStreamController.add(_threadList.reversed.toList());
        setState(() {
          dataLoaded = true;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    threadStreamController.close();
    inboxSubscription!.cancel();
    messageSubscription!.cancel();
    super.dispose();
  }
}
