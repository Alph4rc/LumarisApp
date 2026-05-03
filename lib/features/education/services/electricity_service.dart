import 'package:url_launcher/url_launcher.dart';

import '../models/electric_data.dart';
import '../../../core/services/prefs_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../state/prefs_keys.dart';
import 'electricity_api.dart';

typedef ElectricityBalanceReader = Future<double?> Function({String? url});
typedef ElectricityWeeklyDataReader =
    Future<List<ElectricData>> Function({String? url});
typedef ElectricityRechargeUrlReader = Future<String?> Function({String? url});

/// 电费数据服务
///
/// 负责封装电费 API 调用，并统一处理本地 URL 缓存与充值页跳转逻辑。
class ElectricityService {
  ElectricityService({
    ElectricityBalanceReader? balanceReader,
    ElectricityWeeklyDataReader? weeklyDataReader,
    ElectricityRechargeUrlReader? rechargeUrlReader,
  })  : _balanceReader = balanceReader ?? ElectricityApi.getCurrentBalance,
        _weeklyDataReader = weeklyDataReader ?? ElectricityApi.getWeeklyData,
        _rechargeUrlReader = rechargeUrlReader ?? ElectricityApi.getRechargeUrl;

  final ElectricityBalanceReader _balanceReader;
  final ElectricityWeeklyDataReader _weeklyDataReader;
  final ElectricityRechargeUrlReader _rechargeUrlReader;

  Future<double?> fetchCurrentBalance({String? url}) async {
    try {
      if (url != null) {
        await PrefsService.instance.setString(
          PrefsKeys.ELECTRICITY_URL,
          url,
        );
      }
      final resolvedUrl = await _resolveSourceUrl();
      if (resolvedUrl.isEmpty) {
        return null;
      }

      return await _balanceReader(url: resolvedUrl);
    } catch (e) {
      AppLogger.error('获取电费余额失败: $e');
      return null;
    }
  }

  Future<List<ElectricData>> fetchWeeklyData() async {
    final resolvedUrl = await _resolveSourceUrl();
    return await _weeklyDataReader(
      url: resolvedUrl.isEmpty ? null : resolvedUrl,
    );
  }

  Future<String?> getRechargeUrl() async {
    final resolvedUrl = await _resolveSourceUrl();
    return await _rechargeUrlReader(
      url: resolvedUrl.isEmpty ? null : resolvedUrl,
    );
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

  Future<String> _resolveSourceUrl({String? url}) async {
    if (url != null) {
      await PrefsService.instance.setString(
        PrefsKeys.ELECTRICITY_URL,
        url,
      );

      return url;
    }
    return PrefsService.instance.getString(PrefsKeys.ELECTRICITY_URL) ?? '';
  }
}
