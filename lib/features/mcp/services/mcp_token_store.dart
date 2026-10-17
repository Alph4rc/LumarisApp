import 'package:ios_club_app/core/services/secure_storage_service.dart';
import 'package:ios_club_app/features/mcp/mcp_constants.dart';

import 'mcp_config_generator.dart';

/// 光序 MCP Bearer Token 的安全存储封装。
class McpTokenStore {
  const McpTokenStore();

  Future<String?> read() async {
    final raw = await SecureStorageService.instance.read(
      key: McpConstants.tokenStorageKey,
    );
    return McpConfigGenerator.normalizeToken(raw ?? '');
  }

  /// 归一化后非空则写入；空字符串等价于清除。
  Future<bool> save(String token) {
    final normalized = McpConfigGenerator.normalizeToken(token);
    if (normalized == null) {
      return clear();
    }

    return SecureStorageService.instance.write(
      key: McpConstants.tokenStorageKey,
      value: normalized,
    );
  }

  Future<bool> clear() {
    return SecureStorageService.instance.delete(
      key: McpConstants.tokenStorageKey,
    );
  }
}
