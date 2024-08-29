library getsocket;

import 'src/io.dart';

class GetSocket extends BaseWebSocket {
  GetSocket(String url, Duration ping) : super(url, ping);
}