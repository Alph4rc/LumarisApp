import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/club/models/academy_count.dart';
import 'package:ios_club_app/features/club/models/article_create_dto.dart';
import 'package:ios_club_app/features/club/models/article_model.dart';
import 'package:ios_club_app/features/club/models/article_update_dto.dart';
import 'package:ios_club_app/features/club/models/create_client_app_model.dart';
import 'package:ios_club_app/features/club/models/department_model.dart';
import 'package:ios_club_app/features/club/models/gender_count.dart';
import 'package:ios_club_app/features/club/models/http_stats.dart';
import 'package:ios_club_app/features/club/models/landscape_count.dart';
import 'package:ios_club_app/features/club/models/login_model.dart';
import 'package:ios_club_app/features/club/models/regenerate_secret_result.dart';
import 'package:ios_club_app/features/club/models/reset_password_data.dart';
import 'package:ios_club_app/features/club/models/resource_model.dart';
import 'package:ios_club_app/features/club/models/year_count.dart';

void main() {
  group('Simple count/auth/resource models', () {
    test('should round-trip academy/gender/landscape/year counts', () {
      expect(
        AcademyCount.fromJson(<String, dynamic>{'type': '软件', 'value': 12})
            .toJson(),
        <String, dynamic>{'type': '软件', 'value': 12},
      );
      expect(
        GenderCount.fromJson(<String, dynamic>{'type': '男', 'value': 20})
            .toJson(),
        <String, dynamic>{'type': '男', 'value': 20},
      );
      expect(
        LandscapeCount.fromJson(<String, dynamic>{'type': '团员', 'sales': 15})
            .toJson(),
        <String, dynamic>{'type': '团员', 'sales': 15},
      );
      expect(
        YearCount.fromJson(<String, dynamic>{'year': '2026', 'value': 10})
            .toJson(),
        <String, dynamic>{'year': '2026', 'value': 10},
      );
    });

    test('should round-trip login/reset/resource/secret models', () {
      expect(
        LoginModel.fromJson(<String, dynamic>{
          'userId': 'u1',
          'password': 'p',
          'rememberMe': true,
        }).toJson(),
        <String, dynamic>{
          'userId': 'u1',
          'password': 'p',
          'rememberMe': true,
        },
      );

      expect(
        ResetPasswordData.fromJson(<String, dynamic>{
          'userId': 'u2',
          'newPassword': 'newp',
        }).toJson(),
        <String, dynamic>{'userId': 'u2', 'newPassword': 'newp'},
      );

      expect(
        RegenerateSecretResult.fromJson(<String, dynamic>{
          'clientId': 'cid',
          'newSecret': 'sec',
        }).toJson(),
        <String, dynamic>{'clientId': 'cid', 'newSecret': 'sec'},
      );

      expect(
        ResourceModel.fromJson(<String, dynamic>{
          'id': 'r1',
          'name': '实验室',
          'description': '预约',
          'tag': 'hot',
        }).toJson(),
        <String, dynamic>{
          'id': 'r1',
          'name': '实验室',
          'description': '预约',
          'tag': 'hot',
        },
      );
    });
  });

  group('Article DTO and model', () {
    test('should parse article create/update dto', () {
      final create = ArticleCreateDto.fromJson(<String, dynamic>{
        'path': '/a.md',
        'title': '标题',
        'content': '正文',
        'identity': 'admin',
        'category': 'news',
        'articleOrder': 1,
      });
      final update = ArticleUpdateDto.fromJson(<String, dynamic>{
        'title': '新标题',
        'content': '新正文',
        'identity': 'editor',
        'category': 'notice',
        'articleOrder': 2,
      });

      expect(create.toJson()['path'], '/a.md');
      expect(create.toJson()['articleOrder'], 1);
      expect(update.toJson()['title'], '新标题');
      expect(update.toJson()['category'], 'notice');
    });

    test('should parse article with nested category', () {
      final article = ArticleModel.fromJson(<String, dynamic>{
        'path': '/b.md',
        'title': '公告',
        'content': '内容',
        'lastWriteTime': '2026-03-01T12:00:00.000Z',
        'identity': 'admin',
        'categoryId': 'c1',
        'category': <String, dynamic>{
          'id': 'c1',
          'name': '通知',
          'order': 3,
          'description': '系统通知',
        },
        'articleOrder': 9,
      });

      expect(article.category, isNotNull);
      expect(article.category!.name, '通知');
      expect(article.lastWriteTime, DateTime.parse('2026-03-01T12:00:00.000Z'));
      expect(article.toJson()['categoryId'], 'c1');
      expect(
        (article.toJson()['category'] as Map<String, dynamic>)['description'],
        '系统通知',
      );
    });
  });

  group('Department and app/http stats', () {
    test('should parse department with fallback empty lists', () {
      final department = DepartmentModel.fromJson(<String, dynamic>{
        'key': 'dev',
        'name': '开发部',
      });
      expect(department.staffs, isEmpty);
      expect(department.projects, isEmpty);
      expect(department.toJson()['key'], 'dev');
    });

    test('should parse create client app model', () {
      final model = CreateClientAppModel.fromJson(<String, dynamic>{
        'applicationName': '统一认证',
        'description': 'SSO',
        'homepageUrl': 'https://example.com',
        'redirectUris': <String>['https://example.com/cb'],
        'logoUrl': 'https://example.com/logo.png',
        'isNeedEMail': true,
        'supportsPkce': true,
      });

      expect(model.applicationName, '统一认证');
      expect(model.redirectUris, <String>['https://example.com/cb']);
      expect(model.toJson()['isNeedEMail'], isTrue);
    });

    test('should parse http stats and keep extra fields', () {
      final stats = HttpStats.fromJson(<String, dynamic>{
        'totalRequests': 100,
        'successfulRequests': 95,
        'failedRequests': 5,
        'avgResponseTime': 12.5,
        'minResponseTime': 3,
        'maxResponseTime': 30,
        'requestsPerSecond': 6,
        'endpointStats': <String, int>{'/api/a': 80, '/api/b': 20},
        'env': 'prod',
      });

      expect(stats.totalRequests, 100);
      expect(stats.avgResponseTime, 12.5);
      expect(stats.minResponseTime, 3.0);
      expect(stats.endpointStats!['/api/a'], 80);
      expect(stats.extra!['env'], 'prod');

      final json = stats.toJson();
      expect(json['totalRequests'], 100);
      expect((json['endpointStats'] as Map<String, int>)['/api/b'], 20);
      expect(json['env'], 'prod');
    });
  });
}
