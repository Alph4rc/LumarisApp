import 'dart:convert';
import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 缓存策略配置
class CachePolicy {
  final Duration maxAge;
  final bool allowStale;
  
  const CachePolicy({
    this.maxAge = const Duration(minutes: 5),
    this.allowStale = false,
  });
  
  // 常用缓存策略
  static const CachePolicy defaultPolicy = CachePolicy();
  static const CachePolicy shortTerm = CachePolicy(maxAge: Duration(minutes: 1));
  static const CachePolicy mediumTerm = CachePolicy(maxAge: Duration(minutes: 15));
  static const CachePolicy longTerm = CachePolicy(maxAge: Duration(hours: 1));
  static const CachePolicy veryLongTerm = CachePolicy(maxAge: Duration(days: 1));
}

/// 请求缓存工具类
class RequestCache {
  /// 单例实例
  static final RequestCache instance = RequestCache._internal();

  /// 工厂构造函数
  factory RequestCache() => instance;

  /// 内部构造函数
  RequestCache._internal();

  /// SharedPreferences 实例
  SharedPreferences? _prefs;
  
  /// URL模式到缓存策略的映射
  final Map<RegExp, CachePolicy> _urlCachePolicies = {
    // 默认策略
    RegExp(r'.*'): CachePolicy.defaultPolicy,
    // 课程相关API - 中短期缓存
    RegExp(r'.*/course.*'): CachePolicy.mediumTerm,
    // 成绩相关API - 长期缓存
    RegExp(r'.*/score.*'): CachePolicy.longTerm,
    // 校巴相关API - 短期缓存
    RegExp(r'.*/bus.*'): CachePolicy.shortTerm,
    // 考试相关API - 长期缓存
    RegExp(r'.*/exam.*'): CachePolicy.longTerm,
    // 培养方案相关API - 超长期缓存
    RegExp(r'.*/program.*'): CachePolicy.veryLongTerm,
    // App信息相关API - 中短期缓存
    RegExp(r'.*/app.*'): CachePolicy.mediumTerm,
  };

  /// 初始化缓存
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// 根据URL获取缓存策略
  CachePolicy _getCachePolicyForUrl(String url) {
    for (final entry in _urlCachePolicies.entries) {
      if (entry.key.hasMatch(url)) {
        return entry.value;
      }
    }
    return CachePolicy.defaultPolicy;
  }

  /// 生成缓存键
  String _generateCacheKey(String url, {Map<String, dynamic>? params}) {
    final paramsString = params != null ? jsonEncode(params) : '';
    return 'request_cache_${Uri.encodeComponent(url)}_${Uri.encodeComponent(paramsString)}';
  }

  /// 生成缓存过期时间键
  String _generateExpiryKey(String cacheKey) {
    return '${cacheKey}_expiry';
  }

  /// 获取缓存数据
  Future<T?> get<T>(String url, {Map<String, dynamic>? params, Duration? maxAge}) async {
    if (_prefs == null) {
      await initialize();
    }

    final cacheKey = _generateCacheKey(url, params: params);
    final expiryKey = _generateExpiryKey(cacheKey);

    // 检查缓存是否存在
    final cachedData = _prefs?.getString(cacheKey);
    final expiryTimeStr = _prefs?.getString(expiryKey);

    if (cachedData == null || expiryTimeStr == null) {
      return null;
    }

    // 检查缓存是否过期
    final expiryTime = DateTime.parse(expiryTimeStr);
    final now = DateTime.now();
    
    // 使用指定的maxAge或根据URL获取默认策略
    final effectiveMaxAge = maxAge ?? _getCachePolicyForUrl(url).maxAge;
    
    if (now.isAfter(expiryTime)) {
      // 缓存过期，删除缓存
      await _prefs?.remove(cacheKey);
      await _prefs?.remove(expiryKey);
      return null;
    }

    // 解析缓存数据
    try {
      final data = jsonDecode(cachedData);
      if (data is T) {
        return data;
      }
      // 尝试类型转换
      if (T == Map && data is List) {
        // 特殊处理：如果期望Map但得到List，返回包含list的map
        return {'data': data} as T;
      }
      return null;
    } catch (e) {
      debugPrint('解析缓存数据失败: $e');
      return null;
    }
  }

  /// 设置缓存数据
  Future<void> set<T>(String url, T data, {Map<String, dynamic>? params, Duration? maxAge}) async {
    if (_prefs == null) {
      await initialize();
    }

    final cacheKey = _generateCacheKey(url, params: params);
    final expiryKey = _generateExpiryKey(cacheKey);

    // 使用指定的maxAge或根据URL获取默认策略
    final effectiveMaxAge = maxAge ?? _getCachePolicyForUrl(url).maxAge;
    
    // 计算过期时间
    final expiryTime = DateTime.now().add(effectiveMaxAge);

    // 存储缓存数据和过期时间
    await _prefs?.setString(cacheKey, jsonEncode(data));
    await _prefs?.setString(expiryKey, expiryTime.toIso8601String());
  }

  /// 删除缓存数据
  Future<void> delete(String url, {Map<String, dynamic>? params}) async {
    if (_prefs == null) {
      await initialize();
    }

    final cacheKey = _generateCacheKey(url, params: params);
    final expiryKey = _generateExpiryKey(cacheKey);

    await _prefs?.remove(cacheKey);
    await _prefs?.remove(expiryKey);
  }
  
  /// 删除匹配URL模式的所有缓存
  Future<void> deleteByPattern(RegExp pattern) async {
    if (_prefs == null) {
      await initialize();
    }
    
    final keys = _prefs?.getKeys() ?? <String>[];
    for (final key in keys) {
      if (key.startsWith('request_cache_') && !key.endsWith('_expiry')) {
        // 提取原始URL
        final cacheKey = key.replaceFirst('request_cache_', '');
        final parts = cacheKey.split('_');
        if (parts.isNotEmpty) {
          try {
            final url = Uri.decodeComponent(parts[0]);
            if (pattern.hasMatch(url)) {
              await _prefs?.remove(key);
              await _prefs?.remove('${key}_expiry');
            }
          } catch (e) {
            debugPrint('解析缓存键失败: $e');
          }
        }
      }
    }
  }

  /// 清除所有缓存
  Future<void> clear() async {
    if (_prefs == null) {
      await initialize();
    }

    final keys = _prefs?.getKeys() ?? <String>[];
    for (final key in keys) {
      if (key.startsWith('request_cache_')) {
        await _prefs?.remove(key);
      }
    }
  }

  /// 获取缓存大小
  Future<int> getCacheSize() async {
    if (_prefs == null) {
      await initialize();
    }

    int size = 0;
    final keys = _prefs?.getKeys() ?? <String>[];
    for (final key in keys) {
      if (key.startsWith('request_cache_') && !key.endsWith('_expiry')) {
        final value = _prefs?.getString(key);
        if (value != null) {
          size += value.length;
        }
      }
    }
    return size;
  }
  
  /// 添加自定义URL缓存策略
  void addUrlCachePolicy(RegExp urlPattern, CachePolicy policy) {
    _urlCachePolicies[urlPattern] = policy;
  }
}

/// 缓存拦截器
class CacheInterceptor extends Interceptor {
  final RequestCache _cache = RequestCache();
  
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // 只有GET请求才使用缓存
    if (options.method == 'GET') {
      final cachedData = await _cache.get(options.uri.toString(), params: options.queryParameters);
      if (cachedData != null) {
        // 使用缓存数据
        final response = Response(
          data: cachedData,
          requestOptions: options,
          statusCode: 200,
          statusMessage: 'OK (from cache)',
        );
        return handler.resolve(response);
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    // 只有GET请求才缓存
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      await _cache.set(
        response.requestOptions.uri.toString(),
        response.data,
        params: response.requestOptions.queryParameters,
      );
    }
    handler.next(response);
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 如果网络错误且允许使用过期缓存，可以考虑返回过期缓存
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      // 只有GET请求才尝试使用过期缓存
      if (err.requestOptions.method == 'GET') {
        final policy = _cache._getCachePolicyForUrl(err.requestOptions.uri.toString());
        if (policy.allowStale) {
          // 尝试获取过期缓存
          final cacheKey = _cache._generateCacheKey(
            err.requestOptions.uri.toString(),
            params: err.requestOptions.queryParameters,
          );
          final expiryKey = _cache._generateExpiryKey(cacheKey);
          
          // 直接获取缓存，不检查过期时间
          final cachedData = _cache._prefs?.getString(cacheKey);
          if (cachedData != null) {
            try {
              final data = jsonDecode(cachedData);
              final response = Response(
                data: data,
                requestOptions: err.requestOptions,
                statusCode: 200,
                statusMessage: 'OK (from stale cache)',
              );
              return handler.resolve(response);
            } catch (e) {
              // 解析失败，继续处理错误
            }
          }
        }
      }
    }
    handler.next(err);
  }
}