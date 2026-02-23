import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late CourseStore courseStore;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await PrefsService.init();
  });

  setUp(() {
    courseStore = CourseStore();
  });

  group('CourseStore', () {
    test('should_initialize_with_empty_lists', () {
      expect(courseStore.courses, isEmpty);
      expect(courseStore.ignoreCourses, isEmpty);
    });

    test('should_set_ignore_courses_in_bulk', () {
      courseStore.setIgnoreCourses(['数学', '英语']);

      expect(courseStore.ignoreCourses, hasLength(2));
      expect(courseStore.ignoreCourses, containsAll(['数学', '英语']));
    });

    test('should_add_single_ignore_course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.addIgnoreCourse('英语');

      expect(courseStore.ignoreCourses, hasLength(2));
      expect(courseStore.ignoreCourses, containsAll(['数学', '英语']));
    });

    test('should_not_add_duplicate_ignore_course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await courseStore.addIgnoreCourse('数学');

      expect(courseStore.ignoreCourses, hasLength(1));
    });

    test('should_remove_ignore_course', () async {
      courseStore.setIgnoreCourses(['数学', '英语']);
      await courseStore.removeIgnoreCourse('数学');

      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('英语'));
      expect(courseStore.ignoreCourses, isNot(contains('数学')));
    });

    test('should_not_throw_when_removing_non_existent_course', () async {
      courseStore.setIgnoreCourses(['数学']);
      await expectLater(courseStore.removeIgnoreCourse('英语'), completes);
      expect(courseStore.ignoreCourses, hasLength(1));
    });

    test('should_clear_course_data_without_throwing', () {
      expect(() => courseStore.clearCourseData(), returnsNormally);
    });

    test('should_expose_ignoreCoursesList_as_reactive_list', () {
      expect(courseStore.ignoreCoursesList, isA<List<String>>());
    });

    test('should_add_to_empty_ignore_list', () async {
      await courseStore.addIgnoreCourse('新课程');

      expect(courseStore.ignoreCourses, hasLength(1));
      expect(courseStore.ignoreCourses, contains('新课程'));
    });

    test('should_handle_large_ignore_course_list', () async {
      final largeList = List.generate(100, (i) => '课程$i');
      courseStore.setIgnoreCourses(largeList);
      expect(courseStore.ignoreCourses, hasLength(100));

      await courseStore.addIgnoreCourse('新课程');
      expect(courseStore.ignoreCourses, hasLength(101));

      await courseStore.removeIgnoreCourse('课程50');
      expect(courseStore.ignoreCourses, hasLength(100));
      expect(courseStore.ignoreCourses, isNot(contains('课程50')));
    });

    test('should_clear_courses_from_memory', () {
      courseStore.clearCourseData();
      expect(courseStore.courses, isEmpty);
    });
  });
}
