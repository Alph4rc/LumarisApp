import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/edu_api_models.dart';
import 'package:ios_club_app/features/education/models/payment_model.dart';
import 'package:ios_club_app/features/education/models/raw_string_response.dart';

void main() {
  group('CourseResultResponse', () {
    test('should deserialize v1 payload', () {
      final response = CourseResultResponse.fromJson(<String, dynamic>{
        'success': true,
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'weekIndexes': <dynamic>[1, '2'],
            'teachers': <String>['T1'],
            'campus': 'Main',
            'room': 'A101',
            'courseName': 'Math',
            'courseCode': 'M101',
            'weekday': '1',
            'startUnit': 1,
            'endUnit': '2',
            'credits': '3.0',
            'lessonId': 'L1',
          }
        ],
        'expirationTime': '2026-03-23T00:00:00Z',
      });

      expect(response.success, isTrue);
      expect(response.data.single.courseName, 'Math');
      expect(response.data.single.weekIndexes, <int>[1, 2]);
      expect(response.data.single.endUnit, 2);
    });
  });

  group('ExamResponse', () {
    test('should round-trip exams list', () {
      final response = ExamResponse.fromJson(<String, dynamic>{
        'exams': <Map<String, dynamic>>[
          <String, dynamic>{
            'name': '线性代数',
            'time': '2026-01-10 08:00~10:00',
            'location': 'A101',
            'seat': '08',
          }
        ],
        'canClick': true,
        'error': null,
      });

      expect(response.canClick, isTrue);
      expect(response.exams.single.room, 'A101');
      expect(response.toJson()['exams'], hasLength(1));
    });
  });

  group('SemesterResult', () {
    test('should parse value-text items only', () {
      final result = SemesterResult.fromJson(<String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{'value': '2025-2', 'text': '2025-2026-2'}
        ]
      });

      expect(result.data.single.semester, '2025-2');
      expect(result.data.single.name, '2025-2026-2');
    });
  });

  group('PaymentData', () {
    test('should parse payment turnover payload', () {
      final result = PaymentData.fromJson(<String, dynamic>{
        'records': <Map<String, dynamic>>[
          <String, dynamic>{
            'turnoverType': '消费',
            'datetimeStr': '2026-03-23 12:00:00',
            'resume': '食堂',
            'tranamt': '1500',
          }
        ],
        'total': '88.5',
      });

      expect(result.payments.single.amount, 1500);
      expect(result.total, 88.5);
    });
  });

  group('RawStringResponse', () {
    test('should wrap raw string responses', () {
      final result = RawStringResponse.fromResponse('plain-text-response');
      expect(result.value, 'plain-text-response');
      expect(
          result.toJson(), <String, dynamic>{'value': 'plain-text-response'});
    });
  });
}
