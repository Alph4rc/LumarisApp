import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/models/school.dart';

void main() {
  group('School fallback', () {
    test('should have default school', () {
      final defaultSchool = School.fallbackList.first;
      expect(defaultSchool, isNotNull);
      expect(defaultSchool.code, equals(School.defaultCode));
      expect(defaultSchool.name, equals('西安建筑科技大学'));
      expect(defaultSchool.website, equals('https://xauatapi.xauat.site'));
    });

    test('should find school by code', () {
      final school = School.findByCode(
        School.fallbackList,
        School.defaultCode,
      );
      expect(school, isNotNull);
      expect(school!.code, equals(School.defaultCode));
    });

    test('should return null for invalid school code', () {
      final school = School.findByCode(
        School.fallbackList,
        'invalid_code',
      );
      expect(school, isNull);
    });

    test('should get fallback schools', () {
      final schools = School.fallbackList;
      expect(schools, isNotEmpty);
      expect(schools.length, greaterThanOrEqualTo(1));
    });

    test('default school code should be valid', () {
      final school = School.findByCode(
        School.fallbackList,
        School.defaultCode,
      );
      expect(school, isNotNull);
    });
  });

  group('School', () {
    test('should create from json', () {
      final json = {
        'code': 'test',
        'name': '测试大学',
        'website': 'https://api.test.edu.cn',
        'features': <String>['timetable'],
        'enabled': true,
        'week_start_day': DateTime.monday,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final school = School.fromJson(json);
      expect(school.code, equals('test'));
      expect(school.name, equals('测试大学'));
      expect(school.website, equals('https://api.test.edu.cn'));
      expect(school.features, equals([Feature.timetable]));
      expect(school.weekStartDay, equals(DateTime.monday));
    });

    test('should default missing week start day to Sunday', () {
      final json = {
        'code': 'test',
        'name': '测试大学',
        'website': 'https://api.test.edu.cn',
        'features': <String>['timetable'],
        'enabled': true,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final school = School.fromJson(json);
      expect(school.weekStartDay, equals(DateTime.sunday));
    });

    test('should default invalid week start day to Sunday', () {
      final json = {
        'code': 'test',
        'name': '测试大学',
        'website': 'https://api.test.edu.cn',
        'features': <String>['timetable'],
        'enabled': true,
        'week_start_day': DateTime.wednesday,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final school = School.fromJson(json);
      expect(school.weekStartDay, equals(DateTime.sunday));
    });

    test('should default non integer week start day to Sunday', () {
      final json = {
        'code': 'test',
        'name': '测试大学',
        'website': 'https://api.test.edu.cn',
        'features': <String>['timetable'],
        'enabled': true,
        'week_start_day': '1',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final school = School.fromJson(json);
      expect(school.weekStartDay, equals(DateTime.sunday));
    });

    test('should convert to json', () {
      final school = School(
        code: 'test',
        name: '测试大学',
        website: 'https://api.test.edu.cn',
        features: [Feature.timetable],
        weekStartDay: DateTime.monday,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = school.toJson();
      expect(json['code'], equals('test'));
      expect(json['name'], equals('测试大学'));
      expect(json['website'], equals('https://api.test.edu.cn'));
      expect(json['features'], equals(['timetable']));
      expect(json['week_start_day'], equals(DateTime.monday));
    });
  });
}
