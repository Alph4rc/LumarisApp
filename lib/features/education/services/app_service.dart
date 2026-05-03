import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/services/base_http_client.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

import 'app_api.dart';

class AppService {
  static Future<ReleaseModel> getReleases() async {
    final prefs = PrefsService.instance;

    try {
      final releases = await AppApi.getAppInfo();

      if (releases.isNotEmpty) {
        final reInfo = releases.first;
        final re = ReleaseModel(
          name: reInfo.name ?? '0.0.0',
          body: reInfo.body ?? '',
        );

        if (re.body.contains('[强制更新]')) {
          return re;
        }

        final bool? updateIgnored = prefs.getBool(PrefsKeys.UPDATE_IGNORED);

        if (updateIgnored != null && updateIgnored == true) {
          return ReleaseModel(name: '0.0.0', body: '0.0.0');
        }

        return re;
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching releases: $e');
      }
    }

    return ReleaseModel(name: '0.0.0', body: '0.0.0');
  }

  static Future<(bool, ReleaseModel)> isNeedUpdate() async {
    final result = await getReleases();
    final packageInfo = await PackageInfo.fromPlatform();
    if (result.name == '0.0.0') {
      return (false, result);
    }

    final resultList = result.name.split('.').map((e) => int.parse(e)).toList();
    final currentList =
        packageInfo.version.split('.').map((e) => int.parse(e)).toList();

    final len = resultList.length > currentList.length
        ? currentList.length
        : resultList.length;

    for (int i = 0; i < len; i++) {
      if (resultList[i] > currentList[i]) {
        return (true, result);
      } else if (resultList[i] < currentList[i]) {
        return (false, result);
      }
    }

    return (resultList.length > currentList.length, result);
  }

  static Future<void> updateApp(String name) async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (name != packageInfo.version) {
      final url =
          'https://gitee.com/luckyfishisdashen/iOSClub.AppMobile/releases/download/$name/app-release.apk';

      if (await canLaunchUrl(Uri.parse(url))) {
        final downloadClient = BaseHttpClient(
          enableCache: false,
          connectTimeout: const Duration(minutes: 5),
          receiveTimeout: const Duration(minutes: 5),
          defaultHeaders: {
            'Content-Type': 'application/vnd.android.package-archive',
          },
        );

        try {
          final bytes = await downloadClient.downloadBytes(url);

          if (bytes.isNotEmpty) {
            // 获取应用缓存目录
            final directory = await getTemporaryDirectory();
            final filePath = '${directory.path}/app-release.apk';

            // 保存文件到本地
            final file = File(filePath);
            if (file.existsSync()) {
              await file.delete();
            } else {
              await file.create();
            }
            await file.writeAsBytes(bytes);

            try {
              await OpenFile.open(filePath);
            } catch (e) {
              if (kDebugMode) {
                AppLogger.debug('无法打开APK: $e');
              }
            }

            if (kDebugMode) {
              AppLogger.debug('APK下载成功: $filePath');
            }
          } else {
            throw '下载失败，文件为空';
          }
        } finally {
          downloadClient.dispose();
        }
      } else {
        throw '无法下载';
      }
    }
  }
}

class ReleaseModel {
  final String name;
  final String body;

  ReleaseModel({
    required this.name,
    required this.body,
  });

  factory ReleaseModel.fromJson(Map<String, dynamic> json) {
    return ReleaseModel(
      name: json['name'],
      body: json['body'],
    );
  }
}
