/// 跨模块共享的 API 端点常量。
class ApiEndpoints {
  const ApiEndpoints._();

  /// Luminous（光序基础后端）主机地址。
  static const String luminousHost = 'https://luminous.xauat.site';

  /// Luminous MCP Server 路径（Streamable HTTP，仅 POST）。
  static const String luminousMcpPath = '/mcp';

  /// Luminous MCP Server 完整地址。
  static const String luminousMcp = '$luminousHost$luminousMcpPath';
}
