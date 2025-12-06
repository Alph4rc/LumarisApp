import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/core/models/course_model.dart';
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
      expect(courseStore.customCourses, isEmpty);
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

    test('should add custom course', () async {
      final customCourse = CourseModel(
        courseName: '自定义课程',
        room: 'Room 101',
        teachers: ['张老师'],
        weekday: 1,
        startUnit: 1,
        endUnit: 2,
        credits: '2.0',
        courseCode: 'CUSTOM001',
      );
      
      await courseStore.addCustomCourse(customCourse);
      
      expect(courseStore.customCourses, hasLength(1));
      expect(courseStore.customCourses.first.courseName, '自定义课程');
      expect(courseStore.customCourses.first.teachers, contains('张老师'));
    });

    test('should delete custom course', () async {
      final customCourse = CourseModel(
        courseName: '自定义课程',
        room: 'Room 101',
      );
      
      await courseStore.addCustomCourse(customCourse);
      expect(courseStore.customCourses, hasLength(1));
      
      await courseStore.deleteCustomCourse(customCourse);
      expect(courseStore.customCourses, isEmpty);
    });

    test('should clear course data', () {
      // Test that clearCourseData doesn't throw exceptions
      expect(() => courseStore.clearCourseData(), returnsNormally);
    });

    test('should have correct read-only list properties', () {
      // Verify that we can access the read-only lists
      expect(() => courseStore.courses, returnsNormally);
      expect(() => courseStore.customCourses, returnsNormally);
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

    test('should handle custom courses with special characters', () async {
      final specialCourse = CourseModel(
        courseName: '课程名称包含特殊字符: !@#\$%^&*()_+',
        room: '教室101-ABC',
        teachers: ['老师名称包含空格'],
        courseCode: 'CODE-123_ABC',
      );
      
      await courseStore.addCustomCourse(specialCourse);
      
      expect(courseStore.customCourses, hasLength(1));
      expect(courseStore.customCourses.first.courseName, contains('特殊字符'));
      expect(courseStore.customCourses.first.room, contains('101-ABC'));
    });

    test('should handle boundary values for course properties', () async {
      final boundaryCourse = CourseModel(
        weekday: -1, // Invalid weekday
        startUnit: 0, // Invalid start unit
        endUnit: 10, // High end unit
        credits: '0.0', // Zero credits
        campus: '', // Empty campus
      );
      
      await courseStore.addCustomCourse(boundaryCourse);
      
      expect(courseStore.customCourses, hasLength(1));
      expect(courseStore.customCourses.first.weekday, -1);
      expect(courseStore.customCourses.first.startUnit, 0);
      expect(courseStore.customCourses.first.endUnit, 10);
    });
  });
}