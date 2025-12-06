import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../utils/request_cache.dart';

class NetService {
  static final RequestCache _cache = RequestCache.instance;
  
  static Future<Map<String, dynamic>> get() async {
    const url = 'http://10.99.144.34/cgi-bin/rad_user_info?callback=json';
    const maxRetries = 3;
    const timeoutDuration = Duration(seconds: 3);
    
    // 尝试从缓存获取数据
    final cachedData = await _cache.get<Map<String, dynamic>>(url);
    if (cachedData != null) {
      return cachedData;
    }
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final response = await http
            .get(Uri.parse(url))
            .timeout(timeoutDuration);
            
        if (response.statusCode == 200) {
          var text = response.body;
          text = text.substring(text.indexOf('{'), text.lastIndexOf('}') + 1);
          final res = jsonDecode(text);
          
          // 将数据存入缓存
          await _cache.set(url, res);
          
          return res;
        } else {
          throw HttpException('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      } on SocketException catch (e) {
        if (attempt == maxRetries - 1) {
          throw Exception('网络连接失败: $e');
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      } on TimeoutException catch (e) {
        if (attempt == maxRetries - 1) {
          throw Exception('请求超时: $e');
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      } catch (e) {
        if (attempt == maxRetries - 1) {
          throw Exception('请求失败: $e');
        }
        await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
      }
    }
    
    throw Exception('获取数据失败');
  }
}