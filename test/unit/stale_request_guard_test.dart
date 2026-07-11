import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/utils/stale_request_guard.dart';

void main() {
  group('StaleRequestGuard', () {
    test('should_mark_previous_request_stale_when_new_request_begins', () {
      final guard = StaleRequestGuard();

      final firstRequest = guard.beginRequest();
      final secondRequest = guard.beginRequest();

      expect(guard.isCurrent(firstRequest), isFalse);
      expect(guard.isCurrent(secondRequest), isTrue);
    });
  });
}
