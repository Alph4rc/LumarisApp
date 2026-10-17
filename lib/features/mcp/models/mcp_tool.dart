/// MCP `tools/list` 返回的单个工具。
///
/// 服务端可能附带 `_meta`、`annotations` 等未知字段，这里只取展示所需的
/// 三项，其余一律忽略。
class McpTool {
  const McpTool({required this.name, this.description = '', this.inputSchema});

  final String name;
  final String description;
  final Map<String, dynamic>? inputSchema;

  factory McpTool.fromJson(Map<String, dynamic> json) {
    final schema = json['inputSchema'];

    return McpTool(
      name: (json['name'] as String?)?.trim() ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
      inputSchema: schema is Map ? Map<String, dynamic>.from(schema) : null,
    );
  }
}
