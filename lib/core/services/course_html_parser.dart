import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';

class CourseHtmlParser {
  static int _weekdayFromColumnIndex(int index) {
    // Imported timetable columns are Monday-first; CourseModel uses
    // DateTime.weekday.
    return index + 1;
  }

  static String _cleanText(String? text) {
    if (text == null || text.isEmpty) {
      return '';
    }

    var result = text.replaceAll('\u00A0', ' ');
    result = result.replaceAll(RegExp(r'\s+'), ' ');
    return result.trim();
  }

  static List<int> _parseWeekIndexes(String? weeksText) {
    if (weeksText == null || weeksText.isEmpty) {
      return [];
    }

    final text = weeksText.replaceAll('周', '').trim();
    final result = <int>[];

    for (final rawPart in text.split(',')) {
      final part = rawPart.trim();
      if (part.isEmpty) {
        continue;
      }

      if (part.contains('~')) {
        final pieces = part.split('~');
        if (pieces.length >= 2) {
          final start = int.tryParse(pieces[0].trim());
          final end = int.tryParse(pieces[1].trim());
          if (start != null && end != null) {
            for (var i = start; i <= end; i++) {
              result.add(i);
            }
          }
        }
      } else {
        final value = int.tryParse(part);
        if (value != null) {
          result.add(value);
        }
      }
    }

    result.sort();
    return result;
  }

  static ({int startUnit, int endUnit}) _parseTimeUnits(String? timeText) {
    if (timeText == null || timeText.isEmpty) {
      return (startUnit: 0, endUnit: 0);
    }

    var text = timeText.trim();

    if (text.contains('节')) {
      text = text.replaceAll('节', '').trim();
      final parts = text
          .split(',')
          .map((e) => e.trim())
          .where((e) => RegExp(r'^\d+$').hasMatch(e))
          .toList();

      if (parts.isNotEmpty) {
        final nums = parts.map(int.parse).toList();
        return (startUnit: nums.first, endUnit: nums.last);
      }
    }

    return (startUnit: 0, endUnit: 0);
  }

  static CourseModel parseCard(Element card, int weekdayIdx) {
    final codeNode = card.querySelector('.card-content-code');
    final code = codeNode != null ? _cleanText(codeNode.text) : '';

    final infoNode = card.querySelector('.card-content-info');

    final rawLines = <String>[];
    var rawText = '';

    if (infoNode != null) {
      rawText = infoNode.text.replaceAll('\u00A0', ' ');
      rawLines.addAll(
        rawText
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty),
      );
    }

    final courseName = rawLines.isNotEmpty ? rawLines[0] : '';

    var room = '';
    for (final line in rawLines.skip(1)) {
      if (!line.startsWith('(') &&
          !line.contains('上课组') &&
          !line.contains('人数')) {
        room = line;
        break;
      }
    }

    final parenMatches = RegExp(r'\(([^()]*)\)')
        .allMatches(rawText)
        .map((match) => _cleanText(match.group(1)))
        .where((item) => item.isNotEmpty)
        .toList();

    var weeksText = '';
    var timeText = '';

    for (final item in parenMatches) {
      if (item.contains('周') && weeksText.isEmpty) {
        weeksText = item;
      } else if ((item.contains('节') || item.contains('~')) &&
          timeText.isEmpty) {
        timeText = item;
      }
    }

    final weekIndexes = _parseWeekIndexes(weeksText);
    final timeUnits = _parseTimeUnits(timeText);

    return CourseModel(
      weekday: weekdayIdx,
      courseCode: code,
      courseName: courseName,
      room: room,
      weekIndexes: weekIndexes,
      startUnit: timeUnits.startUnit,
      endUnit: timeUnits.endUnit,
      teachers: <String>[],
      credits: '',
      lessonId: '',
      campus: '',
      isCustom: false,
    );
  }

  static List<CourseModel> parseHtml(String html) {
    final document = html_parser.parse(html);
    final columns = document
        .querySelectorAll('.course-table .time-table-body > .columns.weekday');

    final courses = <CourseModel>[];

    for (var index = 0; index < columns.length; index++) {
      final col = columns[index];
      final cards = col.querySelectorAll('.card-view');

      for (final card in cards) {
        courses.add(parseCard(card, _weekdayFromColumnIndex(index)));
      }
    }

    return courses;
  }
}
