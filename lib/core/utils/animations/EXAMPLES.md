# 动画系统快速示例

## 🚀 快速开始

### 1. 导入动画包

```dart
import 'package:ios_club_app/core/utils/animations/animations.dart';
```

## 📱 实际应用示例

### 示例 1：饭卡余额页面动画

```dart
// payment_page.dart 实际使用

// 1. 余额卡片进入动画
Widget _buildStatCard(String title, double amount, IconData icon, Color color) {
  return AnimatedCard(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: YourCardContent(),
    ),
  );
}

// 2. 交易记录列表动画
ListView.builder(
  itemCount: records.length,
  itemBuilder: (context, index) => AnimatedListItem(
    index: index,
    child: _buildTransactionItem(records[index]),
  ),
)

// 3. 绑定按钮交互反馈
AnimatedButton(
  onTap: () => showBindDialog(),
  child: CupertinoButton(
    color: CupertinoColors.activeBlue,
    child: Text('绑定饭卡'),
    onPressed: null, // 由 AnimatedButton 处理
  ),
)
```

### 示例 2：成绩页面动画

```dart
// score_page.dart 实际使用

// 1. 学期卡片动画
Widget _buildSemesterCard(ScoreList score) {
  return AnimatedCard(
    child: ClubCard(
      child: Column(
        children: [
          Text('2023-2024学年 第1学期'),
          ListView.builder(
            itemCount: score.list.length,
            itemBuilder: (context, index) => AnimatedListItem(
              index: index,
              child: _buildScoreItem(score.list[index]),
            ),
          ),
        ],
      ),
    ),
  );
}
```

### 示例 3：首页功能磁贴动画

```dart
// tiles_widget.dart 实际使用

GridView.custom(
  childrenDelegate: SliverChildBuilderDelegate(
    (context, index) => AnimatedCard(
      delay: Duration(milliseconds: 100 * index), // 瀑布流效果
      child: buildTile(tiles[index]),
    ),
    childCount: tiles.length,
  ),
)
```

## 🎯 常见场景

### 场景 1：简单列表页面

```dart
class MyListPage extends StatelessWidget {
  final List<String> items = ['Item 1', 'Item 2', 'Item 3'];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          child: ListTile(
            title: Text(items[index]),
          ),
        );
      },
    );
  }
}
```

**效果：**
- Item 1 立即出现
- Item 2 延迟 50ms
- Item 3 延迟 100ms
- 每项从下往上滑入 + 淡入

### 场景 2：卡片网格

```dart
class CardGridPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        spacing: 16,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return AnimatedCard(
          delay: Duration(milliseconds: 50 * index),
          child: Card(
            child: Center(child: Text('Card $index')),
          ),
        );
      },
    );
  }
}
```

**效果：**
- 6 个卡片依次出现
- 每个卡片滑入 + 缩放 + 淡入
- 瀑布流延迟创造视觉层次

### 场景 3：可点击的卡片列表

```dart
class InteractiveCardList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          child: InteractiveCard(
            onTap: () => print('Tapped card $index'),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Tap me $index'),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

**效果：**
- 列表项依次出现（进入动画）
- 点击时卡片缩小到 0.95（按压反馈）
- 松开恢复原大小

### 场景 4：带加载状态的页面

```dart
class DataPage extends StatefulWidget {
  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  bool isLoading = true;
  String data = '';

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isLoading = false;
      data = 'Loaded data!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedCard(
      child: ShimmerLoading(
        isLoading: isLoading,
        skeleton: CardSkeleton(height: 200),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(data),
          ),
        ),
      ),
    );
  }
}
```

**效果：**
- 打开页面：卡片滑入 + 显示闪光骨架屏
- 2 秒后：骨架屏淡出，真实内容淡入
- 过渡平滑自然

### 场景 5：表单按钮

```dart
class FormPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(labelText: '用户名'),
        ),
        SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(labelText: '密码'),
          obscureText: true,
        ),
        SizedBox(height: 24),
        AnimatedButton(
          onTap: () => submitForm(),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '登录',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  void submitForm() {
    print('Form submitted');
  }
}
```

**效果：**
- 按下按钮：缩小到 0.95
- 松开：恢复到 1.0
- 点击触发 submitForm

### 场景 6：设置页面列表

```dart
class SettingsPage extends StatelessWidget {
  final List<String> settings = [
    '账号设置',
    '隐私设置',
    '通知设置',
    '关于我们',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: settings.length,
      itemBuilder: (context, index) {
        return AnimatedListItem(
          index: index,
          child: AnimatedButton(
            onTap: () => navigateTo(settings[index]),
            child: ListTile(
              title: Text(settings[index]),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        );
      },
    );
  }

  void navigateTo(String setting) {
    print('Navigate to $setting');
  }
}
```

**效果：**
- 列表项依次滑入（进入动画）
- 点击列表项时有按压反馈
- 视觉反馈清晰

## 🎨 动画组合技巧

### 组合 1：进入动画 + 交互反馈

```dart
// ❌ 不推荐 - 过度嵌套
AnimatedCard(
  child: AnimatedListItem(
    index: 0,
    child: InteractiveCard(
      child: content,
    ),
  ),
)

// ✅ 推荐 - 分别应用
// 方案 1：列表 + 交互
AnimatedListItem(
  index: index,
  child: InteractiveCard(
    onTap: onTap,
    child: content,
  ),
)

// 方案 2：卡片 + 交互（独立卡片场景）
AnimatedCard(
  child: InteractiveCard(
    onTap: onTap,
    child: content,
  ),
)
```

### 组合 2：自定义延迟

```dart
// 首页快捷功能磁贴
// 每个磁贴延迟 100ms
GridView.builder(
  itemBuilder: (context, index) => AnimatedCard(
    delay: Duration(milliseconds: 100 * index),
    child: Tile(),
  ),
)

// 详情页的多个卡片
// 第一个卡片无延迟，后续递增
Column(
  children: [
    AnimatedCard(child: Card1()),
    AnimatedCard(delay: Duration(milliseconds: 100), child: Card2()),
    AnimatedCard(delay: Duration(milliseconds: 200), child: Card3()),
  ],
)
```

### 组合 3：桌面端悬停效果

```dart
// 桌面端使用 HoverCard
PlatformUtils.isDesktop
  ? HoverCard(
      onTap: onTap,
      child: content,
    )
  : InteractiveCard(
      onTap: onTap,
      child: content,
    )
```

## 📏 时长选择指南

| 场景 | 推荐时长 | 理由 |
|------|----------|------|
| 按钮按压 | 200ms | 需要快速响应 |
| 列表项���现 | 300-400ms | 平衡速度和观感 |
| 卡片进入 | 400ms | 复杂动画需要时间 |
| 进度条变化 | 600-1000ms | 让用户看清变化 |
| 骨架屏闪光 | 1500ms | 循环动画不宜过快 |

## 🎯 性能优化建议

### 1. 限制列表延迟

```dart
// ✅ 自动限制
AnimatedListItem(
  index: index, // 自动计算延迟，最大 400ms
  child: item,
)

// ❌ 避免
AnimatedCard(
  delay: Duration(milliseconds: 1000 * index), // 可能过长
  child: item,
)
```

### 2. 使用 const

```dart
// ✅ 性能更好
const AnimatedListItem(
  index: 0,
  child: const MyWidget(),
)

// ✅ 也可以
AnimatedListItem(
  index: index, // 动态值不能 const
  child: const MyWidget(), // 子组件可以
)
```

### 3. 避免在大列表中使用复杂动画

```dart
// ✅ 大列表（>50项）
ListView.builder(
  itemBuilder: (context, index) {
    if (index < 10) {
      // 只为前 10 项添加动画
      return AnimatedListItem(index: index, child: item);
    }
    return item;
  },
)

// ❌ 避免
ListView.builder(
  itemCount: 1000,
  itemBuilder: (context, index) => AnimatedCard( // 过多动画
    child: InteractiveCard( // 嵌套过深
      child: HoverCard( // 不必要
        child: item,
      ),
    ),
  ),
)
```

## 🔍 调试技巧

### 查看动画效果

```dart
// 1. 减慢动画速度（开发模式）
timeDilation = 2.0; // 2x 慢速播放

// 2. 添加日志
AnimatedCard(
  child: Builder(
    builder: (context) {
      print('Card built at ${DateTime.now()}');
      return YourCard();
    },
  ),
)

// 3. 使用 Flutter DevTools
// Performance -> Timeline 查看动画性能
```

## 💡 小贴士

1. **渐进增强** - 先实现功能，再添加动画
2. **测试真机** - 动画在模拟器和真机上表现可能不同
3. **用户可控** - 考虑添加"减少动画"选项
4. **保持一致** - 相同类型的元素使用相同的动画
5. **适度使用** - 不是所有地方都需要动画

## 🎓 学习资源

- [Apple HIG - Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [Material Design - Motion](https://m3.material.io/styles/motion)
- [Flutter Animation Docs](https://docs.flutter.dev/ui/animations)
- 本项目 README: `lib/core/utils/animations/README.md`
