import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client.dart';
import 'package:ios_club_app/features/mcp/mcp_constants.dart';
import 'package:ios_club_app/features/mcp/models/mcp_probe_result.dart';
import 'package:ios_club_app/features/mcp/services/mcp_probe_service.dart';

typedef _Responder =
    void Function(RequestOptions options, RequestInterceptorHandler handler);

void _respondJson(
  RequestOptions options,
  RequestInterceptorHandler handler,
  Map<String, dynamic> data, {
  int statusCode = 200,
}) {
  handler.resolve(
    Response<dynamic>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}

void _respondValue(
  RequestOptions options,
  RequestInterceptorHandler handler,
  dynamic data, {
  int statusCode = 200,
}) {
  handler.resolve(
    Response<dynamic>(
      requestOptions: options,
      statusCode: statusCode,
      data: data,
    ),
  );
}

Map<String, dynamic> _initializeResponse() {
  return <String, dynamic>{
    'jsonrpc': '2.0',
    'id': 1,
    'result': <String, dynamic>{
      'protocolVersion': '2025-06-18',
      'capabilities': <String, dynamic>{'tools': <String, dynamic>{}},
      'serverInfo': <String, dynamic>{
        'name': 'luminous-mcp-server',
        'version': '1.0.0',
      },
    },
  };
}

Map<String, dynamic> _toolsResponse() {
  return <String, dynamic>{
    'jsonrpc': '2.0',
    'id': 2,
    'result': <String, dynamic>{
      'tools': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'query_school',
          'description': '学校详情',
          'inputSchema': <String, dynamic>{'type': 'object'},
          '_meta': <String, dynamic>{'hidden': true},
        },
        <String, dynamic>{'name': 'list_schools', 'description': '启用学校列表'},
      ],
      'ttlMs': 300000,
      'cacheScope': 'public',
    },
  };
}

BasicHttpClient _client(
  Map<String, _Responder> responders, {
  List<RequestOptions>? captured,
}) {
  final client = BasicHttpClient();
  client.dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        captured?.add(options);
        final body = options.data is Map
            ? Map<String, dynamic>.from(options.data as Map)
            : const <String, dynamic>{};
        final responder = responders[body['method'] as String?];
        if (responder == null) {
          handler.reject(
            DioException(
              requestOptions: options,
              error: 'Unexpected method: ${body['method']}',
              type: DioExceptionType.unknown,
            ),
          );
          return;
        }
        responder(options, handler);
      },
    ),
  );
  return client;
}

Map<String, _Responder> _successResponders() {
  return <String, _Responder>{
    'initialize': (options, handler) =>
        _respondJson(options, handler, _initializeResponse()),
    'notifications/initialized': (options, handler) =>
        _respondValue(options, handler, null, statusCode: 202),
    'tools/list': (options, handler) =>
        _respondJson(options, handler, _toolsResponse()),
  };
}

void main() {
  group('McpProbeService', () {
    test('performs initialize, initialized and tools/list in order', () async {
      final captured = <RequestOptions>[];
      final client = _client(_successResponders(), captured: captured);
      final service = McpProbeService(client: client);

      final result = await service.probe(token: '  Bearer abc\n');

      expect(result.isSuccess, isTrue);
      expect(result.serverName, 'luminous-mcp-server');
      expect(result.serverVersion, '1.0.0');
      expect(result.protocolVersion, '2025-06-18');
      expect(result.tools.map((tool) => tool.name), [
        'query_school',
        'list_schools',
      ]);
      expect(result.tools.first.description, '学校详情');

      expect(captured.map((options) => (options.data as Map)['method']), [
        'initialize',
        'notifications/initialized',
        'tools/list',
      ]);
      for (final options in captured) {
        expect(options.headers['Accept'], McpConstants.acceptHeader);
        expect(options.headers['Content-Type'], 'application/json');
        expect(
          options.headers['Mcp-Protocol-Version'],
          McpConstants.protocolVersion,
        );
        expect(options.headers['Authorization'], 'Bearer abc');
      }

      client.dispose();
    });

    test('omits authorization header when no token is provided', () async {
      final captured = <RequestOptions>[];
      final client = _client(_successResponders(), captured: captured);

      final result = await McpProbeService(client: client).probe(token: '');

      expect(result.isSuccess, isTrue);
      expect(captured.first.headers.containsKey('Authorization'), isFalse);

      client.dispose();
    });

    test('maps 401 to unauthorized', () async {
      final client = _client(<String, _Responder>{
        'initialize': (options, handler) => handler.reject(
          DioException(
            requestOptions: options,
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: 401,
              data: <String, dynamic>{'code': 401},
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
      });

      final result = await McpProbeService(client: client).probe();

      expect(result.failure, McpProbeFailure.unauthorized);
      client.dispose();
    });

    test('maps 429 to rateLimited', () async {
      final client = _client(<String, _Responder>{
        'initialize': (options, handler) => handler.reject(
          DioException(
            requestOptions: options,
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: 429,
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
      });

      final result = await McpProbeService(client: client).probe();

      expect(result.failure, McpProbeFailure.rateLimited);
      client.dispose();
    });

    test('maps 502 to server', () async {
      final client = _client(<String, _Responder>{
        'initialize': (options, handler) => handler.reject(
          DioException(
            requestOptions: options,
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: 502,
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
      });

      final result = await McpProbeService(client: client).probe();

      expect(result.failure, McpProbeFailure.server);
      client.dispose();
    });

    test('maps json-rpc errors to protocol failures', () async {
      final responders = _successResponders();
      responders['tools/list'] = (options, handler) =>
          _respondJson(options, handler, <String, dynamic>{
            'jsonrpc': '2.0',
            'id': 2,
            'error': <String, dynamic>{
              'code': -32601,
              'message': 'method not found',
            },
          });
      final client = _client(responders);

      final result = await McpProbeService(client: client).probe();

      expect(result.failure, McpProbeFailure.protocol);
      expect(result.detail, contains('-32601'));
      client.dispose();
    });

    test('maps non-json responses to protocol failures', () async {
      final client = _client(<String, _Responder>{
        'initialize': (options, handler) =>
            _respondValue(options, handler, '<html>bad gateway</html>'),
      });

      final result = await McpProbeService(client: client).probe();

      expect(result.failure, McpProbeFailure.protocol);
      client.dispose();
    });

    test('tolerates missing tool descriptions', () async {
      final responders = _successResponders();
      responders['tools/list'] = (options, handler) =>
          _respondJson(options, handler, <String, dynamic>{
            'jsonrpc': '2.0',
            'id': 2,
            'result': <String, dynamic>{
              'tools': <Map<String, dynamic>>[
                <String, dynamic>{'name': 'ping'},
              ],
            },
          });
      final client = _client(responders);

      final result = await McpProbeService(client: client).probe();

      expect(result.isSuccess, isTrue);
      expect(result.tools.single.name, 'ping');
      expect(result.tools.single.description, '');
      client.dispose();
    });

    test('decodes sse-formatted responses as a fallback', () async {
      final client = _client(<String, _Responder>{
        'initialize': (options, handler) => _respondValue(
          options,
          handler,
          'event: message\n'
          'data: {"jsonrpc":"2.0","id":1,"result":'
          '{"protocolVersion":"2025-06-18","serverInfo":'
          '{"name":"luminous-mcp-server","version":"1.0.0"}}}\n\n',
        ),
        'notifications/initialized': (options, handler) =>
            _respondValue(options, handler, null, statusCode: 202),
        'tools/list': (options, handler) => _respondValue(
          options,
          handler,
          'data: {"jsonrpc":"2.0","id":2,"result":{"tools":'
          '[{"name":"get_bus"}]}}\n\n',
        ),
      });

      final result = await McpProbeService(client: client).probe();

      expect(result.isSuccess, isTrue);
      expect(result.tools.single.name, 'get_bus');
      client.dispose();
    });

    test('treats an empty notifications response as success', () async {
      final responders = _successResponders();
      responders['notifications/initialized'] = (options, handler) =>
          _respondValue(options, handler, null, statusCode: 202);
      final client = _client(responders);

      final result = await McpProbeService(client: client).probe();

      expect(result.isSuccess, isTrue);
      client.dispose();
    });
  });
}
