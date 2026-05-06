import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/release_info.dart';
import 'package:ios_club_app/features/education/services/app_service.dart';
import 'package:ios_club_app/features/system/update/app_version.dart';

void main() {
  group('AppService', () {
    test('should compare build number when semantic version is the same', () {
      final result = AppService.isRemoteVersionNewer(
        remoteVersion: '1.1.20+2',
        currentVersion: '1.1.20',
        currentBuildNumber: '1',
      );

      expect(result, isTrue);
    });

    test('should compare beta release with build number correctly', () {
      final result = AppService.isRemoteVersionNewer(
        remoteVersion: 'beta 1.1.20+2',
        currentVersion: '1.1.20',
        currentBuildNumber: '1',
      );

      expect(result, isTrue);
    });

    test('stable release should be newer than beta with same build number', () {
      final betaVersion = AppVersion.tryParse('beta 1.1.20+2');
      final stableVersion = AppVersion.tryParse('1.1.20+2');

      expect(betaVersion, isNotNull);
      expect(stableVersion, isNotNull);
      expect(stableVersion!.isNewerThan(betaVersion!), isTrue);
    });

    test('should_use_first_asset_browser_download_url_that_contains_apk', () {
      final release = ReleaseModel.fromReleaseInfo(
        ReleaseInfo(
          id: 1,
          name: '1.2.3',
          body: 'release notes',
          createdAt: DateTime.parse('2026-05-06T00:00:00Z'),
          assets: [
            AssetInfo(
              browserDownloadUrl: 'https://downloads.example.com/readme.txt',
              name: 'readme.txt',
            ),
            AssetInfo(
              browserDownloadUrl: 'https://downloads.example.com/app.apk',
              name: 'app-release.apk',
            ),
          ],
        ),
      );

      final result = AppService.getReleaseDownloadUrl(release);

      expect(result, 'https://downloads.example.com/app.apk');
    });

    test('should_fallback_to_tag_name_when_building_default_download_url', () {
      const release = ReleaseModel(
        name: 'beta 1.2.3+4',
        body: 'release notes',
        tagName: 'beta-1.2.3+4',
      );

      final result = AppService.getReleaseDownloadUrl(release);

      expect(
        result,
        'https://gitee.com/luckyfishisdashen/iOSClub.AppMobile/releases/download/beta-1.2.3+4/app-release.apk',
      );
    });

    test('should_fallback_to_default_release_path_when_asset_url_is_missing',
        () {
      const release = ReleaseModel(
        name: '1.2.3',
        body: 'release notes',
      );

      final result = AppService.getReleaseDownloadUrl(release);

      expect(
        result,
        'https://gitee.com/luckyfishisdashen/iOSClub.AppMobile/releases/download/1.2.3/app-release.apk',
      );
    });
  });
}
