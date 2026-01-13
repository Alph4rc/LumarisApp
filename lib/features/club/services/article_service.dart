import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:ios_club_app/features/club/services/api_client.dart';
import 'package:ios_club_app/features/club/models/article_model.dart';
import 'package:ios_club_app/features/club/models/article_create_dto.dart';
import 'package:ios_club_app/features/club/models/article_update_dto.dart';

class ArticleService {
  /// 获取所有文章
  static Future<List<ArticleModel>?> getAllArticles() async {
    try {
      final response = await ApiClient.get('/Article');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching articles: $e');
      }
    }
    return null;
  }

  /// 创建文章
  static Future<ArticleModel?> createArticle(ArticleCreateDto articleData) async {
    try {
      final response = await ApiClient.post('/Article', body: articleData.toJson());
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ArticleModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error creating article: $e');
      }
    }
    return null;
  }

  /// 根据路径获取文章
  static Future<ArticleModel?> getArticleByPath(String path) async {
    try {
      final response = await ApiClient.get('/Article/$path');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return ArticleModel.fromJson(data);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching article by path: $e');
      }
    }
    return null;
  }

  /// 更新文章
  static Future<bool> updateArticle(String path, ArticleUpdateDto articleData) async {
    try {
      final response = await ApiClient.post('/Article/update/$path', body: articleData.toJson());
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating article: $e');
      }
    }
    return false;
  }

  /// 删除文章
  static Future<bool> deleteArticle(String path) async {
    try {
      final response = await ApiClient.post('/Article/delete/$path');
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting article: $e');
      }
    }
    return false;
  }

  /// 搜索文章（带高亮）
  static Future<List<dynamic>?> searchArticlesWithHighlights(String keyword) async {
    try {
      final response = await ApiClient.get('/Article/search/highlights?keyword=$keyword');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        final List<dynamic>? data = apiResponse['data'];
        return data;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching articles with highlights: $e');
      }
    }
    return null;
  }

  /// 获取文章分类
  static Future<Map<String, dynamic>?> getCategories() async {
    try {
      final response = await ApiClient.get('/Article/category');
      if (response.statusCode == 200) {
        final Map<String, dynamic> apiResponse = jsonDecode(response.body);
        return apiResponse['data'];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching categories: $e');
      }
    }
    return null;
  }

  /// 更新文章顺序
  ///
  /// @param orders 文章路径到顺序的映射，例如 {"article1": 1, "article2": 2}
  static Future<bool> updateArticleOrders(Map<String, int> orders) async {
    try {
      final response = await ApiClient.post('/Article/update-orders', body: orders);
      return response.statusCode == 200;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating article orders: $e');
      }
    }
    return false;
  }
}