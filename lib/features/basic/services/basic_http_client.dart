import 'package:dio/dio.dart';

class BasicHttpClient {
  final Dio _dio;

  BasicHttpClient({Dio? dio}) : _dio = dio ?? Dio() {
    _setupDio();
  }

  void _setupDio() {
    _dio.options = BaseOptions(
      baseUrl: "https://luminous.xauat.site",
      // 增加超时时间以适应重登录场景
      // 重登录可能需要3-5秒，加上原请求时间，总共需要更长的超时
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      contentType: 'application/json',
    );
  }

  Dio get dio => _dio;

  Future<dynamic> get(String url,
      {Map<String, dynamic>? queryParameters}) async {
    final requestTarget = _resolveRequestTarget(url, queryParameters);
    var response = await _dio.get(
      requestTarget.path,
      queryParameters: requestTarget.queryParameters,
    );
    return response.data;
  }

  Future<dynamic> post(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    final requestTarget = _resolveRequestTarget(url, queryParameters);
    var response = await _dio.post(
      requestTarget.path,
      data: data,
      queryParameters: requestTarget.queryParameters,
    );
    return response.data;
  }

  void dispose() {
    _dio.close();
  }

  _ResolvedRequestTarget _resolveRequestTarget(
    String path,
    Map<String, dynamic>? queryParameters,
  ) {
    final uri = Uri.parse(path);
    final mergedQueryParameters = <String, dynamic>{
      ..._extractQueryParameters(uri),
      ...?queryParameters,
    };

    return _ResolvedRequestTarget(
      path: uri.hasQuery ? uri.replace(query: null).toString() : path,
      queryParameters:
          mergedQueryParameters.isEmpty ? null : mergedQueryParameters,
    );
  }

  Map<String, dynamic> _extractQueryParameters(Uri uri) {
    if (!uri.hasQuery) {
      return <String, dynamic>{};
    }

    return <String, dynamic>{
      for (final entry in uri.queryParametersAll.entries)
        entry.key: entry.value.length == 1 ? entry.value.single : entry.value,
    };
  }
}

class _ResolvedRequestTarget {
  const _ResolvedRequestTarget({
    required this.path,
    required this.queryParameters,
  });

  final String path;
  final Map<String, dynamic>? queryParameters;
}
