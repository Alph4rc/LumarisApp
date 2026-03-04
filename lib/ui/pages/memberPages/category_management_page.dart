import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ios_club_app/features/club/models/article_model.dart';
import 'package:ios_club_app/features/club/services/category_service.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/components/club_card.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';

/// 分类管理页面
/// 支持分类的增删改查和排序
class CategoryManagementPage extends StatefulWidget {
  const CategoryManagementPage({super.key});

  @override
  State<CategoryManagementPage> createState() => _CategoryManagementPageState();
}

class _CategoryManagementPageState extends State<CategoryManagementPage> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categories = await CategoryService.getAllCategories();
      if (categories != null) {
        setState(() {
          _categories = categories
              .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = '获取分类列表失败';
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

  Future<void> _deleteCategory(String name) async {
    final confirmed = await PlatformDialog.showConfirmDialog(
      context,
      title: '确认删除',
      content: '确定要删除这个分类吗？此分类下的文章将变为未分类。',
      confirmText: '删除',
      cancelText: '取消',
    );

    if (confirmed == true) {
      try {
        final result = await CategoryService.deleteCategory(name);
        if (result != null) {
          Get.snackbar('成功', '分类已删除', snackPosition: SnackPosition.BOTTOM);
          _loadCategories();
        }
      } catch (e) {
        Get.snackbar('错误', '删除失败: $e', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  void _showCategoryFormDialog([CategoryModel? category]) {
    showDialog(
      context: context,
      builder: (context) => _CategoryFormDialog(
        category: category,
        onSaved: _loadCategories,
      ),
    );
  }

  Future<void> _reorderCategories(List<CategoryModel> newOrder) async {
    try {
      // 构建排序映射 {categoryId: newOrder}
      final orderMap = <String, int>{};
      for (var i = 0; i < newOrder.length; i++) {
        if (newOrder[i].id != null) {
          orderMap[newOrder[i].id!] = i;
        }
      }

      await CategoryService.updateCategoryOrders(orderMap);
      Get.snackbar('成功', '分类顺序已更新', snackPosition: SnackPosition.BOTTOM);
      _loadCategories();
    } catch (e) {
      Get.snackbar('错误', '更新顺序失败: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _showReorderDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReorderCategoriesDialog(
        categories: _categories,
        onReordered: _reorderCategories,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: ClubAppBar(
        title: '分类管理',
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _categories.isEmpty ? null : _showReorderDialog,
            tooltip: '调整顺序',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCategoryFormDialog(),
            tooltip: '新建分类',
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
                        onPressed: _loadCategories,
                        child: const Text('重试'),
                      ),
                    ],
                  ),
                )
              : _categories.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 64,
                              color:
                                  isDarkMode ? Colors.grey : Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('暂无分类',
                              style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey
                                      : Colors.grey[600])),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _showCategoryFormDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('创建第一个分类'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadCategories,
                      child: CustomScrollView(
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final category = _categories[index];
                                  return _buildCategoryCard(category);
                                },
                                childCount: _categories.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildCategoryCard(CategoryModel category) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ClubCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 排序值指示器
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.blue.withValues(alpha: 0.2)
                    : Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${category.order ?? 0}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 分类信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (category.description != null &&
                      category.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      category.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 8),
                  if (category.description != null &&
                      category.description!.isNotEmpty)
                    Text(
                      category.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.grey : Colors.grey[500],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            // 操作菜单
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
                  _showCategoryFormDialog(category);
                } else if (value == 'delete') {
                  _deleteCategory(category.name);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 分类表单对话框
class _CategoryFormDialog extends StatefulWidget {
  final CategoryModel? category;
  final VoidCallback onSaved;

  const _CategoryFormDialog({
    this.category,
    required this.onSaved,
  });

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late int _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _descriptionController =
        TextEditingController(text: widget.category?.description ?? '');
    _order = widget.category?.order ?? 0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final categoryModel = CategoryModel(
        id: widget.category?.id,
        name: _nameController.text,
        description: _descriptionController.text,
        order: _order,
      );

      await CategoryService.createOrUpdateCategory(categoryModel.toJson());
      Get.snackbar('成功', widget.category == null ? '分类已创建' : '分类已更新',
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
    final isEdit = widget.category != null;

    return Dialog(
      backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? '编辑分类' : '新建分类',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '分类名称 *',
                      hintText: '输入分类名称',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入分类名称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: '分类描述',
                      hintText: '输入分类描述（可选）',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _order.toString(),
                    decoration: const InputDecoration(
                      labelText: '排序值',
                      helperText: '数值越小越靠前',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _order = int.tryParse(value) ?? 0;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveCategory,
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(isEdit ? '保存' : '创建'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 重新排序对话框
class _ReorderCategoriesDialog extends StatefulWidget {
  final List<CategoryModel> categories;
  final Function(List<CategoryModel>) onReordered;

  const _ReorderCategoriesDialog({
    required this.categories,
    required this.onReordered,
  });

  @override
  State<_ReorderCategoriesDialog> createState() =>
      _ReorderCategoriesDialogState();
}

class _ReorderCategoriesDialogState extends State<_ReorderCategoriesDialog> {
  late List<CategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    _categories = List.from(widget.categories);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDarkMode ? const Color(0xFF1C1C1E) : Colors.white,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    '调整分类顺序',
                    style: TextStyle(
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
            const Divider(height: 1),
            Expanded(
              child: ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = _categories.removeAt(oldIndex);
                    _categories.insert(newIndex, item);
                  });
                },
                children: _categories.map((category) {
                  return ListTile(
                    key: ValueKey(category.id),
                    leading: const Icon(Icons.drag_handle),
                    title: Text(category.name),
                    subtitle: category.description != null &&
                            category.description!.isNotEmpty
                        ? Text(category.description!)
                        : null,
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      widget.onReordered(_categories);
                      Navigator.pop(context);
                    },
                    child: const Text('保存'),
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
