import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/services/gzip_service.dart';

void main() {
  group('GzipService', () {
    test('should compress and decompress string losslessly', () async {
      const input = 'Hello 你好 123 !@#';
      final compressed = await GzipService.compress(input);
      final decompressed = await GzipService.decompress(compressed);

      expect(compressed, isNotEmpty);
      expect(decompressed, input);
    });

    test('should support empty string', () async {
      final compressed = await GzipService.compress('');
      final decompressed = await GzipService.decompress(compressed);

      expect(decompressed, '');
    });
  });
}
