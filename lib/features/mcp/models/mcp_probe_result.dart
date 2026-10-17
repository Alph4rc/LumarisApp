import 'mcp_tool.dart';

/// 连通性探测失败的原因分类。
enum McpProbeFailure {
  unauthorized,
  forbidden,
  rateLimited,
  network,
  server,
  protocol,
  unexpected,
}

/// 一次 MCP 连通性探测的结果。
class McpProbeResult {
  const McpProbeResult({
    this.failure,
    this.serverName = '',
    this.serverVersion = '',
    this.protocolVersion = '',
    this.tools = const <McpTool>[],
    this.detail,
  });

  /// 为 null 表示探测成功。
  final McpProbeFailure? failure;

  final String serverName;
  final String serverVersion;
  final String protocolVersion;
  final List<McpTool> tools;

  /// 便于排查的诊断信息；不得包含令牌。
  final String? detail;

  bool get isSuccess => failure == null;
}
