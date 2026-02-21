import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as parser;
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ios_club_app/state/prefs_keys.dart';

import 'package:ios_club_app/core/models/electric_data.dart';
import 'package:ios_club_app/core/models/tile_configuration.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// Custom exception for tile configuration errors
class TileConfigurationException implements Exception {
  final String message;
  final String? details;

  TileConfigurationException(this.message, {this.details});

  @override
  String toString() =>
      'TileConfigurationException: $message${details != null ? ' ($details)' : ''}';
}

class TileService {
  static final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  static Future<double?> getTextAfterKeyword({String? url}) async {
    try {
      final prefs = PrefsService.instance;

      if (url == null || url.isEmpty) {
        url = prefs.getString(PrefsKeys.ELECTRICITY_URL) ?? '';

        if (url.isEmpty) {
          return null;
        }
      }

      final response = await _dio.get(url);
      if (response.statusCode != 200) {
        throw Exception('HTTP请求失败: ${response.statusCode}');
      }

      // 解析HTML内容
      final document = parser.parse(response.data);

      // 获取所有文本节点
      final textNodes = document.body?.text
              .split('\n')
              .map((t) => t.trim())
              .where((t) => t.isNotEmpty) ??
          [];

      // 遍历所有文本节点查找关键字
      for (var text in textNodes) {
        if (text.contains('充值余额：¥')) {
          // 提取关键字后面的内容
          final textAfterKeyword = text.split('充值余额：¥')[1].trim();
          // 尝试将提取的内容转换为double
          final result = double.tryParse(textAfterKeyword);
          if (result != null) {
            await prefs.setString(PrefsKeys.ELECTRICITY_URL, url);
            return result;
          }
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('请求失败: $e');
      }
      return null;
    }
  }

  static Future<void> setTiles(List<String> map) async {
    final prefs = PrefsService.instance;
    await prefs.setStringList(PrefsKeys.TILES, map);
  }

  static Future<List<String>> getTiles() async {
    final prefs = PrefsService.instance;
    return prefs.getStringList(PrefsKeys.TILES) ?? [];
  }

  static Future<void> openInWeChat(String url) async {
    // 尝试打开微信
    // 转成微信的 URL
    final encodedUrl = Uri.encodeComponent(url);
    final wechatUrl = 'weixin://dl/business/?url=$encodedUrl';
    if (await canLaunchUrl(Uri.parse(wechatUrl))) {
      await launchUrl(Uri.parse(wechatUrl),
          mode: LaunchMode.externalApplication);
    } else {
      // 如果无法打开微信，则直接在浏览器中打开
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw '无法打开 URL: $url';
      }
    }
  }

  static Future<List<ElectricData>> getElectricityWeeklyData() async {
    final prefs = PrefsService.instance;

    var url = prefs.getString(PrefsKeys.ELECTRICITY_URL) ?? '';

    if (url.isEmpty) {
      return [];
    }

    url = url.replaceAll('wxAccount', 'wxElecDtl');

    final response = await _dio.get(url);
    var document = parser.parse(response.data);
    var tables = document.querySelectorAll('table');
    final List<ElectricData> data = [];
    for (var table in tables) {
      var rows = table.querySelectorAll('tr');
      for (var row in rows) {
        var cells = row.querySelectorAll('td');
        if (cells.length == 3) {
          final split = cells[1].text.split(' ');
          final dayTime = split[0].split('/');
          final time = split[1].split(':');
          final date = DateTime(int.parse(dayTime[0]), int.parse(dayTime[1]),
              int.parse(dayTime[2]), int.parse(time[0]));
          if (data.isEmpty || data.last.timestamp.hour != date.hour) {
            data.add(ElectricData(
              timestamp: date,
              value: double.tryParse(cells[2].text)!,
            ));
          } else {
            data.last.value += double.tryParse(cells[2].text)!;
          }
        }
      }
    }

    data.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return data;
  }

  // ========== New Tile Configuration Methods ==========

  /// Get the complete tile configuration from local storage
  static Future<TileConfigurationList> getTileConfigurations() async {
    final prefs = PrefsService.instance;

    try {
      // Try new format first
      final newFormatJson = prefs.getString(PrefsKeys.TILE_CONFIGURATIONS);
      if (newFormatJson != null && newFormatJson.isNotEmpty) {
        final json = jsonDecode(newFormatJson) as Map<String, dynamic>;
        return TileConfigurationList.fromJson(json);
      }

      // Fall back to old format and migrate (only if not empty)
      final oldFormatList = prefs.getStringList(PrefsKeys.TILES);
      if (oldFormatList != null && oldFormatList.isNotEmpty) {
        final config = _migrateFromOldFormat(oldFormatList);
        await saveTileConfigurations(config);
        return config;
      }

      // No data, return default
      return TileConfigurationList.defaultConfig();
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to load tile configuration: $e');
      }
      return TileConfigurationList.defaultConfig();
    }
  }

  /// Save the complete tile configuration to local storage
  static Future<void> saveTileConfigurations(
      TileConfigurationList config) async {
    final prefs = PrefsService.instance;

    try {
      // Update lastModified timestamp
      final updatedConfig = config.copyWith(lastModified: DateTime.now());

      // Serialize to JSON
      final json = jsonEncode(updatedConfig.toJson());

      // Save to storage
      await prefs.setString(PrefsKeys.TILE_CONFIGURATIONS, json);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to save tile configuration: $e');
      }
      throw TileConfigurationException(
        '保存失败，请重试',
        details: e.toString(),
      );
    }
  }

  /// Move a tile to a new position in the display order
  static Future<void> reorderTile(
      String tileId, int oldIndex, int newIndex) async {
    try {
      final config = await getTileConfigurations();
      final reordered = config.reorderTile(tileId, oldIndex, newIndex);
      await saveTileConfigurations(reordered);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to reorder tile: $e');
      }
      throw TileConfigurationException(
        '重新排序失败',
        details: e.toString(),
      );
    }
  }

  /// Show or hide a tile
  static Future<void> toggleTileVisibility(String tileId) async {
    try {
      final config = await getTileConfigurations();
      final toggled = config.toggleVisibility(tileId);
      await saveTileConfigurations(toggled);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to toggle tile visibility: $e');
      }
      throw TileConfigurationException(
        '切换显示状态失败',
        details: e.toString(),
      );
    }
  }

  /// Reset tile configuration to default state
  static Future<void> resetToDefault() async {
    try {
      final defaultConfig = TileConfigurationList.defaultConfig();
      await saveTileConfigurations(defaultConfig);
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Failed to reset tile configuration: $e');
      }
      throw TileConfigurationException(
        '重置失败',
        details: e.toString(),
      );
    }
  }

  /// Get list of all available tile types
  static List<String> getAvailableTiles() {
    return ['电费', '校车', '饭卡'];
  }

  /// Migrate from old format (List&lt;String>) to new format (TileConfigurationList)
  static TileConfigurationList _migrateFromOldFormat(List<String> oldList) {
    final configurations = oldList.asMap().entries.map((entry) {
      return TileConfiguration(
        id: entry.value,
        order: entry.key,
        isVisible: true,
      );
    }).toList();

    return TileConfigurationList(
      configurations: configurations,
      lastModified: DateTime.now(),
    );
  }
}
