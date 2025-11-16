import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ios_club_app/stores/prefs_keys.dart';

class ApiClient {
  static const String _baseUrl = 'https://api.xauat.site';
  
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
  
  static Future<http.Response> get(String path, {bool withAuth = true}) async {
    final headers = await getHeaders(withAuth: withAuth);
    final uri = Uri.parse('$_baseUrl$path');
    if (kDebugMode) {
      print('GET $uri');
    }
    return http.get(uri, headers: headers);
  }
  
  static Future<http.Response> post(String path, {dynamic body, bool withAuth = true}) async {
    final headers = await getHeaders(withAuth: withAuth);
    final uri = Uri.parse('$_baseUrl$path');
    final encodedBody = body != null ? jsonEncode(body) : null;
    if (kDebugMode) {
      print('POST $uri');
      if (encodedBody != null) {
        print('Body: $encodedBody');
      }
    }
    return http.post(uri, headers: headers, body: encodedBody);
  }
  
  static Future<http.Response> put(String path, {dynamic body, bool withAuth = true}) async {
    final headers = await getHeaders(withAuth: withAuth);
    final uri = Uri.parse('$_baseUrl$path');
    final encodedBody = body != null ? jsonEncode(body) : null;
    if (kDebugMode) {
      print('PUT $uri');
      if (encodedBody != null) {
        print('Body: $encodedBody');
      }
    }
    return http.put(uri, headers: headers, body: encodedBody);
  }
  
  static Future<http.Response> delete(String path, {bool withAuth = true}) async {
    final headers = await getHeaders(withAuth: withAuth);
    final uri = Uri.parse('$_baseUrl$path');
    if (kDebugMode) {
      print('DELETE $uri');
    }
    return http.delete(uri, headers: headers);
  }
}