import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path/path.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/events/inboxEvent.dart';
import 'package:ridealike/pages/messages/events/loadEvent.dart';
import 'package:ridealike/pages/messages/events/messageEvent.dart';
import 'package:ridealike/pages/messages/events/threadevent.dart';
import 'package:ridealike/pages/messages/models/message.dart';
import 'package:ridealike/pages/messages/models/swap.dart';
import 'package:ridealike/pages/messages/models/thread.dart';
import 'package:ridealike/pages/messages/utils/eventbusutils.dart';
import 'package:ridealike/pages/messages/utils/imageutils.dart';
import 'package:ridealike/pages/messages/utils/socket_client.dart';
import 'package:ridealike/pages/messages/widgets/imagedetails.dart';
import 'package:ridealike/utils/app_events/app_events_utils.dart';

class MessageListController extends ControllerMVC {
  Thread? thread;
  StreamController<List<Message>> messageStreamController =
      StreamController<List<Message>>();
  TextEditingController messageEditController = TextEditingController();
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  List<Message> _messageList = [];
  ScrollController scrollController = ScrollController();
  BuildContext? context;
  bool showLoadMore = false;
  final ImagePicker picker = ImagePicker();
  StreamSubscription? inboxSubscription;
  StreamSubscription? threadSubscription;
  StreamSubscription? messageSubscription;
  StreamSubscription? loadSubscription;

  String userId = "";
  final storage = new FlutterSecureStorage();
  var visiblePercentage;
  bool loaded = false;
  bool socketOn = false;
  String _messageImageId = '';
  final ValueNotifier<bool> imageUploading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> enableButton = ValueNotifier<bool>(false);

  void settingModalBottomSheet(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            child: new Wrap(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Stack(
                          children: <Widget>[
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Color(0xFFF68E65),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Attach photo',
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 16,
                                  color: Color(0xFF371D32),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                new ListTile(
                  leading: Image.asset('icons/Take-Photo_Sheet.png'),
                  title: Text(
                    'Take photo',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xFF371D32),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickeImageThroughCamera(context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
                new ListTile(
                  leading: Image.asset('icons/Attach-Photo_Sheet.png'),
                  title: Text(
                    'Attach photo',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 16,
                      color: Color(0xFF371D32),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    pickeImageFromGallery(context);
                  },
                ),
                Divider(color: Color(0xFFABABAB)),
              ],
            ),
          );
        });
  }

  pickeImageThroughCamera(context) async {
    var status = true;
    // if (Platform.isIOS) {
    //   status = await Permission.camera.request().isGranted;
    // }
    final picker = ImagePicker();
    if (status) {
      final pickedFile = await picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 50,
          maxHeight: 500,
          maxWidth: 500,
          preferredCameraDevice: CameraDevice.front);

      var imageRes = await uploadImage(File(pickedFile! .path));

      if (json.decode(imageRes.body!)['Status'] == 'success') {
        _messageImageId = json.decode(imageRes.body!)['FileID'];
        sendImage(_messageImageId);
      }
    } else {
      Platform.isIOS
          ? showDialog(
              context: context,
              builder: (context) {
                return CupertinoAlertDialog(
                  title: Text('Permission Required'),
                  content: Text(
                      'RideAlike needs permission to access your photo library to select a photo.'),
                  actions: [
                    CupertinoDialogAction(
                      child: Text('Not now'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    CupertinoDialogAction(
                      child: Text('Open settings'),
                      onPressed: () async {
                        await storage.write(key: 'route', value: '/messages');
                        openAppSettings().whenComplete(() {
                          return Navigator.pop(context);
                        });
                        openAppSettings().whenComplete(() {
                          return Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                );
              },
            )
          : Container();
    }
  }
  Future<bool> checkForStoragePermission(BuildContext context) async {
    // 1. Request storage permission if necessary
    var storageStatus = await Permission.mediaLibrary.status;
    if (!storageStatus.isGranted) {
      if (await Permission.mediaLibrary.request().isGranted) {
        // Either the permission was already granted before or the user just granted it.
        return true;
      }
      if (storageStatus.isDenied) {
        // Permission denied, show informative dialog and guide to app settings
        showDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Permission Required'),
              content: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'RideAlike needs permission to access your photo library to select a photo.'),
              ),
              actions: [
                CupertinoDialogAction(
                  child: Text('Not now'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                CupertinoDialogAction(
                  child: Text('Open settings'),
                  onPressed: () async {
                    await storage.write(
                        key: 'route', value: '/profile_edit_tab');
                    openAppSettings().whenComplete(() {
                      //return Navigator.pop(context);
                    });
                  },
                ),
              ],
            );
          },
        );
        return false;
      } else if (storageStatus.isPermanentlyDenied) {
        // Permanently denied, guide user to app settings
        await openAppSettings();
        return false;
      }
      throw Exception('Storage permission required to create folder.');
    } else {
      return true;
    }
  }

  pickeImageFromGallery(context) async {
    var status = true;
    print("status" +status.toString());
    if (status) {
      //List<Asset> resultList = await ImageUtils.loadAssets();
      //var data = await resultList[0].getThumbByteData(500, 500, quality: 80);
      List<XFile> resultList = await picker.pickMultiImage();
      var data = await resultList[0].readAsBytes();
      var imageRes = await ImageUtils.sendImageData(
          data.buffer.asUint8List(), resultList[0].name ?? '');

      print(imageRes);
      if (imageRes['Status'] == 'success') {
        _messageImageId = imageRes['FileID'];
        sendImage(_messageImageId);
      }
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Permission Required'),
            content: Text(
                'RideAlike needs permission to access your photo library to select a photo.'),
            actions: [
              CupertinoDialogAction(
                child: Text('Not now'),
                onPressed: () => Navigator.of(context).pop(),
              ),
              CupertinoDialogAction(
                child: Text('Open settings'),
                onPressed: () async {
                  await storage.write(key: 'route', value: '/messages');
                  openAppSettings().whenComplete(() {
                    return Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        },
      );
    }
  }

  uploadImage(filename) async {
    imageUploading.value = true;

    var stream =
        new http.ByteStream(DelegatingStream.typed(filename.openRead()));
    var length = await filename.length();

    var uri = Uri.parse(uploadUrl);
    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('files', stream, length,
        filename: basename(filename.path));

    String? jwt = await storage.read(key: 'jwt');
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    request.headers.addAll(headers);

    request.files.add(multipartFile);
    var response = await request.send();

    var response2 = await http.Response.fromStream(response);

    imageUploading.value = false;

    return response2;
  }

  /*void startSocket() {
    if (!socketOn) {
      SocketClient.init().then((value) {
        print("connected");
        socketOn = true;
        if (!loaded) {
          getThreadList();
        }
      });
    } else {
      if (!loaded) {
        getThreadList();
      }
    }
  }*/

  void addMessage(Message message) {
    try {
      print("add message");
      _messageList.add(message);
      messageStreamController.add(_messageList);
      goToBottom();
    } catch (e) {
      print(e);
    }
  }

  void addPreviousMessageList(List<Message> list) {
    print("*************************************");
    print(_messageList.length);
    print("*************************************");
    try {
      list.forEach((element) {
        _messageList.insert(0, element);
      });

      messageStreamController.add(_messageList);
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    messageStreamController.close();
    messageEditController.dispose();
    scrollController.dispose();
    inboxSubscription!.cancel();
    threadSubscription!.cancel();
    messageSubscription!.cancel();
    loadSubscription!.cancel();
    super.dispose();
  }

  void getMessageList() {
    print("yes yes");
    try {
      List<Message> filteredList = _filterList(thread!.messages);
      _messageList = filteredList.reversed.toList();
      _messageList[_messageList.length - 1].load = true;
      messageStreamController.add(_messageList);
      //goToBottom();
      print("*************************************");
      print(_messageList.length);
      print("*************************************");
    } catch (e) {
      print(e);
    }
  }

  /*List<Message> _filterList(List<Message> messages) {
    List<Message> messageList = List();
    for (Message m in messages) {
      if (m.type == "SwapAgreementCard") {
        var index = _containsList(messageList, m.swap.agreementId);
        if (index >= 0) {
          messageList.removeAt(index);
        }
      }
      messageList.add(m);
    }

    return messageList;
  }*/

  List<Message> _filterList(List<Message> messages) {
    List<Message> messageList = [];
    for (Message m in messages) {
      if (m.type == "SwapAgreementCard") {
        var index = _containsList(messageList, m.swap!.agreementId);
        if (index < 0) {
          messageList.add(m);
        }
      } else {
        messageList.add(m);
      }
    }
    return messageList;
  }

  dynamic _containsList(List<Message> messages, String id) {
    var pos = -1;
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].type == "SwapAgreementCard" &&
          messages[i].swap != null &&
          messages[i].swap!.agreementId == id) {
        pos = i;
      }
    }
    return pos;
  }

  void getPreviousMessageList() {
    var msgToSend = {
      "threadId": thread!.id,
      "limit": 10,
      "skip": _messageList.length,
    };

    var dataToSend = {"dataType": "ThreadData", "data": msgToSend};

    print(dataToSend);

    SocketClient.send(dataToSend);
    setState(() {
      showLoadMore = true;
    });
  }

  void getThreadList() async {
    try {
      var msgToSend = {
        "token": await storage.read(key: 'jwt'),
        "userId": await storage.read(key: 'user_id'),
      };
      var dataToSend = {"dataType": "InitData", "data": msgToSend};
      print(dataToSend);
      SocketClient.send(dataToSend);
    } catch (e) {
      print(e);
    }
  }

  void goToBottom() {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.animateTo(scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    });
  }

  @override
  void initState() {
    super.initState();
    //AppEventsUtils.logEvent("messaging_chat_view");
    AppEventsUtils.logEvent("page_viewed", params: {"page_name" : "Messaging Chat View"});
    setUserID();

    setUpEventBus();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      scrollController.addListener(() {
        if (scrollController.position.atEdge) {
          if (scrollController.position.pixels == 0) {
            print("you are at top position");
            getPreviousMessageList();
          } else {
            print("you are at bottom position");
          }
        }
      });
      if (thread!.messages.length > 0) {
        getMessageList();
      } else {
        Future.delayed(Duration(seconds: 2), () {
          messageStreamController.add([]);
          getThreadList();
        });
      }
      Future.delayed(Duration(seconds: 5), () {
        loaded = true;
      });
    });
  }

  setUserID() async {
    userId = (await storage.read(key: 'user_id'))!;
  }

  void sendMessage(String message) {
    AppEventsUtils.logEvent("send_message",params: {"message_type": "Text", "message": message, "message_length": message.length});
    var msgToSend = {
      "senderId": userId,
      "receiverId": thread!.userId,
      "messageType": "Text",
      "messageBody": message,
    };

    var dataToSend = {
      "dataType": "MessageData",
      "data": msgToSend,
    };

    print(dataToSend);
    SocketClient.send(dataToSend);

    sendThreadRead(thread!.id);
  }

  void sendImage(String image) {
    AppEventsUtils.logEvent("send_message",params: {"message_type": "Image"});
    var msgToSend = {
      "senderId": userId,
      "receiverId": thread!.userId,
      "messageType": "Image",
      "messageBody": image,
    };

    var dataToSend = {
      "dataType": "MessageData",
      "data": msgToSend,
    };

    print(dataToSend);
    SocketClient.send(dataToSend);

    sendThreadRead(thread!.id);
  }

  void sendThreadRead(String threadId) async {
    try {
      var msgToSend = {
        "threadId": threadId,
        "senderId": userId,
      };
      var dataToSend = {"dataType": "ThreadReadData", "data": msgToSend};
      print(jsonEncode(dataToSend));
      SocketClient.send(dataToSend);
    } catch (e) {
      print(e);
    }
  }

  void setUpEventBus() {
    loadSubscription =
        EventBusUtils.getInstance().on<LoadEvent>().listen((event) {
          goToBottom();
    });
    messageSubscription =
        EventBusUtils.getInstance().on<MessageEvent>().listen((event) {
      print("MessageListener:::");
      var data = event.data;
      var message = data["data"];
      addMessage(
        Message(
          threadId: message["threadId"],
          senderId: message["senderId"],
          receiverId: message["receiverId"],
          message: message["messageBody"],
          type: message["messageType"],
          time: message["createdAt"],
        ),
      );
      if(message["messageType"] == "Text"){
        AppEventsUtils.logEvent("receive_message",params: {"message_type": message["messageType"], "message": message["messageBody"], "message_length": message["messageBody"].length});
      } else {
        AppEventsUtils.logEvent("receive_message",params: {"message_type": message["messageType"]});
      }
    });
    threadSubscription =
        EventBusUtils.getInstance().on<ThreadEvent>().listen((event) {
      setState(() {
        showLoadMore = false;
      });
      print("ThreadListener:::");
      var data = event.data;
      print(data["data"]);
      if (data["data"] != null) {
        List messageList = data["data"];
        List<Message> previousMessages = [];
        for (var message in messageList) {
          previousMessages.add(Message(
            threadId: message["threadId"],
            senderId: message["senderId"],
            receiverId: message["receiverId"],
            message: message["messageBody"],
            type: message["messageType"],
            time: message["createdAt"],
          ));
        }
        addPreviousMessageList(previousMessages);
      }
    });
    inboxSubscription =
        EventBusUtils.getInstance().on<InboxEvent>().listen((event) {
      try {
        print("InboxListener:::");
        var data = event.data;
        var threadData = data["data"];
        List threadList = threadData["threads"];
        for (var threadItem in threadList) {
          List<Message> messages = [];

          if (threadItem["messages"] != null) {
            List messageList = threadItem["messages"];

            for (var message in messageList) {
              print(message["messageType"]);
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
                    message: message["messageBody"],
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
                    type: message["messageType"],
                    time: message["createdAt"],
                    swap: Swap(
                      userId: message["senderId"],
                      agreementId: message["messageBody"],
                    ),
                  ),
                );
              }
            }
          }

          Thread th = Thread(
              id: threadItem["threadId"].toString(),
              userId: threadItem["userId1"] == userId
                  ? threadItem["userId2"]
                  : threadItem["userId1"],
              name: "Name",
              message: messages.length > 0 ? messages[0].message : "",
              time: threadItem["updatedAt"],
              image: "https://picsum.photos/200/300",
              messages: messages);
          if (th.userId == thread!.userId) {
            List<Message> filteredList = _filterList(th.messages);
            _messageList = filteredList.reversed.toList();
            messageStreamController.add(_messageList);
          }
        }
      } catch (e) {
        print(e);
      }
    });
  }

  void viewImageDetails(BuildContext context, String image) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ImageDetails(image: image)),
    );
  }
}
