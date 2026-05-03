import 'dart:async' show TimeoutException, unawaited;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/core/utils/animations/animated_card.dart';
import 'package:ios_club_app/core/utils/animations/animated_list_item.dart';
import 'package:ios_club_app/features/education/models/edu_fetch_models.dart';
import 'package:ios_club_app/features/education/services/score_service.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/features/education/models/score_model.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/theme/club_radii.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/loading_state_view.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class ScorePage extends ConsumerStatefulWidget {
  const ScorePage({super.key});

  @override
  ConsumerState<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends ConsumerState<ScorePage>
    with SingleTickerProviderStateMixin {
  final List<ScoreList> _scoreList = [];
  bool _isLoading = true;
  bool _isFool = false;
  String _loadingText = '正在获取数据...';
  final List<ScoreList> _yearList = [];
  bool _isYear = false;

  late PageController pageController = PageController();
  late int _currentIndex = 0;
  final List<String> _selectorList = [];

  static const yearStringList = [
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十'
  ];

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh({bool isRefresh = false}) async {
    if (isRefresh || _isFool) {
      await _loadScores(policy: FetchPolicy.refresh);
      return;
    }

    final localSnapshot =
        await ScoreService.getScores(policy: FetchPolicy.localFirst);
    if (localSnapshot.data.isNotEmpty) {
      _applyScoreData(localSnapshot.data, isLoading: false);
      unawaited(_loadScores(
        policy: FetchPolicy.refresh,
        keepCurrentDataWhileLoading: true,
        showStaleMessage: false,
      ));
      return;
    }

    await _loadScores(policy: FetchPolicy.refresh);
  }

  Future<void> _loadScores({
    required FetchPolicy policy,
    bool keepCurrentDataWhileLoading = false,
    bool showStaleMessage = true,
  }) async {
    if (!mounted) return;

    setState(() {
      _isLoading = !keepCurrentDataWhileLoading;
      _loadingText = '正在获取成绩数据...';
    });

    try {
      final snapshot = await ScoreService.getScores(policy: policy).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('获取成绩数据超时');
        },
      );

      _applyScoreData(snapshot.data, isLoading: false);
      if (!mounted) return;
      if (snapshot.isStale && snapshot.data.isNotEmpty && showStaleMessage) {
        showClubSnackBar(context, const Text('刷新失败，已回退到本地数据'));
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        showClubSnackBar(context, const Text('获取数据超时，请检查网络连接后重试'));
      }
      AppLogger.warning('[ScorePage] 获取数据超时: $e');
    } catch (e, stackTrace) {
      if (mounted) {
        showClubSnackBar(context, Text('获取数据失败: ${e.toString()}'));
      }
      AppLogger.error('[ScorePage] 获取数据失败', error: e, stackTrace: stackTrace);
    } finally {
      _isFool = false;
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _applyScoreData(List<ScoreList> scores, {required bool isLoading}) {
    if (!mounted) return;
    setState(() {
      _scoreList
        ..clear()
        ..addAll(scores);
      _isLoading = isLoading;
      _selectorList
        ..clear()
        ..addAll(_buildSelectorList(scores.length));
    });
  }

  List<String> _buildSelectorList(int count) {
    final selectorList = <String>[];
    for (var i = 0; i < count; i++) {
      final y = count - i + 1;
      selectorList
          .add('大${yearStringList[y ~/ 2 - 1]}${y % 2 == 1 ? '下' : '上'}');
    }
    return selectorList;
  }

  void _handleFoolishMode() {
    final colors = context.clubColors;
    setState(() {
      _isFool = true;
      for (final item in _scoreList) {
        for (final item2 in item.list) {
          item2.grade = '100';
          item2.gpa = '5';
        }
      }
    });

    showClubSnackBar(
      context,
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('是的，在下绩点5.0'),
          Icon(Icons.mood, color: colors.quaternaryLabel),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    // 检查是否为游客模式
    if (!ref.watch(userStoreProvider).isLogin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.warning,
                size: 48,
                color: colors.secondaryLabel,
              ),
              SizedBox(height: 16),
              Text(
                '未登录',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '请先去登录即可查看成绩',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.secondaryLabel,
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // 导航到个人页面进行登录
                  AppRouter.go(AppRoutes.profile);
                },
                child: Text('前往登录'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: LoadingStateView(
            title: _loadingText,
            subtitle: '正在读取缓存并同步教务成绩，网络较慢时可能需要几秒',
          ),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(),
          _buildStatsCard(),
          _buildSelector(),
          Expanded(
            child: _buildScoreList(),
          )
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '成绩与绩点',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _changeScoreList,
                  icon: Icon(_isYear
                      ? Icons.calendar_today_rounded
                      : Icons.calendar_view_day_rounded),
                ),
                if (!_isFool)
                  IconButton(
                    onPressed: _handleFoolishMode,
                    icon: const Icon(Icons.mood),
                  ),
                IconButton(
                  onPressed: () => refresh(isRefresh: true),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
        ));
  }

  void _changeScoreList() {
    setState(() {
      _isYear = !_isYear;
      if (_isYear && _scoreList.isNotEmpty && _yearList.isEmpty) {
        for (var i = _scoreList.length - 1; i >= 0; i--) {
          var j = _scoreList.length - 1 - i;
          if (j % 2 == 0) {
            _yearList.add(ScoreList(
              semester: _scoreList[i].semester,
              list: _scoreList[i].list.toList(),
            ));
          } else {
            var a = _yearList.lastOrNull;
            if (a != null) {
              a.list.addAll(_scoreList[i].list.toList());
            }
          }
        }
      }

      if (_scoreList.isNotEmpty) {
        if (_isYear) {
          _selectorList.clear();
          for (var i = 0; i < _yearList.length; i++) {
            _selectorList.add('大${yearStringList[i]}');
          }
        } else {
          _selectorList.clear();
          for (var i = 0; i < _scoreList.length; i++) {
            var y = _scoreList.length - i + 1;
            _selectorList
                .add('大${yearStringList[y ~/ 2 - 1]}${y % 2 == 1 ? '下' : '上'}');
          }
        }

        if (_currentIndex >= _selectorList.length) {
          _currentIndex = _selectorList.length - 1;
        }
        pageController.jumpToPage(_currentIndex);
      }
    });
  }

  Widget _buildStatsCard() {
    if (_scoreList.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ClubCard(
        child: _buildStatsPadding(),
      ),
    );
  }

  Widget _buildStatsPadding({ScoreList? scoreList}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatItem(
            icon: Icons.credit_score,
            value: scoreList == null
                ? ScoreList.getTotalGpa(_scoreList).toStringAsFixed(2)
                : scoreList.totalGpa.toStringAsFixed(2),
            label: 'GPA',
          ),
          _buildStatItem(
            icon: Icons.library_books,
            value: scoreList == null
                ? ScoreList.getTotalCourse(_scoreList).toString()
                : scoreList.totalCourse.toString(),
            label: '通过课程',
          ),
          InkWell(
            onTap: _showCreditInfoDialog,
            child: _buildStatItem(
              icon: Icons.equalizer,
              value: scoreList == null
                  ? ScoreList.getTotalCredit(_scoreList).toStringAsFixed(1)
                  : scoreList.totalCredit.toStringAsFixed(1),
              label: '总学分',
              withInfo: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    bool withInfo = false,
  }) {
    final colors = context.clubColors;
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (withInfo)
              Icon(
                Icons.info_outline,
                size: 9,
                color: colors.secondaryLabel,
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: colors.secondaryLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCreditInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('说明'),
        content: const Text('这里的学分是按照成绩算出来的，只要没有挂科就OK。教务系统给的一般来说要小于等于这个数'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    if (_selectorList.isEmpty) {
      return Container();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: CupertinoSlidingSegmentedControl<int>(
        proportionalWidth: true,
        groupValue: _currentIndex,
        onValueChanged: (int? value) async {
          if (value != null && value < _selectorList.length) {
            setState(() {
              pageController.jumpToPage(value);
              setState(() {
                _currentIndex = value;
              });
            });
          }
        },
        children: _selectorList
            .map(
              (x) => Text(x),
            )
            .toList()
            .asMap(),
      ),
    );
  }

  Widget _buildScoreList() {
    return _scoreList.isEmpty
        ? _buildEmptyState()
        : _isYear
            ? _buildYearList()
            : _buildSemesterList();
  }

  Widget _buildSemesterList() {
    return PageView.builder(
      controller: pageController,
      onPageChanged: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      itemCount: _scoreList.length,
      itemBuilder: (context, index) => SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: _buildSemesterCard(_scoreList[index]),
      ),
    );
  }

  Widget _buildYearList() {
    return PageView.builder(
        controller: pageController,
        itemCount: _yearList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) => SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _buildYearCard(_yearList[index], index),
            ));
  }

  Widget _buildYearCard(ScoreList score, int index) {
    const yearStringList = ['一', '二', '三', '四', '五', '六', '七', '八', '九', '十'];
    return ClubCard(
        margin: const EdgeInsets.all(16),
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(children: [
              Text('大${yearStringList[index]}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
              _buildStatsPadding(scoreList: score),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: score.list.length,
                itemBuilder: (context, index) => AnimatedListItem(
                  index: index,
                  child: _buildScoreItem(score.list[index]),
                ),
              )
            ])));
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          EmptyWidget(
            title: '没有成绩',
            subtitle: '建议刷新或退出重进',
            icon: Icons.school,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => refresh(isRefresh: true),
            child: const Text('刷新数据'),
          ),
        ],
      ),
    );
  }

  Widget _buildSemesterCard(ScoreList score) {
    final semesterNames = score.semester.name.split('-');
    return AnimatedCard(
      child: ClubCard(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            children: [
              Text(
                '${semesterNames[0]}至${semesterNames[1]}年 第${semesterNames[2]}学期',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: score.list.length,
                itemBuilder: (context, index) => AnimatedListItem(
                  index: index,
                  child: _buildScoreItem(score.list[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreItem(ScoreModel item) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Material(
      borderRadius: ClubRadii.navigation,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: ClubRadii.navigation,
        onTap: () => _showScoreDetails(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: CourseColorManager.generateSoftColor(item.name),
                  borderRadius: ClubRadii.indicatorBorder,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${item.name}${item.isMinor ? ' (辅修)' : ''}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              _buildScoreMeta(item),
                            ]),
                      ),
                      if (isTablet)
                        Expanded(
                          child: Text(
                            item.gradeDetail,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                    ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreMeta(ScoreModel item) {
    final colors = context.clubColors;
    return Wrap(
      spacing: 16,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.time, size: 16, color: colors.secondaryLabel),
            const SizedBox(width: 4),
            Text('${item.credit}学分',
                style: TextStyle(color: colors.secondaryLabel))
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.location,
                size: 16, color: colors.secondaryLabel),
            const SizedBox(width: 4),
            Text('成绩 ${item.grade}',
                style: TextStyle(color: colors.secondaryLabel))
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(CupertinoIcons.star, size: 16, color: colors.secondaryLabel),
            const SizedBox(width: 4),
            Text('绩点 ${item.gpa}',
                style: TextStyle(color: colors.secondaryLabel))
          ],
        ),
      ],
    );
  }

  Future<void> _showScoreDetails(ScoreModel score) async {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final content = _buildScoreDetailsContent(score, isTablet);

    if (isTablet) {
      await showDialog<void>(
        context: context,
        builder: (context) => SimpleDialog(children: [content]),
      );
    } else {
      await showClubModalBottomSheet(context, content);
    }
  }

  Widget _buildScoreDetailsContent(ScoreModel score, bool isTablet) {
    final colors = context.clubColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalHeader(
            title: score.name,
            subtitle: score.isMinor ? '辅修课程' : null,
          ),
          ModalInfoRow(
            icon: CupertinoIcons.star_fill,
            label: '课程学分',
            content: '${score.credit} 学分',
            color: colors.yellow,
          ),
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.chart_bar_fill,
            label: '课程成绩',
            content: score.grade,
            color: colors.danger,
          ),
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.star_circle_fill,
            label: '课程绩点',
            content: score.gpa,
            color: colors.success,
          ),
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.doc_text_fill,
            label: '成绩详情',
            content: score.gradeDetail,
            color: colors.primary,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}
