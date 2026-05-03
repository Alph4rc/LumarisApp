import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/features/education/services/app_service.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';
import 'package:ios_club_app/routes/router.dart';
import 'package:ios_club_app/state/settings_store.dart';
import 'package:ios_club_app/platform/android/download_service.dart';
import 'package:ios_club_app/ui/components/club_list_tile.dart';
import 'package:ios_club_app/ui/components/platform_dialog.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:ios_club_app/features/system/update/check_update_manager.dart';

class VersionSetting extends ConsumerStatefulWidget {
  const VersionSetting({super.key});

  @override
  ConsumerState<VersionSetting> createState() => _VersionSettingState();
}

class _VersionSettingState extends ConsumerState<VersionSetting> {
  late bool isNeedUpdate = false;
  late String version = '';
  late String newVersion = '';
  int tapCount = 0;
  DateTime? lastTapTime;

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((packageInfo) {
      setState(() {
        version = packageInfo.version;
        if (PlatformUtils.isAndroid) {
          CheckUpdateManager.checkForUpdates().then((res) {
            isNeedUpdate = res.$1;
            if (res.$1) {
              newVersion = res.$2.name;
            }
          });
        }
      });
    });
  }

  void _handleTap() {
    final now = DateTime.now();
    if (lastTapTime == null ||
        now.difference(lastTapTime!) > const Duration(seconds: 1)) {
      // 重置计数器
      tapCount = 0;
    }

    tapCount++;
    lastTapTime = now;

    if (tapCount >= 5) {
      // 显示彩蛋页面
      AppRouter.push(AppRoutes.egg);

      // 重置计数器
      tapCount = 0;
      lastTapTime = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsStoreProvider);
    final settingsStore = ref.read(settingsStoreProvider.notifier);
    final colors = context.clubColors;

    return Column(
      children: [
        ClubListTile(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          leading: isNeedUpdate
              ? Badge(
                  backgroundColor: colors.danger,
                  child: Icon(
                    Icons.update,
                    size: 20,
                  ),
                )
              : Icon(Icons.verified, size: 20, color: colors.success),
          title: const Text('版本'),
          subtitle: Text(version),
          subtitleTextStyle: TextStyle(
            fontSize: 13,
            color: colors.secondaryLabel,
          ),
          onTap: () async {
            _handleTap(); // 处理点击事件

            if (isNeedUpdate) {
              final result = await PlatformDialog.showConfirmDialog(
                context,
                title: '是否更新最新版本: $newVersion',
                content: '发现新版本可用，是否立即更新？',
                confirmText: '是的',
                cancelText: '不要',
              );

              if (result == true) {
                final a = await AppService.getReleases();
                if (context.mounted) {
                  UpdateManager.showUpdateWithProgress(context, a.name);
                }
              }
            }
          },
        ),
        if (CheckUpdateManager.shouldCheckForUpdates())
          ClubListTile(
            contentPadding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            leading: Icon(
              Icons.update,
              size: 20,
              color: colors.warning,
            ),
            title: const Text('更新日志'),
            subtitle: const Text('忽略版本更新'),
            subtitleTextStyle: TextStyle(
              fontSize: 12,
              color: colors.secondaryLabel,
            ),
            trailing: CupertinoSwitch(
              value: settings.updateIgnored,
              onChanged: (bool value) async {
                await settingsStore.setUpdateIgnored(value);
              },
            ),
          ),
      ],
    );
  }
}
