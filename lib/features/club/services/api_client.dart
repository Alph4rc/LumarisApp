import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import '../../../core/utils/request_cache.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class ApiClient {
  static const String _baseUrl = 'https://api.xauat.site';
  static final RequestCache _cache = RequestCache();
  
  static Future<Map<String, String>> getHeaders({bool withAuth = false}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final jwt = prefs.getString(PrefsKeys.MEMBER_JWT);
      if (jwt != null) {
        headers['Authorization'] = 'Bearer $jwt';
      }
    }
    
    return headers;
  }
  
  static Future<http.Response> get(String path, {bool withAuth = true, bool useCache = true}) async {
    final uri = Uri.parse('$_baseUrl$path');
    
    // 如果使用缓存，先尝试从缓存获取
    if (useCache) {
      final cachedData = await _cache.get(uri.toString());
      if (cachedData != null) {
        if (kDebugMode) {
          AppLogger.debug('GET $uri (from cache)');
        }
        // 返回缓存数据作为http.Response
        return http.Response(
          jsonEncode(cachedData),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
    }
    
    // 缓存不存在或不使用缓存，发起网络请求
    final headers = await getHeaders(withAuth: withAuth);
    if (kDebugMode) {
      AppLogger.debug('GET $uri');
    }
    final response = await http.get(uri, headers: headers);
    
    // 如果请求成功且使用缓存，将数据存入缓存
    if (useCache && response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        await _cache.set(uri.toString(), data);
      } catch (e) {
        if (kDebugMode) {
          AppLogger.error('Failed to cache response: $e');
        }
      }
    }
    
    return response;
  }
  
  static Future<http.Response> post(String path, {dynamic body, bool withAuth = true}) async {
    final headers = await getHeaders(withAuth: withAuth);
    final uri = Uri.parse('$_baseUrl$path');
    final encodedBody = body != null ? jsonEncode(body) : null;
    if (kDebugMode) {
      AppLogger.debug('POST $uri');
      if (encodedBody != null) {
        AppLogger.debug('Body: $encodedBody');
      }
    }
    return http.post(uri, headers: headers, body: encodedBody);
  }
  
  static Future<http.Response> put(String path, {dynamic body, bool withAuth = true}) async {
    final headers = await getHeaders(withAuth: withAuth);
    final uri = Uri.parse('$_baseUrl$path');
    final encodedBody = body != null ? jsonEncode(body) : null;
    if (kDebugMode) {
      AppLogger.debug('PUT $uri');
      if (encodedBody != null) {
        AppLogger.debug('Body: $encodedBody');
      }
    }
    return http.put(uri, headers: headers, body: encodedBody);
  }
  
  static Future<http.Response> delete(String path, {bool withAuth = true}) async {
    final headers = await getHeaders(withAuth: withAuth);
    final uri = Uri.parse('$_baseUrl$path');
    if (kDebugMode) {
      AppLogger.debug('DELETE $uri');
    }
    return http.delete(uri, headers: headers);
  }
}