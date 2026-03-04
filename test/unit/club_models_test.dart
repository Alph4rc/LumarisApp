import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/club/models/api_response.dart';
import 'package:ios_club_app/features/club/models/client_application.dart';
import 'package:ios_club_app/features/club/models/member_model.dart';
import 'package:ios_club_app/features/club/models/project_model.dart';
import 'package:ios_club_app/features/club/models/staff_model.dart';
import 'package:ios_club_app/features/club/models/student_model.dart';
import 'package:ios_club_app/features/club/models/task_model.dart';
import 'package:ios_club_app/features/club/models/todo_model.dart';

void main() {
  group('ApiResponse', () {
    test('should parse success response and computed fields', () {
      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        <String, dynamic>{
          'code': 200,
          'errorCode': 0,
          'message': 'ok',
          'detail': null,
          'data': <String, dynamic>{'x': 1},
          'requestId': 'rid-1',
          'timestamp': '2026-03-02T00:00:00Z',
        },
      );

      expect(response.isSuccess, isTrue);
      expect(response.hasError, isFalse);
      expect(response.errorMessage, 'ok');
      expect(response.data!['x'], 1);
      expect(response.toJson()['code'], 200);
      expect(response.toString(), contains('ApiResponse(code: 200'));
    });

    test('should support typed converter and error detail', () {
      final response = ApiResponse<int>.fromJson(
        <String, dynamic>{
          'code': 400,
          'errorCode': 1001,
          'message': 'bad request',
          'detail': 'field invalid',
          'data': '7',
        },
        fromJsonT: (dynamic value) => int.parse(value as String),
      );

      expect(response.data, 7);
      expect(response.isSuccess, isFalse);
      expect(response.hasError, isTrue);
      expect(response.errorMessage, 'field invalid');
    });
  });

  group('Project/Task', () {
    test('should round-trip project model', () {
      final model = ProjectModel.fromJson(<String, dynamic>{
        'title': '校园开放日',
        'id': 'p1',
        'description': '活动组织',
        'startTime': '2026-03-01',
        'endTime': '2026-03-07',
      });

      expect(model.title, '校园开放日');
      expect(model.id, 'p1');
      expect(model.toJson()['description'], '活动组织');
    });

    test('should round-trip task model', () {
      final model = TaskModel.fromJson(<String, dynamic>{
        'title': '排班',
        'description': '分配值班',
        'startTime': '09:00',
        'endTime': '12:00',
        'status': true,
        'id': 't1',
      });

      expect(model.status, isTrue);
      expect(model.toJson()['id'], 't1');
      expect(model.toJson()['title'], '排班');
    });
  });

  group('Staff/Todo/Student', () {
    final studentJson = <String, dynamic>{
      'userName': '张三',
      'userId': '2026001',
      'academy': '信息学院',
      'politicalLandscape': '团员',
      'gender': '男',
      'className': '计科01',
      'phoneNum': '13800000000',
      'joinTime': '2026-03-01T08:00:00.000',
      'passwordHash': 'hash',
      'eMail': 'a@example.com',
    };

    test('should parse student with optional email', () {
      final student = StudentModel.fromJson(studentJson);
      expect(student.userName, '张三');
      expect(student.joinTime, DateTime.parse('2026-03-01T08:00:00.000'));
      expect(student.eMail, 'a@example.com');
      expect(student.toJson()['userId'], '2026001');
    });

    test('should parse todo with nested student and serialize back', () {
      final todo = TodoModel.fromJson(<String, dynamic>{
        'title': '发布通知',
        'description': '发送活动提醒',
        'startTime': '2026-03-02T09:00:00.000',
        'endTime': '2026-03-02T10:00:00.000',
        'status': false,
        'id': 'todo1',
        'student': studentJson,
        'studentId': '2026001',
        'createdTime': '2026-03-02T08:00:00.000',
      });

      expect(todo.student, isNotNull);
      expect(todo.student!.userName, '张三');
      expect(todo.createdTime, DateTime.parse('2026-03-02T08:00:00.000'));
      expect(todo.toJson()['studentId'], '2026001');
      expect((todo.toJson()['student'] as Map<String, dynamic>)['academy'],
          '信息学院');
    });

    test('should parse staff with empty projects/tasks fallback', () {
      final staffWithEmpty = StaffModel.fromJson(<String, dynamic>{
        'userId': 'u1',
        'name': '李四',
        'identity': '管理员',
      });
      expect(staffWithEmpty.projects, isEmpty);
      expect(staffWithEmpty.tasks, isEmpty);

      final staff = StaffModel.fromJson(<String, dynamic>{
        'userId': 'u2',
        'name': '王五',
        'identity': '成员',
        'projects': <Map<String, dynamic>>[
          <String, dynamic>{
            'title': '迎新',
            'id': 'p2',
            'description': '迎新活动',
          },
        ],
        'tasks': <Map<String, dynamic>>[
          <String, dynamic>{
            'title': '签到',
            'description': '现场签到',
            'startTime': '08:00',
            'endTime': '11:00',
            'status': false,
            'id': 't2',
          },
        ],
      });

      expect(staff.projects.length, 1);
      expect(staff.tasks.length, 1);
      expect(staff.toJson()['name'], '王五');
    });
  });

  group('Member/ClientApplication', () {
    test('should parse member and member data list', () {
      final member = MemberModel.fromJson(<String, dynamic>{
        'identity': '部长',
        'userName': '赵六',
        'userId': '2026123',
        'academy': '建筑学院',
        'politicalLandscape': '群众',
        'gender': '女',
        'className': '建工02',
        'phoneNum': '13900000000',
        'joinTime': '2026-02-01T00:00:00.000',
        'passwordHash': 'ph',
        'eMail': null,
      });

      expect(member.eMail, isNull);
      expect(member.toJson()['identity'], '部长');

      final memberData = MemberData.fromJson(<String, dynamic>{
        'totalCount': 1,
        'totalPages': 1,
        'data': <Map<String, dynamic>>[member.toJson()],
      });
      expect(memberData.totalCount, 1);
      expect(memberData.data.single.userName, '赵六');
      expect(memberData.toJson()['TotalCount'], 1);
    });

    test('should parse client application date fields', () {
      final app = ClientApplication.fromJson(<String, dynamic>{
        'clientId': 'cid',
        'clientSecret': 'secret',
        'applicationName': '门户',
        'description': '统一入口',
        'homepageUrl': 'https://example.com',
        'redirectUris': 'https://example.com/callback',
        'logoUrl': 'https://example.com/logo.png',
        'isActive': true,
        'supportsPkce': true,
        'isNeedEMail': false,
        'createdAt': '2026-01-01T00:00:00.000Z',
        'updatedAt': '2026-01-02T00:00:00.000Z',
      });

      expect(app.clientId, 'cid');
      expect(app.isActive, isTrue);
      expect(app.supportsPkce, isTrue);
      expect(app.createdAt, DateTime.parse('2026-01-01T00:00:00.000Z'));
      expect(app.toJson()['applicationName'], '门户');
      expect(app.toJson()['updatedAt'], '2026-01-02T00:00:00.000Z');
    });
  });
}
