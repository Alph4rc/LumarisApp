import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/club/models/data_access_stats.dart';
import 'package:ios_club_app/features/club/models/data_centre_model.dart';
import 'package:ios_club_app/features/club/models/data_change_stats.dart';
import 'package:ios_club_app/features/club/models/update_client_app_model.dart';

void main() {
  group('DataAccessStats', () {
    test('should parse entities, timestamp and extra fields', () {
      final model = DataAccessStats.fromJson(<String, dynamic>{
        'totalAccessCount': 120,
        'topAccessedEntities': <Map<String, dynamic>>[
          <String, dynamic>{
            'entityId': 'e1',
            'entityName': '成员',
            'accessCount': 80,
            'lastAccessTime': '2026-03-02T10:00:00.000Z',
            'source': 'web',
          },
        ],
        'entityType': 'member',
        'top': 10,
        'timestamp': '2026-03-02T12:00:00.000Z',
        'env': 'prod',
      });

      expect(model.totalAccessCount, 120);
      expect(model.topAccessedEntities, isNotNull);
      expect(model.topAccessedEntities!.single.entityName, '成员');
      expect(model.topAccessedEntities!.single.extra!['source'], 'web');
      expect(model.extra!['env'], 'prod');

      final json = model.toJson();
      expect(json['entityType'], 'member');
      expect((json['topAccessedEntities'] as List).length, 1);
      expect(json['timestamp'], '2026-03-02T12:00:00.000Z');
    });

    test('should keep nullable lists as null when source list empty', () {
      final model = DataAccessStats.fromJson(<String, dynamic>{
        'topAccessedEntities': <dynamic>[],
      });
      expect(model.topAccessedEntities, isNull);
    });
  });

  group('DataChangeStats', () {
    test('should parse entities and emit toJson', () {
      final model = DataChangeStats.fromJson(<String, dynamic>{
        'totalChangeCount': 30,
        'topChangedEntities': <Map<String, dynamic>>[
          <String, dynamic>{
            'entityId': 'c1',
            'entityName': '任务',
            'changeCount': 11,
            'lastChangeTime': '2026-03-02T09:00:00.000Z',
            'operator': 'admin',
          },
        ],
        'entityType': 'task',
        'top': 5,
        'timestamp': '2026-03-02T12:00:00.000Z',
      });

      expect(model.totalChangeCount, 30);
      expect(model.topChangedEntities!.single.changeCount, 11);
      expect(model.topChangedEntities!.single.extra!['operator'], 'admin');

      final json = model.toJson();
      expect(json['top'], 5);
      expect((json['topChangedEntities'] as List).length, 1);
    });
  });

  group('DataCentreModel', () {
    test('should parse summary fields and serialize', () {
      final model = DataCentreModel.fromJson(<String, dynamic>{
        'members': 100,
        'departments': 6,
        'staffs': 18,
        'tasks': 20,
        'projects': 4,
        'resources': 15,
        'todos': 9,
      });

      expect(model.members, 100);
      expect(model.departments, 6);
      expect(model.toJson()['resources'], 15);
    });

    test('should parse grade count nullable values', () {
      final count = GradeCount.fromJson(<String, dynamic>{
        'grade': '2026',
        'value': 12,
      });
      final empty = GradeCount.fromJson(<String, dynamic>{});

      expect(count.toJson(), <String, dynamic>{'grade': '2026', 'value': 12});
      expect(empty.grade, isNull);
      expect(empty.value, isNull);
    });
  });

  group('UpdateClientAppModel', () {
    test('should parse update client app model with optional list', () {
      final model = UpdateClientAppModel.fromJson(<String, dynamic>{
        'applicationName': '新门户',
        'description': 'desc',
        'homepageUrl': 'https://example.com',
        'redirectUris': <String>['https://example.com/callback'],
        'logoUrl': 'https://example.com/logo.png',
        'isActive': true,
        'isNeedEMail': false,
        'supportsPkce': true,
      });

      expect(model.applicationName, '新门户');
      expect(model.redirectUris, <String>['https://example.com/callback']);
      expect(model.toJson()['isActive'], isTrue);
      expect(model.toJson()['isNeedEMail'], isFalse);
    });
  });
}
