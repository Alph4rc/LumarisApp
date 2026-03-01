import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/time_info.dart';

void main() {
  group('TimeInfo', () {
    test('should parse base fields and string extras', () {
      final info = TimeInfo.fromJson(<String, dynamic>{
        'startTime': '2026-03-01',
        'endTime': '2026-07-01',
        'semester': '2025-2026-2',
        'week': '3',
        'note': 'mid-term',
        'numeric': 123,
      });

      expect(info.startTime, '2026-03-01');
      expect(info.endTime, '2026-07-01');
      expect(info.semester, '2025-2026-2');
      expect(info.extra, isNotNull);
      expect(info.extra!['week'], '3');
      expect(info.extra!['note'], 'mid-term');
      expect(info.extra!.containsKey('numeric'), isFalse);
    });

    test('toJson should include base fields and extra values', () {
      final info = TimeInfo(
        startTime: 's',
        endTime: 'e',
        semester: 'sem',
        extra: <String, String>{'x': '1'},
      );

      final json = info.toJson();
      expect(json['startTime'], 's');
      expect(json['endTime'], 'e');
      expect(json['semester'], 'sem');
      expect(json['x'], '1');
    });

    test('operator [] should support known keys and extras', () {
      final info = TimeInfo(
        startTime: 'start',
        endTime: 'end',
        semester: 'term',
        extra: <String, String>{'week': '8'},
      );

      expect(info['startTime'], 'start');
      expect(info['endTime'], 'end');
      expect(info['semester'], 'term');
      expect(info['week'], '8');
      expect(info['missing'], isNull);
    });
  });
}
