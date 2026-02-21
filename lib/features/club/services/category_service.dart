import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

/// 分类服务类
///
/// 负责处理文章分类的增删改查操作
class CategoryService {
  /// 获取所有分类
  static Future<List<dynamic>?> getAllCategories() async {
    try {
      final response = await ApiClient.get('/Category/all');
      return ApiResponseHelper.parseRaw<List<dynamic>>(
        response,
        errorMessage: 'Error fetching all categories',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching all categories: $e');
      }
      return null;
    }
  }

  /// 根据名称获取分类
  static Future<Map<String, dynamic>?> getCategoryByName(String name) async {
    try {
      final response = await ApiClient.get('/Category/$name');
      return ApiResponseHelper.parseRaw<Map<String, dynamic>>(
        response,
        errorMessage: 'Error fetching category by name',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching category by name: $e');
      }
      return null;
    }
  }

  /// 根据ID获取分类
  static Future<Map<String, dynamic>?> getCategoryById(String id) async {
    try {
      final response = await ApiClient.get('/Category/byId/$id');
      return ApiResponseHelper.parseRaw<Map<String, dynamic>>(
        response,
        errorMessage: 'Error fetching category by id',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching category by id: $e');
      }
      return null;
    }
  }

  /// 获取分类下的所有文章
  static Future<List<dynamic>?> getArticlesByCategory(String categoryId) async {
    try {
      final response = await ApiClient.get('/Category/articles/$categoryId');
      return ApiResponseHelper.parseRaw<List<dynamic>>(
        response,
        errorMessage: 'Error fetching articles by category',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching articles by category: $e');
      }
      return null;
    }
  }

  /// 创建或更新分类
  static Future<String?> createOrUpdateCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await ApiClient.post('/Category/CreateOrUpdate', body: categoryData);
      return ApiResponseHelper.parseString(
        response,
        errorMessage: 'Error creating or updating category',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error creating or updating category: $e');
      }
      return null;
    }
  }

  /// 删除分类
  static Future<String?> deleteCategory(String name) async {
    try {
      final response = await ApiClient.get('/Category/Delete/$name');
      return ApiResponseHelper.parseString(
        response,
        errorMessage: 'Error deleting category',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error deleting category: $e');
      }
      return null;
    }
  }

  /// 更新分类顺序
  static Future<String?> updateCategoryOrder(String name, int order) async {
    try {
      final response = await ApiClient.post('/Category/UpdateOrder/$name/$order');
      return ApiResponseHelper.parseString(
        response,
        errorMessage: 'Error updating category order',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating category order: $e');
      }
      return null;
    }
  }

  /// 批量更新分类顺序
  ///
  /// @param orders 分类名称到顺序的映射，例如 {"category1": 1, "category2": 2}
  static Future<String?> updateCategoryOrders(Map<String, int> orders) async {
    try {
      final response = await ApiClient.post('/Category/UpdateOrders', body: orders);
      return ApiResponseHelper.parseString(
        response,
        errorMessage: 'Error updating category orders',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating category orders: $e');
      }
      return null;
    }
  }
}
