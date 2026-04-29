import 'package:flutter_test/flutter_test.dart';
import 'package:ios_club_app/core/models/result.dart';
import 'package:ios_club_app/state/base_store.dart';

class _TestStore extends BaseStore {}

void main() {
  group('BaseStore', () {
    test('should_update_state_and_call_success_when_result_succeeds', () async {
      final store = _TestStore();
      var captured = '';

      await store.handleResult(
        Future.value(Result.success('ok')),
        (data) => captured = data,
      );

      expect(captured, 'ok');
      expect(store.loading, isFalse);
      expect(store.hasError, isFalse);
    });

    test('should_set_error_message_when_result_fails', () async {
      final store = _TestStore();

      await store.handleResult(
        Future.value(Result.failure(AppError.business('业务失败'))),
        (_) => fail('success callback should not run'),
      );

      expect(store.loading, isFalse);
      expect(store.hasError, isTrue);
      expect(store.errorMessage, '业务失败');
    });

    test('should_set_generic_error_when_operation_throws', () async {
      final store = _TestStore();

      await store.handleResult<String>(
        Future<String>.error(StateError('boom'))
            .then((value) => Result.success(value)),
        (_) => fail('success callback should not run'),
      );

      expect(store.loading, isFalse);
      expect(store.errorMessage, '操作失败，请重试');
    });

    test('should_return_value_from_successful_result', () async {
      final store = _TestStore();

      final value = await store.handleResultWithReturn(
        Future.value(Result.success(21)),
        (data) => data * 2,
      );

      expect(value, 42);
      expect(store.loading, isFalse);
      expect(store.hasError, isFalse);
    });

    test('should_return_null_from_failed_result_with_return', () async {
      final store = _TestStore();

      final value = await store.handleResultWithReturn<int, int>(
        Future.value(Result.failure(AppError.validation('参数错误'))),
        (data) => data * 2,
      );

      expect(value, isNull);
      expect(store.loading, isFalse);
      expect(store.errorMessage, '参数错误');
    });

    test('should_handle_result_without_loading', () async {
      final store = _TestStore();
      store.state = store.state.copyWith(isLoading: true);
      var captured = 0;

      await store.handleResultWithoutLoading(
        Future.value(Result.success(7)),
        (data) => captured = data,
      );

      expect(captured, 7);
      expect(store.loading, isTrue);
      expect(store.hasError, isFalse);
    });
  });
}
