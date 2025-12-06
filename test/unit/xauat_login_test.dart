import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/xauat_login.dart';

void main() {
  group('XAUATLogin', () {
    late XAUATLogin xauatLogin;

    setUp(() {
      xauatLogin = XAUATLogin();
    });

    tearDown(() {
      xauatLogin.dispose();
    });

    test('should create instance', () {
      expect(xauatLogin, isNotNull);
    });

    test('should create LoginTokenModel with default values', () {
      final token = LoginTokenModel();
      
      expect(token.eduCookie, '');
      expect(token.ssoCookie, '');
      expect(token.success, true);
      expect(token.message, '');
    });

    test('should create LoginTokenModel with provided values', () {
      final token = LoginTokenModel(
        eduCookie: 'edu_cookie',
        ssoCookie: 'sso_cookie',
        success: false,
        message: 'error message',
      );
      
      expect(token.eduCookie, 'edu_cookie');
      expect(token.ssoCookie, 'sso_cookie');
      expect(token.success, false);
      expect(token.message, 'error message');
    });

    test('should convert LoginTokenModel to JSON', () {
      final token = LoginTokenModel(
        eduCookie: 'edu_cookie',
        ssoCookie: 'sso_cookie',
        success: false,
        message: 'error message',
      );
      
      final json = token.toJson();
      
      expect(json['eduCookie'], 'edu_cookie');
      expect(json['ssoCookie'], 'sso_cookie');
      expect(json['success'], false);
      expect(json['message'], 'error message');
    });

    test('_randomString should generate string with correct length', () {
      final randomString = xauatLogin.randomStringTest(10);
      expect(randomString.length, 10);
    });

    test('_randomString should generate different strings on multiple calls', () {
      final string1 = xauatLogin.randomStringTest(10);
      final string2 = xauatLogin.randomStringTest(10);
      final string3 = xauatLogin.randomStringTest(10);
      
      // 虽然理论上可能重复，但概率极低
      expect(string1, isNot(equals(string2)));
      expect(string1, isNot(equals(string3)));
      expect(string2, isNot(equals(string3)));
    });

    test('_randomString should handle edge cases for length', () {
      // 长度为0
      final emptyString = xauatLogin.randomStringTest(0);
      expect(emptyString, isEmpty);
      expect(emptyString.length, 0);
      
      // 非常长的字符串
      final longString = xauatLogin.randomStringTest(1000);
      expect(longString.length, 1000);
      
      // 长度为1
      final singleCharString = xauatLogin.randomStringTest(1);
      expect(singleCharString.length, 1);
    });

    test('_buildCookieString should build correct cookie string', () {
      final cookies = <String, String>{
        'cookie1': 'value1',
        'cookie2': 'value2',
      };
      
      final cookieString = xauatLogin.buildCookieStringTest(cookies);
      // 顺序可能不同，所以我们需要检查是否包含这些值
      expect(cookieString, contains('cookie1=value1'));
      expect(cookieString, contains('cookie2=value2'));
      expect(cookieString, contains('; '));
    });

    test('_buildCookieString should handle empty cookies map', () {
      final cookies = <String, String>{};
      final cookieString = xauatLogin.buildCookieStringTest(cookies);
      expect(cookieString, isEmpty);
    });

    test('_buildCookieString should handle single cookie', () {
      final cookies = <String, String>{
        'singleCookie': 'singleValue',
      };
      final cookieString = xauatLogin.buildCookieStringTest(cookies);
      expect(cookieString, 'singleCookie=singleValue');
      expect(cookieString, isNot(contains('; ')));
    });

    test('_buildCookieString should handle cookies with special characters', () {
      final cookies = <String, String>{
        'cookie with spaces': 'value with spaces',
        'cookie=with=equals': 'value=with=equals',
        'cookie;with;semicolons': 'value;with;semicolons',
      };
      final cookieString = xauatLogin.buildCookieStringTest(cookies);
      expect(cookieString, contains('cookie with spaces=value with spaces'));
      expect(cookieString, contains('cookie=with=equals=value=with=equals'));
      expect(cookieString, contains('cookie;with;semicolons=value;with;semicolons'));
    });

    test('LoginTokenModel should handle empty messages', () {
      final token = LoginTokenModel(
        success: false,
        message: '',
      );
      expect(token.message, '');
      expect(token.success, false);
    });

    test('LoginTokenModel should handle long messages', () {
      final longMessage = 'a' * 1000;
      final token = LoginTokenModel(
        success: false,
        message: longMessage,
      );
      expect(token.message, longMessage);
      expect(token.message.length, 1000);
    });

    test('LoginTokenModel should correctly serialize boolean success field', () {
      final successToken = LoginTokenModel(success: true);
      final failureToken = LoginTokenModel(success: false);
      
      expect(successToken.toJson()['success'], true);
      expect(failureToken.toJson()['success'], false);
    });

    // Test the dispose method
    test('should dispose correctly', () {
      // Just verify it doesn't throw an exception
      expect(() => xauatLogin.dispose(), returnsNormally);
    });

    // Test that the instance has correct initial state
    test('should have correct initial state', () {
      // Verify that the instance is properly initialized
      expect(() => xauatLogin.randomStringTest(5), returnsNormally);
      expect(() => xauatLogin.buildCookieStringTest({'test': 'value'}), returnsNormally);
    });
  });
  
  group('LoginTokenModel', () {
    test('should have correct equality behavior', () {
      final token1 = LoginTokenModel(
        eduCookie: 'edu1',
        ssoCookie: 'sso1',
        success: true,
        message: 'success',
      );
      
      final token2 = LoginTokenModel(
        eduCookie: 'edu1',
        ssoCookie: 'sso1',
        success: true,
        message: 'success',
      );
      
      final token3 = LoginTokenModel(
        eduCookie: 'edu2',
        ssoCookie: 'sso2',
        success: false,
        message: 'failure',
      );
      
      // Same values should be equal
      expect(token1.toJson(), equals(token2.toJson()));
      
      // Different values should not be equal
      expect(token1.toJson(), isNot(equals(token3.toJson())));
    });
    
    test('should have correct default values', () {
      // Test that the model has correct default values
      final token = LoginTokenModel();
      
      expect(token.eduCookie, equals(''));
      expect(token.ssoCookie, equals(''));
      expect(token.success, equals(true));
      expect(token.message, equals(''));
    });
    
    test('should handle boolean values correctly', () {
      // Test that the success field handles both true and false values correctly
      final successToken = LoginTokenModel(success: true);
      final failureToken = LoginTokenModel(success: false);
      
      expect(successToken.success, isTrue);
      expect(failureToken.success, isFalse);
      
      // Verify that the JSON conversion handles booleans correctly
      expect(successToken.toJson()['success'], isTrue);
      expect(failureToken.toJson()['success'], isFalse);
    });
  });
}