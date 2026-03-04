import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/todo_item.dart';

void main() {
  group('TodoItem', () {
    test('should initialize with generated id and default completion', () {
      final item = TodoItem(title: '写测试', deadline: '2026-03-02');
      expect(item.id, isNotEmpty);
      expect(item.title, '写测试');
      expect(item.deadline, '2026-03-02');
      expect(item.isCompleted, isFalse);
      expect(item.description, isNull);
      expect(item.key, isNull);
    });

    test('should serialize and deserialize with optional fields', () {
      final item = TodoItem(
        id: 'todo-1',
        title: '提测',
        deadline: '2026-03-03',
        isCompleted: true,
      )
        ..description = '补充边界用例'
        ..key = 'k1';

      final json = item.toJson();
      expect(json['id'], 'todo-1');
      expect(json['title'], '提测');
      expect(json['deadline'], '2026-03-03');
      expect(json['isCompleted'], isTrue);
      expect(json['description'], '补充边界用例');
      expect(json['key'], 'k1');

      final decoded = TodoItem.fromJson(json);
      expect(decoded.id, 'todo-1');
      expect(decoded.title, '提测');
      expect(decoded.deadline, '2026-03-03');
      expect(decoded.isCompleted, isTrue);
      expect(decoded.description, '补充边界用例');
      expect(decoded.key, 'k1');
    });

    test('should fallback missing fields to safe defaults', () {
      final decoded = TodoItem.fromJson(<String, dynamic>{});
      expect(decoded.id, isNotEmpty);
      expect(decoded.title, '');
      expect(decoded.deadline, '');
      expect(decoded.isCompleted, isFalse);
      expect(decoded.description, isNull);
      expect(decoded.key, isNull);
    });
  });
}
