import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/features/education/models/release_info.dart';
import 'package:ios_club_app/features/system/update/app_version.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

import 'app_api.dart';

class AppService {
  static Future<ReleaseModel> getReleases({bool includeBeta = false}) async {
    final prefs = PrefsService.instance;

    try {
      final releases = await AppApi.getAppInfo();

      if (releases.isNotEmpty) {
        final re = _selectRelease(releases, includeBeta: includeBeta);
        if (re == null) {
          return const ReleaseModel(name: '0.0.0', body: '0.0.0');
        }

        if (re.body.contains('[强制更新]')) {
          return re;
        }

        final bool? updateIgnored = prefs.getBool(PrefsKeys.UPDATE_IGNORED);

        if (updateIgnored != null && updateIgnored == true) {
          return const ReleaseModel(name: '0.0.0', body: '0.0.0');
        }

        return re;
      }
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching releases: $e');
      }
    }

    return const ReleaseModel(name: '0.0.0', body: '0.0.0');
  }

  static Future<(bool, ReleaseModel)> isNeedUpdate({
    bool includeBeta = false,
  }) async {
    final result = await getReleases(includeBeta: includeBeta);
    if (result.name == '0.0.0') {
      return (false, result);
    }

    final releaseVersion = AppVersion.tryParse(result.name);
    if (releaseVersion == null) {
      return (false, result);
    }

    final currentVersion = await getCurrentVersion();
    return (releaseVersion.isNewerThan(currentVersion), result);
  }

  static Future<AppVersion> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return AppVersion.fromPackageInfo(packageInfo);
  }

  static bool isRemoteVersionNewer({
    required String remoteVersion,
    required String currentVersion,
    String currentBuildNumber = '',
  }) {
    final parsedRemote = AppVersion.tryParse(remoteVersion);
    if (parsedRemote == null) {
      return false;
    }

    final currentRaw = currentBuildNumber.trim().isEmpty
        ? currentVersion
        : '$currentVersion+$currentBuildNumber';
    final parsedCurrent = AppVersion.tryParse(currentRaw);
    if (parsedCurrent == null) {
      return false;
    }

    return parsedRemote.isNewerThan(parsedCurrent);
  }

  static String getReleaseDownloadUrl(ReleaseModel release) {
    final assetUrl = release.downloadUrl?.trim();
    if (assetUrl != null && assetUrl.isNotEmpty) {
      return assetUrl;
    }

    return 'https://gitee.com/luckyfishisdashen/iOSClub.AppMobile/releases/download/${release.releaseIdentifier}/app-release.apk';
  }

  static Future<void> updateApp(ReleaseModel release) async {
    final releaseVersion = AppVersion.tryParse(release.name);
    if (releaseVersion == null) {
      throw '无法识别版本号: ${release.name}';
    }

    final currentVersion = await getCurrentVersion();
    if (!releaseVersion.isNewerThan(currentVersion)) {
      return;
    }

    final url = getReleaseDownloadUrl(release);
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw '无法在浏览器中打开更新链接';
      }

      if (kDebugMode) {
        AppLogger.debug('已在浏览器中打开更新链接: $url');
      }
    } else {
      throw '无法打开更新链接';
    }
  }

  static ReleaseModel? _selectRelease(
    List<ReleaseInfo> releases, {
    required bool includeBeta,
  }) {
    for (final releaseInfo in releases) {
      final release = ReleaseModel.fromReleaseInfo(releaseInfo);
      final parsedVersion = AppVersion.tryParse(release.name);
      if (parsedVersion == null) {
        continue;
      }

      if (!includeBeta && parsedVersion.isBeta) {
        continue;
      }

      return release;
    }

    return null;
  }
}

class ReleaseModel {
  final String name;
  final String body;
  final String? downloadUrl;
  final String? tagName;

  const ReleaseModel({
    required this.name,
    required this.body,
    this.downloadUrl,
    this.tagName,
  });

  String get releaseIdentifier {
    final trimmedTag = tagName?.trim();
    if (trimmedTag != null && trimmedTag.isNotEmpty) {
      return trimmedTag;
    }

    return name.trim();
  }

  factory ReleaseModel.fromReleaseInfo(ReleaseInfo releaseInfo) {
    return ReleaseModel(
      name: (releaseInfo.name ?? releaseInfo.tagName ?? '0.0.0').trim(),
      body: releaseInfo.body ?? '',
      downloadUrl: releaseInfo.assets
          ?.map((asset) => asset.browserDownloadUrl?.trim())
          .whereType<String>()
          .firstWhere(
            (url) => url.isNotEmpty && url.toLowerCase().contains('apk'),
            orElse: () => '',
          ),
      tagName: releaseInfo.tagName?.trim(),
    );
  }

  factory ReleaseModel.fromJson(Map<String, dynamic> json) {
    return ReleaseModel(
      name: json['name'],
      body: json['body'],
      downloadUrl: json['downloadUrl'],
      tagName: json['tagName'],
    );
  }
}
