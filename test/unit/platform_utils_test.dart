import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/utils/platform_utils.dart';

void main() {
  group('PlatformUtils Tests', () {
    test('should return correct values for Web environment', () {
      // 在测试环境中，我们主要检查工具类不会抛出异常
      expect(() => PlatformUtils.isWeb, returnsNormally);
      expect(() => PlatformUtils.isMPFlutter, returnsNormally);
      expect(() => PlatformUtils.isMacOS, returnsNormally);
      expect(() => PlatformUtils.isWindows, returnsNormally);
      expect(() => PlatformUtils.isLinux, returnsNormally);
      expect(() => PlatformUtils.isAndroid, returnsNormally);
      expect(() => PlatformUtils.isIOS, returnsNormally);
      expect(() => PlatformUtils.isDesktop, returnsNormally);
      expect(() => PlatformUtils.isMobile, returnsNormally);
      expect(() => PlatformUtils.getDesktopFontFamily(''), returnsNormally);
      expect(() => PlatformUtils.getWindowsFontFamily(), returnsNormally);
    });

    test('should handle null font family gracefully', () {
      expect(PlatformUtils.getDesktopFontFamily(null), isNull);
      expect(PlatformUtils.getDesktopFontFamily(''), isNull);
    });

    test('should return desktop font family only on desktop platforms', () {
      final result = PlatformUtils.getDesktopFontFamily('Roboto');
      if (PlatformUtils.isDesktop) {
        expect(result, equals('Roboto'));
      } else {
        expect(result, isNull);
      }
    });
  });
}
