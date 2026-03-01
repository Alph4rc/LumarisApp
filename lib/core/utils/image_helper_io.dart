import 'dart:io';
import 'package:flutter/material.dart';

Widget getImage(String path,
    {BoxFit? fit,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder}) {
  final file = File(path);
  if (file.existsSync()) {
    return Image.file(
      file,
      fit: fit,
      errorBuilder: errorBuilder ?? (context, error, stackTrace) => Container(),
    );
  }
  return Container();
}
