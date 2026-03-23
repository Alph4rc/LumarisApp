import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/course_time.dart';
import 'package:ios_club_app/core/models/member_info.dart';
import 'package:ios_club_app/features/education/models/user_data.dart';
import 'package:ios_club_app/features/education/models/week_info.dart';

void main() {
  group('UserData', () {
    test('should parse from json', () {
      final model = UserData.fromJson(<String, dynamic>{
        'studentId': '20261234',
        'cookie': 'sid=abc',
      });
      expect(model.studentId, '20261234');
      expect(model.cookie, 'sid=abc');
    });
  });

  group('MemberInfo', () {
    test('should parse with nested member info and serialize', () {
      final model = MemberInfo.fromJson(<String, dynamic>{
        'memberData': <String, dynamic>{'role': 'admin'},
        'info': <String, dynamic>{
          'identity': '管理员',
          'userName': '张三',
          'userId': 'u1',
          'academy': '信息学院',
          'politicalLandscape': '团员',
          'gender': '男',
          'className': '计科01',
          'phoneNum': '13800000000',
          'joinTime': '2026-03-01T00:00:00.000',
          'passwordHash': 'hash',
          'eMail': 'x@example.com',
        },
      });

      expect(model.memberData['role'], 'admin');
      expect(model.info, isNotNull);
      expect(model.info!.userName, '张三');

      final json = model.toJson();
      expect((json['memberData'] as Map<String, dynamic>)['role'], 'admin');
      expect((json['info'] as Map<String, dynamic>)['userId'], 'u1');
    });

    test('should fallback empty memberData when missing', () {
      final model = MemberInfo.fromJson(<String, dynamic>{});
      expect(model.memberData, isEmpty);
      expect(model.info, isNull);
      expect(model.toJson()['memberData'], isEmpty);
    });
  });

  group('WeekInfo', () {
    test('should parse with defaults', () {
      final model = WeekInfo.fromJson(<String, dynamic>{});
      expect(model.week, 0);
      expect(model.maxWeek, 0);
      expect(model.toJson(), <String, dynamic>{'week': 0, 'maxWeek': 0});
    });
  });

  group('CourseTime', () {
    test('difference should return startTime minus input time', () {
      final start = DateTime(2026, 3, 2, 10, 0);
      final end = DateTime(2026, 3, 2, 11, 30);
      final model =
          CourseTime(startTime: start, courseName: '高数', endTime: end);

      final diff = model.difference(DateTime(2026, 3, 2, 9, 30));
      expect(diff, const Duration(minutes: 30));
      expect(model.courseName, '高数');
      expect(model.endTime, end);
    });
  });
}
