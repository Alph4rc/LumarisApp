import 'package:mpflutter_build_tools/main.dart' as build_tools;

void main(List<String> arguments) async {
  final buildArgs = List<String>.from(arguments)
    ..add('--wechat')
    ..add('--no-tree-shake-icons');
  build_tools.main(buildArgs);
}
