import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/basic/services/basic_http_client.dart';
import 'package:ios_club_app/features/mcp/models/mcp_probe_result.dart';
import 'package:ios_club_app/features/mcp/models/mcp_tool.dart';
import 'package:ios_club_app/features/mcp/services/mcp_config_generator.dart';
import 'package:ios_club_app/features/mcp/services/mcp_probe_service.dart';
import 'package:ios_club_app/features/mcp/services/mcp_token_store.dart';
import 'package:ios_club_app/l10n/app_localizations.dart';
import 'package:ios_club_app/ui/pages/mcp_page/mcp_page.dart';

class _FakeTokenStore extends McpTokenStore {
  _FakeTokenStore([this.value]);

  String? value;

  @override
  Future<String?> read() async => value;

  @override
  Future<bool> save(String token) async {
    value = McpConfigGenerator.normalizeToken(token);
    return true;
  }

  @override
  Future<bool> clear() async {
    value = null;
    return true;
  }
}

class _FakeProbeService extends McpProbeService {
  _FakeProbeService(this.result) : super(client: BasicHttpClient());

  final McpProbeResult result;
  String? lastToken;

  @override
  Future<McpProbeResult> probe({String? token}) async {
    lastToken = token;
    return result;
  }
}

Widget _buildApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      ...GlobalMaterialLocalizations.delegates,
    ],
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the service address and token state', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        McpPage(
          tokenStore: _FakeTokenStore(),
          probeService: _FakeProbeService(const McpProbeResult()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('https://luminous.xauat.site/mcp'),
      findsWidgets,
    );
    expect(find.text('No token set'), findsOneWidget);
    expect(find.text('Test connection'), findsOneWidget);
  });

  testWidgets('updates the json preview as the token changes', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        McpPage(
          tokenStore: _FakeTokenStore(),
          probeService: _FakeProbeService(const McpProbeResult()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final field = find.byType(CupertinoTextField);

    await tester.enterText(field, 'test-token');
    await tester.pump();

    expect(
      find.textContaining('"Authorization": "Bearer test-token"'),
      findsWidgets,
    );

    await tester.enterText(field, '');
    await tester.pump();

    expect(find.textContaining('"Authorization"'), findsNothing);
  });

  testWidgets('saves the normalized token', (tester) async {
    final store = _FakeTokenStore();

    await tester.pumpWidget(
      _buildApp(
        McpPage(
          tokenStore: store,
          probeService: _FakeProbeService(const McpProbeResult()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(CupertinoTextField), '  Bearer abc\n');
    await tester.pump();

    await tester.ensureVisible(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(store.value, 'abc');
    expect(find.text('Token saved'), findsWidgets);
  });

  testWidgets('shows probe results and available tools', (tester) async {
    final probe = _FakeProbeService(
      const McpProbeResult(
        serverName: 'luminous-mcp-server',
        serverVersion: '1.0.0',
        protocolVersion: '2025-06-18',
        tools: <McpTool>[McpTool(name: 'query_school', description: '学校详情')],
      ),
    );

    await tester.pumpWidget(
      _buildApp(
        McpPage(tokenStore: _FakeTokenStore('abc'), probeService: probe),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Test connection'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test connection'));
    await tester.pumpAndSettle();

    expect(probe.lastToken, 'abc');
    expect(find.text('Connection successful'), findsOneWidget);
    expect(find.text('Available tools (1)'), findsOneWidget);
    expect(find.text('query_school'), findsOneWidget);
    expect(find.text('学校详情'), findsOneWidget);
  });

  testWidgets('copies the generated json config', (tester) async {
    final clipboard = <String, dynamic>{};
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            clipboard.addAll(Map<String, dynamic>.from(call.arguments as Map));
          }
          return null;
        });

    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    await tester.pumpWidget(
      _buildApp(
        McpPage(
          tokenStore: _FakeTokenStore('abc'),
          probeService: _FakeProbeService(const McpProbeResult()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Copy JSON config'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy JSON config'));
    await tester.pumpAndSettle();

    expect(clipboard['text'], McpConfigGenerator.buildJson('abc'));
  });
}
