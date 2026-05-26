import 'package:dio/dio.dart';

class BasicHttpClient {
    final Dio _dio;

    BasicHttpClient({Dio? dio}) : _dio = dio ?? Dio(){
      _setupDio();
    }

    void _setupDio(){
      _dio.options = BaseOptions(
      baseUrl: "https://luminous.xauat.site",
      // 增加超时时间以适应重登录场景
      // 重登录可能需要3-5秒，加上原请求时间，总共需要更长的超时
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    );
    }

    Future<dynamic> get(String url, {Map<String, dynamic>? queryParameters}) async {
        var response = await _dio.get(url, queryParameters: queryParameters);
        return response.data;
    }

    Future<dynamic> post(String url, {dynamic data}) async {
        var response = await _dio.post(url, data: data);
        return response.data;
    }


  void dispose() {
    _dio.close();
  }
}