import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('should have default school', () {
      final defaultSchool = ApiConfig.getDefaultSchool();
      expect(defaultSchool, isNotNull);
      expect(defaultSchool.id, equals('xauat'));
      expect(defaultSchool.name, equals('西安建筑科技大学'));
      expect(defaultSchool.eduApiBaseUrl, equals('https://xauatapi.xauat.site'));
    });

    test('should get school by id', () {
      final school = ApiConfig.getSchoolById('xauat');
      expect(school, isNotNull);
      expect(school!.id, equals('xauat'));
    });

    test('should return null for invalid school id', () {
      final school = ApiConfig.getSchoolById('invalid_id');
      expect(school, isNull);
    });

    test('should get all schools', () {
      final schools = ApiConfig.getAllSchools();
      expect(schools, isNotEmpty);
      expect(schools.length, greaterThanOrEqualTo(1));
    });

    test('default school id should be valid', () {
      final school = ApiConfig.getSchoolById(ApiConfig.defaultSchoolId);
      expect(school, isNotNull);
    });
  });

  group('SchoolConfig', () {
    test('should create from json', () {
      final json = {
        'id': 'test',
        'name': '测试大学',
        'eduApiBaseUrl': 'https://api.test.edu.cn',
      };

      final config = SchoolConfig.fromJson(json);
      expect(config.id, equals('test'));
      expect(config.name, equals('测试大学'));
      expect(config.eduApiBaseUrl, equals('https://api.test.edu.cn'));
    });

    test('should convert to json', () {
      const config = SchoolConfig(
        id: 'test',
        name: '测试大学',
        eduApiBaseUrl: 'https://api.test.edu.cn',
      );

      final json = config.toJson();
      expect(json['id'], equals('test'));
      expect(json['name'], equals('测试大学'));
      expect(json['eduApiBaseUrl'], equals('https://api.test.edu.cn'));
    });
  });
}
