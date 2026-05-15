import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/services/course_html_parser.dart';
import 'package:ios_club_app/features/education/models/course_model.dart';
import 'package:ios_club_app/state/course_store.dart';
import 'package:ios_club_app/state/schedule_store.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

class HtmlImportPage extends ConsumerStatefulWidget {
  const HtmlImportPage({super.key});

  @override
  ConsumerState<HtmlImportPage> createState() => _HtmlImportPageState();
}

class _HtmlImportPageState extends ConsumerState<HtmlImportPage> {
  final _controller = TextEditingController();
  List<CourseModel>? _parsedCourses;
  bool _isParsing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _parseHtml() {
    final html = _controller.text.trim();
    if (html.isEmpty) {
      showClubSnackBar(context, Text(context.l10n.pasteHtmlHint));
      return;
    }

    setState(() => _isParsing = true);

    try {
      final courses = CourseHtmlParser.parseHtml(html);
      setState(() {
        _parsedCourses = courses;
        _isParsing = false;
      });
    } catch (e) {
      setState(() => _isParsing = false);
      showClubSnackBar(context, Text('${context.l10n.noCoursesParsed}: $e'));
    }
  }

  Future<void> _importCourses() async {
    if (_parsedCourses == null || _parsedCourses!.isEmpty) return;

    await ref
        .read(courseStoreProvider.notifier)
        .saveGuestCourses(_parsedCourses!);
    ref.read(scheduleStoreProvider.notifier).loadGuestCourseData();

    if (mounted) {
      showClubSnackBar(
        context,
        Text(
          '${context.l10n.importCourses} ${_parsedCourses!.length} ${context.l10n.schedulePage}',
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;

    return Scaffold(
      appBar: ClubAppBar(title: l10n.htmlImport),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: l10n.pasteHtmlHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.groupedBackground,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isParsing ? null : _parseHtml,
                icon: const Icon(Icons.search),
                label: Text(l10n.parseAndPreview),
              ),
            ),
          ),
          if (_parsedCourses != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${l10n.parseResult} (${_parsedCourses!.length})',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: colors.label,
                  ),
                ),
              ),
            ),
            if (_parsedCourses!.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.noCoursesParsed,
                  style: TextStyle(color: colors.secondaryLabel),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _parsedCourses!.length,
                  itemBuilder: (context, index) {
                    final course = _parsedCourses![index];
                    return _buildCourseCard(course, colors);
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      _parsedCourses!.isNotEmpty ? _importCourses : null,
                  icon: const Icon(Icons.download),
                  label: Text(l10n.importCourses),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCourseCard(CourseModel course, dynamic colors) {
    final weekStr = CourseModel.formatWeekRanges(course.weekIndexes);
    const weekdayNames = ['一', '二', '三', '四', '五', '六', '日'];
    final weekday =
        course.weekday < weekdayNames.length ? weekdayNames[course.weekday] : '?';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              course.courseName,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            if (course.courseCode.isNotEmpty)
              Text(
                course.courseCode,
                style: TextStyle(fontSize: 13, color: colors.secondaryLabel),
              ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              children: [
                if (course.room.isNotEmpty)
                  Text(
                    '地点: ${course.room}',
                    style:
                        TextStyle(fontSize: 13, color: colors.secondaryLabel),
                  ),
                Text(
                  '周$weekday',
                  style: TextStyle(fontSize: 13, color: colors.secondaryLabel),
                ),
                if (course.startUnit > 0)
                  Text(
                    '第${course.startUnit}-${course.endUnit}节',
                    style:
                        TextStyle(fontSize: 13, color: colors.secondaryLabel),
                  ),
              ],
            ),
            if (weekStr.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '周次: $weekStr',
                  style:
                      TextStyle(fontSize: 12, color: colors.tertiaryLabel),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
