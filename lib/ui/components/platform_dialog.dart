import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';

class PlatformDialogAction<T> {
  const PlatformDialogAction({
    required this.label,
    this.value,
    this.isDestructiveAction = false,
    this.isDefaultAction = false,
    this.autoPop = true,
    this.onPressed,
  });

  final String label;
  final T? value;
  final bool isDestructiveAction;
  final bool isDefaultAction;
  final bool autoPop;
  final FutureOr<void> Function()? onPressed;
}

/// 一个跨平台的对话框组件
/// 在 iOS 和 macOS 上使用 Cupertino 风格，在其他平台上使用 Material 风格
class PlatformDialog {
  static bool get _useCupertino =>
      !PlatformUtils.isWeb && (PlatformUtils.isIOS || PlatformUtils.isMacOS);

  /// 显示一个确认对话框
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) async {
    return showCustomDialog<bool>(
      context,
      title: title,
      content: Text(content),
      actions: [
        PlatformDialogAction<bool>(
          label: cancelText ?? '取消',
          value: false,
        ),
        PlatformDialogAction<bool>(
          label: confirmText ?? '确认',
          value: true,
          isDefaultAction: true,
        ),
      ],
    );
  }

  /// 显示一个带输入框的对话框
  static Future<String?> showInputDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? hintText,
    String? confirmText,
    String? cancelText,
  }) async {
    if (_useCupertino) {
      return _showCupertinoInputDialog(
        context,
        title: title,
        content: content,
        hintText: hintText,
        confirmText: confirmText,
        cancelText: cancelText,
      );
    }
    return _showMaterialInputDialog(
      context,
      title: title,
      content: content,
      hintText: hintText,
      confirmText: confirmText,
      cancelText: cancelText,
    );
  }

  /// 显示一个支持自定义内容和操作按钮的跨平台对话框
  static Future<T?> showCustomDialog<T>(
    BuildContext context, {
    String? title,
    Widget? content,
    List<PlatformDialogAction<T>> actions = const [],
    bool barrierDismissible = true,
  }) async {
    if (_useCupertino) {
      return showCupertinoDialog<T>(
        context: context,
        barrierDismissible: barrierDismissible,
        builder: (BuildContext dialogContext) {
          return CupertinoAlertDialog(
            title: title == null ? null : Text(title),
            content: content,
            actions: _buildCupertinoActions(dialogContext, actions),
          );
        },
      );
    }

    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: title == null ? null : Text(title),
          content: content,
          actions: _buildMaterialActions(dialogContext, actions),
        );
      },
    );
  }

  static List<Widget> _buildMaterialActions<T>(
    BuildContext context,
    List<PlatformDialogAction<T>> actions,
  ) {
    return actions
        .map(
          (action) => TextButton(
            style: action.isDestructiveAction
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            onPressed: () => _handleActionPressed(
              context,
              action,
            ),
            child: Text(action.label),
          ),
        )
        .toList();
  }

  static List<Widget> _buildCupertinoActions<T>(
    BuildContext context,
    List<PlatformDialogAction<T>> actions,
  ) {
    return actions
        .map(
          (action) => CupertinoDialogAction(
            isDestructiveAction: action.isDestructiveAction,
            isDefaultAction: action.isDefaultAction,
            onPressed: () => _handleActionPressed(
              context,
              action,
            ),
            child: Text(action.label),
          ),
        )
        .toList();
  }

  static Future<void> _handleActionPressed<T>(
    BuildContext context,
    PlatformDialogAction<T> action,
  ) async {
    if (action.autoPop) {
      Navigator.of(context).pop(action.value);
    }
    await action.onPressed?.call();
  }

  /// 显示 Material 风格的输入对话框
  static Future<String?> _showMaterialInputDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? hintText,
    String? confirmText,
    String? cancelText,
  }) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (content != null) Text(content),
              TextField(
                controller: controller,
                decoration: InputDecoration(hintText: hintText),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text(cancelText ?? '取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(confirmText ?? '确认'),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        );
      },
    );
  }

  /// 显示 Cupertino 风格的输入对话框
  static Future<String?> _showCupertinoInputDialog(
    BuildContext context, {
    required String title,
    String? content,
    String? hintText,
    String? confirmText,
    String? cancelText,
  }) async {
    final TextEditingController controller = TextEditingController();
    return showCupertinoDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (content != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(content),
                ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: CupertinoTextField(
                  controller: controller,
                  placeholder: hintText,
                ),
              ),
            ],
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text(cancelText ?? '取消'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            CupertinoDialogAction(
              child: Text(confirmText ?? '确认'),
              onPressed: () => Navigator.of(context).pop(controller.text),
            ),
          ],
        );
      },
    );
  }
}
