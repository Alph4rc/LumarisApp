import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:ios_club_app/core/services/network_exception.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client_manager.dart';
import 'package:ios_club_app/features/mcp/mcp_constants.dart';
import 'package:ios_club_app/features/mcp/models/mcp_probe_result.dart';
import 'package:ios_club_app/features/mcp/models/mcp_tool.dart';

import 'mcp_config_generator.dart';

/// 通过 Streamable HTTP 对光序 MCP Server 做一次最小握手与工具枚举。
class McpProbeService {
  McpProbeService({BasicHttpClient? client})
    : _client = client ?? BasicHttpClientManager.instance;

  final BasicHttpClient _client;

  Future<McpProbeResult> probe({String? token}) async {
    final normalized = McpConfigGenerator.normalizeToken(token ?? '');
    final options = _options(normalized);

    try {
      final initializeBody = _decode(
        await _client.post(
          McpConstants.path,
          data: <String, dynamic>{
            'jsonrpc': '2.0',
            'id': 1,
            'method': 'initialize',
            'params': <String, dynamic>{
              'protocolVersion': McpConstants.protocolVersion,
              'capabilities': <String, dynamic>{},
              'clientInfo': <String, dynamic>{
                'name': McpConstants.clientName,
                'version': McpConstants.clientVersion,
              },
            },
          },
          options: options,
        ),
      );

      final initializeError = _jsonRpcError(initializeBody);
      if (initializeError != null) {
        return McpProbeResult(
          failure: McpProbeFailure.protocol,
          detail: initializeError,
        );
      }

      // 标准 MCP 握手通知；无 id，服务端返回 202 或空 body。
      await _client.post(
        McpConstants.path,
        data: <String, dynamic>{
          'jsonrpc': '2.0',
          'method': 'notifications/initialized',
        },
        options: options,
      );

      final toolsBody = _decode(
        await _client.post(
          McpConstants.path,
          data: <String, dynamic>{
            'jsonrpc': '2.0',
            'id': 2,
            'method': 'tools/list',
            'params': <String, dynamic>{},
          },
          options: options,
        ),
      );

      final toolsError = _jsonRpcError(toolsBody);
      if (toolsError != null) {
        return McpProbeResult(
          failure: McpProbeFailure.protocol,
          detail: toolsError,
        );
      }

      final result = toolsBody['result'];
      if (result is! Map) {
        return const McpProbeResult(failure: McpProbeFailure.protocol);
      }

      final rawTools = result['tools'];
      final tools = rawTools is List
          ? rawTools
                .whereType<Map>()
                .map(
                  (item) => McpTool.fromJson(Map<String, dynamic>.from(item)),
                )
                .where((tool) => tool.name.isNotEmpty)
                .toList()
          : const <McpTool>[];

      final initializeResult = initializeBody['result'];
      final serverInfo = initializeResult is Map
          ? initializeResult['serverInfo']
          : null;

      return McpProbeResult(
        serverName: serverInfo is Map
            ? (serverInfo['name'] as String? ?? '')
            : '',
        serverVersion: serverInfo is Map
            ? (serverInfo['version'] as String? ?? '')
            : '',
        protocolVersion: initializeResult is Map
            ? (initializeResult['protocolVersion'] as String? ?? '')
            : '',
        tools: tools,
      );
    } on AuthenticationException catch (error) {
      return McpProbeResult(
        failure: McpProbeFailure.unauthorized,
        detail: error.message,
      );
    } on AuthorizationException catch (error) {
      return McpProbeResult(
        failure: McpProbeFailure.forbidden,
        detail: error.message,
      );
    } on NotFoundException catch (error) {
      return McpProbeResult(
        failure: McpProbeFailure.protocol,
        detail: error.message,
      );
    } on ServerException catch (error) {
      return McpProbeResult(
        failure: McpProbeFailure.server,
        detail: error.message,
      );
    } on TimeoutException {
      return const McpProbeResult(failure: McpProbeFailure.network);
    } on NetworkException catch (error) {
      return McpProbeResult(
        failure: _failureForNetworkError(error),
        detail: error.message,
      );
    } on FormatException catch (error) {
      return McpProbeResult(
        failure: McpProbeFailure.protocol,
        detail: error.message,
      );
    } catch (error) {
      return McpProbeResult(
        failure: McpProbeFailure.unexpected,
        detail: error.toString(),
      );
    }
  }

  Options _options(String? token) {
    return Options(
      headers: <String, dynamic>{
        'Accept': McpConstants.acceptHeader,
        'Content-Type': 'application/json',
        'Mcp-Protocol-Version': McpConstants.protocolVersion,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      contentType: Headers.jsonContentType,
      receiveTimeout: const Duration(seconds: 15),
    );
  }

  McpProbeFailure _failureForNetworkError(NetworkException error) {
    if (error.statusCode == 429) {
      return McpProbeFailure.rateLimited;
    }
    if (error.statusCode != null && error.statusCode! >= 500) {
      return McpProbeFailure.server;
    }
    return McpProbeFailure.network;
  }

  String? _jsonRpcError(Map<String, dynamic> body) {
    final error = body['error'];
    if (error is! Map) {
      return null;
    }

    final code = error['code'];
    final message = error['message'];
    return '${code ?? 'unknown'}: ${message ?? 'JSON-RPC error'}';
  }

  Map<String, dynamic> _decode(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    if (data is String) {
      final text = data.trim();
      if (text.isEmpty) {
        return const <String, dynamic>{};
      }

      if (text.startsWith('event:') || text.startsWith('data:')) {
        for (final line in const LineSplitter().convert(text)) {
          if (!line.startsWith('data:')) {
            continue;
          }
          final payload = line.substring(5).trim();
          if (payload.isEmpty) {
            continue;
          }
          final decoded = jsonDecode(payload);
          if (decoded is Map) {
            return Map<String, dynamic>.from(decoded);
          }
        }
        throw const FormatException('No JSON data in SSE response');
      }

      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    }

    throw const FormatException('Unsupported MCP response');
  }
}
