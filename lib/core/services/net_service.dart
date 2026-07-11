import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ios_club_app/core/services/base_http_client.dart';
import 'package:ios_club_app/core/services/retry_policy.dart';
import 'package:ios_club_app/core/utils/request_cache.dart';

/// 校园网用量数据服务。
///
/// 端点和缓存策略属于该数据服务；底层 HTTP 能力复用 [BaseHttpClient]，
/// 因而不会再维护另一套 Dio、重试和错误处理逻辑。
class NetworkInfoService {
  NetworkInfoService({
    BaseHttpClient? httpClient,
    String endpoint = defaultEndpoint,
  })  : _httpClient = httpClient ??
            BaseHttpClient(
              retryPolicy: RetryPolicy.fast,
              enableCache: false,
              connectTimeout: const Duration(seconds: 3),
              receiveTimeout: const Duration(seconds: 3),
            ),
        _endpoint = endpoint;

  static const String defaultEndpoint =
      'http://10.99.144.34/cgi-bin/rad_user_info?callback=json';

  final BaseHttpClient _httpClient;
  final String _endpoint;
  final RequestCache _cache = RequestCache.instance;

  Future<Map<String, dynamic>> get({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cachedData = await _cache.get<Map<String, dynamic>>(_endpoint);
      if (cachedData != null) {
        return cachedData;
      }
    }

    final response = await _httpClient.get(_endpoint);
    final text = response.toString();
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start < 0 || end < start) {
      throw const FormatException('校园网接口返回了无效的 JSONP 数据');
    }

    final result = jsonDecode(text.substring(start, end + 1));
    if (result is! Map) {
      throw const FormatException('校园网接口返回的数据不是对象');
    }

    final data = Map<String, dynamic>.from(result);
    await _cache.set(_endpoint, data);
    return data;
  }

  void dispose() => _httpClient.dispose();
}

/// 兼容旧调用和既有测试的过渡入口。
/// 新业务应注入并使用 [NetworkInfoService] 实例。
@Deprecated('Use an injected NetworkInfoService instead.')
class NetService {
  static NetworkInfoService _service = NetworkInfoService();

  static Future<Map<String, dynamic>> get({bool forceRefresh = false}) =>
      _service.get(forceRefresh: forceRefresh);

  static void setDioForTest(Dio dio) {
    _service.dispose();
    _service = NetworkInfoService(
      httpClient: BaseHttpClient(
        dio: dio,
        retryPolicy: RetryPolicy.fast,
        enableCache: false,
        connectTimeout: const Duration(seconds: 3),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );
  }

  static void resetForTest() {
    _service.dispose();
    _service = NetworkInfoService();
  }
}
