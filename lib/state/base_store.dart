import 'package:ios_club_app/core/models/result.dart';
import 'package:ios_club_app/core/utils/error_logger.dart';
import 'package:ios_club_app/state/app_states.dart';

abstract class BaseStore {
  BaseStoreState state = const BaseStoreState();

  bool get loading => state.isLoading;
  String get errorMessage => state.errorMessage;
  bool get hasError => state.errorMessage.isNotEmpty;

  void clearError() {
    state = state.copyWith(errorMessage: '');
  }

  Future<void> handleResult<T>(
    Future<Result<T>> operation,
    void Function(T data) onSuccess,
  ) async {
    state = state.copyWith(isLoading: true);
    clearError();

    try {
      final result = await operation;
      result.when(
        success: onSuccess,
        failure: (error) {
          state = state.copyWith(errorMessage: error.userMessage);
          ErrorLogger.logError(error);
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(errorMessage: '操作失败，请重试');
      ErrorLogger.logError(e, stackTrace);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<R?> handleResultWithReturn<T, R>(
    Future<Result<T>> operation,
    R Function(T data) onSuccess,
  ) async {
    state = state.copyWith(isLoading: true);
    clearError();

    try {
      final result = await operation;
      return result.when(
        success: onSuccess,
        failure: (error) {
          state = state.copyWith(errorMessage: error.userMessage);
          ErrorLogger.logError(error);
          return null;
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(errorMessage: '操作失败，请重试');
      ErrorLogger.logError(e, stackTrace);
      return null;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> handleResultWithoutLoading<T>(
    Future<Result<T>> operation,
    void Function(T data) onSuccess,
  ) async {
    clearError();

    try {
      final result = await operation;
      result.when(
        success: onSuccess,
        failure: (error) {
          state = state.copyWith(errorMessage: error.userMessage);
          ErrorLogger.logError(error);
        },
      );
    } catch (e, stackTrace) {
      state = state.copyWith(errorMessage: '操作失败，请重试');
      ErrorLogger.logError(e, stackTrace);
    }
  }
}
