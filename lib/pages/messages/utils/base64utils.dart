import 'dart:convert';
import 'dart:typed_data';

class Base64Utils {
  static final instance = Base64Utils();

  String base64Encode(List<int> bytes) => base64.encode(bytes);

  Uint8List base64Decode(String source) => base64.decode(source);
}
