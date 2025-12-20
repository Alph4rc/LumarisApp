import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('CourseStore', () {
    late CourseStore courseStore;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      courseStore = CourseStore();
    });

    test('should initialize with empty lists', () {
      expect(courseStore.courses, isEmpty);
      expect(courseStore.ignoreCourses, isEmpty);
    });

    test('should add ignore courses to the store', () async {
      courseStore.setIgnoreCourses(['数学', '英语']);

      expect(courseStore.ignoreCourses, hasLength(2));
      expect(courseStore.ignoreCourses, contains('数学'));
      expect(courseStore.ignoreCourses, contains('英语'));
    });

    test('should add single ignore course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.addIgnoreCourse('英语');

      expect(courseStore.ignoreCourses, hasLength(2));
      expect(courseStore.ignoreCourses, contains('数学'));
      expect(courseStore.ignoreCourses, contains('英语'));
    });

    test('should not add duplicate ignore course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.addIgnoreCourse('数学'); // 添加重复项

      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('数学'));
    });

    test('should remove ignore course', () async {
      courseStore.setIgnoreCourses(['数学', '英语']);
      await courseStore.removeIgnoreCourse('数学');

      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('英语'));
    });

    test('should not remove non-existent ignore course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.removeIgnoreCourse('英语'); // 移除不存在的项

      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('数学'));
    });

    test('should clear course data', () {
      // Test that clearCourseData doesn't throw exceptions
      expect(() => courseStore.clearCourseData(), returnsNormally);
    });

    test('should have correct read-only list properties', () {
      // Verify that we can access read-only lists
      expect(() => courseStore.courses, returnsNormally);
      expect(() => courseStore.ignoreCourses, returnsNormally);
      expect(() => courseStore.ignoreCoursesList, returnsNormally);

      // Verify that ignoreCoursesList returns a list
      expect(courseStore.ignoreCoursesList, isA<List<String>>());
    });

    test('should handle empty ignore course list', () async {
      // Test adding to empty list
      await courseStore.addIgnoreCourse('新课程');
      expect(courseStore.ignoreCourses, hasLength(1));

      // Test removing from empty list (should not throw)
      await courseStore.removeIgnoreCourse('不存在的课程');
      expect(courseStore.ignoreCourses, hasLength(1));
    });

    test('should handle large ignore course list', () async {
      // Create a large list of course names
      final largeList = List.generate(100, (index) => '课程$index');

      // Set large list
      courseStore.setIgnoreCourses(largeList);

      // Verify all courses were added
      expect(courseStore.ignoreCourses, hasLength(100));
      expect(courseStore.ignoreCourses.contains('课程0'), true);
      expect(courseStore.ignoreCourses.contains('课程99'), true);

      // Add another course to large list
      await courseStore.addIgnoreCourse('新课程');
      expect(courseStore.ignoreCourses, hasLength(101));

      // Remove a course from large list
      await courseStore.removeIgnoreCourse('课程50');
      expect(courseStore.ignoreCourses, hasLength(100));
      expect(courseStore.ignoreCourses.contains('课程50'), false);
    });
  });
}
