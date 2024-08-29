import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/events/inboxEvent.dart';
import 'package:ridealike/pages/messages/events/messageEvent.dart';
import 'package:ridealike/pages/messages/events/threadevent.dart';
import 'package:ridealike/pages/messages/utils/eventbusutils.dart';
import 'package:ridealike/pages/messages/utils/socket/getsocket.dart';

import '../../../main.dart';

class SocketClient {
  static GetSocket? _socket;
  static final _storage = FlutterSecureStorage();

  static Future<void> init() async {
    try {
      disconnect();
      // Connect to server
      // _socket = GetSocket("http://api.messaging.ridealike.com/ws");
      _socket = GetSocket("$socketServerUrl", const Duration(seconds: 5));
      // To listen socket open
      _socket?.onOpen(() async {
        print('onOpen');
        restart();
      });

      // To listen messages
      _socket?.onMessage((message) {
        print('message received: $message');
        var data = jsonDecode(message.toString());
        print('-------');
        print(data["dataType"]);
        print('-------');
        if (data["dataType"] == "InboxData") {
          print("inbox fire");
          EventBusUtils.getInstance().fire(InboxEvent(data));
        }
        if (data["dataType"] == "ThreadData") {
          print("thread fire");
          EventBusUtils.getInstance().fire(ThreadEvent(data));
        }
        if (data["dataType"] == "MessageData") {
          print("message firing");
          EventBusUtils.getInstance().fire(MessageEvent(data));
          print("message fired");
        }
        if (data["dataType"] == "ThreadReadData") {

        }
      });

      // To listen onClose events
      _socket?.onClose((close) {
        print('close called');
        //restart();
      });

      // To listen errors
      _socket?.onError((e) {
        print('error called');
        //restart();
      });

      // And lastly and most importantly, to connect to your Socket.
      _socket?.connect();
    } catch (e) {
      print(e);
      //restart();
    }
  }

  static void restart() async {
    newMessage.value = false;
    var msgToSend = {
      "token": await _storage.read(key: 'jwt'),
      "userId": await _storage.read(key: 'user_id'),
    };
    var dataToSend = {"dataType": "InitData", "data": msgToSend};
    print(jsonEncode(dataToSend));
    send(dataToSend);
  }

  static void send(dynamic args) {
    if (_socket != null) {
      _socket!.send(jsonEncode(args));
    }
  }

  static void disconnect() async {
    try {
      if (_socket != null) {
        _socket!.close();
        _socket!.dispose();
      }
    } catch (e) {
      print(e);
    }
  }

  static void check() async {
    if (_socket == null || _socket?.connectionStatus?.index != 1) {
      //print("Init Called!");
      //print(await _storage.read(key: 'jwt'));
      //print(await _storage.read(key: 'user_id'));
      if ((await _storage.read(key: 'jwt') != null) &&
          (await _storage.read(key: 'user_id') != null)) {
        init();
      }
    } else {
      //print("Connected Status!");
    }
  }
}