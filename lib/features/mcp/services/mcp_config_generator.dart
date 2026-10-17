import 'dart:convert';

import 'package:ios_club_app/features/mcp/mcp_constants.dart';

/// 生成可粘贴到 MCP 客户端的配置片段。
class McpConfigGenerator {
  const McpConfigGenerator._();

  static final RegExp _whitespace = RegExp(r'\s+');

  /// 归一化用户输入的令牌。
  ///
  /// 去掉首尾空白、误粘贴的 `Bearer ` 前缀，以及令牌中间的换行/空格。
  /// Bearer 凭证本身不允许包含空白，因此删除是安全的。
  static String? normalizeToken(String raw) {
    var value = raw.trim();
    final lower = value.toLowerCase();
    if (lower.startsWith('bearer ')) {
      value = value.substring(7);
    } else if (lower == 'bearer') {
      value = '';
    }
    value = value.replaceAll(_whitespace, '');
    return value.isEmpty ? null : value;
  }

  static Map<String, dynamic> buildConfigMap(String? token) {
    final normalized = normalizeToken(token ?? '');
    final headers = <String, dynamic>{
      if (normalized != null) 'Authorization': 'Bearer $normalized',
    };

    return <String, dynamic>{
      'mcpServers': <String, dynamic>{
        McpConstants.serverName: <String, dynamic>{
          'url': McpConstants.endpoint,
          if (headers.isNotEmpty) 'headers': headers,
        },
      },
    };
  }

  static String buildJson(String? token) {
    return const JsonEncoder.withIndent('  ').convert(buildConfigMap(token));
  }

  static String buildClaudeCodeCommand(String? token) {
    final normalized = normalizeToken(token ?? '');
    final header = normalized == null
        ? ''
        : ' --header "Authorization: Bearer $normalized"';

    return 'claude mcp add --transport http ${McpConstants.serverName} '
        '${McpConstants.endpoint}$header';
  }
}
