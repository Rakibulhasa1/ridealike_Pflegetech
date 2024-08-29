import 'swap.dart';

class Message {
  String type;
  String senderId;
  String message;
  String receiverId;
  String time;
  String threadId;
  Swap? swap;
  bool? load;

  Message({
    required this.type,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.time,
    required this.threadId,
  });

  Message.swap({
    required this.type,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.time,
    required this.threadId,
    required this.swap,
  });


}
