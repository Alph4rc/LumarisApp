import 'package:flutter/material.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.content,
    required this.confirmText,
    required this.cancelText,
  });

  factory PermissionDialog.rationale({
    String? title,
    String? content,
    String? confirmText,
    String? cancelText,
  }) {
    return PermissionDialog(
      title: title ?? '需要权限',
      content: content ?? '该功能需要您授予相应权限才能正常使用',
      confirmText: confirmText ?? '去授权',
      cancelText: cancelText ?? '取消',
    );
  }

  factory PermissionDialog.settingsRedirect({
    String? title,
    String? content,
    String? settingsText,
    String? cancelText,
  }) {
    return PermissionDialog(
      title: title ?? '权限已拒绝',
      content: content ?? '该权限已被永久拒绝，请前往系统设置手动开启',
      confirmText: settingsText ?? '去设置',
      cancelText: cancelText ?? '取消',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
