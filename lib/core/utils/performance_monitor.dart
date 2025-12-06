import 'dart:developer';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 性能监控工具类
class PerformanceMonitor {
  /// 单例实例
  static final PerformanceMonitor instance = PerformanceMonitor._internal();

  /// 工厂构造函数
  factory PerformanceMonitor() => instance;

  /// 内部构造函数
  PerformanceMonitor._internal();

  /// 启动时间
  DateTime? _startTime;

  /// 页面渲染时间记录
  final Map<String, List<int>> _pageRenderTimes = {};

  /// 内存使用记录
  final List<double> _memoryUsage = [];

  /// CPU使用记录
  final List<double> _cpuUsage = [];

  /// 初始化性能监控
  void initialize() {
    _startTime = DateTime.now();
    debugPrint('性能监控初始化完成，启动时间: $_startTime');
    
    // 定期记录性能指标
    if (kDebugMode) {
      _startPeriodicMonitoring();
    }
  }

  /// 开始定期监控
  void _startPeriodicMonitoring() {
    // 每5秒记录一次性能指标
    Future.delayed(const Duration(seconds: 5), () {
      _recordPerformanceMetrics();
      _startPeriodicMonitoring();
    });
  }

  /// 记录性能指标
  void _recordPerformanceMetrics() {
    // 记录内存使用情况
    // 注意：在Flutter中，直接获取内存使用情况需要使用platform_channel
    // 这里使用模拟数据作为示例
    final memoryUsage = 100 + Random().nextDouble() * 200;
    _memoryUsage.add(memoryUsage);
    
    // 记录CPU使用情况
    final cpuUsage = 10 + Random().nextDouble() * 30;
    _cpuUsage.add(cpuUsage);
    
    debugPrint('性能指标 - 内存: ${memoryUsage.toStringAsFixed(2)} MB, CPU: ${cpuUsage.toStringAsFixed(2)}%');
  }

  /// 记录页面渲染时间
  void recordPageRenderTime(String pageName, int renderTime) {
    if (!_pageRenderTimes.containsKey(pageName)) {
      _pageRenderTimes[pageName] = [];
    }
    _pageRenderTimes[pageName]!.add(renderTime);
    
    debugPrint('页面渲染时间 - $pageName: $renderTime ms');
  }

  /// 获取应用启动时间
  int getStartupTime() {
    if (_startTime == null) {
      return 0;
    }
    return DateTime.now().difference(_startTime!).inMilliseconds;
  }

  /// 获取页面平均渲染时间
  double getAveragePageRenderTime(String pageName) {
    if (!_pageRenderTimes.containsKey(pageName) || _pageRenderTimes[pageName]!.isEmpty) {
      return 0;
    }
    final times = _pageRenderTimes[pageName]!;
    final sum = times.reduce((a, b) => a + b);
    return sum / times.length;
  }

  /// 性能监控小部件 - 不再显示GUI，只在控制台输出
  Widget buildPerformanceDashboard() {
    // 只在控制台输出性能数据，不再显示GUI
    return const SizedBox.shrink();
  }
}

/// 性能监控小部件 - 只在控制台输出性能数据，不再显示GUI
class PerformanceMonitorWidget extends StatelessWidget {
  const PerformanceMonitorWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // 直接返回子组件，不再显示性能监控GUI
    return child;
  }
}

/// 页面渲染时间监控小部件
class PageRenderTimeMonitor extends StatefulWidget {
  const PageRenderTimeMonitor({super.key, required this.pageName, required this.child});

  final String pageName;
  final Widget child;

  @override
  State<PageRenderTimeMonitor> createState() => _PageRenderTimeMonitorState();
}

class _PageRenderTimeMonitorState extends State<PageRenderTimeMonitor> {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 当依赖变化时，检查页面是否已经渲染完成
    _checkRenderComplete();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  /// 检查页面是否已经渲染完成
  void _checkRenderComplete() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _stopwatch.stop();
      final renderTime = _stopwatch.elapsedMilliseconds;
      PerformanceMonitor().recordPageRenderTime(widget.pageName, renderTime);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}