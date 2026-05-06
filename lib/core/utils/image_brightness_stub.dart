import 'dart:typed_data';

/// 不支持本地文件的平台（WeChat 小程序等）返回 null
Future<Uint8List?> loadLocalImageBytes(String path) async => null;

/// 网络图片加载（stub 实现）
Future<Uint8List?> loadNetworkImageBytes(String url) async => null;
