import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/electric_data.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../state/prefs_keys.dart';

/// 电费数据服务
///
/// 负责读取本地保存的电费页面链接、抓取余额与明细，
/// 并统一处理充值页跳转逻辑，便于后续切换到后端接口实现。
class ElectricityService {
  ElectricityService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
              ),
            );

  final Dio _dio;

  Future<double?> fetchCurrentBalance({String? url}) async {
    try {
      final resolvedUrl = _resolveSourceUrl(url);
      if (resolvedUrl.isEmpty) {
        return null;
      }

      final response = await _dio.get(resolvedUrl);
      if (response.statusCode != 200) {
        throw Exception('HTTP请求失败: ${response.statusCode}');
      }

      final document = parser.parse(response.data);
      final textNodes = document.body?.text
              .split('\n')
              .map((text) => text.trim())
              .where((text) => text.isNotEmpty) ??
          const Iterable<String>.empty();

      for (final text in textNodes) {
        if (!text.contains('充值余额：¥')) {
          continue;
        }

        final balanceText = text.split('充值余额：¥')[1].trim();
        final balance = double.tryParse(balanceText);
        if (balance != null) {
          await PrefsService.instance.setString(
            PrefsKeys.ELECTRICITY_URL,
            resolvedUrl,
          );
          return balance;
        }
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('获取电费余额失败: $e');
      }
      return null;
    }
  }

  Future<List<ElectricData>> fetchWeeklyData() async {
    final sourceUrl =
        PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL);
    if (sourceUrl == null || sourceUrl.isEmpty) {
      return [];
    }

    final detailUrl = sourceUrl.replaceAll('wxAccount', 'wxElecDtl');
    final response = await _dio.get(detailUrl);
    final document = parser.parse(response.data);
    final tables = document.querySelectorAll('table');
    final List<ElectricData> data = [];

    for (final table in tables) {
      final rows = table.querySelectorAll('tr');
      for (final row in rows) {
        final cells = row.querySelectorAll('td');
        if (cells.length != 3) {
          continue;
        }

        final timestamp = _parseTimestamp(cells[1].text);
        final value = double.tryParse(cells[2].text);
        if (timestamp == null || value == null) {
          continue;
        }

        if (data.isEmpty || data.last.timestamp.hour != timestamp.hour) {
          data.add(ElectricData(timestamp: timestamp, value: value));
        } else {
          data.last.value += value;
        }
      }
    }

    data.sort((left, right) => left.timestamp.compareTo(right.timestamp));
    return data;
  }

  Future<String?> getRechargeUrl() async {
    final sourceUrl =
        PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL);
    if (sourceUrl == null || sourceUrl.isEmpty) {
      return null;
    }
    return sourceUrl.replaceAll('wxAccount', 'wxCharge');
  }

  Future<void> openRechargePage() async {
    final rechargeUrl = await getRechargeUrl();
    if (rechargeUrl == null || rechargeUrl.isEmpty) {
      throw '无法打开 URL: $rechargeUrl';
    }

    final encodedUrl = Uri.encodeComponent(rechargeUrl);
    final wechatUrl = 'weixin://dl/business/?url=$encodedUrl';
    if (await canLaunchUrl(Uri.parse(wechatUrl))) {
      await launchUrl(
        Uri.parse(wechatUrl),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    if (await canLaunchUrl(Uri.parse(rechargeUrl))) {
      await launchUrl(
        Uri.parse(rechargeUrl),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    throw '无法打开 URL: $rechargeUrl';
  }

  String _resolveSourceUrl(String? url) {
    if (url != null && url.isNotEmpty) {
      return url;
    }

    return PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL) ?? '';
  }

  DateTime? _parseTimestamp(String rawValue) {
    final parts = rawValue.trim().split(' ');
    if (parts.length != 2) {
      return null;
    }

    final dayParts = parts[0].split('/');
    final timeParts = parts[1].split(':');
    if (dayParts.length != 3 || timeParts.length < 2) {
      return null;
    }

    final year = int.tryParse(dayParts[0]);
    final month = int.tryParse(dayParts[1]);
    final day = int.tryParse(dayParts[2]);
    final hour = int.tryParse(timeParts[0]);
    if (year == null || month == null || day == null || hour == null) {
      return null;
    }

    return DateTime(year, month, day, hour);
  }
}
