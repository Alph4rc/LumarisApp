import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/release_info.dart';
import 'package:ios_club_app/core/services/app_service.dart';

void main() {
  group('AppService', () {
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
