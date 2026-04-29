import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/controllers/program_controller.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/ui/components/club_radii.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/controllers/program_controller.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';

class ProgramPage extends StatefulWidget {
  const ProgramPage({super.key});

  @override
  State<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  final ScrollController _scrollController = ScrollController();
  final ProgramController controller = Get.put(ProgramController());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: ClubAppBar(
        title: '培养方案',
        scrollController: _scrollController,
        actions: [
          Obx(
            () => IconButton(
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.refreshPrograms(),
              icon: const Icon(CupertinoIcons.refresh),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kTextTabBarHeight),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const SizedBox.shrink();
            }

            if (controller.isError.value) {
              return const SizedBox.shrink();
            }

            if (controller.programs.isEmpty) {
              return const SizedBox.shrink();
            }

            // 确保监听器只添加一次
            controller.addTabListenerIfNeeded();

            return TabBar(
              controller: controller.tabController,
              isScrollable: true,
              tabs: controller.programs.asMap().entries.map((entry) {
                final program = entry.value;
                final term = program.term == "特殊分组"
                    ? controller.semesterNames.length - 1
                    : int.parse(program.term) - 1;

                return Tab(
                  child: Text(
                    controller.semesterNames[term],
                  ),
                );
              }).toList(),
              tabAlignment: TabAlignment.start,
              dividerColor: Colors.transparent,
            );
          }),
        ),
      ),
      body: Obx(() {
        // 获取当前主题模式
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        if (controller.isLoading.value) {
          return const Center(
            child: LoadingStateView(
              title: '正在加载培养方案',
              subtitle: '正在整理学期课程结构和课程类别，请稍等一下',
            ),
          );
        }

        if (controller.isError.value) {
          return RefreshIndicator(
            onRefresh: controller.refreshPrograms,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + kTextTabBarHeight + MediaQuery.sizeOf(context).height * 0.2),
                Column(
                  children: [
                    Icon(CupertinoIcons.exclamationmark_circle,
                        size: 50, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 17,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (controller.programs.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshPrograms,
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight + kTextTabBarHeight + MediaQuery.sizeOf(context).height * 0.2),
                Column(
                  children: [
                    Icon(CupertinoIcons.exclamationmark_circle,
                        size: 50, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      '暂无数据',
                      style: TextStyle(
                        fontSize: 17,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return PageView.builder(
          controller: controller.pageController,
          itemCount: controller.programs.length,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (context, index) {
            final program = controller.programs[index];

            return RefreshIndicator(
              onRefresh: controller.refreshPrograms,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight + kTextTabBarHeight + 16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: program.courses.length,
                itemBuilder: (context, index) {
                  final course = program.courses[index];
                  final courseColor = CourseColorManager.generateSoftColor(
                      course.courseTypeName);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 12.0),
                        child: Row(
                          children: [
                            // 课程类型指示器
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: courseColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 课程信息
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    course.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    course.courseTypeName,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 学分展示
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              decoration: BoxDecoration(
                                color: courseColor.withValues(alpha: 0.15),
                                borderRadius: ClubRadii.control,
                              ),
                              child: Text(
                                "${course.credits} 学分",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: courseColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
