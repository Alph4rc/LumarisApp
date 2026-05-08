# 动画系统使用指南

本目录包含光序的统一动画系统，遵循苹果设计规范，提供流畅、一致的用户体验。

## 📦 组件列表

### 1. AppAnimations - 动画配置常量

统一的动画时长和曲线配置。

```dart
import 'package:ios_club_app/core/utils/animations/animations.dart';

// 使用预定义的动画时长
AnimatedContainer(
  duration: AppAnimations.standard,  // 300ms
  curve: AppAnimations.easeOut,
)
```

**可用配置：**
- `fast` (200ms) - 快速交互
- `standard` (300ms) - 标准过渡
- `medium` (400ms) - 复杂过渡
- `slow` (600ms) - 引人注目的效果
- `extraSlow` (1000ms) - 数值变化

**曲线：**
- `defaultCurve` - 标准缓入缓出
- `easeOut` - 用于进入动画
- `easeIn` - 用于退出动画
- `spring` - 弹性效果
- `smooth` - 平滑变化

### 2. AnimatedListItem - 列表项瀑布流动画

为列表项添加从下往上滑入 + 淡入的进入动画。

```dart
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return AnimatedListItem(
      index: index,
      child: YourListItem(item: items[index]),
    );
  },
)
```

**变体：**
- `AnimatedListItem` - 从下往上滑入（默认）
- `AnimatedListItemSlideLeft` - 从左滑入
- `AnimatedListItemScale` - 缩放进入

### 3. AnimatedCard - 卡片进入动画

为卡片添加滑入 + 缩放 + 淡入的组合动画。

```dart
AnimatedCard(
  delay: Duration(milliseconds: 100),  // 可选延迟
  child: ClubCard(
    child: YourContent(),
  ),
)
```

### 4. InteractiveCard - 可交互卡片

带有点击反馈的卡片，按下时轻微缩小。

```dart
InteractiveCard(
  onTap: () => print('Tapped'),
  child: ClubCard(
    child: YourContent(),
  ),
)
```

### 5. AnimatedButton - 按钮交互动画

为任何按钮添加按压反馈动画。

```dart
AnimatedButton(
  onTap: () => handleAction(),
  child: YourButtonWidget(),
)
```

**变体：**
- `AnimatedButton` - 按压缩放（默认）
- `BounceButton` - 弹跳效果
- `FadeButton` - 淡入淡出
- `ScaleTapContainer` - iOS 风格容器

### 6. ShimmerLoading - 骨架屏加载

仿照苹果风格的闪光加载效果。

```dart
ShimmerLoading(
  isLoading: isLoading,
  skeleton: ListItemSkeleton(),  // 可选自定义骨架
  child: YourActualContent(),
)
```

**预设骨架：**
- `ListItemSkeleton` - 列表项骨架
- `CardSkeleton` - 卡片骨架
- `SkeletonBox` - 方形占位符
- `SkeletonCircle` - 圆形占位符
- `SkeletonLine` - 文本行占位符

## 🎨 使用示例

### 示例 1：带动画的列表页面

```dart
import 'package:ios_club_app/core/utils/animations/animations.dart';

class MyListPage extends StatelessWidget {
  final List<Item> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          child: ListTile(
            title: Text(items[index].title),
          ),
        );
      },
    );
  }
}
```

### 示例 2：带加载状态的卡片

```dart
import 'package:ios_club_app/core/utils/animations/animations.dart';

class DataCard extends StatelessWidget {
  final bool isLoading;
  final String data;

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      child: ShimmerLoading(
        isLoading: isLoading,
        skeleton: CardSkeleton(height: 150),
        child: ClubCard(
          child: Text(data),
        ),
      ),
    );
  }
}
```

### 示例 3：可交互的网格项

```dart
import 'package:ios_club_app/core/utils/animations/animations.dart';

GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
  ),
  itemCount: items.length,
  itemBuilder: (context, index) {
    return AnimatedCard(
      delay: Duration(milliseconds: 50 * index),
      child: InteractiveCard(
        onTap: () => handleTap(items[index]),
        child: YourGridItem(),
      ),
    );
  },
)
```

### 示例 4：带反馈的按钮

```dart
import 'package:ios_club_app/core/utils/animations/animations.dart';

AnimatedButton(
  onTap: () => submitForm(),
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text('提交'),
  ),
)
```

## 🎯 设计原则

1. **一致性** - 所有动画使用统一的时长和曲线
2. **自然** - 模仿物理世界的运动规律
3. **适度** - 不过度使用动画，避免干扰用户
4. **性能** - 使用高效的动画实现，避免掉帧

## ⚙️ 最佳实践

### ✅ 推荐做法

```dart
// 使用预定义的配置
AnimatedContainer(
  duration: AppAnimations.standard,
  curve: AppAnimations.easeOut,
)

// 列表项使用瀑布流动画
ListView.builder(
  itemBuilder: (context, index) => AnimatedListItem(
    index: index,
    child: item,
  ),
)

// 卡片添加进入动画
AnimatedCard(child: ClubCard(...))

// 按钮添加交互反馈
AnimatedButton(onTap: ..., child: ...)
```

### ❌ 避免做法

```dart
// ❌ 不要硬编码时长
AnimatedContainer(
  duration: Duration(milliseconds: 237),  // 使用 AppAnimations.standard
)

// ❌ 不要过度嵌套动画
AnimatedCard(
  child: AnimatedListItem(  // 只选择一个
    child: InteractiveCard(  // 或者只用交互动画
      child: ...
    ),
  ),
)

// ❌ 不要在列表中使用相同延迟
ListView.builder(
  itemBuilder: (context, index) => AnimatedCard(
    delay: Duration(milliseconds: 100),  // 应该基于 index 计算
    child: item,
  ),
)
```

## 🚀 性能优化

1. **使用 const 构造函数** - 尽可能使用 const
2. **避免重复构建** - 在 ListView 中使用 AnimatedListItem 而不是为整个列表添加动画
3. **限制最大延迟** - AppAnimations 自动限制列表项延迟不超过 400ms
4. **合理使用动画** - 不是所有元素都需要动画

## 📚 相关资源

- [Apple Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [Flutter Animation Documentation](https://docs.flutter.dev/ui/animations)
- [Material Motion System](https://m3.material.io/styles/motion/overview)
