import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/education/models/link_model.dart';

void main() {
  group('LinkModel', () {
    test('should serialize deserialize and copy correctly', () {
      const link = LinkModel(
        key: 'lib',
        name: '图书馆',
        icon: 'book',
        url: 'https://example.com/lib',
        description: '馆藏检索',
        index: 1,
      );

      final json = link.toJson();
      final decoded = LinkModel.fromJson(json);
      expect(decoded.key, 'lib');
      expect(decoded.name, '图书馆');
      expect(decoded.icon, 'book');
      expect(decoded.url, 'https://example.com/lib');
      expect(decoded.description, '馆藏检索');
      expect(decoded.index, 1);

      final copied = link.copyWith(name: '图书馆新入口', index: 2);
      expect(copied.name, '图书馆新入口');
      expect(copied.index, 2);
      expect(copied.key, 'lib');
      expect(copied.url, 'https://example.com/lib');
    });

    test('should support null optional fields', () {
      const link = LinkModel(
        key: 'map',
        name: '地图',
        url: 'https://example.com/map',
        index: 3,
      );

      final decoded = LinkModel.fromJson(link.toJson());
      expect(decoded.icon, isNull);
      expect(decoded.description, isNull);
    });
  });

  group('CategoryModel', () {
    test('should serialize deserialize and copy with links', () {
      const link = LinkModel(
        key: 'oa',
        name: '办公系统',
        icon: 'office',
        url: 'https://example.com/oa',
        description: 'OA',
        index: 0,
      );
      const category = CategoryModel(
        key: 'work',
        name: '工作',
        description: '办公入口',
        icon: 'work',
        index: 1,
        links: <LinkModel>[link],
      );

      final json = category.toJson();
      final decoded = CategoryModel.fromJson(json);
      expect(decoded.key, 'work');
      expect(decoded.name, '工作');
      expect(decoded.icon, 'work');
      expect(decoded.description, '办公入口');
      expect(decoded.index, 1);
      expect(decoded.links.length, 1);
      expect(decoded.links.first.name, '办公系统');

      final copied = category.copyWith(name: '办公', links: <LinkModel>[]);
      expect(copied.name, '办公');
      expect(copied.links, isEmpty);
      expect(copied.key, 'work');
    });
  });
}
