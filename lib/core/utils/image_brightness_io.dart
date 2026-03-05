import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// 从本地文件路径加载图片字节
Future<Uint8List?> loadLocalImageBytes(String path) async {
  try {
    final file = File(path);
    if (!file.existsSync()) return null;
    return await file.readAsBytes();
  } catch (e) {
    debugPrint('loadLocalImageBytes error: $e');
    return null;
  }
}

/// 从网络 URL 下载图片字节
Future<Uint8List?> loadNetworkImageBytes(String url) async {
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return response.bodyBytes;
    return null;
  } catch (e) {
    debugPrint('loadNetworkImageBytes error: $e');
    return null;
  }
}
