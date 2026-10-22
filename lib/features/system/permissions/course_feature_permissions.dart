import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/core/services/permission_service.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 需要集中引导授权的课程相关功能。
enum CourseFeaturePermission {
  /// 课表提醒：通知、精确闹钟与后台运行。
  reminder,

  /// 课程小组件：后台运行，保证桌面小组件能持续刷新。
  widget,
}

/// 课表提醒 / 课程小组件所需的系统权限。
///
/// 这里只负责权限的声明、读取与申请，不直接改动业务开关；具体功能是否可用
/// 仍由调用方根据返回结果决定。
class CourseFeaturePermissions {
  const CourseFeaturePermissions._();

  static const Map<CourseFeaturePermission, List<Permission>> _requirements = {
    CourseFeaturePermission.reminder: [
      Permission.notification,
      Permission.scheduleExactAlarm,
      Permission.ignoreBatteryOptimizations,
    ],
    CourseFeaturePermission.widget: [Permission.ignoreBatteryOptimizations],
  };

  static List<Permission> requiredFor(CourseFeaturePermission feature) {
    return List<Permission>.unmodifiable(
      _requirements[feature] ?? const <Permission>[],
    );
  }

  static bool isGranted(PermissionStatus? status) {
    return status == PermissionStatus.granted ||
        status == PermissionStatus.limited ||
        status == PermissionStatus.provisional;
  }

  static bool allGranted(Iterable<PermissionStatus> statuses) {
    final values = statuses.toList(growable: false);
    return values.isNotEmpty && values.every(isGranted);
  }

  static int grantedCount(Iterable<PermissionStatus> statuses) {
    return statuses.where(isGranted).length;
  }

  /// 读取功能所需权限的当前状态。
  ///
  /// 单个权限读取失败时按“未授权”处理，避免整个入口不可用。
  static Future<Map<Permission, PermissionStatus>> load(
    CourseFeaturePermission feature,
  ) async {
    final statuses = <Permission, PermissionStatus>{};

    for (final permission in requiredFor(feature)) {
      try {
        statuses[permission] = await permission.status;
      } catch (error, stackTrace) {
        statuses[permission] = PermissionStatus.denied;
        AppLogger.error(
          'Failed to read permission status for $permission',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return statuses;
  }

  /// 依次申请尚未授予的权限，返回是否全部授权成功。
  ///
  /// 精确闹钟、忽略电池优化在部分 Android 版本上会跳转系统设置页，
  /// 因此逐个申请，避免批量申请时被系统打断后丢失其余权限。
  static Future<bool> requestMissing(
    BuildContext context,
    CourseFeaturePermission feature,
  ) async {
    var granted = true;

    for (final permission in requiredFor(feature)) {
      PermissionStatus status;
      try {
        status = await permission.status;
      } catch (error, stackTrace) {
        granted = false;
        AppLogger.error(
          'Failed to read permission status for $permission',
          error: error,
          stackTrace: stackTrace,
        );
        continue;
      }

      if (isGranted(status)) {
        continue;
      }

      if (!context.mounted) {
        return false;
      }

      final result = await PermissionService.request(
        permission,
        context: context,
        dialogTitle: labelFor(context, permission),
        dialogContent: descriptionFor(context, permission),
        settingsText: context.l10n.goToSettings,
      );

      // 已经跳转系统设置时不要继续申请后续权限，等用户返回后由页面刷新状态。
      if (result.isPermanentlyDenied || result.isRestricted) {
        return false;
      }

      if (!isGranted(result)) {
        granted = false;
      }
    }

    return granted;
  }

  static String labelFor(BuildContext context, Permission permission) {
    final l10n = context.l10n;

    return switch (permission) {
      Permission.notification => l10n.permissionNotificationTitle,
      Permission.scheduleExactAlarm => l10n.permissionExactAlarmTitle,
      Permission.ignoreBatteryOptimizations => l10n.permissionBatteryTitle,
      _ => l10n.permissionManagement,
    };
  }

  static String descriptionFor(BuildContext context, Permission permission) {
    final l10n = context.l10n;

    return switch (permission) {
      Permission.notification => l10n.permissionNotificationDesc,
      Permission.scheduleExactAlarm => l10n.permissionExactAlarmDesc,
      Permission.ignoreBatteryOptimizations => l10n.permissionBatteryDesc,
      _ => l10n.permissionRequiredContent,
    };
  }
}
