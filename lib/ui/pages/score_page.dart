import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/models/semester_model.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/core/utils/animations/animated_card.dart';
import 'package:ios_club_app/core/utils/animations/animated_list_item.dart';
import 'package:ios_club_app/features/education/services/edu_api_client.dart';
import 'package:ios_club_app/features/education/services/edu_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:ios_club_app/core/services/prefs_service.dart';

import 'package:ios_club_app/core/models/score_model.dart';
import 'package:ios_club_app/core/services/data_service.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/components/empty_widget.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';
import 'package:ios_club_app/ui/components/modal_components.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({super.key});

  @override
  State<ScorePage> createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage>
    with SingleTickerProviderStateMixin {
  final UserStore userStore = Get.find();
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
    if (!isRefresh && !_isFool) {
      final cachedData = await _tryGetCachedData();
      if (cachedData != null) {
        if (mounted) {
          setState(() {
            _scoreList
              ..clear()
              ..addAll(cachedData);
            _selectorList.clear();
            for (var i = 0; i < _scoreList.length; i++) {
              var y = _scoreList.length - i + 1;
              _selectorList.add(
                  '大${yearStringList[y ~/ 2 - 1]}${y % 2 == 1 ? '下' : '上'}');
            }
            _isLoading = false;
          });
        }
        return;
      }
    }

    if (_isFool) {
      final cachedData = await _tryGetCachedData();
      if (cachedData != null) {
        if (mounted) {
          setState(() {
            _scoreList
              ..clear()
              ..addAll(cachedData);
            _isLoading = false;
            _isFool = false;
          });
        }
        return;
      }
    }

    await _fetchFreshData(isRefresh: isRefresh);
  }

  Future<List<ScoreList>?> _tryGetCachedData() async {
    final prefs = PrefsService.instance;
    final jsonString = prefs.getString(PrefsKeys.ALL_SCORE_DATA);
    final lastFetchTime = prefs.getInt(PrefsKeys.LAST_SCORE_TIME);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastFetchTime != null &&
        now - lastFetchTime < const Duration(hours: 1).inMilliseconds &&
        jsonString != null &&
        jsonString.isNotEmpty) {
      try {
        final jsonList = jsonDecode(jsonString) as List<dynamic>;
        return jsonList.map((value) => ScoreList.fromJson(value)).toList();
      } catch (e) {
        if (kDebugMode) {
          AppLogger.error('Error parsing cached data: $e');
        }
      }
    }
    return null;
  }

  Future<void> _fetchFreshData({required bool isRefresh}) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      AppLogger.debug('[ScorePage] 开始获取成绩数据');

      // 添加超时保护：获取用户数据最多5秒
      final cookieData = await EduService.getUserData().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          AppLogger.warning('[ScorePage] 获取用户数据超时');
          return null;
        },
      );

      if (cookieData == null) {
        if (mounted) {
          showClubSnackBar(context, const Text('获取用户凭证失败，请重新登录'));
        }
        return;
      }

      setState(() {
        _loadingText = '正在获取所有学期数据...';
      });

      // 添加超时保护：获取学期列表最多10秒
      final semesters =
          await DataService.getSemester(isRefresh: isRefresh).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning('[ScorePage] 获取学期列表超时');
          return <SemesterModel>[];
        },
      );

      final freshScoreList = <ScoreList>[];
      for (final semester in semesters) {
        if (!mounted) break;

        setState(() {
          _loadingText = '正在获取 ${semester.name} 学期数据...';
        });

        AppLogger.debug('[ScorePage] 获取学期 ${semester.name} 的成绩');

        // 添加超时保护：每个学期最多10秒
        final semesterScores = await _fetchSemesterScores(
          studentId: cookieData.studentId,
          semester: semester,
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            AppLogger.warning('[ScorePage] 获取学期 ${semester.name} 超时');
            return null;
          },
        );

        if (semesterScores != null) {
          freshScoreList.add(semesterScores);
        }
      }

      await _cacheFreshData(freshScoreList);

      if (mounted) {
        setState(() {
          _scoreList
            ..clear()
            ..addAll(freshScoreList);
          _isLoading = false;
          _selectorList.clear();
          for (var i = 0; i < _scoreList.length; i++) {
            var y = _scoreList.length - i + 1;
            _selectorList
                .add('大${yearStringList[y ~/ 2 - 1]}${y % 2 == 1 ? '下' : '上'}');
          }
        });
      }

      AppLogger.debug('[ScorePage] 成绩数据获取完成');
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
      // ✅ 确保 _isLoading 总是被设置为 false
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      AppLogger.debug('[ScorePage] 设置 _isLoading = false');
    }
  }

  /// 使用统一的 EduApiClient 获取学期成绩
  /// EduHttpClient 已内置缓存、认证和重登录机制
  Future<ScoreList?> _fetchSemesterScores({
    required String studentId,
    required SemesterModel semester,
  }) async {
    try {
      final response =
          await EduApiClient.getScore(studentId, semester.semester);
      final list = jsonDecode(response) as List;
      return ScoreList(
        semester: semester,
        list: list.map((e) => ScoreModel.fromJson(e)).toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching semester scores: $e');
      }
      return null;
    }
  }

  Future<void> _cacheFreshData(List<ScoreList> freshData) async {
    final prefs = PrefsService.instance;
    await prefs.setString(PrefsKeys.ALL_SCORE_DATA, jsonEncode(freshData));
    await prefs.setInt(
        PrefsKeys.LAST_SCORE_TIME, DateTime.now().millisecondsSinceEpoch);
  }

  void _handleFoolishMode() {
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
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('是的，在下绩点5.0'),
          Icon(Icons.mood, color: Colors.black12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 检查是否为游客模式
    if (!userStore.isLogin) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                size: 48,
                color: CupertinoColors.systemGrey,
              ),
              const SizedBox(height: 16),
              const Text(
                '未登录',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '请先去登录即可查看成绩',
                style: TextStyle(
                  fontSize: 16,
                  color: CupertinoColors.systemGrey.resolveFrom(context),
                ),
              ),
              const SizedBox(height: 24),
              CupertinoButton.filled(
                onPressed: () {
                  // 导航到个人页面进行登录
                  Get.toNamed('/Profile');
                },
                child: const Text('前往登录'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CupertinoActivityIndicator(radius: 16),
            const SizedBox(height: 16),
            Text(
              _loadingText,
              style: TextStyle(
                fontSize: 16,
                color: CupertinoColors.secondaryLabel.resolveFrom(context),
              ),
            )
          ],
        )),
      );
    }

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(),
            _buildStatsCard(),
            _buildSelector(),
            Expanded(
              child: _buildScoreList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            '成绩与绩点',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              fontFamily: '.SF Pro Display',
            ),
          ),
          Row(
            children: [
              _buildIconButton(
                onPressed: _changeScoreList,
                icon: _isYear
                    ? CupertinoIcons.calendar
                    : CupertinoIcons.list_bullet,
              ),
              if (!_isFool)
                _buildIconButton(
                  onPressed: _handleFoolishMode,
                  icon: CupertinoIcons.smiley,
                ),
              _buildIconButton(
                onPressed: () => refresh(isRefresh: true),
                icon: CupertinoIcons.refresh,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      {required VoidCallback onPressed, required IconData icon}) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(
        icon,
        size: 24,
        color: CupertinoColors.activeBlue.resolveFrom(context),
      ),
    );
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
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.secondarySystemGroupedBackground
              .resolveFrom(context),
          borderRadius: BorderRadius.circular(12),
        ),
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
            icon: CupertinoIcons.graph_circle,
            value: scoreList == null
                ? ScoreList.getTotalGpa(_scoreList).toStringAsFixed(2)
                : scoreList.totalGpa.toStringAsFixed(2),
            label: 'GPA',
            color: CupertinoColors.systemIndigo,
          ),
          Container(
            width: 1,
            height: 40,
            color: CupertinoColors.separator.resolveFrom(context),
          ),
          _buildStatItem(
            icon: CupertinoIcons.book,
            value: scoreList == null
                ? ScoreList.getTotalCourse(_scoreList).toString()
                : scoreList.totalCourse.toString(),
            label: '通过课程',
            color: CupertinoColors.systemOrange,
          ),
          Container(
            width: 1,
            height: 40,
            color: CupertinoColors.separator.resolveFrom(context),
          ),
          GestureDetector(
            onTap: _showCreditInfoDialog,
            child: _buildStatItem(
              icon: CupertinoIcons.chart_bar,
              value: scoreList == null
                  ? ScoreList.getTotalCredit(_scoreList).toStringAsFixed(1)
                  : scoreList.totalCredit.toStringAsFixed(1),
              label: '总学分',
              color: CupertinoColors.systemPink,
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
    required Color color,
    bool withInfo = false,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 28,
          color: CupertinoDynamicColor.resolve(color, context),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                CupertinoDynamicColor.resolve(CupertinoColors.label, context),
            letterSpacing: -0.5,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
              ),
            ),
            if (withInfo) ...[
              const SizedBox(width: 2),
              Icon(
                CupertinoIcons.info_circle,
                size: 10,
                color: CupertinoDynamicColor.resolve(
                    CupertinoColors.secondaryLabel, context),
              ),
            ],
          ],
        ),
      ],
    );
  }

  void _showCreditInfoDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('说明'),
        content: const Text('这里的学分是按照成绩算出来的，只要没有挂科就OK。教务系统给的一般来说要小于等于这个数'),
        actions: [
          CupertinoDialogAction(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: CupertinoSlidingSegmentedControl<int>(
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
              (x) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  x,
                  style: TextStyle(
                    fontSize: 13,
                  ),
                ),
              ),
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
        padding: const EdgeInsets.only(bottom: 24),
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
              padding: const EdgeInsets.only(bottom: 24),
              child: _buildYearCard(_yearList[index], index),
            ));
  }

  Widget _buildYearCard(ScoreList score, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
            child: Text(
              '大${yearStringList[index]}学年',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.label.resolveFrom(context),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: CupertinoColors.secondarySystemGroupedBackground
                  .resolveFrom(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildStatsPadding(scoreList: score),
                const Divider(height: 1, indent: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: score.list.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    indent: 60,
                    color: CupertinoColors.separator.resolveFrom(context),
                  ),
                  itemBuilder: (context, index) => AnimatedListItem(
                    index: index,
                    child: _buildScoreItem(score.list[index]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          EmptyWidget(
            title: '没有成绩',
            subtitle: '建议刷新或退出重进',
            icon: CupertinoIcons.book,
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Text(
                '${semesterNames[0]} - ${semesterNames[1]} 学年',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: CupertinoDynamicColor.resolve(
                      CupertinoColors.secondaryLabel, context),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: CupertinoColors.secondarySystemGroupedBackground
                    .resolveFrom(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: score.list.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  indent: 60,
                  color: CupertinoColors.separator.resolveFrom(context),
                ),
                itemBuilder: (context, index) => AnimatedListItem(
                  index: index,
                  child: _buildScoreItem(score.list[index]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0, top: 8.0),
              child: Text(
                '第 ${semesterNames[2]} 学期',
                style: TextStyle(
                  fontSize: 13,
                  color: CupertinoColors.tertiaryLabel.resolveFrom(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreItem(ScoreModel item) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return GestureDetector(
      onTap: () => _showScoreDetails(item),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: CourseColorManager.generateSoftColor(item.name)
                    .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  item.name.isNotEmpty ? item.name.substring(0, 1) : '',
                  style: TextStyle(
                    color: CourseColorManager.generateSoftColor(item.name),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${item.name}${item.isMinor ? ' (辅修)' : ''}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.label.resolveFrom(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.credit}学分',
                    style: TextStyle(
                      fontSize: 13,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.grade,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: CupertinoDynamicColor.resolve(
                        _getGradeColor(item.grade), context),
                  ),
                ),
                if (item.gpa.isNotEmpty && item.gpa != '0')
                  Text(
                    'GPA: ${item.gpa}',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          CupertinoColors.secondaryLabel.resolveFrom(context),
                    ),
                  ),
              ],
            ),
            if (isTablet) ...[
              const SizedBox(width: 16),
              SizedBox(
                width: 100,
                child: Text(
                  item.gradeDetail,
                  style: TextStyle(
                    color: CupertinoColors.secondaryLabel.resolveFrom(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
            const SizedBox(width: 8),
            Icon(
              CupertinoIcons.chevron_forward,
              size: 16,
              color: CupertinoColors.tertiaryLabel.resolveFrom(context),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    final double? score = double.tryParse(grade);
    if (score != null) {
      if (score >= 90) return CupertinoColors.systemGreen;
      if (score >= 80) return CupertinoColors.systemBlue;
      if (score >= 60) return CupertinoColors.systemOrange;
      return CupertinoColors.systemRed;
    }
    // 非数字成绩
    if (grade == '优秀' || grade == 'A') return CupertinoColors.systemGreen;
    if (grade == '良好' || grade == 'B') return CupertinoColors.systemBlue;
    if (grade == '及格' || grade == 'C') return CupertinoColors.systemOrange;
    return CupertinoColors.label.resolveFrom(context);
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
            color: const Color(0xFFFFCC00),
          ),
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.chart_bar_fill,
            label: '课程成绩',
            content: score.grade,
            color: const Color(0xFFFF3B30),
          ),
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.star_circle_fill,
            label: '课程绩点',
            content: score.gpa,
            color: const Color(0xFF34C759),
          ),
          const ModalSpacing(),
          ModalInfoRow(
            icon: CupertinoIcons.doc_text_fill,
            label: '成绩详情',
            content: score.gradeDetail,
            color: const Color(0xFF007AFF),
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}
