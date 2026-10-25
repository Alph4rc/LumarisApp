import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:luamris_ui/luamris_ui.dart';
import 'package:material_ui/material_ui.dart';

/// Debug 专用彩蛋页。
///
/// 路由只在 `kDebugMode` 为 true 时注册；release 构建中该页面不会被引用，
/// 文案也会随 tree-shaking 一并移除，不会出现在提交给 App Store 的产物里。
class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  static const String _title = '🎉 彩蛋';
  static const String _found = '恭喜你发现了隐藏彩蛋！';
  static const String _content = '你是少数知道这个秘密的人之一！\n\n'
      '感谢你对光序的喜爱与支持。\n\n'
      '继续探索，也许还有更多惊喜等着你...';

  @override
  Widget build(BuildContext context) {
    final colors = context.mc.colors;
    return Scaffold(
      appBar: McAppBar(title: _title),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.egg, size: 100, color: colors.warning),
              const SizedBox(height: 20),
              const Text(
                _found,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                _content,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CupertinoButton.filled(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
