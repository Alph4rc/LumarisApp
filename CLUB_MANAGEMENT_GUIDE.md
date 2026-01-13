# 社团管理功能完善指南

## 概述

本指南详细介绍了新增的社团管理功能，包括6个全新的管理页面和统一的管理入口。所有功能都基于 v1.yaml API 规范和现有的服务层实现。

## 新增页面列表

### 1. 社团管理中心 (Admin Portal)
**路由**: `/AdminPortal`
**文件**: `lib/ui/pages/memberPages/admin_portal_page.dart`

**功能特点**:
- 所有管理功能的统一入口
- 卡片式布局，分为4个模块：
  - 核心管理：成员、部门、项目、部员
  - 内容管理：文章、分类、资源、任务
  - 数据分析：数据统计仪表板
  - 系统管理：日志监控、客户端应用
- 快捷统计卡片和管理提示
- 响应式设计，支持深色模式

**使用方法**:
```dart
// 导航到管理中心
Get.toNamed('/AdminPortal');
// 或
Get.to(() => const AdminPortalPage());
```

---

### 2. 文章管理页面 (Article Management)
**路由**: `/ArticleManagement`
**文件**: `lib/ui/pages/memberPages/article_management_page.dart`

**功能特点**:
- ✅ 查看所有文章列表
- ✅ 创建新文章（支持 Markdown）
- ✅ 编辑现有文章
- ✅ 删除文章（带确认对话框）
- ✅ 查看文章详情（底部弹窗 Markdown 渲染）
- ✅ 文章分类管理
- ✅ 文章排序值设置
- ✅ 发布者标识

**API 接口**:
- GET `/Article` - 获取所有文章
- POST `/Article` - 创建文章
- POST `/Article/update/{path}` - 更新文章
- POST `/Article/delete/{path}` - 删除文章

**数据模型**:
- `ArticleModel` - 文章数据模型
- `ArticleCreateDto` - 创建文章DTO
- `ArticleUpdateDto` - 更新文章DTO

---

### 3. 分类管理页面 (Category Management)
**路由**: `/CategoryManagement`
**文件**: `lib/ui/pages/memberPages/category_management_page.dart`

**功能特点**:
- ✅ 查看所有分类
- ✅ 创建新分类
- ✅ 编辑分类（名称、描述、排序）
- ✅ 删除分类（带提示）
- ✅ 拖拽调整分类顺序
- ✅ 显示每个分类的文章数量
- ✅ 批量更新分类排序

**API 接口**:
- GET `/Category/all` - 获取所有分类
- POST `/Category/CreateOrUpdate` - 创建或更新分类
- GET `/Category/Delete/{name}` - 删除分类
- POST `/Category/UpdateOrders` - 更新分类顺序

**数据模型**:
- `CategoryModel` - 分类数据模型

---

### 4. 数据统计仪表板 (Data Dashboard)
**路由**: `/DataDashboard`
**文件**: `lib/ui/pages/memberPages/data_dashboard_page.dart`

**功能特点**:
- ✅ 5个数据统计标签页：
  1. 年级分布（饼图）
  2. 学院分布（柱状图）
  3. 年级统计（列表）
  4. 政治面貌（饼图）
  5. 性别统计（圆形图表 + 比例）
- ✅ 使用 `fl_chart` 绘制图表
- ✅ 下拉刷新
- ✅ 深色模式适配
- ✅ 实时数据可视化

**API 接口**:
- GET `/DataCentre/year` - 年级统计
- GET `/DataCentre/college` - 学院统计
- GET `/DataCentre/grade` - 年级统计
- GET `/DataCentre/landscape` - 政治面貌统计
- GET `/DataCentre/gender` - 性别统计

**数据模型**:
- `YearCount` - 年级统计
- `AcademyCount` - 学院统计
- `GradeCount` - 年级统计
- `LandscapeCount` - 政治面貌统计
- `GenderCount` - 性别统计

---

### 5. 日志监控页面 (Logs & Monitoring)
**路由**: `/LogsMonitoring`
**文件**: `lib/ui/pages/memberPages/logs_monitoring_page.dart`

**功能特点**:
- ✅ 4个标签页：
  1. **系统日志**:
     - 日志级别筛选（Info/Warning/Error）
     - 时间范围筛选（今天/本周/本月）
     - 分页浏览
     - 日志统计概览
     - 清理旧日志功能
  2. **性能监控**:
     - 系统性能指标
     - HTTP 请求统计
  3. **IP黑名单**:
     - 黑名单统计
     - 添加IP到黑名单
     - 拦截统计
  4. **数据统计**:
     - 数据访问统计
     - 数据变更统计
     - 按实体类型筛选

**API 接口**:
- GET `/Logs` - 获取日志（分页）
- GET `/Logs/statistics` - 日志统计
- POST `/Logs/cleanup` - 清理日志
- GET `/Monitoring/performance` - 性能监控
- GET `/Monitoring/http-stats` - HTTP统计
- GET `/IpBlacklist/stats` - IP黑名单统计
- POST `/IpBlacklist/add` - 添加IP

---

### 6. 客户端应用管理 (Client App Management)
**路由**: `/ClientAppManagement`
**文件**: `lib/ui/pages/memberPages/client_app_management_page.dart`

**功能特点**:
- ✅ 查看所有OAuth客户端应用
- ✅ 创建新应用（自动生成 ClientID 和 ClientSecret）
- ✅ 编辑应用配置
- ✅ 删除应用
- ✅ 重新生成 Client Secret
- ✅ 应用详情查看（底部弹窗）
- ✅ 支持配置：
  - 应用名称和描述
  - 主页URL和Logo
  - 回调URL列表
  - PKCE支持
  - 邮箱验证
  - 激活状态

**API 接口**:
- GET `/ClientApp` - 获取所有应用
- POST `/ClientApp` - 创建应用
- PUT `/ClientApp/{clientId}` - 更新应用
- DELETE `/ClientApp/{clientId}` - 删除应用
- POST `/ClientApp/{clientId}/regenerate-secret` - 重新生成密钥

**数据模型**:
- `ClientApplication` - 客户端应用模型
- `CreateClientAppModel` - 创建应用DTO
- `UpdateClientAppModel` - 更新应用DTO

---

## 路由配置

所有新页面已添加到 `lib/routes/router.dart`：

```dart
// 社团管理路由
GetPage(name: '/AdminPortal', page: () => const AdminPortalPage()),
GetPage(name: '/ArticleManagement', page: () => const ArticleManagementPage()),
GetPage(name: '/CategoryManagement', page: () => const CategoryManagementPage()),
GetPage(name: '/DataDashboard', page: () => const DataDashboardPage()),
GetPage(name: '/LogsMonitoring', page: () => const LogsMonitoringPage()),
GetPage(name: '/ClientAppManagement', page: () => const ClientAppManagementPage()),
```

---

## 设计模式

所有新页面遵循现有的设计规范：

### 1. UI 组件
- ✅ `ClubAppBar` - 统一的应用栏
- ✅ `ClubCard` - 卡片容器
- ✅ `PlatformDialog` - 跨平台对话框
- ✅ `CustomScrollView` + `SliverList` - 列表布局
- ✅ `EmptyWidget` - 空状态提示

### 2. 状态管理
- ✅ 使用 `StatefulWidget`
- ✅ `FutureBuilder` 异步加载
- ✅ `RefreshIndicator` 下拉刷新
- ✅ 加载/错误/空状态处理

### 3. 深色模式
```dart
final isDarkMode = Theme.of(context).brightness == Brightness.dark;
final bgColor = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white;
```

### 4. 错误处理
```dart
try {
  final result = await Service.getData();
  // 处理数据
} catch (e) {
  Get.snackbar('错误', '操作失败: $e', snackPosition: SnackPosition.BOTTOM);
}
```

---

## 集成到现有页面

### 方式1: 在 MemberPage 中添加入口

编辑 `lib/ui/pages/member_page.dart`，添加管理中心入口按钮：

```dart
// 在用户信息卡片添加管理按钮
if (userData?.identity == 'President' || userData?.identity == 'Minister') {
  ElevatedButton.icon(
    onPressed: () => Get.toNamed('/AdminPortal'),
    icon: Icon(Icons.admin_panel_settings),
    label: Text('管理中心'),
  ),
}
```

### 方式2: 在底部导航添加标签

编辑 `lib/bottom_navigation.dart`（如果是移动端）或侧边栏（桌面端），添加管理标签。

### 方式3: 直接从任何页面跳转

```dart
// 使用路由名称
Get.toNamed('/AdminPortal');

// 或直接导航
Get.to(() => const AdminPortalPage());
```

---

## 权限控制建议

虽然页面已创建，但建议添加权限检查：

```dart
// 在 admin_portal_page.dart 的 build 方法中
@override
Widget build(BuildContext context) {
  // 检查用户权限
  final userStore = Get.find<UserStore>();
  final identity = userStore.userData?.identity;

  if (identity != 'President' && identity != 'Minister' && identity != 'Founder') {
    return Scaffold(
      appBar: ClubAppBar(title: '无权限'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('您没有权限访问管理中心'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: Text('返回'),
            ),
          ],
        ),
      ),
    );
  }

  // 原有的管理中心内容
  return Scaffold(...);
}
```

---

## 依赖包

新增功能需要以下依赖包（请检查 `pubspec.yaml`）：

```yaml
dependencies:
  flutter:
    sdk: flutter
  get: ^4.6.5                      # GetX 状态管理和路由
  fl_chart: ^0.66.0                # 图表库（数据仪表板）
  flutter_markdown: ^0.6.18        # Markdown 渲染（文章管理）
```

如果缺少这些包，运行：
```bash
flutter pub add fl_chart
flutter pub add flutter_markdown
flutter pub get
```

---

## 测试建议

### 1. 功能测试
- ✅ 测试每个页面的增删改查功能
- ✅ 测试分页和筛选功能
- ✅ 测试表单验证
- ✅ 测试深色模式切换

### 2. UI 测试
- ✅ 检查不同屏幕尺寸的显示
- ✅ 测试空状态、加载状态、错误状态
- ✅ 验证图表在不同数据量下的显示

### 3. 性能测试
- ✅ 测试大量数据的加载性能
- ✅ 检查图表渲染性能
- ✅ 验证列表滚动流畅度

---

## API 兼容性说明

所有页面都基于 `v1.yaml` API 规范开发，确保：
- ✅ 使用正确的 HTTP 方法（GET/POST/PUT/DELETE）
- ✅ 正确处理请求参数和请求体
- ✅ 正确解析响应数据
- ✅ 处理 API 错误响应

如果 API 返回格式与预期不符，请检查：
1. `lib/features/club/services/` 中的服务实现
2. API 响应的数据结构
3. 模型类的字段映射

---

## 常见问题

### Q1: 页面显示空白
**A**: 检查 API 是否返回数据，查看控制台日志。

### Q2: 图表不显示
**A**: 确保 `fl_chart` 包已安装，数据格式正确。

### Q3: Markdown 不渲染
**A**: 确保 `flutter_markdown` 包已安装。

### Q4: 路由跳转失败
**A**: 检查路由是否在 `router.dart` 中正确注册。

### Q5: 深色模式颜色不对
**A**: 检查是否使用了 `Theme.of(context).brightness` 判断。

---

## 后续优化建议

1. **批量操作**: 添加批量删除、批量导出功能
2. **搜索功能**: 为文章、分类、应用添加搜索
3. **数据导出**: 添加导出为 Excel/CSV 功能
4. **实时刷新**: 使用 WebSocket 实现数据实时更新
5. **权限细化**: 实现更精细的权限控制（RBAC）
6. **操作日志**: 记录所有管理操作的审计日志
7. **数据备份**: 添加数据备份和恢复功能
8. **多语言**: 支持国际化（i18n）

---

## 文件清单

```
lib/ui/pages/memberPages/
├── admin_portal_page.dart              # 社团管理主入口
├── article_management_page.dart         # 文章管理
├── category_management_page.dart        # 分类管理
├── data_dashboard_page.dart             # 数据统计仪表板
├── logs_monitoring_page.dart            # 日志监控
├── client_app_management_page.dart      # 客户端应用管理
├── department_page.dart                 # 部门管理（已有）
├── project_page.dart                    # 项目管理（已有）
├── task_page.dart                       # 任务管理（已有）
├── resource_page.dart                   # 资源管理（已有）
├── member_data_page.dart                # 成员数据（已有）
└── staff_data_page.dart                 # 部员数据（已有）

lib/routes/
└── router.dart                          # 路由配置（已更新）
```

---

## 联系方式

如有问题或建议，请联系开发团队或查看项目文档。

---

**版本**: 1.0.0
**最后更新**: 2026-01-13
**作者**: Claude Code
**许可证**: MIT
