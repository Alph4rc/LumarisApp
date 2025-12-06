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

  /// 搜索文章
  static Future<List<ArticleModel>?> searchArticles(String keyword) async {
    try {
      final response = await ApiClient.get('/Article/search?keyword=$keyword');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error searching articles: $e');
      }
    }
    return null;
  }
}