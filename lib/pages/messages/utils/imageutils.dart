import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:multi_image_picker_plus/multi_image_picker_plus.dart' as picker;
import 'package:ridealike/pages/common/constant_url.dart';
import 'package:ridealike/pages/messages/utils/http_client.dart';

class ImageUtils {
var name='images/user.png';
  static Future<List<picker.Asset>> loadAssets() async {
    List<picker.Asset> resultList = [];
    try {
      resultList = await picker.MultiImagePicker.pickImages(
          androidOptions: picker.AndroidOptions(maxImages: 1),
      );
      return resultList;
    } on Exception catch (e) {
      print(e.toString());
      return resultList;
    }
  }

  static Future<dynamic> sendImageData(List<int> data, String name) async {
    try {
      final storage = FlutterSecureStorage();
      var formData = FormData.fromMap(
          {'files': MultipartFile.fromBytes(data, filename: name)});
      final response = await HttpClient.post(uploadUrl, formData,
          token: await storage.read(key: 'jwt')as String) ;
      print(response);
      return response;
    } catch (e) {
      print(e);

      return e;
    }
  }
}
