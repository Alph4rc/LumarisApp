import 'package:flutter/material.dart';
import 'package:ios_club_app/features/club/models/data_centre_model.dart';
import 'package:ios_club_app/features/club/models/year_count.dart';
import 'package:ios_club_app/features/club/models/academy_count.dart';
import 'package:ios_club_app/features/club/models/gender_count.dart';
import 'package:ios_club_app/features/club/models/landscape_count.dart';
import 'package:ios_club_app/features/club/services/data_centre_service.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:fl_chart/fl_chart.dart';

/// 数据统计仪表板页面
/// 展示社团成员的各类统计数据
class DataDashboardPage extends StatefulWidget {
  const DataDashboardPage({super.key});

  @override
  State<DataDashboardPage> createState() => _DataDashboardPageState();
}

class _DataDashboardPageState extends State<DataDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _errorMessage;

  List<YearCount> _yearData = [];
  List<AcademyCount> _collegeData = [];
  List<GradeCount> _gradeData = [];
  List<LandscapeCount> _landscapeData = [];
  List<GenderCount> _genderData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        DataCentreService.getYearStatistics(),
        DataCentreService.getAcademyStatistics(),
        DataCentreService.getGradeStatistics(),
        DataCentreService.getLandscapeStatistics(),
        DataCentreService.getGenderStatistics(),
      ]);

      setState(() {
        _yearData = (results[0] as List<YearCount>?) ?? [];
        _collegeData = (results[1] as List<AcademyCount>?) ?? [];
        _gradeData = (results[2] as List<LandscapeCount>?)?.map((e) => GradeCount(grade: e.type, value: e.sales)).toList() ?? [];
        _landscapeData = (results[3] as List<LandscapeCount>?) ?? [];
        _genderData = (results[4] as List<GenderCount>?) ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载数据失败: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: ClubAppBar(
        title: '数据统计',
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '年级分布'),
            Tab(text: '学院分布'),
            Tab(text: '年级统计'),
            Tab(text: '政治面貌'),
            Tab(text: '性别统计'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 64,
                          color: isDarkMode ? Colors.grey : Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                          style: TextStyle(
                              color:
                                  isDarkMode ? Colors.grey : Colors.grey[600])),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAllData,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAllData,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildYearView(),
                      _buildCollegeView(),
                      _buildGradeView(),
                      _buildLandscapeView(),
                      _buildGenderView(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildYearView() {
    if (_yearData.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClubCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '年级分布饼图',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieChartSections(_yearData),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._yearData.map((data) => _buildStatCard(
                      '${data.year}级',
                      data.value,
                      Icons.school,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCollegeView() {
    if (_collegeData.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClubCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '学院分布图',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              barGroups: _buildBarChartData(_collegeData),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      if (value.toInt() >= 0 &&
                                          value.toInt() < _collegeData.length) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            _getShortName(
                                                _collegeData[value.toInt()]
                                                    .type),
                                            style:
                                                const TextStyle(fontSize: 10),
                                          ),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._collegeData.map((data) => _buildStatCard(
                      data.type,
                      data.value,
                      Icons.business,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGradeView() {
    if (_gradeData.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final data = _gradeData[index];
                return _buildStatCard(
                  data.grade ?? '未知',
                  data.value ?? 0,
                  Icons.grade,
                );
              },
              childCount: _gradeData.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLandscapeView() {
    if (_landscapeData.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClubCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '政治面貌分布',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieChartSectionsForLandscape(
                                  _landscapeData),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ..._landscapeData.map((data) => _buildStatCard(
                      data.type,
                      data.sales,
                      Icons.account_circle,
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderView() {
    if (_genderData.isEmpty) {
      return const Center(child: Text('暂无数据'));
    }

    final total = _genderData.fold<int>(0, (sum, item) => sum + item.value);
    final maleData = _genderData.firstWhere((e) => e.type == '男',
        orElse: () => GenderCount(type: '男', value: 0));
    final femaleData = _genderData.firstWhere((e) => e.type == '女',
        orElse: () => GenderCount(type: '女', value: 0));
    final maleCount = maleData.value;
    final femaleCount = femaleData.value;
    final maleRatio =
        total > 0 ? (maleCount / total * 100).toStringAsFixed(1) : '0';
    final femaleRatio =
        total > 0 ? (femaleCount / total * 100).toStringAsFixed(1) : '0';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ClubCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '性别比例',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue.withValues(alpha: 0.2),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.male,
                                              size: 40, color: Colors.blue),
                                          const SizedBox(height: 4),
                                          Text(
                                            maleCount.toString(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('男生 ($maleRatio%)'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.pink.withValues(alpha: 0.2),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.female,
                                              size: 40, color: Colors.pink),
                                          const SizedBox(height: 4),
                                          Text(
                                            femaleCount.toString(),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.pink,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('女生 ($femaleRatio%)'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ClubCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('总人数', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              total.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            const Text('男女比', style: TextStyle(fontSize: 12)),
                            const SizedBox(height: 4),
                            Text(
                              femaleCount > 0
                                  ? '${(maleCount / femaleCount).toStringAsFixed(2)} : 1'
                                  : '-- : 1',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClubCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color: isDarkMode ? Colors.blue[200] : Colors.blue[700]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
              ),
            ),
            const SizedBox(width: 8),
            const Text('人', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(List<YearCount> data) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return PieChartSectionData(
        value: item.value.toDouble(),
        title: '${item.year}级\n${item.value}人',
        color: colors[index % colors.length],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildPieChartSectionsForLandscape(
      List<LandscapeCount> data) {
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.blue,
      Colors.green,
      Colors.purple,
    ];

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return PieChartSectionData(
        value: item.sales.toDouble(),
        title: '${item.type}\n${item.sales}人',
        color: colors[index % colors.length],
        radius: 100,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  List<BarChartGroupData> _buildBarChartData(List<AcademyCount> data) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.value.toDouble(),
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  String _getShortName(String fullName) {
    // 简化学院名称显示
    if (fullName.length > 6) {
      return '${fullName.substring(0, 6)}...';
    }
    return fullName;
  }
}
