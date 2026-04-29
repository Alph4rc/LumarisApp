import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/features/education/models/exam_result.dart';
import 'package:ios_club_app/core/utils/animations/animations.dart';
import 'package:ios_club_app/features/education/services/exam_service.dart';

import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';

class ExamCard extends StatefulWidget {
  const ExamCard({super.key});

  @override
  State<StatefulWidget> createState() => _ExamCardState();
}

class _ExamCardState extends State<ExamCard> {
  List<ExamData> examItems = [];
  bool isLoading = true;
  String? errorMessage;
  bool isNetworkError = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    ExamService.getExamResult().then((result) => setExam(result));
  }

  void setExam(ExamResult result) {
    setState(() {
      if (result.isSuccess) {
        examItems = result.exams
            .map((course) => ExamData(
                  title: course.name,
                  time: course.examTime,
                  location: course.room,
                  color: CourseColorManager.generateSoftColor(course),
                  seat: course.seatNo,
                ))
            .toList();
        errorMessage = null;
        isNetworkError = false;
      } else {
        examItems = [];
        errorMessage = result.errorMessage;
        isNetworkError = result.isNetworkError;
      }
      isLoading = false;
    });
  }

  Future<void> getExam() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    final result = await ExamService.getExamResult(isRefresh: true);
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
      return AnimatedCard(
        child: ShimmerLoading(
          isLoading: true,
          skeleton: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const SkeletonBox(width: 4, height: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLine(width: 120, height: 14),
                          const SizedBox(height: 6),
                          SkeletonLine(width: 80, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const SkeletonBox(width: 4, height: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonLine(width: 100, height: 14),
                          const SizedBox(height: 6),
                          SkeletonLine(width: 90, height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          child: const ClubCard(
            child: LoadingStateView(
              title: '正在加载考试信息',
              subtitle: '正在同步近期考试安排、考场和座位信息',
              compact: true,
              padding: EdgeInsets.all(20),
            ),
          ),
        ),
      );
    }

    // 显示错误信息
    if (errorMessage != null) {
      return AnimatedCard(
        child: ClubCard(
          padding: const EdgeInsets.all(20),
          child: EmptyWidget(
            title: isNetworkError ? '网络连接失败' : '加载失败',
            subtitle: errorMessage!,
            icon: isNetworkError
                ? CupertinoIcons.wifi_slash
                : CupertinoIcons.exclamationmark_triangle,
          ),
        ),
      );
    }

    final screenWidth = MediaQuery.of(context).size.width;
    // 判断是否为平板布局（宽度大于600）
    final isTablet = screenWidth > 600;

    return examItems.isEmpty
        ? AnimatedCard(
            child: const ClubCard(
              padding: EdgeInsets.all(20),
              child: EmptyWidget(
                title: '最近没有考试',
                subtitle: '说不定刷新一下就有了',
                icon: CupertinoIcons.hourglass,
              ),
            ),
          )
        : AnimatedCard(
            child: ClubCard(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: examItems.length,
                itemBuilder: (context, index) {
                  final exam = examItems[index];

                  return AnimatedListItem(
                    index: index,
                    child: Material(
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
                    ),
                  );
                },
              ),
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
