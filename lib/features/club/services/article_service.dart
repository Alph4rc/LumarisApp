import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/article_model.dart';
import 'package:ios_club_app/features/club/models/article_create_dto.dart';
import 'package:ios_club_app/features/club/models/article_update_dto.dart';
import 'package:ios_club_app/features/club/utils/api_response_helper.dart';
import 'package:ios_club_app/core/utils/app_logger.dart';

class ArticleService {
  /// 获取所有文章
  static Future<List<ArticleModel>?> getAllArticles() async {
    try {
      final response = await ApiClient.get('/Article');
      return ApiResponseHelper.parseList(
        response,
        ArticleModel.fromJson,
        errorMessage: 'Error fetching articles',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching articles: $e');
      }
      return null;
    }
  }

  /// 创建文章
  static Future<ArticleModel?> createArticle(ArticleCreateDto articleData) async {
    try {
      final response = await ApiClient.post('/Article', body: articleData.toJson());
      return ApiResponseHelper.parseSingleObject(
        response,
        ArticleModel.fromJson,
        errorMessage: 'Error creating article',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error creating article: $e');
      }
      return null;
    }
  }

  /// 根据路径获取文章
  static Future<ArticleModel?> getArticleByPath(String path) async {
    try {
      final response = await ApiClient.get('/Article/$path');
      return ApiResponseHelper.parseSingleObject(
        response,
        ArticleModel.fromJson,
        errorMessage: 'Error fetching article by path',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching article by path: $e');
      }
      return null;
    }
  }

  /// 更新文章
  static Future<bool> updateArticle(String path, ArticleUpdateDto articleData) async {
    try {
      final response = await ApiClient.post('/Article/update/$path', body: articleData.toJson());
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error updating article',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating article: $e');
      }
      return false;
    }
  }

  /// 删除文章
  static Future<bool> deleteArticle(String path) async {
    try {
      final response = await ApiClient.post('/Article/delete/$path');
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error deleting article',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error deleting article: $e');
      }
      return false;
    }
  }

  /// 搜索文章（带高亮）
  static Future<List<dynamic>?> searchArticlesWithHighlights(String keyword) async {
    try {
      final response = await ApiClient.get('/Article/search/highlights?keyword=$keyword');
      return ApiResponseHelper.parseRaw<List<dynamic>>(
        response,
        errorMessage: 'Error searching articles with highlights',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error searching articles with highlights: $e');
      }
      return null;
    }
  }

  /// 获取文章分类
  static Future<Map<String, dynamic>?> getCategories() async {
    try {
      final response = await ApiClient.get('/Article/category');
      return ApiResponseHelper.parseRaw<Map<String, dynamic>>(
        response,
        errorMessage: 'Error fetching categories',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error fetching categories: $e');
      }
      return null;
    }
  }

  /// 更新文章顺序
  ///
  /// @param orders 文章路径到顺序的映射，例如 {"article1": 1, "article2": 2}
  static Future<bool> updateArticleOrders(Map<String, int> orders) async {
    try {
      final response = await ApiClient.post('/Article/update-orders', body: orders);
      return ApiResponseHelper.parseBool(
        response,
        errorMessage: 'Error updating article orders',
      );
    } catch (e) {
      if (kDebugMode) {
        AppLogger.error('Error updating article orders: $e');
      }
      return false;
    }
  }
}