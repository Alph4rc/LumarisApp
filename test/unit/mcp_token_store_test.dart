import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/features/mcp/mcp_constants.dart';
import 'package:ios_club_app/features/mcp/services/mcp_token_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final storage = <String, String>{};
  const tokenStore = McpTokenStore();

  setUp(() {
    storage.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          final arguments =
              call.arguments as Map<dynamic, dynamic>? ?? const {};
          switch (call.method) {
            case 'write':
              final value = arguments['value'] as String?;
              if (value == null) {
                storage.remove(arguments['key'] as String);
              } else {
                storage[arguments['key'] as String] = value;
              }
              return null;
            case 'read':
              return storage[arguments['key'] as String];
            case 'delete':
              storage.remove(arguments['key'] as String);
              return null;
            default:
              return null;
          }
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('save normalizes the token before storing it', () async {
    expect(await tokenStore.save('  Bearer abc\n'), isTrue);

    expect(storage[McpConstants.tokenStorageKey], 'abc');
    expect(await tokenStore.read(), 'abc');
  });

  test('saving an empty token clears the stored value', () async {
    await tokenStore.save('abc');
    expect(await tokenStore.save('   '), isTrue);

    expect(storage.containsKey(McpConstants.tokenStorageKey), isFalse);
    expect(await tokenStore.read(), isNull);
  });

  test('clear removes the stored token', () async {
    await tokenStore.save('abc');

    expect(await tokenStore.clear(), isTrue);
    expect(await tokenStore.read(), isNull);
  });

  test('platform failures surface as false and null', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          throw PlatformException(code: 'err', message: 'mock error');
        });

    expect(await tokenStore.save('abc'), isFalse);
    expect(await tokenStore.read(), isNull);
  });
}
