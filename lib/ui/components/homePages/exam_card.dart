import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/core/models/exam_model.dart';
import 'package:ios_club_app/core/services/exam_service.dart';

import '../club_card.dart';
import '../club_modal_bottom_sheet.dart';
import '../empty_widget.dart';
import '../modal_components.dart';

class ExamCard extends StatefulWidget {
  const ExamCard({super.key});

  @override
  State<StatefulWidget> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  List<ExamData> examItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    ExamService.getExam().then((result) => setExam(result));
  }

  void setExam(List<ExamItem> result) {
    setState(() {
      examItems = result
          .map((course) => ExamData(
                title: course.name,
                time: course.examTime,
                location: course.room,
                color: CourseColorManager.generateSoftColor(course),
                seat: course.seatNo,
              ))
          .toList();
      isLoading = false;
    });
  }

  Future<void> getExam() async {
    setState(() {
      isLoading = true;
    });
    final result = await ExamService.getExam(isRefresh: true);
    setExam(result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '近期考试',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await getExam();
                  },
                  icon: const Icon(
                    CupertinoIcons.refresh,
                    size: 22,
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),
            examCard()
          ],
        ));
    
  }

  Widget examWrap(ExamData exam) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.clock,
              size: 16,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
            const SizedBox(width: 6),
            Text(
              exam.time,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        if (exam.location.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.placemark,
                size: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                exam.location,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        if (exam.seat.isNotEmpty)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                CupertinoIcons.calendar,
                size: 16,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                '座位号 ${exam.seat}',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.white60 : Colors.black54,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget examCard() {
    if (isLoading) {
      return const ClubCard(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(height: 16),
            Text(
              '正在加载考试信息...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return examItems.isEmpty
        ? const ClubCard(
            padding: EdgeInsets.all(20),
            child: EmptyWidget(
              title: '最近没有考试',
              subtitle: '说不定刷新一下就有了',
              icon: CupertinoIcons.hourglass,
            ),
          )
        : ClubCard(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: examItems.length,
              itemBuilder: (context, index) {
                final exam = examItems[index];

                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  child: InkWell(
                    onTap: () {
                      if (isTablet) {
                        showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                                  content: _buildExamTip(exam),
                                ));
                      } else {
                        showClubModalBottomSheet(
                          context,
                          _buildExamTip(exam),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          Container(
                            width: 5,
                            height: isTablet ? 42 : 52,
                            decoration: BoxDecoration(
                              color: exam.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  exam.title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: examWrap(exam),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
  }

  Widget _buildExamTip(ExamData exam) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ModalHeader(title: exam.title),
        ModalInfoRow(
          icon: CupertinoIcons.clock,
          label: '考试时间',
          content: exam.time,
          color: const Color(0xFF34C759),
        ),
        if (exam.location.isNotEmpty) ...[
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.placemark,
            label: '考试地点',
            content: exam.location,
            color: const Color(0xFFFF9500),
          ),
        ],
        if (exam.seat.isNotEmpty) ...[
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.calendar,
            label: '座位号',
            content: exam.seat,
            color: const Color(0xFFFF3B30),
          ),
        ],
      ],
    );
  }
}

class ExamData {
  final String title;
  final String time;
  final String location;
  final Color color;
  final String seat;

  ExamData({
    required this.title,
    required this.time,
    required this.location,
    required this.color,
    required this.seat,
  });
}
