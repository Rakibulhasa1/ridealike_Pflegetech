import 'package:ridealike/pages/messages/utils/http_client.dart';
import 'package:ridealike/pages/messages/utils/urls.dart';

class AddressUtils {
  static Future<String> getAddress(double lat, double lon) async {
    String address = "";

    try {
      String url = URLs.geoCodeUrl(lat, lon);
      final response = await HttpClient.get(url);
      var result = response["results"][0];
      print(result["formatted_address"]);
      address = result["formatted_address"].toString();
    } catch (e) {
      print(e);
    }

    return address;
  }
}
