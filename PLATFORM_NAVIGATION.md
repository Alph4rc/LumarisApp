# 平台导航架构说明

本文档说明 iOS Club App 的多平台导航架构设计。

## 架构概览

应用针对不同平台提供了定制化的导航体验：

```
┌─────────────────────────────────────────────────────────────┐
│                    主应用 (MainApp)                          │
└─────────────────────────────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    ┌───▼───┐         ┌────▼────┐       ┌────▼────┐
    │ macOS │         │ Windows │       │  平板   │
    │  UI   │         │  Linux  │       │         │
    └───┬───┘         └────┬────┘       └────┬────┘
        │                  │                  │
    ┌───▼────────┐    ┌────▼─────────┐  ┌────▼──────────┐
    │ macOS      │    │ Windows 11   │  │ NavigationRail│
    │ Native     │    │ Fluent       │  │ + Drawer      │
    │ Sidebar    │    │ Design       │  │               │
    └────────────┘    └──────────────┘  └───────────────┘
```

## 平台判断逻辑

### 1. macOS 平台
- **判断条件**: `PlatformUtils.isMacOS`
- **使用组件**: `MacosWindow` + `macosUISidebar`
- **特点**:
  - 原生 macOS UI 风格
  - 可调整大小的侧边栏（180-280px）
  - 原生标题栏（TitleBar）
  - 底部用户信息卡片
  - 使用 `macos_ui` 包提供的原生组件

**文件位置**: [lib/platform/macos/macos_ui_sidebar.dart](lib/platform/macos/macos_ui_sidebar.dart)

### 2. Windows/Linux 平台
- **判断条件**: `PlatformUtils.isWindows` 或 `isLinux`
- **使用组件**: `WindowsSidebar`
- **特点**:
  - Windows 11 Fluent Design 风格
  - Acrylic 毛玻璃效果背景
  - 左侧高亮条表示选中状态
  - 流畅的悬停动画
  - 渐变色 App 图标
  - 280px 固定宽度

**文件位置**: [lib/platform/windows/windows_sidebar.dart](lib/platform/windows/windows_sidebar.dart)

**设计要点**:
```dart
// 背景色 - 模拟 Acrylic 效果
color: isDark
    ? const Color(0xFF202020).withValues(alpha: 0.95)
    : const Color(0xFFF3F3F3).withValues(alpha: 0.95)

// 选中项 - 左侧高亮条
border: isSelected
    ? Border(left: BorderSide(color: primary, width: 3))
    : null
```

### 3. 平板横屏模式
- **判断条件**: `screenWidth > 600 && screenWidth > screenHeight && !isDesktop`
- **使用组件**: `TabletNavigation`（基于 `NavigationRail`）
- **特点**:
  - 可展开/收起的 NavigationRail
  - 顶部 App Logo
  - 渐变色图标容器
  - 大触摸目标（适合触摸操作）
  - 展开宽度 220px，收起宽度 72px

**文件位置**: [lib/platform/tablet/tablet_navigation.dart](lib/platform/tablet/tablet_navigation.dart)

**交互设计**:
- 展开状态：显示图标 + 文字标签
- 收起状态：仅显示图标
- 顶部折叠/展开切换按钮

### 4. 平板竖屏模式
- **判断条件**: `screenWidth > 600 && screenWidth <= screenHeight && !isDesktop`
- **使用组件**: `TabletDrawerNavigation`
- **特点**:
  - 使用 Drawer 抽屉导航
  - 带渐变色的 DrawerHeader
  - 大号触摸目标
  - 280px 抽屉宽度
  - 点击导航项后自动关闭

**文件位置**: [lib/platform/tablet/tablet_navigation.dart](lib/platform/tablet/tablet_navigation.dart)

### 5. 手机平台
- **判断条件**: `screenWidth <= 600`（默认情况）
- **使用组件**: `BottomNavigation`
- **特点**:
  - iOS 风格底部导航栏
  - 流畅的点击动画
  - 支持震动反馈
  - 仅显示前 4 个导航项
  - 72px 高度

**文件位置**: [lib/bottom_navigation.dart](lib/bottom_navigation.dart)

## 代码结构

### 主入口：lib/main_app.dart

```dart
Widget build(BuildContext context) {
  // 1. 获取屏幕尺寸
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // 2. 判断平台类型
  final isMacOS = PlatformUtils.isMacOS;
  final isWindows = PlatformUtils.isWindows;
  final isLinux = !isMacOS && !isWindows && PlatformUtils.isDesktop;

  // 3. 判断设备类型
  final isTablet = screenWidth > 600 && !PlatformUtils.isDesktop;
  final isTabletLandscape = isTablet && screenWidth > screenHeight;
  final isTabletPortrait = isTablet && screenWidth <= screenHeight;

  // 4. 根据条件返回对应组件
  if (isMacOS) return MacosWindow(...);
  if (isWindows || isLinux) return WindowsSidebar(...);
  if (isTabletLandscape) return TabletNavigation(...);
  if (isTabletPortrait) return TabletDrawerNavigation(...);

  return BottomNavigation(...); // 默认手机端
}
```

### 导航项数据模型

```dart
class SidebarDestination {
  final IconData icon;           // 未选中图标
  final IconData selectedIcon;   // 选中图标
  final String label;            // 文字标签
  final String? badge;           // 徽章（可选）
}
```

## 设计原则

### 1. 平台一致性
- **macOS**: 遵循 Apple Human Interface Guidelines
- **Windows**: 遵循 Windows 11 Fluent Design System
- **平板**: 优化触摸交互，大目标区域
- **手机**: 底部导航，单手操作友好

### 2. 响应式布局
- 根据屏幕尺寸自动切换导航模式
- 平板根据横竖屏动态调整
- 支持窗口大小调整（桌面平台）

### 3. 动画流畅性
- 所有交互提供 150-300ms 过渡动画
- 悬停、选中状态平滑切换
- 颜色、尺寸变化使用 AnimatedContainer

### 4. 可访问性
- 所有导航项提供 tooltip
- 支持键盘导航
- 颜色对比度符合 WCAG 标准
- 触摸目标 >= 48dp（移动端）

## 样式定制

### 颜色方案

```dart
// 亮色模式
backgroundColor: Color(0xFFF3F3F3)
selectedColor: Theme.of(context).colorScheme.primary
unselectedColor: Colors.grey[700]

// 暗色模式
backgroundColor: Color(0xFF202020)
selectedColor: Theme.of(context).colorScheme.primary
unselectedColor: Colors.grey[300]
```

### 间距规范

```dart
// Windows 侧边栏
headerHeight: 56
itemPadding: 16 (horizontal), 12 (vertical)
sidebarWidth: 280

// 平板 NavigationRail
minWidth: 72
minExtendedWidth: 220

// 手机底部导航
barHeight: 72
iconSize: 24
```

## 测试建议

### 1. 平台测试
- ✅ macOS: 测试侧边栏调整大小、用户信息显示
- ✅ Windows: 测试 Fluent Design 效果、悬停动画
- ✅ 平板横屏: 测试展开/收起功能
- ✅ 平板竖屏: 测试抽屉导航
- ✅ 手机: 测试底部导航栏

### 2. 响应式测试
```bash
# 测试不同窗口尺寸
# 手机: 375x667, 414x896
# 平板横屏: 1024x768, 1366x1024
# 平板竖屏: 768x1024
# 桌面: 1920x1080, 2560x1440
```

### 3. 主题测试
- 亮色模式和暗色模式切换
- 自定义主题色
- 高对比度模式

## 常见问题

### Q: 为什么 macOS 不使用 WindowsSidebar？
A: macOS 有专门的 `macos_ui` 包，提供原生的 macOS 控件体验，包括可调整大小的侧边栏、原生标题栏等，更符合 macOS 用户习惯。

### Q: 平板如何判断横竖屏？
A: 通过比较 `screenWidth` 和 `screenHeight` 的大小关系：
- 横屏: `width > height`
- 竖屏: `width <= height`

### Q: 如何添加新的导航项？
A: 在 `main_app.dart` 的 `_destinations` 列表中添加新的 `SidebarDestination`，并在 `_routeMap` 中添加对应路由。

### Q: Windows 侧边栏能否调整宽度？
A: 当前 Windows 侧边栏是固定 280px 宽度。如需调整，修改 `WindowsSidebar` 的 `width` 参数。

## 未来优化方向

1. **Linux 专属样式**: 为 Linux 创建符合 GNOME/KDE 设计规范的独立组件
2. **自适应侧边栏**: 支持用户拖拽调整侧边栏宽度（Windows/Linux）
3. **快捷键支持**: 添加键盘快捷键切换导航（Ctrl+1-7）
4. **多窗口支持**: macOS/Windows 支持多窗口
5. **动画优化**: 添加更多微交互动画
6. **暗色模式增强**: 支持多种暗色主题（纯黑、深灰等）

## 相关文件

- [lib/main_app.dart](lib/main_app.dart) - 主应用入口
- [lib/platform/macos/macos_ui_sidebar.dart](lib/platform/macos/macos_ui_sidebar.dart) - macOS 侧边栏
- [lib/platform/windows/windows_sidebar.dart](lib/platform/windows/windows_sidebar.dart) - Windows 侧边栏
- [lib/platform/tablet/tablet_navigation.dart](lib/platform/tablet/tablet_navigation.dart) - 平板导航
- [lib/bottom_navigation.dart](lib/bottom_navigation.dart) - 手机底部导航
- [lib/modern_sidebar.dart](lib/modern_sidebar.dart) - 通用侧边栏数据模型
- [lib/core/utils/platform_utils.dart](lib/core/utils/platform_utils.dart) - 平台检测工具

## 维护建议

1. 所有平台组件应保持接口一致性
2. 新增导航项时需同步更新所有平台组件
3. 修改样式时注意保持平台特色
4. 定期测试各平台的显示效果
5. 遵循各平台的设计规范更新

---

**最后更新**: 2025-12-23
**版本**: 1.0.0
