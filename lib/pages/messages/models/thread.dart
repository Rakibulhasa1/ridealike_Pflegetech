import 'package:ridealike/pages/messages/models/message.dart';

class Thread {
  String id;
  String userId;
  String image;
  String name;
  String message;
  String time;
  bool seen;
  List<Message> messages;
  String? verificationStatus;

  Thread({
    required this.id,
    required this.userId,
    required this.image,
    required this.name,
    required this.message,
    required this.time,
    this.seen = false,
    required this.messages,
    this.verificationStatus
  });
}
