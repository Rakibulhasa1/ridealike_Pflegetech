import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class NetworkHelper{
  static Future<BaseOptions> _options(String token) async {
    return BaseOptions(
      connectTimeout: Duration(milliseconds: 5000),
      receiveTimeout: Duration(milliseconds: 5000),
      headers: {
        'Authorization': 'Bearer ' + token,
      },
    );
  }

  static Future<Dio> _dioClient(String token) async {
    print(token);
    Dio dio = Dio(await _options(token));
    dio.interceptors.add(
        RetryInterceptor(
          dio: dio,
          logPrint: print, // specify log function (optional)
          retries: 3, // retry count (optional)
          retryDelays: const [ // set delays between retries (optional)
            Duration(seconds: 1), // wait 1 sec before first retry
            Duration(seconds: 2), // wait 2 sec before second retry
            Duration(seconds: 3), // wait 3 sec before third retry
          ],
        )
    );
    dio.interceptors.add(PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));


    /*(dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    };*/
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Don't trust any certificate just because their root cert is trusted.
        final HttpClient client =
        HttpClient(context: SecurityContext(withTrustedRoots: false));
        // You can test the intermediate / root cert here. We just ignore it.
        client.badCertificateCallback =
        ((X509Certificate cert, String host, int port) => true);
        return client;
      },
    );
    return dio;
  }

  static Future<dynamic> get(
      String url, {
        String token = '',
      }) async {
    try {
      Dio dio = await _dioClient(token);
      Response response = await dio.get(url);
      return jsonDecode(response.toString());
    } catch (e) {
      throw e;
    }
  }

  static Future<dynamic> post(String url, dynamic body,
      {String token = ''}) async {
    try {
      Dio dio = await _dioClient(token);
      Response response = await dio.post(url, data: body);
      return jsonDecode(response.toString());
    } catch (e) {
      throw e;
    }
  }

  static Future<dynamic> delete(String url, {String token = ''}) async {
    try {
      Dio dio = await _dioClient(token);
      Response response = await dio.post(url);
      return jsonDecode(response.toString());
    } catch (e) {
      throw e;
    }
  }

  static Future<dynamic> upload(String url, dynamic body,
      {String token = '', bool jwtCheck = true}) async {
    // TODO Implement post with file upload
    /*try {
      Dio dio = await _dioClient(token);
      Response response = await dio.post(url, data: body);
      return jsonDecode(response.toString());
    } catch (e) {
      print(e);
      return e;
    }*/
  }

}