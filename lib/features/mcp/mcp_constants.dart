import 'package:ios_club_app/core/constants/api_endpoints.dart';

/// 光序 MCP 相关常量。
class McpConstants {
  const McpConstants._();

  static const String endpoint = ApiEndpoints.luminousMcp;
  static const String path = ApiEndpoints.luminousMcpPath;

  /// 与 Luminous 生产实例实测可用的协议版本。
  static const String protocolVersion = '2025-06-18';

  static const String clientName = 'ios_club_app';
  static const String clientVersion = '1.0.0';

  /// SecureStorage 中保存 Bearer Token 的 key。
  static const String tokenStorageKey = 'luminous_mcp_token';

  /// 生成的客户端配置里使用的服务名。
  static const String serverName = 'luminous';

  /// Streamable HTTP handler 要求同时接受 JSON 与 SSE。
  static const String acceptHeader = 'application/json, text/event-stream';
}
