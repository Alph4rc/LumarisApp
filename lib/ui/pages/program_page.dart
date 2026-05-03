import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/state/program_page_notifier.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class ProgramPage extends ConsumerStatefulWidget {
  const ProgramPage({super.key});

  @override
  ConsumerState<ProgramPage> createState() => _ProgramPageState();
}

class _ProgramPageState extends ConsumerState<ProgramPage>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;
  late final PageController _pageController;
  int _tabLength = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _ensureTabController(int length) {
    if (length == 0 || _tabLength == length) {
      return;
    }
    _tabController?.dispose();
    _tabLength = length;
    _tabController = TabController(length: length, vsync: this);
    _tabController!.addListener(() {
      if (_tabController != null && !_tabController!.indexIsChanging) {
        _pageController.animateToPage(
          _tabController!.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    if (_tabController != null && _tabController!.index != index) {
      _tabController!.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final programState = ref.watch(programControllerProvider);
    final controller = ref.read(programControllerProvider.notifier);
    _ensureTabController(programState.programs.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '培养方案',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: programState.isLoading
                ? null
                : () => controller.refreshPrograms(),
            icon: const Icon(CupertinoIcons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: programState.isLoading ||
                  programState.isError ||
                  programState.programs.isEmpty ||
                  _tabController == null
              ? const SizedBox.shrink()
              : TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.center,
                  tabs: programState.programs.asMap().entries.map((entry) {
                    final program = entry.value;
                    final term = program.term == '特殊分组'
                        ? controller.semesterNames.length - 1
                        : int.parse(program.term) - 1;

                    return Tab(
                      child: Text(controller.semesterNames[term]),
                    );
                  }).toList(),
                ),
        ),
      ),
      body: Builder(builder: (context) {
        final colors = context.clubColors;

        if (programState.isLoading) {
          return const Center(
            child: LoadingStateView(
              title: '正在加载培养方案',
              subtitle: '正在整理学期课程结构和课程类别，请稍等一下',
            ),
          );
        }

        if (programState.isError) {
          return RefreshIndicator(
            onRefresh: controller.refreshPrograms,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.28),
                Column(
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 50,
                      color: colors.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '加载失败',
                      style: TextStyle(
                        fontSize: 17,
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        if (programState.programs.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refreshPrograms,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.28),
                Column(
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      size: 50,
                      color: colors.danger,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '暂无数据',
                      style: TextStyle(
                        fontSize: 17,
                        color: colors.secondaryLabel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return PageView.builder(
          controller: _pageController,
          itemCount: programState.programs.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final program = programState.programs[index];

            return RefreshIndicator(
              onRefresh: controller.refreshPrograms,
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 16.0),
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: program.courses.length +
                    (programState.errorMessage.isNotEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  if (programState.errorMessage.isNotEmpty && index == 0) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: colors.warningSoft,
                        borderRadius: ClubRadii.panel,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.info_circle,
                            color: colors.warning,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '刷新失败，当前展示的是上次同步的培养方案',
                              style: TextStyle(
                                fontSize: 13,
                                color: colors.secondaryLabel,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final courseIndex =
                      programState.errorMessage.isNotEmpty ? index - 1 : index;
                  final course = program.courses[courseIndex];
                  final courseColor = CourseColorManager.generateSoftColor(
                    course.courseTypeName,
                  );

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: courseColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colors.label,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                course.courseTypeName,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: colors.secondaryLabel,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                            '${course.credits} 学分',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: courseColor,
                            ),
                          ),
                        ),
                      ],
                    ),
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
