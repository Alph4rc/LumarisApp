import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/clubServices/todo_service.dart';
import 'package:ios_club_app/clubModels/todo_model.dart';
import 'package:ios_club_app/widgets/club_app_bar.dart';
import 'package:ios_club_app/widgets/club_card.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  bool _isLoading = true;
  List<TodoModel> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await TodoService.getAllTodos();
      if (tasks != null) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载任务信息失败: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ClubAppBar(title: '社团任务'),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CupertinoActivityIndicator(
                  radius: 14,
                ),
              ),
            )
          else if (_tasks.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.check_mark_circled,
                      size: 64,
                      color: CupertinoColors.systemGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '暂无任务',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '所有任务都已完成',
                      style: TextStyle(
                        fontSize: 14,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = _tasks[index];
                    return _buildTaskCard(task);
                  },
                  childCount: _tasks.length,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTaskCard(TodoModel task) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClubCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 任务头部信息
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    CupertinoColors.systemBlue.withValues(alpha: 0.05),
                    CupertinoColors.systemBlue.withValues(alpha: 0.02),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  // 任务状态图标
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: task.status
                          ? CupertinoColors.systemGreen
                          : CupertinoColors.systemBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        task.status
                            ? CupertinoIcons.check_mark
                            : CupertinoIcons.circle,
                        size: 16,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            decoration: task.status
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          task.id,
                          style: const TextStyle(
                            fontSize: 12,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 任务详细信息
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.description.isNotEmpty) ...[
                    Text(
                      task.description,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (task.startTime != null || task.endTime != null) ...[
                    _buildTimeInfoRow(
                      icon: CupertinoIcons.calendar,
                      title: '时间范围',
                      startTime: task.startTime,
                      endTime: task.endTime,
                    ),
                    _buildDivider(),
                  ],
                  _buildStatusRow(
                    icon: CupertinoIcons.check_mark_circled,
                    title: '任务状态',
                    isFinished: task.status,
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    icon: CupertinoIcons.doc_text,
                    title: '任务ID',
                    value: task.id,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfoRow({
    required IconData icon,
    required String title,
    String? startTime,
    String? endTime,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (startTime != null)
                Text(
                  _formatDate(startTime),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              if (endTime != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(endTime),
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required String title,
    required bool isFinished,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isFinished
                  ? CupertinoColors.systemGreen.withValues(alpha: 0.2)
                  : CupertinoColors.systemOrange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isFinished ? '已完成' : '进行中',
              style: TextStyle(
                fontSize: 12,
                color: isFinished
                    ? CupertinoColors.systemGreen
                    : CupertinoColors.systemOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: CupertinoColors.separator.withValues(alpha: 0.3),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}