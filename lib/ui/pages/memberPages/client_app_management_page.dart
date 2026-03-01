import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/features/club/models/client_application.dart';
import 'package:ios_club_app/features/club/models/create_client_app_model.dart';
import 'package:ios_club_app/features/club/models/update_client_app_model.dart';
import 'package:ios_club_app/features/club/services/client_app_service.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';

/// 客户端应用管理页面
/// 管理OAuth客户端应用
class ClientAppManagementPage extends StatefulWidget {
  const ClientAppManagementPage({super.key});

  @override
  State<ClientAppManagementPage> createState() =>
      _ClientAppManagementPageState();
}

class _ClientAppManagementPageState extends State<ClientAppManagementPage> {
  List<ClientApplication> _apps = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  Future<void> _loadApps() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apps = await ClientAppService.getAllClientApps();
      if (apps != null) {
        setState(() {
          _apps = apps;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '获取应用列表失败';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '加载失败: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteApp(String clientId) async {
    final confirmed = await PlatformDialog.showConfirmDialog(
      context,
      title: '确认删除',
      content: '确定要删除这个客户端应用吗？',
      confirmText: '删除',
      cancelText: '取消',
    );

    if (confirmed == true) {
      try {
        await ClientAppService.deleteClientApp(clientId);
        Get.snackbar('成功', '应用已删除', snackPosition: SnackPosition.BOTTOM);
        _loadApps();
      } catch (e) {
        Get.snackbar('错误', '删除失败: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _regenerateSecret(String clientId) async {
    final confirmed = await PlatformDialog.showConfirmDialog(
      context,
      title: '确认重新生成',
      content: '确定要重新生成Client Secret吗？旧的Secret将失效。',
      confirmText: '重新生成',
      cancelText: '取消',
    );

    if (confirmed == true) {
      try {
        final result = await ClientAppService.regenerateClientSecret(clientId);
        if (result != null) {
          _showSecretDialog(result.newSecret);
          _loadApps();
        }
      } catch (e) {
        Get.snackbar('错误', '重新生成失败: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void _showSecretDialog(String secret) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('新的 Client Secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请立即保存这个Secret，它只会显示一次：'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                secret,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: secret));
              Get.snackbar('成功', 'Secret已复制到剪贴板',
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('复制'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showAppDetails(ClientApplication app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppDetailsSheet(app: app),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => _AppFormDialog(
        onSaved: _loadApps,
      ),
    );
  }

  void _showEditDialog(ClientApplication app) {
    showDialog(
      context: context,
      builder: (context) => _AppFormDialog(
        app: app,
        onSaved: _loadApps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: ClubAppBar(
        title: '客户端应用管理',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
            tooltip: '新建应用',
          ),
        ],
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
                        onPressed: _loadApps,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _apps.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.apps,
                              size: 64,
                              color:
                                  isDarkMode ? Colors.grey : Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('暂无客户端应用',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey
                                      : Colors.grey[600])),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showCreateDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('创建第一个应用'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadApps,
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final app = _apps[index];
                                  return _buildAppCard(app);
                                },
                                childCount: _apps.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildAppCard(ClientApplication app) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClubCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showAppDetails(app),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Logo
                  if (app.logoUrl != null && app.logoUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        app.logoUrl!,
                        width: 48,
                        height: 48,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultIcon(),
                      ),
                    )
                  else
                    _buildDefaultIcon(),
                  const SizedBox(width: 16),
                  // 应用信息
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.applicationName ?? '未命名应用',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Client ID: ${app.clientId}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDarkMode
                                ? Colors.grey[400]
                                : Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 状态指示器
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: app.isActive == true
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      app.isActive == true ? '激活' : '禁用',
                      style: TextStyle(
                        fontSize: 12,
                        color: app.isActive == true ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // 菜单
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('编辑'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'regenerate',
                        child: Row(
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 8),
                            Text('重新生成Secret'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('删除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditDialog(app);
                      } else if (value == 'regenerate' &&
                          app.clientId != null) {
                        _regenerateSecret(app.clientId!);
                      } else if (value == 'delete' && app.clientId != null) {
                        _deleteApp(app.clientId!);
                      }
                    },
                  ),
                ],
              ),
              if (app.description != null && app.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  app.description!,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (app.supportsPkce == true)
                    Chip(
                      label: const Text('支持PKCE'),
                      backgroundColor: Colors.blue.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                      ),
                    ),
                  if (app.isNeedEMail == true)
                    Chip(
                      label: const Text('需要邮箱'),
                      backgroundColor: Colors.orange.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        fontSize: 11,
                        color: isDarkMode
                            ? Colors.orange[200]
                            : Colors.orange[700],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.apps, color: Colors.blue),
    );
  }
}

/// 应用详情底部弹窗
class _AppDetailsSheet extends StatelessWidget {
  final ClientApplication app;

  const _AppDetailsSheet({required this.app});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final redirectUris = app.redirectUris?.split(',') ?? [];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        app.applicationName ?? '应用详情',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildInfoRow('Client ID', app.clientId ?? '-'),
                    _buildInfoRow('应用名称', app.applicationName ?? '-'),
                    _buildInfoRow('描述', app.description ?? '-'),
                    _buildInfoRow('主页URL', app.homepageUrl ?? '-'),
                    _buildInfoRow('Logo URL', app.logoUrl ?? '-'),
                    _buildInfoRow('状态', app.isActive == true ? '激活' : '禁用'),
                    _buildInfoRow(
                        '支持PKCE', app.supportsPkce == true ? '是' : '否'),
                    _buildInfoRow('需要邮箱', app.isNeedEMail == true ? '是' : '否'),
                    const SizedBox(height: 16),
                    const Text(
                      '回调URL列表',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...redirectUris.map((uri) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text('• $uri'),
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }
}

/// 应用表单对话框
class _AppFormDialog extends StatefulWidget {
  final ClientApplication? app;
  final VoidCallback onSaved;

  const _AppFormDialog({
    this.app,
    required this.onSaved,
  });

  @override
  State<_AppFormDialog> createState() => _AppFormDialogState();
}

class _AppFormDialogState extends State<_AppFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _homepageController;
  late TextEditingController _logoController;
  late TextEditingController _redirectUrisController;
  bool _isActive = true;
  bool _supportsPkce = false;
  bool _isNeedEmail = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.app?.applicationName ?? '');
    _descriptionController =
        TextEditingController(text: widget.app?.description ?? '');
    _homepageController =
        TextEditingController(text: widget.app?.homepageUrl ?? '');
    _logoController = TextEditingController(text: widget.app?.logoUrl ?? '');
    _redirectUrisController =
        TextEditingController(text: widget.app?.redirectUris ?? '');
    _isActive = widget.app?.isActive ?? true;
    _supportsPkce = widget.app?.supportsPkce ?? false;
    _isNeedEmail = widget.app?.isNeedEMail ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _homepageController.dispose();
    _logoController.dispose();
    _redirectUrisController.dispose();
    super.dispose();
  }

  Future<void> _saveApp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final redirectUris = _redirectUrisController.text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (widget.app == null) {
        // 创建新应用
        final model = CreateClientAppModel(
          applicationName: _nameController.text,
          description: _descriptionController.text,
          homepageUrl: _homepageController.text,
          logoUrl: _logoController.text,
          redirectUris: redirectUris,
          isNeedEMail: _isNeedEmail,
          supportsPkce: _supportsPkce,
        );

        final result = await ClientAppService.createClientApp(model);
        if (result != null && result.clientSecret != null) {
          _showNewAppDialog(result.clientId ?? '', result.clientSecret ?? '');
        }
      } else {
        // 更新应用
        final model = UpdateClientAppModel(
          applicationName: _nameController.text,
          description: _descriptionController.text,
          homepageUrl: _homepageController.text,
          logoUrl: _logoController.text,
          redirectUris: redirectUris,
          isActive: _isActive,
          isNeedEMail: _isNeedEmail,
          supportsPkce: _supportsPkce,
        );

        await ClientAppService.updateClientApp(widget.app!.clientId!, model);
        Get.snackbar('成功', '应用已更新', snackPosition: SnackPosition.BOTTOM);
        widget.onSaved();
        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      Get.snackbar('错误', '保存失败: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showNewAppDialog(String clientId, String clientSecret) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('应用创建成功'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('请保存以下凭据，Client Secret只会显示一次：'),
            const SizedBox(height: 16),
            SelectableText('Client ID: $clientId'),
            const SizedBox(height: 8),
            SelectableText('Client Secret: $clientSecret'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: 'ID: $clientId\nSecret: $clientSecret'));
              Get.snackbar('成功', '凭据已复制到剪贴板',
                  snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('复制'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onSaved();
              Navigator.pop(context);
            },
            child: const Text('完成'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.app != null;

    return Dialog(
      backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    isEdit ? '编辑应用' : '新建应用',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: '应用名称 *',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入应用名称';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: '应用描述',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _homepageController,
                        decoration: const InputDecoration(
                          labelText: '主页URL',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _logoController,
                        decoration: const InputDecoration(
                          labelText: 'Logo URL',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _redirectUrisController,
                        decoration: const InputDecoration(
                          labelText: '回调URL列表',
                          hintText: '每行一个URL',
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title: const Text('激活状态'),
                        value: _isActive,
                        onChanged: isEdit
                            ? (value) => setState(() => _isActive = value)
                            : null,
                      ),
                      SwitchListTile(
                        title: const Text('支持PKCE'),
                        value: _supportsPkce,
                        onChanged: (value) =>
                            setState(() => _supportsPkce = value),
                      ),
                      SwitchListTile(
                        title: const Text('需要邮箱验证'),
                        value: _isNeedEmail,
                        onChanged: (value) =>
                            setState(() => _isNeedEmail = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _saveApp,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(isEdit ? '保存' : '创建'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
