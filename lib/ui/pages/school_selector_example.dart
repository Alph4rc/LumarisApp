import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/state/settings_store.dart';

/// 学校选择页面示例
///
/// 这是一个示例实现，展示如何创建学校切换 UI
/// 可以根据实际需求进行调整和美化
class SchoolSelectorPageExample extends StatelessWidget {
  const SchoolSelectorPageExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('选择学校'),
        elevation: 0,
      ),
      body: Obx(() {
        final schools = ApiConfig.getAllSchools();
        final currentSchoolId = SettingsStore.to.schoolId;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: schools.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final school = schools[index];
            final isSelected = school.id == currentSchoolId;

            return Card(
              elevation: isSelected ? 4 : 1,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  child: Icon(
                    isSelected ? Icons.check : Icons.school,
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                ),
                title: Text(
                  school.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'ID: ${school.id}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      school.eduApiBaseUrl,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                trailing: isSelected
                    ? Chip(
                        label: const Text(
                          '当前',
                          style: TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                        labelStyle: TextStyle(
                          color: Theme.of(context).primaryColor,
                        ),
                      )
                    : null,
                onTap: isSelected
                    ? null
                    : () => _showSwitchConfirmDialog(context, school),
              ),
            );
          },
        );
      }),
    );
  }

  /// 显示切换确认对话框
  void _showSwitchConfirmDialog(BuildContext context, SchoolConfig school) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('切换学校'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要切换到 ${school.name} 吗？'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '注意',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '切换学校将清除以下数据：\n'
                    '• 登录状态\n'
                    '• 课程信息\n'
                    '• 成绩数据\n'
                    '• 考试信息\n'
                    '\n'
                    '您需要重新登录。',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // 关闭对话框
              await _switchSchool(context, school);
            },
            child: const Text('确定切换'),
          ),
        ],
      ),
    );
  }

  /// 执行学校切换
  Future<void> _switchSchool(BuildContext context, SchoolConfig school) async {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在切换学校...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 执行切换
      await SettingsStore.to.setSchoolId(school.id);

      // 关闭加载对话框
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 显示成功提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('已切换到 ${school.name}\n请重新登录'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // 返回上一页
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 可选：导航到登录页面
      // Get.offAllNamed('/login');
    } catch (e) {
      // 关闭加载对话框
      if (context.mounted) {
        Navigator.pop(context);
      }

      // 显示错误提示
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('切换失败: $e'),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

/// 学校信息卡片组件
///
/// 可以在设置页面中使用，显示当前学校信息
class CurrentSchoolCard extends StatelessWidget {
  const CurrentSchoolCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final school = SettingsStore.to.currentSchool;

      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.school,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '当前学校',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('学校名称', school.name),
              const SizedBox(height: 8),
              _buildInfoRow('学校 ID', school.id),
              const SizedBox(height: 8),
              _buildInfoRow('API 地址', school.eduApiBaseUrl),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SchoolSelectorPageExample(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('切换学校'),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// 使用示例
///
/// 在设置页面中添加：
/// ```dart
/// // 显示当前学校信息
/// CurrentSchoolCard(),
///
/// // 或者直接跳转到学校选择页面
/// ListTile(
///   leading: Icon(Icons.school),
///   title: Text('切换学校'),
///   subtitle: Text(SettingsStore.to.currentSchool.name),
///   trailing: Icon(Icons.chevron_right),
///   onTap: () {
///     Navigator.push(
///       context,
///       MaterialPageRoute(
///         builder: (context) => SchoolSelectorPageExample(),
///       ),
///     );
///   },
/// ),
/// ```
