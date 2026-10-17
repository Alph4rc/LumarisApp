import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client.dart';
import 'package:ios_club_app/features/mcp/mcp_constants.dart';
import 'package:ios_club_app/features/mcp/services/mcp_config_generator.dart';

void main() {
  group('McpConfigGenerator.normalizeToken', () {
    test('trims whitespace and strips bearer prefix', () {
      expect(McpConfigGenerator.normalizeToken('  Bearer abc\n'), 'abc');
      expect(
        McpConfigGenerator.normalizeToken('bearer token-value'),
        'token-value',
      );
    });

    test('removes whitespace inside the token', () {
      expect(McpConfigGenerator.normalizeToken('a\nb c'), 'abc');
    });

    test('returns null for empty input', () {
      expect(McpConfigGenerator.normalizeToken(''), isNull);
      expect(McpConfigGenerator.normalizeToken('   \n'), isNull);
      expect(McpConfigGenerator.normalizeToken('Bearer   '), isNull);
    });
  });

  group('McpConfigGenerator.buildJson', () {
    test('omits headers when token is empty', () {
      final config =
          jsonDecode(McpConfigGenerator.buildJson(null))
              as Map<String, dynamic>;
      final server = config['mcpServers']['luminous'] as Map<String, dynamic>;

      expect(server['url'], McpConstants.endpoint);
      expect(server.containsKey('headers'), isFalse);
    });

    test('emits bearer authorization when token is present', () {
      final config =
          jsonDecode(McpConfigGenerator.buildJson('  Bearer abc\n'))
              as Map<String, dynamic>;
      final server = config['mcpServers']['luminous'] as Map<String, dynamic>;
      final headers = server['headers'] as Map<String, dynamic>;

      expect(headers, <String, dynamic>{'Authorization': 'Bearer abc'});
    });

    test('is pretty printed with two spaces', () {
      final json = McpConfigGenerator.buildJson('abc');

      expect(json, contains('\n  "mcpServers"'));
      expect(json, contains('\n    "luminous"'));
    });
  });

  group('McpConfigGenerator.buildClaudeCodeCommand', () {
    test('includes header when token is present', () {
      final command = McpConfigGenerator.buildClaudeCodeCommand('abc');

      expect(
        command,
        'claude mcp add --transport http luminous '
        '${McpConstants.endpoint} --header "Authorization: Bearer abc"',
      );
    });

    test('omits header when token is empty', () {
      final command = McpConfigGenerator.buildClaudeCodeCommand('  ');

      expect(
        command,
        'claude mcp add --transport http luminous ${McpConstants.endpoint}',
      );
      expect(command, isNot(contains('--header')));
    });
  });

  test('endpoint stays in sync with BasicHttpClient base url', () {
    final client = BasicHttpClient();

    expect(
      '${client.dio.options.baseUrl}${McpConstants.path}',
      McpConstants.endpoint,
    );

    client.dispose();
  });
}
