import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/features/club/services/logs_service.dart';
import 'package:ios_club_app/features/club/services/monitoring_service.dart';
import 'package:ios_club_app/features/club/services/ip_blacklist_service.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';

/// 日志监控页面
/// 整合系统日志、性能监控和IP黑名单管理
class LogsMonitoringPage extends StatefulWidget {
  const LogsMonitoringPage({super.key});

  @override
  State<LogsMonitoringPage> createState() => _LogsMonitoringPageState();
}

class _LogsMonitoringPageState extends State<LogsMonitoringPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClubAppBar(
        title: '系统监控',
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: '系统日志'),
            Tab(text: '性能监控'),
            Tab(text: 'IP黑名单'),
            Tab(text: '数据统计'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LogsTab(),
          _PerformanceTab(),
          _IpBlacklistTab(),
          _DataStatsTab(),
        ],
      ),
    );
  }
}

/// 系统日志标签页
class _LogsTab extends StatefulWidget {
  const _LogsTab();

  @override
  State<_LogsTab> createState() => _LogsTabState();
}

class _LogsTabState extends State<_LogsTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  List<dynamic> _logs = [];
  Map<String, dynamic>? _statistics;
  bool _isLoading = true;
  int _pageIndex = 1;
  int _totalPages = 0;
  String? _levelFilter;
  String _timeRange = 'today';

  @override
  void initState() {
    super.initState();
    _loadLogs();
    _loadStatistics();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);

    try {
      final result = await LogsService.getLogs(
        pageIndex: _pageIndex,
        pageSize: 20,
        levelFilter: _levelFilter,
        timeRange: _timeRange,
      );

      if (result != null && result['data'] != null) {
        setState(() {
          _logs = result['data']['data'] ?? [];
          _totalPages = result['data']['totalPages'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('错误', '加载日志失败: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await LogsService.getStatistics();
      if (stats != null) {
        setState(() => _statistics = stats);
      }
    } catch (e) {
      debugPrint('加载统计失败: $e');
    }
  }

  Future<void> _cleanupLogs() async {
    final confirmed = await PlatformDialog.showConfirmDialog(
      context,
      title: '确认清理',
      content: '确定要清理7天前的日志吗？',
      confirmText: '清理',
      cancelText: '取消',
    );

    if (confirmed == true) {
      try {
        await LogsService.cleanupLogs(days: 7);
        Get.snackbar('成功', '日志已清理', snackPosition: SnackPosition.BOTTOM);
        _loadLogs();
        _loadStatistics();
      } catch (e) {
        Get.snackbar('错误', '清理失败: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        // 统计卡片
        if (_statistics != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClubCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '日志统计',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: _cleanupLogs,
                            tooltip: '清理日志',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            'Total',
                            _statistics!['totalCount']?.toString() ?? '0',
                            Colors.blue,
                          ),
                          if (_statistics!['levelCounts'] != null)
                            ..._statistics!['levelCounts'].entries.map((e) {
                              Color color;
                              switch (e.key.toLowerCase()) {
                                case 'error':
                                  color = Colors.red;
                                  break;
                                case 'warning':
                                  color = Colors.orange;
                                  break;
                                default:
                                  color = Colors.green;
                              }
                              return _buildStatItem(
                                e.key,
                                e.value.toString(),
                                color,
                              );
                            }).toList(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        // 筛选器
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _levelFilter,
                    decoration: const InputDecoration(
                      labelText: '日志级别',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('全部')),
                      DropdownMenuItem(value: 'Information', child: Text('Info')),
                      DropdownMenuItem(value: 'Warning', child: Text('Warning')),
                      DropdownMenuItem(value: 'Error', child: Text('Error')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _levelFilter = value;
                        _pageIndex = 1;
                      });
                      _loadLogs();
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _timeRange,
                    decoration: const InputDecoration(
                      labelText: '时间范围',
                      isDense: true,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'today', child: Text('今天')),
                      DropdownMenuItem(value: 'week', child: Text('本周')),
                      DropdownMenuItem(value: 'month', child: Text('本月')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _timeRange = value ?? 'today';
                        _pageIndex = 1;
                      });
                      _loadLogs();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        // 日志列表
        _isLoading
            ? const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            : _logs.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined,
                              size: 64,
                              color: isDarkMode ? Colors.grey : Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('暂无日志',
                              style: TextStyle(
                                  color: isDarkMode ? Colors.grey : Colors.grey[600])),
                        ],
                      ),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final log = _logs[index];
                          return _buildLogCard(log);
                        },
                        childCount: _logs.length,
                      ),
                    ),
                  ),
        // 分页
        if (_totalPages > 1)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _pageIndex > 1
                        ? () {
                            setState(() => _pageIndex--);
                            _loadLogs();
                          }
                        : null,
                  ),
                  Text('$_pageIndex / $_totalPages'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _pageIndex < _totalPages
                        ? () {
                            setState(() => _pageIndex++);
                            _loadLogs();
                          }
                        : null,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildLogCard(dynamic log) {
    final level = log['level']?.toString() ?? 'Info';
    Color levelColor;
    IconData levelIcon;

    switch (level.toLowerCase()) {
      case 'error':
        levelColor = Colors.red;
        levelIcon = Icons.error;
        break;
      case 'warning':
        levelColor = Colors.orange;
        levelIcon = Icons.warning;
        break;
      default:
        levelColor = Colors.green;
        levelIcon = Icons.info;
    }

    return ClubCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(levelIcon, color: levelColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  level,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: levelColor,
                  ),
                ),
                const Spacer(),
                Text(
                  log['timestamp']?.toString().substring(0, 19) ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(log['message']?.toString() ?? ''),
            if (log['exception'] != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  log['exception'].toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 性能监控标签页
class _PerformanceTab extends StatefulWidget {
  const _PerformanceTab();

  @override
  State<_PerformanceTab> createState() => _PerformanceTabState();
}

class _PerformanceTabState extends State<_PerformanceTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic>? _performanceData;
  Map<String, dynamic>? _httpStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        MonitoringService.getPerformance(),
        MonitoringService.getHttpStats(),
      ]);

      setState(() {
        _performanceData = results[0];
        _httpStats = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('错误', '加载监控数据失败: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 性能数据
                if (_performanceData != null) ...[
                  const Text(
                    '系统性能',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ClubCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _performanceData!.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key),
                                Text(
                                  e.value.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                // HTTP统计
                if (_httpStats != null) ...[
                  const Text(
                    'HTTP 统计',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ClubCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: _httpStats!.entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(e.key),
                                Text(
                                  e.value.toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// IP黑名单标签页
class _IpBlacklistTab extends StatefulWidget {
  const _IpBlacklistTab();

  @override
  State<_IpBlacklistTab> createState() => _IpBlacklistTabState();
}

class _IpBlacklistTabState extends State<_IpBlacklistTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final stats = await IpBlacklistService.getStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('错误', '加载统计失败: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _addIp() async {
    final ipController = TextEditingController();
    final reasonController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加IP到黑名单'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ipController,
              decoration: const InputDecoration(labelText: 'IP地址'),
            ),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: '原因'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('添加'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        await IpBlacklistService.addIp(
          ipController.text,
          reason: reasonController.text.isNotEmpty ? reasonController.text : null,
        );
        Get.snackbar('成功', 'IP已添加到黑名单',
            snackPosition: SnackPosition.BOTTOM);
        _loadStats();
      } catch (e) {
        Get.snackbar('错误', '添加失败: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_stats != null)
                  ClubCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'IP黑名单统计',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatColumn(
                                'IP数量',
                                _stats!['totalIps']?.toString() ?? '0',
                                Icons.block,
                              ),
                              _buildStatColumn(
                                'CIDR范围',
                                _stats!['totalCidrRanges']?.toString() ?? '0',
                                Icons.dns,
                              ),
                              _buildStatColumn(
                                '拦截次数',
                                _stats!['blacklistHits']?.toString() ?? '0',
                                Icons.security,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addIp,
                  icon: const Icon(Icons.add),
                  label: const Text('添加IP到黑名单'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// 数据访问统计标签页
class _DataStatsTab extends StatefulWidget {
  const _DataStatsTab();

  @override
  State<_DataStatsTab> createState() => _DataStatsTabState();
}

class _DataStatsTabState extends State<_DataStatsTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  String _entityType = 'Article';
  Map<String, dynamic>? _accessStats;
  Map<String, dynamic>? _changeStats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        MonitoringService.getDataAccessStats(entityType: _entityType, top: 10),
        MonitoringService.getDataChangeStats(entityType: _entityType, top: 10),
      ]);

      setState(() {
        _accessStats = results[0];
        _changeStats = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar('错误', '加载统计失败: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              initialValue: _entityType,
              decoration: const InputDecoration(labelText: '数据类型'),
              items: const [
                DropdownMenuItem(value: 'Article', child: Text('文章')),
                DropdownMenuItem(value: 'Project', child: Text('项目')),
                DropdownMenuItem(value: 'Department', child: Text('部门')),
                DropdownMenuItem(value: 'Resource', child: Text('资源')),
              ],
              onChanged: (value) {
                setState(() => _entityType = value ?? 'Article');
                _loadStats();
              },
            ),
          ),
        ),
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  '访问统计',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (_accessStats != null)
                  ClubCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_accessStats.toString()),
                    ),
                  ),
                const SizedBox(height: 24),
                const Text(
                  '变更统计',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (_changeStats != null)
                  ClubCard(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(_changeStats.toString()),
                    ),
                  ),
              ]),
            ),
          ),
      ],
    );
  }
}
