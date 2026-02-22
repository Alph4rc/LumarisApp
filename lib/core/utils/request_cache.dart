import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ios_club_app/core/services/hive_manager.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';

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

/// 缓存条目模型
class CacheEntry {
  final dynamic data;
  final int expiryTime; // millisecondsSinceEpoch

  CacheEntry({required this.data, required this.expiryTime});

  Map<String, dynamic> toJson() => {
    'data': data,
    'expiryTime': expiryTime,
  };

  factory CacheEntry.fromJson(Map<String, dynamic> json) => CacheEntry(
    data: json['data'],
    expiryTime: json['expiryTime'] as int,
  );
  
  bool get isExpired => DateTime.now().millisecondsSinceEpoch > expiryTime;
}

/// 请求缓存工具类
class RequestCache {
  /// 单例实例
  static final RequestCache instance = RequestCache._internal();

  /// 工厂构造函数
  factory RequestCache() => instance;

  /// 内部构造函数
  RequestCache._internal();

  /// Hive Box
  Box? _box;
  
  /// 标记是否已初始化
  bool _isInitialized = false;

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
    if (_isInitialized) return;
    
    try {
      _box = await HiveManager.instance.openBox(HiveManager.requestCacheBoxName);
      _isInitialized = true;
      
      // 尝试迁移旧数据
      await _migrateFromSharedPreferences();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize RequestCache box', error: e, stackTrace: stackTrace);
    }
  }
  
  /// 从 SharedPreferences 迁移数据到 Hive
  Future<void> _migrateFromSharedPreferences() async {
    try {
      final prefs = PrefsService.instance;
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((k) => k.startsWith('request_cache_') && !k.endsWith('_expiry')).toList();
      
      if (cacheKeys.isEmpty) return;
      
      AppLogger.info('Migrating ${cacheKeys.length} cache entries from SharedPreferences to Hive...');
      
      int migratedCount = 0;
      for (final key in cacheKeys) {
        final expiryKey = '${key}_expiry';
        final dataStr = prefs.getString(key);
        final expiryStr = prefs.getString(expiryKey);
        
        if (dataStr != null && expiryStr != null) {
          try {
            // 解析原始键以获取 URL (假设键格式: request_cache_URL_PARAMS)
            // 这里为了简单，直接使用原 key 作为 Hive 的 key
            // 但需要注意原 key 包含了 'request_cache_' 前缀，我们可以保留或去除
            // 为了兼容现有的 _generateCacheKey 逻辑，我们保持一致的 key 生成方式
            // 因此，如果 _generateCacheKey 生成的 key 与 prefs 中的 key 一致，我们可以直接迁移
            
            final data = jsonDecode(dataStr);
            final expiryTime = DateTime.parse(expiryStr).millisecondsSinceEpoch;
            
            // 存入 Hive
            final entry = CacheEntry(data: data, expiryTime: expiryTime);
            await _box?.put(key, entry.toJson());
            
            migratedCount++;
          } catch (e) {
            AppLogger.warning('Failed to migrate cache entry: $key', error: e);
          }
        }
        
        // 无论迁移成功与否，都删除旧数据
        await prefs.remove(key);
        await prefs.remove(expiryKey);
      }
      
      AppLogger.info('Migrated $migratedCount cache entries to Hive.');
    } catch (e, stackTrace) {
      AppLogger.error('Error during cache migration', error: e, stackTrace: stackTrace);
    }
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
    // 保持与旧版一致的 Key 生成逻辑，以便兼容
    return 'request_cache_${Uri.encodeComponent(url)}_${Uri.encodeComponent(paramsString)}';
  }

  /// 获取缓存数据
  Future<T?> get<T>(String url, {Map<String, dynamic>? params, Duration? maxAge}) async {
    if (!_isInitialized) await initialize();

    final cacheKey = _generateCacheKey(url, params: params);
    final dynamic rawData = _box?.get(cacheKey);

    if (rawData == null) return null;
    
    try {
      // Hive 中存储的是 Map (json)
      final entry = CacheEntry.fromJson(Map<String, dynamic>.from(rawData));
      
      if (entry.isExpired) {
        await _box?.delete(cacheKey);
        return null;
      }
      
      final data = entry.data;
      
      if (data is T) {
        return data;
      }
      
      // 尝试类型转换
      if (T == Map && data is List) {
        return {'data': data} as T;
      }
      
      return data as T?;
    } catch (e) {
      AppLogger.debug('解析Hive缓存数据失败: $e');
      // 数据损坏，删除
      await _box?.delete(cacheKey);
      return null;
    }
  }

  /// 设置缓存数据
  Future<void> set<T>(String url, T data, {Map<String, dynamic>? params, Duration? maxAge}) async {
    if (!_isInitialized) await initialize();

    final cacheKey = _generateCacheKey(url, params: params);
    
    // 使用指定的maxAge或根据URL获取默认策略
    final effectiveMaxAge = maxAge ?? _getCachePolicyForUrl(url).maxAge;
    
    // 计算过期时间
    final expiryTime = DateTime.now().add(effectiveMaxAge).millisecondsSinceEpoch;

    // 存储
    final entry = CacheEntry(data: data, expiryTime: expiryTime);
    await _box?.put(cacheKey, entry.toJson());
  }

  /// 删除缓存数据
  Future<void> delete(String url, {Map<String, dynamic>? params}) async {
    if (!_isInitialized) await initialize();
    final cacheKey = _generateCacheKey(url, params: params);
    await _box?.delete(cacheKey);
  }
  
  /// 删除匹配URL模式的所有缓存
  Future<void> deleteByPattern(RegExp pattern) async {
    if (!_isInitialized) await initialize();
    
    final keys = _box?.keys.cast<String>() ?? [];
    for (final key in keys) {
      if (key.startsWith('request_cache_')) {
        // 提取原始URL
        final cacheKey = key.replaceFirst('request_cache_', '');
        final parts = cacheKey.split('_');
        if (parts.isNotEmpty) {
          try {
            final url = Uri.decodeComponent(parts[0]);
            if (pattern.hasMatch(url)) {
              await _box?.delete(key);
            }
          } catch (e) {
            AppLogger.debug('解析缓存键失败: $e');
          }
        }
      }
    }
  }

  /// 清除所有缓存
  Future<void> clear() async {
    if (!_isInitialized) await initialize();
    await _box?.clear();
  }

  /// 获取缓存大小 (字节数 - 估算)
  Future<int> getCacheSize() async {
    if (!_isInitialized) await initialize();
    
    // Hive 不直接提供字节大小，这里只能返回条目数或者做一个粗略估算
    // 为了兼容旧接口，我们尽量返回一个有意义的数字
    // 这里简单返回条目数 * 平均大小(假设1KB)
    return (_box?.length ?? 0) * 1024; 
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
          
          if (!_cache._isInitialized) await _cache.initialize();
          final rawData = _cache._box?.get(cacheKey);

          if (rawData != null) {
            try {
              final entry = CacheEntry.fromJson(Map<String, dynamic>.from(rawData));
              // 不检查过期时间，直接使用
              final response = Response(
                data: entry.data,
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
