import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:ios_club_app/core/models/semester_model.dart';
import 'package:ios_club_app/core/models/course_color_manager.dart';
import 'package:ios_club_app/features/education/services/edu_service.dart';
import 'package:ios_club_app/state/prefs_keys.dart';
import 'package:ios_club_app/state/user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ios_club_app/core/models/score_model.dart';
import 'package:ios_club_app/core/models/user_data.dart';
import 'package:ios_club_app/core/services/data_service.dart';
import 'package:ios_club_app/ui/components/club_modal_bottom_sheet.dart';
import 'package:ios_club_app/ui/components/show_club_snack_bar.dart';

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

  // 主题颜色辅助方法 - iOS 原生风格
  bool get _isDarkMode => Theme.of(context).brightness == Brightness.dark;

  // 背景色 - 参考 schedule_list_page
  Color get _backgroundColor => _isDarkMode ? Colors.black : Colors.grey[50]!;

  // iOS 原生卡片背景色
  Color get _cardColor => _isDarkMode
      ? CupertinoColors.systemGrey6.darkColor
      : CupertinoColors.white;

  // iOS 原生文本颜色
  Color get _primaryTextColor =>
      _isDarkMode ? CupertinoColors.white : CupertinoColors.black;

  Color get _secondaryTextColor => CupertinoColors.systemGrey;

  // iOS 原生分隔线颜色
  Color get _separatorColor => _isDarkMode
      ? CupertinoColors.separator.darkColor
      : CupertinoColors.separator;

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
    final prefs = await SharedPreferences.getInstance();
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
          print('Error parsing cached data: $e');
        }
      }
    }
    return null;
  }

  Future<void> _fetchFreshData({required bool isRefresh}) async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final cookieData = await EduService.getUserData();
      if (cookieData == null) {
        if (mounted) {
          showClubSnackBar(context, Text('获取用户凭证失败，请重新登录'));
        }
        return;
      }

      final headers = _buildHeaders(cookieData);
      setState(() {
        _loadingText = '正在获取所有学期数据...';
      });
      final semesters = await DataService.getSemester(isRefresh: isRefresh);

      final freshScoreList = <ScoreList>[];
      for (final semester in semesters) {
        setState(() {
          _loadingText = '正在获取 ${semester.name} 学期数据...';
        });

        final semesterScores = await _fetchSemesterScores(
          cookieData: cookieData,
          semester: semester,
          headers: headers,
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
    } catch (e) {
      if (mounted) {
        showClubSnackBar(context, Text('获取数据失败: ${e.toString()}'));
      }
      debugPrint('Error fetching data: $e');
    } finally {
      _isFool = false;
    }
  }

  Map<String, String> _buildHeaders(UserData cookieData) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Cookie': cookieData.cookie,
      'xauat': cookieData.cookie,
    };
  }

  Future<ScoreList?> _fetchSemesterScores({
    required UserData cookieData,
    required SemesterModel semester,
    required Map<String, String> headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${semester.semester}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final list = jsonDecode(response.body) as List;
        return ScoreList(
          semester: semester,
          list: list.map((e) => ScoreModel.fromJson(e)).toList(),
        );
      } else {
        return await _retryWithFreshLogin(
          cookieData: cookieData,
          semester: semester,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching semester scores: $e');
      }
      return null;
    }
  }

  Future<ScoreList?> _retryWithFreshLogin({
    required UserData cookieData,
    required SemesterModel semester,
  }) async {
    await EduService.login();
    final freshCookieData = await EduService.getUserData();
    if (freshCookieData == null) return null;

    final response = await http.get(
      Uri.parse(
        'https://xauatapi.xauat.site/Score?studentId=${cookieData.studentId}&semester=${semester.semester}',
      ),
      headers: _buildHeaders(freshCookieData),
    );

    if (response.statusCode == 200) {
      final list = jsonDecode(response.body) as List;
      return ScoreList(
        semester: semester,
        list: list.map((e) => ScoreModel.fromJson(e)).toList(),
      );
    }
    return null;
  }

  Future<void> _cacheFreshData(List<ScoreList> freshData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('all_score_data', jsonEncode(freshData));
    await prefs.setInt(
        'last_Score_time', DateTime.now().millisecondsSinceEpoch);
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
        backgroundColor: _backgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.person_crop_circle_badge_xmark,
                    size: 80,
                    color: CupertinoColors.systemGrey,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '未登录',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: _primaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '请先登录查看成绩',
                    style: TextStyle(
                      fontSize: 17,
                      color: _secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CupertinoButton.filled(
                    onPressed: () {
                      Get.toNamed('/Profile');
                    },
                    child: const Text('前往登录'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CupertinoActivityIndicator(radius: 14),
              const SizedBox(height: 16),
              Text(
                _loadingText,
                style: TextStyle(
                  fontSize: 15,
                  color: _secondaryTextColor,
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '成绩',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: _primaryTextColor,
            ),
          ),
          Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _changeScoreList,
                child: Icon(
                  _isYear
                      ? CupertinoIcons.calendar
                      : CupertinoIcons.list_bullet,
                  color: CupertinoColors.activeBlue,
                  size: 22,
                ),
              ),
              if (!_isFool)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: _handleFoolishMode,
                  child: const Icon(
                    CupertinoIcons.smiley,
                    color: CupertinoColors.activeBlue,
                    size: 22,
                  ),
                ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => refresh(isRefresh: true),
                child: const Icon(
                  CupertinoIcons.arrow_clockwise,
                  color: CupertinoColors.activeBlue,
                  size: 22,
                ),
              ),
            ],
          ),
        ],
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: _buildStatsPadding(),
    );
  }

  Widget _buildStatsPadding({ScoreList? scoreList}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              icon: CupertinoIcons.star_fill,
              value: scoreList == null
                  ? ScoreList.getTotalGpa(_scoreList).toStringAsFixed(2)
                  : scoreList.totalGpa.toStringAsFixed(2),
              label: 'GPA',
              color: CupertinoColors.systemPurple,
            ),
            Container(
              width: 0.5,
              height: 40,
              color: _separatorColor,
            ),
            _buildStatItem(
              icon: CupertinoIcons.book_fill,
              value: scoreList == null
                  ? ScoreList.getTotalCourse(_scoreList).toString()
                  : scoreList.totalCourse.toString(),
              label: '课程',
              color: CupertinoColors.systemBlue,
            ),
            Container(
              width: 0.5,
              height: 40,
              color: _separatorColor,
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showCreditInfoDialog,
              child: _buildStatItem(
                icon: CupertinoIcons.chart_bar_fill,
                value: scoreList == null
                    ? ScoreList.getTotalCredit(_scoreList).toStringAsFixed(1)
                    : scoreList.totalCredit.toStringAsFixed(1),
                label: '学分',
                color: CupertinoColors.systemGreen,
                withInfo: true,
              ),
            )
          ],
        ),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 28,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: _primaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: _secondaryTextColor,
              ),
            ),
            if (withInfo) ...[
              const SizedBox(width: 2),
              Icon(
                CupertinoIcons.info_circle,
                size: 13,
                color: _secondaryTextColor,
              ),
            ],
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
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _isDarkMode
            ? CupertinoColors.tertiarySystemFill.darkColor
            : CupertinoColors.tertiarySystemFill,
        borderRadius: BorderRadius.circular(9),
      ),
      child: CupertinoSlidingSegmentedControl<int>(
        backgroundColor: Colors.transparent,
        thumbColor: _cardColor,
        groupValue: _currentIndex,
        onValueChanged: (int? value) async {
          if (value != null && value < _selectorList.length) {
            setState(() {
              pageController.jumpToPage(value);
              _currentIndex = value;
            });
          }
        },
        children: Map.fromEntries(
          _selectorList.asMap().entries.map(
                (entry) => MapEntry(
                  entry.key,
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 5,
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _currentIndex == entry.key
                            ? _primaryTextColor
                            : _secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              ),
        ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // iOS 风格的分组标题
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 22, 32, 8),
          child: Text(
            '大${yearStringList[index]}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _secondaryTextColor,
              letterSpacing: -0.08,
            ),
          ),
        ),
        // 该学年的统计信息
        _buildStatsPadding(scoreList: score),
        const SizedBox(height: 16),
        // iOS 风格的分组列表卡片
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: score.list.length,
            itemBuilder: (context, index) {
              final isLast = index == score.list.length - 1;
              return _buildScoreListItem(score.list[index], isLast);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.doc_text_search,
              size: 80,
              color: CupertinoColors.systemGrey,
            ),
            const SizedBox(height: 24),
            Text(
              '没有成绩',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: _primaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '建议刷新或退出重进',
              style: TextStyle(
                fontSize: 17,
                color: _secondaryTextColor,
              ),
            ),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: () => refresh(isRefresh: true),
              child: const Text('刷新数据'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSemesterCard(ScoreList score) {
    final semesterNames = score.semester.name.split('-');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // iOS 风格的分组标题
        Padding(
          padding: const EdgeInsets.fromLTRB(32, 22, 32, 8),
          child: Text(
            '${semesterNames[0]}至${semesterNames[1]}年 第${semesterNames[2]}学期',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _secondaryTextColor,
              letterSpacing: -0.08,
            ),
          ),
        ),
        // iOS 风格的分组列表卡片
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: score.list.length,
            itemBuilder: (context, index) {
              final isLast = index == score.list.length - 1;
              return _buildScoreListItem(score.list[index], isLast);
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // iOS 风格的列表项（用于分组列表内）
  Widget _buildScoreListItem(ScoreModel item, bool isLast) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: _separatorColor,
                  width: 0.5,
                ),
              ),
      ),
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onPressed: () => _showScoreDetails(item),
        child: Row(
          children: [
            // 左侧彩色标记
            Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                color: CourseColorManager.generateSoftColor(item.name),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            const SizedBox(width: 12),
            // 主要内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 17,
                            color: _primaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.isMinor)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemOrange
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '辅修',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: CupertinoColors.systemOrange,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.credit}学分 · 成绩 ${item.grade} · GPA ${item.gpa}',
                    style: TextStyle(
                      fontSize: 15,
                      color: _secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 右侧箭头
            Icon(
              CupertinoIcons.chevron_right,
              size: 18,
              color: CupertinoColors.systemGrey3,
            ),
          ],
        ),
      ),
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
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题行
          Row(
            children: [
              Expanded(
                child: Text(
                  score.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: _primaryTextColor,
                  ),
                ),
              ),
              if (score.isMinor)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '辅修',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: CupertinoColors.systemOrange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // iOS 风格的分组列表
          Container(
            decoration: BoxDecoration(
              color: _isDarkMode
                  ? CupertinoColors.tertiarySystemFill.darkColor
                  : CupertinoColors.tertiarySystemFill,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildSimpleDetailRow(
                  label: '学分',
                  value: score.credit.toString(),
                  icon: CupertinoIcons.chart_bar_fill,
                  color: CupertinoColors.systemGreen,
                  isFirst: true,
                ),
                _buildSimpleDetailRow(
                  label: '成绩',
                  value: score.grade,
                  icon: CupertinoIcons.checkmark_seal_fill,
                  color: CupertinoColors.systemBlue,
                ),
                _buildSimpleDetailRow(
                  label: '绩点',
                  value: score.gpa,
                  icon: CupertinoIcons.star_fill,
                  color: CupertinoColors.systemPurple,
                ),
                _buildSimpleDetailRow(
                  label: '详情',
                  value: score.gradeDetail,
                  icon: CupertinoIcons.doc_text,
                  color: CupertinoColors.systemGrey,
                  isLast: true,
                  isMultiline: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleDetailRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    bool isFirst = false,
    bool isLast = false,
    bool isMultiline = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: _separatorColor,
                  width: 0.5,
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment:
            isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    color: _secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: _primaryTextColor,
                    height: 1.3,
                  ),
                  maxLines: isMultiline ? null : 1,
                  overflow: isMultiline ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
