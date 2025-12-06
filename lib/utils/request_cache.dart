import 'dart:convert';
import 'dart:core';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// 初始化缓存
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
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
  Future<T?> get<T>(String url, {Map<String, dynamic>? params, Duration maxAge = const Duration(minutes: 5)}) async {
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
    if (DateTime.now().isAfter(expiryTime)) {
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
      return null;
    } catch (e) {
      debugPrint('解析缓存数据失败: $e');
      return null;
    }
  }

  /// 设置缓存数据
  Future<void> set<T>(String url, T data, {Map<String, dynamic>? params, Duration maxAge = const Duration(minutes: 5)}) async {
    if (_prefs == null) {
      await initialize();
    }

    final cacheKey = _generateCacheKey(url, params: params);
    final expiryKey = _generateExpiryKey(cacheKey);

    // 计算过期时间
    final expiryTime = DateTime.now().add(maxAge);

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
      if (key.startsWith('request_cache_')) {
        final value = _prefs?.getString(key);
        if (value != null) {
          size += value.length;
        }
      }
    }
    return size;
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
}