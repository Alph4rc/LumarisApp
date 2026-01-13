import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/features/club/models/article_model.dart';
import 'package:ios_club_app/features/club/models/article_create_dto.dart';
import 'package:ios_club_app/features/club/models/article_update_dto.dart';
import 'package:ios_club_app/features/club/services/article_service.dart';
import 'package:ios_club_app/features/club/services/category_service.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 文章管理页面
/// 支持文章的增删改查
class ArticleManagementPage extends StatefulWidget {
  const ArticleManagementPage({super.key});

  @override
  State<ArticleManagementPage> createState() => _ArticleManagementPageState();
}

class _ArticleManagementPageState extends State<ArticleManagementPage> {
  List<ArticleModel> _articles = [];
  List<dynamic> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _loadCategories();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final articles = await ArticleService.getAllArticles();
      if (articles != null) {
        setState(() {
          _articles = articles;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '获取文章列表失败';
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

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getAllCategories();
      if (categories != null) {
        setState(() {
          _categories = categories;
        });
      }
    } catch (e) {
      AppLogger.debug('加载分类失败: $e');
    }
  }

  Future<void> _deleteArticle(String path) async {
    final confirmed = await PlatformDialog.showConfirmDialog(
      context,
      title: '确认删除',
      content: '确定要删除这篇文章吗？此操作不可恢复。',
      confirmText: '删除',
      cancelText: '取消',
    );

    if (confirmed == true) {
      try {
        final result = await ArticleService.deleteArticle(path);
        if (result) {
          Get.snackbar('成功', '文章已删除', snackPosition: SnackPosition.BOTTOM);
          _loadArticles();
        }
      } catch (e) {
        Get.snackbar('错误', '删除失败: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void _showArticleDetail(ArticleModel article) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ArticleDetailSheet(article: article),
    );
  }

  void _showCreateArticleDialog() {
    showDialog(
      context: context,
      builder: (context) => _ArticleFormDialog(
        categories: _categories,
        onSaved: () {
          _loadArticles();
        },
      ),
    );
  }

  void _showEditArticleDialog(ArticleModel article) {
    showDialog(
      context: context,
      builder: (context) => _ArticleFormDialog(
        article: article,
        categories: _categories,
        onSaved: () {
          _loadArticles();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: ClubAppBar(
        title: '文章管理',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateArticleDialog,
            tooltip: '新建文章',
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
                        onPressed: _loadArticles,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _articles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.article_outlined,
                              size: 64,
                              color:
                                  isDarkMode ? Colors.grey : Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('暂无文章',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey
                                      : Colors.grey[600])),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _showCreateArticleDialog,
                            icon: const Icon(Icons.add),
                            label: const Text('创建第一篇文章'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadArticles,
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final article = _articles[index];
                                  return _buildArticleCard(article);
                                },
                                childCount: _articles.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildArticleCard(ArticleModel article) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final categoryName = article.category?.name ?? '未分类';

    return ClubCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showArticleDetail(article),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      article.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                        _showEditArticleDialog(article);
                      } else if (value == 'delete') {
                        _deleteArticle(article.path);
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  Chip(
                    label: Text(categoryName),
                    backgroundColor: isDarkMode
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.blue.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                    ),
                  ),
                  if (article.identity != null)
                    Chip(
                      label: Text('发布者: ${article.identity}'),
                      backgroundColor: isDarkMode
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.green.withValues(alpha: 0.1),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color:
                            isDarkMode ? Colors.green[200] : Colors.green[700],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                article.content,
                style: TextStyle(
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16,
                      color: isDarkMode ? Colors.grey : Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    '最后修改: ${_formatDate(article.lastWriteTime)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDarkMode ? Colors.grey : Colors.grey[500],
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

  String _formatDate(DateTime? date) {
    if (date == null) return '未知';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

/// 文章详情底部弹窗
class _ArticleDetailSheet extends StatelessWidget {
  final ArticleModel article;

  const _ArticleDetailSheet({required this.article});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
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
                        article.title,
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
                child: Markdown(
                  controller: scrollController,
                  data: article.content,
                  selectable: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 文章表单对话框（新建/编辑）
class _ArticleFormDialog extends StatefulWidget {
  final ArticleModel? article;
  final List<dynamic> categories;
  final VoidCallback onSaved;

  const _ArticleFormDialog({
    this.article,
    required this.categories,
    required this.onSaved,
  });

  @override
  State<_ArticleFormDialog> createState() => _ArticleFormDialogState();
}

class _ArticleFormDialogState extends State<_ArticleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pathController;
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _identityController;
  String? _selectedCategoryId;
  int _articleOrder = 0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pathController = TextEditingController(text: widget.article?.path ?? '');
    _titleController = TextEditingController(text: widget.article?.title ?? '');
    _contentController =
        TextEditingController(text: widget.article?.content ?? '');
    _identityController =
        TextEditingController(text: widget.article?.identity ?? '');
    _selectedCategoryId = widget.article?.categoryId;
    _articleOrder = widget.article?.articleOrder ?? 0;
  }

  @override
  void dispose() {
    _pathController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  Future<void> _saveArticle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.article == null) {
        // 新建文章
        final dto = ArticleCreateDto(
          path: _pathController.text,
          title: _titleController.text,
          content: _contentController.text,
          identity: _identityController.text,
          category: _selectedCategoryId,
          articleOrder: _articleOrder,
        );
        await ArticleService.createArticle(dto);
      } else {
        // 更新文章
        final dto = ArticleUpdateDto(
          title: _titleController.text,
          content: _contentController.text,
          identity: _identityController.text,
          category: _selectedCategoryId,
          articleOrder: _articleOrder,
        );
        await ArticleService.updateArticle(widget.article!.path, dto);
      }

      Get.snackbar('成功', widget.article == null ? '文章已创建' : '文章已更新',
          snackPosition: SnackPosition.BOTTOM);
      widget.onSaved();
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      Get.snackbar('错误', '保存失败: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.article != null;

    return Dialog(
      backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // 标题栏
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
                    isEdit ? '编辑文章' : '新建文章',
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
            // 表单内容
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isEdit)
                        TextFormField(
                          controller: _pathController,
                          decoration: const InputDecoration(
                            labelText: '文章路径 *',
                            hintText: '例如: my-article',
                            helperText: '只能包含字母、数字、下划线和连字符',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入文章路径';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(value)) {
                              return '路径格式不正确';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: '文章标题 *',
                          hintText: '输入文章标题',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return '请输入文章标题';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: '文章内容 *',
                          hintText: '支持 Markdown 格式',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 10,
                        validator: (value) {
                          if (value == null || value.length < 10) {
                            return '内容至少10个字符';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _identityController,
                        decoration: const InputDecoration(
                          labelText: '发布者标识',
                          hintText: '输入发布者标识',
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: '分类',
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('无分类'),
                          ),
                          ...widget.categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(category.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedCategoryId = value);
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: _articleOrder.toString(),
                        decoration: const InputDecoration(
                          labelText: '排序值',
                          helperText: '用于控制文章显示顺序 (0-1000)',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          _articleOrder = int.tryParse(value) ?? 0;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // 底部按钮
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
                    onPressed: _isLoading ? null : _saveArticle,
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
