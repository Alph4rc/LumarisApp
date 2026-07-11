import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

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
    return compute(_computeIsDarkFromBytes, bytes);
  } catch (e) {
    debugPrint('computeImageIsDark error: $e');
    return null;
  }
}

bool? _computeIsDarkFromBytes(Uint8List bytes) {
  final decodedImage = img.decodeImage(bytes);
  if (decodedImage == null) return null;

  final image = img.copyResize(decodedImage, width: 50, height: 50);
  double totalLuminance = 0;
  int sampleCount = 0;

  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      // 基于人眼感知权重的相对亮度公式
      totalLuminance += 0.299 * r + 0.587 * g + 0.114 * b;
      sampleCount++;
    }
  }

  if (sampleCount == 0) return null;
  // 亮度 < 128 认为是暗色
  return (totalLuminance / sampleCount) < 128;
}
