import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/course_html_parser.dart';

void main() {
  group('CourseHtmlParser', () {
    test('should_map_monday_first_columns_to_datetime_weekday_values', () {
      final html = '''
<div class="course-table">
  <div class="time-table-body">
    <div class="columns weekday">
      <div class="card-view">
        <div class="card-content-code">MATH101</div>
        <div class="card-content-info">
          高等数学
          教一101
          (1~2周)
          (1,2节)
        </div>
      </div>
    </div>
    <div class="columns weekday"></div>
    <div class="columns weekday"></div>
    <div class="columns weekday"></div>
    <div class="columns weekday"></div>
    <div class="columns weekday"></div>
    <div class="columns weekday">
      <div class="card-view">
        <div class="card-content-code">ENG201</div>
        <div class="card-content-info">
          大学英语
          教二202
          (3周)
          (3,4节)
        </div>
      </div>
    </div>
  </div>
</div>
''';

      final courses = CourseHtmlParser.parseHtml(html);

      expect(courses, hasLength(2));
      expect(courses.first.weekday, DateTime.monday);
      expect(courses.last.weekday, DateTime.sunday);
    });
  });
}
