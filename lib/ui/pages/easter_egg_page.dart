import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.clubColors;
    return Scaffold(
      appBar: ClubAppBar(
        title: '🎉 彩蛋',
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.egg,
                size: 100,
                color: colors.warning,
              ),
              const SizedBox(height: 20),
              const Text(
                '恭喜你发现了隐藏彩蛋！',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                '你是少数知道这个秘密的人之一！\n\n'
                '感谢你对 iOS Club App 的喜爱与支持。\n\n'
                '继续探索，也许还有更多惊喜等着你...',
                style: TextStyle(
                  fontSize: 16,
                ),
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
