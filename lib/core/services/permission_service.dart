import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ios_club_app/ui/components/permission_dialog.dart';

export 'package:permission_handler/permission_handler.dart' show Permission, PermissionStatus;

class PermissionService {
  /// 请求单个权限，支持回调处理不同结果。
  ///
  /// 传入 [context] 时，会在需要时弹出 rationale 说明对话框或引导去设置的对话框。
  static Future<PermissionStatus> request(
    Permission permission, {
    VoidCallback? onGranted,
    VoidCallback? onDenied,
    VoidCallback? onPermanentlyDenied,
    VoidCallback? onRestricted,
    String? dialogTitle,
    String? dialogContent,
    String? settingsText,
    String? cancelText,
    BuildContext? context,
  }) async {
    final status = await permission.status;

    // 已授权，直接回调
    if (status == PermissionStatus.granted ||
        status == PermissionStatus.limited ||
        status == PermissionStatus.provisional) {
      onGranted?.call();
      return status;
    }

    // 已被永久拒绝，引导去设置
    if (status == PermissionStatus.permanentlyDenied) {
      if (context != null && context.mounted) {
        await _showSettingsDialog(
          context,
          title: dialogTitle,
          content: dialogContent,
          settingsText: settingsText,
          cancelText: cancelText,
        );
      }
      onPermanentlyDenied?.call();
      return status;
    }

    // 受限状态（如家长控制）
    if (status == PermissionStatus.restricted) {
      onRestricted?.call();
      return status;
    }

    // 需要显示 rationale 时弹窗说明
    if (await permission.shouldShowRequestRationale &&
        context != null &&
        context.mounted) {
      final proceed = await _showRationaleDialog(
        context,
        title: dialogTitle,
        content: dialogContent,
        confirmText: settingsText,
        cancelText: cancelText,
      );
      if (!proceed) {
        onDenied?.call();
        return status;
      }
    }

    // 发起权限请求
    final result = await permission.request();

    switch (result) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        onGranted?.call();
      case PermissionStatus.permanentlyDenied:
        if (context != null && context.mounted) {
          await _showSettingsDialog(
            context,
            title: dialogTitle,
            content: dialogContent,
            settingsText: settingsText,
            cancelText: cancelText,
          );
        }
        onPermanentlyDenied?.call();
      case PermissionStatus.denied:
        onDenied?.call();
      case PermissionStatus.restricted:
        onRestricted?.call();
    }

    return result;
  }

  /// 批量请求权限（静默，不弹窗）。
  ///
  /// 返回每个权限的最终状态，适用于应用启动时的批量权限请求。
  static Future<Map<Permission, PermissionStatus>> requestMultiple(
    List<Permission> permissions,
  ) async {
    final results = <Permission, PermissionStatus>{};

    final toRequest = <Permission>[];
    for (final permission in permissions) {
      final status = await permission.status;
      results[permission] = status;
      if (status != PermissionStatus.granted) {
        toRequest.add(permission);
      }
    }

    if (toRequest.isNotEmpty) {
      final requestResults = await toRequest.request();
      results.addAll(requestResults);
    }

    return results;
  }

  static Future<bool> _showRationaleDialog(
    BuildContext context, {
    String? title,
    String? content,
    String? confirmText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => PermissionDialog.rationale(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
    return result ?? false;
  }

  static Future<void> _showSettingsDialog(
    BuildContext context, {
    String? title,
    String? content,
    String? settingsText,
    String? cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => PermissionDialog.settingsRedirect(
        title: title,
        content: content,
        settingsText: settingsText,
        cancelText: cancelText,
      ),
    );
    if (result == true) {
      await openAppSettings();
    }
  }
}
