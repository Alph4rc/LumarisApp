import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/services/app_api.dart';

Map<String, dynamic> releaseJson([
  String name = '1.2.2',
  String asset = 'app-arm64-v8a-release.apk',
]) {
  return <String, dynamic>{
    'id': 0,
    'tag_name': name,
    'name': name,
    'body': 'release notes',
    'created_at': '2026-10-17T00:00:00Z',
    'assets': <dynamic>[
      <String, dynamic>{
        'browser_download_url': 'https://example.com/$asset',
        'name': 'release_android',
      },
    ],
  };
}

void main() {
  group('AppApi.parseReleases', () {
    test('parses bare release array (old Gitee contract)', () {
      final releases = AppApi.parseReleases(<dynamic>[releaseJson()]);

      expect(releases, hasLength(1));
      expect(releases.first.name, '1.2.2');
      expect(
        releases.first.assets?.first.browserDownloadUrl,
        'https://example.com/app-arm64-v8a-release.apk',
      );
    });

    test('parses Luminous envelope with data.items', () {
      final releases = AppApi.parseReleases(<String, dynamic>{
        'code': 200,
        'message': 'success',
        'data': <String, dynamic>{
          'total': 1,
          'items': <dynamic>[releaseJson()],
        },
      });

      expect(releases, hasLength(1));
      expect(releases.first.name, '1.2.2');
    });

    test('parses envelope whose data is a list', () {
      final releases = AppApi.parseReleases(<String, dynamic>{
        'code': 200,
        'data': <dynamic>[releaseJson()],
      });

      expect(releases, hasLength(1));
      expect(releases.first.name, '1.2.2');
    });

    test('parses a single release object', () {
      final releases = AppApi.parseReleases(releaseJson());

      expect(releases, hasLength(1));
      expect(releases.first.name, '1.2.2');
    });

    test('parses a JSON string body', () {
      final releases = AppApi.parseReleases(jsonEncode([releaseJson()]));

      expect(releases, hasLength(1));
      expect(releases.first.name, '1.2.2');
    });

    test('throws on unexpected response type', () {
      expect(() => AppApi.parseReleases(42), throwsFormatException);
    });
  });
}
