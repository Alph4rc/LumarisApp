import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';

import 'image_brightness_stub.dart'
    if (dart.library.io) 'image_brightness_io.dart';

/// 分析图片整体亮度，判断是否为暗色图片
///
/// 通过对图片像素进行采样，计算平均亮度值。
/// 返回 true 表示暗色图片，false 表示亮色图片，null 表示检测失败。
Future<bool?> computeImageIsDark(String imagePath) async {
  try {
    Uint8List? bytes;
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      bytes = await loadNetworkImageBytes(imagePath);
    } else {
      bytes = await loadLocalImageBytes(imagePath);
    }
    if (bytes == null) return null;
    return await _computeIsDarkFromBytes(bytes);
  } catch (e) {
    debugPrint('computeImageIsDark error: $e');
    return null;
  }
}

Future<bool?> _computeIsDarkFromBytes(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(
    bytes,
    targetWidth: 50,
    targetHeight: 50,
  );
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  image.dispose();

  if (byteData == null) return null;

  final pixels = byteData.buffer.asUint8List();
  double totalLuminance = 0;
  int sampleCount = 0;

  for (int i = 0; i < pixels.length; i += 4) {
    final r = pixels[i];
    final g = pixels[i + 1];
    final b = pixels[i + 2];
    // 基于人眼感知权重的相对亮度公式
    totalLuminance += 0.299 * r + 0.587 * g + 0.114 * b;
    sampleCount++;
  }

  if (sampleCount == 0) return null;
  // 亮度 < 128 认为是暗色
  return (totalLuminance / sampleCount) < 128;
}
