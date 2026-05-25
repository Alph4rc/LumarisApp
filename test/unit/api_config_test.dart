import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('should have default school', () {
      final defaultSchool = ApiConfig.fallbackSchools.first;
      expect(defaultSchool, isNotNull);
      expect(defaultSchool.code, equals('xauat'));
      expect(defaultSchool.name, equals('西安建筑科技大学'));
      expect(defaultSchool.website, equals('https://xauatapi.xauat.site'));
    });

    test('should find school by code', () {
      final school = ApiConfig.findSchoolByCode(
        ApiConfig.fallbackSchools,
        'xauat',
      );
      expect(school, isNotNull);
      expect(school!.code, equals('xauat'));
    });

    test('should return null for invalid school code', () {
      final school = ApiConfig.findSchoolByCode(
        ApiConfig.fallbackSchools,
        'invalid_code',
      );
      expect(school, isNull);
    });

    test('should get fallback schools', () {
      final schools = ApiConfig.fallbackSchools;
      expect(schools, isNotEmpty);
      expect(schools.length, greaterThanOrEqualTo(1));
    });

    test('default school code should be valid', () {
      final school = ApiConfig.findSchoolByCode(
        ApiConfig.fallbackSchools,
        ApiConfig.defaultSchoolCode,
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
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
      };

      final school = School.fromJson(json);
      expect(school.code, equals('test'));
      expect(school.name, equals('测试大学'));
      expect(school.website, equals('https://api.test.edu.cn'));
      expect(school.features, equals([Feature.timetable]));
    });

    test('should convert to json', () {
      final school = School(
        code: 'test',
        name: '测试大学',
        website: 'https://api.test.edu.cn',
        features: [Feature.timetable],
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      final json = school.toJson();
      expect(json['code'], equals('test'));
      expect(json['name'], equals('测试大学'));
      expect(json['website'], equals('https://api.test.edu.cn'));
      expect(json['features'], equals(['timetable']));
    });
  });
}
