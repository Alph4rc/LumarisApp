import 'package:get/get.dart';
import 'package:ios_club_app/core/models/result.dart';
import 'package:ios_club_app/core/utils/error_logger.dart';

/// Store基类，提供统一的错误处理能力
///
/// 所有Store都应该继承此基类以获得：
/// - 统一的loading状态管理
/// - 统一的错误状态管理
/// - 便捷的Result处理方法
///
/// 使用示例：
/// ```dart
/// class CourseStore extends BaseStore {
///   final courses = <CourseModel>[].obs;
///
///   Future<void> loadCourses() async {
///     await handleResult(
///       EduApiService.getCourses(),
///       (data) => courses.assignAll(data),
///     );
///   }
/// }
/// ```
abstract class BaseStore extends GetxController {
  /// 加载状态
  final isLoading = false.obs;

  /// 错误消息
  final errorMessage = ''.obs;

  /// 清除错误消息
  void clearError() {
    errorMessage.value = '';
  }

  /// 处理Result结果
  ///
  /// 自动管理loading状态和错误状态
  /// 成功时调用onSuccess回调
  /// 失败时设置errorMessage
  Future<void> handleResult<T>(
    Future<Result<T>> operation,
    void Function(T data) onSuccess,
  ) async {
    isLoading.value = true;
    clearError();

    try {
      final result = await operation;
      result.when(
        success: (data) {
          onSuccess(data);
        },
        failure: (error) {
          errorMessage.value = error.userMessage;
          ErrorLogger.logError(error);
        },
      );
    } catch (e, stackTrace) {
      errorMessage.value = '操作失败，请重试';
      ErrorLogger.logError(e, stackTrace);
    } finally {
      isLoading.value = false;
    }
  }

  /// 处理Result结果（带返回值）
  ///
  /// 与handleResult类似，但支持返回值
  /// 失败时返回null
  Future<R?> handleResultWithReturn<T, R>(
    Future<Result<T>> operation,
    R Function(T data) onSuccess,
  ) async {
    isLoading.value = true;
    clearError();

    try {
      final result = await operation;
      return result.when(
        success: (data) {
          return onSuccess(data);
        },
        failure: (error) {
          errorMessage.value = error.userMessage;
          ErrorLogger.logError(error);
          return null;
        },
      );
    } catch (e, stackTrace) {
      errorMessage.value = '操作失败，请重试';
      ErrorLogger.logError(e, stackTrace);
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// 处理Result结果（不管理loading状态）
  ///
  /// 适用于不需要显示loading的场景
  Future<void> handleResultWithoutLoading<T>(
    Future<Result<T>> operation,
    void Function(T data) onSuccess,
  ) async {
    clearError();

    try {
      final result = await operation;
      result.when(
        success: (data) {
          onSuccess(data);
        },
        failure: (error) {
          errorMessage.value = error.userMessage;
          ErrorLogger.logError(error);
        },
      );
    } catch (e, stackTrace) {
      errorMessage.value = '操作失败，请重试';
      ErrorLogger.logError(e, stackTrace);
    }
  }

  /// 检查是否有错误
  bool get hasError => errorMessage.value.isNotEmpty;

  /// 检查是否正在加载
  bool get loading => isLoading.value;
}
